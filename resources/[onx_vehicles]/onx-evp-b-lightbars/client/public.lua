local PENDING = {}

---Spawns a vehicle at the specified coordinates and heading with full validation and model streaming
---@param modelHash number The hash of the vehicle model to spawn
---@param coords vector3 The coordinates where the vehicle should be spawned (x, y, z)
---@param heading number The heading/direction the vehicle will face when spawned (in degrees)
---@return number vehicle The entity handle of the spawned vehicle, or 0 if failed
function spawnVehicle(modelHash, coords, heading)
    if not IsModelInCdimage(modelHash) then
        return 0
    end
    RequestModel(modelHash)

    if not waitWithTimeout(function()
        return HasModelLoaded(modelHash)
    end, 15000, 'Model hash ' .. modelHash .. ' loading timed out') then
        log('Failed to load model hash ' .. modelHash)
        SetModelAsNoLongerNeeded(modelHash)
        return 0
    end

    local key = coords.x .. "," .. coords.y .. "," .. coords.z .. "," .. heading
    if PENDING[key] then
        return 0
    end

    PENDING[key] = true

    local entityHandle = CreateVehicle(modelHash, coords.x, coords.y, coords.z, heading, true, true)

    local success = waitWithTimeout(function()
        return entityHandle ~= 0 and DoesEntityExist(entityHandle)
    end, 15000, 'Failed to spawn after 15 seconds')

    SetModelAsNoLongerNeeded(modelHash)
    PENDING[key] = nil

    if not success then
        return 0
    end

    PENDING[key] = nil
    return entityHandle
end

function deleteVehicle(handle)
    DeleteEntity(handle)
end

-- Requires modifications if you are using sv_filterRequestControl since that stops clients getting control of entities
function requestEntityOwnership(handles)
    return waitWithTimeout(function()
        for _, entity in ipairs(handles) do
            NetworkRequestControlOfEntity(entity)
        end
        for _, entity in ipairs(handles) do
            if not NetworkHasControlOfEntity(entity) then
                return false
            end
        end

        return true
    end, 15000, 'Failed to get control of entities within 15 seconds')
end
