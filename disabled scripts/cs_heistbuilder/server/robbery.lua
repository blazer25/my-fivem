local Robbery = {}
local Utils = CS_HEIST_SHARED_UTILS or {}

local ActiveRobberies = {}
local ActiveGuards = {}
local ActiveTellers = {}
local CashRegisters = {}

-- Server creates networked entities, clients configure them
local function spawnGuard(robberyId, guardData)
    local coords = guardData.coords or {}
    local model = guardData.model or 's_m_m_security_01'
    local weapon = guardData.weapon or 'WEAPON_CARBINERIFLE'
    
    CreateThread(function()
        -- Validate coordinates
        if not coords.x or not coords.y or not coords.z then
            print(('[cs_heistbuilder] ERROR: Invalid guard coordinates for robbery %s'):format(robberyId))
            return
        end
        
        -- Server can create networked peds
        local ped = CreatePed(4, GetHashKey(model), coords.x, coords.y, coords.z, coords.w or 0.0, true, true)
        if not DoesEntityExist(ped) then 
            print(('[cs_heistbuilder] ERROR: Failed to create guard at %s, %s, %s'):format(coords.x, coords.y, coords.z))
            return 
        end
        
        local netId = NetworkGetNetworkIdFromEntity(ped)
        ActiveGuards[netId] = {
            ped = ped,
            robberyId = robberyId,
            guardData = guardData
        }
        
        -- Send to clients to configure (clients handle SetNetworkIdCanMigrate)
        TriggerClientEvent('cs_heistbuilder:client:configureGuard', -1, netId, robberyId, {
            weapon = weapon,
            fleeAttributes = 0,
            combatAttributes = 46,
            combatAbility = 2,
            accuracy = 70,
            invincible = false,
            coords = coords  -- Pass coords for positioning
        })
    end)
end

local function spawnTeller(robberyId, tellerData)
    local coords = tellerData.coords or {}
    local model = tellerData.model or 's_f_y_shop_low'
    
    CreateThread(function()
        -- Validate coordinates
        if not coords.x or not coords.y or not coords.z then
            print(('[cs_heistbuilder] ERROR: Invalid teller coordinates for robbery %s'):format(robberyId))
            return
        end
        
        -- Server can create networked peds
        local ped = CreatePed(4, GetHashKey(model), coords.x, coords.y, coords.z, coords.w or 0.0, true, true)
        if not DoesEntityExist(ped) then 
            print(('[cs_heistbuilder] ERROR: Failed to create teller at %s, %s, %s'):format(coords.x, coords.y, coords.z))
            return 
        end
        
        local netId = NetworkGetNetworkIdFromEntity(ped)
        ActiveTellers[netId] = {
            ped = ped,
            robberyId = robberyId,
            tellerData = tellerData
        }
        
        -- Send to clients to configure (clients handle SetNetworkIdCanMigrate)
        TriggerClientEvent('cs_heistbuilder:client:configureTeller', -1, netId, robberyId)
    end)
end

-- Cash registers are found on client side from existing world objects
-- No need to spawn them - they already exist in the city

local RobberyCooldowns = {}

function Robbery.spawnRobbery(heist)
    -- Guards and tellers spawn permanently on server start
    -- This just initializes the robbery state
    if ActiveRobberies[heist.id] then return end
    
    local robberyType = heist.type or 'bank'
    ActiveRobberies[heist.id] = {
        heist = heist,
        type = robberyType,
        guardsKilled = 0,
        tellersKilled = 0,
        requiredGuards = 0,
        requiredTellers = 0,
        activated = false,
        registers = {},
        guards = {},
        tellers = {}
    }
    
    local state = ActiveRobberies[heist.id]
    
    -- Count required guards/tellers
    if heist.guards then
        state.requiredGuards = #heist.guards
    end
    
    if robberyType == 'store' and heist.tellers then
        state.requiredTellers = #heist.tellers
    end
    
    -- Spawn guards permanently (they respawn after cooldown)
    Robbery.spawnGuards(heist)
    
    -- For stores: spawn tellers (registers already exist in the city)
    if robberyType == 'store' then
        Robbery.spawnTellers(heist)
        -- Don't spawn cash registers - use existing ones in the city
        -- Client will find and track existing registers at the coordinates
        if heist.cashRegisters then
            -- Send register coordinates to clients to find existing registers
            TriggerClientEvent('cs_heistbuilder:client:findRegisters', -1, heist.id, heist.cashRegisters)
        end
    end
    
    TriggerClientEvent('cs_heistbuilder:client:robberyReady', -1, heist.id, heist)
