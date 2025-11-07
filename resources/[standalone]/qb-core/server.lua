CreateThread(function()
    -- Wait for qbx_core to fully start
    while GetResourceState('qbx_core') ~= 'started' do
        Wait(200)
    end

    local success, QBCore = pcall(function()
        return exports['qbx_core']:GetCoreObject()
    end)

    if not success or not QBCore then
        print("^1[qb-core bridge]^7 ERROR: Unable to get CoreObject from qbx_core. Check load order or errors above.")
        return
    end

    -- Export the old QBCore functions for compatibility
    exports('GetCoreObject', function()
        return QBCore
    end)

    exports('GetPlayers', function()
        return QBCore.Functions.GetPlayers()
    end)

    exports('GetQBPlayers', function()
        return QBCore.Functions.GetQBPlayers()
    end)

    exports('GetPlayer', function(source)
        return QBCore.Functions.GetPlayer(source)
    end)

    exports('GetPlayerByCitizenId', function(citizenId)
        return QBCore.Functions.GetPlayerByCitizenId(citizenId)
    end)

    exports('GetPlayerByPhone', function(phoneNumber)
        return QBCore.Functions.GetPlayerByPhone(phoneNumber)
    end)

    print('^2[qb-core bridge]^7 fully initialized — Qbox compatibility active.')
end)
