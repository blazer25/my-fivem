local QBCore                  = exports[Config.CoreName]:GetCoreObject()

function PayToSociety(society, amount, senderCitizenid)
    if not Config.DisableQBMagementExports then
        exports[Config.JobManageScript]:AddMoney(society, amount)
    else
        exports[Config.BankingScript]:AddMoney(society, amount, 'Phone invoice')
    end

    for k, v in pairs(QBCore.Functions.GetQBPlayers()) do
        local item = GetPhoneItem(v)

        if item then
            if Config.Inventory == "ox_inventory" then
                if item.metadata.serial ~= nil or item.metadata.serial ~= "" then
                    if v.PlayerData.citizenid == senderCitizenid then
                        TriggerClientEvent("jpr-phonesystem:client:customnotification", v.PlayerData.source, {
                            app = "Custom", -- dont change
                            title = Config.Locales["69"],
                            img = "https://r2.fivemanage.com/PztPJI1MS4DPN1q0LBqaP/ey4BGlT.png",
                            text = Config.Locales["70"]..amount..Config.Locales["3"],
                            time = 2600,
                        })

                        break
                    end
                end
            else
                if item.info.serie ~= nil or item.info.serie ~= "" then
                    if v.PlayerData.citizenid == senderCitizenid then
                        TriggerClientEvent("jpr-phonesystem:client:customnotification", v.PlayerData.source, {
                            app = "Custom", -- dont change
                            title = Config.Locales["69"],
                            img = "https://r2.fivemanage.com/PztPJI1MS4DPN1q0LBqaP/ey4BGlT.png",
                            text = Config.Locales["70"]..amount..Config.Locales["3"],
                            time = 2600,
                        })

                        break
                    end
                end
            end
        end
    end
end

function SendWebhookSocial(app, webhook, message, photo, title, image, color, perfil, mostraravatar)
    local webhook = webhook
    if webhook == '' then
        return
    end

    local headers = {
        ['Content-Type'] = 'application/json'
    }
    local data = nil
    
    if perfil ~= nil and mostraravatar then
        if perfil == '' or perfil == nil or perfil == 'default' then
            perfil = 'https://r2.fivemanage.com/PztPJI1MS4DPN1q0LBqaP/8UaNhbE.png'
        end

        data = {
            ["username"] = app,
            ["embeds"] = {{
                    ["thumbnail"] = {
                        ["url"] = perfil
                    },
                    ["color"] = color
            }}
        }
    else
        data = {
            ["username"] = app,
            ["embeds"] = {{
                    ["color"] = color
            }}
        }
    end

    if image ~= "" and image ~= nil then
        if string.match(image, "%.webm$") then
            data['embeds'][1]['description'] = '**'..title..' ** \n ' ..message..'\n'..image
        else
            data['embeds'][1]['image'] = {['url'] = image}
            data['embeds'][1]['description'] = '**'..title..' ** \n ' ..message
        end
    else
        data['embeds'][1]['description'] = '**'..title..' ** \n ' ..message
    end
    
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode(data), headers)
end

function PegarVeiculosJogadorFunction(citizenid)
    local Veiculos = MySQL.query.await('SELECT * FROM player_vehicles WHERE citizenid = ?', {citizenid})

    if (GetResourceState("jg-advancedgarages") == "started") then
        if Veiculos then
            for k,v in pairs(Veiculos) do
                if v then
                    v.state = v.in_garage
                    v.garage = v.garage_id
                end
            end
        end
    end

    if (GetResourceState("cd-garages") == "started") then
        if Veiculos then
            for k,v in pairs(Veiculos) do
                if v then
                    v.state = v.in_garage
                    v.garage = v.garage_id

                    if v.impound == 1 then
                        v.state = 2
                    end
                end
            end
        end
    end

    if (GetResourceState("RxGarage") == "started") then
        if Veiculos then
            for k,v in pairs(Veiculos) do
                if v then
                    if v.location then
                        v.state = 1
                        v.garage = v.location
                    else
                        v.state = 0
                        v.garage = "Unknown"
                    end

                    if v.impound_till then
                        if v.impound_till > 0 then
                            v.state = 2
                        end
                    end
                end
            end
        end
    end

    return Veiculos
end

RegisterNetEvent('jpr-phonesystem:server:updatevehiclestate', function(plate)
    MySQL.Async.execute('UPDATE player_vehicles SET state = 0 WHERE plate = ?',{plate})
end)

