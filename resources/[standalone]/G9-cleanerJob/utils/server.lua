G9Series = {}


function G9Series:getPlayer(src)
    if core == nil then return core end

    if framework then
        return core.Functions.GetPlayer(src)
    else
        return core.GetPlayerFromId(src)
    end
end

function G9Series:getIdentifier(player)
    if player == nil then
        return false
    end

    if framework then
        local identifier = player.PlayerData.citizenid
        if identifier == nil then
            return false
        end
        return identifier
    elseif not framework then
        return player.getIdentifier()
    else
        return false
    end
end


function G9Series:removeMoney(source, type, amount)
    amount = tonumber(amount)
    if framework then
        local player = core.Functions.GetPlayer(source)
        if type == "bank" then
            if player.PlayerData.money["bank"] >= amount then
                player.Functions.RemoveMoney("bank", amount)
                return true
            else
                return false
            end
        elseif type == "cash" then
            if player.PlayerData.money["cash"] >= amount then
                player.Functions.RemoveMoney("cash", amount)
                return true
            else
                return false
            end
        else
            return false
        end
    elseif not framework then
        local xPlayer = core.GetPlayerFromId(source)
        if type == "bank" then
            if xPlayer.getAccount("bank").money >= amount then
                xPlayer.removeAccountMoney("bank", amount)
                return true
            else
                return false
            end
        elseif type == "cash" then
            if xPlayer.getMoney() >= amount then
                xPlayer.removeMoney(amount)
                return true
            else
                return false
            end
        else
            return false
        end
    else
        return false
    end
end


function G9Series:addMoney(src, type, amount)
    local player = G9Series:getPlayer(src)
    if framework then
        player.Functions.AddMoney(type, amount)
    else
        if type == 'cash' then
            type = 'money'
        end
        player.addAccountMoney(type, amount)
    end
end