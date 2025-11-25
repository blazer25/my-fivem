if not Framework.QBCore() then return end

-- Try QBX Core first, then fall back to QB Core
local QBCore
local usingQBX = false
if GetResourceState('qbx_core') == 'started' then
    -- Use QBX Core
    QBCore = exports.qbx_core
    usingQBX = true
    print("^2[illenium-appearance] Using QBX Core on server^7")
elseif GetResourceState('qb-core') == 'started' then
    -- Use QB Core
    QBCore = exports["qb-core"]:GetCoreObject()
    print("^2[illenium-appearance] Using QB Core on server^7")
else
    -- No compatible framework found
    print("^1[illenium-appearance] No compatible QB framework found on server!^7")
    return
end

-- Verify QBCore is properly loaded
-- qbx_core doesn't have QBCore.Functions, so only check for it when using qb-core
if not QBCore then
    print("^1[illenium-appearance] QBCore not available on server!^7")
    return
end
if not usingQBX and not QBCore.Functions then
    print("^1[illenium-appearance] QBCore functions not available on server!^7")
    return
end

function Framework.GetPlayerID(src)
    if GetResourceState('qbx_core') == 'started' then
        -- QBX Core method
        local Player = exports.qbx_core:GetPlayer(src)
        if Player then
            return Player.PlayerData.citizenid
        end
    elseif QBCore and QBCore.Functions then
        -- QB Core method
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            return Player.PlayerData.citizenid
        end
    end
    return nil
end

function Framework.HasMoney(src, type, money)
    if GetResourceState('qbx_core') == 'started' then
        -- QBX Core method
        local Player = exports.qbx_core:GetPlayer(src)
        if Player and Player.PlayerData and Player.PlayerData.money then
            return Player.PlayerData.money[type] >= money
        end
    elseif QBCore and QBCore.Functions then
        -- QB Core method
        local Player = QBCore.Functions.GetPlayer(src)
        if Player and Player.PlayerData and Player.PlayerData.money then
            return Player.PlayerData.money[type] >= money
        end
    end
    return false
end

function Framework.RemoveMoney(src, type, money)
    if GetResourceState('qbx_core') == 'started' then
        -- QBX Core method
        local Player = exports.qbx_core:GetPlayer(src)
        if Player and Player.Functions then
            return Player.Functions.RemoveMoney(type, money)
        end
    elseif QBCore and QBCore.Functions then
        -- QB Core method
        local Player = QBCore.Functions.GetPlayer(src)
        if Player and Player.Functions then
            return Player.Functions.RemoveMoney(type, money)
        end
    end
    return false
end

function Framework.GetJob(src)
    if GetResourceState('qbx_core') == 'started' then
        -- QBX Core method
        local Player = exports.qbx_core:GetPlayer(src)
        if Player and Player.PlayerData then
            return Player.PlayerData.job
        end
    elseif QBCore and QBCore.Functions then
        -- QB Core method
        local Player = QBCore.Functions.GetPlayer(src)
        if Player and Player.PlayerData then
            return Player.PlayerData.job
        end
    end
    return nil
end

function Framework.GetGang(src)
    if GetResourceState('qbx_core') == 'started' then
        -- QBX Core method
        local Player = exports.qbx_core:GetPlayer(src)
        if Player and Player.PlayerData then
            return Player.PlayerData.gang
        end
    elseif QBCore and QBCore.Functions then
        -- QB Core method
        local Player = QBCore.Functions.GetPlayer(src)
        if Player and Player.PlayerData then
            return Player.PlayerData.gang
        end
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
