local QBCore                  = exports[Config.CoreName]:GetCoreObject()

function VehicleKeys(plate, vehicle)
    Citizen.Wait(1000) -- leave this
    TriggerEvent("vehiclekeys:client:SetOwner", plate)

    if Config.HouseScriptName == "jpr-housing" then
        TriggerServerEvent("jpr-phonesystem:server:updateJPRHousingSystem", plate)
    end
end

function OpenPhone()
    if not PlayerData.metadata['ishandcuffed'] and not PlayerData.metadata['inlaststand'] and not PlayerData.metadata['isdead'] and not IsPauseMenuActive() then
        QBCore.Functions.TriggerCallback('jpr-phonesystem:server:verificarSlotPrimarioKey', function(serial, case)
            if (serial) then
                TriggerEvent("jpr-phonesystem:client:abrirtelemovel", serial.id, serial.name, case)
            end
        end)
    else
        QBCore.Functions.Notify(Config.Locales["56"], "error")
    end
end

local lanterna = false 
local lightIntensity = 10.0 
RegisterNUICallback('UtilizarLanterna', function()
    if lanterna == false then
        lanterna = true
        while lanterna do
            Citizen.Wait(0)
            local playerPed = PlayerPedId()
            local playerPos = GetEntityCoords(playerPed)
            local playerHeading = GetEntityHeading(playerPed)
        
           
            DrawSpotLight(playerPos.x, playerPos.y, playerPos.z, GetEntityForwardVector(playerPed), 255, 255, 255, 11.0, 1.0, 1.0, 10.0, 1.0)
        end
    else
        lanterna = false
    end
end)

RegisterNUICallback('LocalizarVeiculo', function(data, cb) -- function of valet anti spam (check current spawn of vehicle)
    local gameVehicles = QBCore.Functions.GetVehicles()
    local encontrou = false
    for i = 1, #gameVehicles do
        local vehicle = gameVehicles[i]
        if DoesEntityExist(vehicle) then
            if QBCore.Functions.GetPlate(vehicle) == data.veiculoaberto.plate then
                local vehCoords = GetEntityCoords(vehicle)
                SetNewWaypoint(vehCoords.x, vehCoords.y)
                encontrou = true
            end
        end
    end

    cb(encontrou)
end)

RegisterNetEvent('jpr-phonesystem:client:openPhoneSystem', function()
    OpenPhone()
end)

function SetFuel(infos, veh)
    SetVehiclePetrolTankHealth(veh, 1000.0)
    SetVehicleFuelLevel(veh, infos.fuel + 0.0)
    DecorSetFloat(veh, "_FUEL_LEVEL", GetVehicleFuelLevel(veh))
end

function GetPhonePropColor(phoneColor)
    local phoneColors = {
        phone = "scrlt_ifruit14max_03",
        phone_white = "scrlt_ifruit14max_04",
        phone_gold = "scrlt_ifruit14max_02",
        phone_red = "scrlt_ifruit14max_06",
        phone_blue = "scrlt_ifruit14max_05",
        phone_green = "scrlt_iphone14max_02",
        phone_pink = "scrlt_iphone14max_03",
        phone_green_light = "scrlt_iphone14max_01",
        phone_purple = "scrlt_ifruit14max_07",
        phone_purple_deep = "scrlt_ifruit14max_01"
    }
    
    return joaat(phoneColors[phoneColor] or "scrlt_ifruit14max_03")
end