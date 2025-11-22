local QBCore                  = exports[Config.CoreName]:GetCoreObject() 

function RemoveMoney(moneyType, xPlayer, money)
    xPlayer.Functions.RemoveMoney(moneyType, money, "Housing")

    if Config.UseRealEstateAccounts then
        exports[Config.JobManageScript]:AddMoney(Config.RealEstateJob, money)
    end
end

function UpdateOutsideVehicles(netId, plate, veh)
    TriggerEvent("jpr-crewsystem:server:atualizargaragem", plate, veh)
end

function AddMoney(moneyType, xPlayer, money)
    xPlayer.Functions.AddMoney(moneyType, money, "Housing Selling")

    if Config.UseRealEstateAccounts then
        exports[Config.JobManageScript]:RemoveMoney(Config.RealEstateJob, money)
    end
end

QBCore.Functions.CreateUseableItem("lockpick", function(source)
    TriggerClientEvent("lockpicks:UseLockpick", source, false)
end)

QBCore.Functions.CreateUseableItem("advancedlockpick", function(source)
    TriggerClientEvent("lockpicks:UseLockpick", source, true)
end)

QBCore.Functions.CreateUseableItem('police_stormram', function(source, _)
    local Player = QBCore.Functions.GetPlayer(source)
    
    if CheckPoliceJob(Player) then
        if Config.AllowPoliceRaids then
            TriggerClientEvent('jpr-housingsystem:client:HomeInvasion', source)
        end
    else
        TriggerClientEvent('QBCore:Notify', source, Config.Locales["105"], 'error')
    end
end)

function discordLog(name, message)
    local data = {
        {
            ["color"] = '3553600',
            ["title"] = "**".. name .."**",
            ["description"] = message,
        }
    }
    PerformHttpRequest(Config.DiscordWebhook, function(err, text, headers) end, 'POST', json.encode({username = "JPR Housing System", embeds = data, avatar_url = "https://i.imgur.com/pSykl7F.jpg"}), { ['Content-Type'] = 'application/json' })
end

QBCore.Functions.CreateCallback("jpr-housingsystem:server:checkOwnership", function(source, cb, plate, house)
    local src = source
    local pData = QBCore.Functions.GetPlayer(src)

    MySQL.query('SELECT * FROM '..Config.VehiclesTable..' WHERE plate = "'..plate..'"', function (result)
		if result[1] == nil  then
			cb(false)
		else
            local houseRow = MySQL.Sync.fetchAll('SELECT * FROM jpr_housingsystem_houses WHERE houseName = ?', {house.houseName})
            local temKey = false

            if #houseRow > 0 then
                for k, v in pairs(houseRow) do
                    if houseRow[k] then
                        if houseRow[k].keyholders then
                            houseRow[k].keyholders = json.decode(houseRow[k].keyholders)
                            for i, v in pairs(houseRow[k].keyholders) do
                                if v then
                                    if v == result[1].citizenid then
                                        temKey = true

                                        break
                                    end
                                end
                            end
                        end
                    end

                    if temKey then
                        break
                    end
                end
            end

            if temKey then
                cb(true)
            else
                cb(false)
            end
		end
	end) 
end)

