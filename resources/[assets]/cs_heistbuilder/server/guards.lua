local Guards = {}

local ActiveGuards = {}
local ActiveHeists = {}

local function spawnGuard(heistId, guardData)
    local coords = guardData.coords or {}
    local model = guardData.model or 's_m_m_security_01'
    local weapon = guardData.weapon or 'WEAPON_PISTOL'
    
    CreateThread(function()
        local ped = CreatePed(4, GetHashKey(model), coords.x, coords.y, coords.z, coords.w or 0.0, true, true)
        if not DoesEntityExist(ped) then return end
        
        SetPedFleeAttributes(ped, 0, false)
        SetPedCombatAttributes(ped, 46, true)
        SetPedCombatAbility(ped, 2)
        SetPedAccuracy(ped, 60)
        SetPedCanSwitchWeapon(ped, true)
        GiveWeaponToPed(ped, GetHashKey(weapon), 250, false, true)
        SetPedDropsWeaponsWhenDead(ped, false)
        SetEntityInvincible(ped, false)
        SetBlockingOfNonTemporaryEvents(ped, true)
        TaskGuardCurrentPosition(ped, 10.0, 10.0, 1)
        
        local netId = NetworkGetNetworkIdFromEntity(ped)
        ActiveGuards[netId] = {
            ped = ped,
            heistId = heistId,
            guardData = guardData
        }
        
        TriggerClientEvent('cs_heistbuilder:client:guardSpawned', -1, netId, heistId, coords)
    end)
end

local function spawnTeller(heistId, tellerData)
    local coords = tellerData.coords or {}
    local model = tellerData.model or 's_f_y_shop_low'
    
    CreateThread(function()
        local ped = CreatePed(4, GetHashKey(model), coords.x, coords.y, coords.z, coords.w or 0.0, true, true)
        if not DoesEntityExist(ped) then return end
        
        SetPedFleeAttributes(ped, 512, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        TaskStandStill(ped, -1)
        
        local netId = NetworkGetNetworkIdFromEntity(ped)
        ActiveGuards[netId] = {
            ped = ped,
            heistId = heistId,
            isTeller = true
        }
        
        TriggerClientEvent('cs_heistbuilder:client:tellerSpawned', -1, netId, heistId, coords)
    end)
end

function Guards.spawnForHeist(heist)
    if ActiveHeists[heist.id] then return end
    ActiveHeists[heist.id] = {
        heist = heist,
        guards = {},
        tellers = {},
        activated = false
    }
    
    local state = ActiveHeists[heist.id]
    
    -- Spawn guards
    if heist.guards then
        for _, guard in ipairs(heist.guards) do
            spawnGuard(heist.id, guard)
        end
    end
    
    -- Spawn tellers for stores
    if heist.type == 'store' and heist.tellers then
        for _, teller in ipairs(heist.tellers) do
            spawnTeller(heist.id, teller)
        end
    end
    
    TriggerClientEvent('cs_heistbuilder:client:heistReady', -1, heist.id, heist.entryPoint)
end

function Guards.checkGuardDeath(netId)
    local guardData = ActiveGuards[netId]
    if not guardData then return end
    
    local heistId = guardData.heistId
    local state = ActiveHeists[heistId]
    if not state then return end
    
    local ped = NetworkGetEntityFromNetworkId(netId)
    if not DoesEntityExist(ped) or not IsEntityDead(ped) then return end
    
    if guardData.isTeller then
        state.tellers[netId] = true
    else
        state.guards[netId] = true
    end
    
    ActiveGuards[netId] = nil
    
    -- Check if all guards are dead
    local allGuardsDead = true
    if state.heist.guards then
        for _, _ in ipairs(state.heist.guards) do
            if not state.guards[netId] then
                allGuardsDead = false
                break
            end
        end
    end
    
    -- For stores, also check tellers
    if state.heist.type == 'store' then
        local allTellersDead = true
        if state.heist.tellers then
            for _, _ in ipairs(state.heist.tellers) do
                if not state.tellers[netId] then
                    allTellersDead = false
                    break
                end
            end
        end
        allGuardsDead = allGuardsDead and allTellersDead
    end
    
    if allGuardsDead and not state.activated then
        state.activated = true
        TriggerClientEvent('cs_heistbuilder:client:heistActivated', -1, heistId)
        return heistId, true
    end
    
    return heistId, false
end

function Guards.cleanupHeist(heistId)
    if not ActiveHeists[heistId] then return end
    
    for netId, guardData in pairs(ActiveGuards) do
        if guardData.heistId == heistId then
            local ped = NetworkGetEntityFromNetworkId(netId)
            if DoesEntityExist(ped) then
                DeleteEntity(ped)
            end
            ActiveGuards[netId] = nil
        end
    end
    
    ActiveHeists[heistId] = nil
    TriggerClientEvent('cs_heistbuilder:client:heistCleaned', -1, heistId)
end

function Guards.getHeistState(heistId)
    return ActiveHeists[heistId]
end

AddEventHandler('baseevents:onPlayerKilled', function(victim, attacker, deathData)
    if not victim or not IsPedAPlayer(victim) then return end
    
    local ped = GetPlayerPed(victim)
    local netId = NetworkGetNetworkIdFromEntity(ped)
    
    Guards.checkGuardDeath(netId)
end)

AddEventHandler('entityDamaged', function(victim, damageData)
    if not victim or not DoesEntityExist(victim) then return end
    if IsPedAPlayer(victim) then return end
    
    if IsEntityDead(victim) then
        local netId = NetworkGetNetworkIdFromEntity(victim)
        Guards.checkGuardDeath(netId)
    end
end)

CS_HEIST_GUARDS = Guards

return Guards