end

function Robbery.spawnGuards(heist)
    if not heist.guards then return end
    
    local state = ActiveRobberies[heist.id]
    if not state then return end
    
    -- Clear existing guards for this heist
    for netId, guardData in pairs(ActiveGuards) do
        if guardData.robberyId == heist.id then
            local ped = NetworkGetEntityFromNetworkId(netId)
            if DoesEntityExist(ped) then
                DeleteEntity(ped)
            end
            ActiveGuards[netId] = nil
        end
    end
    
    -- Spawn all guards
    for _, guard in ipairs(heist.guards) do
        spawnGuard(heist.id, guard)
    end
end

function Robbery.spawnTellers(heist)
    if not heist.tellers then return end
    
    local state = ActiveRobberies[heist.id]
    if not state then return end
    
    -- Clear existing tellers for this heist
    for netId, tellerData in pairs(ActiveTellers) do
        if tellerData.robberyId == heist.id then
            local ped = NetworkGetEntityFromNetworkId(netId)
            if DoesEntityExist(ped) then
                DeleteEntity(ped)
            end
            ActiveTellers[netId] = nil
        end
    end
    
    -- Spawn all tellers
    for _, teller in ipairs(heist.tellers) do
        spawnTeller(heist.id, teller)
    end
end

function Robbery.checkGuardKill(netId, attacker)
    local guardData = ActiveGuards[netId]
    if not guardData then return end
    
    local robberyId = guardData.robberyId
    local state = ActiveRobberies[robberyId]
    if not state then return end
    
    local ped = NetworkGetEntityFromNetworkId(netId)
    if not DoesEntityExist(ped) or not IsEntityDead(ped) then return end
    
    -- Track this guard as killed for this robbery session
    if not state.guards[netId] then
        state.guards[netId] = true
        state.guardsKilled = state.guardsKilled + 1
    end
    
    -- Remove from active guards (but don't delete yet - will respawn after cooldown)
    ActiveGuards[netId] = nil
    
    local msg = ('Guard eliminated (%d/%d)'):format(state.guardsKilled, state.requiredGuards)
    TriggerClientEvent('cs_heistbuilder:client:robberyUpdate', -1, robberyId, msg)
    
    -- Check if all guards are dead (but only activate if not already activated)
    if not state.activated and state.guardsKilled >= state.requiredGuards then
        if state.type == 'store' then
            -- For stores, wait for tellers too
            if state.tellersKilled >= state.requiredTellers then
                Robbery.activateRobbery(robberyId, attacker)
            end
        else
            -- For banks, activate immediately
            Robbery.activateRobbery(robberyId, attacker)
        end
    end
    
    -- Schedule guard respawn after cooldown
    Robbery.scheduleGuardRespawn(robberyId, guardData.guardData)
end

function Robbery.checkTellerKill(netId, attacker)
    local tellerData = ActiveTellers[netId]
    if not tellerData then return end
    
    local robberyId = tellerData.robberyId
    local state = ActiveRobberies[robberyId]
    if not state then return end
    
    local ped = NetworkGetEntityFromNetworkId(netId)
    if not DoesEntityExist(ped) or not IsEntityDead(ped) then return end
    
    -- Track this teller as killed for this robbery session
    if not state.tellers[netId] then
        state.tellers[netId] = true
        state.tellersKilled = state.tellersKilled + 1
    end
    
    -- Remove from active tellers (but don't delete yet - will respawn after cooldown)
    ActiveTellers[netId] = nil
    
    local msg = ('Teller eliminated (%d/%d)'):format(state.tellersKilled, state.requiredTellers)
    TriggerClientEvent('cs_heistbuilder:client:robberyUpdate', -1, robberyId, msg)
    
    -- For stores, check if all guards and tellers are dead (but only activate if not already activated)
    if not state.activated and state.type == 'store' and state.guardsKilled >= state.requiredGuards and state.tellersKilled >= state.requiredTellers then
        Robbery.activateRobbery(robberyId, attacker)
    end
    
    -- Schedule teller respawn after cooldown
    Robbery.scheduleTellerRespawn(robberyId, tellerData.tellerData)
end

function Robbery.scheduleGuardRespawn(robberyId, guardData)
    if not guardData then return end
    
    local state = ActiveRobberies[robberyId]
    if not state then return end
    
    local cooldownMinutes = (state.heist and state.heist.cooldownMinutes) or 15
    
    CreateThread(function()
        Wait(cooldownMinutes * 60 * 1000)
        
        -- Reset robbery state for respawn
        local currentState = ActiveRobberies[robberyId]
        if currentState then
            currentState.guardsKilled = 0
            currentState.tellersKilled = 0
            currentState.activated = false
            currentState.guards = {}
            currentState.tellers = {}
        end
        
        -- Respawn guard
        spawnGuard(robberyId, guardData)
        
        TriggerClientEvent('cs_heistbuilder:client:robberyUpdate', -1, robberyId, 'Guards have respawned')
    end)
end

function Robbery.scheduleTellerRespawn(robberyId, tellerData)
    if not tellerData then return end
    
    local state = ActiveRobberies[robberyId]
    if not state then return end
    
    local cooldownMinutes = (state.heist and state.heist.cooldownMinutes) or 15
    
    CreateThread(function()
        Wait(cooldownMinutes * 60 * 1000)
        
        -- Respawn teller
        spawnTeller(robberyId, tellerData)
    end)
end

function Robbery.activateRobbery(robberyId, activator)
    local state = ActiveRobberies[robberyId]
    if not state or state.activated then return end
    
    state.activated = true
    
    TriggerClientEvent('cs_heistbuilder:client:robberyActivated', -1, robberyId)
    
    -- For stores, show register locations
    if state.type == 'store' and state.heist.cashRegisters then
        TriggerClientEvent('cs_heistbuilder:client:registersReady', -1, robberyId, state.heist.cashRegisters)
    end
    
    -- Start the heist for the activator
    if activator then
        TriggerEvent('cs_heistbuilder:internal:startRobbery', activator, robberyId)
    end
end

function Robbery.checkRegisterHit(netId, attacker)
    local registerData = CashRegisters[netId]
    if not registerData or registerData.opened then return end
    
    local robberyId = registerData.robberyId
    local state = ActiveRobberies[robberyId]
    if not state or not state.activated then
        if attacker then
            TriggerClientEvent('cs_heistbuilder:client:robberyUpdate', attacker, robberyId, 'Eliminate guards and tellers first!')
        end
        return
    end
    
    -- Mark register as opened (don't give money yet - wait for loot interaction)
    registerData.opened = true
    
    local coords = registerData.registerData.coords or {}
    local amount = math.random(registerData.registerData.minCash or 500, registerData.registerData.maxCash or 1500)
    
    -- Store amount for when player loots it
    registerData.cashAmount = amount
    
    TriggerClientEvent('cs_heistbuilder:client:registerOpened', -1, netId, coords, amount)
    print(('[cs_heistbuilder] Register %s opened by player %s, amount: $%s'):format(netId, attacker or 'unknown', amount))
end

-- Handle loot interaction
RegisterNetEvent('cs_heistbuilder:server:lootRegister', function(netId)
    local src = source
    local registerData = CashRegisters[netId]
    if not registerData or not registerData.opened or registerData.looted then
        TriggerClientEvent('cs_heistbuilder:client:robberyUpdate', src, registerData and registerData.robberyId or '', 'Register already looted!')
        return
    end
    
    local robberyId = registerData.robberyId
    local state = ActiveRobberies[robberyId]
    if not state or not state.activated then
        TriggerClientEvent('cs_heistbuilder:client:robberyUpdate', src, robberyId, 'Robbery not activated yet!')
        return
    end
    
    -- Mark as looted
    registerData.looted = true
    local amount = registerData.cashAmount or math.random(registerData.registerData.minCash or 500, registerData.registerData.maxCash or 1500)
    
    -- Give money to player
    if exports['qbx_core'] and exports['qbx_core'].Functions and exports['qbx_core'].Functions.AddMoney then
        exports['qbx_core'].Functions.AddMoney(src, 'cash', amount, 'store_robbery')
    elseif exports['ox_inventory'] and exports['ox_inventory'].AddItem then
        exports['ox_inventory']:AddItem(src, 'money', amount)
    end
    
    TriggerClientEvent('cs_heistbuilder:client:lootCollected', src, amount)
    print(('[cs_heistbuilder] Player %s looted register %s: $%s'):format(src, netId, amount))
end)

function Robbery.cleanupRobbery(robberyId)
    -- Don't delete guards/tellers permanently - they respawn after cooldown
    -- Only clean up if heist is being removed from config
    
    local state = ActiveRobberies[robberyId]
    if not state then return end
    
    -- Only clean up registers and reset state
    for netId, registerData in pairs(CashRegisters) do
        if registerData.robberyId == robberyId then
            local obj = NetworkGetEntityFromNetworkId(netId)
            if DoesEntityExist(obj) then
                DeleteEntity(obj)
            end
            CashRegisters[netId] = nil
        end
    end
    
    -- Reset state but keep robbery active for respawn
    state.guardsKilled = 0
    state.tellersKilled = 0
    state.activated = false
    state.guards = {}
    state.tellers = {}
    
    TriggerClientEvent('cs_heistbuilder:client:robberyCleaned', -1, robberyId)
end

function Robbery.removeRobbery(robberyId)
    -- Permanently remove robbery and all NPCs (for config changes)
    Robbery.cleanupRobbery(robberyId)
    
    -- Delete guards
    for netId, guardData in pairs(ActiveGuards) do
        if guardData.robberyId == robberyId then
            local ped = NetworkGetEntityFromNetworkId(netId)
            if DoesEntityExist(ped) then
                DeleteEntity(ped)
            end
            ActiveGuards[netId] = nil
        end
    end
    
    -- Delete tellers
    for netId, tellerData in pairs(ActiveTellers) do
        if tellerData.robberyId == robberyId then
            local ped = NetworkGetEntityFromNetworkId(netId)
            if DoesEntityExist(ped) then
                DeleteEntity(ped)
            end
            ActiveTellers[netId] = nil
        end
    end
    
    ActiveRobberies[robberyId] = nil
end

function Robbery.getRobberyState(robberyId)
    return ActiveRobberies[robberyId]
end

-- Track guard kills
AddEventHandler('entityDamaged', function(victim, damageData)
    if not victim or not DoesEntityExist(victim) then return end
    if IsPedAPlayer(victim) then return end
    
    local netId = NetworkGetNetworkIdFromEntity(victim)
    if ActiveGuards[netId] then
        if IsEntityDead(victim) then
            local attacker = damageData.damagedBy and damageData.damagedBy.entity or nil
            local attackerSrc = attacker and NetworkGetEntityOwner(attacker) or nil
            Robbery.checkGuardKill(netId, attackerSrc)
        end
    elseif ActiveTellers[netId] then
        if IsEntityDead(victim) then
            local attacker = damageData.damagedBy and damageData.damagedBy.entity or nil
            local attackerSrc = attacker and NetworkGetEntityOwner(attacker) or nil
            Robbery.checkTellerKill(netId, attackerSrc)
        end
    end
end)

-- Track register hits
AddEventHandler('entityDamaged', function(victim, damageData)
    if not victim or not DoesEntityExist(victim) then return end
    if IsPedAPlayer(victim) then return end
    
    local netId = NetworkGetNetworkIdFromEntity(victim)
    if CashRegisters[netId] then
        local attacker = damageData.damagedBy and damageData.damagedBy.entity or nil
        local attackerSrc = attacker and NetworkGetEntityOwner(attacker) or nil
        Robbery.checkRegisterHit(netId, attackerSrc)
    end
end)

-- Server events from client
RegisterNetEvent('cs_heistbuilder:server:guardKilled', function(netId)
    local src = source
    Robbery.checkGuardKill(netId, src)
end)

RegisterNetEvent('cs_heistbuilder:server:tellerKilled', function(netId)
    local src = source
    Robbery.checkTellerKill(netId, src)
end)

RegisterNetEvent('cs_heistbuilder:server:registerHit', function(netId)
    local src = source
    Robbery.checkRegisterHit(netId, src)
end)

-- Start robbery event
AddEventHandler('cs_heistbuilder:internal:startRobbery', function(source, robberyId)
    local heist = Robbery.getRobberyState(robberyId)
    if not heist then return end
    
    -- Trigger normal heist start
    TriggerEvent('cs_heistbuilder:internal:startTest', source, robberyId)
end)

CS_HEIST_ROBBERY = Robbery

return Robbery