QBCore.Functions.CreateCallback('jpr-housingsystem:server:VerificarKeyholders', function(playerId, cb, citizenID, data, apart_id)
	local src = source
    local newHolders = {}
    local oldHolders = nil

    if apart_id then
        oldHolders = MySQL.query.await('SELECT keyholders FROM jpr_housingsystem_houses WHERE houseName = ? and apart_id = ?', {data.CasaAtual.houseName, apart_id})
    else
        oldHolders = MySQL.query.await('SELECT keyholders FROM jpr_housingsystem_houses WHERE houseName = ?', {data.CasaAtual.houseName})
    end

    local existe = false
    if QBCore.Functions.GetPlayer(tonumber(citizenID)) then
        citizenID = QBCore.Functions.GetPlayer(tonumber(citizenID))
        citizenID = citizenID.PlayerData.citizenid

        if oldHolders[1] then
            oldHolders = json.decode(oldHolders[1].keyholders)
            for k, _ in pairs(oldHolders) do
                if oldHolders[k] == citizenID then
                    existe = true
                end
            end
        end
    
        -----
        local haveAppKey = false
        local Appartment = MySQL.query.await('SELECT * FROM jpr_housingsystem_houses WHERE houseName = ?', {data.CasaAtual.houseName})
    
        for k, _ in pairs(Appartment) do
            if Appartment[k] then
                local Holders = json.decode(Appartment[k].keyholders)
                for i, _ in pairs(Holders) do
                    if Holders[i] == citizenID then
                        haveAppKey = true
    
                        break
                    end
                end
    
                if haveAppKey then
                    break
                end
            end
        end
    
        ---
    
        if existe or haveAppKey then
            cb(false)
        else
            if oldHolders then
                table.insert(oldHolders, citizenID)
    
                if (data.CasaAtual.shared == true or data.CasaAtual.shared == 1) then
                    local src = playerId
                    local xPlayer =  QBCore.Functions.GetPlayer(playerId)
                    local cid = xPlayer.PlayerData.citizenid
            
                    local apart_id = GetApartIDFromHouseID(data.CasaAtual.houseName, cid)
                    if apart_id then
                        MySQL.update('UPDATE jpr_housingsystem_houses SET keyholders = ? WHERE apart_id = ?', {json.encode(oldHolders), apart_id})
    
                        discordLog(citizenID ..  '', Config.Locales["77"].. data.CasaAtual.houseName.." - "..apart_id)
    
                        local xPlayerHolder = QBCore.Functions.GetPlayerByCitizenId(citizenID)
                        if xPlayerHolder then
                            TriggerClientEvent("jpr-housingsystem:client:updateTargets", xPlayerHolder.PlayerData.source)
                        end
                    end
                else
                    MySQL.update('UPDATE jpr_housingsystem_houses SET keyholders = ? WHERE houseName = ?', {json.encode(oldHolders), data.CasaAtual.houseName})
            
                    local xPlayerHolder = QBCore.Functions.GetPlayerByCitizenId(citizenID)
                    if xPlayerHolder then
                        TriggerClientEvent("jpr-housingsystem:client:updateTargets", xPlayerHolder.PlayerData.source)
                    end
    
                    discordLog(citizenID ..  '', Config.Locales["77"].. data.CasaAtual.houseName)
                end
            end
    
            cb(true)
        end
    else
        print("Housing System - JPResources - Error Code 2")
    end
end)

if Config.Inventory == "ox_inventory" then
    AddEventHandler('onResourceStart', function()
        Wait(15000)
        local houses = MySQL.Sync.fetchAll('SELECT * FROM jpr_housingsystem_houses', {})
        if #houses > 0  then
            for k, v in pairs(houses) do
                if houses[k] then
                    if Config.DebugOX then
                        print("created: ".."stash"..houses[k].stashName)
                    end

                    local slots = Config.StashLevel[""..houses[k].stashLevel..""].slots
                    local maxweight = Config.StashLevel[""..houses[k].stashLevel..""].kg
                    
                    if Config.CustomStashLevels[houses[k].houseName] then
                        if houses[k].stashLevel > Config.CustomStashLevels[houses[k].houseName].MaxLevelStash then
                            slots = Config.CustomStashLevels[houses[k].houseName].StashLevel[Config.CustomStashLevels[houses[k].houseName].MaxLevelStash].slots
                            maxweight = Config.CustomStashLevels[houses[k].houseName].StashLevel[Config.CustomStashLevels[houses[k].houseName].MaxLevelStash].kg
                        else
                            slots = Config.CustomStashLevels[houses[k].houseName].StashLevel[""..houses[k].stashLevel..""].slots
                            maxweight = Config.CustomStashLevels[houses[k].houseName].StashLevel[""..houses[k].stashLevel..""].kg
                        end
                    end
                    
                    exports.ox_inventory:RegisterStash(houses[k].stashName, houses[k].stashName, slots, maxweight)
                end
            end
        end
    end)
end

function GetHouseStashItems(stashName)
    local items = nil
    local temitems = nil

    if string.find(stashName, "house_house_") then
        stashName = string.gsub(stashName, "house_house_", "apartment_")
    end

    if (Config.Inventory == "ox_inventory") then
        local itemsJarda = exports.ox_inventory:GetInventoryItems(stashName, false)
     
        if itemsJarda  then
            local itemsarmario = {}
            for i = 1, #itemsJarda, 1 do
                if itemsJarda[i] then
                   
                    itemsarmario[i] = {
                        name = itemsJarda[i].name,
                        amount = itemsJarda[i].count,
                        label = itemsJarda[i].label,
                    }
                end
            end

            if itemsarmario[1] then
               
                temitems = itemsarmario
            end
        end
    else
        if Config.UsingNewQBInv then
            items = MySQL.scalar.await('SELECT items FROM inventories WHERE identifier = ?', {stashName})
        elseif Config.Inventory == "codem-inventory" then
            items = exports['codem-inventory']:GetStashItems(stashName)
        else
            items = MySQL.scalar.await('SELECT items FROM stashitems WHERE stash = ?', {stashName})
        end
        
        if items ~= nil  then
            local stashItems = items

            if Config.Inventory ~= "codem-inventory" then
                stashItems = json.decode(items)
            end
            
            local itemsarmario = {}
            if stashItems then
                for _, item in pairs(stashItems) do
                    local itemInfo = QBCore.Shared.Items[item.name:lower()]
                    if itemInfo then
                        itemsarmario[item.slot] = {
                            name = itemInfo["name"],
                            amount = tonumber(item.amount),
                            info = item.info or "",
                            label = itemInfo["label"],
                            description = itemInfo["description"] or "",
                            weight = itemInfo["weight"],
                            type = itemInfo["type"],
                            unique = itemInfo["unique"],
                            useable = itemInfo["useable"],
                            image = itemInfo["image"],
                            slot = item.slot,
                        }
                    end
                end
            end

            temitems = itemsarmario
        end
    end

    return temitems
