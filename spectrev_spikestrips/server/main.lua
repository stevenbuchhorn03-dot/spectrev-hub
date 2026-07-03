-- devix-core Objekt (Framework-Bridge: GetPlayer, GetPlayerJob, AddItem, RemoveItem, Notify)
local DEVIX = exports['devix-core']:getObjects()

-- Ausgelegte Nagelbänder: [id] = { owner = src, coords = vec3, heading = number }
local strips = {}
local nextId = 0

-- Zählt die aktuell ausgelegten Bänder eines Beamten (per Server-ID)
local function countStrips(src)
    local count = 0
    for _, data in pairs(strips) do
        if data.owner == src then
            count = count + 1
        end
    end
    return count
end

-- Liest den Dienstgrad robust aus (Zahl oder Tabelle {level=...})
local function getGradeLevel(job)
    local grade = job and job.grade
    if type(grade) == 'table' then
        grade = grade.level or grade.grade or 0
    end
    return tonumber(grade) or 0
end

-- Prüft Job + Dienstgrad anhand des Player-Objekts
local function isAuthorized(player)
    if not player then return false end
    local job = DEVIX.GetPlayerJob(player)
    return job ~= nil and job.name == Config.Job and getGradeLevel(job) >= Config.MinGrade
end

-- ─── Item benutzt → Auslegen anstoßen ─────────────────────────────────
-- Wird von devix aufgerufen, wenn das Item benutzt wird.
-- In der Item-Config: server = { useExport = 'spectrev_spikestrips.useNagelband' }
exports('useNagelband', function(src, itemData)
    local player = DEVIX.GetPlayer(src)
    if not player then return end

    if not isAuthorized(player) then
        DEVIX.Notify(src, 'Nur die Polizei kann Nagelbänder benutzen.', 'error')
        return
    end

    if countStrips(src) >= Config.MaxPerPlayer then
        DEVIX.Notify(src, ('Du hast bereits das Maximum von %s Nagelbändern ausgelegt.'):format(Config.MaxPerPlayer), 'error')
        return
    end

    -- Item wird erst nach erfolgreicher Platzierung (confirmDeploy) verbraucht
    TriggerClientEvent('spectrev_spikes:tryDeploy', src, false)
end)

-- ─── Admin-Command: Nagelband ohne Item ablegen ───────────────────────
RegisterCommand(Config.AdminCommand, function(source, args, rawCommand)
    if source == 0 then
        print('[spectrev_spikestrips] Dieser Befehl kann nur im Spiel benutzt werden.')
        return
    end
    -- Sichtbarkeit/Ausführung über restricted=true (ACE command.<name>)
    TriggerClientEvent('spectrev_spikes:tryDeploy', source, true)
end, true) -- restricted = true → nur Spieler mit ACE-Recht command.<AdminCommand>

-- ─── Platzierung bestätigen → ggf. Item verbrauchen & Band registrieren ─

RegisterNetEvent('spectrev_spikes:confirmDeploy', function(coords, heading, isAdmin)
    local src = source

    if isAdmin then
        -- Server-seitige Absicherung: Client-Flag alleine reicht nicht
        if not IsPlayerAceAllowed(src, 'command.' .. Config.AdminCommand) then
            return
        end
    else
        local player = DEVIX.GetPlayer(src)
        if not isAuthorized(player) then return end

        if countStrips(src) >= Config.MaxPerPlayer then
            DEVIX.Notify(src, ('Du hast bereits das Maximum von %s Nagelbändern ausgelegt.'):format(Config.MaxPerPlayer), 'error')
            return
        end

        -- Item vorhanden? Dann verbrauchen (1 Stück)
        local hasItem = exports['devix-inventory']:GetItemCount(src, Config.Item) or 0
        if hasItem < 1 then return end
        if not DEVIX.RemoveItem(player, Config.Item, 1) then return end
    end

    -- Anti-Cheat: gemeldete Position muss nah am Spieler sein
    local serverCoords = GetEntityCoords(GetPlayerPed(src))
    if #(serverCoords - vector3(coords.x, coords.y, coords.z)) > Config.MaxDeployDistance then
        -- Bei regulärem Auslegen wurde das Item schon entfernt → zurückgeben
        if not isAdmin then
            DEVIX.AddItem(DEVIX.GetPlayer(src), Config.Item, 1)
        end
        return
    end

    nextId = nextId + 1
    local id = nextId
    strips[id] = { owner = src, coords = coords, heading = heading }

    -- Alle Clients spawnen das Band lokal
    TriggerClientEvent('spectrev_spikes:create', -1, id, coords, heading)
end)

-- ─── Einsammeln ───────────────────────────────────────────────────────

RegisterNetEvent('spectrev_spikes:pickup', function(id)
    local src = source
    local player = DEVIX.GetPlayer(src)
    if not isAuthorized(player) then return end

    local strip = strips[id]
    if not strip then return end

    -- Anti-Cheat: Beamter muss nah am Band stehen
    local serverCoords = GetEntityCoords(GetPlayerPed(src))
    if #(serverCoords - vector3(strip.coords.x, strip.coords.y, strip.coords.z)) > Config.MaxPickupDistance then
        return
    end

    if Config.ReturnItem then
        if exports['devix-inventory']:CanCarryItem(src, Config.Item, 1) then
            DEVIX.AddItem(player, Config.Item, 1)
        else
            DEVIX.Notify(src, 'Dein Inventar ist voll.', 'error')
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
