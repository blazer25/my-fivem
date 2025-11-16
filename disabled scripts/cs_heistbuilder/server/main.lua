local Utils = CS_HEIST_SHARED_UTILS or {}
local Storage = CS_HEIST_SERVER and CS_HEIST_SERVER.Storage or {}
local Reputation = CS_HEIST_REPUTATION or {}
local Police = CS_HEIST_POLICE or {}
local StepTypes = CS_HEIST_STEP_TYPES or {}

local ActiveHeists = {}
local Cooldowns = {}

local function loadHeists()
    return Storage.loadAll()
end

Storage.loadAll()

-- Spawn robberies on startup - guards spawn permanently
CreateThread(function()
    Wait(5000)
    
    -- Ensure Robbery module is loaded
    local RobberyModule = CS_HEIST_ROBBERY
    if not RobberyModule or not RobberyModule.spawnRobbery then
        print('[cs_heistbuilder] ERROR: Robbery module not loaded!')
        return
    end
    
    local heists = Storage.getHeists()
    local spawnedCount = 0
    local skippedCount = 0
    
    for _, heist in pairs(heists) do
        if heist.type and (heist.type == 'bank' or heist.type == 'store') then
            -- Check if heist has guards or tellers configured
            if heist.guards and #heist.guards > 0 then
                -- Guards and tellers spawn immediately and stay permanently
                RobberyModule.spawnRobbery(heist)
                spawnedCount = spawnedCount + 1
                print(('[cs_heistbuilder] Spawned robbery: %s (%s guards, %s tellers)'):format(
                    heist.id or 'unknown',
                    heist.guards and #heist.guards or 0,
                    heist.tellers and #heist.tellers or 0
                ))
            else
                skippedCount = skippedCount + 1
                print(('[cs_heistbuilder] Skipped heist %s: No guards configured'):format(heist.id or 'unknown'))
            end
        end
    end
    
    print(('[cs_heistbuilder] Robbery spawn complete: %d spawned, %d skipped'):format(spawnedCount, skippedCount))
end)

local function setCooldown(heist)
    if not heist then return end
    Cooldowns[heist.id] = os.time() + (heist.cooldownMinutes or 30) * 60
end

local function hasCooldown(id)
    local cd = Cooldowns[id]
    if not cd then return false end
    if os.time() >= cd then
        Cooldowns[id] = nil
        return false
    end
    return true, cd - os.time()
end

local function giveRewards(source, heist)
    local rewards = heist.rewards or {}
    if rewards.cash then
        local amount = math.random(rewards.cash.min, rewards.cash.max)
        if exports['qbx_core'] and exports['qbx_core'].Functions and exports['qbx_core'].Functions.AddMoney then
            exports['qbx_core'].Functions.AddMoney(source, 'cash', amount, 'heist_reward')
        else
            exports['ox_inventory']:AddItem(source, 'cash', amount)
        end
    end
    if rewards.items then
        for _, item in ipairs(rewards.items) do
            exports['ox_inventory']:AddItem(source, item.item, item.count or 1)
        end
    end
    TriggerClientEvent('cs_heistbuilder:client:reward', source, { message = 'Loot secured!' })
end

local function applyReputation(source, success)
    if not Config.Reputation.Enabled then return end
    local identifier = CS_HEIST_SERVER.GetIdentifier(source)
    local amount = success and (Config.Reputation.Rewards.success or 10) or (Config.Reputation.Rewards.fail or -5)
    Reputation.add(identifier, amount)
end

local function startHeistForPlayer(source, heist)
    ActiveHeists[source] = {
        id = heist.id,
        stepIndex = 0,
        started = os.time(),
        data = heist
    }
    TriggerClientEvent('cs_heistbuilder:client:startHeist', source, heist)
end

local function getHeistById(id)
    local cache = Storage.getHeists()
    local heist = cache[id]
    if heist then return heist end
    for _, entry in pairs(cache) do
        if entry.id == id then return entry end
    end
    return nil
end

local function canStartHeist(source, heist)
    if not heist then
        return false, 'Heist not found'
    end
    if hasCooldown(heist.id) then
        return false, 'Heist is cooling down'
    end
    if Police.count() < heist.requiredPolice then
        return false, 'Not enough police on duty'
    end
    local identifier = CS_HEIST_SERVER.GetIdentifier(source)
    if not Reputation.canAccess(identifier, heist.reputationRequired) then
        return false, 'Insufficient reputation'
    end
    return true
end

lib.callback.register('cs_heistbuilder:server:getHeists', function()
    local list = {}
    for _, heist in pairs(Storage.getHeists()) do
        list[#list + 1] = heist
    end
    return list
end)

RegisterNetEvent('cs_heistbuilder:server:requestHeist', function(id)
    local src = source
    local heist = getHeistById(id)
    local success, reason = canStartHeist(src, heist)
    if not success then
        TriggerClientEvent('cs_heistbuilder:client:abort', src, reason)
        return
    end
    startHeistForPlayer(src, heist)
end)

RegisterNetEvent('cs_heistbuilder:server:stepResult', function(heistId, stepIndex, success, payload)
    local src = source
    local state = ActiveHeists[src]
    if not state or state.id ~= heistId then return end
    if stepIndex ~= state.stepIndex + 1 then
        Utils.debug('Step index mismatch for %s', heistId)
        return
    end
    local step = state.data.steps[stepIndex]
    if not step then return end
    if not success then
        TriggerClientEvent('cs_heistbuilder:client:abort', src, 'Stage failed')
        applyReputation(src, false)
        ActiveHeists[src] = nil
        return
    end

    local handler = StepTypes[step.type]
    if handler and handler.startServer then
        local serverPayload = handler.startServer(src, step, payload)
        if serverPayload then
            payload = Utils.deepMerge(payload or {}, serverPayload)
        end
    end

    if payload and payload.noise then
        Police.logEvidence('Noise complaint', GetEntityCoords(GetPlayerPed(src)))
    end

    state.stepIndex = stepIndex
    if state.stepIndex >= #state.data.steps then
        giveRewards(src, state.data)
        applyReputation(src, true)
        setCooldown(state.data)
        TriggerClientEvent('cs_heistbuilder:client:abort', src, 'Heist complete!')
        ActiveHeists[src] = nil
    else
        state.stepIndex = state.stepIndex + 1
        TriggerClientEvent('cs_heistbuilder:client:nextStep', src)
    end
end)

AddEventHandler('cs_heistbuilder:internal:startTest', function(source, heistId)
    local heist = getHeistById(heistId)
    if not heist then
        for _, entry in pairs(Storage.getHeists()) do
            heist = entry
            break
        end
    end
    if not heist then return end
    startHeistForPlayer(source, heist)
end)

AddEventHandler('playerJoining', function()
    local src = source
    if not src or src <= 0 then return end
    local state = Player(src).state
    state:set('isHeistBuilderAdmin', Utils.hasBuilderPerms(src), true)
end)
