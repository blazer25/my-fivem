DebugPrint("qb-license server loaded")
---@type LicensesList
local licenseList = {}

for i = 1, #Shared.config.licenses, 1 do
    if not QBCore.Shared.Items[Shared.config.licenses[i]] then
        DebugWarn(Shared.config.licenses[i] .. " not found in items.lua please add into items.lua ")
    else
        licenseList[Shared.config.licenses[i]] = QBCore.Shared.Items[Shared.config.licenses[i]].label or
            'Unknown'
    end
end

for i = 1, #Shared.config.theoryLicenses, 1 do
    if not QBCore.Shared.Items[Shared.config.theoryLicenses[i]] then
        DebugWarn(Shared.config.licenses[i] .. " not found in items.lua please add into items.lua ")
    else
        licenseList[Shared.config.theoryLicenses[i]] = QBCore.Shared.Items[Shared.config.theoryLicenses[i]]
            .label or 'Unknown'
    end
end

RegisterNetEvent('qb-license:integration:server:GiveLicense', function(type)
    local source = source
    local player = Server.GetPlayer(source)

    if player then
        if not Shared.config.examProveAsLicense and IsTheory(type) then
            return Server.GiveTheory(source, type)
        end

        local licenses = player.PlayerData.metadata.licences or {}
        licenses[type] = true
        player.Functions.SetMetaData('licences', licenses)
        local info = {
            firstname = player.PlayerData.charinfo.firstname,
            lastname = player.PlayerData.charinfo.lastname,
            birthdate = player.PlayerData.charinfo.birthdate,
            type = type
        }
        player.Functions.AddItem(type, 1, nil, info)
    end
end)

local function ShowLicense(src, item)
    local playerPed = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(playerPed)
    local players = QBCore.Functions.GetPlayers()
    for _, v in pairs(players) do
        local targetPed = GetPlayerPed(v)
        local dist = #(playerCoords - GetEntityCoords(targetPed))
        if dist < 3.0 then
            TriggerClientEvent('chat:addMessage', v, {
                template =
                '<div class="chat-message advert" style="background: linear-gradient(to right, rgba(5, 5, 5, 0.6), #657175); display: flex;"><div style="margin-right: 10px;"><i class="far fa-id-card" style="height: 100%;"></i><strong> {0}</strong><br> <strong>First Name:</strong> {1} <br><strong>Last Name:</strong> {2} <br><strong>Birth Date:</strong> {3} <br><strong>Licenses:</strong> {4}</div></div>',
                args = {
                    'Drivers License',
                    item.info.firstname,
                    item.info.lastname,
                    item.info.birthdate,
                    item.info.type
                }
            }
            )
        end
    end
end

RegisterNetEvent('qb-inventory:server:useItem', function(item)
    local src = source
    local itemData = exports["qb-inventory"]:GetItemBySlot(src, item.slot)
    if not itemData then return end
    local itemInfo = QBCore.Shared.Items[itemData.name]
    for i = 1, #Shared.config.licenses, 1 do
        if itemData.name == Shared.config.licenses[i] then
            exports["qb-inventory"]:UseItem(itemData.name, src, itemData)
            TriggerClientEvent('qb-inventory:client:ItemBox', source, itemInfo, 'use')
            ShowLicense(src, itemData)
        end
    end

    for i = 1, #Shared.config.theoryLicenses, 1 do
        if itemData.name == Shared.config.theoryLicenses[i] then
            exports["qb-inventory"]:UseItem(itemData.name, src, itemData)
            TriggerClientEvent('qb-inventory:client:ItemBox', source, itemInfo, 'use')
            ShowLicense(src, itemData)
        end
    end
end)

lib.callback.register('driveschool:server:GetLicensesList', function(source, type)
    return licenseList
end)

if Shared.config.debug then
    RegisterCommand('removelicensesqb', function(source, args, rawCommand)
        local player = Server.GetPlayer(source)
        if player then
            local licenses = player.PlayerData.metadata.licences or {}
            for k, v in pairs(licenses) do
                player.Functions.RemoveItem(k, 1)
                licenses[k] = nil
            end
            player.Functions.SetMetaData('licences', licenses)
        end
    end, false)
end
