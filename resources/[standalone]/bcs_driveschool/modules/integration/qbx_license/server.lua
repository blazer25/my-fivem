DebugPrint("qbx_license server loaded")
---@type LicensesList
local licenseList = {}
local qbx = exports.qbx_core
local ox_inventory = exports.ox_inventory
local items = ox_inventory:Items()

for i = 1, #Shared.config.licenses, 1 do
    if not items[Shared.config.licenses[i]] then
        DebugWarn(Shared.config.licenses[i] .. " not found in items.lua please add into items.lua ")
    else
        licenseList[Shared.config.licenses[i]] = items[Shared.config.licenses[i]].label or
            'Unknown'
    end
end

for i = 1, #Shared.config.theoryLicenses, 1 do
    if not items[Shared.config.theoryLicenses[i]] then
        DebugWarn(Shared.config.licenses[i] .. " not found in items.lua please add into items.lua ")
    else
        licenseList[Shared.config.theoryLicenses[i]] = items[Shared.config.theoryLicenses[i]]
            .label or 'Unknown'
    end
end

RegisterNetEvent('qbx_license:integration:server:GiveLicense', function(type)
    local source = source
    local player = qbx:GetPlayer(source)
    if player then
        if not Shared.config.examProveAsLicense and IsTheory(type) then
            return Server.GiveTheory(source, type)
        end

        local licenses = qbx:GetMetadata(source, 'licenses') or {}
        licenses[type] = true
        qbx:SetMetadata(source, 'licenses', licenses)
        local info = {
            firstname = player.PlayerData.charinfo.firstname,
            lastname = player.PlayerData.charinfo.lastname,
            birthdate = player.PlayerData.charinfo.birthdate,
            type = type
        }
        ox_inventory:AddItem(source, type, 1, info)
    end
end)

local function ShowLicense(src, label, data)
    local playerPed = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(playerPed)
    local players = GetPlayers()
    for _, v in pairs(players) do
        local targetPed = GetPlayerPed(v)
        local dist = #(playerCoords - GetEntityCoords(targetPed))
        if dist < 3.0 then
            TriggerClientEvent('chat:addMessage', v --[[@as number]], {
                template =
                '<div class="chat-message advert" style="background: linear-gradient(to right, rgba(5, 5, 5, 0.6), #657175); display: flex;"><div style="margin-right: 10px;"><i class="far fa-id-card" style="height: 100%;"></i><strong> {0}</strong><br> <strong>First Name:</strong> {1} <br><strong>Last Name:</strong> {2} <br><strong>Birth Date:</strong> {3} <br><strong>Licenses:</strong> {4}</div></div>',
                args = {
                    label,
                    data.firstname,
                    data.lastname,
                    data.birthdate,
                    data.type
                }
            }
            )
        end
    end
end

exports('ShowLicense', function(event, item, inventory, slot, data)
    if event == 'usingItem' then
        local label = inventory.items[slot].label
        local metadata = inventory.items[slot].metadata
        if metadata then
            ShowLicense(inventory.id, label, metadata)
        else
            print('No metadata found')
        end
    end
end)

lib.callback.register('driveschool:server:GetLicensesList', function(source, type)
    return licenseList
end)

lib.callback.register('qbx_license:integration:server:GetPlayerLicenses', function(source)
    return qbx:GetMetadata(source, 'licenses') or {}
end)
