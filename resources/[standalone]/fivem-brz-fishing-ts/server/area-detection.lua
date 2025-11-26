-- Area Detection System
-- Detects which fishing area (River, Lake, Sea) the player is in

local FISHING_AREAS = {
    river = {
        -- River locations (examples - adjust coordinates to your map)
        { coords = vec3(1290.0, 4200.0, 33.0), radius = 100 }, -- Alamo Sea area
        { coords = vec3(2500.0, 5000.0, 45.0), radius = 80 }, -- Zancudo River
        { coords = vec3(1700.0, 3800.0, 35.0), radius = 60 }, -- Lago Zancudo
    },
    lake = {
        -- Lake locations
        { coords = vec3(1290.0, 4200.0, 33.0), radius = 150 }, -- Alamo Sea (larger area)
        { coords = vec3(2100.0, 3900.0, 40.0), radius = 120 }, -- Lago Zancudo (lake portion)
        { coords = vec3(1200.0, 4500.0, 30.0), radius = 100 }, -- Other lake areas
    },
    sea = {
        -- Sea/Deep water locations
        { coords = vec3(-3500.0, -1000.0, 1.0), radius = 300 }, -- Deep sea west
        { coords = vec3(-2000.0, 6000.0, 1.0), radius = 300 }, -- Deep sea north
        { coords = vec3(-1847.98, -1193.15, 14.30), radius = 50 }, -- Del Perro Pier area
        { coords = vec3(-1598.84, 5200.18, 4.31), radius = 50 }, -- Paleto Bay docks
        { coords = vec3(0.0, -3000.0, 1.0), radius = 200 }, -- Ocean south
    },
}

---@param coords vector3
---@return string|nil area
local function detectFishingArea(coords)
    -- Check Sea first (most specific)
    for _, zone in ipairs(FISHING_AREAS.sea) do
        local distance = #(coords - zone.coords)
        if distance <= zone.radius then
            return 'sea'
        end
    end
    
    -- Check Lake
    for _, zone in ipairs(FISHING_AREAS.lake) do
        local distance = #(coords - zone.coords)
        if distance <= zone.radius then
            return 'lake'
        end
    end
    
    -- Check River
    for _, zone in ipairs(FISHING_AREAS.river) do
        local distance = #(coords - zone.coords)
        if distance <= zone.radius then
            return 'river'
        end
    end
    
    -- Default to sea if near water but not in defined zone
    return nil
end

---@param source number
---@return string|nil area
function GetPlayerFishingArea(source)
    local ped = GetPlayerPed(source)
    if not ped or ped == 0 then return nil end
    
    local coords = GetEntityCoords(ped)
    return detectFishingArea(coords)
end

-- Export for other scripts
exports('GetPlayerFishingArea', GetPlayerFishingArea)
exports('DetectFishingArea', detectFishingArea)

-- Store area zones for client access
exports('GetFishingAreas', function()
    return FISHING_AREAS
end)

