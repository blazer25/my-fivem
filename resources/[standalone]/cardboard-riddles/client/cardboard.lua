print('[Cardboard-Riddles] Client script loaded')

local function showCardboardImage(image)
    print('[Cardboard] Showing image:', image)
    SendNUIMessage({
        action = 'showCardboard',
        image = image
    })
    SetNuiFocus(true, true)
end

-- ox_inventory uses TriggerEvent (local event), not network event
AddEventHandler('cardboard:read', function(data, itemData)
    print('[Cardboard] Event triggered!')
    if data then print('[Cardboard] Data received') end
    if itemData then 
        print('[Cardboard] ItemData:', itemData.name or 'no name')
        if itemData.metadata then
            print('[Cardboard] Metadata:', json.encode(itemData.metadata))
        end
    end
    
    -- Check metadata to determine which image to show
    local metadata = itemData and itemData.metadata or {}
    local imageType = metadata.type or 'password' -- default to password
    
    print('[Cardboard] Image type:', imageType)
    
    if imageType == 'location' then
        showCardboardImage('backmarket-location.png')
    else
        showCardboardImage('backmarket-password.png')
    end
end)

RegisterNUICallback('closeCardboard', function()
    print('[Cardboard] Closing NUI')
    SetNuiFocus(false, false)
end)

