local function showCardboardImage(image)
    SendNUIMessage({
        action = 'showCardboard',
        image = image
    })
    SetNuiFocus(true, true)
end

RegisterNetEvent('cardboard:password', function()
    showCardboardImage('backmarket-password.png')
end)

RegisterNetEvent('cardboard:location', function()
    showCardboardImage('backmarket-location.png')
end)

RegisterNUICallback('closeCardboard', function()
    SetNuiFocus(false, false)
end)

