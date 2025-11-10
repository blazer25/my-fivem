local Core = nil

-- Initialize QBX and QBCore with safe placeholder structure to prevent nil errors
-- This ensures they exist even if core isn't ready yet
-- Set as globals immediately to prevent nil errors during script load
if not _G.QBX then
    _G.QBX = {
        Functions = {
            CreateCallback = function(...) 
                -- Wait a bit for initialization, then try again
                local attempts = 0
                local placeholder = _G.QBX  -- Store reference to check if it changed
                while attempts < 20 do
                    Wait(100)
                    attempts = attempts + 1
                    -- Check if real QBX is now available (it will be a different object)
                    if _G.QBX and _G.QBX.Functions and _G.QBX.Functions.CreateCallback and _G.QBX ~= placeholder then
                        return _G.QBX.Functions.CreateCallback(...)
                    end
                    -- Try to initialize if we can
                    if GetResourceState('qbx_core') == 'started' then
                        local success, coreObj = pcall(function()
                            return exports['qbx_core']:GetCoreObject()
                        end)
                        if success and coreObj and coreObj.Functions then
                            _G.QBX = coreObj
                            QBX = coreObj
                            return coreObj.Functions.CreateCallback(...)
                        end
                    end
                end
                print('^3[JPR Casino] WARNING: CreateCallback called before QBX initialized (after wait)^0')
                return nil 
            end,
            GetPlayer = function(source) 
                -- Wait a bit for initialization, then try again
                local attempts = 0
                local placeholder = _G.QBX  -- Store reference to check if it changed
                while attempts < 20 do
                    Wait(100)
                    attempts = attempts + 1
                    -- Check if real QBX is now available (it will be a different object)
                    if _G.QBX and _G.QBX.Functions and _G.QBX.Functions.GetPlayer and _G.QBX ~= placeholder then
                        return _G.QBX.Functions.GetPlayer(source)
                    end
                    -- Try to initialize if we can
                    if GetResourceState('qbx_core') == 'started' then
                        local success, coreObj = pcall(function()
                            return exports['qbx_core']:GetCoreObject()
                        end)
                        if success and coreObj and coreObj.Functions then
                            _G.QBX = coreObj
                            QBX = coreObj
                            return coreObj.Functions.GetPlayer(source)
                        end
                    end
                end
                print('^3[JPR Casino] WARNING: GetPlayer called before QBX initialized (after wait) for source ' .. tostring(source) .. '^0')
                return nil 
            end
        }
    }
end
-- Also set local QBX reference
QBX = _G.QBX

if not _G.QBCore then
    _G.QBCore = {}
end
if not QBCore then
    QBCore = {}
end

