if Config.qbSettings.enabled then
    QBCore = nil
    
    -- Try QBox first (qbx_core), then fallback to qb-core
    if GetResourceState('qbx_core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
    elseif GetResourceState('qb-core') == 'started' then
        if Config.qbSettings.useNewQBExport then
            QBCore = exports['qb-core']:GetCoreObject()
        end
    end
    
    if not QBCore then
        print('^1[KQ_LOOTAREAS] ERROR: Neither qbx_core nor qb-core is available!^7')
        return
    end
    
    function DoesPlayerHaveItem(player, item, amount)
        local xPlayer = QBCore.Functions.GetPlayer(player)
        if not xPlayer then return false end
        
        if QBCore.Shared and QBCore.Shared.Items then
            TriggerClientEvent('inventory:client:ItemBox', player, QBCore.Shared.Items[item], 'remove', amount or 1)
        end

        local playerItem = xPlayer.Functions.GetItemByName(item)
        return playerItem and ((playerItem.amount or playerItem.count) >= (amount or 1))
    end

    function RemovePlayerItem(player, item, amount)
        local xPlayer = QBCore.Functions.GetPlayer(tonumber(player))
        if not xPlayer then return end
        xPlayer.Functions.RemoveItem(item, amount or 1)
    end

    function AddPlayerItem(player, item, amount)
        local xPlayer = QBCore.Functions.GetPlayer(tonumber(player))
        if not xPlayer then return false end
        
        if QBCore.Shared and QBCore.Shared.Items then
            TriggerClientEvent('inventory:client:ItemBox', player, QBCore.Shared.Items[item], 'add', amount or 1)
        end

        return xPlayer.Functions.AddItem(item, amount or 1)
    end
end
