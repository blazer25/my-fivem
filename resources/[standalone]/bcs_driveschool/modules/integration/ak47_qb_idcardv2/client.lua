DebugPrint("ak47_qbidcardv2 client loaded")

---@diagnostic disable-next-line: duplicate-set-field
function Client.GetPlayerLicenses()
end

---@diagnostic disable-next-line: duplicate-set-field
function Client.PlayerHasLicense(type)
    if not Shared.config.examProveAsLicense and IsTheory(type) then
        return Client.PlayerHasTheory(type)
    end
    return exports['ak47_qb_idcardv2']:HasLicense(type)
end

---@diagnostic disable-next-line: duplicate-set-field
function Client.GivePlayerLicense(type)
    DebugPrint("Gave license: " .. type)
    TriggerServerEvent('ak47_qb_idcardv2:integration:server:GiveLicense', type)
end
