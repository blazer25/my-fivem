function CreateTargetZone(zoneName, coords, options)
    RemoveTargetZone(zoneName)
    
    if coords then
        if Config.TargetScript == "ox-target" or Config.TargetScript == "ox_target" then
            RemoveTargetZone(zoneName)
            Citizen.Wait(1)

            parameters = {
                coords = coords,
                size = vector3(5.5, 4, 2),
                name = "casinoSystem-"..zoneName,
                rotation = -72,
                options = options,
                distance = 1.5
            }
            
            exports.ox_target:addBoxZone(parameters)
        else
            RemoveTargetZone(zoneName)
            Citizen.Wait(1)
            
            exports[Config.TargetScript]:AddBoxZone("casinoSystem-"..zoneName, coords, 5.5, 4, {
                name = "casinoSystem-"..zoneName,
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
        exports[Config.TargetScript]:removeZone("casinoSystem-"..zoneName)
    else
        exports[Config.TargetScript]:RemoveZone("casinoSystem-"..zoneName)
    end
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

function Notify(message, notifType)
    QBCore.Functions.Notify(message, notifType)
end

function RequestAnimDictCasino(anim)
    RequestAnimDict(dict)
end

function RequestTheModel(model)
	RequestModel(model)
	while not HasModelLoaded(model) do
		Wait(0)
	end
end

function GetItemCount(item)
    if (GetResourceState("ox_inventory") == "started") then
        return exports.ox_inventory:Search('count', item) or 0
    else
        local player = QBCore.Functions.GetPlayerData()
        local amount = 0

        for _, v in ipairs(player.items) do
            if v.name == item then
                amount = amount + v.amount
            end
        end

        return amount
    end
end

function OpenSlotsMenu(options)
    -- Request the buttons GFX to be loaded
    local ButtonsHandle = RequestScaleformMovie('INSTRUCTIONAL_BUTTONS')

    -- Wait for the buttons GFX to be fully loaded
    while not HasScaleformMovieLoaded(ButtonsHandle) do
        Wait(0)
    end

    -- Clear previous buttons
    CallScaleformMovieMethod(ButtonsHandle, 'CLEAR_ALL')
    -- Disable mouse buttons
    CallScaleformMovieMethodWithNumber(ButtonsHandle, 'TOGGLE_MOUSE_BUTTONS', 0)

    -- Define button configurations (E, R, ENTER, SETA)
    local buttons = {
        {icon = '', text = Config.Locales["8"]..tostring(GetItemCount(Config.CasinoItemName)).."x"},
        {icon = '~INPUT_CONTEXT~', text = Config.Locales["4"]},       -- E
        {icon = '~INPUT_RELOAD~', text = Config.Locales["5"]},       -- R
        {icon = '~INPUT_FRONTEND_ACCEPT~', text = Config.Locales["6"]}, -- ENTER
        {icon = '~INPUT_CELLPHONE_LEFT~', text = Config.Locales["7"]}, -- SETA (esquerda, como exemplo)
    }

    -- Add each button configuration to Scaleform
    for index, button in ipairs(buttons) do
        BeginScaleformMovieMethod(ButtonsHandle, 'SET_DATA_SLOT')
        ScaleformMovieMethodAddParamInt(index - 1) -- Slot index
        ScaleformMovieMethodAddParamPlayerNameString(button.icon) -- Icon
        ScaleformMovieMethodAddParamPlayerNameString(button.text) -- Text
        EndScaleformMovieMethod()
    end

    -- Sets buttons ready to be drawn
    CallScaleformMovieMethod(ButtonsHandle, 'DRAW_INSTRUCTIONAL_BUTTONS')

    -- Unload the scaleform movie after enter has been pressed
    --SetScaleformMovieAsNoLongerNeeded(ButtonsHandle)

    return ButtonsHandle
end

function GetVehicleProperties(...)
    return QBCore.Functions.GetVehicleProperties(...)
end

function SpawnVehicle(vehInfo, coords, warp)
    local veh = CreateVehicle(vehInfo.vehicle, coords.x, coords.y, coords.z, coords.w, true, false)
    local netid = NetworkGetNetworkIdFromEntity(veh)
    SetVehicleHasBeenOwnedByPlayer(veh, true)
    SetNetworkIdCanMigrate(netid, true)
    SetVehicleNeedsToBeHotwired(veh, false)
    SetVehRadioStation(veh, 'OFF')
    SetModelAsNoLongerNeeded(vehInfo.vehicle)
    SetEntityHeading(veh, coords.w)
    TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
 
    return veh, netid
end

function GiveKeys(plate, veh)
    TriggerEvent("vehiclekeys:client:SetOwner", plate)
end

function OpenBlackJackInteractions(time, bet, amount)
    -- Request the buttons GFX to be loaded
    local ButtonsHandle = RequestScaleformMovie('INSTRUCTIONAL_BUTTONS')

    -- Wait for the buttons GFX to be fully loaded
    while not HasScaleformMovieLoaded(ButtonsHandle) do
        Wait(0)
    end

    -- Clear previous buttons
    CallScaleformMovieMethod(ButtonsHandle, 'CLEAR_ALL')
    -- Disable mouse buttons
    CallScaleformMovieMethodWithNumber(ButtonsHandle, 'TOGGLE_MOUSE_BUTTONS', 0)

    -- Define button configurations (E, R, ENTER, SETA)
    local buttons = {
        {icon = '~INPUT_FRONTEND_ACCEPT~', text = Config.Locales["25"]},
        {icon = '~INPUT_CELLPHONE_UP~', text = Config.Locales["26"]},     
        {icon = '~INPUT_CELLPHONE_DOWN~', text = Config.Locales["31"]},    
        {icon = '~INPUT_CELLPHONE_CANCEL~', text = Config.Locales["27"]},     

        {icon = '', text = Config.Locales["28"]..time},
        {icon = '', text = Config.Locales["29"]..bet},
        {icon = '', text = Config.Locales["30"]..amount},
    }

    -- Add each button configuration to Scaleform
    for index, button in ipairs(buttons) do
        BeginScaleformMovieMethod(ButtonsHandle, 'SET_DATA_SLOT')
        ScaleformMovieMethodAddParamInt(index - 1) -- Slot index
        ScaleformMovieMethodAddParamPlayerNameString(button.icon) -- Icon
        ScaleformMovieMethodAddParamPlayerNameString(button.text) -- Text
        EndScaleformMovieMethod()
    end

    -- Sets buttons ready to be drawn
    CallScaleformMovieMethod(ButtonsHandle, 'DRAW_INSTRUCTIONAL_BUTTONS')

    -- Unload the scaleform movie after enter has been pressed
    --SetScaleformMovieAsNoLongerNeeded(ButtonsHandle)

    return ButtonsHandle
end
            
function HitStandMenu()
    exports[Config.MenuScript]:openMenu({
        {
            id = 1,
            header = "Casino System",
            isMenuHeader = true,
        },
        {
            id = 2,
            header = Config.Locales["39"],
            params = {
                event = 'jpr-casinosystem:client:blackjackMenu',
                args = 1,
            }
        },
        {
            id = 3,
            header = Config.Locales["40"],
            params = {
                event = "jpr-casinosystem:client:blackjackMenu",
                args = 2,
            }
        },

    })
end

function HitStandDoubleMenu()
    exports[Config.MenuScript]:openMenu({
        {
            id = 1,
            header = "Casino System",
            isMenuHeader = true,
        },
        {
            id = 2,
            header = Config.Locales["39"],
            params = {
                event = 'jpr-casinosystem:client:blackjackMenu',
                args = 1,
            }
        },
        {
            id = 3,
            header = Config.Locales["40"],
            params = {
                event = "jpr-casinosystem:client:blackjackMenu",
                args = 2,
            }
        },
        {
            id = 4,
            header = Config.Locales["42"],
            params = {
                event = "jpr-casinosystem:client:blackjackMenu",
                args = 3,
            }
        },

    })
end

function HitSplitMenu()
    exports[Config.MenuScript]:openMenu({
        {
            id = 1,
            header = "Casino System",
            isMenuHeader = true,
        },
        {
            id = 2,
            header = Config.Locales["39"],
            params = {
                event = 'jpr-casinosystem:client:blackjackMenu',
                args = 1,
            }
        },
        {
            id = 3,
            header = Config.Locales["43"],
            params = {
                event = "jpr-casinosystem:client:blackjackMenu",
                args = 4,
            }
        },

    })
end

function OpenRouletteInteractions(time, bet, amount)
    -- Request the buttons GFX to be loaded
    local ButtonsHandle = RequestScaleformMovie('INSTRUCTIONAL_BUTTONS')

    -- Wait for the buttons GFX to be fully loaded
    while not HasScaleformMovieLoaded(ButtonsHandle) do
        Wait(0)
    end

    -- Clear previous buttons
    CallScaleformMovieMethod(ButtonsHandle, 'CLEAR_ALL')
    -- Disable mouse buttons
    CallScaleformMovieMethodWithNumber(ButtonsHandle, 'TOGGLE_MOUSE_BUTTONS', 0)

    -- Define button configurations (E, R, ENTER, SETA)
    local buttons = {
        {icon = '~INPUT_VEH_ATTACK~', text = Config.Locales["25"]},
        {icon = '~INPUT_CELLPHONE_UP~', text = Config.Locales["26"]},     
        {icon = '~INPUT_CELLPHONE_DOWN~', text = Config.Locales["31"]},    
        {icon = '~INPUT_CELLPHONE_CANCEL~', text = Config.Locales["27"]},     

        {icon = '', text = Config.Locales["28"]..time},
        {icon = '', text = Config.Locales["29"]..bet},
        {icon = '', text = Config.Locales["30"]..amount},
    }

    -- Add each button configuration to Scaleform
    for index, button in ipairs(buttons) do
        BeginScaleformMovieMethod(ButtonsHandle, 'SET_DATA_SLOT')
        ScaleformMovieMethodAddParamInt(index - 1) -- Slot index
        ScaleformMovieMethodAddParamPlayerNameString(button.icon) -- Icon
        ScaleformMovieMethodAddParamPlayerNameString(button.text) -- Text
        EndScaleformMovieMethod()
    end

    -- Sets buttons ready to be drawn
    CallScaleformMovieMethod(ButtonsHandle, 'DRAW_INSTRUCTIONAL_BUTTONS')

    -- Unload the scaleform movie after enter has been pressed
    --SetScaleformMovieAsNoLongerNeeded(ButtonsHandle)

    return ButtonsHandle
end

function OpenPokerInteractions()
    -- Request the buttons GFX to be loaded
    local ButtonsHandle = RequestScaleformMovie('INSTRUCTIONAL_BUTTONS')

    -- Wait for the buttons GFX to be fully loaded
    while not HasScaleformMovieLoaded(ButtonsHandle) do
        Wait(0)
    end

    -- Clear previous buttons
    CallScaleformMovieMethod(ButtonsHandle, 'CLEAR_ALL')
    -- Disable mouse buttons
    CallScaleformMovieMethodWithNumber(ButtonsHandle, 'TOGGLE_MOUSE_BUTTONS', 0)

    -- Define button configurations (E, R, ENTER, SETA)
    local buttons = {
        {icon = '~INPUT_VEH_ATTACK~', text = Config.Locales["25"]},
        {icon = '~INPUT_CELLPHONE_UP~', text = Config.Locales["26"]},     
        {icon = '~INPUT_CELLPHONE_DOWN~', text = Config.Locales["31"]},    
        {icon = '~INPUT_CELLPHONE_CANCEL~', text = Config.Locales["27"]},     
    }

    -- Add each button configuration to Scaleform
    for index, button in ipairs(buttons) do
        BeginScaleformMovieMethod(ButtonsHandle, 'SET_DATA_SLOT')
        ScaleformMovieMethodAddParamInt(index - 1) -- Slot index
        ScaleformMovieMethodAddParamPlayerNameString(button.icon) -- Icon
        ScaleformMovieMethodAddParamPlayerNameString(button.text) -- Text
        EndScaleformMovieMethod()
    end

    -- Sets buttons ready to be drawn
    CallScaleformMovieMethod(ButtonsHandle, 'DRAW_INSTRUCTIONAL_BUTTONS')

    -- Unload the scaleform movie after enter has been pressed
    --SetScaleformMovieAsNoLongerNeeded(ButtonsHandle)

    return ButtonsHandle
end

function table.contains(table, element)
    for _, value in ipairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

local function OpenCasinoMenu(entries)
    if not entries or #entries == 0 then return end

    local contextId = ('casino-menu-%s'):format(GetGameTimer())
    local title = 'Casino System'
    local options = {}

    for _, entry in ipairs(entries) do
        if entry.isMenuHeader then
            title = entry.header or title
        else
            local optionTitle = entry.header or entry.label or 'Option'
            local description = entry.txt
            options[#options + 1] = {
                title = optionTitle,
                description = description,
                onSelect = function()
                    local params = entry.params or {}
                    if params.serverEvent then
                        TriggerServerEvent(params.serverEvent, params.args)
                    elseif params.event then
                        TriggerEvent(params.event, params.args)
                    end
                end
            }
        end
    end

    if #options == 0 then return end

    lib.registerContext({
        id = contextId,
        title = title,
        options = options
    })
    lib.showContext(contextId)
end

RegisterNetEvent('jpr-casinosystem:client:useBar', function(args)
    local barMenu = {}

    if args.args then
        for k,v in pairs(args.args.items) do
            v.pedID = args.args.pedID

            local tempVar = {
                id = k,
                header = v.label,
                txt = Config.Locales["112"]..v.value..Config.Locales["103"],
                params = {
                    event = 'jpr-casinosystem:client:buyBarItem',
                    args = {v},
                }
            }

            table.insert(barMenu, tempVar)
        end
    end

    OpenCasinoMenu(barMenu)
end)

RegisterNetEvent('jpr-casinosystem:client:exchange',function()
    OpenCasinoMenu({
        {
            id = 1,
            header = Config.Locales["104"],
            isMenuHeader = true,
        },
        {
            id = 2,
            header = Config.Locales["100"],
            txt = Config.Locales["102"]..Config.ChipsExchange.moneyPerChip..Config.Locales["103"],
            params = {
                event = "jpr-casinosystem:client:buyChips",
            }
        },
        {
            id = 3,
            header = Config.Locales["101"],
            txt = Config.Locales["98"]..Config.ChipsExchange.moneyPerChip..Config.Locales["103"]..Config.Locales["99"],
            params = {
                event = 'jpr-casinosystem:client:exchangeChips',
            }
        },
    })
end)

RegisterNetEvent('jpr-casinosystem:client:memberships',function()
    local memberMenu = {}

    if Config.Memberships then
        for k,v in pairs(Config.Memberships.items) do
            v.pedID = Config.Memberships.pedID

            local tempVar = {
                id = k,
                header = v.label,
                params = {
                    event = 'jpr-casinosystem:client:buyCasinoExtra',
                    args = {v},
                }
            }

            table.insert(memberMenu, tempVar)
        end
    end

    OpenCasinoMenu(memberMenu)
end)

RegisterNetEvent('jpr-casinosystem:client:exchangeChips',function()
    TriggerServerEvent('jpr-casinosystem:server:exchangeChips', GetItemCount(Config.CasinoItemName), Config.ChipsExchange.pedID)
end)

RegisterNetEvent('jpr-casinosystem:client:buyBarItem',function(v)
    local item = v[1]

    if item.item then
        TriggerServerEvent("jpr-casinosystem:server:buyCasinoBar", item)
    else
        Notify(Config.Locales["58"], "error")
    end
end)

RegisterNetEvent('jpr-casinosystem:client:buyCasinoExtra', function(v)
    local item = v[1]

    if item.item then
        if (GetItemCount(item.item) > 0) then
            Notify(Config.Locales["107"], "error")
        else
            TriggerServerEvent("jpr-casinosystem:server:buyCasinoExtra", item)
        end
    else
        Notify(Config.Locales["58"], "error")
    end
end)

RegisterNetEvent('jpr-casinosystem:client:buyChips',function()
    local number = exports["jpr-libs"]:ShowInput({
        header = Config.Locales["110"],
        inputs = {
            {
                type = 'number',
                isRequired = true,
                name = 'number',
                text = "1"
            }
        }
    })

    if number and tonumber(number.number) > 0 then
        TriggerServerEvent("jpr-casinosystem:server:buyCasinoCoins", number, Config.ChipsExchange.pedID)
    else
        Notify(Config.Locales["114"], "error")
    end
end)

RegisterNetEvent('jpr-casinosystem:client:pedCasinoAnimate',function(pedID)
    if pedID then
        RequestAnimDict('mp_common')
        TaskPlayAnim(pedID, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 2, 0, false, false, false)
        Wait(1500)
        ClearPedTasks(pedID)
    end
end)

function CreateBlips()
    local blip = AddBlipForCoord(Config.CasinoCoords.x, Config.CasinoCoords.y, Config.CasinoCoords.z)

    SetBlipSprite(blip, 679)
    SetBlipDisplay(blip, 4)
    SetBlipScale  (blip, 0.8)
    SetBlipAsShortRange(blip, true)
    SetBlipColour(blip, 0)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Config.Locales["113"])
    EndTextCommandSetBlipName(blip)
end