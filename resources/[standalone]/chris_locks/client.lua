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
local AdminUIOpen = false
local DoorSelectActive = false
local DoorSelectEntity = 0
local DoorSelectDouble = false
local DoorSelectQueue = {}
local CustomDoors = {}

local function rotationToDirection(rotation)
    local radX = math.rad(rotation.x)
    local radZ = math.rad(rotation.z)
    local cosX = math.cos(radX)
    return vec3(-math.sin(radZ) * cosX, math.cos(radZ) * cosX, math.sin(radX))
end

local function cameraRaycast(flags, distance)
    if lib and lib.raycast and lib.raycast.cam then
        return lib.raycast.cam(flags, distance)
    end

    local camCoord = GetGameplayCamCoord()
    local direction = rotationToDirection(GetGameplayCamRot(2))
    local range = distance or 10.0
    local destination = vec3(
        camCoord.x + direction.x * range,
        camCoord.y + direction.y * range,
        camCoord.z + direction.z * range
    )

    local rayFlags = flags or (1 | 16)
    local rayHandle = StartShapeTestRay(
        camCoord.x, camCoord.y, camCoord.z,
        destination.x, destination.y, destination.z,
        rayFlags,
        PlayerPedId(),
        7
    )

    local retval, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)
    if retval ~= 1 then
        return false, 0, endCoords, surfaceNormal
    end

    return hit == 1, entityHit, endCoords, surfaceNormal
end

local function resetDoorSelectionState()
    DoorSelectDouble = false
    DoorSelectQueue = {}
end

local function roundValue(value, decimals)
    local multiplier = 10 ^ (decimals or 2)
    return math.floor(value * multiplier + 0.5) / multiplier
end

local function buildDoorEntry(entity)
    local coords = GetEntityCoords(entity)
    local heading = GetEntityHeading(entity)
    local model = GetEntityModel(entity)
    local min, max = GetModelDimensions(model)
    local footprint = math.max(math.abs(max.x - min.x), math.abs(max.y - min.y))

    return {
        entity = entity,
        model = model,
        heading = heading,
        coords = { x = coords.x, y = coords.y, z = coords.z },
        footprint = footprint
    }
end

local function finalizeCustomDoorSelection()
    local count = #DoorSelectQueue
    if count == 0 then return end

    local entries = {}
    local center = vec3(0.0, 0.0, 0.0)
    local radius = 2.0

    for i = 1, count do
        local entry = DoorSelectQueue[i]
        entries[i] = {
            model = entry.model,
            heading = entry.heading,
            coords = {
                x = entry.coords.x,
                y = entry.coords.y,
                z = entry.coords.z
            }
        }
        center += vec3(entry.coords.x, entry.coords.y, entry.coords.z)

        local entryRadius = (entry.footprint or 1.6) * 0.5 + 0.75
        if entryRadius > radius then
            radius = entryRadius
        end
    end

    center = center / count

    if count == 2 then
        local c1 = vec3(entries[1].coords.x, entries[1].coords.y, entries[1].coords.z)
        local c2 = vec3(entries[2].coords.x, entries[2].coords.y, entries[2].coords.z)
        local pairRadius = #(c1 - c2) * 0.5 + 0.75
        if pairRadius > radius then
            radius = pairRadius
        end
    end

    radius = roundValue(radius, 2)

    local payload = {
        doorId = '',
        label = count == 2 and _('admin_select_custom_double_label') or _('admin_select_custom_single_label'),
        coords = { x = center.x, y = center.y, z = center.z },
        radius = radius,
        newDoor = {
            double = count == 2,
            doors = entries,
            center = { x = center.x, y = center.y, z = center.z },
            suggestedRadius = radius
        }
    }

    TriggerEvent('chris_locks:client:doorSelectResult', payload)
end

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

local function openAdminUI()
    if AdminUIOpen then return end
    AdminUIOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'openAdmin' })
end

local function closeAdminUI()
    if not AdminUIOpen then return end
    AdminUIOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeAdmin' })
end

local function stopDoorSelection(reopen)
    if DoorSelectEntity and DoorSelectEntity ~= 0 then
        SetEntityDrawOutline(DoorSelectEntity, false)
        DoorSelectEntity = 0
    end
    if DoorSelectActive then
        DoorSelectActive = false
        if lib and lib.hideTextUI then
            lib.hideTextUI()
        end
        EnableAllControlActions(0)
    end
    resetDoorSelectionState()
    if reopen then
        openAdminUI()
    end
end

local function startDoorSelection(options)
    if DoorSelectActive then return end
    DoorSelectActive = true
    DoorSelectEntity = 0
    DoorSelectDouble = (options and (options.doubleDoor or options.double)) and true or false
    DoorSelectQueue = {}
    local message = DoorSelectDouble and _('admin_select_door_ui_double') or _('admin_select_door_ui')
    if lib and lib.showTextUI then
        lib.showTextUI(message)
    else
        clientNotify(message, 'inform')
    end
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

