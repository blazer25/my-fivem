DebugPrint("QBX client loaded")
QBX = exports['qbx_core']

RegisterNetEvent('qbx_medical:client:onPlayerDied', function()
    if exports.bcs_driveschool:GetPractical() then
        exports.bcs_driveschool:PracticalEnd()
    end
end)

---@diagnostic disable-next-line: duplicate-set-field
function Client.GetPlayerData()
    return QBX:GetPlayerData()
end

---@diagnostic disable-next-line: duplicate-set-field
function Client.PlayerHasTheory(typeTheory)
    local metadata = Client.GetPlayerData().metadata or {}
    local theoryLicenses = metadata.exam_driveschool or {}
    return theoryLicenses[typeTheory]
end
