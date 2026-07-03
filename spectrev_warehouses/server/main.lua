local ESX = exports['es_extended']:getSharedObject()

-- Laufzeit-Cache aller gekauften Warehouses:  [configId] = { owner, level, progress }
local Warehouses = {}

-- ─────────────────────────────────────────────────────────────────────────────
--  Inventar-Abstraktion  (Devix-Stash-API bzw. ox_inventory)
-- ─────────────────────────────────────────────────────────────────────────────
-- Devix und ox_inventory sprechen Stashes UNTERSCHIEDLICH an:
--   Devix: AddItemStash / RemoveItemStash / GetStashItems (dedizierte Stash-Exports)
--   ox   : AddItem / RemoveItem / GetItem, wobei der Stash als "inv" übergeben wird
-- Diese Schicht kapselt beide Wege hinter Inv.register/add/remove/count.
local function detectBackend()
    if Config.InventoryBackend == 'devix' or Config.InventoryBackend == 'ox' then
        return Config.InventoryBackend
    end
    if GetResourceState(Config.DevixResource) == 'started' then return 'devix' end
    return 'ox'
end

local BACKEND = detectBackend()
local Inv = {}

if BACKEND == 'devix' then
    local dev = exports[Config.DevixResource]
    -- Stash owner-los (feste ID) registrieren; Zugriffskontrolle macht dieses
    -- Script server-seitig über den Warehouse-Besitz (siehe requestOpen).
    function Inv.register(id, label, slots, weight) dev:RegisterStash(id, label, slots, weight) end
    function Inv.add(stash, item, count) return dev:AddItemStash(stash, item, count) and true or false end
    function Inv.remove(stash, item, count) return (dev:RemoveItemStash(stash, item, count)) and true or false end
    function Inv.count(stash, item)
        local items = dev:GetStashItems(stash) or {}
        local total = 0
        for _, it in pairs(items) do
            if it and it.name == item then total = total + (it.amount or it.count or 1) end
        end
        return total
    end
else -- ox_inventory
    local ox = exports.ox_inventory
    function Inv.register(id, label, slots, weight) ox:RegisterStash(id, label, slots, weight) end
    function Inv.add(stash, item, count) return ox:AddItem(stash, item, count) and true or false end
    function Inv.remove(stash, item, count) return ox:RemoveItem(stash, item, count) and true or false end
    function Inv.count(stash, item) return ox:GetItem(stash, item, nil, true) or 0 end
end

-- ─────────────────────────────────────────────────────────────────────────────
--  Helfer
-- ─────────────────────────────────────────────────────────────────────────────
local function getWarehouseConfig(configId)
    for i, wh in ipairs(Config.Warehouses) do
        if wh.id == configId then return wh, i end
    end
end

local function stashId(kind, configId) return ('wh_%s_%s'):format(kind, configId) end

local function registerStashes(configId, level)
    local lvl = Config.Levels[level]
    Inv.register(stashId('input',  configId), 'Rohstoff-Einlass', lvl.inputSlots,  lvl.inputWeight)
    Inv.register(stashId('output', configId), 'Ausgabe',          lvl.outputSlots, lvl.outputWeight)
    Inv.register(stashId('store',  configId), 'Lager',            lvl.storeSlots,  lvl.storeWeight)
end

-- Bucht 'amount' vom konfigurierten Konto ab.
--
-- Absicherung: ESX' ox_inventory-Override (setAccount/addAccount/removeAccountMoney)
-- greift intern auf das upvalue 'Inventory' zu. Feuert das aktive Inventar das Event
-- 'ox_inventory:loadInventory' NICHT (z.B. Devix), bleibt 'Inventory' = nil und der
-- Abbuch-Aufruf wirft einen Fehler. Deshalb buchen wir abgesichert ab und
-- VERIFIZIEREN danach den Kontostand, statt dem (evtl. crashenden) Call zu vertrauen.
local function chargePlayer(xPlayer, amount)
    local account = xPlayer.getAccount(Config.PaymentAccount)
    if not account or account.money < amount then return false end

    local before  = account.money
    local target  = before - amount

    pcall(function()
        xPlayer.removeAccountMoney(Config.PaymentAccount, amount, 'spectrev_warehouses')
    end)

    -- Hat der Override den Betrag bereits abgezogen (vor dem Inventory-Zugriff)?
    local after = xPlayer.getAccount(Config.PaymentAccount)
    if after and after.money <= target then
        return true
    end

    -- Fallback: Kontostand direkt setzen (ebenfalls abgesichert) und erneut prüfen.
    pcall(function()
        xPlayer.setAccountMoney(Config.PaymentAccount, target, 'spectrev_warehouses')
    end)
    local final = xPlayer.getAccount(Config.PaymentAccount)
    return final ~= nil and final.money <= target
end

