local properties = nil

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    Wait(1000)
    SendNUIMessage({
        action = "SET_STYLE",
        data = "default"
    })
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    SendNUIMessage({
        action = "SET_STYLE",
        data = "default"
    })
end)

RegisterNUICallback("buttonSubmit", function(data, cb)
    SetNuiFocus(false)
    properties:resolve(data.data)
    properties = nil
    cb("ok")
end)

RegisterNUICallback("closeInput", function(_, cb)
    SetNuiFocus(false)

    properties:resolve(nil)
    properties = nil
    cb("ok")
end)

local function ShowInput(data)
    Wait(150)
    if not data then return end
    if properties then return end

    properties = promise.new()

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "OPEN_INPUT",
        data = data
    })

    return Citizen.Await(properties)
end

exports("ShowInput", ShowInput)
