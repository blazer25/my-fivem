DebugPrint("cs_license server loaded")

---@type LicensesList
local licenseList = {}

for i = 1, #Shared.config.licenses, 1 do ---@todo license list
    local license = Shared.config.licenses[i]
    licenseList[license] = license
end

lib.callback.register('cs_license:integration:server:GetLicenses', function(source)
    local player = Server.GetPlayer(source)
    local identifier = player.identifier
    local licenses = exports['cs_license']:GetPlayerLicenses(identifier)
    local retval = {}
    for i = 1, #licenses, 1 do
        retval[licenses[i].license] = true
    end
    return retval
end)

lib.callback.register('cs_license:integration:server:HasLicense', function(source, type)
    local player = Server.GetPlayer(source)
    local identifier = player.identifier
    local result = exports['cs_license']:GetPlayerLicenses(identifier)

    if result and result[1] then
        for i = 1, #result, 1 do
            if result[i].license == type then
                return true
            end
        end
    end
    return false
end)

lib.callback.register('driveschool:server:GetLicensesList', function(source, type)
    return licenseList
end)

RegisterNetEvent('cs_license:integration:server:GiveLicense', function(type)
    local source = source
    if not Shared.config.examProveAsLicense and IsTheory(type) then
        return Server.GiveTheory(source, type)
    end
    exports['cs_license']:RegisterCard(source, type, 7, true)
end)
