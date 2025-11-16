local Guards = {}

local GuardPeds = {}
local HeistLocations = {}
local ActiveHeists = {}

RegisterNetEvent('cs_heistbuilder:client:heistReady', function(heistId, entryPoint)
    if not entryPoint then return end
    HeistLocations[heistId] = entryPoint
    
    CreateThread(function()
        while HeistLocations[heistId] do
            local coords = GetEntityCoords(cache.ped)
            local entryCoords = vector3(entryPoint.x, entryPoint.y, entryPoint.z)
            local distance = #(coords - entryCoords)
            
            if distance < 50.0 then
                DrawMarker(1, entryPoint.x, entryPoint.y, entryPoint.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.0, 255, 0, 0, 100, false, false, 2, false, nil, nil, false)
                lib.showTextUI(('[E] - Start Heist\nDistance: %.1fm'):format(distance))
            else
                lib.hideTextUI()
            end
            
            Wait(0)
        end
    end)
end)

RegisterNetEvent('cs_heistbuilder:client:guardSpawned', function(netId, heistId, coords)
    GuardPeds[netId] = {
        heistId = heistId,
        coords = coords
    }
end)

RegisterNetEvent('cs_heistbuilder:client:tellerSpawned', function(netId, heistId, coords)
    GuardPeds[netId] = {
        heistId = heistId,
        coords = coords,
        isTeller = true
    }
end)

RegisterNetEvent('cs_heistbuilder:client:heistActivated', function(heistId)
    ActiveHeists[heistId] = true
    lib.notify({
        title = 'Heist Activated',
        description = 'All guards eliminated! Loot the location.',
        type = 'success'
    })
end)

RegisterNetEvent('cs_heistbuilder:client:heistCleaned', function(heistId)
    HeistLocations[heistId] = nil
    ActiveHeists[heistId] = nil
    
    for netId, _ in pairs(GuardPeds) do
        if GuardPeds[netId].heistId == heistId then
            GuardPeds[netId] = nil
        end
    end
end)

AddEventHandler('entityDamaged', function(victim, damageData)
    if not victim or not DoesEntityExist(victim) then return end
    if IsPedAPlayer(victim) then return end
    
    local netId = NetworkGetNetworkIdFromEntity(victim)
    if not GuardPeds[netId] then return end
    
    if IsEntityDead(victim) then
        TriggerServerEvent('cs_heistbuilder:server:guardKilled', netId)
    end
end)

CS_HEIST_CLIENT_GUARDS = Guards

return Guards

