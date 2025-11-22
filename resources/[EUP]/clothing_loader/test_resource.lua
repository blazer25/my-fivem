-- Simple test script to verify clothing_loader functionality
-- Run this with: exec test_resource.lua

print("^2=== Clothing Loader Resource Test ===^7")

-- Test 1: Check if resource is running
local resourceState = GetResourceState('clothing_loader')
print(string.format("Resource State: %s", resourceState))

if resourceState ~= 'started' then
    print("^1ERROR: clothing_loader resource is not started!^7")
    return
end

-- Test 2: Check file structure
local requiredFiles = {
    'fxmanifest.lua',
    'client.lua',
    'server.lua',
    'data/shop_ped_apparel.meta',
    'data/componentsets.meta',
    'data/pedaccessories.meta'
}

print("\n^3Checking file structure:^7")
for _, file in ipairs(requiredFiles) do
    local content = LoadResourceFile('clothing_loader', file)
    if content then
        print(string.format("  ✅ %s - OK", file))
    else
        print(string.format("  ❌ %s - MISSING", file))
    end
end

-- Test 3: Check exports
print("\n^3Checking exports:^7")
local success, buildInfo = pcall(function()
    return exports.clothing_loader:GetBuildInfo()
end)

if success then
    print("  ✅ GetBuildInfo export - OK")
    if buildInfo then
        print(string.format("    Last Build: %s", buildInfo.lastBuild or "Never"))
        print(string.format("    Total Files: %d", buildInfo.totalFiles or 0))
    end
else
    print("  ❌ GetBuildInfo export - ERROR")
end

-- Test 4: Test commands (admin only)
print("\n^3Available commands:^7")
print("  /clothinginfo - View build information")
print("  /rebuildclothing - Rebuild clothing system")
print("  /validateclothing - Validate clothing (debug mode)")

print("\n^2=== Test Complete ===^7")
print("^3Next steps:^7")
print("1. Run build script: cd scripts && node build_clothing.js")
print("2. Use /clothinginfo command in-game")
print("3. Add clothing files and rebuild")
