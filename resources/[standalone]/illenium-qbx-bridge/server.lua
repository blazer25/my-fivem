-- illenium-appearance QBX Bridge - Server Side
-- Provides QB Core compatible exports that route to QBX Core

local QBXCore = nil
local bridgeReady = false

-- Bridge exports for illenium-appearance
-- Register exports immediately so they're available even before initialization completes

local BridgeExports = {
    -- Get player using QBX Core
    GetPlayer = function(src)
        if not bridgeReady or not QBXCore then return nil end
        return QBXCore:GetPlayer(src)
    end,
    
    -- Check if bridge is ready
    IsReady = function()
        return bridgeReady
    end,
    
    -- Get QBX Core directly
    GetQBXCore = function()
        return QBXCore
    end
}

-- Register the exports table immediately (before initialization)
exports('illenium-qbx-bridge', BridgeExports)

-- Initialize bridge immediately (synchronous check first, then async wait if needed)
if GetResourceState('qbx_core') == 'started' then
    -- Try to get QBX Core exports immediately
    QBXCore = exports.qbx_core
    
    if QBXCore then
        bridgeReady = true
        print("^2[illenium-qbx-bridge] Server bridge initialized successfully!^7")
    else
        print("^3[illenium-qbx-bridge] qbx_core started but exports not ready, waiting...^7")
    end
end

-- If not ready, wait asynchronously
if not bridgeReady then
    CreateThread(function()
        -- Wait for qbx_core to be ready
        while GetResourceState('qbx_core') ~= 'started' do
            Wait(100) -- Check more frequently
        end
        
        -- Get QBX Core exports
        QBXCore = exports.qbx_core
        
        if not QBXCore then
            print("^1[illenium-qbx-bridge] Failed to get qbx_core exports!^7")
            return
        end
        
        bridgeReady = true
        print("^2[illenium-qbx-bridge] Server bridge initialized successfully!^7")
    end)
end
