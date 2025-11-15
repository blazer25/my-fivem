local areaRadius = 50.0
local certianArea = vector3(978.0613, -120.729042, 73.25029)

-- Remove peds within the radius
AddEventHandler('populationPedCreating', function(x, y, z, model, setters)
    if #(certianArea - vector3(x, y, z)) < areaRadius then
        CancelEvent()
    end
end)
Citizen.CreateThread(function()
    -- Coordinates, heading, model, and color configurations for the bikes
    local bikes = {
        {
            x = 1000.56561, y = -126.296188, z = 73.61, heading = 60.0, model = "nightblade",
            primaryColor = 150, secondaryColor = 131, -- Example colors: Black and Red
            wheelColor = 131 -- Example wheel color: Silver
        },
        {
            x = 1002.56561, y = -128.2, z = 73.61, heading = 60.0, model = "avarus",
            primaryColor = 150, secondaryColor = 131, -- Example colors: Blue and Yellow
            wheelColor = 131 -- Example wheel color: Red
        }
    }

    -- Function to load the vehicle model
    local function LoadModel(model)
        local hash = GetHashKey(model)
        RequestModel(hash)
        while not HasModelLoaded(hash) do
            Citizen.Wait(0)
        end
        return hash
    end

    -- Iterate through bike configurations
    for _, bike in ipairs(bikes) do
        -- Load the bike model
        local bikeModel = LoadModel(bike.model)

        -- Create the bike
        local vehicle = CreateVehicle(bikeModel, bike.x, bike.y, bike.z, bike.heading, false, false)

        -- Customize the bike's colors
        SetVehicleColours(vehicle, bike.primaryColor, bike.secondaryColor)
        SetVehicleExtraColours(vehicle, bike.wheelColor, 0) -- Apply wheel color (secondary pearl color left as 0)

        -- Make the bike non-drivable and immovable
        SetVehicleDoorsLocked(vehicle, 2) -- Lock doors
        FreezeEntityPosition(vehicle, true) -- Freeze position to prevent movement
        SetEntityInvincible(vehicle, true) -- Make it indestructible
        SetVehicleUndriveable(vehicle, true) -- Disable driving

        -- Cleanup model to free memory
        SetModelAsNoLongerNeeded(bikeModel)
    end
end)
