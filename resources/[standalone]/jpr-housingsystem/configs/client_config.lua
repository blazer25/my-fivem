local QBCore                  = exports[Config.CoreName]:GetCoreObject() 

function WardrobeMenu(houseName)
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "Clothes1", 0.4)
    TriggerEvent('qb-clothing:client:openOutfitMenu')

    TriggerServerEvent("jpr-housingsystem:server:doDiscordLog", QBCore.Functions.GetPlayerData().citizenid ..  '', Config.Locales["67"]..houseName)
end

function VehicleKeys(plate, model)
    SetVehiclePetrolTankHealth(model, 1000.0)
    Citizen.Wait(1000) -- leave this
    TriggerEvent("vehiclekeys:client:SetOwner", plate)
end

function StoreVehicleFunction(vehicle, plate)
    -- your custom function when storing vehicles
end

function DrawText3Ds(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    --local factor = (string.len(text)) / 370
    --DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function OpenStashFunction(level, houseName)
    if string.find(level.stashName, "house_house_") then
        level.stashName = string.gsub(level.stashName, "house_house_", "apartment_")
    end

    local slots = Config.StashLevel[tostring(level.level)].slots
    local maxweight = Config.StashLevel[tostring(level.level)].kg
    if Config.CustomStashLevels[houseName] then
        if level.level > Config.CustomStashLevels[houseName].MaxLevelStash then
            slots = Config.CustomStashLevels[houseName].StashLevel[Config.CustomStashLevels[houseName].MaxLevelStash].slots
            maxweight = Config.CustomStashLevels[houseName].StashLevel[Config.CustomStashLevels[houseName].MaxLevelStash].kg
        else
            slots = Config.CustomStashLevels[houseName].StashLevel[""..level.level..""].slots
            maxweight = Config.CustomStashLevels[houseName].StashLevel[""..level.level..""].kg
        end
    end
    
    if Config.Inventory == "ox_inventory" then
        QBCore.Functions.TriggerCallback('jpr-housingsystem:server:abrirStashOX', function()
            exports.ox_inventory:openInventory('stash', level.stashName)
        end, level.stashName, maxweight, slots)
    else
        TriggerServerEvent("inventory:server:OpenInventory", "stash", level.stashName, {maxweight = maxweight, slots = slots})
        TriggerEvent("inventory:client:SetCurrentStash", level.stashName)

        if Config.UsingNewQBInv then
            TriggerServerEvent("jpr-housingsystem:server:UsingNewQBInv", level.stashName, {maxweight = maxweight, slots = slots})
        end
    end
end

RegisterNetEvent('jpr-housingsystem:client:openHouseFurnitureStash')
AddEventHandler('jpr-housingsystem:client:openHouseFurnitureStash', function(infos)
    if Config.Inventory == "ox_inventory" then
        QBCore.Functions.TriggerCallback('jpr-housingsystem:server:abrirStashOX', function()
            exports.ox_inventory:openInventory('stash', infos.args.stashName)
        end, infos.args.stashName, tonumber(infos.args.maxweight), tonumber(infos.args.slots))
    else
        TriggerServerEvent("inventory:server:OpenInventory", "stash", infos.args.stashName, {maxweight = infos.args.maxweight, slots = tostring(infos.args.slots)})
        TriggerEvent("inventory:client:SetCurrentStash", infos.args.stashName)

        if Config.UsingNewQBInv then
            TriggerServerEvent("jpr-housingsystem:server:UsingNewQBInv", infos.args.stashName, {maxweight = infos.args.maxweight, slots = tostring(infos.args.slots)})
        end
    end
end)

function CheckForSpawnSpam(plate, callback)
    if GetResourceState('jpr-garages') == 'started' then
        QBCore.Functions.TriggerCallback('jpr-garages:server:IsSpawnOk', function(spawn)
            callback(spawn)
        end, plate)
    elseif (GetResourceState('qb-garages') == 'started') then
        QBCore.Functions.TriggerCallback('qb-garage:server:IsSpawnOk', function(spawn)
            callback(spawn)
        end, plate)
    else
        local gameVehicles = GetGamePool('CVehicle')
        local encontrou = false
        local contador = 0
        for i = 1, #gameVehicles do
            local vehicle = gameVehicles[i]
            if DoesEntityExist(vehicle) then
                if GetVehicleNumberPlateText(vehicle):gsub("%s", "") == plate:gsub("%s", "") then
                    encontrou = true
                    contador = contador + 1
                end
            end
        end

        if encontrou == false or contador <= 1 then
            callback(true)
        else
            callback(false)
        end
    end
end

function DoorSound()
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_open", 0.25)
end

function CallPolice(House)
    TriggerServerEvent('police:server:policeAlert', Config.Locales["56"])
end

local robberyhouseInfos = nil
local usingAdvanced = false
function OpenLockpick(houseInfos, advanced)
    robberyhouseInfos = houseInfos
    usingAdvanced = advanced
    TriggerEvent("qb-lockpick:client:openLockpick", AfterLockpickTry)
end

function AfterLockpickTry(success)
    if success and robberyhouseInfos then
        robberyhouseInfos.args = robberyhouseInfos

        if robberyhouseInfos.args.doorInside.isShell then
            TriggerEvent('jpr-housingsystem:client:entrarCasaCompradaShell', robberyhouseInfos, true)
        elseif not robberyhouseInfos.args.mlo then
            TriggerEvent('jpr-housingsystem:client:entrarCasaComprada', robberyhouseInfos, true)
        else 
            TriggerEvent('jpr-housingsystem:client:lockpickMLODoor', robberyhouseInfos, true)
        end
        
        QBCore.Functions.Notify(Config.Locales["59"], "success")
    else
        robberyhouseInfos = nil
        if usingAdvanced then
            if math.random(1, 100) < 20 then
                TriggerServerEvent("jpr-housingsystem:server:removeAdvancedLockpick")
                TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["advancedlockpick"], "remove")
            end
        else
            if math.random(1, 100) < 40 then
                TriggerServerEvent("jpr-housingsystem:server:removeLockpick")
                TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["lockpick"], "remove")
            end
        end

        QBCore.Functions.Notify(Config.Locales["58"], "error")
    end
