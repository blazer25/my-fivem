local Core = nil

if GetResourceState('qbx_core') == 'started' then
    Core = QBX
    QBCore = QBX    -- ✅ backward-compatibility alias
    print('^2[JPR Casino] Linked to QBOX Core via global QBX^0')
elseif GetResourceState('qb-core') == 'started' then
    Core = exports['qb-core']:GetCoreObject()
    QBCore = Core
    print('^2[JPR Casino] Linked to QB-Core^0')
else
    print('^1[JPR Casino] No core framework detected (qbx_core or qb-core)^0')
    Core, QBCore = {}, {}
end

return Core
