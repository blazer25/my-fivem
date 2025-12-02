-- Area-Based Leveling System
-- Tracks XP and levels for River, Lake, and Sea fishing separately

local XP_PER_LEVEL = {
    [1] = 0,
    [2] = 100,
    [3] = 250,
    [4] = 450,
    [5] = 700,
    [6] = 1000,
    [7] = 1400,
    [8] = 1900,
    [9] = 2500,
    [10] = 3200,
    [11] = 4000,
    [12] = 5000,
    [13] = 6200,
    [14] = 7600,
    [15] = 9200,
}

local XP_PER_CATCH = {
    common = 10,
    uncommon = 25,
    rare = 50,
    epic = 100,
    legendary = 250,
}

local AREA_XP_MULTIPLIER = {
    river = 1.0,
    lake = 1.2,
    sea = 1.5,
}

---@param citizenid string
---@return table|nil
local function getPlayerLevels(citizenid)
    local result = MySQL.single.await('SELECT * FROM fishing_levels WHERE citizenid = ?', {citizenid})
    if not result then
        -- Create new entry
        MySQL.insert.await('INSERT INTO fishing_levels (citizenid, river_level, river_xp, lake_level, lake_xp, sea_level, sea_xp) VALUES (?, 1, 0, 1, 0, 1, 0)', {citizenid})
        return {
            citizenid = citizenid,
            river_level = 1,
            river_xp = 0,
            lake_level = 1,
            lake_xp = 0,
            sea_level = 1,
            sea_xp = 0
        }
    end
    return result
end

---@param citizenid string
---@param area string
---@param level number
---@param xp number
local function updatePlayerLevels(citizenid, area, level, xp)
    local columnLevel = area .. '_level'
    local columnXp = area .. '_xp'
    MySQL.update.await('UPDATE fishing_levels SET ' .. columnLevel .. ' = ?, ' .. columnXp .. ' = ? WHERE citizenid = ?', {level, xp, citizenid})
end

---@param level number
---@return number requiredXP
local function getRequiredXPForLevel(level)
    return XP_PER_LEVEL[level] or 0
end

---@param currentXP number
---@return number level
local function calculateLevel(currentXP)
    local level = 1
    for lvl, requiredXP in pairs(XP_PER_LEVEL) do
        if currentXP >= requiredXP and lvl > level then
            level = lvl
        end
    end
    return level
end

---@param source number
---@param area string
---@param fishRarity string
function AwardFishingXP(source, area, fishRarity)
    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then return end
    
    local citizenid = Player.PlayerData.citizenid
    local levels = getPlayerLevels(citizenid)
    
    if not levels then return end
    
    -- Calculate XP award
    local baseXP = XP_PER_CATCH[fishRarity] or 10
    local multiplier = AREA_XP_MULTIPLIER[area] or 1.0
    local xpAward = math.floor(baseXP * multiplier)
    
    -- Get current area stats
    local currentLevel = area == 'river' and levels.river_level or (area == 'lake' and levels.lake_level or levels.sea_level)
    local currentXP = area == 'river' and levels.river_xp or (area == 'lake' and levels.lake_xp or levels.sea_xp)
    
    -- Add XP
    local newXP = currentXP + xpAward
    local newLevel = calculateLevel(newXP)
    
    -- Update database
    if area == 'river' then
        updatePlayerLevels(citizenid, 'river', newLevel, newXP)
    elseif area == 'lake' then
        updatePlayerLevels(citizenid, 'lake', newLevel, newXP)
    else
        updatePlayerLevels(citizenid, 'sea', newLevel, newXP)
    end
    
    -- Notify if leveled up
    if newLevel > currentLevel then
        lib.notify(source, {
            title = 'Fishing Level Up!',
            description = string.format('You reached %s Level %d!', area:upper(), newLevel),
            type = 'success'
        })
    end
    
    return newLevel, newXP
end

---@param source number
---@param area string
---@return number level, number xp
function GetPlayerAreaLevel(source, area)
    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then return 1, 0 end
    
    local citizenid = Player.PlayerData.citizenid
    local levels = getPlayerLevels(citizenid)
    
    if not levels then return 1, 0 end
    
    if area == 'river' then
        return levels.river_level, levels.river_xp
    elseif area == 'lake' then
        return levels.lake_level, levels.lake_xp
    else
        return levels.sea_level, levels.sea_xp
    end
end

---@param source number
---@return table
function GetAllPlayerLevels(source)
    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then 
        return {
            river_level = 1, river_xp = 0,
            lake_level = 1, lake_xp = 0,
            sea_level = 1, sea_xp = 0
        }
    end
    
    local citizenid = Player.PlayerData.citizenid
    local levels = getPlayerLevels(citizenid)
    
    return levels or {
        river_level = 1, river_xp = 0,
        lake_level = 1, lake_xp = 0,
        sea_level = 1, sea_xp = 0
    }
end

-- Exports
exports('AwardFishingXP', AwardFishingXP)
exports('GetPlayerAreaLevel', GetPlayerAreaLevel)
exports('GetAllPlayerLevels', GetAllPlayerLevels)
exports('GetRequiredXPForLevel', getRequiredXPForLevel)
exports('CalculateLevel', calculateLevel)

-- Export for client
exports('GetRequiredXPForLevel', getRequiredXPForLevel)