-- Function to initialize core from qbx_core
-- Only works on server side (exports are server-only)
local function initQBXCore()
    -- Only run on server side
    if not IsDuplicityVersion() then
        return false
    end
    
    local resourceState = GetResourceState('qbx_core')
    if resourceState ~= 'started' then
        return false
    end
    
    -- Try to get the core object
    -- Note: qbx_core might not export GetCoreObject directly, but qb-core bridge does
    local success, coreObj = pcall(function()
        -- Try qbx_core first (if it has the export)
        if exports['qbx_core'] and type(exports['qbx_core']) == 'table' and exports['qbx_core'].GetCoreObject then
            return exports['qbx_core']:GetCoreObject()
        end
        -- Try qb-core bridge (which re-exports it)
        if GetResourceState('qb-core') == 'started' and exports['qb-core'] and exports['qb-core'].GetCoreObject then
            return exports['qb-core']:GetCoreObject()
        end
        -- Last resort: try direct call (might work if export exists but isn't in table)
        return exports['qbx_core']:GetCoreObject()
    end)
    
    -- Verify that coreObj exists and has Functions before considering it initialized
    if success and coreObj then
        if coreObj.Functions then
            Core = coreObj
            -- Only update if we got a valid core object
            _G.QBX = coreObj  -- Set global QBX (replaces placeholder)
            QBX = coreObj     -- Also set local reference
            _G.QBCore = coreObj  -- ✅ backward-compatibility alias (explicit global)
            QBCore = coreObj     -- Also set without _G for compatibility
            print('^2[JPR Casino] Linked to QBOX Core via exports^0')
            return true
        else
            print('^3[JPR Casino] Warning: qbx_core object received but Functions not available yet (object type: ' .. tostring(type(coreObj)) .. ')^0')
            -- Check what properties it has
            if type(coreObj) == 'table' then
                local keys = {}
                for k, v in pairs(coreObj) do
                    table.insert(keys, tostring(k))
                end
                print('^3[JPR Casino] Object has keys: ' .. table.concat(keys, ', ') .. '^0')
            end
            return false
        end
    else
        -- Better error reporting
        if not success then
            print('^3[JPR Casino] pcall failed: ' .. tostring(coreObj) .. '^0')
        elseif not coreObj then
            print('^3[JPR Casino] Export returned nil^0')
        end
        return false
    end
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
-- Only run on server side (shared scripts run on both client and server)
local initialized = false
if IsDuplicityVersion() then
    local qbxState = GetResourceState('qbx_core')
    local qbCoreState = GetResourceState('qb-core')
    
    -- Wait for both qbx_core and qb-core bridge to be ready
    if (qbxState == 'started' or qbxState == 'starting') and (qbCoreState == 'started' or qbCoreState == 'starting') then
        -- Wait a bit for the resources to fully initialize
        Wait(2000)  -- Give resources 2 seconds to fully initialize and register exports
        
        -- Try a few times synchronously (with small waits) before going async
        for i = 1, 15 do
            if initQBXCore() then
                initialized = true
                break
            end
            if i < 15 then
                Wait(200)  -- Wait 200ms between attempts
            end
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
-- Use the same approach as server_config.lua which successfully initializes
-- Only run on server side (shared scripts run on both client and server)
if not initialized then
    if IsDuplicityVersion() then  -- Only run on server
        local qbxState = GetResourceState('qbx_core')
        local qbCoreState = GetResourceState('qb-core')
        
        if (qbxState == 'starting' or qbxState == 'started') or (qbCoreState == 'starting' or qbCoreState == 'started') then
            CreateThread(function()
                local attempts = 0
                local maxAttempts = 100  -- Wait up to 10 seconds (100 * 100ms) - same as server_config
                
                while (not _G.QBX or not _G.QBX.Functions) and attempts < maxAttempts do
                    Wait(100)  -- Use 100ms like server_config, not 500ms
                    attempts = attempts + 1
                    
                    -- Wait for both resources to be started
                    local qbxReady = GetResourceState('qbx_core') == 'started'
                    local qbCoreReady = GetResourceState('qb-core') == 'started'
                    
                    -- Actively try to initialize during the wait (like server_config does)
                    -- Try both qbx_core and qb-core exports (bridge might provide it)
                    if (qbxReady or qbCoreReady) and (not _G.QBX or not _G.QBX.Functions) then
                        local success, coreObj = pcall(function()
                            -- Try qbx_core first
                            if exports['qbx_core'] and exports['qbx_core'].GetCoreObject then
                                return exports['qbx_core']:GetCoreObject()
                            end
                            -- Fallback to qb-core bridge if available
                            if GetResourceState('qb-core') == 'started' and exports['qb-core'] and exports['qb-core'].GetCoreObject then
                                return exports['qb-core']:GetCoreObject()
                            end
                            return nil
                        end)
                        if success and coreObj and coreObj.Functions then
                            Core = coreObj
                            _G.QBX = coreObj
                            QBX = coreObj
                            _G.QBCore = coreObj
                            QBCore = coreObj
                            print('^2[JPR Casino] Successfully initialized QBOX Core after ' .. attempts .. ' attempts^0')
                            return  -- Successfully initialized
                        elseif not success and attempts % 20 == 0 then
                            print('^3[JPR Casino] Initialization attempt ' .. attempts .. ' failed: ' .. tostring(coreObj) .. '^0')
                        elseif success and coreObj and not coreObj.Functions and attempts % 20 == 0 then
                            print('^3[JPR Casino] Initialization attempt ' .. attempts .. ': Got object but no Functions^0')
                        elseif success and not coreObj and attempts % 20 == 0 then
                            print('^3[JPR Casino] Initialization attempt ' .. attempts .. ': Export returned nil^0')
                        end
                    end
                    
                    -- Also try using initQBXCore function
                    if initQBXCore() then
                        print('^2[JPR Casino] Successfully initialized QBOX Core via initQBXCore after ' .. attempts .. ' attempts^0')
                        return  -- Successfully initialized
                    end
                    
                    -- Print progress every 10 attempts (reduced spam)
                    if attempts % 10 == 0 then
                        local state = GetResourceState('qbx_core')
                        print('^3[JPR Casino] Still waiting for qbx_core... (attempt ' .. attempts .. '/' .. maxAttempts .. ', state: ' .. tostring(state) .. ')^0')
                    end
                end
                
                -- If we still haven't initialized, keep placeholder structure
                if not Core or not Core.Functions then
                    local finalState = GetResourceState('qbx_core')
                    print('^1[JPR Casino] ERROR: Failed to initialize QBOX Core after ' .. maxAttempts .. ' retries^0')
                    print('^1[JPR Casino] qbx_core state: ' .. tostring(finalState) .. '^0')
                    print('^1[JPR Casino] Check if qbx_core is started and the export is working^0')
                    print('^1[JPR Casino] Try: ensure qbx_core is started BEFORE jpr-casinosystem in server.cfg^0')
                    -- Keep the placeholder structure to prevent nil errors
                    Core = {}
                end
            end)
        else
            print('^1[JPR Casino] No core framework detected (qbx_core or qb-core)^0')
            print('^1[JPR Casino] qbx_core state: ' .. tostring(GetResourceState('qbx_core')) .. '^0')
            Core = {}
            -- Keep placeholder structure for QBX and QBCore
        end
    end
end

return Core
