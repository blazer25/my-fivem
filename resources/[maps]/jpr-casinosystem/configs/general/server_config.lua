function RemoveItem(Player, itemName, quantity)
    if not Player then
        print('^1[JPR Casino] ERROR: RemoveItem called with nil Player^0')
        return false
    end
    if not Player.Functions then
        print('^1[JPR Casino] ERROR: Player.Functions is nil for RemoveItem^0')
        return false
    end
    if not Player.Functions.RemoveItem then
        print('^1[JPR Casino] ERROR: Player.Functions.RemoveItem is nil^0')
        return false
    end
    local success = Player.Functions.RemoveItem(itemName, quantity)
    if success then
        print('^2[JPR Casino] Removed item: ' .. tostring(itemName) .. ' x' .. tostring(quantity) .. ' from player ' .. tostring(Player.PlayerData.source) .. '^0')
    else
        print('^3[JPR Casino] Failed to remove item: ' .. tostring(itemName) .. ' x' .. tostring(quantity) .. ' from player ' .. tostring(Player.PlayerData.source) .. '^0')
    end
    return success
end

function AddItem(Player, itemName, quantity)
    if not Player then
        print('^1[JPR Casino] ERROR: AddItem called with nil Player^0')
        return false
    end
    if not Player.Functions then
        print('^1[JPR Casino] ERROR: Player.Functions is nil for AddItem^0')
        return false
    end
    if not Player.Functions.AddItem then
        print('^1[JPR Casino] ERROR: Player.Functions.AddItem is nil^0')
        return false
    end
    local success = Player.Functions.AddItem(itemName, quantity)
    if success then
        print('^2[JPR Casino] Added item: ' .. tostring(itemName) .. ' x' .. tostring(quantity) .. ' to player ' .. tostring(Player.PlayerData.source) .. '^0')
    else
        print('^3[JPR Casino] Failed to add item: ' .. tostring(itemName) .. ' x' .. tostring(quantity) .. ' to player ' .. tostring(Player.PlayerData.source) .. '^0')
    end
    return success
end

function RemoveMoney(Player, moneyType, amount, reason)
    if not Player then
        print('^1[JPR Casino] ERROR: RemoveMoney called with nil Player^0')
        return
    end
    if not Player.Functions then
        print('^1[JPR Casino] ERROR: Player.Functions is nil for RemoveMoney^0')
        return
    end
    if not Player.Functions.RemoveMoney then
        print('^1[JPR Casino] ERROR: Player.Functions.RemoveMoney is nil^0')
        return
    end
    Player.Functions.RemoveMoney(moneyType, amount, reason)
end

function AddMoney(Player, moneyType, amount, reason)
    if not Player then
        print('^1[JPR Casino] ERROR: AddMoney called with nil Player^0')
        return
    end
    if not Player.Functions then
        print('^1[JPR Casino] ERROR: Player.Functions is nil for AddMoney^0')
        return
    end
    if not Player.Functions.AddMoney then
        print('^1[JPR Casino] ERROR: Player.Functions.AddMoney is nil^0')
        return
    end
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
    if not source then
        print('^1[JPR Casino] ERROR: GetPlayer called with nil source^0')
        return nil
    end
    
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
                    _G.QBX = coreObj
                    QBX = coreObj
                    _G.QBCore = coreObj
                    QBCore = coreObj
                    print('^2[JPR Casino] Re-initialized QBX in GetPlayer^0')
                    break
                end
            end
        end
        if not QBX or not QBX.Functions then
            print('^1[JPR Casino] ERROR: QBX.Functions not available after wait (attempts: ' .. attempts .. ')^0')
            return nil
        end
    end
    
    if not QBX.Functions.GetPlayer then
        print('^1[JPR Casino] ERROR: QBX.Functions.GetPlayer is nil^0')
        return nil
    end
    
    local player = QBX.Functions.GetPlayer(source)
    if not player then
        print('^3[JPR Casino] WARNING: GetPlayer returned nil for source ' .. tostring(source) .. '^0')
    end
    return player
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

-- Ensure QBX is initialized on server start
CreateThread(function()
    local maxWait = 100  -- Wait up to 10 seconds (100 * 100ms)
    local attempts = 0
    
    while (not QBX or not QBX.Functions) and attempts < maxWait do
        Wait(100)
        attempts = attempts + 1
        
        -- Try to initialize if we have the export available
        if GetResourceState('qbx_core') == 'started' and (not QBX or not QBX.Functions) then
            local success, coreObj = pcall(function()
                return exports['qbx_core']:GetCoreObject()
            end)
            if success and coreObj and coreObj.Functions then
                _G.QBX = coreObj
                QBX = coreObj
                _G.QBCore = coreObj
                QBCore = coreObj
                print('^2[JPR Casino] QBX initialized in server_config startup thread^0')
                break
            end
        end
    end
    
    if QBX and QBX.Functions then
        print('^2[JPR Casino] Server config ready - QBX.Functions available^0')
    else
        print('^1[JPR Casino] WARNING: QBX.Functions not available after startup wait^0')
    end
end)

RegisterNetEvent('jpr:server:casino:giveVehicle', function(Infos)
    local Player = GetPlayer(source)

    if Player and Infos.entity then
        MySQL.Async.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, fuel, engine, body) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)', 
        {Player.PlayerData.license, Player.PlayerData.citizenid, Infos.vehicle, GetHashKey(Infos.vehicle), json.encode(Infos.props), Infos.plate, Infos.totalFuel, Infos.engineDamage, Infos.bodyDamage})
    end
end)