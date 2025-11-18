-- Framework detection and initialization
local isQBox = GetResourceState('qbx_core') == 'started'
local isQBCore = GetResourceState('qb-core') == 'started'

if isQBox then
    -- QBox doesn't use GetCoreObject, we'll use exports directly when needed
    QBCore = {
        Functions = {
            -- QBox client functions are accessed via exports when needed
        }
    }
elseif isQBCore then
    QBCore = exports['qb-core']:GetCoreObject()
end

local cashObjects = {}

-- Table to track rope-attached ATMs
local ropeAttachedATMs = {}

-- Table to track robbed ATM coordinates to prevent respawning
local robbedATMCoords = {}

local atmModels = {
    ["prop_atm_01"] = vector3(0.072237, 0.50293, 0.779063),
    ["prop_atm_02"] = vector3(0.01,0.11,0.92),
    ["prop_atm_03"] = vector3(-0.14,-0.01,0.88),
    ["prop_fleeca_atm"] = vector3(0.127, 0.017, 1.0)
}

-- Function to check if an ATM has been robbed at a specific location
function IsATMAlreadyRobbed(atmCoords)
    for _, robbedCoords in pairs(robbedATMCoords) do
        if #(atmCoords - robbedCoords) < 1.0 then
            return true
        end
    end
    return false
end

-- Function to mark an ATM as robbed
function MarkATMAsRobbed(atmCoords)
    table.insert(robbedATMCoords, atmCoords)
end

function GetTarget()
    if Config.Target ~= 'autodetect' then
        return Config.Target
    end

    if GetResourceState('ox_target') == 'started' then
        return 'ox_target'
    elseif GetResourceState('qb-target') == 'started' then
        return 'qb-target'
    else
        print('^1[Warning] No compatible Target resource detected.^0')
        return nil
    end
end

local targetResource = GetTarget()

for _, model in ipairs(Config.AtmModels) do
    if targetResource == 'ox_target' then
        local options = {}
        local function canInteractGeneric(entity, action)
            if ropeAttachedATMs[entity] then
                if action == 'rope' then
                    return false
                end
                if action == 'hack' or action == 'drill' then
                    if ropeAttachedATMs[entity].detached or ropeAttachedATMs[entity].ropeAttached then
                        return false
                    end
                end
            end
            local coords = GetEntityCoords(entity)
            return not IsATMAlreadyRobbed(coords)
        end
        if Config.EnableHacking then
            local hackOption = {
                event = 'pl_atmrobbery_hack',
                label = locale('hack_atm_label'),
                icon = 'fas fa-laptop-code',
                model = model,
                distance = 2,
                canInteract = function(entity) return canInteractGeneric(entity, 'hack') end
            }
            if Config.HackingItem and Config.HackingItem ~= false then
                hackOption.items = Config.HackingItem
            end
            table.insert(options, hackOption)
        end
        if Config.EnableDrilling then
            local drillOption = {
                event = 'pl_atmrobbery_drill',
                label = locale('drill_atm_label'),
                icon = 'fas fa-tools',
                model = model,
                distance = 2,
                canInteract = function(entity) return canInteractGeneric(entity, 'drill') end
            }
            if Config.DrillItem and Config.DrillItem ~= false then
                drillOption.items = Config.DrillItem
            end
            table.insert(options, drillOption)
        end
        if Config.EnableRopeRobbery and (model == 'prop_fleeca_atm' or model == 'prop_atm_02' or model == 'prop_atm_03') then
            table.insert(options, {
                event = 'pl_atmrobbery_rope',
                label = locale('rope_atm_label'),
                icon = 'fas fa-link',
                model = model,
                distance = 2,
                items = Config.RopeItem,
                canInteract = function(entity) return canInteractGeneric(entity, 'rope') end
            })
        end
        exports.ox_target:addModel(model, options)
        
    elseif targetResource == 'qb-target' then
        local options = {}
        local function canInteractGeneric(entity, action)
            if ropeAttachedATMs[entity] then
                if action == 'rope' then
                    return false
                end
                if action == 'hack' or action == 'drill' then
                    if ropeAttachedATMs[entity].detached or ropeAttachedATMs[entity].ropeAttached then
                        return false
                    end
                end
            end
            local coords = GetEntityCoords(entity)
            return not IsATMAlreadyRobbed(coords)
        end
        if Config.EnableHacking then
            local hackOption = {
                type = "client",
                event = 'pl_atmrobbery_hack',
                icon = 'fas fa-laptop-code',
                label = locale('hack_atm_label'),
                model = model,
                canInteract = function(entity) return canInteractGeneric(entity, 'hack') end
            }
            if Config.HackingItem and Config.HackingItem ~= false then
                hackOption.item = Config.HackingItem
            end
            table.insert(options, hackOption)
        end
        if Config.EnableDrilling then
            local drillOption = {
                type = "client",
                event = 'pl_atmrobbery_drill',
                icon = 'fas fa-tools',
                label = locale('drill_atm_label'),
                model = model,
                canInteract = function(entity) return canInteractGeneric(entity, 'drill') end
            }
            if Config.DrillItem and Config.DrillItem ~= false then
                drillOption.item = Config.DrillItem
            end
            table.insert(options, drillOption)
        end
        if Config.EnableRopeRobbery and (model == 'prop_fleeca_atm' or model == 'prop_atm_02' or model == 'prop_atm_03') then
            table.insert(options, {
                type = "client",
                event = 'pl_atmrobbery_rope',
                icon = 'fas fa-link',
                label = locale('rope_atm_label'),
                model = model,
                item = Config.RopeItem,
                canInteract = function(entity) return canInteractGeneric(entity, 'rope') end
            })
        end
        exports['qb-target']:AddTargetModel(model, {
            options = options,
            distance = 1.0
        })
    end
