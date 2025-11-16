local Robbery = {}
local Utils = CS_HEIST_SHARED_UTILS or {}
local ClientUtils = CS_HEIST_CLIENT_UTILS or {}

local ActiveRobberies = {}
local GuardPeds = {}
local TellerPeds = {}
local CashRegisters = {}

-- Track guard kills on client
AddEventHandler('entityDamaged', function(victim, damageData)
    if not victim or not DoesEntityExist(victim) then return end
    if IsPedAPlayer(victim) then return end
    
    local netId = NetworkGetNetworkIdFromEntity(victim)
    if GuardPeds[netId] or TellerPeds[netId] then
        if IsEntityDead(victim) then
            if GuardPeds[netId] then
                TriggerServerEvent('cs_heistbuilder:server:guardKilled', netId)
            elseif TellerPeds[netId] then
                TriggerServerEvent('cs_heistbuilder:server:tellerKilled', netId)
            end
        end
    end
end)

-- Track register shots using entity damaged event
AddEventHandler('entityDamaged', function(victim, damageData)
    if not victim or not DoesEntityExist(victim) then return end
    if IsPedAPlayer(victim) then return end
    
    local netId = NetworkGetNetworkIdFromEntity(victim)
    if CashRegisters[netId] and not CashRegisters[netId].opened then
        -- Check if entity is a cash register object
        if GetEntityType(victim) == 3 then -- OBJECT type
            local health = GetEntityHealth(victim)
            if health < 100 then
                TriggerServerEvent('cs_heistbuilder:server:registerHit', netId)
            end
        end
    end
end)

