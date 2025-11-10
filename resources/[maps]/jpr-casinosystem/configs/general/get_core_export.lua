local Core = nil

-- Initialize QBX and QBCore with safe placeholder structure to prevent nil errors
-- This ensures they exist even if core isn't ready yet
-- Set as globals immediately to prevent nil errors during script load
if not _G.QBX then
    _G.QBX = {
        Functions = {
            CreateCallback = function(...) 
                print('^3[JPR Casino] WARNING: CreateCallback called before QBX initialized^0')
                return nil 
            end,
            GetPlayer = function(...) 
                print('^3[JPR Casino] WARNING: GetPlayer called before QBX initialized^0')
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
local function initQBXCore()
    if GetResourceState('qbx_core') ~= 'started' then
        return false
    end
    
    -- Check if export exists
    local exportExists = pcall(function()
        return exports['qbx_core'] ~= nil
    end)
    
    if not exportExists then
        return false
    end
    
    -- Try to get the core object
    local success, coreObj = pcall(function()
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
        local errMsg = "unknown error"
        if not success then
            errMsg = tostring(coreObj)  -- coreObj contains the error message
        elseif not coreObj then
            errMsg = "export returned nil"
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
local initialized = false
local resourceState = GetResourceState('qbx_core')
if resourceState == 'started' or resourceState == 'starting' then
    -- Wait a bit for the resource to fully initialize
    Wait(1000)  -- Give qbx_core 1 second to fully initialize
    
    -- Try a few times synchronously (with small waits) before going async
    for i = 1, 10 do
        if initQBXCore() then
            initialized = true
            break
        end
        if i < 10 then
            Wait(200)  -- Wait 200ms between attempts
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
            local maxAttempts = 100  -- Try for up to 50 seconds (100 * 500ms)
            local lastWarning = 0
            
            while attempts < maxAttempts do
                Wait(500)
                attempts = attempts + 1
                
                if initQBXCore() then
                    print('^2[JPR Casino] Successfully initialized QBOX Core after ' .. attempts .. ' attempts^0')
                    return  -- Successfully initialized
                end
                
                -- Print progress every 10 attempts (reduced spam)
                if attempts % 10 == 0 then
                    print('^3[JPR Casino] Still waiting for qbx_core... (attempt ' .. attempts .. '/' .. maxAttempts .. ')^0')
                end
            end
            
            -- If we still haven't initialized, keep placeholder structure
            if not Core or not Core.Functions then
                print('^1[JPR Casino] ERROR: Failed to initialize QBOX Core after ' .. maxAttempts .. ' retries^0')
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

return Core
