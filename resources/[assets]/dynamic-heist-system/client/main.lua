-- main.lua (Client-side)
-- Entry point for client-side logic in the Dynamic Heist System

local heistActive = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        -- Check for player proximity to heist locations
        if not heistActive then
            -- Example coordinates for heist trigger
            local playerCoords = GetEntityCoords(PlayerPedId())
            if #(playerCoords - vector3(251.85, 217.0, 101.68)) < 5.0 then
                DrawText3D(playerCoords, "~g~Press E to start the bank heist")
                if IsControlJustReleased(0, 38) then -- E key
                    heistActive = true
                    TriggerServerEvent('heist:initiate')
                end
            end
        end
    end
end)

-- DrawText function for interacting with locations
function DrawText3D(coords, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(coords.x, coords.y, coords.z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

RegisterNetEvent('heist:notify')
AddEventHandler('heist:notify', function(message)
    -- Notify player with a simple message
    ShowNotification("~y~[Heist]~s~ " .. message)
end)

function ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentSubstringPlayerName(text)
    DrawNotification(false, true)
end
