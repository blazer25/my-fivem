-- Job Center
-- Tech Development - https://discord.gg/tHAbhd94vS

if Config.Framework == 'esx' then 
    ESX = exports.es_extended:getSharedObject()
elseif Config.Framework == 'qbcore' then
    QBCore = exports['qb-core']:GetCoreObject()
end

local function getJobConfig(jobId)
    if not jobId then return nil end

    for _, job in ipairs(Config.Jobs) do
        if job.id == jobId then
            return job
        end
    end

    return nil
end

local function notifyPlayer(message, msgType)
    if Config.Framework == 'qbcore' and QBCore and QBCore.Functions and QBCore.Functions.Notify then
        QBCore.Functions.Notify(message, msgType or 'success')
        return
    end

    SetNotificationTextEntry('STRING')
    AddTextComponentSubstringPlayerName(message)
    DrawNotification(false, true)
end

local function setJobWaypoint(jobData)
    if not jobData or not jobData.gps then return end

    local gps = jobData.gps
    if not gps.x or not gps.y then return end

    SetNewWaypoint(gps.x + 0.0, gps.y + 0.0)
    notifyPlayer(("GPS set for %s."):format(jobData.label or 'job'), 'success')
end


Callback = function(name, ...)
    if Config.Framework == 'esx' and ESX and ESX.TriggerServerCallback then 
        ESX.TriggerServerCallback(name, ...)
    elseif Config.Framework == 'qbcore' and QBCore and QBCore.Functions and QBCore.Functions.TriggerCallback then
        QBCore.Functions.TriggerCallback(name, ...)
    end
end

if Config.Framework == 'esx' then 
    RegisterNetEvent('esx:setJob')
    AddEventHandler('esx:setJob', function(job)
        SendNUIMessage({
            type = "UPDATE_CURRENTJOB",
            myJob = job.name
        })
    end)
elseif Config.Framework == 'qbcore' then
    RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
        SendNUIMessage({
            type = "UPDATE_CURRENTJOB",
            myJob = val.job.name
        })
    end)
end


RegisterNUICallback('changeJob', function(data, cb)
    local jobId = data and data.job or nil

    if jobId then
        TriggerServerEvent('ricky-jobcenter:updateJob', jobId)
        setJobWaypoint(getJobConfig(jobId))
    end

    if cb then
        cb('ok')
    end
end)

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    if cb then
        cb('ok')
    end
end)


OpenJobCenter = function()
    Callback('ricky-jobcenter:getData', function(myJob, name, avatar)
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = 'SET_CONFIG',
            config = Config
        })
        SendNUIMessage({
            type = 'OPEN',
            jobs = Config.Jobs,
            myJob = myJob,
            name = name,
            avatar = avatar
        })
    end)
end

local sleep = 1000
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(sleep)
        local playerCoords = GetEntityCoords(PlayerPedId())

        for _, location in pairs(Config.Coords) do
            DrawMarker(
                1,
                location.x, location.y, location.z,
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                1.0, 1.0, 0.5,
                255, 255, 255, 100,
                false, false, 2, false,
                nil, nil, false
            )

            local distance = #(playerCoords - location)

            if distance < 5.5 then
                sleep = 1
                ShowHelpNotification(Config.Lang[Config.Language]["open_menu"])

                if IsControlJustReleased(0, 38) then
                    OpenJobCenter()
                end
            else
                sleep = 1000
            end
        end
    end
end)
