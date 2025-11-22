if not Framework.QBCore() then return end

-- Try to use QBX Bridge first, then fall back to qb-core
local QBCore = nil
local usingBridge = false

-- Check for bridge immediately (it should be ready since it loads before this)
if GetResourceState('illenium-qbx-bridge') == 'started' then
    -- Try to access bridge exports
    local success, bridgeIsReady = pcall(function()
        return exports['illenium-qbx-bridge']:IsReady()
    end)
    
    if success and bridgeIsReady then
        local success2, qbxCore = pcall(function()
            return exports['illenium-qbx-bridge']:GetQBXCore()
        end)
        
        if success2 and qbxCore then
            -- Create QB Core compatible object using bridge
            QBCore = {
                Functions = {
                    GetPlayer = function(src)
                        local success3, player = pcall(function()
                            return exports['illenium-qbx-bridge']:GetPlayer(src)
                        end)
                        return success3 and player or nil
                    end
                },
                Shared = qbxCore.Shared or {}
            }
            usingBridge = true
            print("^2[illenium-appearance] Using QBX Bridge for QBX Core compatibility^7")
        end
    end
end

-- Fallback to regular qb-core if bridge not available
if not QBCore then
    if GetResourceState('qb-core') == 'started' then
        QBCore = exports["qb-core"]:GetCoreObject()
        print("^2[illenium-appearance] Using standard qb-core^7")
    else
        print("^1[illenium-appearance] No compatible framework found!^7")
        return
    end
end

function Framework.GetPlayerID(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        return Player.PlayerData.citizenid
    end
end

function Framework.HasMoney(src, type, money)
    local Player = QBCore.Functions.GetPlayer(src)
    return Player.PlayerData.money[type] >= money
end

function Framework.RemoveMoney(src, type, money)
    local Player = QBCore.Functions.GetPlayer(src)
    return Player.Functions.RemoveMoney(type, money)
end

function Framework.GetJob(src)
    local Player = QBCore.Functions.GetPlayer(src)
    return Player.PlayerData.job
end

function Framework.GetGang(src)
    local Player = QBCore.Functions.GetPlayer(src)
    return Player.PlayerData.gang
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
