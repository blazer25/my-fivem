CreateThread(function()
    while not GetResourceState('qbx_core'):find('start') do
        Wait(50)
    end

    local QBCore = exports['qbx_core']:GetCoreObject()

    -- Basic QBCore export
    exports('GetCoreObject', function()
        return QBCore
    end)

    -- Compatibility with older QB scripts:
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

    print('[qb-core] Bridge server initialized with legacy exports.')
end)
