
local lastRobberyTime = 0
local resourceName = 'pl-atmrob'
lib.versionCheck('pulsepk/pl-atmrob')
lib.locale()
local atmRobberyState = {}

local isEsExtendedStarted = GetResourceState('es_extended') == 'started'
local isQbCoreStarted = GetResourceState('qb-core') == 'started' or GetResourceState('qbx_core') == 'started'


--credits to Lation for checkforpolice
--https://github.com/IamLation/lation_247robbery
lib.callback.register('pl_atmrobbery:checkforpolice', function()
    
    local copCount, jobs = 0, {}
    for _, job in pairs(Config.Police.Job) do
        jobs[job] = true
    end
    local requiredJob = Config.Police.Job
    local requiredCount = Config.Police.required

    if isEsExtendedStarted then
        for _, player in pairs(getPlayers()) do
            if jobs[player.getJob().name] then
                copCount = copCount + 1
            end
        end
    elseif isQbCoreStarted then
        for _, playerId in pairs(getPlayers()) do
            local player = getPlayer(playerId)
            if jobs[player.PlayerData.job.name] and player.PlayerData.job.onduty then
                copCount = copCount + 1
            end
        end
    end
    return copCount >= requiredCount
end)


lib.callback.register('pl_atmrobbery:checktime', function()
    local timePassed = os.time() - lastRobberyTime

    if lastRobberyTime ~= 0 and timePassed < Config.CooldownTimer then
        return false, Config.CooldownTimer - timePassed
    end

    lastRobberyTime = os.time()
    return true
end)

RegisterServerEvent('pl_atmrobbery:MinigameResult')
AddEventHandler('pl_atmrobbery:MinigameResult', function(success, method)
    local src = source
    if success and (method == 'drill' or method == 'hack') then
        atmRobberyState[src] = {
            minigamePassed = true,
            pickupcash = 0,
            method = method
        }
    else
        atmRobberyState[src] = nil
    end
end)

RegisterNetEvent('pl_atmrobbery:robbery')
AddEventHandler('pl_atmrobbery:robbery', function(atmCoords)
    local src = source
    local Player = getPlayer(src)
    local Identifier = getPlayerIdentifier(src)
    local PlayerName = getPlayerName(src)
    local ped = GetPlayerPed(src)
    local distance = GetEntityCoords(ped)

    if #(distance - atmCoords) <= 5 then
        if Player then
            local state = atmRobberyState[src]

            if state and state.minigamePassed then
                local method = state.method or 'drill'
                local maxCashPiles = method == 'hack' and Config.Reward.hack_cash_pile or Config.Reward.drill_cash_pile

                state.pickupcash = state.pickupcash + 1
                AddPlayerMoney(Player, Config.Reward.account, Config.Reward.cash_prop_value)

                TriggerClientEvent('pl_atmrobbery:notification', src, locale('server_pickup_cash', Config.Reward.cash_prop_value), 'success')

                if state.pickupcash >= maxCashPiles then
                    atmRobberyState[src] = nil
                else
                    atmRobberyState[src] = state
                end
            else
                print(('^1[Exploit Attempt]^0 %s (%s) tried to rob ATM without completing the minigame.'):format(PlayerName, Identifier))
            end
        end
    else
        print(('^1[Exploit Attempt]^0 %s (%s) triggered robbery too far from ATM.'):format(PlayerName, Identifier))
    end
end)

RegisterNetEvent('pl_atmrobbery:rope_robbery_success')
AddEventHandler('pl_atmrobbery:rope_robbery_success', function(atmCoords)
    local src = source
    local Player = getPlayer(src)
    local Identifier = getPlayerIdentifier(src)
    local PlayerName = getPlayerName(src)
    local ped = GetPlayerPed(src)
    local distance = GetEntityCoords(ped)

    -- More lenient distance check for rope robbery since ATM can be moved significantly
    if #(distance - atmCoords) <= 15 then
        if Player then
            -- Give money directly for rope robbery
            local totalReward = Config.Reward.reward
            AddPlayerMoney(Player, Config.Reward.account, totalReward)
            
            TriggerClientEvent('pl_atmrobbery:notification', src, locale('server_pickup_cash', totalReward), 'success')
        end
    else
        print(('^1[Exploit Attempt]^0 %s (%s) triggered rope robbery too far from ATM.'):format(PlayerName, Identifier))
    end
end)

local WaterMark = function()
    SetTimeout(1500, function()
        print('^1['..resourceName..'] ^2Thank you for Downloading the Script^0')
        print('^1['..resourceName..'] ^2If you encounter any issues please Join the discord https://discord.gg/c6gXmtEf3H to get support..^0')
        print('^1['..resourceName..'] ^2Enjoy a secret 20% OFF any script of your choice on https://pulsescripts.com/^0')
        print('^1['..resourceName..'] ^2Using the coupon code: SPECIAL20 (one-time use coupon, choose wisely)^0')
    
    end)
end

if Config.WaterMark then
    WaterMark()
end

AddEventHandler('playerDropped', function()
    local src = source
    atmRobberyState[src] = nil
end)

