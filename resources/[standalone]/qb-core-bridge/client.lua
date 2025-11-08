local function safeSetProps(veh, props)
    if not props then return end
    local ok = pcall(function()
        if QBCore and QBCore.Functions and QBCore.Functions.SetVehicleProperties then
            QBCore.Functions.SetVehicleProperties(veh, props)
        end
    end)
    if not ok then
        print('[qb-core-bridge] Note: SetVehicleProperties not available; skipping props.')
    end
end

RegisterNetEvent('qb-core-bridge:client:spawnVehicle', function(model, plate, props)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    if type(model) == 'string' then model = joaat(model) end
    if not IsModelInCdimage(model) or not IsModelAVehicle(model) then
        print(('[qb-core-bridge] Invalid vehicle model: %s'):format(tostring(model)))
        return
    end

    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local veh = CreateVehicle(model, pos.x + 2.0, pos.y, pos.z, heading, true, false)
    SetPedIntoVehicle(ped, veh, -1)
    SetVehicleNumberPlateText(veh, plate or 'ADMIN')
    SetEntityAsMissionEntity(veh, true, true)

    safeSetProps(veh, props)

    SetModelAsNoLongerNeeded(model)
    print(('[qb-core-bridge] Vehicle spawned: %s'):format(tostring(model)))
end)