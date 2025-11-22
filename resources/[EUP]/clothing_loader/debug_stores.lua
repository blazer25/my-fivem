-- Debug script to check clothing store initialization
-- Run this in F8 console: exec debug_stores.lua

print("^2=== Clothing Store Debug ===^7")

-- Check if illenium-appearance is running
local appearanceState = GetResourceState('illenium-appearance')
print(string.format("illenium-appearance state: %s", appearanceState))

if appearanceState ~= 'started' then
    print("^1ERROR: illenium-appearance is not started!^7")
    return
end

-- Check framework detection
print("\n^3Framework Detection:^7")
print(string.format("qb-core state: %s", GetResourceState('qb-core')))
print(string.format("qbx_core state: %s", GetResourceState('qbx_core')))
print(string.format("es_extended state: %s", GetResourceState('es_extended')))

-- Check if we can access the config
local success, config = pcall(function()
    return exports['illenium-appearance']:GetConfig()
end)

if success and config then
    print("^2✅ Config accessible^7")
    if config.Stores then
        print(string.format("Found %d clothing stores in config", #config.Stores))
    end
else
    print("^1❌ Cannot access config^7")
end

-- Check blips
print("\n^3Checking Blips:^7")
local blipCount = 0
for i = 0, 2000 do
    if DoesBlipExist(i) then
        local blipSprite = GetBlipSprite(i)
        if blipSprite == 366 then -- Clothing store sprite
            blipCount = blipCount + 1
        end
    end
end
print(string.format("Found %d clothing store blips on map", blipCount))

-- Player position check
local playerPed = PlayerPedId()
local playerCoords = GetEntityCoords(playerPed)
print(string.format("\nPlayer position: %.2f, %.2f, %.2f", playerCoords.x, playerCoords.y, playerCoords.z))

-- Check nearest clothing store
local nearestStore = nil
local nearestDistance = 999999
local storeCoords = {
    vector3(-705.5, -149.22, 37.42),  -- Vinewood
    vector3(425.91, -801.03, 29.49),  -- Downtown
    vector3(75.39, -1398.28, 29.38),  -- Strawberry
    vector3(-827.39, -1075.93, 11.33) -- Vespucci Beach
}

for i, coords in ipairs(storeCoords) do
    local distance = #(playerCoords - coords)
    if distance < nearestDistance then
        nearestDistance = distance
        nearestStore = i
    end
end

if nearestStore then
    print(string.format("Nearest clothing store: #%d (%.2f units away)", nearestStore, nearestDistance))
    if nearestDistance < 50 then
        print("^2You are near a clothing store!^7")
    else
        print("^3Try teleporting to a clothing store location^7")
    end
end

print("\n^3Teleport Commands:^7")
print("Vinewood: /tp -705 -149 37")
print("Downtown: /tp 425 -801 29") 
print("Strawberry: /tp 75 -1398 29")
print("Vespucci: /tp -827 -1075 11")

print("\n^2=== Debug Complete ===^7")