end

function ExpulsarPlayer()
    local PlayerData = QBCore.Functions.GetPlayerData()
    local insideMeta = PlayerData.metadata["housingSystem"]
   
    if insideMeta then
        local houseInfo = nil
        for k, _ in pairs(Config.Houses) do
            if Config.Houses[k].houseName == insideMeta.house then
                houseInfo = Config.Houses[k]
                break
            end
        end
        
        if houseInfo then
            if not houseInfo.mlo then
                houseInfo.args = houseInfo
                if insideMeta.house then
                    if not houseInfo.doorInside.isShell then
                        TriggerEvent("jpr-housingsystem:client:entrarCasaComprada", houseInfo)
                    else
                        TriggerEvent("jpr-housingsystem:client:entrarCasaCompradaShell", houseInfo)
                    end
                elseif insideMeta.garage then
                    TriggerEvent("jpr-housingsystem:client:abrirGaragemComprada", houseInfo)
                end
            else
                if insideMeta.garage then
                    houseInfo.args = houseInfo
                    TriggerEvent("jpr-housingsystem:client:abrirGaragemComprada", houseInfo)
                else
                    --SetEntityCoords(PlayerPedId(), houseInfo.doorCoords)
                    --TriggerServerEvent('jpr-housingsystem:server:SetInsideMeta', houseInfo.houseName, false)  
                end
            end
           
            --TriggerServerEvent('jpr-housingsystem:server:SetInsideMeta', houseInfo.houseName, false)
        end
    end

    /* TESTING 
    local closestHouse = nil
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    for i, v in pairs(Config.Houses) do
        local dist = GetDistanceBetweenCoords(coords, v.doorCoords.x, v.doorCoords.y, v.doorCoords.z, true
        if dist < 20 then
            closestHouse = v
            break
        end
    en
    if closestHouse then
        if closestHouse.mlo then
            SetEntityCoords(PlayerPedId(), closestHouse.doorCoords)
        end
    end
    */
end

function CreateTargetZone(zoneName, coords, options)
    if coords then
        if Config.TargetScript == "ox-target" or Config.TargetScript == "ox_target" then
            RemoveTargetZone(zoneName)
            Citizen.Wait(1)

            parameters = {
                coords = coords,
                size = vector3(5.5, 4, 2),
                name = "houseSystem-"..zoneName,
                rotation = -72,
                options = options,
                distance = 1.5
            }
            
            exports.ox_target:addBoxZone(parameters)
        else
            RemoveTargetZone(zoneName)
            Citizen.Wait(1)
            
            exports[Config.TargetScript]:AddBoxZone("houseSystem-"..zoneName, coords, 5.5, 4, {
                name = "houseSystem-"..zoneName,
                heading = -72,
                debugPoly = false,
                minZ = coords.z - 2,
                maxZ = coords.z + 2,
            }, {
                options = options,
                distance = 1.5
            })
        end
    end
