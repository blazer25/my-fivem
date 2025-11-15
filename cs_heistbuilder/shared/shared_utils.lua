local sharedUtils = {}

local isServer = IsDuplicityVersion()

--- Merge tables deeply (used for config overrides)
---@param destination table
---@param source table
---@return table
function sharedUtils.deepMerge(destination, source)
    destination = destination or {}
    source = source or {}

    for key, value in pairs(source) do
        if type(value) == 'table' then
            destination[key] = sharedUtils.deepMerge(destination[key] or {}, value)
        else
            destination[key] = value
        end
    end

    return destination
end

--- Shallow clone helper
function sharedUtils.clone(data)
    if type(data) ~= 'table' then return data end
    local copy = {}
    for key, value in pairs(data) do
        if type(value) == 'table' then
            copy[key] = sharedUtils.clone(value)
        else
            copy[key] = value
        end
    end
    return copy
end

--- Convert vector3/4 to serialisable table
function sharedUtils.serialiseVec(vec)
    if type(vec) == 'vector3' then
        return { x = vec.x + 0.0, y = vec.y + 0.0, z = vec.z + 0.0 }
    elseif type(vec) == 'vector4' then
        return { x = vec.x + 0.0, y = vec.y + 0.0, z = vec.z + 0.0, w = vec.w + 0.0 }
    elseif type(vec) == 'table' then
        local output = {}
        for key, value in pairs(vec) do
            output[key] = value
        end
        return output
    end
    return nil
end

--- Convert serialised vector table back to vector3/4
function sharedUtils.toVector(data)
    if type(data) ~= 'table' then return data end
    if data.w then
        return vector4(data.x + 0.0, data.y + 0.0, data.z + 0.0, data.w + 0.0)
    end
    return vector3(data.x + 0.0, data.y + 0.0, data.z + 0.0)
end

--- Distance helper used by client + server
function sharedUtils.distance(a, b)
    a, b = sharedUtils.serialiseVec(a), sharedUtils.serialiseVec(b)
    if not a or not b then return 0.0 end
    local dx, dy, dz = a.x - b.x, a.y - b.y, a.z - b.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

--- Permission helper (Qbox aware)
function sharedUtils.hasBuilderPerms(source)
    if isServer then
        if source == 0 then return true end
        if exports['qbx_core'] and exports['qbx_core'].HasGroup then
            if exports['qbx_core']:HasGroup(source, { 'admin', 'god', 'management' }) then
                return true
            end
        end
        return IsPlayerAceAllowed(source, 'command.heistbuilder')
    else
        if LocalPlayer.state['isHeistBuilderAdmin'] ~= nil then
            return LocalPlayer.state['isHeistBuilderAdmin']
        end
        return false
    end
end

--- Wrapper for debug logs
function sharedUtils.debug(message, ...)
    if not Config or not Config.Debug then return end
    local formatted = ('^3[HeistBuilder]^0 %s'):format(message)
    if isServer then
        print(formatted:format(...))
    else
        lib.print.info(formatted:format(...))
    end
end

sharedUtils.randomId = function(length)
    length = length or 8
    local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local buffer = {}
    for i = 1, length do
        local index = math.random(#chars)
        buffer[#buffer + 1] = chars:sub(index, index)
    end
    return table.concat(buffer)
end

CS_HEIST_SHARED_UTILS = sharedUtils

return sharedUtils
