local Config = Config
local Heists = Config.Heists

local ActiveHeists = {}  -- [id] = { state, lastStart }
local HeistAlerts = {} -- [heistId] = true if cops already alerted
local ClerkPanicCooldown = {} -- prevents spam

-- Centralized heist state tracking
local HeistServerState = HeistServerState or {} -- [heistId] = "idle" | "active" | "cooldown"

-- PROMPT B: Vault door state tracking
local FleecaVaultState = FleecaVaultState or {} -- [heistId] = { spawned = false, open = false }

-- PROMPT C: Loot tracking
local HeistLootServerState = {} -- [heistId] = { [lootKey] = true }

-- PATCH C: Step progression tracking
local HeistStepState = {} -- [heistId] = currentStep

-- Track which safes have been opened (one-time use per heist)
local SafeOpened = {} -- [heistId] = true

-- PATCH C: Heist crew tracking (leader + members) - declared early for use in functions
local HeistCrew = {} -- [heistId] = { leader = src, members = { [src] = true } }

local function GetStep(heistId)
    return HeistStepState[heistId] or 1
end

-- PATCH C: Helper to notify all crew members
local function notifyCrew(heistId, notification)
    if HeistCrew[heistId] and HeistCrew[heistId].members then
        for memberSrc in pairs(HeistCrew[heistId].members) do
            -- Only notify active/online members
            if GetPlayerPed(memberSrc) and GetPlayerPed(memberSrc) ~= 0 then
                TriggerClientEvent('ox_lib:notify', memberSrc, notification)
            end
        end
    end
end

local function AdvanceStep(heistId)
    HeistStepState[heistId] = GetStep(heistId) + 1
    
    -- PATCH C: Sync step to all crew members instead of all players
    if HeistCrew[heistId] and HeistCrew[heistId].members then
        for memberSrc in pairs(HeistCrew[heistId].members) do
            TriggerClientEvent("cs_heistmaster:client:setStep", memberSrc, heistId, HeistStepState[heistId])
        end
        
        -- PATCH C: Notify all crew members of new step
        notifyCrew(heistId, {
            title = 'Heist',
            description = 'New step active. Check your objectives.',
            type = 'info'
        })
    else
        -- Fallback: broadcast to all if crew tracking missing
        TriggerClientEvent("cs_heistmaster:client:setStep", -1, heistId, HeistStepState[heistId])
    end
end

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

-- Centralized heist state management
local function setHeistState(heistId, state)
    HeistServerState[heistId] = state
    -- broadcast to all clients so their local state updates
    TriggerClientEvent('cs_heistmaster:client:setHeistState', -1, heistId, state)
    debugPrint(('Heist state changed: %s = %s'):format(heistId, state))
end

----------------------------------------------------------------
-- Handle heist start request
----------------------------------------------------------------

-- Track active players per heist (for co-op support)
local HeistActivePlayers = {} -- [heistId] = { [playerId] = true }
local HeistStartAttempts = {} -- [heistId] = { time = os.time(), players = {} }

-- Helper to get player coords from server
local function getPlayerCoords(src)
    local ped = GetPlayerPed(src)
    if ped and ped ~= 0 then
        return GetEntityCoords(ped)
    end
    return nil
end

-- Helper to check if player is near heist location
local function isPlayerNearHeist(src, heist, maxDistance)
    maxDistance = maxDistance or 50.0
    local playerCoords = getPlayerCoords(src)
    if not playerCoords then return false end
    
    local heistStart = heist.start
    if not heistStart then return false end
    
    local heistCoords = vec3(heistStart.x, heistStart.y, heistStart.z)
    local distance = #(playerCoords - heistCoords)
    
    return distance <= maxDistance
end

-- Helper to get players within radius of coordinates
local function getPlayersInRadius(coords, radius)
    local nearbyPlayers = {}
    -- Get all players (server-side: GetPlayers returns source IDs as strings/numbers)
    local players = GetPlayers()
    
    for _, playerSrcRaw in ipairs(players) do
        local playerSrc = tonumber(playerSrcRaw)
        if playerSrc and playerSrc > 0 then
            local ped = GetPlayerPed(playerSrc)
            if ped and ped ~= 0 then
                local playerCoords = GetEntityCoords(ped)
                local distance = #(coords - playerCoords)
                if distance <= radius then
                    table.insert(nearbyPlayers, playerSrc)
                end
            end
        end
    end
    
    return nearbyPlayers