end

function RemoveTargetZone(zoneName)
    if Config.TargetScript == "ox-target" or Config.TargetScript == "ox_target" then
        exports[Config.TargetScript]:removeZone("houseSystem-"..zoneName)
    else
        exports[Config.TargetScript]:RemoveZone("houseSystem-"..zoneName)
    end
end

function table.contains(table, element)
    for _, value in ipairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

function table.containsVeh(table, element)
    for _, value in ipairs(table) do

        if value.plate == element then
            return true
        end
    end
    return false
end

function table.containsMLO(table, element)
    for _, value in ipairs(table) do

        if value.houseName == element then
            return true
        end
    end
    return false
end

function isVehicleBlacklisted(vehicle)
    local notBlacklisted = true

    for k,v in pairs(Config.VehicleBlackList) do
        local vehHash = GetEntityModel(vehicle)

        if vehHash == GetHashKey(v) then
            notBlacklisted = false
        end

        if not notBlacklisted then
            break
        end
    end

    return notBlacklisted
end

function DoFadeEffect()
    if Config.FadeScreenOut then
        DoScreenFadeOut(200)
        Wait(500)
    end
end

function ReturnScreenFade()
    if Config.FadeScreenOut then
        Wait(500)
        DoScreenFadeIn(200)
    end
end

function JoinedOnShellHouse()
    SyncWeather()
end

function LeaveOnShellHouse()
    SyncWeather()
end

function SyncWeather()
    TriggerEvent('qb-weathersync:client:EnableSync')
end

RegisterNetEvent('apartments:client:setupSpawnUI', function(cData, new)
    TriggerEvent('qb-spawn:client:setupSpawns', cData, new, nil)
    TriggerEvent('qb-spawn:client:openUI', true)
end)

RegisterNetEvent('apartments:server:CreateApartment')
AddEventHandler('apartments:server:CreateApartment', function()
    QBCore.Functions.TriggerCallback('jpr-housingsystem:server:giveStarterApartment', function(houseInfos)
        if houseInfos then
            local infos = {
                args = houseInfos
            }

            DoScreenFadeIn(500)
            TriggerEvent("jpr-housingsystem:client:entrarCasaComprada", infos)

            Wait(3500)
            SetEntityCoords(PlayerPedId(), 260.86, -999.27, -100.01)
            TriggerEvent('qb-clothes:client:CreateFirstCharacter')
        end
    end, "StartingApartment")
end)

function MinigamePoliceRaid(closestHouse)
    if Config.SkillBarScript == "qb-skillbar" then
		local Skillbar = exports[Config.SkillBarScript]:GetSkillbarObject()
		Skillbar.Start({
			duration = math.random(2500,3500),
			pos = math.random(10, 30),
			width = math.random(10, 20),
		}, function()
            DoRamAnimation(true)
            QBCore.Functions.Notify(Config.Locales["108"], 'success')
            
            TriggerServerEvent("jpr-housingsystem:server:addRaidedHouse", closestHouse.houseName)
		end, function()
            QBCore.Functions.Notify(Config.Locales["109"], 'error')
		end)
	end

    if Config.SkillBarScript == "ox_lib" then
        local success = exports[Config.SkillBarScript]:skillCheck({'easy', 'easy', {areaSize = 60, speedMultiplier = 2}, 'easy'}, {'w', 'a', 's', 'd'})
		
        if success then
            DoRamAnimation(true)
            QBCore.Functions.Notify(Config.Locales["108"], 'success')
            
            TriggerServerEvent("jpr-housingsystem:server:addRaidedHouse", closestHouse.houseName)
        else
            QBCore.Functions.Notify(Config.Locales["109"], 'error')
        end
	end
end

function SpawnVehicle(vehInfo, coords, warp, house)
    local veh = CreateVehicle(vehInfo.vehicle, coords.x, coords.y, coords.z, coords.w, true, false)
    local netid = NetworkGetNetworkIdFromEntity(veh)
    SetVehicleHasBeenOwnedByPlayer(veh, true)
    SetNetworkIdCanMigrate(netid, true)
    SetVehicleNeedsToBeHotwired(veh, false)
    SetVehRadioStation(veh, 'OFF')
    SetModelAsNoLongerNeeded(vehInfo.vehicle)
    SetEntityHeading(veh, coords.w)
    SetVehicleNumberPlateText(veh, vehInfo.plate)
 
    return veh
end