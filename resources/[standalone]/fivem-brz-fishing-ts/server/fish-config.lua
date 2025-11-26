-- Fish Configuration Helper
-- Provides fish config data for other scripts

local function getSettings()
    return exports['fivem-brz-fishing-ts']:SETTINGS()
end

---@param fishName string
---@return table|nil
function GetFishConfig(fishName)
    local SETTINGS = getSettings()
    if not SETTINGS or not SETTINGS.FISHES then return nil end
    
    -- Try exact match first
    if SETTINGS.FISHES[fishName] then
        return SETTINGS.FISHES[fishName]
    end
    
    -- Try lowercase
    local lowerName = string.lower(fishName)
    for k, v in pairs(SETTINGS.FISHES) do
        if string.lower(k) == lowerName or string.lower(v.itemName) == lowerName then
            return v
        end
    end
    
    -- Default config for unknown fish
    return {
        itemName = fishName,
        type = "common",
        hash = 802685111,
    }
end

---@param area string
---@return table
function GetAreaFish(area)
    local SETTINGS = getSettings()
    if not SETTINGS or not SETTINGS.FISHES_BY_AREA then return {} end
    
    local areaFish = SETTINGS.FISHES_BY_AREA[area]
    if not areaFish then return {} end
    
    return areaFish
end

-- Exports
exports('GetFishConfig', GetFishConfig)
exports('GetAreaFish', GetAreaFish)