-- Configure guard on client side (server can't use ped natives)
RegisterNetEvent('cs_heistbuilder:client:configureGuard', function(netId, config)
    CreateThread(function()
        local ped = NetworkGetEntityFromNetworkId(netId)
        if not ped or not DoesEntityExist(ped) then return end
        
        Wait(100) -- Wait for ped to fully spawn
        
        SetEntityAsMissionEntity(ped, true, true)
        SetPedFleeAttributes(ped, config.fleeAttributes or 0, false)
        SetPedCombatAttributes(ped, config.combatAttributes or 46, true)
        SetPedCombatAbility(ped, config.combatAbility or 2)
        SetPedAccuracy(ped, config.accuracy or 70)
        SetPedCanSwitchWeapon(ped, true)
        GiveWeaponToPed(ped, GetHashKey(config.weapon or 'WEAPON_CARBINERIFLE'), 250, false, true)
        SetPedDropsWeaponsWhenDead(ped, false)
        SetEntityInvincible(ped, config.invincible == false and false or true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        TaskGuardCurrentPosition(ped, 15.0, 15.0, 1)
    end)
end)

-- Configure teller on client side
RegisterNetEvent('cs_heistbuilder:client:configureTeller', function(netId)
    CreateThread(function()
        local ped = NetworkGetEntityFromNetworkId(netId)
        if not ped or not DoesEntityExist(ped) then return end
        
        Wait(100) -- Wait for ped to fully spawn
        
        SetEntityAsMissionEntity(ped, true, true)
        SetPedFleeAttributes(ped, 512, true)
        SetPedCombatAttributes(ped, 0, false)
        SetBlockingOfNonTemporaryEvents(ped, true)
        TaskStandStill(ped, -1)
    end)
end)

RegisterNetEvent('cs_heistbuilder:client:robberyReady', function(robberyId, heist)
    ActiveRobberies[robberyId] = {
        heist = heist,
        activated = false
    }
    
    lib.notify({
        title = 'Robbery Ready',
        description = ('%s guards spawned. Eliminate them to start.'):format(heist.guards and #heist.guards or 0),
        type = 'inform'
    })
end)

RegisterNetEvent('cs_heistbuilder:client:guardSpawned', function(netId, robberyId, coords)
    GuardPeds[netId] = {
        robberyId = robberyId,
        coords = coords
    }
end)

RegisterNetEvent('cs_heistbuilder:client:tellerSpawned', function(netId, robberyId, coords)
    TellerPeds[netId] = {
        robberyId = robberyId,
        coords = coords
    }
end)

RegisterNetEvent('cs_heistbuilder:client:registerSpawned', function(netId, robberyId, coords)
    CashRegisters[netId] = {
        robberyId = robberyId,
        coords = coords,
        opened = false
    }
end)

RegisterNetEvent('cs_heistbuilder:client:robberyUpdate', function(robberyId, message)
    lib.notify({
        title = 'Robbery Update',
        description = message,
        type = 'inform'
    })
end)

RegisterNetEvent('cs_heistbuilder:client:robberyActivated', function(robberyId)
    local state = ActiveRobberies[robberyId]
    if not state then return end
    
    state.activated = true
    
    lib.notify({
        title = 'Robbery Activated!',
        description = 'All guards eliminated! Loot the location.',
        type = 'success'
    })
end)

RegisterNetEvent('cs_heistbuilder:client:registersReady', function(robberyId, registers)
    CreateThread(function()
        while ActiveRobberies[robberyId] and ActiveRobberies[robberyId].activated do
            for _, register in ipairs(registers) do
                local coords = Utils.toVector(register.coords)
                local playerCoords = GetEntityCoords(cache.ped)
                local distance = #(playerCoords - coords)
                
                if distance < 5.0 then
                    ClientUtils.marker(1, coords, { r = 255, g = 255, b = 0, a = 120 }, 0.8)
                    ClientUtils.showHelp('Shoot the cash register to open it')
                end
            end
            Wait(0)
        end
    end)
end)

RegisterNetEvent('cs_heistbuilder:client:registerOpened', function(netId, coords, amount)
    if CashRegisters[netId] then
        CashRegisters[netId].opened = true
    end
    
    -- Create money pickup effect
    CreateThread(function()
        local moneyObj = CreateObject(`prop_anim_cash_pile_01`, coords.x, coords.y, coords.z + 0.5, false, true, true)
        Wait(2000)
        if DoesEntityExist(moneyObj) then
            DeleteObject(moneyObj)
        end
    end)
end)

RegisterNetEvent('cs_heistbuilder:client:lootCollected', function(amount)
    lib.notify({
        title = 'Cash Collected',
        description = ('You collected $%s'):format(amount),
        type = 'success'
    })
end)

RegisterNetEvent('cs_heistbuilder:client:robberyCleaned', function(robberyId)
    ActiveRobberies[robberyId] = nil
    
    -- Clean up guards
    for netId, _ in pairs(GuardPeds) do
        if GuardPeds[netId].robberyId == robberyId then
            GuardPeds[netId] = nil
        end
    end
    
    -- Clean up tellers
    for netId, _ in pairs(TellerPeds) do
        if TellerPeds[netId].robberyId == robberyId then
            TellerPeds[netId] = nil
        end
    end
    
    -- Clean up registers
    for netId, _ in pairs(CashRegisters) do
        if CashRegisters[netId].robberyId == robberyId then
            CashRegisters[netId] = nil
        end
    end
end)

-- Draw markers for guards/tellers
CreateThread(function()
    while true do
        Wait(0)
        local playerCoords = GetEntityCoords(cache.ped)
        
        -- Draw guard markers
        for netId, guardData in pairs(GuardPeds) do
            local ped = NetworkGetEntityFromNetworkId(netId)
            if DoesEntityExist(ped) and not IsEntityDead(ped) then
                local coords = GetEntityCoords(ped)
                local distance = #(playerCoords - coords)
                if distance < 50.0 then
                    DrawMarker(1, coords.x, coords.y, coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.8, 0.8, 0.8, 255, 0, 0, 120, false, false, 2, false, nil, nil, false)
                end
            end
        end
        
        -- Draw teller markers
        for netId, tellerData in pairs(TellerPeds) do
            local ped = NetworkGetEntityFromNetworkId(netId)
            if DoesEntityExist(ped) and not IsEntityDead(ped) then
                local coords = GetEntityCoords(ped)
                local distance = #(playerCoords - coords)
                if distance < 50.0 then
                    DrawMarker(1, coords.x, coords.y, coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.8, 0.8, 0.8, 255, 100, 0, 120, false, false, 2, false, nil, nil, false)
                end
            end
        end
    end
end)

CS_HEIST_CLIENT_ROBBERY = Robbery

return Robbery

