-- Framework detection bridge for Qbox / QB-Core
local Framework = nil

if GetResourceState('qbx_core') == 'started' then
    if QBX then
        Framework = QBX
        print("^2[JPR Phone] Linked to QBOX Core (qbx_core)^0")
    else
        print("^1[JPR Phone] qbx_core started but QBX global not found!^0")
        Framework = {}
    end
elseif GetResourceState('qb-core') == 'started' then
    Framework = exports['qb-core']:GetCoreObject()
    print("^2[JPR Phone] Linked to QB-Core^0")
else
    print("^1[JPR Phone] No framework found (qbx_core or qb-core)^0")
    Framework = {}
end

return Framework
