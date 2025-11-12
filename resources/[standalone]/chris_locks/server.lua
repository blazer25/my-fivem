--[[
    Chris Locks System
    Author: Chris Hepburn
    Description: Advanced player and business lock system for FiveM (Qbox / QB / OX compatible)
    Version: 1.0.0
]]

local Framework = require 'server.framework'
local Utils = require 'shared.utils'
local _ = Utils._
local notify = Utils.notify

local Locks = {}
local SanitizedLocks = {}
local ActiveTimers = {}
local DebugStates = {}

local Inventory = {
    resource = Utils.resourceActive('ox_inventory') and 'ox_inventory' or nil
}

local function playerHasItem(source, item)
    if not item or item == '' then return false end
    if Inventory.resource == 'ox_inventory' then
        return exports.ox_inventory:Search(source, 'count', item) > 0
    end
    local player = Framework.getPlayer(source)
    if player and player.Functions and player.Functions.GetItemByName then
        return player.Functions.GetItemByName(item) ~= nil
    end
    return false
end

local function playerHasJob(source, jobs)
    if not jobs or #jobs == 0 then return false end
    return Framework.hasJob(source, jobs)
end

local function playerHasGang(source, gangs)
    if not gangs or #gangs == 0 then return false end
    return Framework.hasGang(source, gangs)
end

local function getIdentifier(source)
    return Framework.getIdentifier(source)
end

local function setDoorState(lock, locked)
    if lock.doorData then
        TriggerClientEvent('chris_locks:client:setCustomDoorState', -1, lock.id, locked)
    end
    if lock.targetDoorId and not lock.targetDoorId:find('custom:', 1, true) then
        Framework.setDoorStateAll(lock.targetDoorId, locked)
    end
end

local function sanitizeLock(lock)
    return {
        id = lock.id,
        type = lock.type,
        coords = { x = lock.coords.x, y = lock.coords.y, z = lock.coords.z },
        radius = lock.radius,
        hidden = lock.hidden,
        targetDoorId = lock.targetDoorId,
        unlockDuration = lock.unlockDuration,
        locked = lock.locked,
        customDoor = lock.doorData ~= nil,
    }
end

local function ensureVector(value)
    if value and type(value) == 'vector3' then
        return value
    end
    if value and type(value) == 'table' then
        return vector3(value.x or 0.0, value.y or 0.0, value.z or 0.0)
    end
    return vector3(0.0, 0.0, 0.0)
end

local function cloneCoordsTable(value)
    if not value then
        return { x = 0.0, y = 0.0, z = 0.0 }
    end
    return {
        x = tonumber(value.x) or 0.0,
        y = tonumber(value.y) or 0.0,
        z = tonumber(value.z) or 0.0,
    }
end

local function normalizeDoorId(value)
    if not value or value == '' then
        return nil
    end
    return value
end

