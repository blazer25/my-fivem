DebugPrint("qb-license client loaded")

---@diagnostic disable-next-line: duplicate-set-field
function Client.GetPlayerLicenses()
    return Client.GetPlayerData().metadata.licenses or {}
end

---@diagnostic disable-next-line: duplicate-set-field
function Client.PlayerHasLicense(type)
    if not Shared.config.examProveAsLicense and IsTheory(type) then
        return Client.PlayerHasTheory(type)
    end
    return Client.GetPlayerLicenses()[type] == true
end

---@diagnostic disable-next-line: duplicate-set-field
function Client.GivePlayerLicense(type)
    DebugPrint("Gave license: " .. type)
    TriggerServerEvent('qb-license:integration:server:GiveLicense', type)
end
