Framework = {}
currentZone = nil

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
        return FrameworkObject.ShowNotification(msg,tip)
    else
        -- Write your own code.
        return nil
    end
end

function Framework:GetVehicleProperties(vehicle)
    if shared.Framework == "qb" then
        return FrameworkObject.Functions.GetVehicleProperties(vehicle)
    elseif shared.Framework == "esx" then
        return FrameworkObject.Game.GetVehicleProperties(vehicle)
    else
        -- Write your own code.
        return nil
    end
end

for k, v in pairs(shared.Storage) do
    if shared.onlyUseTargetwithNpc then
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
                        name = "OpenStorageMenu",
                        label = shared.Locales["open_storage_target"],
                        icon = "fas fa-briefcase",
                        onSelect = function()
                            currentZone = k
                            OpenStorageMenu()
                        end,
                    },
                },
            })
        else
            exports['qb-target']:AddTargetEntity(ped, {
                options = {
                    {
                        label = shared.Locales["open_storage_target"],
                        icon = "fas fa-briefcase",
                        action = function()
                            currentZone = k
                            OpenStorageMenu()
                        end
                    }
                },
                distance = 2.0
            })
        end
    elseif not shared.onlyUseTarget and not shared.onlyUseTargetwithNpc then
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
    elseif shared.onlyUseTarget then
        if GetResourceState('ox_target') == 'started' then
            exports.ox_target:addBoxZone({
                coords = vector3(v.pedCoords.x,v.pedCoords.y,v.pedCoords.z),
                size = vec3(1, 1, 2),
                rotation = 0,
                debug = shared.debug,
                distance = 2.5,
                options = {
                    {
                        name = "OpenStorageMenu",
                        label = shared.Locales["open_storage_target"],
                        icon = "fas fa-briefcase",
                        onSelect = function()
                            currentZone = k
                            OpenStorageMenu()
                        end,
                    },
                },
            })
        else
            exports['qb-target']:AddBoxZone("storage_zone", vector3(v.pedCoords.x,v.pedCoords.y,v.pedCoords.z), 2.0, 2.0, {
            name = "storage_zone",
            heading = 0,
            debugPoly = false,
            minZ = 0,
            maxZ = 1000,
        }, {
            options = {
                {
                    label = shared.Locales["open_storage_target"],
                    icon = "fas fa-briefcase",
                    action = function()
                        currentZone = "storage_zone"
                        OpenStorageMenu()
                    end
                }
            },
            distance = 2.0
        })
        end
    end
end

function HandleDealerZone(_coords)
    coords = vector3(_coords.x, _coords.y, _coords.z)
    if menuOpened then return end

    local ped = PlayerPedId()
    local playerCoords = GetEntityCoords(ped)
    local distance = #(playerCoords - coords)

    if distance < 18.0 then
        DrawMarker(1, pedCoords.x, pedCoords.y, pedCoords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 0.5, 255, 255, 0, 100, false, true, 2, true, nil, nil, false)
        if distance < 1.5 then
            Draw3DText(coords.x, coords.y, coords.z + 0.4, shared.Locales["open_storage"])
            if IsControlJustReleased(0, 38) then
                OpenStorageMenu()
            end
        end
    end
end

RegisterNetEvent('savana-storage:client:sendNotifys',function(msg, tipim)
    Framework:Notify(msg, tipim)
end)

RegisterNUICallback('openStash', function(data, cb) 
    SetNuiFocus(false,false) 
    local weight = data.data.weight
    local name = data.data.name
    local slot = data.data.capacity
    if GetResourceState('ox_inventory') == 'started' then
        TriggerServerEvent('savana-storage:createStash', name, slot, weight)
        exports.ox_inventory:openInventory('stash', name)
    elseif GetResourceState('qb-inventory') == 'started' then    
        TriggerServerEvent('savana-storage:openInventory', 'qb', 'savana_'..name, slot, weight)
    else
        TriggerServerEvent('inventory:server:OpenInventory', 'stash', 'savana_'..name, {
            maxweight = weight,
            slots = slot,
        })
        TriggerEvent('inventory:client:SetCurrentStash', 'savana_'..name)
    end
    cb('success')
end)

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
                Draw3DText(coords.x, coords.y, coords.z + 0.4, shared.Locales["open_storage"])
                if IsControlJustReleased(0, 38) then
                    OpenStorageMenu()
                end
            else
                Draw3DText(coords.x, coords.y, coords.z + 0.4, shared.Locales["open_storage"])
                if IsControlJustReleased(0, 38) then
                    endMission()
                end
            end
        end
    end
end

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
    for _, storage in pairs(shared.Storage) do
        local blip = AddBlipForCoord(storage.pedCoords.x, storage.pedCoords.y, storage.pedCoords.z)

        SetBlipSprite(blip, storage.blip.sprite) 
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, storage.blip.size)
        SetBlipColour(blip, storage.blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(storage.blip.text)
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