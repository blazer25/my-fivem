shared = {}
shared.Locale = "en" -- "en", "ar", de, es, fr, hi, it, jp, ku, pt, ru, th, tr, zh
shared.Framework = "auto" -- qb, qbold, esx, esxold, custom, auto
shared.onlyUseTarget = false -- shared.onlyUseTargetwithNpc  must be false when this is activated
shared.onlyUseTargetwithNpc = true -- shared.onlyUseTarget  must be false when this is activated
shared.weightPrice = 10 -- 1 kg price
shared.capacityPrice = 10 --1x slot Price
shared.storagePrice = 1000 --storage price
shared.debug = false

shared.Storage = {
    [1] = {
        ped = "a_m_m_genfat_02",
        pedCoords = vector4(1183.9828, -3303.8513, 7.0960, 93.5404),
        blip = { -- To close the blip, in c_framework.lua, delete line 195 through line 218 or put it in the comment line.
            size = 0.7,
            color = 3,
            sprite = 473,
            text = "Storage",
            blipname = "Storage",
        }
    },
}

shared.Locales = {
    ["open_storage"] = "[E] - Open Storage",
    ["open_storage_target"] = "Open Storage",
    ["already_name"] = 'The repository name already exists. Please choose another name.',
    ["succes_purchase"] = 'The repository was successfully purchased.',
    ["notenough_money"] = "You don't have enough money",
    ["removeFavorite"] = 'Repository removed from favorites',
    ["addFavorite"] = 'Repository added to favorites',
    ["passchanged"] = 'Password changed, log in again!',
    ["errorpass"] = 'The password is wrong!',
    ["errorpasschanged"] = 'The password has not been changed. The old password is wrong!',
    ["errorlimit"] = 'It must be a value higher than 0!',
    ["noAccess"] = 'You are not allowed to change your password!',
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
else
    shared.Framework = "custom"
    -- Write your own code shared object code.
    FrameworkObject = nil
end

