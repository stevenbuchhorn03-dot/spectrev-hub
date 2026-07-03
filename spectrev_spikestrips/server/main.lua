-- ESX-Objekt (imports.lua setzt es bereits global; Guard zur Sicherheit)
ESX = ESX or exports['es_extended']:getSharedObject()

-- Ausgelegte Nagelbänder: [id] = { owner = identifier, coords = vec3, heading = number }
local strips = {}
local nextId = 0

-- Zählt die aktuell ausgelegten Bänder eines Beamten
local function countStrips(identifier)
    local count = 0
    for _, data in pairs(strips) do
        if data.owner == identifier then
            count = count + 1
        end
    end
    return count
end

-- Prüft Job + Dienstgrad
local function isAuthorized(xPlayer)
    local job = xPlayer.getJob()
    return job.name == Config.Job and job.grade >= Config.MinGrade
end

-- ─── Item benutzt → Auslegen anstoßen ─────────────────────────────────

ESX.RegisterUsableItem(Config.Item, function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    if not isAuthorized(xPlayer) then
        xPlayer.showNotification('Nur die Polizei kann Nagelbänder benutzen.')
        return
    end

    if countStrips(xPlayer.identifier) >= Config.MaxPerPlayer then
        xPlayer.showNotification(('Du hast bereits das Maximum von %s Nagelbändern ausgelegt.'):format(Config.MaxPerPlayer))
        return
    end

    -- Item wird erst nach erfolgreicher Platzierung (confirmDeploy) verbraucht
    TriggerClientEvent('spectrev_spikes:tryDeploy', source)
end)

-- ─── Platzierung bestätigen → Item verbrauchen & Band registrieren ────

RegisterNetEvent('spectrev_spikes:confirmDeploy', function(coords, heading)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or not isAuthorized(xPlayer) then return end

    -- Anti-Cheat: gemeldete Position muss nah am Spieler sein
    local serverCoords = GetEntityCoords(GetPlayerPed(src))
    if #(serverCoords - vector3(coords.x, coords.y, coords.z)) > Config.MaxDeployDistance then
        return
    end

    if countStrips(xPlayer.identifier) >= Config.MaxPerPlayer then
        xPlayer.showNotification(('Du hast bereits das Maximum von %s Nagelbändern ausgelegt.'):format(Config.MaxPerPlayer))
        return
    end

    local item = xPlayer.getInventoryItem(Config.Item)
    if not item or item.count < 1 then
        return
    end

    xPlayer.removeInventoryItem(Config.Item, 1)

    nextId = nextId + 1
    local id = nextId
    strips[id] = { owner = xPlayer.identifier, coords = coords, heading = heading }

    -- Alle Clients spawnen das Band lokal
    TriggerClientEvent('spectrev_spikes:create', -1, id, coords, heading)
end)

-- ─── Einsammeln ───────────────────────────────────────────────────────

RegisterNetEvent('spectrev_spikes:pickup', function(id)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or not isAuthorized(xPlayer) then return end

    local strip = strips[id]
    if not strip then return end

    -- Anti-Cheat: Beamter muss nah am Band stehen
    local serverCoords = GetEntityCoords(GetPlayerPed(src))
    if #(serverCoords - vector3(strip.coords.x, strip.coords.y, strip.coords.z)) > Config.MaxPickupDistance then
        return
    end

    if Config.ReturnItem then
        if xPlayer.canCarryItem(Config.Item, 1) then
            xPlayer.addInventoryItem(Config.Item, 1)
        else
            xPlayer.showNotification('Dein Inventar ist voll.')
            return
        end
    end

    strips[id] = nil
    TriggerClientEvent('spectrev_spikes:remove', -1, id)
end)

-- ─── Sync für (neu) geladene Clients ──────────────────────────────────

RegisterNetEvent('spectrev_spikes:requestSync', function()
    local src = source
    for id, data in pairs(strips) do
        TriggerClientEvent('spectrev_spikes:create', src, id, data.coords, data.heading)
    end
end)
