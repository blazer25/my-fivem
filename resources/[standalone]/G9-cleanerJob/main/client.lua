local playerJob = {
    start = false,
    carRemoved = false,
    selectedJob = nil,
    jobs = {},
    price = nil,
    xp = nil,
    car = nil
}


function open()
    if not playerJob.start then
        local response = lib.callback.await('g9:getCleaner', false)
        local streetPrice = jobs.jobSettings["street"][response.level].price
        local gardenPrice = jobs.jobSettings["garden"][response.level].price
        local streetStep = #jobs.jobCoords["street"]
        local gardenStep = #jobs.jobCoords["garden"]
        SendNUIMessage({
            action = 'open',
            playerName = G9Series:getPlayerName(),
            level = response.level,
            xp = response.xp,
            sprice = streetPrice,
            gprice = gardenPrice,
            streetStep = streetStep,
            gardenStep = gardenStep,
            lang = Locales[cfg.lang]
        })
        SetNuiFocus(true, true)
    else
        notify(lang("alreadyWork"))
    end
end

RegisterNUICallback('selectJob', function(data)
    local response = lib.callback.await('g9:getCleaner', false) 
    local job = data.selected
    playerJob.price = jobs.jobSettings[job][response.level].price
    playerJob.xp = jobs.jobSettings[job][response.level].xp
    if job == 'street' then
        for k, v in ipairs(jobs.jobCoords["street"]) do
            table.insert(playerJob.jobs, v)
        end        
        Wait(1000)
        streetJob()
    elseif job == 'garden' then
        for k, v in ipairs(jobs.jobCoords["garden"]) do
            table.insert(playerJob.jobs, v)
        end
        Wait(1000)
        gardenJob()
    end
end)

local sleep = 2000
local kir = nil

