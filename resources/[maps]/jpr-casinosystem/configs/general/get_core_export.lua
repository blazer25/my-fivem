local Core = nil

if GetResourceState('qbx_core') == 'started' then
    if QBX then
        Core = QBX
        _G.QBCore = QBX    -- ✅ backward-compatibility alias (explicit global)
        QBCore = QBX       -- Also set without _G for compatibility
        print('^2[JPR Casino] Linked to QBOX Core via global QBX^0')
    else
        print('^1[JPR Casino] ERROR: QBX global is nil!^0')
        Core, _G.QBCore, QBCore = {}, {}, {}
    end
elseif GetResourceState('qb-core') == 'started' then
    Core = exports['qb-core']:GetCoreObject()
    _G.QBCore = Core
    QBCore = Core
    print('^2[JPR Casino] Linked to QB-Core^0')
else
    print('^1[JPR Casino] No core framework detected (qbx_core or qb-core)^0')
    Core, _G.QBCore, QBCore = {}, {}, {}
end

return Core