end

function AddCashToTarget(cash,atmCoords)
    if targetResource == 'qb-target' then
        exports['qb-target']:AddTargetEntity(cash, {
            options = {
                {
                    type = "client",
                    event = "pl_atmrobbery:pickupCash",
                    icon = "fas fa-money-bill-wave",
                    label = locale('pick_up_cash'),
                    atmCoords = atmCoords
                }
            },
            distance = 1.5
        })
    elseif targetResource == 'ox_target' then
        exports.ox_target:addLocalEntity(cash, {
            {
                event = "pl_atmrobbery:pickupCash",
                icon = "fas fa-money-bill-wave",
                label = locale('pick_up_cash'),
                args = atmCoords
            }
        })
    end
end

RegisterNetEvent('pl_atmrobbery:notification')
AddEventHandler('pl_atmrobbery:notification', function(message, type)
    if Config.Notify == 'ox' then
        lib.notify({
            title = 'Pulse Scripts ATM',
            description = message,
            type = type
        })
    elseif Config.Notify == 'esx' then
        TriggerEvent("esx:showNotification", message)
    elseif Config.Notify == 'okok' then
        exports['okokNotify']:Alert("Info", message, 5000, 'info')
    elseif Config.Notify == 'qb' then
        QBCore.Functions.Notify(message, type, 5000)
    elseif Config.Notify == 'wasabi' then
        exports.wasabi_notify:notify("Pulse Scripts ATM ROBBERY", message, 6000, type, false, 'fas fa-ghost')
    elseif Config.Notify == 'brutal_notify' then
        exports['brutal_notify']:SendAlert('Notify', message, 6000, type, false)
    elseif Config.Notify == 'custom' then
        -- Add your custom notifications here
    end
end)

function DispatchAlert()
    if Config.Dispatch == 'ps' then
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local street1, street2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
        local street1name = GetStreetNameFromHashKey(street1)
        local street2name = GetStreetNameFromHashKey(street2)
        local alert = {
            coords = coords,
            message = locale('dispatch_message')..street1name.. ' ' ..street2name,
            dispatchCode = '10-90',
            description = 'ATM Robbery',
            radius = 0,
            sprite = 431,
            color = 1,
            scale = 1.0,
            length = 3
        }
        exports["ps-dispatch"]:CustomAlert(alert)
    elseif Config.Dispatch == 'qs' then
        local playerData = exports['qs-dispatch']:GetPlayerInfo()
        TriggerServerEvent('qs-dispatch:server:CreateDispatchCall', {
            job = Config.Police.Job,
            callLocation = playerData.coords,
            callCode = { code = '10-90', snippet = 'ATM Robbery' },
            message = "street_1: ".. playerData.street_1.. " street_2: ".. playerData.street_2.."",
            flashes = false, -- No flashing icon
            image = nil,
            blip = {
                sprite = 431,
                scale = 1.2,
                colour = 1,
                flashes = true,
                text = 'ATM Robbery',
                time = (30 * 1000), 
            }
        })
    elseif Config.Dispatch == 'aty' then
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local street1, street2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
        local street1name = GetStreetNameFromHashKey(street1)
        local street2name = GetStreetNameFromHashKey(street2)
        TriggerServerEvent("aty_dispatch:server:customDispatch",
            "ATM Robbery",          -- title
            "10-90",                -- code
            street1name ' ' ..street2name, -- location
            coords,      -- coords (vector3)
            nil,         -- gender
            nil, -- vehicle name
            nil, -- vehicle object (optional)
            nil, -- weapon (not needed for ATM robbery)
            431, -- blip sprite (robbery icon)
            Config.Police.Job -- jobs to notify
            )

    elseif Config.Dispatch == 'rcore' then
        local playerData = exports['rcore_dispatch']:GetPlayerData()
        exports['screenshot-basic']:requestScreenshotUpload('InsertWebhookLinkHERE', "files[]", function(val)
            local image = json.decode(val)
            local alert = {
                code = '10-90 - ATM Robbery',
                default_priority = 'low',
                coords = playerData.coords,
                job = Config.Police.Job,
                text = 'ATM Robbery in progress on ' ..playerData.street_1,
                type = 'alerts',
                blip_time = 30,
                image = image.attachments[1].proxy_url,
                blip = {
                    sprite = 431,
                    colour = 1,
                    scale = 1.0,
                    text = '10-990 - ATM Robbery',
                    flashes = false,
                    radius = 0,
                }
            }
            TriggerServerEvent('rcore_dispatch:server:sendAlert', alert)
        end)
    elseif Config.Dispatch == 'cd_dispatch' then
        local data = exports['cd_dispatch']:GetPlayerInfo()
        TriggerServerEvent('cd_dispatch:AddNotification', {
            job_table = {'police', }, 
            coords = data.coords,
            title = '10-990 - ATM Robbery',
            message = 'A '..data.sex..' robbing a store at '..data.street, 
            flash = 0,
            unique_id = data.unique_id,
            sound = 1,
            blip = {
                sprite = 431, 
                scale = 1.2, 
                colour = 3,
                flashes = false, 
                text = '911 - ATM Robbery',
                time = 5,
                radius = 0,
            }
        })
    elseif Config.Dispatch == 'op' then
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local street1, street2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
        local street1name = GetStreetNameFromHashKey(street1)
        local street2name = GetStreetNameFromHashKey(street2)
            
        local job = Config.Police.Job -- Jobs that will receive the alert
        local title = "ATM Robbery" -- Main title alert
        local id = GetPlayerServerId(PlayerId()) -- Player that triggered the alert
        local panic = false -- Allow/Disable panic effect
            
        local locationText = street2name and (street1name .. " and " .. street2name) or street1name
        local text = "ATM Robbery in progress at " .. locationText -- Main text alert
            
        TriggerServerEvent('Opto_dispatch:Server:SendAlert', job, title, text, coords, panic, id)

    elseif Config.Dispatch == 'custom' then

    end
