DebugPrint("bcs_licensemanager client loaded")

---@diagnostic disable-next-line: duplicate-set-field
function Client.GetPlayerLicenses()
    return lib.callback.await('bcs_licensemanager:integration:server:GetLicenses')
end

---@diagnostic disable-next-line: duplicate-set-field
function Client.PlayerHasLicense(type)
    if not Shared.config.examProveAsLicense and IsTheory(type) then
        return Client.PlayerHasTheory(type)
    end
    return lib.callback.await('bcs_licensemanager:integration:server:HasLicense', false, type)
end

---@diagnostic disable-next-line: duplicate-set-field
function Client.GivePlayerLicense(type)
    DebugPrint("Gave license: " .. type)

    if not Shared.config.examProveAsLicense and IsTheory(type) then
        TriggerServerEvent('bcs_licensemanager:integration:server:GiveTheory', type)
        return
    end
    TriggerEvent('LicenseManager:client:AddLicense', type, 'Drive School')
end
