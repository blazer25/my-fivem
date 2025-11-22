-- Test Framework Integration
-- Run this in server console: exec test_framework.lua

print("^2=== Framework Integration Test ===^7")

-- Check resource states
print("\n^3Resource States:^7")
print(string.format("qbx_core: %s", GetResourceState('qbx_core')))
print(string.format("qb-core: %s", GetResourceState('qb-core')))
print(string.format("illenium-appearance: %s", GetResourceState('illenium-appearance')))

-- Test QBX Core exports
print("\n^3QBX Core Test:^7")
local success, qbxCore = pcall(function()
    return exports.qbx_core
end)

if success and qbxCore then
    print("^2✅ QBX Core exports accessible^7")
    
    -- Test Functions
    if qbxCore.Functions then
        print("^2✅ QBX Core Functions available^7")
    else
        print("^1❌ QBX Core Functions missing^7")
    end
else
    print("^1❌ QBX Core exports not accessible^7")
end

-- Test Framework detection
print("\n^3Framework Detection Test:^7")
local frameworkTest = pcall(function()
    -- Simulate the framework detection logic
    if GetResourceState('qbx_core') == 'started' then
        print("^2✅ QBX Core detected^7")
        return true
    elseif GetResourceState('qb-core') == 'started' then
        print("^3⚠️  QB Core detected (fallback)^7")
        return true
    else
        print("^1❌ No compatible framework detected^7")
        return false
    end
end)

if not frameworkTest then
    print("^1❌ Framework detection failed^7")
end

print("\n^2=== Test Complete ===^7")
print("^3Next steps if issues persist:^7")
print("1. restart qbx_core")
print("2. restart illenium-appearance")
print("3. Check for any remaining errors")