end

RegisterNetEvent('pl_atmrobbery_drill')
AddEventHandler('pl_atmrobbery_drill', function(data)
    local entity = data.entity
    local atmModel = GetEntityModel(entity)

    if entity and DoesEntityExist(entity) then
        local atmCoords = GetEntityCoords(entity)
        if not IsPedHeadingTowardsPosition(PlayerPedId(), atmCoords.x,atmCoords.y,atmCoords.z,10.0) then
			TaskTurnPedToFaceCoord(PlayerPedId(), atmCoords.x,atmCoords.y,atmCoords.z, 1500)
		end
        local enoughpolice = lib.callback.await('pl_atmrobbery:checkforpolice', false)
        if enoughpolice then
            local checktime = lib.callback.await('pl_atmrobbery:checktime', false)
            if checktime then
                Wait(1000)
                if Config.Police.notify then
                    DispatchAlert()
                end
                -- Check if M-drilling resource is available
                if GetResourceState('M-drilling') == 'started' then
                    TriggerEvent("Drilling:Start",function(success)
                        if (success) then
                            TriggerServerEvent('pl_atmrobbery:MinigameResult', true, 'drill')
                            if not Config.MoneyDrop then
                                LootATM(atmCoords)
                            else
                                TriggerEvent('pl_atmrobbery_drill:success',entity, atmCoords, atmModel)
                            end
                        else
                            TriggerServerEvent('pl_atmrobbery:MinigameResult', false, 'drill')
                        end
                    end)
                else
                    -- Fallback to ox_lib skillcheck if M-drilling is not available
                    local success = lib.skillCheck({'easy', 'medium', { areaSize = 60, speedMultiplier = 1 }, 'medium'}, { 'w', 'a', 's', 'd' })
                    if success then
                        TriggerServerEvent('pl_atmrobbery:MinigameResult', true, 'drill')
                        if not Config.MoneyDrop then
                            LootATM(atmCoords)
                        else
                            TriggerEvent('pl_atmrobbery_drill:success',entity, atmCoords, atmModel)
                        end
                    else
                        TriggerServerEvent('pl_atmrobbery:MinigameResult', false, 'drill')
                        TriggerEvent('pl_atmrobbery:notification', locale('failed_robbery'), 'error')
                    end
                end
            else
                TriggerEvent('pl_atmrobbery:notification', locale('wait_robbery'),'error')
            end
        else
            TriggerEvent('pl_atmrobbery:notification', locale('not_enough_police'),'error')
        end
    end
end)
RegisterNetEvent('pl_atmrobbery_hack')
AddEventHandler('pl_atmrobbery_hack', function(data)
    local entity = data.entity
    local atmModel = GetEntityModel(entity)

    if entity and DoesEntityExist(entity) then
        local atmCoords = GetEntityCoords(entity)
        if not IsPedHeadingTowardsPosition(PlayerPedId(), atmCoords.x,atmCoords.y,atmCoords.z,10.0) then
			TaskTurnPedToFaceCoord(PlayerPedId(), atmCoords.x,atmCoords.y,atmCoords.z, 1500)
		end
        local enoughpolice = lib.callback.await('pl_atmrobbery:checkforpolice', false)
        if enoughpolice then
            local checktime = lib.callback.await('pl_atmrobbery:checktime', false)
            if checktime then
                Wait(1000)
                if Config.Police.notify then
                    DispatchAlert()
                end
                lib.progressBar({
                    duration = Config.Hacking.InitialHackDuration,
                    label = 'Initializing Hack',
                    useWhileDead = false,
                    canCancel = false,
                    disable = {
                        car = true,
                        move = true,
                        combat = true,
                    },
                    anim = {
                        dict = 'missheist_jewel@hacking',
                        clip = 'hack_loop',
                    }
                })
                TriggerEvent('pl_atmrobbery:StartMinigame', entity, atmCoords, atmModel)
            else
                TriggerEvent('pl_atmrobbery:notification', locale('wait_robbery'),'error')
            end
        else
            TriggerEvent('pl_atmrobbery:notification', locale('not_enough_police'),'error')
        end
    end
    
end)