end

RegisterNetEvent('cs_heistmaster:requestStart', function(heistId)
    local src = source
    local heist = Heists[heistId]
    if not heist then
        debugPrint(('Player %s tried to start invalid heist %s'):format(src, tostring(heistId)))
        return
    end

    local state = getHeistState(heistId)
    local now = os.time()
    
    -- Initialize active players tracking
    if not HeistActivePlayers[heistId] then
        HeistActivePlayers[heistId] = {}
    end
    
    -- If heist is already active, allow player to join if they're near the location
    if state.state == 'in_progress' then
        -- Check if player is already participating
        if HeistActivePlayers[heistId] and HeistActivePlayers[heistId][src] then
            debugPrint(('Player %s already participating in heist %s'):format(src, heistId))
            return
        end
        
        -- Allow joining if player is near heist location (co-op support)
        if isPlayerNearHeist(src, heist, 50.0) then
            -- Player can join the active heist
            if not HeistActivePlayers[heistId] then
                HeistActivePlayers[heistId] = {}
            end
            HeistActivePlayers[heistId][src] = true
            
            -- PATCH C: Add to crew if crew exists
            if not HeistCrew[heistId] then
                HeistCrew[heistId] = { leader = nil, members = {} }
            end
            HeistCrew[heistId].members[src] = true
            
            debugPrint(('Player %s joined active heist %s'):format(src, heistId))
            
            -- Send heist data to joining player
            TriggerClientEvent('cs_heistmaster:client:startHeist', src, heistId, heist)
            
            -- Sync current step
            local currentStep = HeistStepState[heistId] or 1
            TriggerClientEvent("cs_heistmaster:client:setStep", src, heistId, currentStep)
            
            TriggerClientEvent('ox_lib:notify', src, {
                title = heist.label,
                description = 'You joined an active heist!',
                type = 'info'
            })
            return
        else
            -- Player too far away, can't join
            TriggerClientEvent('ox_lib:notify', src, {
                description = 'This heist is already active. Get closer to join.',
                type = 'error'
            })
            return
        end
    end
    
    -- Server-side anti-spam: prevent multiple players from starting same heist within 2 seconds
    if not HeistStartAttempts[heistId] then
        HeistStartAttempts[heistId] = { time = now, players = {} }
    end
    
    local attempt = HeistStartAttempts[heistId]
    if (now - attempt.time) < 2 then
        -- Check if another player already attempted
        for _, playerId in ipairs(attempt.players) do
            if playerId ~= src then
                debugPrint(('Heist %s start blocked - another player already attempting'):format(heistId))
                return
            end
        end
    end
    
    -- Add this player to attempt list
    table.insert(attempt.players, src)
    attempt.time = now

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

    -- Clear attempt tracking
    HeistStartAttempts[heistId] = nil
    
    -- PATCH C: Create heist crew with leader
    local startCoords = getPlayerCoords(src)
    if not startCoords then
        startCoords = vec3(heist.start.x, heist.start.y, heist.start.z)
    end
    
    HeistCrew[heistId] = {
        leader = src,
        members = { [src] = true }
    }
    
    -- PATCH C: Auto-add nearby players (within 15m) as crew members
    local nearbyPlayers = getPlayersInRadius(startCoords, 15.0)
    for _, playerSrc in ipairs(nearbyPlayers) do
        if playerSrc ~= src and playerSrc > 0 then
            HeistCrew[heistId].members[playerSrc] = true
            debugPrint(('Auto-added player %s to heist crew %s (within 15m)'):format(playerSrc, heistId))
        end
    end
    
    -- Add all crew members to active players
    if not HeistActivePlayers[heistId] then
        HeistActivePlayers[heistId] = {}
    end
    for memberSrc in pairs(HeistCrew[heistId].members) do
        HeistActivePlayers[heistId][memberSrc] = true
    end
    
    -- set state and broadcast to client
    state.state = 'in_progress'
    state.lastStart = now

    -- Use centralized state management
    setHeistState(heistId, "active")

    -- PROMPT C: Initialize loot tracking (only if not already initialized)
    if not HeistLootServerState[heistId] then
        HeistLootServerState[heistId] = {}
    end
    
    -- PATCH C: Initialize step state (only if not already initialized)
    if not HeistStepState[heistId] then
        HeistStepState[heistId] = 1
    end

    debugPrint(('Heist %s started by %s with %d crew members'):format(heistId, src, 
        (function() local count = 0; for _ in pairs(HeistCrew[heistId].members) do count = count + 1 end; return count end)()))

    -- PATCH C: Send heist data to all crew members
    for memberSrc in pairs(HeistCrew[heistId].members) do
        TriggerClientEvent('cs_heistmaster:client:startHeist', memberSrc, heistId, heist)
        TriggerClientEvent("cs_heistmaster:client:setStep", memberSrc, heistId, HeistStepState[heistId] or 1)
        
        -- Notify crew members
        if memberSrc == src then
            TriggerClientEvent('ox_lib:notify', memberSrc, {
                title = heist.label,
                description = 'Heist started. You are the leader.',
                type = 'success'
            })
        else
            TriggerClientEvent('ox_lib:notify', memberSrc, {
                title = heist.label,
                description = 'You joined the heist crew!',
                type = 'info'
            })
        end
    end

    -- send guards (if any) to everyone
    TriggerClientEvent('cs_heistmaster:client:spawnGuards', -1, heistId, heist.guards or {})

    -- PROMPT B: Initialize vault door state and spawn for Fleeca banks
    if heist.heistType == 'fleeca' and heist.vault and heist.vault.coords then
        FleecaVaultState[heistId] = { spawned = true, open = false }
        local doorModel = heist.vault.doorModel or 'v_ilev_gb_vauldr'
        TriggerClientEvent('cs_heistmaster:client:spawnVaultDoor', -1, heistId, heist.vault.coords, heist.vault.heading or 160.0, doorModel, false)
    end
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

    -- Check if this player is actually participating
    if not HeistActivePlayers[heistId] or not HeistActivePlayers[heistId][src] then
        debugPrint(('Player %s tried to finish heist %s but is not participating'):format(src, heistId))
        return
    end

    state.state = 'cooldown'
    HeistAlerts[heistId] = nil -- reset alert state

    -- Use centralized state management
    setHeistState(heistId, "cooldown")

    -- PATCH C: Reward splitting - check if heist has sharedReward config
    local sharedReward = heist.sharedReward ~= false -- Default to true (shared)
    local crewMembers = {}
    
    if HeistCrew[heistId] and HeistCrew[heistId].members then
        for memberSrc in pairs(HeistCrew[heistId].members) do
            -- Only include active/online members
            if GetPlayerPed(memberSrc) and GetPlayerPed(memberSrc) ~= 0 then
                table.insert(crewMembers, memberSrc)
            end
        end
    else
        -- Fallback: just the finisher
        crewMembers = { src }
    end
    
    -- Item rewards (cash rewards converted to black_money items)
    local itemList = heist.rewards and heist.rewards.items
    if itemList then
        if sharedReward and #crewMembers > 1 then
            -- Split rewards among crew members
            for _, item in ipairs(itemList) do
                local chance = item.chance or 100
                if math.random(0, 100) <= chance then
                    local totalQty = math.random(item.min or 1, item.max or 1)
                    local qtyPerMember = math.max(1, math.floor(totalQty / #crewMembers))
                    
                    for _, memberSrc in ipairs(crewMembers) do
                        giveItem(memberSrc, item.name, qtyPerMember)
                        debugPrint(('Gave shared reward: %sx %s to crew member %s'):format(qtyPerMember, item.name, memberSrc))
                    end
                end
            end
        else
            -- Leader only or single player
            for _, item in ipairs(itemList) do
                local chance = item.chance or 100
                if math.random(0, 100) <= chance then
                    local qty = math.random(item.min or 1, item.max or 1)
                    giveItem(src, item.name, qty)
                end
            end
        end
    end

    -- PATCH C: Notify all crew members
    for _, memberSrc in ipairs(crewMembers) do
        TriggerClientEvent('ox_lib:notify', memberSrc, {
            title = heist.label,
            description = 'Heist completed successfully.',
            type = 'success'
        })
    end

    -- PATCH C: Remove player from crew and active players
    if HeistCrew[heistId] and HeistCrew[heistId].members then
        HeistCrew[heistId].members[src] = nil
    end
    
    if HeistActivePlayers[heistId] then
        HeistActivePlayers[heistId][src] = nil
    end

    -- PROMPT C: Clear loot tracking after cooldown
    SetTimeout((heist.cooldown or 0) * 1000, function()
        HeistLootServerState[heistId] = nil
        HeistStepState[heistId] = nil
        HeistActivePlayers[heistId] = nil -- Clear active players tracking
        HeistCrew[heistId] = nil -- Clear crew tracking
        SafeOpened[heistId] = nil -- Clear safe opened tracking
        -- Reset to idle after cooldown
        setHeistState(heistId, "idle")
    end)

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

    -- Remove this player from active players (but don't abort for everyone if others are participating)
    if HeistActivePlayers[heistId] then
        HeistActivePlayers[heistId][src] = nil
        
        -- Check if any players are still participating
        local hasActivePlayers = false
        for _ in pairs(HeistActivePlayers[heistId]) do
            hasActivePlayers = true
            break
        end
        
        -- Only abort for everyone if no players are left participating
        if not hasActivePlayers then
            state.state = 'idle'
            HeistAlerts[heistId] = nil -- reset alert state
            
            -- Use centralized state management
            setHeistState(heistId, "cooldown")
            
            -- PROMPT C: Clear loot tracking
            HeistLootServerState[heistId] = nil
            HeistStepState[heistId] = nil
            HeistActivePlayers[heistId] = nil
            HeistCrew[heistId] = nil -- Clear crew tracking
            SafeOpened[heistId] = nil -- Clear safe opened tracking
            
            debugPrint(('Heist %s aborted by %s (no players left)'):format(heistId, src))
            TriggerClientEvent('cs_heistmaster:client:cleanupHeist', -1, heistId)
        else
            -- Other players still participating, only cleanup for this player
            debugPrint(('Player %s left heist %s (others still participating)'):format(src, heistId))
            TriggerClientEvent('cs_heistmaster:client:cleanupHeist', src, heistId)
        end
    else
        -- Fallback: full abort if tracking is missing
        state.state = 'idle'
        HeistAlerts[heistId] = nil
        setHeistState(heistId, "cooldown")
        HeistLootServerState[heistId] = nil
        HeistStepState[heistId] = nil
        debugPrint(('Heist %s aborted by %s'):format(heistId, src))
        TriggerClientEvent('cs_heistmaster:client:cleanupHeist', -1, heistId)
    end
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
-- Remove safe key after use
----------------------------------------------------------------

RegisterNetEvent('cs_heistmaster:removeSafeKey', function(heistId)
    local src = source
    local keyName = "safe_key_"..heistId
    
    if exports['ox_inventory'] then
        exports['ox_inventory']:RemoveItem(src, keyName, 1)
        debugPrint('Removed safe key from player: ' .. src)
    end
end)

----------------------------------------------------------------
-- Safe reward handler (for key-based silent opening)
----------------------------------------------------------------

RegisterNetEvent('cs_heistmaster:safeReward', function(heistId)
    local src = source
    local heist = Heists[heistId]
    if not heist then return end

    -- Check if safe has already been opened (one-time use per heist)
    if SafeOpened[heistId] then
        debugPrint(('Safe already opened for heist %s by another player'):format(heistId))
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Safe Already Opened',
            description = 'This safe has already been opened.',
            type = 'info'
        })
        return
    end

    -- Mark safe as opened
    SafeOpened[heistId] = true
    
    -- PATCH A+++: Notify all crew members that safe was opened
    if HeistCrew[heistId] and HeistCrew[heistId].members then
        for memberSrc in pairs(HeistCrew[heistId].members) do
            TriggerClientEvent('ox_lib:notify', memberSrc, {
                title = 'Safe Opened',
                description = 'The safe has been opened!',
                type = 'success'
            })
        end
    end

    -- Give safe-specific rewards (different from loot rewards)
    -- Use heist-specific safe rewards if configured, otherwise use default
    local safeReward = {
        items = {
            { name = 'black_money', chance = 100, min = 3500, max = 4000 }, -- Default: ~3.5-4k for safe (total ~6k with register)
        }
    }
    
    -- Check if heist has specific safe rewards configured
    if heist.safeReward and heist.safeReward.items then
        safeReward.items = heist.safeReward.items
    end

    -- PATCH C: Reward splitting for safe rewards
    local sharedReward = heist.sharedReward ~= false -- Default to true (shared)
    local crewMembers = {}
    
    if HeistCrew[heistId] and HeistCrew[heistId].members then
        for memberSrc in pairs(HeistCrew[heistId].members) do
            -- Only include active/online members
            if GetPlayerPed(memberSrc) and GetPlayerPed(memberSrc) ~= 0 then
                table.insert(crewMembers, memberSrc)
            end
        end
    else
        -- Fallback: just the opener
        crewMembers = { src }
    end

    -- Item rewards
    if safeReward.items then
        if sharedReward and #crewMembers > 1 then
            -- Split rewards among crew members
            for _, item in ipairs(safeReward.items) do
                local chance = item.chance or 100
                if math.random(0, 100) <= chance then
                    local totalQty = math.random(item.min or 1, item.max or 1)
                    local qtyPerMember = math.max(1, math.floor(totalQty / #crewMembers))
                    
                    for _, memberSrc in ipairs(crewMembers) do
                        giveItem(memberSrc, item.name, qtyPerMember)
                        debugPrint(('Gave shared safe reward: %sx %s to crew member %s'):format(qtyPerMember, item.name, memberSrc))
                    end
                end
            end
        else
            -- Leader only or single player
            for _, item in ipairs(safeReward.items) do
                local chance = item.chance or 100
                if math.random(0, 100) <= chance then
                    local qty = math.random(item.min or 1, item.max or 1)
                    giveItem(src, item.name, qty)
                    debugPrint(('Gave safe reward: %sx %s to player %s'):format(qty, item.name, src))
                end
            end
        end
    end
end)

----------------------------------------------------------------
-- Vault door control (server-side)
----------------------------------------------------------------

-- PROMPT B: Server-side vault door control
RegisterNetEvent('cs_heistmaster:server:setVaultOpen', function(heistId)
    local src = source
    local heist = Heists[heistId]
    if not heist or heist.heistType ~= 'fleeca' then return end

    if not FleecaVaultState[heistId] then
        FleecaVaultState[heistId] = { spawned = true, open = false }
    end

    FleecaVaultState[heistId].open = true

    -- Tell all clients to animate the door opening
    TriggerClientEvent('cs_heistmaster:client:openVaultDoor', -1, heistId)
    debugPrint(('Vault door opened for heist: %s'):format(heistId))
end)

RegisterNetEvent('cs_heistmaster:fleeca:openVaultDoor', function(heistId)
    -- Legacy event - redirect to new system
    TriggerEvent('cs_heistmaster:server:setVaultOpen', heistId)
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

-- PROMPT B: Sync vault doors for late joiners
RegisterNetEvent('cs_heistmaster:server:syncVaultDoors', function()
    local src = source
    for heistId, heist in pairs(Heists) do
        if heist.heistType == 'fleeca' and heist.vault and heist.vault.coords then
            local state = FleecaVaultState[heistId] or { spawned = false, open = false }
            local doorModel = heist.vault.doorModel or 'v_ilev_gb_vauldr'
            TriggerClientEvent('cs_heistmaster:client:spawnVaultDoor', src, heistId, heist.vault.coords, heist.vault.heading or 160.0, doorModel, state.open)
        end
    end
end)

-- PROMPT B: Request sync when player loads
AddEventHandler('qbx_core:server:playerLoaded', function()
    local src = source
    Wait(2000) -- Wait a bit for everything to load
    TriggerClientEvent('cs_heistmaster:client:requestVaultSync', src)
end)

-- PATCH C: Step completion handler
RegisterNetEvent("cs_heistmaster:server:completeStep", function(heistId, step)
    local src = source
    if step ~= GetStep(heistId) then 
        debugPrint(('Step mismatch: expected %s, got %s for heist %s'):format(GetStep(heistId), step, heistId))
        return 
    end
    
    local heist = Heists[heistId]
    local stepData = heist and heist.steps and heist.steps[step]
    local stepLabel = stepData and stepData.label or ('Step ' .. step)
    
    -- Sync loot completion to all crew members
    local lootKey = ('step_%s_%s'):format(step, heistId)
    if HeistCrew[heistId] and HeistCrew[heistId].members then
        for memberSrc in pairs(HeistCrew[heistId].members) do
            -- Notify all crew members that this step is completed
            TriggerClientEvent('cs_heistmaster:client:syncLootCompletion', memberSrc, heistId, lootKey)
            
            -- PATCH A+++: Notify crew members of step completion
            TriggerClientEvent('ox_lib:notify', memberSrc, {
                title = 'Heist Progress',
                description = ('%s completed'):format(stepLabel),
                type = 'info'
            })
        end
    end
    
    AdvanceStep(heistId)
end)

-- Callback to check if safe is already opened
lib.callback.register('cs_heistmaster:checkSafeOpened', function(source, heistId)
    return SafeOpened[heistId] == true
end)

-- PROMPT C: Server-side loot reward handler
RegisterNetEvent('cs_heistmaster:server:giveLoot', function(heistId, lootKey)
    local src = source
    local heist = Heists[heistId]
    if not heist then return end

    HeistLootServerState[heistId] = HeistLootServerState[heistId] or {}
    if HeistLootServerState[heistId][lootKey] then
        -- Already looted, ignore to prevent abuse
        debugPrint(('Loot key %s already used for heist %s'):format(lootKey, heistId))
        return
    end

    HeistLootServerState[heistId][lootKey] = true

    -- PATCH C: Sync loot completion to all crew members
    if HeistCrew[heistId] and HeistCrew[heistId].members then
        for memberSrc in pairs(HeistCrew[heistId].members) do
            -- Notify all crew members that this loot is completed
            TriggerClientEvent('cs_heistmaster:client:syncLootCompletion', memberSrc, heistId, lootKey)
        end
    end

    -- Extract step index from lootKey (format: "step_<index>_<heistId>")
    local stepIndex = tonumber(lootKey:match('step_(%d+)_'))
    if not stepIndex then
        -- Fallback for old format: "step_<index>"
        stepIndex = tonumber(lootKey:match('step_(%d+)'))
    end
    
    if stepIndex and heist.steps and heist.steps[stepIndex] then
        local step = heist.steps[stepIndex]
        
        -- Give dirty money for loot actions (only for 'loot' action, not 'smash')
        if step.action == 'loot' then
            -- Give dirty money (black_money) for register/vault looting
            local lootReward = {
                items = {
                    { name = 'black_money', chance = 100, min = 2000, max = 2500 }, -- Default: ~2k for register
                }
            }
            
            -- Use heist-specific rewards if configured
            if heist.rewards and heist.rewards.items then
                lootReward.items = heist.rewards.items
            end
            
            -- PATCH C: Reward splitting for loot rewards
            local sharedReward = heist.sharedReward ~= false -- Default to true (shared)
            local crewMembers = {}
            
            if HeistCrew[heistId] and HeistCrew[heistId].members then
                for memberSrc in pairs(HeistCrew[heistId].members) do
                    -- Only include active/online members
                    if GetPlayerPed(memberSrc) and GetPlayerPed(memberSrc) ~= 0 then
                        table.insert(crewMembers, memberSrc)
                    end
                end
            else
                -- Fallback: just the looter
                crewMembers = { src }
            end
            
            -- Give item rewards
            if lootReward.items then
                if sharedReward and #crewMembers > 1 then
                    -- Split rewards among crew members
                    for _, item in ipairs(lootReward.items) do
                        local chance = item.chance or 100
                        if math.random(0, 100) <= chance then
                            local totalQty = math.random(item.min or 1, item.max or 1)
                            local qtyPerMember = math.max(1, math.floor(totalQty / #crewMembers))
                            
                            for _, memberSrc in ipairs(crewMembers) do
                                giveItem(memberSrc, item.name, qtyPerMember)
                                debugPrint(('Gave shared loot reward: %sx %s to crew member %s'):format(qtyPerMember, item.name, memberSrc))
                            end
                        end
                    end
                else
                    -- Leader only or single player
                    for _, item in ipairs(lootReward.items) do
                        local chance = item.chance or 100
                        if math.random(0, 100) <= chance then
                            local qty = math.random(item.min or 1, item.max or 1)
                            giveItem(src, item.name, qty)
                            debugPrint(('Gave loot reward: %sx %s to player %s'):format(qty, item.name, src))
                        end
                    end
                end
            end
        end
    end

    debugPrint(('Loot given for heist %s, key: %s'):format(heistId, lootKey))
end)

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

-- Initialize heist and vault states after config loads
CreateThread(function()
    Wait(1000) -- Wait for config to load
    for heistId, heist in pairs(Heists) do
        HeistServerState[heistId] = HeistServerState[heistId] or "idle"
        
        if heist.heistType == 'fleeca' then
            FleecaVaultState[heistId] = FleecaVaultState[heistId] or { spawned = false, open = false }
        end
    end
end)


