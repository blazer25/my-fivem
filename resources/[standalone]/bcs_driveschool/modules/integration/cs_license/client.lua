DebugPrint("cs_license client loaded")

---@diagnostic disable-next-line: duplicate-set-field
function Client.GetPlayerLicenses()
    return lib.callback.await('cs_license:integration:server:GetLicenses')
end

---@diagnostic disable-next-line: duplicate-set-field
function Client.PlayerHasLicense(type)
        if not Shared.config.examProveAsLicense and IsTheory(type) then
        return Client.PlayerHasTheory(type)
    end
    return lib.callback.await('cs_license:integration:server:HasLicense', false, type)
end

---@diagnostic disable-next-line: duplicate-set-field
function Client.GivePlayerLicense(type)
    DebugPrint("Gave license: " .. type)
    TriggerServerEvent('cs_license:integration:server:GiveLicense', type)
end