RegisterNUICallback('locksAdmin:close', function(_, cb)
    cb(1)
    closeAdminUI()
end)

RegisterNUICallback('locksAdmin:startDoorSelect', function(data, cb)
    cb(1)
    closeAdminUI()
    startDoorSelection(data or {})
end)

RegisterNUICallback('locksAdmin:getLocks', function(_, cb)
    local response = lib.callback.await('chris_locks:admin:listLocks', false) or {}
    cb(response)
end)

RegisterNUICallback('locksAdmin:updatePassword', function(data, cb)
    local success, message = lib.callback.await('chris_locks:admin:updatePassword', false, data)
    cb({ success = success, message = message })
end)

RegisterNUICallback('locksAdmin:createLock', function(data, cb)
    local success, message = lib.callback.await('chris_locks:createLock', false, data)
    cb({ success = success, message = message })
end)

RegisterNUICallback('locksAdmin:removeLock', function(data, cb)
    local success, message = lib.callback.await('chris_locks:removeLock', false, data)
    cb({ success = success, message = message })
end)

RegisterNUICallback('locksAdmin:getDoorInfo', function(data, cb)
    local result = lib.callback.await('chris_locks:getDoorInfo', false, data and data.doorId) or {}
    if result and result.coords then
        result.coords = {
            x = result.coords.x or 0.0,
            y = result.coords.y or 0.0,
            z = result.coords.z or 0.0
        }
    end
    cb(result)
end)

RegisterNUICallback('locksAdmin:teleport', function(data, cb)
    cb(1)
    if not data or not data.id then return end
    TriggerServerEvent('chris_locks:admin:teleport', data.id)
end)

RegisterCommand('chrisLocks:interact', function()
    if IsPauseMenuActive() or IsPlayerDead(PlayerId()) then return end
    handleInteraction()
end, false)

RegisterKeyMapping('chrisLocks:interact', 'Interact with hidden locks', 'keyboard', Config.InteractionKey or 'E')

RegisterCommand('locksadmin', function()
    if AdminUIOpen then
        closeAdminUI()
        return
    end
    local allowed = lib.callback.await('chris_locks:canManage', false)
    if not allowed then
        clientNotify(_('notify_not_authorized'), 'error')
        return
    end
    openAdminUI()
end, false)

RegisterCommand('lockdebug', function()
    TriggerServerEvent('chris_locks:toggleDebug')
end, false)

RegisterNetEvent('chris_locks:client:setDebug', function(state)
    DebugEnabled = state
    clientNotify(_('command_usage_debug', tostring(DebugEnabled)), 'inform')
end)

RegisterNetEvent('chris_locks:client:teleportToCoords', function(coords)
    if not coords or not coords.x then return end
    local ped = PlayerPedId()
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Wait(0)
    end
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, true)
    Wait(100)
    DoScreenFadeIn(500)
end)

RegisterNetEvent('chris_locks:client:setLocks', function(data)
    handleLocksUpdate(data)
end)

local function getCustomDoorHash(lockId, index)
    return GetHashKey(('chris_locks_%s_%s'):format(lockId, index))
end

RegisterNetEvent('chris_locks:client:registerCustomDoor', function(lockId, data, locked)
    if CustomDoors[lockId] and CustomDoors[lockId].doors then
        for i = 1, #CustomDoors[lockId].doors do
            local hash = getCustomDoorHash(lockId, i)
            RemoveDoorFromSystem(hash)
        end
    end

    CustomDoors[lockId] = data or {}

    if not data or not data.doors then return end

    for i = 1, #data.doors do
        local door = data.doors[i]
        local coords = door.coords or {}
        local model = door.model
        if type(model) == 'string' then
            model = GetHashKey(model)
        else
            model = tonumber(model) or 0
        end
        local hash = getCustomDoorHash(lockId, i)

        AddDoorToSystem(hash, model, coords.x or 0.0, coords.y or 0.0, coords.z or 0.0, false, false, false)
        DoorSystemSetDoorState(hash, 4, false, false)
        DoorSystemSetAutomaticRate(hash, 10.0, false, false)
        DoorSystemSetDoorState(hash, locked and 1 or 0, false, false)
    end
end)

RegisterNetEvent('chris_locks:client:setCustomDoorState', function(lockId, locked)
    local data = CustomDoors[lockId]
    if not data or not data.doors then return end
    local state = locked and 1 or 0
    for i = 1, #data.doors do
        local hash = getCustomDoorHash(lockId, i)
        DoorSystemSetDoorState(hash, 4, false, false)
        DoorSystemSetDoorState(hash, state, false, false)
    end
end)

