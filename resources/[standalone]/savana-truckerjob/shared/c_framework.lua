Framework = {}
currentZone = nil



if GetResourceState('qbx_core') == 'started' then
    shared.Framework = "qb"
end

function Framework:GetIdentifier()
    if shared.Framework == "qb" then
        return FrameworkObject.Functions.GetPlayerData().citizenid
    elseif shared.Framework == "esx" then
        return FrameworkObject.GetPlayerData().identifier
    else
        -- Write your own code.
        return nil
    end
end

function Framework:Notify(msg, tip)
    if shared.Framework == "qb" then
        return FrameworkObject.Functions.Notify(msg, tip, 2500)
    elseif shared.Framework == "esx" then        
        return FrameworkObject.ShowNotification(msg,tip, 2500)
    else
        -- Write your own code.
        return nil
    end
end


function Framework:removeKey(vehicle,trailer)
    print(vehicle.. ' ve ' ..trailer.. ' anahtarı silindi')
end

function Framework:SpawnClear(data,count)
    if shared.Framework == "qb" then
        return FrameworkObject.Functions.SpawnClear(data,count)
    elseif shared.Framework == "esx" then        
        return FrameworkObject.Game.IsSpawnPointClear(data,count)
    else
        -- Write your own code.
        return nil
    end
end

loadVehicle = function(modelName, coords, heading)
    local model = modelName or 'mule'
    if type(model) ~= 'number' then model = joaat(model) end

    if not IsModelInCdimage(model) then
        Framework:Notify('Invalid vehicle model: '..tostring(modelName), 'error')
        print('[TruckerJob] Model not found:', modelName)
        return nil
    end

    -- Qbox-safe model loading
    if lib and lib.requestModel then
        if not lib.requestModel(model, 10000) then
            Framework:Notify('Failed to load model '..tostring(modelName), 'error')
            return nil
        end
    else
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(50) end
    end

    if not coords or not coords.x then
        coords = vec4(-422.0, -2787.5, 6.0, 315.0)
    end

    -- Create vehicle
    local veh = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w or heading or 0.0, true, true)
    local netId = NetworkGetNetworkIdFromEntity(veh)
    SetNetworkIdCanMigrate(netId, true)
    SetEntityAsMissionEntity(veh, true, true)
    SetVehicleOnGroundProperly(veh)
    SetVehicleNumberPlateText(veh, 'TRUCK')
    SetVehicleDirtLevel(veh, 0.0)
    TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
    SetModelAsNoLongerNeeded(model)

    -- Fuel support
    if GetResourceState('cdn-fuel') == 'started' then
        exports['cdn-fuel']:SetFuel(veh, 100.0)
    elseif GetResourceState('LegacyFuel') == 'started' then
        exports['LegacyFuel']:SetFuel(veh, 100.0)
    elseif GetResourceState('ox_fuel') == 'started' then
        Entity(veh).state.fuel = 100
    end

    Framework:Notify('Vehicle spawned: '..tostring(modelName), 'success')
    print('[TruckerJob] Vehicle spawned successfully:', modelName)
    return veh
end

RegisterNetEvent('trucker:spawnTruckAndTrailer', function(truckModel, trailerModel, startCoords, trailerCoords)
    local ped = PlayerPedId()
    local truck = loadVehicle(truckModel, startCoords)
    if not truck then
        Framework:Notify('Truck failed to spawn', 'error')
        return
    end

    Wait(1500) -- short delay for physics

    local trailer = loadVehicle(trailerModel, trailerCoords)
    if not trailer then
        Framework:Notify('Trailer failed to spawn', 'error')
        return
    end

    Wait(1000)
    AttachVehicleToTrailer(truck, trailer, 1.0)

    Framework:Notify('Truck and trailer ready — drive safely!', 'success')
    print('[TruckerJob] Truck + Trailer spawned and attached')
end)

function fuel(car)
    if GetResourceState('savana-fuel') == 'started' then
        return exports['savana-fuel']:SetFuel(car, 100.0)
    end
    if GetResourceState('cdn-fuel') == 'started' then
        return exports.cdn-fuel:SetFuel(car, 100.0)
    end
    if GetResourceState('cdn-fuel') == 'started' then
        return exports['cdn-fuel']:SetFuel(car, 100.0)
    end
    if GetResourceState('ox_fuel') == 'started' then
        return Entity(car) and Entity(car).state and Entity(car).state.fuel or 100
    end
end

