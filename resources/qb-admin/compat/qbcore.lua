-- ✅ Qbox Compatibility Bridge for Legacy QB Scripts
-- Makes qb-admin and other old scripts work with qbx_core

local QBX = exports.qbx_core

QBCore = {}
QBCore.Functions = {}

-- Player wrappers
QBCore.Functions.GetPlayer = function(src)
    return QBX:GetPlayer(src)
end

QBCore.Functions.GetPlayers = function()
    return QBX:GetPlayers()
end

-- Permissions
QBCore.Functions.HasPermission = function(src, perm)
    return QBX:HasPermission(src, perm)
end

-- Callbacks
QBCore.Functions.CreateCallback = function(name, cb)
    return QBX:RegisterCallback(name, cb)
end

QBCore.Functions.TriggerCallback = function(name, src, cb, ...)
    return QBX:TriggerCallback(name, src, cb, ...)
end

-- Jobs/Gangs (compat helpers)
QBCore.Functions.GetPlayerByCitizenId = function(cid)
    return QBX:GetPlayerByCitizenId(cid)
end

QBCore.Functions.GetPlayerByLicense = function(license)
    return QBX:GetPlayerByLicense(license)
end

-- Money
QBCore.Functions.AddMoney = function(src, account, amount, reason)
    local player = QBX:GetPlayer(src)
    if player then
        player.Functions.AddMoney(account, amount, reason)
    end
end

QBCore.Functions.RemoveMoney = function(src, account, amount, reason)
    local player = QBX:GetPlayer(src)
    if player then
        player.Functions.RemoveMoney(account, amount, reason)
    end
end

Compat = {}
print("^2[Bridge]^7 Qbox compatibility bridge for qb-admin loaded successfully.^0")
