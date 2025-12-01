-- Fishing Rod Handler (Lua)
-- Handles fishing rod item usage and /fish command
-- Replaces TypeScript client functionality

local isFishing = false

-- Handle fishing rod item usage from ox_inventory
AddEventHandler('ox_inventory:usedItem', function(itemName, slot, metadata)
    if itemName == 'fishingrod1' then
        changeFishingState()
    end
end)

-- /fish command as fallback
RegisterCommand('fish', function()
    changeFishingState()
end, false)

-- Add command suggestion
TriggerEvent('chat:addSuggestion', '/fish', 'Start or stop fishing')

-- Handle fishing state change
function changeFishingState()
    if isFishing then
        -- Stop fishing
        isFishing = false
        lib.notify({
            title = 'Fishing',
            description = 'Fishing stopped',
            type = 'info'
        })
    else
        -- Start fishing - request from server
        isFishing = true
        TriggerServerEvent('brz-fishing:requestStartFishing')
    end
end

-- Listen for server response to start fishing
RegisterNetEvent('brz-fishing:startFishing', function(fishId)
    -- Server has selected a fish, now the TypeScript minigame would start
    -- For now, we just acknowledge it
    lib.notify({
        title = 'Fishing',
        description = 'Fishing started! Use the rod to catch fish.',
        type = 'success'
    })
end)

-- Reset fishing state if player dies or disconnects
AddEventHandler('playerSpawned', function()
    isFishing = false
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        isFishing = false
    end
end)

