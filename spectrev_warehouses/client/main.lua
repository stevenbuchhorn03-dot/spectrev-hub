-- Backend-Erkennung (analog zum Server)
local function detectBackend()
    if Config.InventoryBackend == 'devix' or Config.InventoryBackend == 'ox' then
        return Config.InventoryBackend
    end
    if GetResourceState(Config.DevixResource) == 'started' then return 'devix' end
    return 'ox'
end
local BACKEND = detectBackend()

local State = {}          -- [configId] = { owned, mine, level }
local Current = nil       -- aktuell betretenes Warehouse: { cfg, level, veh, netId }
local ShellObj = nil      -- gespawntes Shell-Objekt
local interiorZones = {}  -- ox_target Zonen-IDs im Inneren

-- ─────────────────────────────────────────────────────────────────────────────
--  Helfer
-- ─────────────────────────────────────────────────────────────────────────────
local function notify(msg, kind)
    lib.notify({ description = msg, type = kind or 'inform' })
end

local function refreshState()
    State = lib.callback.await('spectrev_wh:getState', false) or {}
end

local function anchorPlus(offset)
    local a = Config.Interior.anchor
    return vector3(a.x + offset.x, a.y + offset.y, a.z + offset.z)
end

-- Öffnen läuft server-validiert: Client fragt an -> Server prüft Besitz -> Server
-- schickt 'spectrev_wh:doOpen' mit der Stash-ID zurück -> Client öffnet das UI.
local function openStash(kind)
    if not Current then return end
    TriggerServerEvent('spectrev_wh:requestOpen', Current.cfg.id, kind)
end

RegisterNetEvent('spectrev_wh:doOpen', function(stashIdStr)
    if BACKEND == 'devix' then
        exports[Config.DevixResource]:OpenStashInventory(stashIdStr)
    else
        exports.ox_inventory:openInventory('stash', stashIdStr)
    end
end)

-- ─────────────────────────────────────────────────────────────────────────────
--  Shell spawnen / entfernen
-- ─────────────────────────────────────────────────────────────────────────────
local function spawnShell()
    if not Config.Interior.spawnShell then return end
    local hash = joaat(Config.Interior.shellModel)
    RequestModel(hash)
    local timeout = 0
    while not HasModelLoaded(hash) and timeout < 100 do
        Wait(50); timeout = timeout + 1
    end
    if not HasModelLoaded(hash) then
        print('[spectrev_warehouses] Shell-Model konnte nicht geladen werden: ' .. Config.Interior.shellModel)
        return
    end
    local a = Config.Interior.anchor
    ShellObj = CreateObject(hash, a.x, a.y, a.z, false, false, false)
    SetEntityHeading(ShellObj, Config.Interior.shellHeading)
    FreezeEntityPosition(ShellObj, true)
    SetModelAsNoLongerNeeded(hash)
end

local function deleteShell()
    if ShellObj and DoesEntityExist(ShellObj) then DeleteEntity(ShellObj) end
    ShellObj = nil
end

-- ─────────────────────────────────────────────────────────────────────────────
--  Interior-Targets
-- ─────────────────────────────────────────────────────────────────────────────
local function createInteriorZones()
    local P = Config.Interior.points

    interiorZones[#interiorZones + 1] = exports.ox_target:addBoxZone({
        coords = anchorPlus(P.input.offset), size = P.input.size, rotation = 0.0,
        options = { { name = 'wh_input', icon = 'fa-solid fa-arrow-down-to-line',
            label = 'Rohstoffe einlagern', onSelect = function() openStash('input') end } },
    })
    interiorZones[#interiorZones + 1] = exports.ox_target:addBoxZone({
        coords = anchorPlus(P.output.offset), size = P.output.size, rotation = 0.0,
        options = { { name = 'wh_output', icon = 'fa-solid fa-box-open',
            label = 'Fertige Resource abholen', onSelect = function() openStash('output') end } },
    })
    interiorZones[#interiorZones + 1] = exports.ox_target:addBoxZone({
        coords = anchorPlus(P.store.offset), size = P.store.size, rotation = 0.0,
        options = { { name = 'wh_store', icon = 'fa-solid fa-warehouse',
            label = 'Lager öffnen', onSelect = function() openStash('store') end } },
    })
    interiorZones[#interiorZones + 1] = exports.ox_target:addBoxZone({
        coords = anchorPlus(P.terminal.offset), size = P.terminal.size, rotation = 0.0,
        options = { { name = 'wh_terminal', icon = 'fa-solid fa-gears',
            label = 'Terminal (Status / Upgrade)', onSelect = function() openTerminal() end } },
    })
    interiorZones[#interiorZones + 1] = exports.ox_target:addBoxZone({
        coords = anchorPlus(P.exit.offset), size = P.exit.size, rotation = 0.0,
        options = { { name = 'wh_exit', icon = 'fa-solid fa-door-open',
            label = 'Warehouse verlassen', onSelect = function() leaveWarehouse() end } },
    })
