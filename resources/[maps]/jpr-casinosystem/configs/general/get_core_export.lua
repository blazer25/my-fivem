local Core = nil

-- Initialize QBX and QBCore with safe placeholder structure to prevent nil errors
-- This ensures they exist even if core isn't ready yet
if not QBX then
    QBX = {}
end
if not _G.QBCore then
    _G.QBCore = {}
end
if not QBCore then
    QBCore = {}
end

-- Function to initialize core from qbx_core
local function initQBXCore()
    if GetResourceState('qbx_core') == 'started' then
        local success, coreObj = pcall(function()
            return exports['qbx_core']:GetCoreObject()
        end)
        
        -- Verify that coreObj exists and has Functions before considering it initialized
        if success and coreObj and coreObj.Functions then
            Core = coreObj
            QBX = coreObj  -- Set global QBX
            _G.QBCore = coreObj  -- ✅ backward-compatibility alias (explicit global)
            QBCore = coreObj     -- Also set without _G for compatibility
            print('^2[JPR Casino] Linked to QBOX Core via exports^0')
            return true
        else
            if success and coreObj then
                print('^3[JPR Casino] Warning: qbx_core object received but Functions not available yet^0')
            else
                print('^3[JPR Casino] Warning: qbx_core export not ready yet, will retry...^0')
            end
            return false
        end
    end
    return false
end

-- Function to initialize core from qb-core
local function initQBCore()
    if GetResourceState('qb-core') == 'started' then
        local success, coreObj = pcall(function()
            return exports['qb-core']:GetCoreObject()
        end)
        
        if success and coreObj then
            Core = coreObj
            _G.QBCore = coreObj
            QBCore = coreObj
            print('^2[JPR Casino] Linked to QB-Core^0')
            return true
        end
    end
    return false
end

-- Try to initialize immediately with a short synchronous wait
local initialized = false
if GetResourceState('qbx_core') == 'started' or GetResourceState('qbx_core') == 'starting' then
    -- Try a few times synchronously (with small waits) before going async
    for i = 1, 5 do
        if initQBXCore() then
            initialized = true
            break
        end
        if i < 5 then
            Wait(100)  -- Small wait between attempts
        end
    end
end

-- Only try qb-core if qbx_core is not available at all
-- Don't fall back to qb-core if qbx_core exists but just isn't ready yet
if not initialized then
    if GetResourceState('qbx_core') ~= 'started' and GetResourceState('qbx_core') ~= 'starting' then
        -- qbx_core doesn't exist, try qb-core as fallback
        if GetResourceState('qb-core') == 'started' then
            initialized = initQBCore()
        end
    end
end

-- If initialization failed, set up async retry mechanism
if not initialized then
    if GetResourceState('qbx_core') == 'starting' or GetResourceState('qbx_core') == 'started' then
        CreateThread(function()
            local attempts = 0
            local maxAttempts = 40  -- Try for up to 20 seconds (40 * 500ms)
            
            while attempts < maxAttempts do
                Wait(500)
                attempts = attempts + 1
                
                if initQBXCore() then
                    print('^2[JPR Casino] Successfully initialized QBOX Core after ' .. attempts .. ' attempts^0')
                    return  -- Successfully initialized
                end
            end
            
            -- If we still haven't initialized, keep placeholder structure
            if not Core or not Core.Functions then
                print('^1[JPR Casino] ERROR: Failed to initialize QBOX Core after ' .. maxAttempts .. ' retries^0')
                -- Keep the placeholder structure to prevent nil errors
                Core = {}
            end
        end)
    else
        print('^1[JPR Casino] No core framework detected (qbx_core or qb-core)^0')
        Core = {}
        -- Keep placeholder structure for QBX and QBCore
    end
end

return Core
