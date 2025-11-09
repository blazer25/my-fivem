return {
    ---@type function
    ---@param title string
    ---@param message string
    ---@param type string
    ---@param duration number
    notify = function(title, message, type, duration)
        lib.notify({
            title = title,
            description = message,
            type = type,
            duration = duration,
            position = 'top'
        })
    end,

    ---@type function
    ---@param show boolean
    ---@param message? string
    helpText = function(show, message)
        if show then
            lib.showTextUI(message)
        else
            lib.hideTextUI()
        end
    end,

    ---@type Location
    location = {
        coords = vec4(838.0568, -1395.9075, 26.3134, 358.0418)
    },

    ---@type TrackSetting
    track = {
        model = 'prop_mp_cone_02',
        disableCollision = false
    },

    ---@type BlipSettings
    blipPoint = {
        enable = true, -- Enable/Disable blips
        show = 3,      -- Blip showing on the map
        settings = {
            sprite = 1,
            scale = 1.0,
            colour = 3
        }
    },

    blipSchool = {
        enable = true,
        settings = {
            sprite = 408,
            scale = 1.0,
            colour = 4
        }
    },

    ---@type boolean
    backLastPoint = false, -- Return to last point when error point is reached

    ---@type number
    waitDistance = 10.0, -- Wait distance between waiting list

    ---@type number
    waitNotify = 5, -- how many times to notify

    ---@type number
    waitNotifyInterval = 5000, -- Wait notification interval

    ui = {
        currency = 'EUR',
    },

    target = false,             -- Enable/Disable target

    pedModel = 's_m_y_cop_01', -- ped model to spawn

    giveKey = function(vehicle)
        local plate = GetVehicleNumberPlateText(vehicle)
        if GetResourceState('qb-vehiclekeys') == 'started' then
            TriggerEvent('qb-vehiclekeys:client:AddKeys', plate)
        elseif GetResourceState('Renewed-Vehiclekeys') == 'started' then
            exports['Renewed-Vehiclekeys']:addKey(plate)
        elseif GetResourceState('dusa_vehiclekeys') == 'started' then
            exports['dusa_vehiclekeys']:AddKey(plate)
        elseif GetResourceState('wasabi_carlock') == 'started' then
            exports.wasabi_carlock:GiveKey(plate)
        end
    end,

    removeKey = function(vehicle)
        local plate = GetVehicleNumberPlateText(vehicle)
        if GetResourceState('qb-vehiclekeys') == 'started' then
            TriggerEvent('qb-vehiclekeys:client:RemoveKeys', plate)
        elseif GetResourceState('wasabi_carlock') == 'started' then
            exports.wasabi_carlock:RemoveKey(plate)
        elseif GetResourceState('Renewed-Vehiclekeys') == 'started' then
            exports['Renewed-Vehiclekeys']:removeKey(plate)
        end
    end,

    setFuel = function(vehicle)
        if GetResourceState('ox_fuel') == 'started' then
            Entity(vehicle).state.fuel = 100
        elseif GetResourceState('cdn-fuel') == 'started' then
            exports["cdn-fuel"]:SetFuel(vehicle, 100)
        end
    end
}
