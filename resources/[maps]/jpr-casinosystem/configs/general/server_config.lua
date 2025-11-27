local function fetchCore(name)
    local resourceState = GetResourceState(name)
    if resourceState ~= 'started' and resourceState ~= 'starting' then return nil end

    local ok, core = pcall(function()
        return exports[name]:GetCoreObject()
    end)

    if ok then return core end
    return nil
end

-- Retry mechanism to wait for core to be ready
local QBCore = nil
local attempts = 0
local maxAttempts = 50 -- Wait up to 5 seconds (50 * 100ms)

while not QBCore and attempts < maxAttempts do
    QBCore = fetchCore(Config.CoreName) or fetchCore('qb-core')
    if not QBCore then
        Wait(100)
        attempts = attempts + 1
    end
end

if not QBCore or not QBCore.Functions then
    error('[JPR Casino] Unable to fetch core object in server_config. Ensure qbx_core or qb-core is running.')
end

local ox_inventory = exports.ox_inventory

local function Notify(source, message, notifyType)
    TriggerClientEvent('QBCore:Notify', source, message, notifyType or 'error')
end

local function GetPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

function RemoveMoney(Player, account, amount, reason)
    Player.Functions.RemoveMoney(account, amount, reason or 'Casino transaction')
end

function AddMoney(Player, account, amount, reason)
    Player.Functions.AddMoney(account, amount, reason or 'Casino transaction')
end

function RemoveItem(Player, item, amount)
    if not Player or not Player.PlayerData then return false end
    return ox_inventory:RemoveItem(Player.PlayerData.source, item, amount)
end

function AddItem(Player, item, amount)
    if not Player or not Player.PlayerData then return false end
    return ox_inventory:AddItem(Player.PlayerData.source, item, amount)
end

function CheckMoney(source, amount)
    local Player = GetPlayer(source)
    if not Player then return false end

    if Player.PlayerData.money.cash >= amount then
        RemoveMoney(Player, 'cash', amount, 'Casino purchase')
        return true, 'cash'
    elseif Player.PlayerData.money.bank >= amount then
        RemoveMoney(Player, 'bank', amount, 'Casino purchase')
        return true, 'bank'
    else
        return false
    end
end

function NotifyServer(Player, message, notifyType)
    if Player and Player.PlayerData then
        Notify(Player.PlayerData.source, message, notifyType)
    end
end

RegisterNetEvent('jpr:server:casino:giveVehicle', function(data)
    local Player = GetPlayer(source)
    if not Player or not data or not data.entity then return end

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