for k, v in pairs(shared.TruckerJob) do
    if shared.UseTarget then
        RequestModel(v.ped)
        while not HasModelLoaded(v.ped) do
            Wait(0)
        end
        local ped = CreatePed(4, GetHashKey(v.ped), v.pedCoords.x, v.pedCoords.y, v.pedCoords.z -1, v.pedCoords.w, false, false)
        SetEntityHeading(ped, v.pedCoords.w)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetPedDiesWhenInjured(ped, false)
        SetPedCanRagdoll(ped, false)

        if GetResourceState('ox_target') == 'started' then
            local coord = v.pedCoords
            exports.ox_target:addBoxZone({
                coords = vector3(coord.x,coord.y,coord.z),
                size = vec3(1, 1, 2),
                rotation = 0,
                debug = shared.debug,
                distance = 2.5,
                options = {
                    {
                        name = "openTruckerMenu",
                        label = shared.Locales["open_job_target"],
                        icon = "fas fa-briefcase",
                        onSelect = function()
                            currentZone = k
                            OpenTruckerMenu()
                        end,
                        canInteract = function(entity, distance, data)
                            return not working 
                        end,
                    },
                    {
                        name = 'cancel_mission',
                        label = shared.Locales["cancel_job_target"],
                        icon = "fas fa-truck",
                        onSelect = function(data)
                            endMission()
                        end,
                        canInteract = function(entity, distance, data)
                            return working 
                        end,
                    },
                },
            })
        else
            exports['qb-target']:AddTargetEntity(ped, {
                options = {
                    {
                        label = shared.Locales["open_job_target"],
                        icon = "fas fa-briefcase",
                        action = function()
                            currentZone = k
                            OpenTruckerMenu()
                        end,
                        canInteract = function()
                            if not working then 
                                return true
                            end
                        end,
                    },
                    {
                        action = function()
                            endMission()
                        end,
                        icon = 'fas fa-truck',
                        label = shared.Locales["cancel_job_target"],
                        canInteract = function()
                            if working then 
                                return true
                            end
                        end,
                    },
                },
                distance = 2.0
            })
        end
    else
        local coords = vector3(v.pedCoords.x, v.pedCoords.y, v.pedCoords.z)
        
        Citizen.CreateThread(function()

            while true do
                wait = 1000
                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)
                local coords = vector3(v.pedCoords.x, v.pedCoords.y, v.pedCoords.z)
                local distance = #(playerCoords - coords)

                if distance < 18.0 then
                    currentZone = k
                    HandleDealerZone(v.pedCoords)
                    wait = 0
                end
                Citizen.Wait(wait)
            end
        end)
    end
end

function HandleDealerZone(_coords)
    coords = vector3(_coords.x, _coords.y, _coords.z)
    if menuOpened then return end

    local ped = PlayerPedId()
    local playerCoords = GetEntityCoords(ped)
    local distance = #(playerCoords - coords)

    if distance < 18.0 then
        DrawMarker(1, coords.x, coords.y, coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 0.5, 255, 255, 0, 100, false, true, 2, true, nil, nil, false)
        if distance < 1.5 then
            if not working then
                Draw3DText(coords.x, coords.y, coords.z + 0.4, shared.Locales["open_job"])
                if IsControlJustReleased(0, 38) then
                    OpenTruckerMenu()
                end
            else
                Draw3DText(coords.x, coords.y, coords.z + 0.4, shared.Locales["cancel_job"])
                if IsControlJustReleased(0, 38) then
                    endMission()
                end
            end
        end
    end
end

RegisterNetEvent('savana-trucker:client:sendNotifys',function(msg, tipim)
    Framework:Notify(msg, tipim)
end)


function Draw3DText(x, y, z, Text)
	if Text then
		SetTextScale(0.35, 0.35)
		SetTextFont(4)
		SetTextProportional(1)
		SetTextColour(255, 255, 255, 215)
		SetTextEntry("STRING")
		SetTextCentre(true)
		AddTextComponentString(Text)
		SetDrawOrigin(x, y, z, 0)
		DrawText(0.0, 0.0)
		local Factor = (string.len(Text)) / 370
		DrawRect(0.0, 0.0 + 0.0125, 0.017 + Factor, 0.03, 0, 0, 0, 75)
		ClearDrawOrigin()
	end
end

function createBlips()
    for _, trucker in pairs(shared.TruckerJob) do
        local blip = AddBlipForCoord(trucker.pedCoords.x, trucker.pedCoords.y, trucker.pedCoords.z)

        SetBlipSprite(blip, trucker.blip.sprite) 
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, trucker.blip.size)
        SetBlipColour(blip, trucker.blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(trucker.blip.text)
        EndTextCommandSetBlipName(blip)
    end
end

if shared.Framework == 'esx' or shared.Framework == 'esxold' then
    RegisterNetEvent('esx:playerLoaded', function()
        createBlips()
    end)
else
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        createBlips()
    end)
end