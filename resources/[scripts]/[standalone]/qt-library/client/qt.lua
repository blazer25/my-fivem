---@diagnostic disable: missing-parameter
QT = {}
QT.PlayerInfo = {}
State = {}
State.ServerCallbacks = {}
State.CurrentRequestId = 0
QT.IsBusy = false
local contexts = {}
local openContextMenu = nil
---@field event? string
---@field serverEvent? string
---@field args? any

QT.AddCommand = function(name, handler, restricted)
    RegisterCommand(name, function(source, args, rawCommand)
        handler(args)
    end, restricted)
end

QT.CreateVehicle = function(data, cb)
    local playerPed = PlayerPedId()
    local vehicleHash = GetHashKey(data.model)
    RequestModel(vehicleHash)
    CreateThread(function()
        local waiting = 0
        while not HasModelLoaded(vehicleHash) do
            waiting = waiting + 100
            Wait(100)
            if waiting > 5000 then
                break
            end
        end
        if HasModelLoaded(vehicleHash) then
            local vehicle = CreateVehicle(vehicleHash, data.coords.x, data.coords.y, data.coords.z, data.coords.w, true, false)
            SetVehicleHasBeenOwnedByPlayer(vehicle, true)
            cb(vehicle)
        else
            cb(nil)
            print("qt-library [ERROR] : Vehicle model not exist")
        end
    end)
end

QT.InDistance = function(v, num)
    local ply = GetEntityCoords(PlayerPedId())
    local dist = #(ply - vector3(v.x, v.y, v.z))
    return dist <= num
end

QT.VehicleNearPoint = function(v, num)
local dist = IsAnyVehicleNearPoint(v.x, v.y, v.z, num)
    if dist then
        return true
    else
        return false
    end
end

QT.EntPos = function(entity)
    local info_data = { coords = GetEntityCoords(entity), heading = GetEntityHeading(entity) }
    return info_data
end

QT.RequestAnim = function(animDict)
    if not HasAnimDictLoaded(animDict) then
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Wait(100)
        end
    end
    return animDict
end

QT.RequestModel = function(model)
    RequestModel(GetHashKey(model))
    while not HasModelLoaded(model) do Wait(100) end
end

QT.Scenario = function(entity, scenario)
    TaskStartScenarioInPlace(entity, scenario, 0, true)
end

QT.TextUI = function(key, msg)
    SendNUIMessage({
        type = 'showTextUI',
        letter = key,
        description = msg
    })
end

QT.DisableUI = function()
    SendNUIMessage({
        type = 'hideTextUI',
    })
end

CreateThread(function()
    while true do
        Wait(0)
        if NetworkIsPlayerActive(PlayerId()) then
            TriggerServerEvent("qt-onPlayerLoad", GetPlayerServerId(PlayerId()))
            TriggerEvent("qt-onPlayerLoad", GetPlayerServerId(PlayerId()))
            break
        end
    end
end)

RegisterNetEvent("qt-onPlayerLoad")
 AddEventHandler("qt-onPlayerLoad", function(xPlayer)
    QT.PlayerInfo.playerId = xPlayer
    QT.PlayerInfo.Ped = PlayerPedId()
end)

function QT.TriggerServerCall(name, cb, ...)
    State.ServerCallbacks[State.CurrentRequestId] = cb

    TriggerServerEvent('qt:RegisterCallback', name, State.CurrentRequestId, ...)
    State.CurrentRequestId = State.CurrentRequestId < 65535 and State.CurrentRequestId + 1 or 0
end

RegisterNetEvent('qt:serverCallback')
AddEventHandler('qt:serverCallback', function(requestId, ...)
    State.ServerCallbacks[requestId](...)
    State.ServerCallbacks[requestId] = nil
end)

QT.Notify = function(data)
    SendNUIMessage({
        type = 'notification',
        notificationType = data.type,  -- 'success', 'error', 'warning', 'info', 'system'
        title = data.title,
        message = data.msg
    })
end

RegisterNetEvent('qt-library:SendAlert')
AddEventHandler('qt-library:SendAlert', function(data)
    QT.Notify(data)
end)

local controls = {
    INPUT_LOOK_LR = 1,
    INPUT_LOOK_UD = 2,
    INPUT_SPRINT = 21,
    INPUT_AIM = 25,
    INPUT_MOVE_LR = 30,
    INPUT_MOVE_UD = 31,
    INPUT_DUCK = 36,
    INPUT_VEH_MOVE_LEFT_ONLY = 63,
    INPUT_VEH_MOVE_RIGHT_ONLY = 64,
    INPUT_VEH_ACCELERATE = 71,
    INPUT_VEH_BRAKE = 72,
    INPUT_VEH_EXIT = 75,
    INPUT_VEH_MOUSE_CONTROL_OVERRIDE = 106,
    INPUT_CHARACTER_WHEEL = 19
}

QT.Progress = function(data)

        QT.IsBusy = true

        Animations(data.animation)

        SendNUIMessage({
            type = 'progress',
            description = data.description,
            duration = data.duration,
        })

        ExtensionsToogle(data.disabled)

end

RegisterNUICallback("onProgressCancel", function()
    QT.IsBusy = false
    ClearPedTasks(PlayerPedId())
end)

QT.IS_BUSY = function()
    if QT.IsBusy then
        return true
    else
        return false
    end
end

QT.SetBusy = function(boolean)
    QT.IsBusy = boolean
  --  print("Busy state changed for player by ID : "..GetPlayerServerId(PlayerId()))
end

