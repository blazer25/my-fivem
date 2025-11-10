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
    if not QBX or not QBX.Functions then
        print('^1[JPR Casino] ERROR: QBX.Functions not available yet^0')
        return nil
    end
    return QBX.Functions.CreateCallback(...)
end

function NotifyServer(player, message, notifyType)
    if not player or not player.PlayerData then
        return
    end
    TriggerClientEvent('QBX:Notify', player.PlayerData.source, message, notifyType)
end

function GetPlayer(source)
    if not QBX or not QBX.Functions then
        -- Wait a bit and retry if QBX isn't ready
        local attempts = 0
        local maxAttempts = 50  -- Wait up to 5 seconds (50 * 100ms)
        while (not QBX or not QBX.Functions) and attempts < maxAttempts do
            Wait(100)
            attempts = attempts + 1
            -- Try to re-initialize if we have the export available
            if GetResourceState('qbx_core') == 'started' and not QBX.Functions then
                local success, coreObj = pcall(function()
                    return exports['qbx_core']:GetCoreObject()
                end)
                if success and coreObj and coreObj.Functions then
                    QBX = coreObj
                    _G.QBCore = coreObj
                    QBCore = coreObj
                    break
                end
            end
        end
        if not QBX or not QBX.Functions then
            print('^1[JPR Casino] ERROR: QBX.Functions not available after wait (attempts: ' .. attempts .. ')^0')
            return nil
        end
    end
    return QBX.Functions.GetPlayer(source)
end

function CheckMoney(source, amount)
    local xPlayer = GetPlayer(source)
    
    if not xPlayer or not xPlayer.PlayerData then
        return false
    end
    
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