end

QBCore.Commands.Add(Config.RealEstateCommand, Config.Locales["37"], {}, false, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == Config.RealEstateJob then
        TriggerClientEvent("jpr-housingsystem:client:abrirMenuRealEstate", Player.PlayerData.source)
    else
        TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Config.Locales["38"], "error")
    end
end)

QBCore.Commands.Add(Config.RealEstateTierCommand, Config.Locales["38"], {}, false, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == Config.RealEstateJob then
        TriggerClientEvent("jpr-housingsystem:client:abrirMenuRealEstateTier", Player.PlayerData.source)
    else
        TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Config.Locales["38"], "error")
    end
end)

QBCore.Commands.Add(Config.RealEstateDoorCommand, Config.Locales["102"], {}, false, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == Config.RealEstateJob then
        TriggerClientEvent("jpr-housingsystem:client:abrirMenuRealEstateDoor", Player.PlayerData.source)
    else
        TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Config.Locales["38"], "error")
    end
end)

local contador = 1
QBCore.Commands.Add(Config.SellHouseCommand, Config.Locales["43"], {}, false, function(source, args)
    local src = source
    
    TriggerEvent("jpr-housingsystem:server:sellHouseCommand", src)
end)

QBCore.Commands.Add(Config.DeleteHouseCommand, Config.Locales["48"], {}, false, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local cid = Player.PlayerData.citizenid

    if Player.PlayerData.job.name == Config.RealEstateJob then
        TriggerClientEvent("jpr-housingsystem:client:deleteHouse", Player.PlayerData.source)

        discordLog(cid ..  '', Config.Locales["65"])
    else
        TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Config.Locales["38"], "error")
    end
end)

RegisterNetEvent('jpr-housingsystem:server:sellHouseCommand', function(src)
    local Player = QBCore.Functions.GetPlayer(src)
    local cid = Player.PlayerData.citizenid

    if contador == 2 then
        contador = 1 
        TriggerClientEvent("jpr-housingsystem:client:venderCasaAtual", Player.PlayerData.source)

        discordLog(cid ..  '', Config.Locales["64"])
    else
        contador = contador + 1
        TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Config.Locales["44"])
        Wait(25000)
        contador = 1
    end
end)

RegisterNetEvent('jpr-housingsystem:server:updateVehicleState', function(state, plate)
    if GetResourceState('jg-advancedgarages') == 'started' then
        MySQL.update('UPDATE '..Config.VehiclesTable..' SET in_garage = ? WHERE plate = ?', {state, plate})
    else
        MySQL.update('UPDATE '..Config.VehiclesTable..' SET state = ? WHERE plate = ?', {state, plate})
    end
end)

function updateVehicleGarage(houseInfos, infos)
    if GetResourceState('jg-advancedgarages') == 'started' then
        MySQL.update('UPDATE '..Config.VehiclesTable..' SET garage_id = ?, in_garage = 1 WHERE plate = ?', {houseInfos.houseName, infos.plate})
    else
        MySQL.update('UPDATE '..Config.VehiclesTable..' SET garage = ?, state = 1 WHERE plate = ?', {houseInfos.houseName, infos.plate})
    end
end

RegisterNetEvent("jpr-housingsystem:server:UsingNewQBInv")
AddEventHandler("jpr-housingsystem:server:UsingNewQBInv",function(name, infos)
    local src = source

    if src then
        exports['qb-inventory']:OpenInventory(src, name, {
            maxweight = infos.maxweight,
            slots = infos.slots,
            label = name
        })
    end
end)

function LogoutPlayer(src)
    TriggerClientEvent('qb-multicharacter:client:chooseChar', src)
end

function CheckPoliceJob(xPlayer)
    return (xPlayer.PlayerData.job.name == 'police' and xPlayer.PlayerData.job.onduty)
end