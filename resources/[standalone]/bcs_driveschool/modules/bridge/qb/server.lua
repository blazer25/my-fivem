DebugPrint("QB server loaded")

QBCore = exports["qb-core"]:GetCoreObject()

---@param source number
---@return Player | nil
---@diagnostic disable-next-line: duplicate-set-field
Server.GetPlayer = function(source)
    local player = QBCore.Functions.GetPlayer(source)
    if player then
        return {
            identifier = player.PlayerData.citizenid,
            source = source,

            ---@param amount number
            ---@param type string
            HasMoney = function(amount, type)
                return player.PlayerData.money[type] >= amount
            end,
            ---@param amount number
            ---@param type string
            RemoveMoney = function(amount, type)
                player.Functions.RemoveMoney(type, amount)
            end,
            SetMetadata = player.Functions.SetMetaData,
        }
    end

    return nil
end

---@param source number
---@param typeTheory string
---@diagnostic disable-next-line: duplicate-set-field
Server.GiveTheory = function(source, typeTheory)
    local player = QBCore.Functions.GetPlayer(source)
    if player then
        local metadata = player.PlayerData.metadata or {}
        local theoryLicenses = metadata.exam_driveschool or {}
        theoryLicenses[typeTheory] = true
        player.Functions.SetMetaData('exam_driveschool', theoryLicenses)
    end
end