ExtensionsToogle = function(disabled)

    while QT.IsBusy do

        if disabled.FreezePlayer then
            DisableControlAction(0, controls.INPUT_SPRINT, true)
            DisableControlAction(0, controls.INPUT_MOVE_LR, true)
            DisableControlAction(0, controls.INPUT_MOVE_UD, true)
            DisableControlAction(0, controls.INPUT_DUCK, true)
        end

        if disabled.MouseControl then
            DisableControlAction(0, controls.INPUT_LOOK_LR, true)
            DisableControlAction(0, controls.INPUT_LOOK_UD, true)
            DisableControlAction(0, controls.INPUT_VEH_MOUSE_CONTROL_OVERRIDE, true)
        end

        if disabled.Sprint and not disabled.FreezePlayer then
            DisableControlAction(0, controls.INPUT_SPRINT, true)
        end

        if disabled.Vehicle then
            DisableControlAction(0, controls.INPUT_VEH_MOVE_LEFT_ONLY, true)
            DisableControlAction(0, controls.INPUT_VEH_MOVE_RIGHT_ONLY, true)
            DisableControlAction(0, controls.INPUT_VEH_ACCELERATE, true)
            DisableControlAction(0, controls.INPUT_VEH_BRAKE, true)
            DisableControlAction(0, controls.INPUT_VEH_EXIT, true)
        end

        if disabled.target then
            ExecuteCommand('-ox_target', disableTargeting, false)
        end

        if not QT.IsBusy then
            break
        end

      Wait(0)

    end

end

Animations = function(anim)
    if anim ~= nil then
        if anim.dict and anim.animation then
            QT.RequestAnim(anim.animation)
            TaskPlayAnim(PlayerPedId(), anim.animation, anim.dict, 8.0, -8.0, -1, 2, 0, false, false, false)
        end
        if anim.scenario then
            QT.Scenario(PlayerPedId(), anim.scenario)
        end
    end
end

QT.RegisterContextIndex = function(data)
    if not data then
        print("Data is missing for RegisterContextIndex")
        return
    end
    contexts[data.menu_id] = data
end

QT.ShowContext = function(contextId)
    local data = contexts[contextId]
    if not data then
        print("No context found for ID: " .. tostring(contextId))
        return
    end
    openContextMenu = contextId
    SendNUIMessage({
        action = "ShowContext",
        header = data.header,
        back = data.back, 
        options = data.options,
    })
    SetNuiFocus(true, true)
    QT.SetBusy(true)
end

QT.RemoveContext = function()
    SendNUIMessage({
        action = "RemoveContext",
     })
     SetNuiFocus(false, false)
     QT.SetBusy(false)
end

--[[QT.RegisterContextIndex({
    menu_id = "test",
    header = "NASLOV TEST",
    options = {
        {
            title = "Test polje 1",
            description = "testic deskripcije 1",
            icon = "fas fa-star",
            arrow = false, 
            event = "kuracv"
        },
        {
            title = "Test polje 2",
            description = "testic deskripcije 2",
            icon = "fa-solid fa-plane-slash",
            arrow = true, 
            event = "kuracv"
        },
    }
})]]

RegisterNUICallback("RemoveContext", function()
    QT.RemoveContext()
    QT.SetBusy(false)
end)

RegisterNUICallback("ShowContext", function(data)
    QT.ShowContext(data.contextId)
end)

RegisterNUICallback('onClick', function(data, cb)
    local id = tonumber(data.id)
    if not id then
        print("Invalid ID received in onClick callback.")
        return
    end

    local context = contexts[openContextMenu] 
    if not context or not context.options or not context.options[id + 1] then
        print("No context or option found for ID: " .. tostring(id))
        return
    end

    local option = context.options[id + 1] 


    if option.event then
        TriggerEvent(option.event, option.args)
    end

    if option.serverEvent then
        TriggerServerEvent(option.serverEvent, option.args)
    end

    QT.RemoveContext()

end)

local box

QT.CreateBox = function(title, data)
    box = promise.new()  
    SendNUIMessage({
        action = "openBox",
        title = title, 
        info = data
    })
    SetNuiFocus(true, true)

    return Citizen.Await(box)
end

RegisterNUICallback("closeBox", function(_, cb)
    if box then
        box:resolve(nil) 
        box = nil  
    end
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('submitForm', function(data, cb)
    SetNuiFocus(false, false)
    if box then
        box:resolve(data) 
        box = nil 
    end
    cb('ok')
end)

--[[RegisterCommand("testiccc", function()
    local formData = QT.CreateBox("Test Form", {
        { label = 'First Name', type = 'input', required = true },
        { label = 'Last Name', type = 'input', required = true },
        { label = 'Email', type = 'input', required = true },
        { label = 'Date of Birth', value = '', type = 'date', required = true, min = "2023-01-01", max = "2024-12-31" },
        { label = 'Age', type = 'number', min = 1, max = 99, required = true },  
        { label = 'Select Option', options = { 'Option 1', 'Option 2', 'Option 3' }, type = 'select' },
        { label = 'Test Checkbox', value = 'checkbox', type = 'checkbox' },
    })

    if formData then
        print(json.encode(formData))  
    else
        print("Form was canceled or closed.")
    end

end)]]

local question 

QT.Question = function(data)
    question = promise.new()  

    SendNUIMessage({
        action = "QuestionBox",
        title = data.title, 
        question = data.question,
        disclaimer = data.disclaimer
    })
    SetNuiFocus(true, true) 

    return Citizen.Await(question)
end

--[[RegisterCommand("beba", function()
    QT.CloseQuestion()
end)]]

RegisterNUICallback("closeQuestion", function(data, cb)
    if question then
        question:resolve(data.result) 
        question = nil  
    end
    SetNuiFocus(false, false)
    cb('ok')
end)

QT.CloseQuestion = function()
   SendNUIMessage({
      action = "CloseBox"
   })
end

