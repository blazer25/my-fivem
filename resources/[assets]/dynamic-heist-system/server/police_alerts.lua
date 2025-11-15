local Global = _G.DynamicHeist or {}
_G.DynamicHeist = Global
local DynamicHeist = Global
DynamicHeist.Alerts = DynamicHeist.Alerts or {}

local Alerts = DynamicHeist.Alerts

local QBCore, ESX = nil, nil
if Config.Framework == "qb" then
    local ok, obj = pcall(function()
        return exports["qb-core"]:GetCoreObject()
    end)
    if ok then QBCore = obj end
elseif Config.Framework == "esx" then
    local ok, obj = pcall(function()
        return exports["es_extended"]:getSharedObject()
    end)
    if ok then ESX = obj end
end

local function getPoliceTargets()
    local targets = {}
    if QBCore then
        local players = QBCore.Functions.GetQBPlayers and QBCore.Functions.GetQBPlayers() or QBCore.Functions.GetPlayers()
        if type(players) == "table" then
            for _, player in pairs(players) do
                local pdata = player.PlayerData or player
                local job = pdata.job or {}
                if job.name == "police" and job.onduty ~= false then
                    table.insert(targets, pdata.source or pdata.PlayerData and pdata.PlayerData.source)
                end
            end
        end
    elseif ESX and ESX.GetExtendedPlayers then
        local players = ESX.GetExtendedPlayers("job", "police")
        for _, player in ipairs(players) do
            table.insert(targets, player.source)
        end
    else
        for _, playerId in ipairs(GetPlayers()) do
            if IsPlayerAceAllowed(playerId, "heist.police") then
                table.insert(targets, tonumber(playerId))
            end
        end
    end
    return targets
end

local function buildDispatchMessage(payload)
    local pieces = {
        ("ALARM: %s"):format(payload.alarm or "unknown"),
        ("LOCATION: %s"):format(payload.label or "Unknown"),
        ("STAGE: %s"):format(payload.stage or "Unknown"),
        ("TYPE: %s"):format(payload.dispatchType or "general")
    }
    return table.concat(pieces, " | ")
end

function Alerts.Send(payload)
    payload = payload or {}
    local message = buildDispatchMessage(payload)
    print("[DynamicHeist][Dispatch] " .. message)
    local targets = getPoliceTargets()
    for _, playerId in ipairs(targets) do
        if playerId then
            TriggerClientEvent("heist:policeAlert", playerId, payload)
        end
    end
end

AddEventHandler("heist:dispatch", function(heistId, payload)
    payload = payload or {}
    payload.heistId = heistId
    Alerts.Send(payload)
end)

local evidenceLog = {}

function Alerts.RecordEvidence(heistId, source, evidenceItems)
    evidenceLog[heistId] = evidenceLog[heistId] or {}
    table.insert(evidenceLog[heistId], {
        player = source,
        items = evidenceItems,
        timestamp = os.time()
    })
    print(("[DynamicHeist][Evidence] %s -> %s"):format(heistId, table.concat(evidenceItems, ", ")))
end

exports("GetEvidenceLog", function(heistId)
    return evidenceLog[heistId]
end)

DynamicHeist.Alerts = Alerts
