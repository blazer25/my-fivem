local Core = nil

-- Initialize QBX and QBCore with safe placeholder structure to prevent nil errors
-- This ensures they exist even if core isn't ready yet
-- Set as globals immediately to prevent nil errors during script load
-- These placeholders wait for server_config.lua to initialize the real QBX
if not _G.QBX then
    _G.QBX = {
        Functions = {
            CreateCallback = function(...) 
                -- Wait for server_config.lua to initialize QBX
                local attempts = 0
                local placeholder = _G.QBX  -- Store reference to check if it changed
                while attempts < 50 do
                    Wait(100)
                    attempts = attempts + 1
                    -- Check if real QBX is now available (it will be a different object)
                    if _G.QBX and _G.QBX.Functions and _G.QBX.Functions.CreateCallback and _G.QBX ~= placeholder then
                        return _G.QBX.Functions.CreateCallback(...)
                    end
                end
                print('^3[JPR Casino] WARNING: CreateCallback called before QBX initialized (after wait)^0')
                return nil 
            end,
            GetPlayer = function(source) 
                -- Wait for server_config.lua to initialize QBX
                local attempts = 0
                local placeholder = _G.QBX  -- Store reference to check if it changed
                while attempts < 50 do
                    Wait(100)
                    attempts = attempts + 1
                    -- Check if real QBX is now available (it will be a different object)
                    if _G.QBX and _G.QBX.Functions and _G.QBX.Functions.GetPlayer and _G.QBX ~= placeholder then
                        return _G.QBX.Functions.GetPlayer(source)
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

-- Simplified initialization: Let server_config.lua handle actual initialization
-- This file just sets up placeholders to prevent nil errors
-- server_config.lua runs later as a server script and successfully initializes QBX

-- On server side, set up a thread to sync with server_config.lua's initialization
if IsDuplicityVersion() then
    CreateThread(function()
        -- Wait a bit for server_config.lua to initialize
        Wait(2000)
        
        -- Check if server_config.lua has initialized QBX
        local attempts = 0
        local maxAttempts = 50  -- Wait up to 5 seconds
        
        while (not _G.QBX or not _G.QBX.Functions) and attempts < maxAttempts do
            Wait(100)
            attempts = attempts + 1
            
            -- Check if QBX was set by server_config.lua
            if _G.QBX and _G.QBX.Functions then
                Core = _G.QBX
                QBX = _G.QBX
                _G.QBCore = _G.QBX
                QBCore = _G.QBX
                print('^2[JPR Casino] Synced with server_config initialization^0')
                return
            end
        end
        
        if _G.QBX and _G.QBX.Functions then
            Core = _G.QBX
            print('^2[JPR Casino] Core synced from server_config^0')
        else
            print('^3[JPR Casino] WARNING: server_config.lua did not initialize QBX^0')
            Core = {}
        end
    end)
end

return Core
