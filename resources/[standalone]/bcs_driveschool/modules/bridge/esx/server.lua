DebugPrint("ESX server loaded")
ESX = exports.es_extended:getSharedObject()

---@param source number
---@return Player | nil
---@diagnostic disable-next-line: duplicate-set-field
Server.GetPlayer = function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        return {
            identifier = xPlayer.identifier,
            source = source,
            ---@param amount number
            ---@param type string
            HasMoney = function(amount, type)
                if type == 'cash' then type = 'money' end
                return xPlayer.getAccount(type).money >= amount
            end,
            ---@param amount number
            ---@param type string
            RemoveMoney = function(amount, type)
                if type == 'cash' then type = 'money' end
                xPlayer.removeAccountMoney(type, amount)
            end,
            SetMetadata = xPlayer.setMeta,
        }
    end

    return nil
end

---@param source number
---@param typeTheory string
---@diagnostic disable-next-line: duplicate-set-field
Server.GiveTheory = function(source, typeTheory)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local metadata = xPlayer.getMeta('exam_driveschool') or {}
        metadata[typeTheory] = true
        xPlayer.setMeta('exam_driveschool', metadata)
    end
end
