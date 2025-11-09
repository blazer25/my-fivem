-- Framework detection bridge for Qbox / QB-Core

local Framework = nil

-- Check which framework is running
if GetResourceState('qbx_core') == 'started' then
    -- Qbox: It doesn't use the export GetCoreObject, so fallback to global QBX if available
    if exports['qbx_core'] and exports['qbx_core'].GetCoreObject then
        Framework = exports['qbx_core']:GetCoreObject()
    elseif QBX then
        Framework = QBX
    else
        print("^1[JPR Phone] qbx_core is started, but no usable core object found!^0")
    end
elseif GetResourceState('qb-core') == 'started' then
    Framework = exports['qb-core']:GetCoreObject()
else
    print("^1[JPR Phone] No framework detected (qbx_core or qb-core)^0")
end

return Framework
