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

RegisterNetEvent('qbx_idcard:integration:server:GiveLicense', function(type)
    local source = source
    local player = qbx:GetPlayer(source)
    if player then
        if not Shared.config.examProveAsLicense and IsTheory(type) then
            return Server.GiveTheory(source, type)
        end

        local licenses = qbx:GetMetadata(source, 'licences') or {}
        licenses[type] = true
        qbx:SetMetadata(source, 'licences', licenses)
        ox_inventory:AddItem(source, type, 1, exports.qbx_idcard:GetMetaLicense(source, { type }))
    end
end)

lib.callback.register('driveschool:server:GetLicensesList', function(source, type)
    return licenseList
end)

lib.callback.register('qbx_idcard:integration:server:GetPlayerLicenses', function(source)
    return qbx:GetMetadata(source, 'licences') or {}
end)
