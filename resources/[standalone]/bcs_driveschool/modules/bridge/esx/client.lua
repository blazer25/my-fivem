DebugPrint("ESX client loaded")
ESX = exports.es_extended:getSharedObject()

RegisterNetEvent('esx:onPlayerDeath', function()
    if exports.bcs_driveschool:GetPractical() then
        exports.bcs_driveschool:PracticalEnd()
    end
end)

---@diagnostic disable-next-line: duplicate-set-field
Client.GetPlayerData = function()
    return ESX.GetPlayerData()
end

---@diagnostic disable-next-line: duplicate-set-field
Client.PlayerHasTheory = function(typeTheory)
    local metadata = Client.GetPlayerData().metadata or {}
    local theoryLicenses = metadata.exam_driveschool or {}
    return theoryLicenses[typeTheory]
end
