-- QBOX / QB-Core Auto Framework Bridge
local QBCore = nil

if GetResourceState('qbx_core') == 'started' then
    QBCore = exports['qbx_core']:GetCoreObject()
    print('^2[JPR Casino] Linked to QBOX Core (qbx_core)^0')
elseif GetResourceState('qb-core') == 'started' then
    QBCore = exports['qb-core']:GetCoreObject()
    print('^2[JPR Casino] Linked to QB-Core^0')
else
    print('^1[JPR Casino] No Core Framework Found (qbx_core or qb-core)^0')
    QBCore = {}
end

return QBCore
