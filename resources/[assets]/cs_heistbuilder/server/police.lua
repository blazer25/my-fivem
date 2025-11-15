local Police = {}
local Utils = CS_HEIST_SHARED_UTILS or {}

local function eachOnDutyPolice(cb)
    for _, id in ipairs(GetPlayers()) do
        local src = tonumber(id)
        local qbPlayer = exports['qbx_core'] and exports['qbx_core']:GetPlayer(src)
        if qbPlayer and qbPlayer.PlayerData and qbPlayer.PlayerData.job then
            if qbPlayer.PlayerData.job.name == 'police' and qbPlayer.PlayerData.job.onduty then
                cb(src)
            end
        elseif IsPlayerAceAllowed(src, 'job.police') then
            cb(src)
        end
    end
end

function Police.count()
    local count = 0
    eachOnDutyPolice(function()
        count = count + 1
    end)
    return count
end

function Police.sendDispatch(data)
    data = data or {}
    eachOnDutyPolice(function(src)
        TriggerClientEvent('cs_heistbuilder:client:dispatch', src, data)
    end)
end

function Police.broadcastLastKnown(coords)
    eachOnDutyPolice(function(src)
        TriggerClientEvent('cs_heistbuilder:client:lastKnown', src, coords, Config.Dispatch.lastKnownBlipTime)
    end)
end

function Police.logEvidence(evidenceType, coords)
    Police.sendDispatch({
        coords = coords,
        title = 'Evidence Alert',
        message = ('%s detected'):format(evidenceType or 'Unknown'),
        sprite = 161,
        colour = 5,
        duration = 20,
        evidence = evidenceType
    })
end

CS_HEIST_POLICE = Police

return Police
