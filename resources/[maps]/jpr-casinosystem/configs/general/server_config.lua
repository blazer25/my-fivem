function RemoveItem(Player, itemName, quantity)
    return Player.Functions.RemoveItem(itemName, quantity)
end

function AddItem(Player, itemName, quantity)
    return Player.Functions.AddItem(itemName, quantity)
end

function RemoveMoney(Player, moneyType, amount, reason)
    Player.Functions.RemoveMoney(moneyType, amount, reason)
end

function AddMoney(Player, moneyType, amount, reason)
    Player.Functions.AddMoney(moneyType, amount, reason)
end

function CallBackFunction(...)
    return QBX.Functions.CreateCallback(...)
end

function NotifyServer(player, message, notifyType)
    TriggerClientEvent('QBX:Notify', player.PlayerData.source, message, notifyType)
end

function GetPlayer(source)
    return QBX.Functions.GetPlayer(source)
end

function CheckMoney(source, amount)
    local xPlayer = GetPlayer(source)
    
	if xPlayer.PlayerData.money.cash >= amount then
        RemoveMoney(xPlayer, 'cash', amount, "Casino purchase")

		return true, "cash"
    elseif xPlayer.PlayerData.money.bank >= amount then
        RemoveMoney(xPlayer, 'bank', amount, "Casino purchase")

		return true, "bank"
	else
		return false
	end
end

RegisterNetEvent('jpr:server:casino:giveVehicle', function(Infos)
    local Player = GetPlayer(source)

    if Player and Infos.entity then
        MySQL.Async.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, fuel, engine, body) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)', 
        {Player.PlayerData.license, Player.PlayerData.citizenid, Infos.vehicle, GetHashKey(Infos.vehicle), json.encode(Infos.props), Infos.plate, Infos.totalFuel, Infos.engineDamage, Infos.bodyDamage})
    end
end)