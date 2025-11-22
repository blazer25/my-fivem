if not Framework.QBCore() then return end

-- Try QBX Core first, then fall back to QB Core
local QBCore
if GetResourceState('qbx_core') == 'started' then
    -- Use QBX Core
    QBCore = exports.qbx_core
elseif GetResourceState('qb-core') == 'started' then
    -- Use QB Core
    QBCore = exports["qb-core"]:GetCoreObject()
else
    -- No compatible framework found
    print("^1[illenium-appearance] No compatible QB framework found on server!^7")
    return
end

function Framework.GetPlayerID(src)
    if not QBCore or not QBCore.Functions then return nil end
    
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        return Player.PlayerData.citizenid
    end
end

function Framework.HasMoney(src, type, money)
    if not QBCore or not QBCore.Functions then return false end
    
    local Player = QBCore.Functions.GetPlayer(src)
    if Player and Player.PlayerData and Player.PlayerData.money then
        return Player.PlayerData.money[type] >= money
    end
    return false
end

function Framework.RemoveMoney(src, type, money)
    if not QBCore or not QBCore.Functions then return false end
    
    local Player = QBCore.Functions.GetPlayer(src)
    if Player and Player.Functions then
        return Player.Functions.RemoveMoney(type, money)
    end
    return false
end

function Framework.GetJob(src)
    if not QBCore or not QBCore.Functions then return nil end
    
    local Player = QBCore.Functions.GetPlayer(src)
    if Player and Player.PlayerData then
        return Player.PlayerData.job
    end
    return nil
end

function Framework.GetGang(src)
    if not QBCore or not QBCore.Functions then return nil end
    
    local Player = QBCore.Functions.GetPlayer(src)
    if Player and Player.PlayerData then
        return Player.PlayerData.gang
    end
    return nil
end

function Framework.SaveAppearance(appearance, citizenID)
    Database.PlayerSkins.UpdateActiveField(citizenID, 0)
    Database.PlayerSkins.DeleteByModel(citizenID, appearance.model)
    Database.PlayerSkins.Add(citizenID, appearance.model, json.encode(appearance), 1)
end

function Framework.GetAppearance(citizenID, model)
    local result = Database.PlayerSkins.GetByCitizenID(citizenID, model)
    if result then
        return json.decode(result)
    end
end
