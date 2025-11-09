DebugPrint("QBX server loaded")

local qbx = exports.qbx_core

---@param source number
---@return Player | nil
---@diagnostic disable-next-line: duplicate-set-field
Server.GetPlayer = function(source)
    local player = qbx:GetPlayer(source)
    if player then
        return {
            identifier = player.PlayerData.citizenid,
            source = source,

            ---@param amount number
            ---@param type string
            HasMoney = function(amount, type)
                return qbx:GetMoney(source, type) >= amount
            end,
            ---@param amount number
            ---@param type string
            RemoveMoney = function(amount, type)
                qbx:RemoveMoney(source, type, amount)
            end,
            ---@param key string
            ---@param value any
            SetMetadata = function(key, value)
                qbx:SetMetadata(source, key, value)
            end,
        }
    end

    return nil
end

---@param source number
---@param typeTheory string
---@diagnostic disable-next-line: duplicate-set-field
Server.GiveTheory = function(source, typeTheory)
    local player = qbx:GetPlayer(source)
    if player then
        local metadata = qbx:GetMetadata(source, 'exam_driveschool') or {}
        local theoryLicenses = metadata or {}
        theoryLicenses[typeTheory] = true
        qbx:SetMetadata(source, 'exam_driveschool', theoryLicenses)
    end
end