core = nil
framework = nil

cfg = {
    -- Company Settings
    company = {
        ped = 's_m_m_lifeinvad_01',
        location = vector4(-1269.11, -1153.96, 6.79, 113.99),
        name = 'G9 Clean Co.',
        blipSize = 0.7,
        blipColor = 3,
        blipSprite = 594,
        jobVehicle = 'sadler',
        vehicleLocation = vector4(-1273.15, -1158.42, 5.91, 113.52),
        returnCar = vector3(-1283.38, -1155.57, 5.67)
    },


    lang = 'en',

    carFine = 300,

    useTarget = true,

    cancelCommand = 'canceljob'
}



function vehicleKey()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    local plate = GetVehicleNumberPlateText(vehicle)
    Wait(1000)
    TriggerEvent('vehiclekeys:client:SetOwner', plate)
end


if GetResourceState('qb-core') == 'started' then
    framework = true
    core = exports['qb-core']:GetCoreObject()
elseif GetResourceState('qbx_core') == 'started' then
    framework = true
    core = exports['qb-core']:GetCoreObject()
elseif GetResourceState('es_extended') == 'started' then
    framework = false
    core = exports['es_extended']:getSharedObject()
end


function notify(text,types)
    if framework then
        core.Functions.Notify(text,types)
    else
        core.ShowHelpNotification(text,types)
    end
end