RegisterNetEvent('chris_locks:client:removeCustomDoor', function(lockId)
    local data = CustomDoors[lockId]
    if data and data.doors then
        for i = 1, #data.doors do
            local hash = getCustomDoorHash(lockId, i)
            RemoveDoorFromSystem(hash)
        end
    end
    CustomDoors[lockId] = nil
end)

RegisterNetEvent('chris_locks:client:doorSelectResult', function(payload)
    stopDoorSelection(true)
    if payload and payload.error then
        clientNotify(payload.error, 'error')
        return
    end
    if not payload or ((not payload.doorId or payload.doorId == '') and not payload.newDoor) then
        clientNotify(_('admin_select_door_fail'), 'error')
        return
    end
    if lib and lib.hideTextUI then
        lib.hideTextUI()
    end
    Citizen.SetTimeout(150, function()
        SendNUIMessage({
            action = 'doorSelected',
            doorId = payload.doorId or '',
            label = payload.label,
            coords = payload.coords,
            radius = payload.radius,
            newDoor = payload.newDoor
        })
    end)
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

CreateThread(function()
    local outlineColorSet = false
    while true do
        if DoorSelectActive then
            Wait(0)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 47, true)
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 141, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 257, true)

            local hit, entity, hitCoords = cameraRaycast(1 | 16, 8.0)
            if DoorSelectEntity ~= entity then
                if DoorSelectEntity and DoorSelectEntity ~= 0 then
                    SetEntityDrawOutline(DoorSelectEntity, false)
                end
                DoorSelectEntity = entity
                if not outlineColorSet then
                    outlineColorSet = true
                    SetEntityDrawOutlineShader(1)
                    SetEntityDrawOutlineColor(108, 141, 255, 255)
                end
                if entity and entity ~= 0 and DoesEntityExist(entity) then
                    SetEntityDrawOutline(entity, true)
                end
            end

            if hit and entity and entity ~= 0 and DoesEntityExist(entity) then
                local entityType = GetEntityType(entity)
                if entityType == 3 then
                    local pedCoords = GetEntityCoords(PlayerPedId())
                    DrawLine(pedCoords.x, pedCoords.y, pedCoords.z, hitCoords.x, hitCoords.y, hitCoords.z, 108, 141, 255, 200)
                end
                if IsDisabledControlJustPressed(0, 24) then
                    if entityType ~= 3 then
                        clientNotify(_('admin_select_door_fail'), 'error')
                    else
                        local doorId
                        if Utils.resourceActive('ox_doorlock') and exports.ox_doorlock and exports.ox_doorlock.getDoorIdFromEntity then
                            doorId = exports.ox_doorlock:getDoorIdFromEntity(entity)
                        end
                        if doorId then
                            local data = lib.callback.await('chris_locks:getDoorInfo', false, doorId)
                            if not data or not data.coords then
                                clientNotify(_('admin_select_door_not_registered'), 'error')
                            else
                                local coords = data.coords or {}
                                if data.doors and data.doors[1] and data.doors[1].coords then
                                    coords = data.doors[1].coords
                                end
                                TriggerEvent('chris_locks:client:doorSelectResult', {
                                    doorId = doorId,
                                    label = data.label or data.id or doorId,
                                    coords = {
                                        x = coords.x or 0.0,
                                        y = coords.y or 0.0,
                                        z = coords.z or 0.0,
                                    },
                                    radius = data.distance,
                                })
                            end
                        else
                            local duplicate = false
                            for i = 1, #DoorSelectQueue do
                                if DoorSelectQueue[i].entity == entity then
                                    duplicate = true
                                    break
                                end
                            end

                            if duplicate then
                                clientNotify(_('admin_select_door_duplicate'), 'error')
                            else
                                DoorSelectQueue[#DoorSelectQueue + 1] = buildDoorEntry(entity)

                                if DoorSelectDouble and #DoorSelectQueue < 2 then
                                    clientNotify(_('admin_select_door_wait_second'), 'inform')
                                else
                                    finalizeCustomDoorSelection()
                                end
                            end
                        end
                    end
                elseif IsDisabledControlJustPressed(0, 25) or IsDisabledControlJustPressed(0, 200) or IsDisabledControlJustPressed(0, 202) then
                    DoorSelectQueue = {}
                    stopDoorSelection(true)
                    clientNotify(_('admin_select_door_cancel'), 'inform')
                end
            else
                if DoorSelectEntity and DoorSelectEntity ~= 0 then
                    SetEntityDrawOutline(DoorSelectEntity, false)
                    DoorSelectEntity = 0
                end
            end
        else
            Wait(200)
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if IsPasswordOpen then
        closePasswordNUI()
    end
    if AdminUIOpen then
        closeAdminUI()
    end
    for lockId, data in pairs(CustomDoors) do
        if data.doors then
            for i = 1, #data.doors do
                local hash = getCustomDoorHash(lockId, i)
                RemoveDoorFromSystem(hash)
            end
        end
    end
    CustomDoors = {}
    stopDoorSelection(false)
end)
