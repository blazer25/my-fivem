local Config = Config
local Heists = Config.Heists

local ActiveHeists = {}  -- [id] = { state, lastStart }

local function debugPrint(...)
    if Config.Debug then
        print('[cs_heistmaster:server]', ...)
    end
end

local function isPoliceJob(job)
    if not job then return false end
    for _, j in ipairs(Config.PoliceJobs or {}) do
        if j == job then
            return true
        end
    end
    return false
end

local function getOnlinePoliceCount()
    local count = 0

    if exports['qbx_core'] then
        local players = exports['qbx_core']:GetQBPlayers() or {}
        for _, Player in pairs(players) do
            local job = Player.PlayerData and Player.PlayerData.job and Player.PlayerData.job.name
            if isPoliceJob(job) then
                count = count + 1
            end
        end
    end

    return count
end

local function getHeistState(id)
    if not ActiveHeists[id] then
        ActiveHeists[id] = {
            state = 'idle',
            lastStart = 0,
        }
    end
    return ActiveHeists[id]
end

local function giveMoney(src, amount)
    if amount <= 0 then return end

    if exports['qbx_core'] then
        local Player = exports['qbx_core']:GetPlayer(src)
        if Player and Player.Functions and Player.Functions.AddMoney then
            Player.Functions.AddMoney('cash', amount, 'cs_heistmaster')
            return
        end
    end

    debugPrint(('GiveMoney fallback: %s gets %s cash'):format(src, amount))
end

local function giveItem(src, itemName, amount)
    if not itemName or amount <= 0 then return end
    if exports['ox_inventory'] then
        exports['ox_inventory']:AddItem(src, itemName, amount)
    else
        debugPrint(('GiveItem fallback: %s gets %sx %s'):format(src, amount, itemName))
    end
end

----------------------------------------------------------------
-- Handle heist start request
----------------------------------------------------------------

RegisterNetEvent('cs_heistmaster:requestStart', function(heistId)
    local src = source
    local heist = Heists[heistId]
    if not heist then
        debugPrint(('Player %s tried to start invalid heist %s'):format(src, tostring(heistId)))
        return
    end

    local state = getHeistState(heistId)
    local now = os.time()

    -- cooldown check
    if state.lastStart > 0 and (now - state.lastStart) < (heist.cooldown or 0) then
        local remaining = (heist.cooldown or 0) - (now - state.lastStart)
        TriggerClientEvent('ox_lib:notify', src, {
            description = ('This heist is on cooldown (%ss left).'):format(remaining),
            type = 'error'
        })
        return
    end

    -- police check
    local cops = getOnlinePoliceCount()
    local requiredCops = heist.requiredPolice or 0

    if cops < requiredCops then
        TriggerClientEvent('ox_lib:notify', src, {
            description = ('Not enough police on duty (%s/%s).'):format(cops, requiredCops),
            type = 'error'
        })
        return
    end

    -- item check
    if heist.requiredItem and exports['ox_inventory'] then
        local count = exports['ox_inventory']:Search(src, 'count', heist.requiredItem) or 0
        if count <= 0 then
            TriggerClientEvent('ox_lib:notify', src, {
                description = ('You need a %s to start this heist.'):format(heist.requiredItem),
                type = 'error'
            })
            return
        end
    end

    -- set state and broadcast to client
    state.state = 'in_progress'
    state.lastStart = now

    debugPrint(('Heist %s started by %s'):format(heistId, src))

    -- send full heist data to starter
    TriggerClientEvent('cs_heistmaster:client:startHeist', src, heistId, heist)

    -- send guards (if any) to everyone
    TriggerClientEvent('cs_heistmaster:client:spawnGuards', -1, heistId, heist.guards or {})
end)

----------------------------------------------------------------
-- Finish & reward
----------------------------------------------------------------

RegisterNetEvent('cs_heistmaster:finishHeist', function(heistId)
    local src = source
    local heist = Heists[heistId]
    if not heist then return end

    local state = getHeistState(heistId)
    if state.state ~= 'in_progress' then return end

    state.state = 'cooldown'

    -- Cash rewards
    local cashCfg = heist.rewards and heist.rewards.cash
    if cashCfg then
        local amount = math.random(cashCfg.min or 0, cashCfg.max or 0)
        if amount > 0 then
            giveMoney(src, amount)
        end
    end

    -- Item rewards
    local itemList = heist.rewards and heist.rewards.items
    if itemList then
        for _, item in ipairs(itemList) do
            local chance = item.chance or 100
            if math.random(0, 100) <= chance then
                local qty = math.random(item.min or 1, item.max or 1)
                giveItem(src, item.name, qty)
            end
        end
    end

    TriggerClientEvent('ox_lib:notify', src, {
        title = heist.label,
        description = 'Heist completed successfully.',
        type = 'success'
    })

    TriggerClientEvent('cs_heistmaster:client:cleanupHeist', -1, heistId)
end)

----------------------------------------------------------------
-- Abort flow
----------------------------------------------------------------

RegisterNetEvent('cs_heistmaster:abortHeist', function(heistId)
    local src = source
    local heist = Heists[heistId]
    if not heist then return end

    local state = getHeistState(heistId)
    if state.state ~= 'in_progress' then return end

    state.state = 'idle'
    debugPrint(('Heist %s aborted by %s'):format(heistId, src))
    TriggerClientEvent('cs_heistmaster:client:cleanupHeist', -1, heistId)
end)

----------------------------------------------------------------
-- Debug command to force-start a heist
----------------------------------------------------------------

RegisterCommand('heist_start', function(source, args)
    local src = source
    if src == 0 then
        print('Use this command in-game.')
        return
    end
    local id = args[1]
    if not id or not Heists[id] then
        TriggerClientEvent('ox_lib:notify', src, {
            description = 'Usage: /heist_start <heistId>',
            type = 'error'
        })
        return
    end

    -- simply reuse the requestStart logic
    TriggerClientEvent('cs_heistmaster:client:forceStart', src, id)
end, false)

