if not Framework.QBCore() then return end

local client = client

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
    print("^1[illenium-appearance] No compatible QB framework found!^7")
    return
end

local PlayerData = {}
if GetResourceState('qbx_core') == 'started' then
    PlayerData = QBCore.Functions.GetPlayerData() or {}
elseif QBCore and QBCore.Functions then
    PlayerData = QBCore.Functions.GetPlayerData() or {}
end

local function getRankInputValues(rankList)
    local rankValues = {}
    for k, v in pairs(rankList) do
        rankValues[#rankValues + 1] = {
            label = v.name,
            value = k
        }
    end
    return rankValues
end

local function setClientParams()
    client.job = PlayerData.job
    client.gang = PlayerData.gang
    client.citizenid = PlayerData.citizenid
end

function Framework.GetPlayerGender()
    if PlayerData.charinfo.gender == 1 then
        return "Female"
    end
    return "Male"
end

function Framework.UpdatePlayerData()
    if GetResourceState('qbx_core') == 'started' then
        PlayerData = QBCore.Functions.GetPlayerData() or {}
    elseif QBCore and QBCore.Functions then
        PlayerData = QBCore.Functions.GetPlayerData() or {}
    end
    setClientParams()
end

function Framework.HasTracker()
    if GetResourceState('qbx_core') == 'started' then
        -- QBX Core method
        local playerData = QBCore.Functions.GetPlayerData()
        if playerData and playerData.metadata then
            return playerData.metadata["tracker"] or false
        end
        return false
    else
        -- QB Core method
        return QBCore.Functions.GetPlayerData().metadata["tracker"] or false
    end
end

function Framework.CheckPlayerMeta()
    return PlayerData.metadata["isdead"] or PlayerData.metadata["inlaststand"] or PlayerData.metadata["ishandcuffed"]
end

function Framework.IsPlayerAllowed(citizenid)
    return citizenid == PlayerData.citizenid
end

function Framework.GetRankInputValues(type)
    local grades = QBCore.Shared.Jobs[client.job.name].grades
    if type == "gang" then
        grades = QBCore.Shared.Gangs[client.gang.name].grades
    end
    return getRankInputValues(grades)
end

function Framework.GetJobGrade()
    return client.job.grade.level
end

function Framework.GetGangGrade()
    return client.gang.grade.level
end

RegisterNetEvent("QBCore:Client:OnJobUpdate", function(JobInfo)
    PlayerData.job = JobInfo
    client.job = JobInfo
    ResetBlips()
end)

RegisterNetEvent("QBCore:Client:OnGangUpdate", function(GangInfo)
    PlayerData.gang = GangInfo
    client.gang = GangInfo
    ResetBlips()
end)

RegisterNetEvent("QBCore:Client:SetDuty", function(duty)
    if PlayerData and PlayerData.job then
        PlayerData.job.onduty = duty
        client.job = PlayerData.job
    end
end)

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
    InitAppearance()
end)

RegisterNetEvent("qb-clothes:client:CreateFirstCharacter", function()
    QBCore.Functions.GetPlayerData(function(pd)
        PlayerData = pd
        setClientParams()
        InitializeCharacter(Framework.GetGender(true), function()
            -- Appearance completed callback
            TriggerEvent('qbx_core:client:appearanceCompleted')
        end, function()
            -- Appearance cancelled callback
            TriggerEvent('qbx_core:client:appearanceCancelled')
        end)
    end)
end)

function Framework.CachePed()
    return nil
end

function Framework.RestorePlayerArmour()
    Framework.UpdatePlayerData()
    if PlayerData and PlayerData.metadata then
        Wait(1000)
        SetPedArmour(cache.ped, PlayerData.metadata["armor"])
    end
end