QBCore.Commands.Add(Config.BillingCommand, 'Bill A Player', {{name = 'id', help = 'Player ID'}, {name = 'amount', help = 'Amount'}}, false, function(source, args)
    local biller = QBCore.Functions.GetPlayer(source)
    local billed = QBCore.Functions.GetPlayer(tonumber(args[1]))
    local amount = tonumber(args[2])

    if biller.PlayerData.job.name == "police" or biller.PlayerData.job.name == 'ambulance' or biller.PlayerData.job.name == 'mechanic' then
        if billed ~= nil then
            if biller.PlayerData.citizenid ~= billed.PlayerData.citizenid then
                if amount and amount > 0 then
                    local idunico = tostring(QBCore.Shared.RandomInt(2) .. QBCore.Shared.RandomStr(3) .. QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(4))
                    MySQL.insert(
                        'INSERT INTO jpr_phonesystem_faturas (citizenid, senderCitizenID, amount, society, joblabel, date, idfatura) VALUES (?, ?, ?, ?, ?, now(), ?)',
                        {billed.PlayerData.citizenid, biller.PlayerData.citizenid, amount, biller.PlayerData.job.name,
                         biller.PlayerData.job.label, idunico})

                    TriggerEvent('jpr-phonesystem:server:RefreshBank', billed.PlayerData.source, billed.PlayerData.citizenid)
                    
                    TriggerClientEvent('QBCore:Notify', source, 'Invoice Successfully Sent', 'success')
                    TriggerClientEvent('QBCore:Notify', billed.PlayerData.source, 'New Invoice Received')
                else
                    TriggerClientEvent('QBCore:Notify', source, 'Must Be A Valid Amount Above 0', 'error')
                end
            else
                TriggerClientEvent('QBCore:Notify', source, 'You Cannot Bill Yourself', 'error')
            end
        else
            TriggerClientEvent('QBCore:Notify', source, 'Player Not Online', 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', source, 'No Access', 'error')
    end
end)

RegisterNetEvent('jpr-phonesystem:server:updateJPRHousingSystem', function(plate)
    MySQL.query.await('DELETE FROM jpr_housingsystem_houses_garages WHERE plate = ?', {plate})
end)

QBCore.Functions.CreateCallback('jpr-phonesystem:server:getServerTimeInfos', function(source, cb)
    local date = os.date("%d-%m-%Y")
    local time = os.date("%H:%M:%S")
    
    date = string.gsub(date, "(%d+)-(%d+)-(%d+)", function(day, month, year)
        return day.."-"..tostring(tonumber(month) - 1).."-"..year
    end)
    
    local data = {
        date = date,
        time = time
    }
    cb(data)
end)

QBCore.Functions.CreateCallback('jpr-phonesystem:server:GetInfosForMDT', function(source, cb)
    local vehicles = MySQL.query.await('SELECT * FROM player_vehicles', {})
    local players = MySQL.query.await('SELECT * FROM players', {})
    local houses = MySQL.query.await('SELECT * FROM player_houses', {})

    for k,v in pairs(houses) do
        if v then
            local houseInfo = MySQL.query.await('SELECT * FROM houselocations WHERE name = ?', {v.house})

            if (#houseInfo > 0) then
                v.label = houseInfo[1].label
                v.tier = houseInfo[1].tier

                houseInfo[1].coords = json.decode(houseInfo[1].coords)
                houseInfo[1].coords = json.encode(houseInfo[1].coords.enter)
                
                v.coords = houseInfo[1].coords
            end
        end
    end

    local data = {
        vehicles,
        players,
        houses
    }

    cb(data)
end)

function AntiErrorItemSerialValidation(item, player)
    if Config.UniquePhones then
        if item.info then
            return true
        else
            return false
        end 
    else
        return player.PlayerData.citizenid
    end
end

function ItemSerialValidation(item, player)
    if Config.UniquePhones then
        if item.info.serie ~= nil or item.info.serie ~= "" then
            return true
        else
            return false
        end 
    else
        return player.PlayerData.citizenid
    end
end

function GetSerialFromItem(item, player)
    if Config.UniquePhones then
        if item.info ~= nil then
            if item.info.serie ~= nil or item.info.serie ~= "" then
                return item.info.serie
            else
                return nil
            end
        else
            print("JPResouces - We detected you are using ox_inventory, please set on Config.Inventory = 'ox_inventory'")

            return nil
        end
    else
        return player.PlayerData.citizenid
    end
end

function GetPhoneItem(playerInfos)
    local phone = nil

    if playerInfos then
        for _, phoneItem in ipairs(Config.PhoneItems) do
            local item = playerInfos.Functions.GetItemByName(phoneItem)

            if item then
                phone = item

                break
            end
        end
    end

    return phone
end

function GenerateEmail(xPlayer)
    return xPlayer.PlayerData.charinfo.firstname .. '.' .. xPlayer.PlayerData.charinfo.lastname..""..xPlayer.PlayerData.citizenid..Config.EmailDomain
end

--- needed:
-- citizenid = bill receiver id
-- senderCitizenID = bill sender id
-- amount = bill amount
-- society = (THIS CAN BE NULL "") job name (sender)
-- joblabel = (THIS CAN BE NULL "") job label (sender)
-- idfatura = bill ID

function GetBillingFromPlayer(charID)
    if (GetResourceState("tgg-billing") == "started") then
        local faturas = MySQL.query.await('SELECT * FROM tgg_billing_invoices WHERE recipient_id = ? ORDER BY `timestamp` DESC', {charID})
        local validBills = {}

        if faturas[1] ~= nil then
            for k,v in pairs(faturas) do
                if v.status == "unpaid" then
                    v.citizenid = v.recipient_id
                    v.senderCitizenID = v.sender_id
                    v.amount = v.total
                    v.society = v.sender
                    v.joblabel = v.sender_company_name
                    v.idfatura = v.id

                    table.insert(validBills, v)
                end
            end

            return validBills
        else
            return nil
        end
    elseif (GetResourceState("okokBilling") == "started") then
        local faturas = MySQL.query.await('SELECT * FROM okokbilling WHERE receiver_identifier = ? and status = ?', {charID, 'unpaid'})
        
        if faturas[1] ~= nil then
            for k,v in pairs(faturas) do
                if v then
                    v.citizenid = v.receiver_identifier
                    v.senderCitizenID = v.author_identifier
                    v.amount = v.invoice_value
                    v.joblabel = v.society_name
                    v.idfatura = v.ref_id
                end
            end

            return faturas
        else
            return nil
        end
    elseif (GetResourceState("tgg-billing") == "started") then
        local faturas = MySQL.query.await('SELECT * FROM tgg_billing_invoices WHERE recipient_id = ? and status = ?', {charID, 'unpaid'})
        
        if faturas[1] ~= nil then
            for k,v in pairs(faturas) do
                if v then
                    v.citizenid = v.recipient_id
                    v.senderCitizenID = v.sender_id
                    v.amount = v.total
                    v.joblabel = v.sender_company_name
                    v.idfatura = v.uuid
                    v.society = v.sender
                end
            end

            return faturas
        else
            return nil
        end
    else
        local faturas = MySQL.query.await('SELECT * FROM jpr_phonesystem_faturas WHERE citizenid = ? ORDER BY `date` DESC', {charID})
        
        if faturas[1] ~= nil then
            return faturas
        else
            return nil
        end
    end
end

function RemoveBillingAfterPayment(billID)
    if (GetResourceState("tgg-billing") == "started") then
        MySQL.Async.execute('UPDATE tgg_billing_invoices SET status = ? WHERE id = ?', {"paid", billID})
    elseif (GetResourceState("okokBilling") == "started") then
        MySQL.Async.execute('UPDATE okokbilling SET status = ? WHERE ref_id = ?', {"paid", billID})
    elseif (GetResourceState("tgg-billing") == "started") then
        MySQL.Async.execute('UPDATE tgg_billing_invoices SET status = ? WHERE uuid = ?', {"paid", billID})
    else
        MySQL.Async.execute('DELETE FROM jpr_phonesystem_faturas WHERE idfatura = ?', {billID})
    end
end

-----

function GetPhoneCaseProp(case)
    local phoneCases = {
        phone_case_1 = "scrlt_ip14max_case_01",
        phone_case_2 = "scrlt_ip14max_case_02",
        phone_case_3 = "scrlt_ip14max_case_03",
        phone_case_4 = "scrlt_ip14max_case_04",
        phone_case_5 = "scrlt_ip14max_case_05",
        phone_case_6 = "scrlt_ip14max_case_06",
        phone_case_7 = "scrlt_ip14max_case_07",
        phone_case_8 = "scrlt_ip14max_case_08",
        phone_case_9 = "scrlt_ip14max_case_09",
        phone_case_10 = "scrlt_ip14max_case_10"
    }
    
    return phoneCases[case] or nil
end

function GetCaseItemFromProp(prop)
    local phoneProps = {
        scrlt_ip14max_case_01 = "phone_case_1",
        scrlt_ip14max_case_02 = "phone_case_2",
        scrlt_ip14max_case_03 = "phone_case_3",
        scrlt_ip14max_case_04 = "phone_case_4",
        scrlt_ip14max_case_05 = "phone_case_5",
        scrlt_ip14max_case_06 = "phone_case_6",
        scrlt_ip14max_case_07 = "phone_case_7",
        scrlt_ip14max_case_08 = "phone_case_8",
        scrlt_ip14max_case_09 = "phone_case_9",
        scrlt_ip14max_case_10 = "phone_case_10"
    }
    
    return phoneProps[prop] or nil
end