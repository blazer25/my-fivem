-- Fishing Levels UI
-- Shows player's fishing levels and progression

RegisterCommand('fishinglevels', function()
    local levels = exports['fivem-brz-fishing-ts']:GetAllPlayerLevels()
    local requiredXP = {}
    
    -- Calculate required XP for next levels (matches server-side XP_PER_LEVEL)
    local function getXPForLevel(level)
        local xpTable = {[1]=0, [2]=100, [3]=250, [4]=450, [5]=700, [6]=1000, [7]=1400, [8]=1900, [9]=2500, [10]=3200, [11]=4000, [12]=5000, [13]=6200, [14]=7600, [15]=9200}
        return xpTable[level] or 0
    end
    
    requiredXP.river = getXPForLevel(levels.river_level + 1)
    requiredXP.lake = getXPForLevel(levels.lake_level + 1)
    requiredXP.sea = getXPForLevel(levels.sea_level + 1)
    
    -- Calculate progress percentages
    local riverProgress = requiredXP.river > 0 and ((levels.river_xp / requiredXP.river) * 100) or 0
    local lakeProgress = requiredXP.lake > 0 and ((levels.lake_xp / requiredXP.lake) * 100) or 0
    local seaProgress = requiredXP.sea > 0 and ((levels.sea_xp / requiredXP.sea) * 100) or 0
    
    -- Format display text
    local text = string.format(
        [[~b~FISHING LEVELS~w~

~g~RIVER FISHING~w~
Level: ~y~%d~w~ | XP: ~y~%d~w~ / ~y~%d~w~ (~y~%.1f%%~w~)

~b~LAKE FISHING~w~
Level: ~y~%d~w~ | XP: ~y~%d~w~ / ~y~%d~w~ (~y~%.1f%%~w~)

~o~SEA FISHING~w~
Level: ~y~%d~w~ | XP: ~y~%d~w~ / ~y~%d~w~ (~y~%.1f%%~w~)

~s~Use better equipment to catch rarer fish and earn more XP!]],
        levels.river_level, levels.river_xp, requiredXP.river, riverProgress,
        levels.lake_level, levels.lake_xp, requiredXP.lake, lakeProgress,
        levels.sea_level, levels.sea_xp, requiredXP.sea, seaProgress
    )
    
    lib.notify({
        title = 'Fishing Levels',
        description = text,
        type = 'inform',
        duration = 10000
    })
end, false)

