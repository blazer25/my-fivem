-- ============================================
-- QBOX Compatibility Bridge for Legacy QB Scripts
-- ============================================

CreateThread(function()
    repeat
        Wait(500)
    until GetResourceState('qbx_core') == 'started'

    local QBCore = QBCore or exports['qbx_core']:GetCoreObject()
    if not QBCore.Functions then QBCore.Functions = {} end

    if not QBCore.Functions.HasPermission then
        QBCore.Functions.HasPermission = function(src, perm)
            if not src or not perm then return false end
            local ok, result = pcall(function()
                return exports.qbx_core:HasPermission(src, perm)
            end)
            if ok then
                return result
            else
                print('[Bridge] HasPermission call failed:', result)
                return false
            end
        end
        print('^2[Bridge] Added QBCore.Functions.HasPermission compatibility wrapper.^0')
    end
end)
