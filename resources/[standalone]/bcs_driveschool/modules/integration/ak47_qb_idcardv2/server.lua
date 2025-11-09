local licenseList = {}

for i = 1, #Shared.config.licenses, 1 do
    local label = exports['ak47_qb_idcardv2']:GetLicenseLabel(Shared.config.licenses[i])
    if not label or type(label) ~= 'string' then
        DebugWarn(Shared.config.licenses[i] .. " not found please add into ak47_qb_idcardv2 Config.Cards ")
    else
        licenseList[Shared.config.licenses[i]] = label
    end
end

for i = 1, #Shared.config.theoryLicenses, 1 do
    local label = exports['ak47_qb_idcardv2']:GetLicenseLabel(Shared.config.theoryLicenses[i])
    if not label or type(label) ~= 'string' then
        DebugWarn(Shared.config.theoryLicenses[i] .. " not found please add into ak47_qb_idcardv2 Config.Cards ")
    else
        licenseList[Shared.config.theoryLicenses[i]] = label
    end
end

lib.callback.register('driveschool:server:GetLicensesList', function()
    return licenseList
end)

RegisterNetEvent('ak47_qb_idcardv2:integration:server:GiveLicense', function(typeLicense)
    local source = source
    if not Shared.config.examProveAsLicense and IsTheory(typeLicense) then
        return Server.GiveTheory(source, typeLicense)
    end
    exports['ak47_qb_idcardv2']:GiveIdCard(source, {
        item = typeLicense,
        class = 'C',
        address = '1234, Demo City Name',
        expire = 1,
    })
end)
