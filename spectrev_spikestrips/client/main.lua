-- ESX-Objekt (imports.lua setzt es bereits global; Guard zur Sicherheit)
ESX = ESX or exports['es_extended']:getSharedObject()

-- Lokal gespawnte Nagelbänder auf DIESEM Client: [id] = { entity = handle, coords = vec3 }
-- Jedes Band wird als lokales (nicht-networked) Objekt auf jedem Client gespawnt,
-- damit es keine Ownership-/Despawn-Probleme gibt. Der Server ist die Quelle der Wahrheit.
local localStrips = {}

-- Rad-Bone → Reifen-Index Zuordnung (SetVehicleTyreBurst)
local wheelBones = {
    ['wheel_lf']  = 0, -- vorne links
    ['wheel_rf']  = 1, -- vorne rechts
    ['wheel_lm1'] = 2, -- mitte links
    ['wheel_rm1'] = 3, -- mitte rechts
    ['wheel_lr']  = 4, -- hinten links
    ['wheel_rr']  = 5, -- hinten rechts
}

-- ─── Hilfsfunktionen ──────────────────────────────────────────────────

local function loadModel(model)
    local hash = type(model) == 'number' and model or joaat(model)
    if not IsModelValid(hash) then return nil end
    RequestModel(hash)
    local timeout = 0
    while not HasModelLoaded(hash) and timeout < 100 do
        Wait(10)
        timeout = timeout + 1
    end
    return HasModelLoaded(hash) and hash or nil
end

local function playDeployAnim()
    local anim = Config.DeployAnim
    RequestAnimDict(anim.dict)
    local timeout = 0
    while not HasAnimDictLoaded(anim.dict) and timeout < 50 do
        Wait(10)
        timeout = timeout + 1
    end
    local ped = PlayerPedId()
    if HasAnimDictLoaded(anim.dict) then
        TaskPlayAnim(ped, anim.dict, anim.name, 8.0, -8.0, anim.time, 0, 0, false, false, false)
    end
    Wait(anim.time)
    ClearPedTasks(ped)
end

-- ─── ox_target Registrierung/Entfernung ───────────────────────────────

local function addTarget(id, entity)
    exports.ox_target:addLocalEntity(entity, {
        {
            name     = 'spectrev_spike_pickup_' .. id,
            icon     = Config.Target.icon,
            label    = Config.Target.label,
            distance = Config.Target.distance,
            groups   = Config.Job, -- ox_target/ESX-Bridge beschränkt die Option auf den Job
            onSelect = function()
                TriggerServerEvent('spectrev_spikes:pickup', id)
            end,
        }
    })
end

-- ─── Band spawnen / entfernen ─────────────────────────────────────────

local function createStrip(id, coords, heading)
    if localStrips[id] then return end
    local hash = loadModel(Config.Prop)
    if not hash then return end

    local obj = CreateObject(hash, coords.x, coords.y, coords.z, false, false, false)
    SetEntityHeading(obj, heading + 0.0)
    PlaceObjectOnGroundProperly(obj)
    FreezeEntityPosition(obj, true)
    SetEntityCollision(obj, true, true)
    SetModelAsNoLongerNeeded(hash)

    localStrips[id] = { entity = obj, coords = GetEntityCoords(obj) }
    addTarget(id, obj)
end

local function removeStrip(id)
    local strip = localStrips[id]
    if not strip then return end
    if strip.entity and DoesEntityExist(strip.entity) then
        exports.ox_target:removeLocalEntity(strip.entity, 'spectrev_spike_pickup_' .. id)
        DeleteEntity(strip.entity)
    end
    localStrips[id] = nil
end

-- ─── Reifen-Erkennung ─────────────────────────────────────────────────

local function handleVehicle(vehicle, stripCoords)
    if GetEntitySpeed(vehicle) < Config.BurstSpeed then return end

    for bone, tyre in pairs(wheelBones) do
        local boneIndex = GetEntityBoneIndexByName(vehicle, bone)
        if boneIndex ~= -1 then
            local wheelPos = GetWorldPositionOfEntityBone(vehicle, boneIndex)
            if #(wheelPos - stripCoords) < Config.WheelHitDistance
                and not IsVehicleTyreBurst(vehicle, tyre, false) then
                SetVehicleTyreBurst(vehicle, tyre, true, 1000.0)
            end
        end
    end
end

local function checkBurst()
    for _, vehicle in ipairs(GetGamePool('CVehicle')) do
        local vcoords = GetEntityCoords(vehicle)
        for _, strip in pairs(localStrips) do
            if #(vcoords - strip.coords) < Config.DetectRadius then
                handleVehicle(vehicle, strip.coords)
                break
            end
        end
    end
end

-- Erkennungs-Thread: läuft nur, wenn Bänder existieren, und nur nah dran pro Frame
CreateThread(function()
    while true do
        local wait = 1000
        if next(localStrips) then
            local pcoords = GetEntityCoords(PlayerPedId())
            local near = false
            for _, strip in pairs(localStrips) do
                if #(pcoords - strip.coords) < Config.NearStripDistance then
                    near = true
                    break
                end
            end
            if near then
                wait = 0
                checkBurst()
            else
                wait = 750
            end
        end
        Wait(wait)
    end
end)

-- ─── Auslegen (vom Server angestoßen nach Item-Nutzung) ───────────────

RegisterNetEvent('spectrev_spikes:tryDeploy', function()
    local ped = PlayerPedId()

    if IsPedInAnyVehicle(ped, false) then
        ESX.ShowNotification('Du kannst kein Nagelband im Fahrzeug auslegen.')
        return
    end

    local coords  = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)
    local heading = GetEntityHeading(ped)
    local place   = coords + forward * Config.PlaceForward

    local found, groundZ = GetGroundZFor_3dCoord(place.x, place.y, place.z + 1.0, false)
    local z = found and groundZ or place.z

    playDeployAnim()

    TriggerServerEvent('spectrev_spikes:confirmDeploy', vector3(place.x, place.y, z), heading)
end)

RegisterNetEvent('spectrev_spikes:create', function(id, coords, heading)
    createStrip(id, coords, heading)
end)

RegisterNetEvent('spectrev_spikes:remove', function(id)
    removeStrip(id)
end)

-- ─── Sync beim Laden / Aufräumen ──────────────────────────────────────

AddEventHandler('esx:playerLoaded', function()
    TriggerServerEvent('spectrev_spikes:requestSync')
end)

CreateThread(function()
    -- Falls die Resource neu gestartet wird, während der Spieler schon geladen ist
    Wait(1000)
    if ESX.IsPlayerLoaded and ESX.IsPlayerLoaded() then
        TriggerServerEvent('spectrev_spikes:requestSync')
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for id in pairs(localStrips) do
        removeStrip(id)
    end
end)