local function prepareDoorDataForNetwork(doorData)
    if not doorData or not doorData.doors then return nil end
    local payload = {
        double = doorData.double or (#doorData.doors > 1),
        suggestedRadius = doorData.suggestedRadius,
        center = cloneCoordsTable(doorData.center or {}),
        doors = {}
    }

    for i = 1, #doorData.doors do
        local entry = doorData.doors[i]
        payload.doors[i] = {
            model = entry.model,
            heading = entry.heading,
            coords = cloneCoordsTable(entry.coords)
        }
    end

    return payload
end

local function rehydrateDoorData(data)
    if not data or not data.doors then return nil end
    local doors = {}

    for i = 1, #data.doors do
        local entry = data.doors[i]
        if entry then
            doors[i] = {
                model = tonumber(entry.model),
                heading = tonumber(entry.heading) or 0.0,
                coords = cloneCoordsTable(entry.coords)
            }
        end
    end

    if #doors == 0 then return nil end

    local centerSource = data.center or doors[1].coords

    return {
        double = data.double or (#doors > 1),
        doors = doors,
        center = ensureVector(centerSource),
        suggestedRadius = data.suggestedRadius and tonumber(data.suggestedRadius) or nil
    }
end

local function sanitizeNewDoorData(lockId, newDoor)
    if type(newDoor) ~= 'table' then
        return false, _('admin_select_door_fail')
    end

    local doorsInput = newDoor.doors
    if type(doorsInput) ~= 'table' or #doorsInput == 0 then
        return false, _('admin_select_door_fail')
    end

    local sanitized = {
        double = newDoor.double and true or false,
        doors = {}
    }

    local sumX, sumY, sumZ = 0.0, 0.0, 0.0

    for i = 1, #doorsInput do
        local entry = doorsInput[i]
        if type(entry) ~= 'table' or not entry.coords then
            return false, _('admin_select_door_fail')
        end
        local coords = cloneCoordsTable(entry.coords)
        local model = tonumber(entry.model)
        if not model then
            return false, _('admin_select_door_fail')
        end

        sanitized.doors[i] = {
            model = model,
            heading = tonumber(entry.heading) or 0.0,
            coords = coords
        }

        sumX = sumX + coords.x
        sumY = sumY + coords.y
        sumZ = sumZ + coords.z
    end

    local count = #sanitized.doors
    local center = newDoor.center and cloneCoordsTable(newDoor.center) or {
        x = sumX / count,
        y = sumY / count,
        z = sumZ / count
    }

    sanitized.center = ensureVector(center)
    sanitized.double = sanitized.double or count > 1
    sanitized.suggestedRadius = newDoor.suggestedRadius and tonumber(newDoor.suggestedRadius) or nil

    return true, sanitized
end

local function syncCustomDoor(lock, target)
    if not lock.doorData then return end
    local payload = prepareDoorDataForNetwork(lock.doorData)
    if not payload then return end
    TriggerClientEvent('chris_locks:client:registerCustomDoor', target or -1, lock.id, payload, lock.locked ~= false)
end

local function removeCustomDoor(lockId, target)
    TriggerClientEvent('chris_locks:client:removeCustomDoor', target or -1, lockId)
end

local function adminSerializeLock(lock)
    return {
        id = lock.id,
        type = lock.type,
        coords = { x = lock.coords.x, y = lock.coords.y, z = lock.coords.z },
        radius = lock.radius,
        hidden = lock.hidden,
        targetDoorId = lock.targetDoorId,
        unlockDuration = lock.unlockDuration,
        static = lock.static or false,
        password = lock.data and lock.data.password or nil,
        item = lock.data and lock.data.item or nil,
        jobs = lock.data and lock.data.jobs or {},
        gangs = lock.data and lock.data.gangs or {},
        ownerIdentifier = lock.data and lock.data.ownerIdentifier or nil,
        authorizedPlayers = lock.data and lock.data.authorizedPlayers or {},
        locked = lock.locked,
        customDoor = lock.doorData ~= nil,
    }
end

local LockTypes = {}

LockTypes.password = {
    validate = function(source, lock, payload)
        if not payload or not payload.password then
            notify(source, _('password_required'), 'error')
            return false
        end
        if lock.data.password and payload.password == lock.data.password then
            return true
        end
        notify(source, _('notify_wrong_password'), 'error')
        return false
    end,
    sanitize = function(lock)
        lock.data.password = lock.data.password or ''
    end,
}

LockTypes.item = {
    validate = function(source, lock)
        if not lock.data.item then
            return false
        end
        if playerHasItem(source, lock.data.item) then
            return true
        end
        notify(source, _('notify_missing_item', lock.data.item), 'error')
        return false
    end,
    sanitize = function(lock)
        lock.data.item = lock.data.item or ''
    end,
}

LockTypes.job = {
    validate = function(source, lock)
        local jobs = lock.data.jobs or {}
        local gangs = lock.data.gangs or {}
        if #jobs > 0 and playerHasJob(source, jobs) then
            return true
        end
        if #gangs > 0 and playerHasGang(source, gangs) then
            return true
        end
        notify(source, _('notify_missing_job'), 'error')
        return false
    end,
    sanitize = function(lock)
        lock.data.jobs = lock.data.jobs or {}
        lock.data.gangs = lock.data.gangs or {}
    end,
}

LockTypes.owner = {
    validate = function(source, lock)
        local identifier = Framework.getIdentifier(source)
        lock.data.authorizedPlayers = lock.data.authorizedPlayers or {}
        if identifier and lock.data.authorizedPlayers[identifier] then
            return true
        end
        local owner = lock.data.ownerIdentifier
        if owner and identifier and owner == identifier then
            return true
        end
        notify(source, _('notify_missing_owner'), 'error')
        return false
    end,
    sanitize = function(lock)
        lock.data.ownerIdentifier = lock.data.ownerIdentifier or nil
        lock.data.authorizedPlayers = lock.data.authorizedPlayers or {}
    end,
}

local function mergeLockData(lock)
    local lt = LockTypes[lock.type]
    if lt and lt.sanitize then
        lt.sanitize(lock)
    end
end

local function prepareSanitized(lock)
    SanitizedLocks[lock.id] = sanitizeLock(lock)
end

local function broadcastLocks(target)
    if target then
        TriggerClientEvent('chris_locks:client:setLocks', target, SanitizedLocks)
        for _, lock in pairs(Locks) do
            if lock.doorData then
                syncCustomDoor(lock, target)
            end
        end
    else
        TriggerClientEvent('chris_locks:client:setLocks', -1, SanitizedLocks)
    end
end

local function unlockDoor(lockId, source, reason)
    local lock = Locks[lockId]
    if not lock then return false end
    if not lock.locked then return true end

    lock.locked = false
    setDoorState(lock, false)
    notify(source or 0, _('notify_unlocked'), 'inform')
    if lock.unlockDuration and lock.unlockDuration > 0 then
        if ActiveTimers[lockId] then
            ClearTimeout(ActiveTimers[lockId])
        end
        ActiveTimers[lockId] = SetTimeout(lock.unlockDuration * 1000, function()
            lock.locked = true
            setDoorState(lock, true)
            notify(0, _('notify_relocked'), 'inform')
            ActiveTimers[lockId] = nil
            prepareSanitized(lock)
            broadcastLocks()
        end)
    end
    prepareSanitized(lock)
    broadcastLocks()
    print(('[chris_locks] %s'):format(_('log_unlock_success', lock.id, tostring(source or 0))))
    return true
end

local function lockDoor(lockId, reason)
    local lock = Locks[lockId]
    if not lock then return false end
    if lock.locked then return true end
    lock.locked = true
    if ActiveTimers[lockId] then
        ClearTimeout(ActiveTimers[lockId])
        ActiveTimers[lockId] = nil
    end
    setDoorState(lock, true)
    prepareSanitized(lock)
    broadcastLocks()
    notify(0, _('notify_locked'), 'inform')
    return true
end

local function ensureSchema()
    MySQL.query([[CREATE TABLE IF NOT EXISTS `chris_locks` (
        `id` VARCHAR(50) PRIMARY KEY,
        `type` VARCHAR(30) NOT NULL,
        `coords` JSON NOT NULL,
        `radius` FLOAT DEFAULT 2.5,
        `password` VARCHAR(64) NULL,
        `item` VARCHAR(64) NULL,
        `job` VARCHAR(128) NULL,
        `owner_identifier` VARCHAR(60) NULL,
        `targetDoorId` VARCHAR(64) NULL,
        `doorData` LONGTEXT NULL,
        `hidden` BOOLEAN DEFAULT TRUE,
        `unlockDuration` INT DEFAULT 300,
        `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )]])
    local hasDoorColumn = MySQL.query.await("SHOW COLUMNS FROM `chris_locks` LIKE 'doorData'")
    if not hasDoorColumn or #hasDoorColumn == 0 then
        MySQL.query('ALTER TABLE `chris_locks` ADD COLUMN `doorData` LONGTEXT NULL')
    end
    local doorIdColumn = MySQL.query.await("SHOW COLUMNS FROM `chris_locks` LIKE 'targetDoorId'")
    if doorIdColumn and doorIdColumn[1] and doorIdColumn[1].Null == 'NO' then
        MySQL.query('ALTER TABLE `chris_locks` MODIFY `targetDoorId` VARCHAR(64) NULL')
    end
end

local function decodeJSON(value, default)
    if not value or value == '' then return default end
    local ok, result = pcall(json.decode, value)
    if ok and result then return result end
    return default
end

local function loadLocksFromDatabase()
    local result = MySQL.query.await('SELECT * FROM chris_locks')
    if not result then return end
    for _, row in ipairs(result) do
        local coordTable = decodeJSON(row.coords, { x = 0.0, y = 0.0, z = 0.0 })
        local jobsRaw = decodeJSON(row.job, row.job and splitList(row.job) or {})
        if type(jobsRaw) == 'string' then
            jobsRaw = splitList(jobsRaw)
        end
        local lock = {
            id = row.id,
            type = row.type,
            coords = ensureVector(coordTable),
            radius = row.radius or 2.5,
            hidden = row.hidden ~= 0,
            targetDoorId = normalizeDoorId(row.targetDoorId),
            unlockDuration = row.unlockDuration or Config.DefaultUnlockDuration,
            locked = true,
            data = {
                password = row.password,
                item = row.item,
                jobs = jobsRaw,
                gangs = {},
                ownerIdentifier = row.owner_identifier,
            }
        }
        local doorData = rehydrateDoorData(decodeJSON(row.doorData, nil))
        if doorData then
            lock.doorData = doorData
            lock.coords = ensureVector(doorData.center or lock.coords)
            if (not lock.radius or lock.radius <= 0) and doorData.suggestedRadius then
                lock.radius = doorData.suggestedRadius
            end
        end
        mergeLockData(lock)
        Locks[lock.id] = lock
        prepareSanitized(lock)
    end
    for _, lock in pairs(Locks) do
        if lock.doorData then
            syncCustomDoor(lock)
        end
    end
end

local function integrateStaticLocks()
    for _, entry in ipairs(Config.StaticLocks or {}) do
        if not Locks[entry.id] then
            local lock = {
                id = entry.id,
                type = entry.type,
                coords = ensureVector(entry.coords),
                radius = entry.radius or 2.5,
                hidden = entry.hidden ~= false,
                targetDoorId = normalizeDoorId(entry.targetDoorId),
                unlockDuration = entry.unlockDuration or Config.DefaultUnlockDuration,
                locked = true,
                data = {
                    password = entry.password,
                    item = entry.item,
                    jobs = entry.jobs,
                    gangs = entry.gangs,
                    ownerIdentifier = entry.owner_identifier,
                },
                static = true,
            }
            mergeLockData(lock)
            Locks[lock.id] = lock
            prepareSanitized(lock)
        end
    end
end

local function saveLock(lock)
    if lock.static then return end
    local doorPayload = lock.doorData and prepareDoorDataForNetwork(lock.doorData)
    MySQL.insert('REPLACE INTO chris_locks (id, type, coords, radius, password, item, job, owner_identifier, targetDoorId, doorData, hidden, unlockDuration) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', {
        lock.id,
        lock.type,
        json.encode({ x = lock.coords.x, y = lock.coords.y, z = lock.coords.z }),
        lock.radius,
        lock.data.password,
        lock.data.item,
        lock.data.jobs and json.encode(lock.data.jobs) or nil,
        lock.data.ownerIdentifier,
        normalizeDoorId(lock.targetDoorId),
        doorPayload and json.encode(doorPayload) or nil,
        lock.hidden,
        lock.unlockDuration
    })
end

local function deleteLock(lockId)
    MySQL.execute('DELETE FROM chris_locks WHERE id = ?', { lockId })
end

local function registerLock(lock)
    mergeLockData(lock)
    lock.targetDoorId = normalizeDoorId(lock.targetDoorId)
    lock.locked = true
    if lock.doorData then
        lock.coords = ensureVector(lock.doorData.center or lock.coords)
        if (not lock.radius or lock.radius <= 0) and lock.doorData.suggestedRadius then
            lock.radius = lock.doorData.suggestedRadius
        end
    end
    Locks[lock.id] = lock
    prepareSanitized(lock)
    saveLock(lock)
    if lock.doorData then
        syncCustomDoor(lock)
    end
    setDoorState(lock, true)
    broadcastLocks()
end

local function removeLock(lockId)
    local lock = Locks[lockId]
    if not lock then return false end
    if lock.doorData then
        removeCustomDoor(lockId)
    end
    Locks[lockId] = nil
    SanitizedLocks[lockId] = nil
    deleteLock(lockId)
    broadcastLocks()
    return true
end

local function findLockByDoorId(doorId)
    for id, lock in pairs(Locks) do
        if lock.targetDoorId == doorId then
            return lock
        end
    end
end

local function canUseCommand(source)
    if source == 0 then return true end
    if Config.DebugPermission and IsPlayerAceAllowed(source, Config.DebugPermission) then
        return true
    end
    return false
end

local function createLockFromData(source, data)
    if not canUseCommand(source) then
        return false, _('notify_not_authorized')
    end

    if not data or type(data) ~= 'table' then
        return false, _('command_usage_addlock')
    end

    local id = data.id and data.id:lower()
    if not id or id == '' then
        return false, _('command_usage_addlock')
    end

    if Locks[id] then
        return false, _('notify_exists')
    end

    local lockType = data.type
    if not lockType or not LockTypes[lockType] then
        return false, _('command_usage_addlock')
    end

    local targetDoorId = data.targetDoorId
    local newDoorPayload = data.newDoor
    local coords = nil
    if data.coords then
        coords = ensureVector(data.coords)
    end
    local sanitizedDoor

    if newDoorPayload then
        local ok, result = sanitizeNewDoorData(id, newDoorPayload)
        if not ok then
            return false, result or _('admin_select_door_fail')
        end
        sanitizedDoor = result
        coords = sanitizedDoor.center
        if not targetDoorId or targetDoorId == '' then
            targetDoorId = ('custom:%s'):format(id)
        end
        if not data.radius and sanitizedDoor.suggestedRadius then
            data.radius = sanitizedDoor.suggestedRadius
        end
    elseif Utils.resourceActive('ox_doorlock') and targetDoorId and targetDoorId ~= '' then
        local door = exports.ox_doorlock:getDoor(targetDoorId)
        if not door then
            return false, _('door_not_registered', targetDoorId)
        end
        coords = ensureVector(door.coords)
        targetDoorId = door.id
        if not data.radius and door.distance then
            data.radius = door.distance
        end
    end

    if not coords then
        return false, _('command_usage_addlock')
    end

    targetDoorId = normalizeDoorId(targetDoorId)

    local lock = {
        id = id,
        type = lockType,
        coords = ensureVector(coords),
        radius = tonumber(data.radius) or (sanitizedDoor and sanitizedDoor.suggestedRadius) or 2.5,
        hidden = data.hidden ~= false,
        targetDoorId = targetDoorId,
        unlockDuration = tonumber(data.unlockDuration) or Config.DefaultUnlockDuration,
        data = {},
        doorData = sanitizedDoor,
    }

    local credential = data.credential
    if lockType == 'password' then
        if not credential or credential == '' then
            return false, _('password_required')
        end
        lock.data.password = credential
    elseif lockType == 'item' then
        if not credential or credential == '' then
            return false, _('notify_missing_item', 'item')
        end
        lock.data.item = credential
    elseif lockType == 'job' then
        local jobs = splitList(credential)
        if #jobs == 0 then
            return false, _('notify_missing_job')
        end
        lock.data.jobs = jobs
    elseif lockType == 'owner' then
        if not credential or credential == '' then
            return false, _('notify_missing_owner')
        end
        lock.data.ownerIdentifier = credential
    end

    registerLock(lock)
    return true, _('notify_added', id)
end

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    ensureSchema()
    loadLocksFromDatabase()
    integrateStaticLocks()
    broadcastLocks()
    for _, lock in pairs(Locks) do
        setDoorState(lock, true)
    end
end)

RegisterNetEvent('chris_locks:server:requestLocks', function()
    local src = source
    broadcastLocks(src)
end)

RegisterNetEvent('chris_locks:attemptUnlock', function(lockId, payload)
    local src = source
    local lock = Locks[lockId]
    if not lock then
        notify(src, _('notify_invalid_lock'), 'error')
        return
    end
    if not lock.locked then
        notify(src, _('notify_in_progress'), 'inform')
        return
    end
    local player = Framework.getPlayer(src)
    if not player then
        notify(src, _('notify_invalid_lock'), 'error')
        return
    end
    local handler = LockTypes[lock.type]
    if not handler or not handler.validate then
        notify(src, _('notify_invalid_lock'), 'error')
        return
    end
    if handler.validate(src, lock, payload or {}) then
        unlockDoor(lockId, src, 'player_success')
    else
        print(('[chris_locks] %s'):format(_('log_unlock_fail', lock.id, tostring(src))))
    end
end)

RegisterCommand('addlock', function(source, args)
    if not canUseCommand(source) then
        notify(source, _('notify_not_authorized'), 'error')
        return
    end

    local id = args[1]
    local lockType = args[2]
    local credential = args[3]
    local x, y, z = tonumber(args[4]), tonumber(args[5]), tonumber(args[6])
    local radius = tonumber(args[7]) or 2.5
    local targetDoorId = args[8]
    local duration = tonumber(args[9]) or Config.DefaultUnlockDuration
    local hidden = args[10] ~= 'false'

    local success, message = createLockFromData(source, {
        id = id,
        type = lockType,
        credential = credential,
        coords = x and y and z and { x = x, y = y, z = z } or nil,
        radius = radius,
        targetDoorId = targetDoorId,
        unlockDuration = duration,
        hidden = hidden
    })

    if success then
        notify(source, message, 'success')
    else
        notify(source, message or _('command_usage_addlock'), 'error')
    end
end, false)

RegisterCommand('removelock', function(source, args)
    if not canUseCommand(source) then
        notify(source, _('notify_not_authorized'), 'error')
        return
    end
    local id = args[1]
    if not id then
        notify(source, _('command_usage_removelock'), 'error')
        return
    end
    if removeLock(id) then
        notify(source, _('notify_removed', id), 'success')
    else
        notify(source, _('notify_invalid_lock'), 'error')
    end
end, false)

RegisterCommand('listlocks', function(source)
    if not canUseCommand(source) then
        notify(source, _('notify_not_authorized'), 'error')
        return
    end
    local ids = {}
    for id in pairs(Locks) do
        ids[#ids + 1] = id
    end
    if #ids == 0 then
        notify(source, _('notify_no_locks'), 'inform')
    else
        notify(source, _('command_usage_listlocks', table.concat(ids, ', ')), 'inform')
    end
end, false)

RegisterCommand('lockdebug', function(source)
    if not canUseCommand(source) then
        notify(source, _('notify_not_authorized'), 'error')
        return
    end
    DebugStates[source] = not DebugStates[source]
    TriggerClientEvent('chris_locks:client:setDebug', source, DebugStates[source])
end, false)

RegisterNetEvent('chris_locks:toggleDebug', function()
    local src = source
    if not canUseCommand(src) then
        notify(src, _('notify_not_authorized'), 'error')
        return
    end
    DebugStates[src] = not DebugStates[src]
    TriggerClientEvent('chris_locks:client:setDebug', src, DebugStates[src])
end)

AddEventHandler('playerDropped', function()
    local src = source
    DebugStates[src] = nil
end)

exports('isLocked', function(lockId)
    local lock = Locks[lockId]
    return lock and lock.locked
end)

exports('unlockDoor', function(lockId)
    return unlockDoor(lockId, 0, 'export')
end)

exports('lockDoor', function(lockId)
    return lockDoor(lockId, 'export')
end)

exports('addAuthorizedPlayer', function(lockId, identifier)
    local lock = Locks[lockId]
    if not lock then return false end
    lock.data.authorizedPlayers = lock.data.authorizedPlayers or {}
    lock.data.authorizedPlayers[identifier] = true
    return true
end)

lib.callback.register('chris_locks:canManage', function(source)
    return canUseCommand(source)
end)

lib.callback.register('chris_locks:getDoorInfo', function(source, doorId)
    if not doorId or doorId == '' then return nil end
    for _, lock in pairs(Locks) do
        if lock.targetDoorId == doorId and lock.doorData then
            local payload = prepareDoorDataForNetwork(lock.doorData)
            return {
                id = doorId,
                label = ('Custom door (%s)'):format(lock.id),
                coords = cloneCoordsTable(lock.doorData.center or lock.coords),
                doors = payload and payload.doors or nil,
                distance = lock.radius
            }
        end
    end
    if Utils.resourceActive('ox_doorlock') then
        return exports.ox_doorlock:getDoor(doorId)
    end
    return nil
end)

lib.callback.register('chris_locks:createLock', function(source, data)
    local success, message = createLockFromData(source, data)
    return success, message
end)

lib.callback.register('chris_locks:admin:listLocks', function(source)
    if not canUseCommand(source) then
        return { error = _('notify_not_authorized') }
    end
    local list = {}
    for _, lock in pairs(Locks) do
        list[#list + 1] = adminSerializeLock(lock)
    end
    table.sort(list, function(a, b)
        return tostring(a.id) < tostring(b.id)
    end)
    return { locks = list }
end)

lib.callback.register('chris_locks:admin:updatePassword', function(source, data)
    if not canUseCommand(source) then
        return false, _('notify_not_authorized')
    end
    local id = data and data.id
    if not id or id == '' then
        return false, _('notify_invalid_lock')
    end
    local lock = Locks[id]
    if not lock then
        return false, _('notify_invalid_lock')
    end
    if lock.type ~= 'password' then
        return false, _('notify_invalid_lock')
    end
    local password = data.password
    if password and password ~= '' then
        lock.data.password = password
    else
        lock.data.password = nil
    end
    saveLock(lock)
    prepareSanitized(lock)
    broadcastLocks()
    return true, _('notify_saved')
end)

lib.callback.register('chris_locks:removeLock', function(source, data)
    if not canUseCommand(source) then
        return false, _('notify_not_authorized')
    end
    local id = data and data.id
    if (not id or id == '') and data and data.doorId then
        local lock = findLockByDoorId(data.doorId)
        id = lock and lock.id or id
    end
    if not id or id == '' then
        return false, _('notify_invalid_lock')
    end
    if removeLock(id) then
        return true, _('notify_removed', id)
    end
    return false, _('notify_invalid_lock')
end)

RegisterNetEvent('chris_locks:admin:teleport', function(lockId)
    local src = source
    if not canUseCommand(src) then
        notify(src, _('notify_not_authorized'), 'error')
        return
    end
    local lock = Locks[lockId]
    if not lock then
        notify(src, _('notify_invalid_lock'), 'error')
        return
    end
    TriggerClientEvent('chris_locks:client:teleportToCoords', src, {
        x = lock.coords.x,
        y = lock.coords.y,
        z = lock.coords.z
    })
end)

local function splitList(value)
    if not value or value == '' then return {} end
    local list = {}
    for entry in string.gmatch(value, '([^,]+)') do
        list[#list + 1] = entry:lower():gsub('^%s*(.-)%s*$', '%1')
    end
    return list
end
