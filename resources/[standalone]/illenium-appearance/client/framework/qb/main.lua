if not Framework.QBCore() then return end

local client = client

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
        -- Use QBX Core - use bridge compatibility for Functions access
        usingQBX = true
        -- Get bridge compatibility object for Functions access
        -- Wait a bit for bridge to initialize
        local bridgeReady = false
        local bridgeWaitTime = 0
        while bridgeWaitTime < 2000 and not bridgeReady do
            local success, result = pcall(function() return exports["qb-core"]:GetCoreObject() end)
            if success and result and result.Functions then
                QBCore = result
                bridgeReady = true
            else
                Wait(100)
                bridgeWaitTime = bridgeWaitTime + 100
            end
        end
        if not QBCore then
            print("^3[illenium-appearance] Warning: QBX bridge not available, some features may not work^7")
        end
        print("^2[illenium-appearance] Using QBX Core on client^7")
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
            print("^2[illenium-appearance] Using QB Core on client^7")
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
    print("^1[illenium-appearance] No compatible QB framework found on client! (qbx_core state: " .. tostring(GetResourceState('qbx_core')) .. ", qb-core state: " .. tostring(GetResourceState('qb-core')) .. ")^7")
    return
end

local PlayerData = {}
if usingQBX then
    -- QBX Core method - use bridge compatibility Functions
    if QBCore and QBCore.Functions then
        PlayerData = QBCore.Functions.GetPlayerData() or {}
    else
        -- Fallback: try direct QBX.PlayerData access
        PlayerData = QBX and QBX.PlayerData or {}
    end
elseif QBCore and QBCore.Functions then
    -- QB Core method
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
    if usingQBX then
        -- QBX Core method - use bridge compatibility Functions
        if QBCore and QBCore.Functions then
            PlayerData = QBCore.Functions.GetPlayerData() or {}
        else
            -- Fallback: try direct QBX.PlayerData access
            PlayerData = QBX and QBX.PlayerData or {}
        end
    elseif QBCore and QBCore.Functions then
        -- QB Core method
        PlayerData = QBCore.Functions.GetPlayerData() or {}
    end
    setClientParams()
end

function Framework.HasTracker()
    if usingQBX then
        -- QBX Core method - use bridge compatibility Functions
        local playerData
        if QBCore and QBCore.Functions then
            playerData = QBCore.Functions.GetPlayerData()
        else
            -- Fallback: try direct QBX.PlayerData access
            playerData = QBX and QBX.PlayerData or nil
        end
        if playerData and playerData.metadata then
            return playerData.metadata["tracker"] or false
        end
        return false
    elseif QBCore and QBCore.Functions then
        -- QB Core method
        local playerData = QBCore.Functions.GetPlayerData()
        if playerData and playerData.metadata then
            return playerData.metadata["tracker"] or false
        end
        return false
    end
    return false
end

function Framework.CheckPlayerMeta()
    return PlayerData.metadata["isdead"] or PlayerData.metadata["inlaststand"] or PlayerData.metadata["ishandcuffed"]
end

function Framework.IsPlayerAllowed(citizenid)
    return citizenid == PlayerData.citizenid
end

function Framework.GetRankInputValues(type)
    local grades
    if usingQBX then
        -- QBX Core - use bridge compatibility for Shared data
        local qbCoreCompat = exports["qb-core"]:GetCoreObject()
        if type == "gang" then
            grades = qbCoreCompat.Shared.Gangs[client.gang.name].grades
        else
            grades = qbCoreCompat.Shared.Jobs[client.job.name].grades
        end
    elseif QBCore and QBCore.Shared then
        -- QB Core method
        if type == "gang" then
            grades = QBCore.Shared.Gangs[client.gang.name].grades
        else
            grades = QBCore.Shared.Jobs[client.job.name].grades
        end
    end
    if not grades then
        return {}
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
    if usingQBX then
        -- QBX Core method - use bridge compatibility Functions
        if QBCore and QBCore.Functions then
            PlayerData = QBCore.Functions.GetPlayerData() or {}
        else
            -- Fallback: try direct QBX.PlayerData access
            PlayerData = QBX and QBX.PlayerData or {}
        end
        setClientParams()
        InitializeCharacter(Framework.GetGender(true), function()
            -- Appearance completed callback
            TriggerEvent('qbx_core:client:appearanceCompleted')
        end, function()
            -- Appearance cancelled callback
            TriggerEvent('qbx_core:client:appearanceCancelled')
        end)
    elseif QBCore and QBCore.Functions then
        -- QB Core method - uses callback
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
    end
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
