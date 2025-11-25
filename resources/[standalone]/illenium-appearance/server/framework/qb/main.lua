if not Framework.QBCore() then return end

-- Try QBX Core first, then fall back to QB Core
-- Wait for framework to be ready (handles timing issues during resource startup)
local QBCore
local usingQBX = false
local maxWaitTime = 10000 -- 10 seconds max wait
local waitTime = 0
local waitInterval = 100 -- Check every 100ms

-- Wait for qbx_core to be ready
while waitTime < maxWaitTime do
    local qbxState = GetResourceState('qbx_core')
    if qbxState == 'started' then
        -- Use QBX Core
        QBCore = exports.qbx_core
        usingQBX = true
        print("^2[illenium-appearance] Using QBX Core on server^7")
        break
    elseif qbxState == 'starting' or qbxState == 'stopped' then
        -- Still starting or stopped (will start soon), wait a bit
        Wait(waitInterval)
        waitTime = waitTime + waitInterval
    elseif qbxState == 'missing' then
        -- Resource doesn't exist, check for qb-core instead
        break
    else
        -- Unknown state, wait and retry
        Wait(waitInterval)
        waitTime = waitTime + waitInterval
    end
end

-- If qbx_core not found, try qb-core
if not QBCore then
    waitTime = 0
    while waitTime < maxWaitTime do
        local qbState = GetResourceState('qb-core')
        if qbState == 'started' then
            -- Use QB Core
            QBCore = exports["qb-core"]:GetCoreObject()
            print("^2[illenium-appearance] Using QB Core on server^7")
            break
        elseif qbState == 'starting' or qbState == 'stopped' then
            -- Still starting or stopped (will start soon), wait a bit
            Wait(waitInterval)
            waitTime = waitTime + waitInterval
        elseif qbState == 'missing' then
            -- Resource doesn't exist
            break
        else
            -- Unknown state, wait and retry
            Wait(waitInterval)
            waitTime = waitTime + waitInterval
        end
    end
end

-- Final check
if not QBCore then
    -- No compatible framework found
    print("^1[illenium-appearance] No compatible QB framework found on server! (qbx_core state: " .. tostring(GetResourceState('qbx_core')) .. ", qb-core state: " .. tostring(GetResourceState('qb-core')) .. ")^7")
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
