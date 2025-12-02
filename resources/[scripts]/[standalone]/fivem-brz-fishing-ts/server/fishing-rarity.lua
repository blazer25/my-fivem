-- Fishing Rarity System
-- Overrides the default random fish selection with rarity-based system

local CATCH_RATES = {
    common = 60,
    uncommon = 25,
    rare = 10,
    epic = 4,
    legendary = 1,
}

local FISHES_BY_RARITY = {
    common = { 'fish' },
    uncommon = { 'dolphin', 'hammerShark' },
    rare = { 'tigerShark', 'stingray' },
    epic = { 'killerWhale' },
    legendary = { 'humpBack' },
}

-- Select fish based on base rarity system (no equipment bonuses)
local function selectFishByRarity(_source)
    local adjustedRates = CATCH_RATES

    -- Roll for rarity
    local roll = math.random() * 100
    local selectedRarity = 'common'
    local cumulative = 0
    
    for rarity, rate in pairs(adjustedRates) do
        cumulative = cumulative + rate
        if roll <= cumulative then
            selectedRarity = rarity
            break
        end
    end
    
    -- Select random fish from that rarity
    local fishList = FISHES_BY_RARITY[selectedRarity]
    if not fishList or #fishList == 0 then
        fishList = FISHES_BY_RARITY.common -- Fallback
    end
    
    return fishList[math.random(1, #fishList)]
end

-- Store player fish assignments (override the TypeScript random selection)
local playerFishAssignments = {}

-- Hook into the fishing request to override with rarity system
AddEventHandler('brz-fishing:requestStartFishing', function(playerId)
    local src = playerId or source
    
    -- Detect fishing area
    local area = exports['fivem-brz-fishing-ts']:GetPlayerFishingArea(src)
    if not area then
        area = 'sea' -- Default to sea if not detected
    end
    
    -- Select area-specific fish
    local selectedFish = selectFishByAreaAndRarity(src, area)
    playerFishAssignments[src] = selectedFish
    
    -- Trigger the client event with our selected fish
    TriggerClientEvent('brz-fishing:startFishing', src, selectedFish)
end)

-- Select fish based on area and rarity (no equipment bonuses)
local function selectFishByAreaAndRarity(source, area)
    -- Get area-specific fish list from settings
    local areaFish = exports['fivem-brz-fishing-ts']:GetAreaFish(area)
    if not areaFish or #areaFish == 0 then
        -- Fallback to base rarity system
        return selectFishByRarity(source)
    end

    local adjustedRates = CATCH_RATES
    
    -- Roll for rarity
    local roll = math.random() * 100
    local selectedRarity = 'common'
    local cumulative = 0
    
    for rarity, rate in pairs(adjustedRates) do
        cumulative = cumulative + rate
        if roll <= cumulative then
            selectedRarity = rarity
            break
        end
    end
    
    -- Filter area fish by rarity (check item metadata for rarity)
    local fishByRarity = {}
    for _, fishName in ipairs(areaFish) do
        local item = exports.ox_inventory:Items()[fishName]
        if item then
            -- Check if item has rarity metadata or use default
            local rarity = 'common'
            if item.metadata and item.metadata.rarity then
                rarity = item.metadata.rarity
            else
                -- Try to get from fish config
                local fishConfig = exports['fivem-brz-fishing-ts']:GetFishConfig(fishName)
                if fishConfig and fishConfig.type then
                    rarity = fishConfig.type
                end
            end
            
            if rarity == selectedRarity then
                table.insert(fishByRarity, fishName)
            end
        end
    end
    
    -- If no fish of that rarity in area, try all fish in area
    if #fishByRarity == 0 then
        fishByRarity = areaFish
    end
    
    if #fishByRarity == 0 then
        return 'fish' -- Ultimate fallback
    end
    
    return fishByRarity[math.random(1, #fishByRarity)]
end

-- Override catch event to use our assigned fish
RegisterNetEvent('brz-fishing:catchFish', function()
    local src = source
    local fishId = playerFishAssignments[src]
    
    if fishId then
        -- Detect fishing area
        local area = exports['fivem-brz-fishing-ts']:GetPlayerFishingArea(src)
        if not area then
            area = 'sea' -- Default to sea if not detected
        end
        
        -- Determine fish rarity for XP calculation
        local fishRarity = 'common'
        local fishConfig = exports['fivem-brz-fishing-ts']:GetFishConfig(fishId)
        if fishConfig and fishConfig.type then
            fishRarity = fishConfig.type
        end
        
        -- Award XP
        exports['fivem-brz-fishing-ts']:AwardFishingXP(src, area, fishRarity)
        
        -- Process the catch with our assigned fish
        TriggerEvent('brz-fishing:server:processCatch', src, fishId)
        playerFishAssignments[src] = nil -- Clear after catch
    end
end)

-- Export function
exports('SelectFishByRarity', selectFishByRarity)
exports('GetPlayerAssignedFish', function(playerId)
    return playerFishAssignments[playerId]
end)

