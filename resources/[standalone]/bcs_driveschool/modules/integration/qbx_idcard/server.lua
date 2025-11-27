DebugPrint("qbx_idcard server loaded")
---@type LicensesList
local licenseList = {}
local qbx = exports.qbx_core
local ox_inventory = exports.ox_inventory

-- Load config with error handling
local configData = lib.load('@qbx_idcard.config.shared')
if not configData then
    error("Failed to load qbx_idcard config. Make sure qbx_idcard is started before bcs_driveschool.")
end

local licensesIdcard = configData.licenses
if not licensesIdcard then
    error("qbx_idcard config.licenses table not found. Check qbx_idcard/config/shared.lua")
end

for i = 1, #Shared.config.licenses, 1 do
    if not licensesIdcard[Shared.config.licenses[i]] then
        DebugWarn(Shared.config.licenses[i] .. " not found in qbx_idcard/config/shared.lua please add")
    else
        licenseList[Shared.config.licenses[i]] = licensesIdcard[Shared.config.licenses[i]].header
    end
end

for i = 1, #Shared.config.theoryLicenses, 1 do
    if not licensesIdcard[Shared.config.theoryLicenses[i]] then
        DebugWarn(Shared.config.theoryLicenses[i] .. " not found in qbx_idcard/config/shared.lua please add")
    else
        licenseList[Shared.config.theoryLicenses[i]] = licensesIdcard[Shared.config.theoryLicenses[i]].header
    end
end

-- Helper function to check if license type is a theory license
local function IsTheory(type)
    if not type then return false end
    for i = 1, #Shared.config.theoryLicenses do
        if Shared.config.theoryLicenses[i] == type then
            return true
        end
    end
    return false
end

RegisterNetEvent('qbx_idcard:integration:server:GiveLicense', function(type)
    local source = source
    local player = qbx:GetPlayer(source)
    if not player then
        DebugWarn("Failed to give license " .. type .. " - player not found")
        return
    end

    if not Shared.config.examProveAsLicense and IsTheory(type) then
        return Server.GiveTheory(source, type)
    end

    -- Check if player already has the license
    local licenses = qbx:GetMetadata(source, 'licences') or {}
    if licenses[type] then
        DebugPrint("Player already has license: " .. type)
        -- Still give the item if they don't have it in inventory
        local hasItem = ox_inventory:Search(source, 1, type)
        if not hasItem or #hasItem == 0 then
            DebugPrint("Player has license metadata but no item, adding item: " .. type)
            ox_inventory:AddItem(source, type, 1, exports.qbx_idcard:GetMetaLicense(source, { type }))
        end
        return
    end

    -- Give the license
    DebugPrint("Giving license: " .. type .. " to player " .. source)
    licenses[type] = true
    qbx:SetMetadata(source, 'licences', licenses)
    
    local success, err = pcall(function()
        ox_inventory:AddItem(source, type, 1, exports.qbx_idcard:GetMetaLicense(source, { type }))
    end)
    
    if not success then
        DebugWarn("Failed to add license item " .. type .. " to inventory: " .. tostring(err))
        -- Still keep the metadata even if item add failed
    else
        DebugPrint("Successfully gave license " .. type .. " to player " .. source)
    end
end)

lib.callback.register('driveschool:server:GetLicensesList', function(source, type)
    return licenseList
end)

lib.callback.register('qbx_idcard:integration:server:GetPlayerLicenses', function(source)
    return qbx:GetMetadata(source, 'licences') or {}
end)