function LootATM(atmCoords)
        lib.progressBar({
            duration = Config.Hacking.LootAtmDuration,
            label = 'Collecting Cash',
            useWhileDead = false,
            canCancel = false,
            disable = {
                car = true,
                move = true,
                combat = true,
            },
            anim = {
                dict = 'oddjobs@shop_robbery@rob_till',
                clip = 'loop', 
            }
        })
        TriggerServerEvent('pl_atmrobbery:robbery',atmCoords)
end

RegisterNetEvent('pl_atmrobbery:StartMinigame', function(entity, atmCoords, atmModel)
    local function handleResult(success)
        if success then
            TriggerServerEvent('pl_atmrobbery:MinigameResult', true, 'hack')
            if Config.MoneyDrop then
                TriggerEvent("pl_atmrobbery:spitCash", entity, atmCoords, atmModel)
            else
                LootATM(atmCoords)
            end
        else
            TriggerServerEvent('pl_atmrobbery:MinigameResult', false)
            TriggerEvent('pl_atmrobbery:notification', locale('failed_robbery'), 'error')
        end
    end

    local minigame = Config.Hacking.Minigame

    if minigame == 'utk_fingerprint' then
        if GetResourceState('utk_fingerprint') == 'started' then
            TriggerEvent("utk_fingerprint:Start", 1, 6, 1, function(outcome, _)
                handleResult(outcome == true)
            end)
        else
            TriggerEvent('pl_atmrobbery:notification', 'utk_fingerprint resource is not available. Falling back to ox_lib.', 'error')
            local outcome = lib.skillCheck({'easy', 'easy', { areaSize = 60, speedMultiplier = 1 }, 'easy'}, { 'w', 'a', 's', 'd' })
            handleResult(outcome == true)
        end

    elseif minigame == 'ox_lib' then
        local outcome = lib.skillCheck({'easy', 'easy', { areaSize = 60, speedMultiplier = 1 }, 'easy'}, { 'w', 'a', 's', 'd' })
        handleResult(outcome == true)

    elseif minigame == 'ps-ui-circle' then
        if GetResourceState('ps-ui') == 'started' then
            exports['ps-ui']:Circle(function(success)
                handleResult(success)
            end, 4, 60)
        else
            TriggerEvent('pl_atmrobbery:notification', 'ps-ui resource is not available. Falling back to ox_lib.', 'error')
            local outcome = lib.skillCheck({'easy', 'easy', { areaSize = 60, speedMultiplier = 1 }, 'easy'}, { 'w', 'a', 's', 'd' })
            handleResult(outcome == true)
        end

    elseif minigame == 'ps-ui-maze' then
        if GetResourceState('ps-ui') == 'started' then
            exports['ps-ui']:Maze(function(success)
                handleResult(success)
            end, 120)
        else
            TriggerEvent('pl_atmrobbery:notification', 'ps-ui resource is not available. Falling back to ox_lib.', 'error')
            local outcome = lib.skillCheck({'easy', 'easy', { areaSize = 60, speedMultiplier = 1 }, 'easy'}, { 'w', 'a', 's', 'd' })
            handleResult(outcome == true)
        end

    elseif minigame == 'ps-ui-scrambler' then
        if GetResourceState('ps-ui') == 'started' then
            exports['ps-ui']:Scrambler(function(success)
                handleResult(success)
            end, 'numeric', 120, 1)
        else
            TriggerEvent('pl_atmrobbery:notification', 'ps-ui resource is not available. Falling back to ox_lib.', 'error')
            local outcome = lib.skillCheck({'easy', 'easy', { areaSize = 60, speedMultiplier = 1 }, 'easy'}, { 'w', 'a', 's', 'd' })
            handleResult(outcome == true)
        end

    else
        TriggerEvent('pl_atmrobbery:notification', 'Invalid minigame configuration. Falling back to ox_lib.', 'error')
        local outcome = lib.skillCheck({'easy', 'easy', { areaSize = 60, speedMultiplier = 1 }, 'easy'}, { 'w', 'a', 's', 'd' })
        handleResult(outcome == true)
    end
end)

