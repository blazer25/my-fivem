RegisterCommand(Config.AdminPanelCommand or 'admin', function()
    TriggerServerEvent('919-admin:server:RequestPanel')
end)

-- Optional: keybind (default 0 key from config)
RegisterKeyMapping(Config.AdminPanelCommand or 'admin', 'Open Admin Menu', 'keyboard', Config.AdminPanelKey or '0')

-- Optional: allow admins to re-open from NUI event
RegisterNetEvent('919-admin:client:OpenMenu', function(playerList, serverInfo, maxClients, version, role)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openMenu",
        data = {
            players = playerList,
            server = serverInfo,
            maxClients = maxClients,
            version = version,
            role = role
        }
    })
end)
