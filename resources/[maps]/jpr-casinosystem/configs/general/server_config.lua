local QBCore = require 'configs.general.get_core_export'
local ox_inventory = exports.ox_inventory

local M = {}

local function Notify(source, message, notifyType)
    TriggerClientEvent('QBCore:Notify', source, message, notifyType or 'error')
end

local function GetPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

function M.RemoveMoney(Player, account, amount, reason)
    Player.Functions.RemoveMoney(account, amount, reason or 'Casino transaction')
end

function M.AddMoney(Player, account, amount, reason)
    Player.Functions.AddMoney(account, amount, reason or 'Casino transaction')
end

function M.RemoveItem(Player, item, amount)
    local src = Player.PlayerData.source
    return ox_inventory:RemoveItem(src, item, amount)
end

function M.AddItem(Player, item, amount)
    local src = Player.PlayerData.source
    return ox_inventory:AddItem(src, item, amount)
end

function M.CheckMoney(source, amount)
    local Player = GetPlayer(source)

    if Player.PlayerData.money.cash >= amount then
        M.RemoveMoney(Player, 'cash', amount, 'Casino purchase')
        return true, 'cash'
    elseif Player.PlayerData.money.bank >= amount then
        M.RemoveMoney(Player, 'bank', amount, 'Casino purchase')
        return true, 'bank'
    else
        return false
    end
end

function M.NotifyServer(Player, message, notifyType)
    Notify(Player.PlayerData.source, message, notifyType)
end

RegisterNetEvent('jpr:server:casino:giveVehicle', function(data)
    local Player = GetPlayer(source)
    if not Player or not data.entity then return end

    MySQL.insert(
        'INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, fuel, engine, body) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        {
            Player.PlayerData.license,
            Player.PlayerData.citizenid,
            data.vehicle,
            GetHashKey(data.vehicle),
            json.encode(data.props),
            data.plate,
            data.totalFuel,
            data.engineDamage,
            data.bodyDamage
        }
    )
end)

return M