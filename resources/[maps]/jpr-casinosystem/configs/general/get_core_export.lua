local Core

local maxAttempts = 200 -- wait up to ~20 seconds
local attempt = 0

if IsDuplicityVersion() then
    while attempt < maxAttempts do
        attempt += 1
        local success, coreObj = pcall(function()
            if GetResourceState('qbx_core') == 'started' then
                if exports['qbx_core'] and exports['qbx_core'].GetCoreObject then
                    return exports['qbx_core']:GetCoreObject()
                elseif exports['qb-core'] and exports['qb-core'].GetCoreObject then
                    return exports['qb-core']:GetCoreObject()
                end
            end
            return nil
        end)

        if success and coreObj and coreObj.Functions then
            Core = coreObj
            _G.QBX = coreObj
            _G.QBCore = coreObj
            QBX = coreObj
            QBCore = coreObj
            print('^2[JPR Casino] Core export acquired from qbx_core^0')
            break
        end

        Wait(100)
    end

    if not Core then
        error('[JPR Casino] Failed to acquire core export from qbx_core / qb-core before timeout')
    end
else
    -- client side, wait until state bag or exports register QBX
    while attempt < maxAttempts do
        attempt += 1
        if _G.QBX and _G.QBX.Functions then
            Core = _G.QBX
            break
        end
        if _G.QBCore and _G.QBCore.Functions then
            Core = _G.QBCore
            break
        end
        Wait(100)
    end

    if not Core then
        error('[JPR Casino] Client failed to detect QBX/QBCore within timeout; ensure qbx_core is started first')
    end
end

return Core
