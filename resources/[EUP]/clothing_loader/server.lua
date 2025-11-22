-- Clothing/EUP Loader - Server Script
-- Manages clothing builds and provides admin commands

local clothingLoader = {
    version = "1.0.0",
    buildInfo = {
        lastBuild = nil,
        totalFiles = 0,
        totalClothing = 0,
        errors = {}
    }
}

-- Initialize server
CreateThread(function()
    print("^2[Clothing Loader]^7 Server initialized - Version " .. clothingLoader.version)
    LoadBuildInfo()
end)

-- Load build information
function LoadBuildInfo()
    local buildFile = LoadResourceFile(GetCurrentResourceName(), 'build_info.json')
    if buildFile then
        local success, buildData = pcall(json.decode, buildFile)
        if success then
            clothingLoader.buildInfo = buildData
            print(string.format("^2[Clothing Loader]^7 Build info loaded - %d files processed", 
                clothingLoader.buildInfo.totalFiles or 0))
        end
    else
        print("^3[Clothing Loader]^7 No build info found - run build script to generate")
    end
end

-- Save build information
function SaveBuildInfo()
    local buildJson = json.encode(clothingLoader.buildInfo, {indent = true})
    SaveResourceFile(GetCurrentResourceName(), 'build_info.json', buildJson, -1)
end

-- Helper function to check admin permissions
local function isPlayerAdmin(source)
    if source == 0 then return true end -- Console is always admin
    
    -- Check for various admin permissions
    if IsPlayerAceAllowed(source, 'clothing.admin') then return true end
    if IsPlayerAceAllowed(source, 'admin') then return true end
    if IsPlayerAceAllowed(source, 'god') then return true end
    if IsPlayerAceAllowed(source, 'qbcore.admin') then return true end
    if IsPlayerAceAllowed(source, 'qbcore.god') then return true end
    
    return false
end

-- Admin command to get build status
RegisterCommand('clothinginfo', function(source, args, rawCommand)
    if isPlayerAdmin(source) then
        local info = clothingLoader.buildInfo
        
        if source == 0 then
            -- Console output
            print("^2=== Clothing Loader Build Info ===^7")
            print(string.format("Last Build: %s", info.lastBuild or "Never"))
            print(string.format("Total Files: %d", info.totalFiles or 0))
            print(string.format("Total Clothing Items: %d", info.totalClothing or 0))
            print(string.format("Errors: %d", #(info.errors or {})))
            
            if info.errors and #info.errors > 0 then
                print("^1Recent Errors:^7")
                for i, error in ipairs(info.errors) do
                    if i <= 5 then -- Show only last 5 errors
                        print(string.format("  - %s", error))
                    end
                end
            end
        else
            -- Player output
            TriggerClientEvent('chat:addMessage', source, {
                color = {0, 255, 0},
                multiline = true,
                args = {"Clothing Loader", string.format("Build: %s | Files: %d | Items: %d | Errors: %d", 
                    info.lastBuild or "Never", 
                    info.totalFiles or 0, 
                    info.totalClothing or 0, 
                    #(info.errors or {}))}
            })
        end
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Clothing Loader", "You don't have permission to use this command."}
        })
    end
end, false)

-- Admin command to rebuild clothing
RegisterCommand('rebuildclothing', function(source, args, rawCommand)
    if isPlayerAdmin(source) then
        if source == 0 then
            print("^3[Clothing Loader]^7 Manual rebuild requested from console")
        else
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 255, 0},
                multiline = true,
                args = {"Clothing Loader", "Rebuild requested. Check console for progress."}
            })
        end
        
        -- Trigger rebuild (this would typically call the Node.js script)
        ExecuteCommand('system "node resources/[EUP]/clothing_loader/scripts/build_clothing.js"')
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Clothing Loader", "You don't have permission to use this command."}
        })
    end
end, false)

-- Export build info for other resources
exports('GetBuildInfo', function()
    return clothingLoader.buildInfo
end)

-- Export function to update build info (used by build script)
exports('UpdateBuildInfo', function(newInfo)
    clothingLoader.buildInfo = newInfo
    SaveBuildInfo()
end)

-- Event handler for build completion
RegisterNetEvent('clothing_loader:buildComplete', function(buildData)
    clothingLoader.buildInfo = buildData
    SaveBuildInfo()
    
    print("^2[Clothing Loader]^7 Build completed successfully!")
    print(string.format("  Files processed: %d", buildData.totalFiles))
    print(string.format("  Clothing items: %d", buildData.totalClothing))
    
    if buildData.errors and #buildData.errors > 0 then
        print(string.format("^1  Errors encountered: %d^7", #buildData.errors))
    end
end)

-- Clothing outfit management
local playerOutfits = {}

-- Helper function to get player identifier
local function getPlayerIdentifier(source)
    local identifiers = GetPlayerIdentifiers(source)
    for _, id in pairs(identifiers) do
        if string.find(id, "license:") then
            return id
        end
    end
    return nil
end

-- Save player outfit
RegisterNetEvent('clothing_loader:saveOutfit', function(outfitName, outfitData)
    local source = source
    local identifier = getPlayerIdentifier(source)
    
    if not identifier then return end
    
    if not playerOutfits[identifier] then
        playerOutfits[identifier] = {}
    end
    
    playerOutfits[identifier][outfitName] = {
        data = outfitData,
        created = os.time(),
        modified = os.time()
    }
    
    TriggerClientEvent('chat:addMessage', source, {
        color = {0, 255, 0},
        multiline = true,
        args = {"Clothing Loader", string.format("Outfit '%s' saved successfully!", outfitName)}
    })
end)

-- Load player outfit
RegisterNetEvent('clothing_loader:loadOutfit', function(outfitName)
    local source = source
    local identifier = getPlayerIdentifier(source)
    
    if not identifier or not playerOutfits[identifier] or not playerOutfits[identifier][outfitName] then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Clothing Loader", "Outfit not found!"}
        })
        return
    end
    
    local outfit = playerOutfits[identifier][outfitName]
    TriggerClientEvent('clothing_loader:applyOutfit', source, outfit.data)
end)

-- Get player outfits list (using event-based system for compatibility)
RegisterNetEvent('clothing_loader:getOutfits', function()
    local source = source
    local identifier = getPlayerIdentifier(source)
    
    local outfitsList = {}
    if identifier and playerOutfits[identifier] then
        for name, outfit in pairs(playerOutfits[identifier]) do
            table.insert(outfitsList, {
                name = name,
                created = outfit.created,
                modified = outfit.modified
            })
        end
    end
    
    TriggerClientEvent('clothing_loader:receiveOutfits', source, outfitsList)
end)

-- Resource stop handler
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        SaveBuildInfo()
    end
end)
