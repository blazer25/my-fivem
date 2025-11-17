local QBCore = nil
local isQBox = false

-- Try QBox first (qbx_core), then fallback to qb-core
if GetResourceState('qbx_core') == 'started' then
    local qbx = exports.qbx_core
    isQBox = true
    
    -- Create a QBCore-compatible wrapper for QBox
    QBCore = {
        Functions = {
            GetPlayer = function(source)
                return qbx:GetPlayer(source)
            end,
        },
        Shared = {
            Items = {} -- Will be populated if needed
        }
    }
    
    print('^2[pl-atmrob]^7 Using QBox framework (qbx_core)')
elseif GetResourceState('qb-core'):find('start') then
    QBCore = exports['qb-core']:GetCoreObject()
    print('^2[pl-atmrob]^7 Using QBCore framework')
end

if not QBCore then 
    print('^1[pl-atmrob] ERROR: Neither qbx_core nor qb-core is available!^7')
    return 
end

function getPlayer(target)
    if isQBox then
        return exports.qbx_core:GetPlayer(target)
    else
        return QBCore.Functions.GetPlayer(target)
    end
end

function getPlayers()
    if isQBox then
        -- QBox: Use native GetPlayers() which returns player IDs as strings, convert to numbers
        local players = {}
        for _, playerId in ipairs(GetPlayers()) do
            table.insert(players, tonumber(playerId))
        end
        return players
    else
        return QBCore.Functions.GetPlayers()
    end
end

function getPlayerName(target)
    local xPlayer = getPlayer(target)
    if not xPlayer then return "Unknown" end

    if xPlayer.PlayerData and xPlayer.PlayerData.charinfo then
        return xPlayer.PlayerData.charinfo.firstname .. " " .. xPlayer.PlayerData.charinfo.lastname
    elseif xPlayer.PlayerData and xPlayer.PlayerData.name then
        return xPlayer.PlayerData.name
    end
    
    return "Unknown"
end

function getPlayerIdentifier(target)
    local xPlayer = getPlayer(target)
    if not xPlayer then return nil end

    if xPlayer.PlayerData then
        return xPlayer.PlayerData.citizenid or xPlayer.PlayerData.license
    end
    
    return nil
end

function GetJob(target)
    local xPlayer = getPlayer(target)
    if not xPlayer then return nil end
    
    if xPlayer.PlayerData and xPlayer.PlayerData.job then
        return xPlayer.PlayerData.job.name
    end
    
    return nil
end

function AddPlayerMoney(Player, account, TotalBill)
    if not Player or not Player.PlayerData then return end
    
    local source = Player.PlayerData.source
    
    if account == 'bank' then
        if isQBox then
            exports.qbx_core:AddMoney(source, 'bank', TotalBill)
        else
            Player.Functions.AddMoney('bank', TotalBill)
        end
    elseif account == 'cash' then
        if isQBox then
            exports.qbx_core:AddMoney(source, 'cash', TotalBill)
        else
            Player.Functions.AddMoney('cash', TotalBill)
        end
    elseif account == 'dirty' then
        if GetResourceState("ox_inventory") == "started" then
            exports.ox_inventory:AddItem(source, 'markedbills', 1, {worth = TotalBill})
        elseif lib.checkDependency('qb-inventory', '2.0.0') then
            local info = {worth = TotalBill}
            exports['qb-inventory']:AddItem(source, 'markedbills', 1, false, info)
            if QBCore.Shared and QBCore.Shared.Items and QBCore.Shared.Items['markedbills'] then
                TriggerClientEvent('qb-inventory:client:ItemBox', source, QBCore.Shared.Items['markedbills'], "add", info)
            end
        else
            if isQBox then
                exports.qbx_core:AddItem(source, 'markedbills', 1, {worth = TotalBill})
            else
                local info = {worth = TotalBill}
                Player.Functions.AddItem('markedbills', 1, false, info)
                if QBCore.Shared and QBCore.Shared.Items and QBCore.Shared.Items['markedbills'] then
                    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['markedbills'], "add", info)
                end
            end
        end
    end
end
