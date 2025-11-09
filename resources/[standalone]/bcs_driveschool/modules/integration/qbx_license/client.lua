DebugPrint("qbx_license client loaded")

---@diagnostic disable-next-line: duplicate-set-field
function Client.GetPlayerLicenses()
    return lib.callback.await('qbx_license:integration:server:GetPlayerLicenses')
end

---@diagnostic disable-next-line: duplicate-set-field
function Client.PlayerHasLicense(type)
    if not Shared.config.examProveAsLicense and IsTheory(type) then
        return Client.PlayerHasTheory(type)
    end
    return Client.GetPlayerLicenses()[type] ~= nil
end

---@diagnostic disable-next-line: duplicate-set-field
function Client.GivePlayerLicense(type)
    DebugPrint("Gave license: " .. type)
    TriggerServerEvent('qbx_license:integration:server:GiveLicense', type)
end