RegisterNetEvent("pl_atmrobbery:pickupCash")
AddEventHandler("pl_atmrobbery:pickupCash", function(data)
    local entity = data.entity
    local playerPed = PlayerPedId()
    local atmCoords
    if targetResource == 'ox_target' then
        atmCoords = data.args
    elseif targetResource == 'qb-target' then
        atmCoords = data.atmCoords
    end
    RequestAnimDict("pickup_object")
    while not HasAnimDictLoaded("pickup_object") do
        Wait(10)
    end

    TaskPlayAnim(playerPed, "pickup_object", "pickup_low", 8.0, -8.0, -1, 48, 0, false, false, false)

    Wait(1000)

    if DoesEntityExist(entity) then
        DeleteEntity(entity)
        TriggerServerEvent('pl_atmrobbery:robbery', atmCoords)
    end
    ClearPedTasks(playerPed)
end)
local function getModelNameFromHash(hash)
    for modelName, _ in pairs(atmModels) do
        if GetHashKey(modelName) == hash then
            return modelName
        end
    end
    return nil -- Not found
end

RegisterNetEvent("pl_atmrobbery_drill:success")
AddEventHandler("pl_atmrobbery_drill:success", function(atmEntity, atmCoords, atmModel)
    local cashModel = "hei_prop_heist_cash_pile"
    RequestModel(cashModel)
    while not HasModelLoaded(cashModel) do
        Wait(10)
    end

    local atmForward = GetEntityForwardVector(atmEntity)
    local atmHeading = GetEntityHeading(atmEntity)

    local dropOffset
    local atmModelName = getModelNameFromHash(atmModel)
    if atmModels[atmModelName] then
        dropOffset = atmModels[atmModelName]
    end
    local dropPosition = atmCoords + dropOffset
    for i = 1, Config.Reward.drill_cash_pile do 
        Wait(150)

        local cash = CreateObject(GetHashKey(cashModel), dropPosition.x, dropPosition.y, dropPosition.z, true, true, true)
        SetEntityHeading(cash, atmHeading)

        local forceX = atmForward.x * 2
        local forceY = atmForward.y * 2
        local forceZ = 0.2
        if atmModelName ~= "prop_atm_01" then
            SetEntityNoCollisionEntity(cash, atmEntity, false)
            SetEntityNoCollisionEntity(atmEntity, cash, false)
        end
        SetEntityVelocity(cash, forceX, forceY, forceZ)
        AddCashToTarget(cash,atmCoords)
        table.insert(cashObjects, cash)
    end
end)

RegisterNetEvent("pl_atmrobbery:spitCash")
AddEventHandler("pl_atmrobbery:spitCash", function(atmEntity, atmCoords, atmModel)
    local cashModel = "prop_anim_cash_pile_01"
    RequestModel(cashModel)
    while not HasModelLoaded(cashModel) do
        Wait(10)
    end

    local atmForward = GetEntityForwardVector(atmEntity)
    local atmHeading = GetEntityHeading(atmEntity)

    local dropOffset
    local atmModelName = getModelNameFromHash(atmModel)
    if atmModels[atmModelName] then
        dropOffset = atmModels[atmModelName]
    end

    local dropPosition = atmCoords + dropOffset
    for i = 1, Config.Reward.hack_cash_pile do 
        Wait(150)

        local cash = CreateObject(GetHashKey(cashModel), dropPosition.x, dropPosition.y, dropPosition.z, true, true, true)
        SetEntityHeading(cash, atmHeading)
        local forceX = atmForward.x * 2 
        local forceY = atmForward.y * 2
        local forceZ = 0.2
        if atmModelName ~= "prop_atm_01" then
            SetEntityNoCollisionEntity(cash, atmEntity, false)
            SetEntityNoCollisionEntity(atmEntity, cash, false)
        end
        
        SetEntityVelocity(cash, forceX, forceY, forceZ)
        AddCashToTarget(cash,atmCoords)
        table.insert(cashObjects, cash)
    end
end)


local function ensure_rope_textures_loaded()
	if not RopeAreTexturesLoaded() then
		RopeLoadTextures()
		while not RopeAreTexturesLoaded() do
			Wait(0)
		end
	end
end

local function cleanup_rope_textures()
	local ropes = GetAllRopes()
	if type(ropes) == "table" and #ropes == 0 then
		RopeUnloadTextures()
	end
end