end

local function removeInteriorZones()
    for _, id in ipairs(interiorZones) do exports.ox_target:removeZone(id) end
    interiorZones = {}
end

-- ─────────────────────────────────────────────────────────────────────────────
--  Betreten / Verlassen
-- ─────────────────────────────────────────────────────────────────────────────
function enterWarehouse(cfg)
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    local netId = 0
    if veh ~= 0 then
        if GetPedInVehicleSeat(veh, -1) ~= ped then
            return notify('Nur der Fahrer kann einfahren.', 'error')
        end
        netId = NetworkGetNetworkIdFromEntity(veh)
        SetNetworkIdCanMigrate(netId, false)
    end

    local res = lib.callback.await('spectrev_wh:enter', false, cfg.id, netId)
    if not res then return notify('Kein Zugriff auf dieses Warehouse.', 'error') end

    DoScreenFadeOut(500); Wait(600)
    spawnShell()

    local a = Config.Interior.anchor
    if veh ~= 0 then
        local vs = Config.Interior.vehicleSpawn
        SetEntityCoords(veh, a.x + vs.x, a.y + vs.y, a.z + vs.z, false, false, false, false)
        SetEntityHeading(veh, vs.w)
    else
        local ps = Config.Interior.pedSpawn
        SetEntityCoords(ped, a.x + ps.x, a.y + ps.y, a.z + ps.z, false, false, false, false)
        SetEntityHeading(ped, ps.w)
    end

    Current = { cfg = cfg, level = res.level, veh = veh, netId = netId }
    createInteriorZones()
    Wait(400)
    DoScreenFadeIn(700)
    notify(('%s betreten (Level %d)'):format(cfg.label, res.level), 'success')
end

function leaveWarehouse()
    if not Current then return end
    local cfg = Current.cfg
    local ped = PlayerPedId()
    local veh = Current.veh

    DoScreenFadeOut(500); Wait(600)
    removeInteriorZones()

    lib.callback.await('spectrev_wh:leave', false, Current.netId)

    local ex = cfg.exit
    if veh ~= 0 and DoesEntityExist(veh) then
        SetEntityCoords(veh, ex.x, ex.y, ex.z, false, false, false, false)
        SetEntityHeading(veh, ex.w)
    else
        SetEntityCoords(ped, ex.x, ex.y, ex.z, false, false, false, false)
        SetEntityHeading(ped, ex.w)
    end

    deleteShell()
    Current = nil
    Wait(300)
    DoScreenFadeIn(700)
end

-- ─────────────────────────────────────────────────────────────────────────────
--  Terminal (Status + Upgrade)
-- ─────────────────────────────────────────────────────────────────────────────
function openTerminal()
    if not Current then return end
    local st = lib.callback.await('spectrev_wh:status', false, Current.cfg.id)
    if not st then return notify('Terminal nicht erreichbar.', 'error') end

    local options = {
        { title = ('Level %d – %s'):format(st.level, st.levelLabel),
          description = ('Verarbeitung: %d Crafts/Stunde (automatisch)'):format(st.craftsPerHour),
          icon = 'fa-solid fa-industry', disabled = true },
        { title = 'Rohstoffe im Einlass',
          description = st.inputSummary, icon = 'fa-solid fa-boxes-stacked', disabled = true },
    }

    if st.nextLevel then
        options[#options + 1] = {
            title = ('Upgrade auf Level %d – %s'):format(st.nextLevel, st.nextLabel),
            description = ('Kosten: $%s  ·  mehr Tempo, Kapazität & Lager'):format(st.upgradePrice),
            icon = 'fa-solid fa-arrow-up-right-dots',
            onSelect = function() doUpgrade() end,
        }
    else
        options[#options + 1] = {
            title = 'Maximales Level erreicht', icon = 'fa-solid fa-crown', disabled = true }
    end

    lib.registerContext({ id = 'spectrev_wh_terminal', title = Current.cfg.label, options = options })
    lib.showContext('spectrev_wh_terminal')
