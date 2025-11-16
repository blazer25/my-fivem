local Robbery = {}
local Utils = CS_HEIST_SHARED_UTILS or {}
local ClientUtils = CS_HEIST_CLIENT_UTILS or {}

local ActiveRobberies = {}
local GuardPeds = {}
local TellerPeds = {}
local CashRegisters = {}

-- Create relationship groups on client start
CreateThread(function()
    -- Create GUARD relationship group if it doesn't exist
    if not DoesRelationshipGroupExist(GetHashKey('GUARD')) then
        AddRelationshipGroup('GUARD')
    end
    
    -- Set GUARD to hate PLAYER (5 = hate relationship)
    SetRelationshipBetweenGroups(5, GetHashKey('GUARD'), GetHashKey('PLAYER'))
    SetRelationshipBetweenGroups(5, GetHashKey('PLAYER'), GetHashKey('GUARD'))
end)

-- Track guard/teller deaths using game event
AddEventHandler('gameEventTriggered', function(name, args)
    if name == 'CEventNetworkEntityDamage' then
        local victim = args[1]
        if not victim or not DoesEntityExist(victim) then return end
        if IsPedAPlayer(victim) then return end
        
        -- Check if it's a guard or teller
        local netId = NetworkGetNetworkIdFromEntity(victim)
        if GuardPeds[netId] or TellerPeds[netId] then
            -- Check if they're dead
            Wait(100)  -- Wait a moment for death to register
            if IsEntityDead(victim) or GetEntityHealth(victim) <= 0 then
                if GuardPeds[netId] then
                    TriggerServerEvent('cs_heistbuilder:server:guardKilled', netId)
                    GuardPeds[netId] = nil  -- Remove from tracking
                elseif TellerPeds[netId] then
                    TriggerServerEvent('cs_heistbuilder:server:tellerKilled', netId)
                    TellerPeds[netId] = nil  -- Remove from tracking
                end
            end
        end
    end
end)

-- Also track using entity damaged as backup
AddEventHandler('entityDamaged', function(victim, damageData)
    if not victim or not DoesEntityExist(victim) then return end
    if IsPedAPlayer(victim) then return end
    
    local netId = NetworkGetNetworkIdFromEntity(victim)
    if GuardPeds[netId] or TellerPeds[netId] then
        Wait(100)
        if IsEntityDead(victim) or GetEntityHealth(victim) <= 0 then
            if GuardPeds[netId] then
                TriggerServerEvent('cs_heistbuilder:server:guardKilled', netId)
                GuardPeds[netId] = nil
            elseif TellerPeds[netId] then
                TriggerServerEvent('cs_heistbuilder:server:tellerKilled', netId)
                TellerPeds[netId] = nil
            end
        end
    end
end)

-- Track register shots using entity damaged event
AddEventHandler('gameEventTriggered', function(name, args)
    if name == 'CEventNetworkEntityDamage' then
        local victim = args[1]
        if not victim or not DoesEntityExist(victim) then return end
        if GetEntityType(victim) ~= 3 then return end  -- Only objects
        
        local netId = NetworkGetNetworkIdFromEntity(victim)
        if CashRegisters[netId] and not CashRegisters[netId].opened then
            local health = GetEntityHealth(victim)
            if health < 100 then
                -- Mark as opened and notify server
                CashRegisters[netId].opened = true
                TriggerServerEvent('cs_heistbuilder:server:registerHit', netId)
            end
        end
    end
end)