RegisterNetEvent('pl_atmrobbery_rope')
AddEventHandler('pl_atmrobbery_rope', function(data)
    local entity = data.entity
    local atmModel = GetEntityModel(entity)

    if entity and DoesEntityExist(entity) then
        local atmCoords = GetEntityCoords(entity)
        if not IsPedHeadingTowardsPosition(PlayerPedId(), atmCoords.x,atmCoords.y,atmCoords.z,10.0) then
			TaskTurnPedToFaceCoord(PlayerPedId(), atmCoords.x,atmCoords.y,atmCoords.z, 1500)
		end
        local enoughpolice = lib.callback.await('pl_atmrobbery:checkforpolice', false)
        if enoughpolice then
            local checktime = lib.callback.await('pl_atmrobbery:checktime', false)
            if checktime then
                Wait(1000)
                if Config.Police.notify then
                    DispatchAlert()
                end

                StartRopeAttachment(entity, atmCoords, atmModel)
            else
                TriggerEvent('pl_atmrobbery:notification', locale('wait_robbery'),'error')
            end
        else
            TriggerEvent('pl_atmrobbery:notification', locale('not_enough_police'),'error')
        end
    end
end)

function StartRopeAttachment(atmEntity, atmCoords, atmModel)
    local playerPed = PlayerPedId()
    
    SetEntityDynamic(atmEntity, true)
    SetEntityHasGravity(atmEntity, false)
    SetEntityCollision(atmEntity, true, true)
    

    lib.progressBar({
        duration = 3000,
        label = 'Attaching Rope to ATM',
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
            move = true,
            combat = true,
        },
        anim = {
            dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
            clip = 'machinic_loop_mechandplayer',
        }
    })
    
    local atmForward = GetEntityForwardVector(atmEntity)
    local atmAttachmentPoint = atmCoords + (atmForward * 0.5) + vector3(0, 0, 0.5)
    
    ropeAttachedATMs[atmEntity] = {
        entity = atmEntity,
        coords = atmCoords,
        model = atmModel,
        ropeAttached = false,
        atmAttachmentPoint = atmAttachmentPoint,
        initialAtmCoords = atmCoords
    }
    
    TriggerEvent('pl_atmrobbery:notification', locale('rope_attached'), 'success')
    
    AddVehicleRopeTarget(atmEntity)
end

function AddVehicleRopeTarget(atmEntity)
    local vehicles = GetGamePool('CVehicle')
    local atmCoords = GetEntityCoords(atmEntity)
    local nearbyVehicles = {}
    
    for _, vehicle in pairs(vehicles) do
        if DoesEntityExist(vehicle) then
            local vehicleCoords = GetEntityCoords(vehicle)
            local distance = #(atmCoords - vehicleCoords)
            if distance <= 20.0 then
                table.insert(nearbyVehicles, vehicle)
            end
        end
    end
    
    for _, vehicle in pairs(nearbyVehicles) do
        if targetResource == 'ox_target' then
            exports.ox_target:addLocalEntity(vehicle, {
                {
                    event = 'pl_atmrobbery_attach_vehicle_rope',
                    icon = 'fas fa-link',
                    label = locale('attach_rope_to_vehicle'),
                    args = {atmEntity = atmEntity},
                    distance = 3.0
                }
            })
        elseif targetResource == 'qb-target' then
            exports['qb-target']:AddTargetEntity(vehicle, {
                options = {
                    {
                        type = "client",
                        event = 'pl_atmrobbery_attach_vehicle_rope',
                        icon = 'fas fa-link',
                        label = locale('attach_rope_to_vehicle'),
                        atmEntity = atmEntity
                    }
                },
                distance = 3.0
            })
        end
    end
    
    ropeAttachedATMs[atmEntity].targetedVehicles = nearbyVehicles
end

RegisterNetEvent('pl_atmrobbery_attach_vehicle_rope')
AddEventHandler('pl_atmrobbery_attach_vehicle_rope', function(data)
    local vehicle
    local atmEntity
    
    if targetResource == 'ox_target' then
        vehicle = data.entity
        atmEntity = data.args.atmEntity
    elseif targetResource == 'qb-target' then
        vehicle = data.entity
        atmEntity = data.atmEntity
    end
    
    if vehicle and atmEntity and DoesEntityExist(vehicle) and DoesEntityExist(atmEntity) then
        if ropeAttachedATMs[atmEntity] and not ropeAttachedATMs[atmEntity].ropeAttached then
            AttachRopeToVehicle(atmEntity, vehicle)
        else
            TriggerEvent('pl_atmrobbery:notification', 'Rope is already attached to a vehicle or ATM is not ready.', 'error')
        end
    end
end)