end

function doUpgrade()
    if not Current then return end
    local ok, res = lib.callback.await('spectrev_wh:upgrade', false, Current.cfg.id)
    if not ok then return notify(res or 'Upgrade fehlgeschlagen.', 'error') end
    Current.level = res
    notify(('Warehouse auf Level %d aufgewertet!'):format(res), 'success')
    refreshState()
end

-- ─────────────────────────────────────────────────────────────────────────────
--  Exterior-Targets & Blips
-- ─────────────────────────────────────────────────────────────────────────────
local function buyWarehouse(cfg)
    local ok, msg = lib.callback.await('spectrev_wh:buy', false, cfg.id)
    notify(msg, ok and 'success' or 'error')
    if ok then refreshState() end
end

local function createExterior(cfg)
    -- Kauf-Punkt
    exports.ox_target:addBoxZone({
        coords = cfg.purchase, size = vector3(1.5, 1.5, 2.0), rotation = 0.0,
        options = { {
            name = 'wh_buy_' .. cfg.id,
            icon = 'fa-solid fa-file-signature',
            label = ('Warehouse kaufen ($%s)'):format(cfg.price),
            distance = 2.5,
            canInteract = function() local s = State[cfg.id]; return s and not s.owned end,
            onSelect = function() buyWarehouse(cfg) end,
        } },
    })

    -- Garagentor
    exports.ox_target:addBoxZone({
        coords = vector3(cfg.garage.x, cfg.garage.y, cfg.garage.z),
        size = vector3(4.0, 4.0, 3.0), rotation = cfg.garage.w,
        options = {
            {
                name = 'wh_enter_veh_' .. cfg.id,
                icon = 'fa-solid fa-warehouse',
                label = 'Einfahren',
                distance = 4.0,
                canInteract = function()
                    local s = State[cfg.id]
                    return s and s.mine and GetVehiclePedIsIn(PlayerPedId(), false) ~= 0
                end,
                onSelect = function() enterWarehouse(cfg) end,
            },
            {
                name = 'wh_enter_foot_' .. cfg.id,
                icon = 'fa-solid fa-person-walking',
                label = 'Betreten',
                distance = 2.5,
                canInteract = function()
                    local s = State[cfg.id]
                    return s and s.mine and GetVehiclePedIsIn(PlayerPedId(), false) == 0
                end,
                onSelect = function() enterWarehouse(cfg) end,
            },
        },
    })

    -- Blip
    if cfg.blip then
        local blip = AddBlipForCoord(cfg.purchase.x, cfg.purchase.y, cfg.purchase.z)
        SetBlipSprite(blip, cfg.blip.sprite)
        SetBlipColour(blip, cfg.blip.color)
        SetBlipScale(blip, cfg.blip.scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(cfg.label)
        EndTextCommandSetBlipName(blip)
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
--  Init
-- ─────────────────────────────────────────────────────────────────────────────
RegisterNetEvent('spectrev_wh:refresh', function() refreshState() end)

CreateThread(function()
    while not LocalPlayer.state.isLoggedIn do
        if GetResourceState('es_extended') == 'started' then
            -- ESX legacy: warte kurz, bis der Spieler geladen ist
        end
        Wait(500)
        if NetworkIsPlayerActive(PlayerId()) then break end
    end
    Wait(1000)
    refreshState()
    for _, cfg in ipairs(Config.Warehouses) do
        createExterior(cfg)
    end
end)

-- Falls die Resource neu gestartet wird während man drin ist: Shell säubern.
-- (Den Routing-Bucket setzt der Server beim nächsten leave/Disconnect zurück.)
AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    deleteShell()
end)
