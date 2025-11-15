-- main.lua (Server-side)
-- Entry point for server logic in the Dynamic Heist System

RegisterCommand("start_heist", function(source, args, rawCommand)
    -- Heist initialization logic
    local playerName = GetPlayerName(source)
    print(("[Server] %s initiated a heist"):format(playerName))
    TriggerEvent('heist:initiate', source)
end)

AddEventHandler('heist:initiate', function(player)
    -- Simplified heist start logic
    print("[Server] Heist event triggered for Player ID:", player)
    TriggerClientEvent('heist:notify', player, "The heist has started! Good luck!")
end)

-- Example: Simulating police notification
AddEventHandler('heist:notify_police', function(location)
    print("[Server] Police have been notified about a heist at:", location)
end)