function AttachRopeToVehicle(atmEntity, vehicle)
    local atmData = ropeAttachedATMs[atmEntity]
    if not atmData then return end
    
    local atmCoords = GetEntityCoords(atmEntity)
    local vehicleCoords = GetEntityCoords(vehicle)
    
    local vehicleBack = GetOffsetFromEntityInWorldCoords(vehicle, 0, -2.0, 0.5)
    
    ensure_rope_textures_loaded()

    local ropeLength = #(atmData.atmAttachmentPoint - vehicleBack)
    local rope = AddRope(
        atmData.atmAttachmentPoint.x, atmData.atmAttachmentPoint.y, atmData.atmAttachmentPoint.z,
        0.0, 0.0, 0.0,
        ropeLength,
        0,
        ropeLength,
        ropeLength * 0.8,
        1.0,
        false,
        true,
        false,
        1.0,
        true
    )

    if not DoesRopeExist(rope) then
        cleanup_rope_textures()
        TriggerEvent('pl_atmrobbery:notification', locale('rope_robbery_failed'), 'error')
        return
    end
    

    AttachEntitiesToRope(rope, atmEntity, vehicle, 
        atmData.atmAttachmentPoint.x, atmData.atmAttachmentPoint.y, atmData.atmAttachmentPoint.z-0.2,
        vehicleBack.x, vehicleBack.y, vehicleBack.z-0.2,
        ropeLength, false, false, "", "")
    
    atmData.vehicle = vehicle
    atmData.rope = rope
    atmData.ropeAttached = true
    atmData.vehicleAttachmentPoint = vehicleBack
    
    TriggerEvent('pl_atmrobbery:notification', locale('rope_vehicle_attached'), 'success')
    
    RemoveVehicleRopeTarget(atmEntity)
    
    MonitorVehicleMovement(atmEntity, vehicle)
end

function RemoveVehicleRopeTarget(atmEntity)
    if ropeAttachedATMs[atmEntity] and ropeAttachedATMs[atmEntity].targetedVehicles then
        for _, vehicle in pairs(ropeAttachedATMs[atmEntity].targetedVehicles) do
            if DoesEntityExist(vehicle) then
                if targetResource == 'ox_target' then
                    exports.ox_target:removeEntity(vehicle)
                elseif targetResource == 'qb-target' then
                    exports['qb-target']:RemoveTargetEntity(vehicle)
                end
            end
        end
        ropeAttachedATMs[atmEntity].targetedVehicles = nil
    end
end

function MonitorVehicleMovement(atmEntity, vehicle)
    local initialVehicleCoords = GetEntityCoords(vehicle)
    local initialAtmCoords = GetEntityCoords(atmEntity)
    local distanceMoved = 0
    local requiredDistance = Config.RopeRobbery.RequiredDistance
    
    CreateThread(function()
        while ropeAttachedATMs[atmEntity] and ropeAttachedATMs[atmEntity].ropeAttached do
            Wait(100)
            
            if not DoesEntityExist(vehicle) or not DoesEntityExist(atmEntity) then
                
                ropeAttachedATMs[atmEntity] = nil
                break
            end
            
            local currentVehicleCoords = GetEntityCoords(vehicle)
            local currentAtmCoords = GetEntityCoords(atmEntity)
            
            local vehicleDistance = #(currentVehicleCoords - initialVehicleCoords)
            local atmDisplacement = #(currentAtmCoords - initialAtmCoords)
            
            distanceMoved = vehicleDistance
            
            local ropeLength = #(currentVehicleCoords - currentAtmCoords)
            if ropeLength > Config.RopeRobbery.TautRopeLength then 
                local vehicleVelocity = GetEntityVelocity(vehicle)
                local dragForce = Config.RopeRobbery.DragForce
                local newVelocityX = vehicleVelocity.x * (1 - dragForce)
                local newVelocityY = vehicleVelocity.y * (1 - dragForce)
                
                SetEntityVelocity(vehicle, newVelocityX, newVelocityY, vehicleVelocity.z)
                
                
                if atmDisplacement < 2.0 then
                    local pullDirection = currentVehicleCoords - currentAtmCoords
                    local pullForce = Config.RopeRobbery.ResistanceForce * 0.1
                    local atmVelocity = GetEntityVelocity(atmEntity)
                    
                    SetEntityVelocity(atmEntity, 
                        atmVelocity.x + pullDirection.x * pullForce,
                        atmVelocity.y + pullDirection.y * pullForce,
                        atmVelocity.z
                    )
                end
            end
            
            if distanceMoved >= requiredDistance or atmDisplacement >= 3.0 then
                DetachATM(atmEntity)
                break
            end
        
            if ropeLength > Config.RopeRobbery.MaxRopeLength then
                TriggerEvent('pl_atmrobbery:notification', locale('rope_robbery_failed'), 'error')
                -- Do not delete rope automatically; only stop monitoring
                ropeAttachedATMs[atmEntity] = nil
                break
            end
        end
    end)
end