function streetJob()
    local priceXp = {
        money = playerJob.price,
        xp = playerJob.xp
    }

    giveCar()

    playerJob.start = true

    local hash = GetHashKey('proc_litter_01')
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(0)
    end


    local sleep = 1000
    local kir = nil

    local function newJob()
        if #playerJob.jobs == 0 then
            returnCompany()
            playerJob.start = false
            return nil, nil
        end
        local randomIndex = math.random(1, #playerJob.jobs)
        local coord = playerJob.jobs[randomIndex]
        SetNewWaypoint(coord.x, coord.y)
        return coord, randomIndex
    end

    local currentCoord, currentIndex = newJob()
    if not currentCoord then return end

    while playerJob.start do
        Wait(sleep)

        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = #(playerCoords - currentCoord)

        if kir == nil then
            kir = CreateObject(hash, currentCoord.x, currentCoord.y, currentCoord.z - 1, true, true, true)
            FreezeEntityPosition(kir, true)
        end

        if distance < 50 then
            sleep = 0
            DrawMarker(2, currentCoord.x, currentCoord.y, currentCoord.z, 0.0, 0.0, 0.0,
                180.0, 0.0, 0.0, 0.75, 0.75, 0.75, 0, 255, 0, 100,
                false, true, 2, false, false, false, false)
            if distance < 2 then 
                if IsControlJustReleased(0, 38) then
                    if not IsPedInAnyVehicle(PlayerPedId(), false) then
                        table.remove(playerJob.jobs, currentIndex)
                        TaskTurnPedToFaceEntity(PlayerPedId(), kir, -1)
                        cleanAnim(kir)
                        DeleteObject(kir)
                        kir = nil
                        local data = lib.callback.await('g9:addXpMoney', false, priceXp)
                        if data == 'levelUp' then
                            SendNUIMessage({
                                action = 'levelUp',
                                level = 3
                            })
                        end
                        currentCoord, currentIndex = newJob()
                        if not currentCoord then
                            break
                        else
                            notify(lang("next"), 'success')
                        end
                    else
                        notify(lang("noVehicle"), 'error')
                    end
                end
            end
        else
            sleep = 1000
        end
    end
end

function gardenJob()
    local priceXp = {
        money = playerJob.price,
        xp = playerJob.xp
    }

    giveCar()

    playerJob.start = true


    local hash = GetHashKey('prop_tree_olive_01')
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(0)
    end

    local sleep = 1000
    local kir = nil

    local function newJob()
        if #playerJob.jobs == 0 then
            returnCompany()
            playerJob.start = false
            return nil, nil
        end
        local randomIndex = math.random(1, #playerJob.jobs)
        local coord = playerJob.jobs[randomIndex]
        SetNewWaypoint(coord.x, coord.y)
        return coord, randomIndex
    end

    local currentCoord, currentIndex = newJob()
    if not currentCoord then return end

    while playerJob.start do
        Wait(sleep)

        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = #(playerCoords - currentCoord)

        if kir == nil then
            kir = CreateObject(hash, currentCoord.x, currentCoord.y, currentCoord.z - 2.5, true, true, true)
            FreezeEntityPosition(kir, true)
        end

        if distance < 50 then
            sleep = 0
            SetEntityDrawOutline(kir, true)
            if distance < 2 then 
                if IsControlJustReleased(0, 38) then
                    if not IsPedInAnyVehicle(PlayerPedId()) then
                        table.remove(playerJob.jobs, currentIndex)
                        TaskTurnPedToFaceEntity(PlayerPedId(), kir, -1)
                        gardenAnim(kir)
                        DeleteObject(kir)
                        kir = nil
                        local data = lib.callback.await('g9:addXpMoney', false, priceXp)
                        if data == 'levelUp' then
                            SendNUIMessage({
                                action = 'levelUp',
                                level = 3
                            })
                        end
                        currentCoord, currentIndex = newJob()
                        if not currentCoord then
                            break
                        else
                            notify(lang("next"), 'success')
                        end
                    else
                        notify(lang("noVehicle"), 'error')
                    end
                end
            end
        else
            sleep = 1000
        end
    end
end


function LoadAnim(anim)
    RequestAnimDict(anim)
    while not HasAnimDictLoaded(anim) do
        Citizen.Wait(100)
    end
end

function cleanAnim(entity)
    RequestModel("prop_tool_broom")

	while not HasModelLoaded("prop_tool_broom") do
		Citizen.Wait(10)
	end

    local player = PlayerPedId()
    local coords = GetEntityCoords(player)
    local newProp = CreateObject(GetHashKey("prop_tool_broom"), coords.x, coords.y, coords.z, true, true, true)
    AttachEntityToEntity(
        newProp, 
        player, 
        GetPedBoneIndex(player, 28422), 
        0.0, 0.0, 0.24, 
        0.0, 0.0, 0.0, 
        true, true, false, true, 1, true
    )
    local animDict = 'anim@amb@drug_field_workers@rake@male_b@base'
    local animName = 'base'
    LoadAnim(animDict)
    TaskPlayAnim(player, animDict, animName, 8.0, -8.0, -1, 1, 0, false, false, false)
    while true do
        Wait(1000)
        local alphaLevel = GetEntityAlpha(entity)
        alphaLevel = alphaLevel - 50
        SetEntityAlpha(entity, alphaLevel, 0)
        if alphaLevel < 20 then 
            break
        end
    end
    ClearPedTasksImmediately(player)
    DeleteObject(newProp)
end

function gardenAnim(entity)
    RequestModel("w_me_hatchet")

    while not HasModelLoaded("w_me_hatchet") do
        Citizen.Wait(10)
    end

    local player = PlayerPedId()
    local coords = GetEntityCoords(player)
    local axe = CreateObject(GetHashKey("w_me_hatchet"), coords.x, coords.y, coords.z, true, true, true)
    
    AttachEntityToEntity(
        axe,
        player,
        GetPedBoneIndex(player, 57005), -- Sağ el
        0.1, 0.0, 0.0,
        0.0, 270.0, 90.0,
        true, true, false, true, 1, true
    )

    local animDict = "melee@hatchet@streamed_core"
    local animName = "plyr_rear_takedown_b"

    LoadAnim(animDict)
    TaskPlayAnim(player, animDict, animName, 8.0, -8.0, -1, 1, 0, false, false, false)

    local duration = 3000
    local start = GetGameTimer()

    while GetGameTimer() - start < duration do
        Wait(500)
        local alphaLevel = GetEntityAlpha(entity)
        alphaLevel = alphaLevel - 50
        SetEntityAlpha(entity, alphaLevel, 0)
        if alphaLevel < 20 then 
            break
        end
    end

    ClearPedTasksImmediately(player)
    DeleteObject(axe)
end



function giveCar()
    RequestModel(cfg.company.jobVehicle)
    while not HasModelLoaded(cfg.company.jobVehicle) do
        Wait(0)
    end
    local coords = cfg.company.vehicleLocation
    local vehicle = CreateVehicle(GetHashKey(cfg.company.jobVehicle), coords.x, coords.y, coords.z, 0.0, true, false)
    
    SetEntityHeading(vehicle, coords.w)
    SetVehicleNumberPlateText(vehicle, math.random(12314522,19999999))
    SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
    vehicleKey()
    playerJob.car = GetVehicleNumberPlateText(vehicle)
end

RegisterNUICallback('close', function() 
    SetNuiFocus(false,false)
end)


function returnCompany()
    notify(lang("finish"), 'success')
    SetNewWaypoint(cfg.company.location.x, cfg.company.location.y)
    
    carRemoved = true
    while carRemoved do
        Wait(sleep)
        local player = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(player, false)
        local plate = GetVehicleNumberPlateText(vehicle)
        local returnCoord = cfg.company.returnCar
        local distance = #(GetEntityCoords(player) - returnCoord)
        
        if distance < 20 then
            sleep = 0
            DrawMarker(2, returnCoord.x, returnCoord.y, returnCoord.z, 0.0, 0.0, 0.0,
                180.0, 0.0, 0.0, 0.75, 0.75, 0.75, 0, 255, 0, 100,
                false, true, 2, false, false, false, false)
            
            if distance < 3 then
                if IsControlJustReleased(0, 38) then
                    if plate == playerJob.car then
                        DeleteVehicle(vehicle)
                        carRemoved = false
                        notify(lang("vehicleFinish"), "success")
                        playerJob = {
                            start = false,
                            carRemoved = false,
                            selectedJob = nil,
                            jobs = {},
                            price = nil,
                            xp = nil,
                            car = nil
                        }
                        break
                    else
                        notify(lang("mirrorCar"), "error")
                        carRemoved = false
                        playerJob = {
                            start = false,
                            carRemoved = false,
                            selectedJob = nil,
                            jobs = {},
                            price = nil,
                            xp = nil,
                            car = nil
                        }
                        break
                    end
                end
            end
        end
    end
end

RegisterCommand(cfg.cancelCommand, function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if playerJob.start then
        playerJob = {
            start = false,
            carRemoved = false,
            selectedJob = nil,
            jobs = {},
            price = nil,
            xp = nil,
            car = nil
        }
        DeleteVehicle(vehicle)
        DeleteObject(kir)
        notify(lang('cancelJob'), 'error')
    end  
end)


CreateThread(function() 
    local blip = AddBlipForCoord(cfg.company.location.x, cfg.company.location.y, cfg.company.location.z)
    SetBlipSprite(blip, cfg.company.blipSprite)
    SetBlipColour(blip, cfg.company.blipColor)
    SetBlipScale(blip, cfg.company.blipSize)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(cfg.company.name)
    EndTextCommandSetBlipName(blip)
end)