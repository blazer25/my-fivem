-- ============================================
-- QBOX Compatibility Bridge for Legacy QB Scripts
-- ============================================
local QBCore = QBCore or exports['qbx_core']:GetCoreObject()

-- Only add this if HasPermission isn't already defined
if not QBCore.Functions then QBCore.Functions = {} end

if not QBCore.Functions.HasPermission then
    QBCore.Functions.HasPermission = function(src, perm)
        if not src or not perm then return false end
        local success, result = pcall(function()
            return exports.qbx_core:HasPermission(src, perm)
        end)
        if success then
            return result
        else
            print("[Bridge] HasPermission call failed:", result)
            return false
        end
    end
    print("^2[Bridge] Added QBCore.Functions.HasPermission compatibility wrapper.^0")
end
