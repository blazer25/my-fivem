CreateThread(function()
    while GetResourceState('qbx_core') ~= 'started' do
        Wait(50)
    end

    local QBCore = exports['qbx_core']:GetCoreObject()
    exports('GetCoreObject', function()
        return QBCore
    end)

    print('[qb-core] Bridge client initialized.')
end)
