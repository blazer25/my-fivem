-- Simple QBCore bridge for Qbox
CreateThread(function()
    while not GetResourceState('qbx_core'):find('start') do
        Wait(50)
    end
    local QBCore = exports['qbx_core']:GetCoreObject()
    exports('GetCoreObject', function()
        return QBCore
    end)
    print('[qb-core] Bridge client initialized.')
end)