-- Configure guard (server creates, client configures with client-side natives)
RegisterNetEvent('cs_heistbuilder:client:configureGuard', function(netId, robberyId, config)
    CreateThread(function()
        local ped = NetworkGetEntityFromNetworkId(netId)
        if not ped or not DoesEntityExist(ped) then 
            -- Wait a bit for entity to sync
            Wait(1000)
            ped = NetworkGetEntityFromNetworkId(netId)
            if not ped or not DoesEntityExist(ped) then return end
        end
        
        -- Store original coords from server data for positioning
        local serverCoords = config.coords or {}
        
        -- Network/migration settings (client-side only)
        SetNetworkIdCanMigrate(netId, false)
        
        -- Configure ped behavior (client-side natives)
        SetEntityAsMissionEntity(ped, true, true)
        SetPedKeepTask(ped, true)
        
        -- FLEE: Set to 0, 0 to prevent fleeing (0 = never flee, false = don't allow)
        SetPedFleeAttributes(ped, 0, false)
        
        -- COMBAT: Make them aggressive fighters
        SetPedCombatAttributes(ped, 46, true)  -- Can use cover and vehicles
        SetPedCombatAbility(ped, 100)  -- Expert combat ability
        SetPedCombatMovement(ped, 2)  -- Offensive movement
        SetPedCombatRange(ped, 2)  -- Long range combat
        SetPedAccuracy(ped, config.accuracy or 70)
        SetPedCanSwitchWeapon(ped, true)
        SetPedDropsWeaponsWhenDead(ped, false)
        
        -- ALERTNESS: Make them aware
        SetPedAlertness(ped, 3)  -- Maximum alertness
        SetPedSeeingRange(ped, 100.0)
        SetPedHearingRange(ped, 100.0)
        
        -- Give weapon
        GiveWeaponToPed(ped, GetHashKey(config.weapon or 'WEAPON_CARBINERIFLE'), 250, false, true)
        SetPedCurrentWeaponVisible(ped, true, true)
        
        -- RELATIONSHIP: Make hostile to players
        SetPedRelationshipGroupHash(ped, GetHashKey('GUARD'))
        SetRelationshipBetweenGroups(5, GetHashKey('GUARD'), GetHashKey('PLAYER'))  -- 5 = hate
        
        -- PREVENT FLEEING: Disable panic/flee behavior
        SetPedConfigFlag(ped, 287, true)  -- PED_FLAG_NO_FLEE (don't flee)
        
        -- HEALTH: Make guards killable (set max health to 200 like players)
        SetEntityMaxHealth(ped, 200)
        SetEntityHealth(ped, 200)
        SetPedDiesWhenInjured(ped, true)  -- Allow them to die when injured
        SetEntityInvincible(ped, false)  -- Make them killable!
        SetPedCanRagdoll(ped, true)  -- Allow ragdoll on death
        SetPedConfigFlag(ped, 118, false)  -- PED_FLAG_DISABLE_RAGDOLL = false (allow ragdoll)
        
        SetBlockingOfNonTemporaryEvents(ped, true)
        
        -- Remove any target interactions (prevent third eye/pick lock)
        if exports.ox_target and exports.ox_target.removeLocalEntity then
            exports.ox_target:removeLocalEntity(ped)
        end
        if exports['qb-target'] and exports['qb-target'].RemoveTargetEntity then
            exports['qb-target']:RemoveTargetEntity(ped)
        end
        
        -- Set ped to exact spawn location and heading from server
        if serverCoords.x and serverCoords.y and serverCoords.z then
            SetEntityCoords(ped, serverCoords.x, serverCoords.y, serverCoords.z, false, false, false, true)
            if serverCoords.w then
                SetEntityHeading(ped, serverCoords.w)
            end
        end
        
        -- Track on client
        GuardPeds[netId] = {
            robberyId = robberyId,
            coords = GetEntityCoords(ped),
            ped = ped
        }
        
        -- Monitor for player presence and combat
        CreateThread(function()
            while DoesEntityExist(ped) and not IsEntityDead(ped) do
                Wait(200)
                local playerPed = PlayerPedId()
                if DoesEntityExist(playerPed) then
                    local distance = #(GetEntityCoords(ped) - GetEntityCoords(playerPed))
                    
                    -- If player is nearby with weapon drawn, guard should be alert
                    if distance < 20.0 then
                        -- If player is aiming at guard or shooting nearby, make guard combat
                        if IsPlayerFreeAiming(PlayerId()) or IsPedShooting(playerPed) or HasEntityBeenDamagedByEntity(ped, playerPed, true) then
                            ClearPedTasks(ped)
                            TaskCombatPed(ped, playerPed, 0, 16)
                            SetPedKeepTask(ped, true)
                        elseif not IsPedInCombat(ped) and distance > 5.0 then
                            -- Guard position when not in combat and player is far
                            TaskGuardCurrentPosition(ped, 10.0, 10.0, 1)
                        end
                    else
                        -- Default: Guard position when player is far
                        if not IsPedInCombat(ped) then
                            TaskGuardCurrentPosition(ped, 15.0, 15.0, 1)
                        end
                    end
                end
            end
        end)
    end)
end)

-- Configure teller (server creates, client configures)
RegisterNetEvent('cs_heistbuilder:client:configureTeller', function(netId, robberyId)
    CreateThread(function()
        local ped = NetworkGetEntityFromNetworkId(netId)
        if not ped or not DoesEntityExist(ped) then 
            -- Wait a bit for entity to sync
            Wait(1000)
            ped = NetworkGetEntityFromNetworkId(netId)
            if not ped or not DoesEntityExist(ped) then return end
        end
        
        -- Network/migration settings (client-side only)
        SetNetworkIdCanMigrate(netId, false)
        
        -- Configure ped behavior (client-side natives)
        SetEntityAsMissionEntity(ped, true, true)
        SetPedKeepTask(ped, true)
        
        -- FLEE: Set to 0, 0 to prevent fleeing (they should stay at counter)
        SetPedFleeAttributes(ped, 0, false)
        
        -- PREVENT FLEEING: Disable panic/flee behavior
        SetPedConfigFlag(ped, 287, true)  -- PED_FLAG_NO_FLEE
        
        -- COMBAT: Disable combat so they don't fight
        SetPedCombatAttributes(ped, 0, false)
        SetPedCombatAbility(ped, 0)
        
        -- HEALTH: Make tellers killable
        SetEntityMaxHealth(ped, 200)
        SetEntityHealth(ped, 200)
        SetPedDiesWhenInjured(ped, true)
        SetEntityInvincible(ped, false)
        
        -- Keep them in place
        SetBlockingOfNonTemporaryEvents(ped, true)
        FreezeEntityPosition(ped, false)  -- Allow standing still task
        TaskStandStill(ped, -1)
        
        -- Remove any target interactions (prevent third eye/pick lock)
        if exports.ox_target and exports.ox_target.removeLocalEntity then
            exports.ox_target:removeLocalEntity(ped)
        end
        if exports['qb-target'] and exports['qb-target'].RemoveTargetEntity then
            exports['qb-target']:RemoveTargetEntity(ped)
        end
        
        -- Track on client
        TellerPeds[netId] = {
            robberyId = robberyId,
            coords = GetEntityCoords(ped),
            ped = ped
        }
    end)
end)

-- Find existing cash registers in the city (don't spawn new ones)
RegisterNetEvent('cs_heistbuilder:client:findRegisters', function(robberyId, registerConfigs)
    CreateThread(function()
        for _, registerConfig in ipairs(registerConfigs) do
            local coords = registerConfig.coords or {}
            if coords.x and coords.y and coords.z then
                -- Wait a bit for world to load
                Wait(2000)
                
                -- Find existing cash register object near coordinates
                local model = registerConfig.model or `prop_till_01`
                local obj = GetClosestObjectOfType(coords.x, coords.y, coords.z, 2.0, model, false, false, false)
                
                if obj and DoesEntityExist(obj) then
                    local netId = NetworkGetNetworkIdFromEntity(obj)
                    
                    -- Make register vulnerable to damage
                    SetEntityProofs(obj, false, false, false, false, false, false, false, false)
                    SetEntityHealth(obj, 100)
                    SetEntityMaxHealth(obj, 100)
                    
                    -- Remove any target interactions (prevent third eye/pick lock)
                    if exports.ox_target and exports.ox_target.removeLocalEntity then
                        exports.ox_target:removeLocalEntity(obj)
                    end
                    if exports['qb-target'] and exports['qb-target'].RemoveTargetEntity then
                        exports['qb-target']:RemoveTargetEntity(obj)
                    end
                    
                    -- Track on client
                    CashRegisters[netId] = {
                        robberyId = robberyId,
                        coords = coords,
                        obj = obj,
                        opened = false,
                        registerData = registerConfig
                    }
                    
                    print(('[cs_heistbuilder] Found existing register at %s, %s, %s'):format(coords.x, coords.y, coords.z))
                else
                    print(('[cs_heistbuilder] WARNING: Could not find existing register at %s, %s, %s'):format(coords.x, coords.y, coords.z))
                end
            end
        end
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

