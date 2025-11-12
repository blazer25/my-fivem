--[[
    Chris Locks System
    Author: Chris Hepburn
    Description: Advanced player and business lock system for FiveM (Qbox / QB / OX compatible)
    Version: 1.0.0
]]

local Utils = require 'shared.utils'
local _ = Utils._
local notify = Utils.notify

local Locks = {}
local DebugEnabled = Config.Debug or false
local IsPasswordOpen = false
local ActiveLockId = nil

local function requestLocks()
    TriggerServerEvent('chris_locks:server:requestLocks')
end

local function tableValues(t)
    local v = {}
    for key, value in pairs(t) do
        v[key] = value
    end
    return v
end

local function handleLocksUpdate(data)
    Locks = {}
    for lockId, info in pairs(data or {}) do
        local c = info.coords or { x = 0.0, y = 0.0, z = 0.0 }
        info.coords = vec3(c.x, c.y, c.z)
        Locks[lockId] = info
    end
end

local function getNearestLock()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local closest, closestDist
    for lockId, info in pairs(Locks) do
        local dist = #(pos - info.coords)
        if not closestDist or dist < closestDist then
            closest = info
            closestDist = dist
        end
    end
    if closest and closestDist <= (closest.radius or 2.0) then
        return closest, closestDist
    end
    return nil
end

local function closePasswordNUI()
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
    IsPasswordOpen = false
    ActiveLockId = nil
end

local function openPasswordNUI(lock)
    if IsPasswordOpen then return end
    IsPasswordOpen = true
    ActiveLockId = lock.id
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        lockId = lock.id,
        title = _('prompt_password_title'),
        placeholder = _('prompt_password_placeholder'),
        submit = _('prompt_password_submit'),
        cancel = _('prompt_password_cancel')
    })
end

local function attemptUnlock(lock, payload)
    TriggerServerEvent('chris_locks:attemptUnlock', lock.id, payload or {})
end

local function handleInteraction()
    local lock = getNearestLock()
    if not lock then
        clientNotify(_('notify_invalid_lock'), 'error')
        return
    end
    if lock.hidden == false then
        clientNotify(_('notify_locked'), 'inform')
    end
    if not lock.locked then
        clientNotify(_('notify_in_progress'), 'inform')
        return
    end
    if lock.type == 'password' then
        openPasswordNUI(lock)
    else
        attemptUnlock(lock)
    end
end

RegisterNUICallback('submitPassword', function(data, cb)
    cb(1)
    local password = data and data.password
    if not password or password == '' then
        clientNotify(_('password_required'), 'error')
        return
    end
    if not ActiveLockId then return end
    attemptUnlock({ id = ActiveLockId }, { password = password })
    closePasswordNUI()
end)

RegisterNUICallback('cancelPassword', function(_, cb)
    cb(1)
    closePasswordNUI()
end)

RegisterCommand('chrisLocks:interact', function()
    if IsPauseMenuActive() or IsPlayerDead(PlayerId()) then return end
    handleInteraction()
end, false)

RegisterKeyMapping('chrisLocks:interact', 'Interact with hidden locks', 'keyboard', Config.InteractionKey or 'E')

local function clientNotify(message, type)
    if Utils.resourceActive('ox_lib') and lib and lib.notify then
        lib.notify({
            title = 'Locks',
            description = message,
            type = type or 'inform'
        })
    else
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName(message)
        EndTextCommandThefeedPostMessagetext('CHAR_DEFAULT', 'CHAR_DEFAULT', false, 4, 'Locks', '')
        EndTextCommandThefeedPostTicker(false, false)
    end
end

RegisterCommand('lockdebug', function()
    TriggerServerEvent('chris_locks:toggleDebug')
end, false)

RegisterNetEvent('chris_locks:client:setDebug', function(state)
    DebugEnabled = state
    clientNotify(_('command_usage_debug', tostring(DebugEnabled)), 'inform')
end)

RegisterNetEvent('chris_locks:client:setLocks', function(data)
    handleLocksUpdate(data)
end)

CreateThread(function()
    requestLocks()
    while true do
        local wait = 500
        if DebugEnabled then wait = 0 end
        local lock = getNearestLock()
        if lock then
            wait = 0
            if DebugEnabled then
                DrawMarker(1, lock.coords.x, lock.coords.y, lock.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, lock.radius * 2.0, lock.radius * 2.0, 0.2, 0, 153, 204, 80, false, true, 2, false, nil, nil, false)
                local msg = string.format('ID: %s\nType: %s\nLocked: %s', lock.id, lock.type, tostring(lock.locked))
                AddTextEntry('CHRIS_LOCKS_DEBUG', msg)
                BeginTextCommandDisplayHelp('CHRIS_LOCKS_DEBUG')
                EndTextCommandDisplayHelp(0, false, false, -1)
            elseif lock.hidden == false then
                SetTextComponentFormat('STRING')
                AddTextComponentString(_('notify_locked'))
                DisplayHelpTextFromStringLabel(0, false, false, -1)
            end
        end
        Wait(wait)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if IsPasswordOpen then
        closePasswordNUI()
    end
end)
