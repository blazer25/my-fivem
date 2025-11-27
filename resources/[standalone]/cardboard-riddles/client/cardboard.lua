print('[Cardboard-Riddles] Client script loaded')

local function showCardboardImage(image)
    SendNUIMessage({
        action = 'showCardboard',
        image = image
    })
    SetNuiFocus(true, true)
end

-- ox_inventory uses TriggerEvent (local event), not network event
AddEventHandler('cardboard:read', function(data, itemData)
    if not itemData then return end
    
    local itemName = itemData.name or ''
    
    -- Determine which image based on item name
    if itemName == 'cardboard-location' then
        showCardboardImage('blackmarket-location.png')
    else
        -- Default to password for 'cardboard' item
        showCardboardImage('blackmarket-password.png')
    end
end)

RegisterNUICallback('closeCardboard', function()
    SetNuiFocus(false, false)
end)

