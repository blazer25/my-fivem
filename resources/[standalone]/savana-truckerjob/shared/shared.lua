shared = {}
shared.Locale = "en" -- "en" , "tr"
shared.Framework = "auto" -- qb, qbold, esx, esxold, custom, auto
shared.UseTarget = true
shared.debug = false
shared.infoText = true
shared.customKey = true -- Custom Vehicle Keys

shared.TruckerJob = {
    [1] = {
        ped = "a_m_m_genfat_02",
        pedCoords = vector4(839.2369, -2923.8972, 5.8920, 279.8569),
        blip = {
            size = 0.7,
            color = 3,
            sprite = 477,
            text = "Trucker Job",
            blipname = "Trucker Job",
        },
        Jobs = {
            {
                level = 1, xp = 25,
                imgSrc = 'images/trailers/tanker.png',
                name = 'Fuel Tanker XL', type = 'ADR 3', 
                vehicles = {'phantom3', 'tanker'}, totalPrice = 70, 
                start = { vector3(852.97, -2905.25, 5.97), 180.05}, 
                trailer = {vector3(861.22, -2908.3, 5.97), 180.37}, 
                arrive = vector3(-969.0496, -2899.3401, 14.0317)
            },
            {
                level = 5, xp = 50,
                imgSrc = 'images/trailers/trailerlogs.png',
                name = 'Timber Haul', type = 'NO ADR',
                vehicles = {'phantom', 'trailerlogs'}, totalPrice = 140, 
                start = { vector3(852.97, -2905.25, 5.97), 180.05}, 
                trailer = {vector3(861.22, -2908.3, 5.97), 180.37}, 
                arrive = vector3(1385.0824, -742.9412, 67.1472)
            },
            {
                level = 10, xp = 75,
                imgSrc = 'images/trailers/trailers4.png',
                name = 'Clothing Materials', type = 'NO ADR',
                vehicles = {'phantom3', 'trailers4'}, totalPrice = 210, 
                start = { vector3(852.97, -2905.25, 5.97), 180.05}, 
                trailer = {vector3(861.22, -2908.3, 5.97), 180.37}, 
                arrive = vector3(725.4348, -983.8358, 24.2330)
            },
            {
                level = 15, xp = 100,
                imgSrc = 'images/trailers/docktrailer.png',
                name = 'Ammunition', type = 'ADR 1',
                vehicles = {'phantom', 'docktrailer'}, totalPrice = 650, 
                start = { vector3(852.97, -2905.25, 5.97), 180.05}, 
                trailer = {vector3(861.22, -2908.3, 5.97), 180.37}, 
                arrive = vector3(-3171.3262, 1109.1091, 20.8950)
            },
            {
                level = 20, xp = 125,
                imgSrc = 'images/trailers/trailers.png',
                name = 'Mining Materials', type = 'NO ADR',
                vehicles = {'phantom', 'trailers'}, totalPrice = 750, 
                start = { vector3(852.97, -2905.25, 5.97), 180.05}, 
                trailer = {vector3(861.22, -2908.3, 5.97), 180.37}, 
                arrive = vector3(2977.2314, 2756.8716, 43.0334)
            },
            {
                level = 25, xp = 150,
                imgSrc = 'images/trailers/tr4.png',
                name = 'Used Cars', type = 'NO ADR',
                vehicles = {'phantom3', 'tr4'}, totalPrice = 900, 
                start = { vector3(852.97, -2905.25, 5.97), 180.05}, 
                trailer = {vector3(861.22, -2908.3, 5.97), 180.37}, 
                arrive = vector3(1221.25, 2709.15, 38.08)
            },
            {
                level = 30, xp = 200,
                imgSrc = 'images/trailers/trailers3.png',
                name = 'Frozen Chicken', type = 'NO ADR',
                vehicles = {'phantom', 'trailers3'}, totalPrice = 2000, 
                start = { vector3(852.97, -2905.25, 5.97), 180.05}, 
                trailer = {vector3(861.22, -2908.3, 5.97), 180.37}, 
                arrive = vector3(-61.2230, 6276.7446, 31.4082)
            },
         },
    },
}

shared.Locales = {
    ['open_job'] = '[E] - Trucker Job',
    ['open_job_target'] = 'Trucker Job',
    ['cancel_job'] = '[E] - Cancel Job',
    ['cancel_job_target'] = 'Cancel Job',
    ['destination'] = 'Destination',
    ['get_to_truck'] = 'Go to ~y~Truck~w~',
    ['truck'] = 'Truck',
    ['trailer'] = 'Trailer',
    ['get_to_trailer'] = 'Get ~y~Trailer~w~ at the marked location',
    ['detach'] = 'Detach ~y~Trailer~w~ [H].',
    ['park'] = 'Park ~y~Trailer~w~ at destination point',
    ['drive_destination'] = 'Deliver the load to the marked location',
    ['get_out'] = 'Get off the truck and hand over the truck',
    ['park_truck'] = 'Park at Destination ~y~Truck~w~ .',
    ['drive_back'] = 'Drive back to the company and deliver the ~y~Truck~w~',
    ['vehicle_spawn'] = "The vehicle didn't spawn! Area full",
    ['completed'] = "Mission completed.",
    ['exp'] = " Exp: ",
    ['money'] = " Money: $",
}

-- Auto Framework Detection
if shared.Framework == "auto" then
    if GetResourceState("qb-core") == "started" then
        shared.Framework = "qb"
    elseif GetResourceState("es_extended") == "started" then
        shared.Framework = "esx"
    else
        print("Couldn't find a framework. Using custom framework.")
        shared.Framework = "custom"
    end
end

-- Framework Object
if shared.Framework == "qb" or shared.Framework == "QB" or shared.Framework == "qb-core" then
    shared.Framework = "qb"
    FrameworkObject = exports['qb-core']:GetCoreObject()
elseif shared.Framework == "qbold" then
    FrameworkObject = nil
    shared.Framework = "qb"
    
    Citizen.CreateThread(function()
        while FrameworkObject == nil do
            TriggerEvent('QBCore:GetObject', function(obj) FrameworkObject = obj end)
            Citizen.Wait(50)
        end
    end)
elseif shared.Framework == "esx" or shared.Framework == "ESX" or shared.Framework == "es_extended" then
    shared.Framework = "esx"
    FrameworkObject = exports['es_extended']:getSharedObject()
elseif shared.Framework == "esxold" then
    FrameworkObject = nil
    shared.Framework = "esx"

    Citizen.CreateThread(function()
        while FrameworkObject == nil do
            TriggerEvent('esx:getSharedObject', function(obj) FrameworkObject = obj end)
            Citizen.Wait(50)
        end
    end)
elseif shared.Framework == 'auto' then
    if GetResourceState('qb-core') == 'started' then
        FrameworkObject = exports['qb-core']:GetCoreObject()
        shared.Framework = "qb"
    elseif GetResourceState('es_extended') == 'started' then
        FrameworkObject = exports['es_extended']:getSharedObject()
        shared.Framework = "esx"
    end

else
    shared.Framework = "custom"
    -- Write your own code shared object code.
    FrameworkObject = nil
end