-- ─────────────────────────────────────────────────────────────────────────────
--  Laden beim Start
-- ─────────────────────────────────────────────────────────────────────────────
CreateThread(function()
    while GetResourceState('oxmysql') ~= 'started' do Wait(100) end
    local rows = MySQL.query.await('SELECT config_id, owner, level, progress FROM spectrev_warehouses') or {}
    for _, r in ipairs(rows) do
        -- Nur laden, wenn der Standort noch in der Config existiert
        if getWarehouseConfig(r.config_id) then
            Warehouses[r.config_id] = {
                owner    = r.owner,
                level    = r.level,
                progress = r.progress + 0.0,
            }
            registerStashes(r.config_id, r.level)
        end
    end
    print(('[spectrev_warehouses] %d Warehouse(s) geladen.'):format(#rows))
end)

-- ─────────────────────────────────────────────────────────────────────────────
--  Zustands-Sync für Clients
-- ─────────────────────────────────────────────────────────────────────────────
local function buildStateFor(identifier)
    local state = {}
    for _, wh in ipairs(Config.Warehouses) do
        local data = Warehouses[wh.id]
        state[wh.id] = {
            owned = data ~= nil,
            mine  = data ~= nil and data.owner == identifier,
            level = data and data.level or 0,
        }
    end
    return state
end

lib.callback.register('spectrev_wh:getState', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return {} end
    return buildStateFor(xPlayer.identifier)
end)

-- ─────────────────────────────────────────────────────────────────────────────
--  Kauf
-- ─────────────────────────────────────────────────────────────────────────────
lib.callback.register('spectrev_wh:buy', function(source, configId)
    local cfg = getWarehouseConfig(configId)
    if not cfg then return false, 'Ungültiges Warehouse.' end
    if Warehouses[configId] then return false, 'Dieses Warehouse ist bereits verkauft.' end

    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false, 'Fehler.' end

    if not chargePlayer(xPlayer, cfg.price) then
        return false, 'Du hast nicht genug Geld.'
    end

    Warehouses[configId] = { owner = xPlayer.identifier, level = 1, progress = 0.0 }
    MySQL.insert.await(
        'INSERT INTO spectrev_warehouses (config_id, owner, level, progress) VALUES (?, ?, 1, 0)',
        { configId, xPlayer.identifier }
    )
    registerStashes(configId, 1)
    TriggerClientEvent('spectrev_wh:refresh', -1)
    return true, 'Warehouse gekauft!'
end)

-- ─────────────────────────────────────────────────────────────────────────────
--  Betreten / Verlassen  (Routing-Bucket + Instanzierung)
-- ─────────────────────────────────────────────────────────────────────────────
lib.callback.register('spectrev_wh:enter', function(source, configId, vehNetId)
    local wh = Warehouses[configId]
    local cfg, index = getWarehouseConfig(configId)
    if not wh or not cfg then return false end

    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or wh.owner ~= xPlayer.identifier then return false end

    local bucket = Config.BucketBase + index
    SetPlayerRoutingBucket(source, bucket)
    if vehNetId and vehNetId ~= 0 then
        local veh = NetworkGetEntityFromNetworkId(vehNetId)
        if veh and veh ~= 0 then SetEntityRoutingBucket(veh, bucket) end
    end
    return { level = wh.level }
end)

lib.callback.register('spectrev_wh:leave', function(source, vehNetId)
    if vehNetId and vehNetId ~= 0 then
        local veh = NetworkGetEntityFromNetworkId(vehNetId)
        if veh and veh ~= 0 then SetEntityRoutingBucket(veh, 0) end
    end
    SetPlayerRoutingBucket(source, 0)
    return true
end)

-- Sicherheitsnetz: beim Disconnect Bucket zurücksetzen
AddEventHandler('playerDropped', function()
    SetPlayerRoutingBucket(source, 0)
end)

-- ─────────────────────────────────────────────────────────────────────────────
--  Stash öffnen (server-authoritativ: prüft Besitz, dann öffnet der Client)
-- ─────────────────────────────────────────────────────────────────────────────
local VALID_KINDS = { input = true, output = true, store = true }

RegisterNetEvent('spectrev_wh:requestOpen', function(configId, kind)
    local src = source
    if not VALID_KINDS[kind] then return end
    local wh = Warehouses[configId]
    if not wh then return end
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or wh.owner ~= xPlayer.identifier then return end
    TriggerClientEvent('spectrev_wh:doOpen', src, stashId(kind, configId))
end)

-- ─────────────────────────────────────────────────────────────────────────────
--  Upgrade
-- ─────────────────────────────────────────────────────────────────────────────
lib.callback.register('spectrev_wh:upgrade', function(source, configId)
    local wh = Warehouses[configId]
    if not wh then return false, 'Warehouse nicht gefunden.' end

    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or wh.owner ~= xPlayer.identifier then
        return false, 'Das ist nicht dein Warehouse.'
    end

    local nextLevel = wh.level + 1
    local lvl = Config.Levels[nextLevel]
    if not lvl then return false, 'Maximales Level bereits erreicht.' end
    if not lvl.upgradePrice then return false, 'Kein Upgrade verfügbar.' end

    if not chargePlayer(xPlayer, lvl.upgradePrice) then
        return false, 'Du hast nicht genug Geld.'
    end

    wh.level = nextLevel
    MySQL.update.await('UPDATE spectrev_warehouses SET level = ? WHERE config_id = ?', { nextLevel, configId })
    -- Stashes mit neuer Kapazität neu registrieren
    registerStashes(configId, nextLevel)
    TriggerClientEvent('spectrev_wh:refresh', -1)
    return true, nextLevel
end)

-- ─────────────────────────────────────────────────────────────────────────────
--  Status (für das Terminal)
-- ─────────────────────────────────────────────────────────────────────────────
lib.callback.register('spectrev_wh:status', function(source, configId)
    local wh = Warehouses[configId]
    if not wh then return false end

    local lvl     = Config.Levels[wh.level]
    local nextLvl = Config.Levels[wh.level + 1]
    local input   = stashId('input', configId)

    -- Übersicht der Rohstoffe im Einlass (nur Items, die in Rezepten vorkommen)
    local seen, summary = {}, {}
    for _, recipe in ipairs(Config.Recipes) do
        for _, ing in ipairs(recipe.input) do
            if not seen[ing.name] then
                seen[ing.name] = true
                local c = Inv.count(input, ing.name)
                if c > 0 then summary[#summary + 1] = ('%s x%d'):format(ing.name, c) end
            end
        end
    end

    return {
        level         = wh.level,
        levelLabel    = lvl.label,
        craftsPerHour = lvl.craftsPerHour,
        nextLevel     = nextLvl and (wh.level + 1) or nil,
        nextLabel     = nextLvl and nextLvl.label or nil,
        upgradePrice  = nextLvl and nextLvl.upgradePrice or nil,
        inputSummary  = #summary > 0 and table.concat(summary, ', ') or 'Einlass ist leer',
    }
end)

-- ─────────────────────────────────────────────────────────────────────────────
--  Verarbeitungs-Tick  (automatisch, auch offline)
-- ─────────────────────────────────────────────────────────────────────────────
-- Versucht EINEN Durchlauf eines Rezepts. Da es für Stashes kein zuverlässiges
-- "CanCarry" gibt, fügen wir die Outputs zuerst hinzu (add gibt bei vollem Stash
-- false zurück) und rollen bei fehlendem Platz zurück. Erst wenn alle Outputs
-- Platz hatten, werden die Inputs entfernt.
local function tryCraft(input, output, recipe)
    -- genug Input?
    for _, ing in ipairs(recipe.input) do
        if Inv.count(input, ing.name) < ing.count then return false end
    end
    -- Outputs mit Rollback bei fehlendem Platz
    local added = {}
    for _, out in ipairs(recipe.output) do
        if Inv.add(output, out.name, out.count) then
            added[#added + 1] = out
        else
            for _, a in ipairs(added) do Inv.remove(output, a.name, a.count) end
            return false -- Ausgabe voll
        end
    end
    -- Inputs verbrauchen
    for _, ing in ipairs(recipe.input) do Inv.remove(input, ing.name, ing.count) end
    return true
end

local function processCrafts(configId, maxCrafts)
    local input  = stashId('input',  configId)
    local output = stashId('output', configId)
    local done = 0

    for _ = 1, maxCrafts do
        local crafted = false
        for _, recipe in ipairs(Config.Recipes) do
            if tryCraft(input, output, recipe) then
                done = done + 1
                crafted = true
                break
            end
        end
        if not crafted then break end -- kein Rezept mehr machbar
    end
    return done
end

CreateThread(function()
    local dtHours = Config.Processing.tickSeconds / 3600.0
    while true do
        Wait(Config.Processing.tickSeconds * 1000)
        for configId, wh in pairs(Warehouses) do
            if wh.owner then
                local lvl = Config.Levels[wh.level]
                wh.progress = wh.progress + lvl.craftsPerHour * dtHours
                local doable = math.floor(wh.progress)
                if doable > 0 then
                    processCrafts(configId, doable)
                    -- Nur den Nachkomma-Rest behalten; unbenutzte ganze Crafts verfallen
                    -- (verhindert unendliches Aufstauen bei leerem Einlass).
                    wh.progress = wh.progress - doable
                    if wh.progress < 0 then wh.progress = 0.0 end
                    MySQL.update('UPDATE spectrev_warehouses SET progress = ? WHERE config_id = ?',
                        { wh.progress, configId })
                end
            end
        end
    end
end)

-- ─────────────────────────────────────────────────────────────────────────────
--  Admin: Warehouse zurücksetzen (Verkauf/Reset)
-- ─────────────────────────────────────────────────────────────────────────────
lib.addCommand('resetwarehouse', { help = 'Warehouse-Besitz zurücksetzen', params = {
    { name = 'id', help = 'config_id des Warehouses', type = 'string' },
}, restricted = 'group.admin' }, function(source, args)
    local configId = args.id
    if not Warehouses[configId] then
        return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'Nicht gefunden.' })
    end
    Warehouses[configId] = nil
    MySQL.update.await('DELETE FROM spectrev_warehouses WHERE config_id = ?', { configId })
    TriggerClientEvent('spectrev_wh:refresh', -1)
    TriggerClientEvent('ox_lib:notify', source, { type = 'success', description = 'Warehouse zurückgesetzt.' })
end)
