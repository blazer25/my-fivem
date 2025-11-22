-- Test clothing stores functionality
-- Run this in F8 console after joining the server

print("^2=== Testing Clothing Stores ===^7")

-- Teleport to a clothing store
local clothingStoreCoord = vector3(-705.5, -149.22, 37.42) -- Vinewood store
SetEntityCoords(PlayerPedId(), clothingStoreCoord.x, clothingStoreCoord.y, clothingStoreCoord.z)

print("^3Teleported to Vinewood clothing store^7")
print("^3Look for:^7")
print("- Blip on map (shirt icon)")
print("- Interaction zone/prompt")
print("- NPC ped (if enabled)")

-- Wait a moment then check
CreateThread(function()
    Wait(2000)
    
    -- Check if we're in a zone
    local playerCoords = GetEntityCoords(PlayerPedId())
    local distance = #(playerCoords - clothingStoreCoord)
    
    print(string.format("Distance from store center: %.2f units", distance))
    
    if distance < 10 then
        print("^2✅ You are at the clothing store location^7")
        print("^3Try pressing E or looking for interaction prompts^7")
    else
        print("^1❌ Teleport may have failed^7")
    end
    
    -- Try to trigger the clothing menu directly
    print("^3Attempting to open clothing menu directly...^7")
    TriggerEvent('illenium-appearance:client:openClothingShop')
end)