function DetachATM(atmEntity)
    if not ropeAttachedATMs[atmEntity] then return end
    
    local atmData = ropeAttachedATMs[atmEntity]
    local atmCoords = GetEntityCoords(atmEntity)
    
    DetachEntity(atmEntity, true, true)
    
    SetEntityDynamic(atmEntity, true)
    SetEntityHasGravity(atmEntity, true)
    SetEntityCollision(atmEntity, true, true)
    
    FreezeEntityPosition(atmEntity, true)
    Wait(500)
    FreezeEntityPosition(atmEntity, false)
    
    local vehicleCoords = GetEntityCoords(atmData.vehicle)
    local pullDirection = vehicleCoords - atmCoords
    local pullForce = 8.0 -- Increased force
    
    SetEntityVelocity(atmEntity, 
        pullDirection.x * pullForce, 
        pullDirection.y * pullForce, 
        -5.0 -- Strong downward force
    )
    
    -- Add rotation for dramatic effect
    SetEntityAngularVelocity(atmEntity, 3.0, 3.0, 10.0)
    
    -- Mark ATM as detached and add robbery option
    atmData.detached = true
    atmData.ropeAttached = false
    
    TriggerEvent('pl_atmrobbery:notification', locale('atm_detached'), 'success')
    
    RemoveGlobalATMOptions(atmEntity)
    
    AddDetachedATMTarget(atmEntity, atmCoords, atmData.model)
end

function RemoveGlobalATMOptions(atmEntity)
    if targetResource == 'ox_target' then
        exports.ox_target:removeEntity(atmEntity)
    elseif targetResource == 'qb-target' then
        exports['qb-target']:RemoveTargetEntity(atmEntity)
    end
end

function AddDetachedATMTarget(atmEntity, atmCoords, atmModel)
    if targetResource == 'ox_target' then
        exports.ox_target:addLocalEntity(atmEntity, {
            {
                event = 'pl_atmrobbery_rob_detached',
                icon = 'fas fa-money-bill-wave',
                label = locale('rob_detached_atm'),
                args = {entity = atmEntity, coords = atmCoords, model = atmModel}
            }
        })
    elseif targetResource == 'qb-target' then
        exports['qb-target']:AddTargetEntity(atmEntity, {
            options = {
                {
                    type = "client",
                    event = 'pl_atmrobbery_rob_detached',
                    icon = 'fas fa-money-bill-wave',
                    label = locale('rob_detached_atm'),
                    entity = atmEntity,
                    coords = atmCoords,
                    model = atmModel
                }
            },
            distance = 1.5
        })
    end
end

RegisterNetEvent('pl_atmrobbery_rob_detached')
AddEventHandler('pl_atmrobbery_rob_detached', function(data)
    local entity, atmCoords, atmModel
    
    if targetResource == 'ox_target' then
        entity = data.args.entity
        atmCoords = data.args.coords
        atmModel = data.args.model
    elseif targetResource == 'qb-target' then
        entity = data.entity
        atmCoords = data.coords
        atmModel = data.model
    end
    
    if entity and DoesEntityExist(entity) and ropeAttachedATMs[entity] and ropeAttachedATMs[entity].detached then

        if targetResource == 'ox_target' then
            exports.ox_target:removeEntity(entity)
        elseif targetResource == 'qb-target' then
            exports['qb-target']:RemoveTargetEntity(entity)
        end
        
        local currentAtmCoords = GetEntityCoords(entity)
        
        local originalAtmCoords = ropeAttachedATMs[entity].initialAtmCoords
        MarkATMAsRobbed(originalAtmCoords)
        
        TriggerServerEvent('pl_atmrobbery:rope_robbery_success', currentAtmCoords)
        

        if ropeAttachedATMs[entity] then
            local atmData = ropeAttachedATMs[entity]
            if atmData.rope and DoesRopeExist(atmData.rope) then
                DeleteRope(atmData.rope)
                cleanup_rope_textures()
            end
        end
        CleanupRopeRobbery(entity)
        
        if DoesEntityExist(entity) then
            DeleteEntity(entity)
        end
    end
end)

function CleanupRopeRobbery(atmEntity)
    if ropeAttachedATMs[atmEntity] then
        local atmData = ropeAttachedATMs[atmEntity]
        

        ropeAttachedATMs[atmEntity] = nil
    end
end

function DeleteCashObjects()
    for _, cash in pairs(cashObjects) do
        if targetResource == 'ox_target' then
            exports.ox_target:removeEntity(cash)
        elseif targetResource == 'qb-target' then
            exports['qb-target']:RemoveTargetEntity(cash)
        end
        DeleteEntity(cash)
    end
    cashObjects = {}
end

CreateThread(function()
    while true do
        Wait(5000) -- Check every 5 seconds
        
        local atmEntities = {}
        for _, model in ipairs(Config.AtmModels) do
            local entities = GetGamePool('CObject')
            for _, entity in pairs(entities) do
                if DoesEntityExist(entity) and GetEntityModel(entity) == GetHashKey(model) then
                    table.insert(atmEntities, entity)
                end
            end
        end
        
        for _, entity in pairs(atmEntities) do
            if DoesEntityExist(entity) then
                local coords = GetEntityCoords(entity)
                if IsATMAlreadyRobbed(coords) then
                    -- This ATM is at a robbed location, delete it
                    DeleteEntity(entity)
                end
            end
        end
    end
end)


AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        DeleteCashObjects() 
        for atmEntity, _ in pairs(ropeAttachedATMs) do
            CleanupRopeRobbery(atmEntity)
        end
		cleanup_rope_textures()
    end
end)

