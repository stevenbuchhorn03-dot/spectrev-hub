local ESX = exports['es_extended']:getSharedObject()

-- Laufzeit-Cache aller gekauften Warehouses:  [configId] = { owner, level, progress }
local Warehouses = {}

-- ─────────────────────────────────────────────────────────────────────────────
--  Inventar-Wrapper  (nur diese Funktionen anpassen, falls Devix andere Exports hat)
-- ─────────────────────────────────────────────────────────────────────────────
local RES = Config.InventoryResource
local Inv = {
    register  = function(id, label, slots, weight, owner)
        return exports[RES]:RegisterStash(id, label, slots, weight, owner)
    end,
    add       = function(stash, item, count) return exports[RES]:AddItem(stash, item, count) end,
    remove    = function(stash, item, count) return exports[RES]:RemoveItem(stash, item, count) end,
    count     = function(stash, item) return exports[RES]:GetItem(stash, item, nil, true) or 0 end,
    canCarry  = function(stash, item, count) return exports[RES]:CanCarryItem(stash, item, count) end,
}

-- ─────────────────────────────────────────────────────────────────────────────
--  Helfer
-- ─────────────────────────────────────────────────────────────────────────────
local function getWarehouseConfig(configId)
    for i, wh in ipairs(Config.Warehouses) do
        if wh.id == configId then return wh, i end
    end
end

local function stashId(kind, configId) return ('wh_%s_%s'):format(kind, configId) end

local function registerStashes(configId, owner, level)
    local lvl = Config.Levels[level]
    Inv.register(stashId('input',  configId), 'Rohstoff-Einlass', lvl.inputSlots,  lvl.inputWeight,  owner)
    Inv.register(stashId('output', configId), 'Ausgabe',          lvl.outputSlots, lvl.outputWeight, owner)
    Inv.register(stashId('store',  configId), 'Lager',            lvl.storeSlots,  lvl.storeWeight,  owner)
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
            registerStashes(r.config_id, r.owner, r.level)
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
    registerStashes(configId, xPlayer.identifier, 1)
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
    registerStashes(configId, wh.owner, nextLevel)
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
local function processCrafts(configId, maxCrafts)
    local input  = stashId('input',  configId)
    local output = stashId('output', configId)
    local done = 0

    for _ = 1, maxCrafts do
        local crafted = false
        for _, recipe in ipairs(Config.Recipes) do
            local ok = true
            -- genug Input?
            for _, ing in ipairs(recipe.input) do
                if Inv.count(input, ing.name) < ing.count then ok = false break end
            end
            -- Platz in der Ausgabe?
            if ok then
                for _, out in ipairs(recipe.output) do
                    if not Inv.canCarry(output, out.name, out.count) then ok = false break end
                end
            end
            if ok then
                for _, ing in ipairs(recipe.input)  do Inv.remove(input,  ing.name, ing.count) end
                for _, out in ipairs(recipe.output) do Inv.add(output, out.name, out.count) end
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
