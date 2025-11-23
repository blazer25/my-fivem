Config = {}


------------------------------ BIKE IN CLUB HOUSE ------------------------------
Config.bike1 = {
    ['coords'] = vector4(2048.19, 4731.72, 41.16, 137.21),
    ['bike1'] =  'nightblade',
    ['plate'] = 'APOLLO', -- Make sure only 8 characters
}

r, g, b = 0, 0, 0  -- RGB Colour
x, y, z = 0, 0, 0  -- RGB Colour



    CreateThread(function()
        local model = GetHashKey(Config.bike1['bike1'])
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(0)
        end
        local veh = CreateVehicle(model, Config.bike1['coords'].x, Config.bike1['coords'].y, Config.bike1['coords'].z-0.5, false, false)
        SetModelAsNoLongerNeeded(model)
        SetEntityAsMissionEntity(veh, true, true)
        SetVehicleOnGroundProperly(veh)
        SetEntityInvincible(veh,true)
        SetVehicleDirtLevel(veh, 0.0)
        SetVehicleDoorsLocked(veh, 3)
        SetEntityHeading(veh,Config.bike1['coords'].w)
        SetVehicleCustomPrimaryColour(veh, r, g, b) -- bike1 colour
        SetVehicleCustomSecondaryColour(veh, r, g, b) -- bike1 colour
        SetVehicleExtraColours(veh, 1, 1)-- bike1 colour
        FreezeEntityPosition(veh, true)
        SetVehicleNumberPlateText(veh, Config.bike1['plate'])
    end)

------------------------------ CLEAR PEDS FROM AREA ------------------------------
CreateThread(function()
    while true do
        ClearAreaOfPeds(2034.01, 4698.57, 41.36, 20.0); 
        ClearAreaOfPeds(2080.9, 4755.12, 41.59, 10.0);
        -- ClearAreaOfVehicles(1452.67, -2605.99, 48.52, 15.0, false, false, false, false, false);
        Wait(100)
    end
end)

