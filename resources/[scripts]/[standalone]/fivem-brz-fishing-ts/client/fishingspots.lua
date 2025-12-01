-- Fishing Spots System
-- Creates different fishing zones with varying difficulty and fish availability

local FishingSpots = {
    -- Easy spots (shore) - Common fish only
    {
        name = 'Shore Fishing Spot',
        coords = vec3(-1847.98, -1193.15, 14.30),
        radius = 15.0,
        difficulty = 'easy',
        availableFish = { 'common' },
        blip = {
            sprite = 68,
            color = 3,
            scale = 0.8,
            label = 'Shore Fishing'
        }
    },
    {
        name = 'Paleto Shore',
        coords = vec3(-1598.84, 5200.18, 4.31),
        radius = 15.0,
        difficulty = 'easy',
        availableFish = { 'common' },
        blip = {
            sprite = 68,
            color = 3,
            scale = 0.8,
            label = 'Shore Fishing'
        }
    },
    -- Medium spots (pier) - Uncommon + Rare
    {
        name = 'Del Perro Pier',
        coords = vec3(-1850.0, -1240.0, 8.0),
        radius = 20.0,
        difficulty = 'medium',
        availableFish = { 'common', 'uncommon', 'rare' },
        blip = {
            sprite = 68,
            color = 5,
            scale = 0.9,
            label = 'Pier Fishing'
        }
    },
    {
        name = 'Paleto Pier',
        coords = vec3(-1600.0, 5250.0, 2.0),
        radius = 20.0,
        difficulty = 'medium',
        availableFish = { 'common', 'uncommon', 'rare' },
        blip = {
            sprite = 68,
            color = 5,
            scale = 0.9,
            label = 'Pier Fishing'
        }
    },
    -- Hard spots (deep sea) - All fish types including Epic and Legendary
    {
        name = 'Deep Sea Fishing',
        coords = vec3(-3500.0, -1000.0, 1.0),
        radius = 50.0,
        difficulty = 'hard',
        availableFish = { 'common', 'uncommon', 'rare', 'epic', 'legendary' },
        blip = {
            sprite = 68,
            color = 1,
            scale = 1.0,
            label = 'Deep Sea Fishing'
        }
    },
    {
        name = 'North Deep Sea',
        coords = vec3(-2000.0, 6000.0, 1.0),
        radius = 50.0,
        difficulty = 'hard',
        availableFish = { 'common', 'uncommon', 'rare', 'epic', 'legendary' },
        blip = {
            sprite = 68,
            color = 1,
            scale = 1.0,
            label = 'Deep Sea Fishing'
        }
    },
}

-- Check if player is at a fishing spot
function GetCurrentFishingSpot()
    local playerCoords = GetEntityCoords(cache.ped)
    
    for _, spot in ipairs(FishingSpots) do
        local distance = #(playerCoords - spot.coords)
        if distance <= spot.radius then
            return spot
        end
    end
    
    return nil
end

-- Export for other scripts
exports('GetCurrentFishingSpot', GetCurrentFishingSpot)
exports('GetFishingSpots', function()
    return FishingSpots
end)
