local Config = Config
local Heists = Config.Heists

local ActiveHeists = {}  -- [id] = { state, lastStart }
local HeistAlerts = {} -- [heistId] = true if cops already alerted
local ClerkPanicCooldown = {} -- prevents spam

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
        local itemName = heist.requiredItem
        local count = 0
        
        -- Try multiple item name variations
        local itemVariations = {}
        if type(itemName) == 'string' then
            if itemName:sub(1, 7):lower() == 'weapon_' then
                -- For weapon_ items, try: WEAPON_ITEM (uppercase), weapon_item (lowercase), and item (without prefix)
                table.insert(itemVariations, itemName:upper())
                table.insert(itemVariations, itemName:lower())
                table.insert(itemVariations, itemName:sub(8):lower()) -- without weapon_ prefix
            else
                -- For regular items, try as-is and lowercase
                table.insert(itemVariations, itemName)
                table.insert(itemVariations, itemName:lower())
            end
        end
        
        -- Try Search for each variation
        for _, variation in ipairs(itemVariations) do
            local searchResult = exports['ox_inventory']:Search(src, 'count', variation)
            if type(searchResult) == 'number' and searchResult > 0 then
                count = searchResult
                break
            end
        end
        
        -- If still not found, try GetItem (more reliable for weapons)
        if count <= 0 and exports['ox_inventory'].GetItem then
            for _, variation in ipairs(itemVariations) do
                local itemResult = exports['ox_inventory']:GetItem(src, variation, nil, true) -- true = return count
                if type(itemResult) == 'number' and itemResult > 0 then
                    count = itemResult
                    break
                end
            end
        end
        
        -- Check if weapon is currently equipped (for weapons only)
        if count <= 0 and type(itemName) == 'string' and itemName:sub(1, 7):lower() == 'weapon_' then
            if exports['ox_inventory'].GetCurrentWeapon then
                local currentWeapon = exports['ox_inventory']:GetCurrentWeapon(src)
                if currentWeapon and currentWeapon.name then
                    local weaponName = currentWeapon.name:lower()
                    local checkName = itemName:lower()
                    if weaponName == checkName or weaponName == checkName:sub(8) then
                        count = 1 -- Weapon is equipped
                    end
                end
            end
        end
        
        if Config.Debug then
            debugPrint(('Item check for %s: found count=%s (tried variations: %s)'):format(
                heist.requiredItem, tostring(count), table.concat(itemVariations, ', ')
            ))
        end
        
        if count <= 0 then
            TriggerClientEvent('ox_lib:notify', src, {
                description = ('You need a %s to start this heist. Make sure it is in your inventory.'):format(heist.requiredItem),
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
    HeistAlerts[heistId] = nil -- reset alert state

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
    HeistAlerts[heistId] = nil -- reset alert state
    debugPrint(('Heist %s aborted by %s'):format(heistId, src))
    TriggerClientEvent('cs_heistmaster:client:cleanupHeist', -1, heistId)
end)

----------------------------------------------------------------
-- Alert police handler
----------------------------------------------------------------

RegisterNetEvent('cs_heistmaster:alertPolice', function(heistId, alertType)
    local src = source
    local heist = Heists[heistId]
    if not heist then return end

    -- don't double-alert for the same heist
    if HeistAlerts[heistId] then return end

    -- optional: treat "silent" as chance-based
    if alertType == 'silent' then
        local chance = 50 -- 50% chance silent fails and cops get warned
        if math.random(1, 100) > chance then
            return -- silent remained silent, no alert
        end
    end

    HeistAlerts[heistId] = true

    -- TODO: Replace with your dispatch system
    -- Example: you might integrate ps-dispatch, core-dispatch, customise to NDRP, etc.
    local msg = ('Suspicious activity reported near %s'):format(heist.label)
    debugPrint('Police alert (' .. heistId .. '): ' .. msg)

    -- If you have your own dispatch system, trigger it here:
    -- TriggerEvent('your_dispatch:server:sendAlert', { type = 'heist', message = msg, coords = heist.start })

    -- Also notify all players with police job as a very basic fallback:
    local cops = getOnlinePoliceCount()
    if cops > 0 then
        -- naive broadcast example
        TriggerClientEvent('ox_lib:notify', -1, {
            title = 'Heist Alert',
            description = msg,
            type = 'error'
        })
    end
end)

----------------------------------------------------------------
-- Give safe key to player
----------------------------------------------------------------

RegisterNetEvent('cs_heistmaster:giveSafeKey', function(heistId)
    local src = source
    local heist = Heists[heistId]
    if not heist or not heist.clerk then return end

    local keyName = "safe_key_"..heistId

    if exports['ox_inventory'] then
        exports['ox_inventory']:AddItem(src, keyName, 1)
        debugPrint('Clerk gave safe key for heist: '..heistId)
    else
        debugPrint('Cannot give safe key - ox_inventory not available')
    end
end)

----------------------------------------------------------------
-- Safe reward handler (for key-based silent opening)
----------------------------------------------------------------

RegisterNetEvent('cs_heistmaster:safeReward', function(heistId)
    local src = source
    local heist = Heists[heistId]
    if not heist then return end

    -- Give safe-specific rewards (you can customize this)
    -- For now, just give extra cash/items
    local safeReward = {
        cash = { min = 1000, max = 3000 },
        items = {
            { name = 'stolen_goods', chance = 50, min = 1, max = 3 },
        }
    }

    -- Cash rewards
    if safeReward.cash then
        local amount = math.random(safeReward.cash.min or 0, safeReward.cash.max or 0)
        if amount > 0 then
            giveMoney(src, amount)
        end
    end

    -- Item rewards
    if safeReward.items then
        for _, item in ipairs(safeReward.items) do
            local chance = item.chance or 100
            if math.random(0, 100) <= chance then
                local qty = math.random(item.min or 1, item.max or 1)
                giveItem(src, item.name, qty)
            end
        end
    end
end)

----------------------------------------------------------------
-- Clerk panic / alarm handler
----------------------------------------------------------------

RegisterNetEvent('cs_heistmaster:clerkPanic', function(heistId)
    local src = source
    local heist = Heists[heistId]
    if not heist or not heist.clerk or not heist.clerk.enabled then return end

    -- prevent double panic spam
    if ClerkPanicCooldown[heistId] then return end
    ClerkPanicCooldown[heistId] = true

    -- send police dispatch
    local msg = ('Clerk panic alarm triggered at %s'):format(heist.label)
    print('[Heist-Clerk] Panic alarm: ' .. msg)

    -- TODO: integrate your actual dispatch system  
    TriggerClientEvent('ox_lib:notify', -1, {
        title = 'Emergency Alert',
        description = msg,
        type = 'error'
    })

    -- indicate heist is alerted
    HeistAlerts[heistId] = true

    -- cooldown
    SetTimeout(300000, function()
        ClerkPanicCooldown[heistId] = nil
    end)
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

