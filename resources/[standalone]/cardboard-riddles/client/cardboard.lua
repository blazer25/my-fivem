local function showCardboardImage(image)
    SendNUIMessage({
        action = 'showCardboard',
        image = image
    })
    SetNuiFocus(true, true)
end

RegisterNetEvent('cardboard:read', function()
    print('[Cardboard] Event triggered - showing image')
    -- Default to password image
    -- You can modify this to check metadata if needed
    showCardboardImage('backmarket-password.png')
end)

RegisterNUICallback('closeCardboard', function()
    SetNuiFocus(false, false)
end)

