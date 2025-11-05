PlayerList = {}
PlayerListCache = {}
ServerInformation = { StaffCount = nil, CharacterCount = nil, VehicleCount = nil, BansCount = nil, PlayerCountHistory = {} }
AdminPanel = { ClientCallbacks = {}, ServerCallbacks = {}, AdminChat = {}, Reports = {}, InterceptedLogs = {} }
LoadedRole = {}
PlayersB = {}

AdminPanel.TriggerClientCallback = function(name, source, cb, ...)
    AdminPanel.ClientCallbacks[name] = cb
    TriggerClientEvent('AdminPanel:Client:TriggerClientCallback', source, name, ...)
end

AdminPanel.CreateCallback = function(name, cb) AdminPanel.ServerCallbacks[name] = cb end

AdminPanel.TriggerCallback = function(name, source, cb, ...)
    if not AdminPanel.ServerCallbacks[name] then return end
    AdminPanel.ServerCallbacks[name](source, cb, ...)
end

RegisterNetEvent('AdminPanel:Server:TriggerClientCallback', function(name, ...)
    if AdminPanel.ClientCallbacks[name] then
        AdminPanel.ClientCallbacks[name](...)
        AdminPanel.ClientCallbacks[name] = nil
    end
end)

RegisterNetEvent('AdminPanel:Server:TriggerCallback', function(name, ...)
    local src = source
    AdminPanel.TriggerCallback(name, src, function(...) TriggerClientEvent('AdminPanel:Client:TriggerCallback', src, name, ...) end, ...)
end)

CreateThread(function()
    while true do
        ServerInformation.PlayerCountHistory[os.time()] = #GetPlayers()

        -- Remove all entries from PlayerCountHistory where the time is older than 24 hours
        for entryTime, _ in pairs(ServerInformation.PlayerCountHistory) do if entryTime < os.time() - 86400 then ServerInformation.PlayerCountHistory[entryTime] = nil end end

        Wait(Config.PlayerGraphFrequency)
    end
end)

if Config.SaveTOJSON then
    CreateThread(function()
        AdminPanel.Reports = json.decode(LoadResourceFile(GetCurrentResourceName(), './json/reports.json'))
        AdminPanel.AdminChat = json.decode(LoadResourceFile(GetCurrentResourceName(), './json/adminchat.json'))
        AdminPanel.InterceptedLogs = json.decode(LoadResourceFile(GetCurrentResourceName(), './json/logs.json'))
    end)

    AddEventHandler('onResourceStop', function(name)
        if name == GetCurrentResourceName() then
            SaveResourceFile(GetCurrentResourceName(), 'json/reports.json', json.encode(AdminPanel.Reports), -1)
            SaveResourceFile(GetCurrentResourceName(), 'json/logs.json', json.encode(AdminPanel.InterceptedLogs), -1)
            SaveResourceFile(GetCurrentResourceName(), 'json/adminchat.json', json.encode(AdminPanel.AdminChat), -1)
        end
    end)
end

if Config.EnableAdminPanelCommand then RegisterCommand(Config.AdminPanelCommand, function(source, args) if AdminPanel.HasPermission(source, 'adminmenu') then OpenPanel(source) end end, false) end

RegisterNetEvent('919-admin:server:ReportReply', function(data)
    if data.name ~= nil then
        for _, playerId in ipairs(GetPlayers()) do
            playerId = tonumber(playerId)
            local charInfo = Bridge.GetCharacterData(playerId)
            if charInfo.CharacterIdentifier == data.name then
                Bridge.Notify(playerId, 'Report Reply: ' .. data.message, 'info')
            end
        end
    end
end)

RegisterNetEvent('919-admin:server:RequestPanel', function()
    local src = source
    if AdminPanel.HasPermission(src, 'adminmenu') then OpenPanel(src) end
end)

OpenPanel = function(source)
    local src = source
    local version = GetResourceMetadata(GetCurrentResourceName(), 'version', 0)
    AdminPanel.GetAllPlayers(function()
        local role = AdminPanel.GetRole(src)
        TriggerClientEvent('919-admin:client:OpenMenu', source, json.encode(ServerInformation.PlayerList), ServerInformation, GetConvarInt('sv_maxclients', 32), version, role)
    end)
end

AdminPanel.CreateCallback('qb-admin:server:GetPlayerCountHistory', function(source, cb) cb(ServerInformation.PlayerCountHistory) end)

AdminPanel.CreateCallback('919-Admin:GetPlayerName', function(source, cb, id)
    local result = Bridge.GetCharacterData(id)
    cb(result.CharacterName)
end)

AdminPanel.CreateCallback('919-admin:server:Refresh', function(source, cb)
    if AdminPanel.HasPermission(src, 'adminmenu') then
        local playerList = {}
        for k, v in ipairs(GetPlayers()) do
            v = tonumber(v)
            local identifiers, steamIdentifier = GetPlayerIdentifiers(v)
            for _, v2 in pairs(identifiers) do
                if string.find(v2, 'license:') then steamIdentifier = v2 end
                if not Config.ShowIPInIdentifiers then if string.find(v2, 'ip:') then identifiers[_] = nil end end
            end

            local PlayerData = Bridge.GetCharacterData(v)
            table.insert(playerList, {
                id = v, name = GetPlayerName(v), identifiers = json.encode(identifiers), role = PlayerData.Role, bank = '$' .. comma_value(PlayerData.Bank), cash = '$' .. comma_value(PlayerData.Cash), steamid = steamIdentifier,
                citizenid = PlayerData.CharacterIdentifier, job = PlayerData.Job, rank = PlayerData.Rank, health = GetEntityHealth(GetPlayerPed(playerId)) - 100, armor = GetPedArmour(GetPlayerPed(playerId)),
                jobboss = PlayerData.IsBoss and '<span class="badge badge-success">' .. Lang:t('alerts.yes') .. '</span>' or '<span class="badge badge-danger">' .. Lang:t('alerts.no') .. '</span>',
                duty = PlayerData.OnDuty and '<span class="badge badge-success">' .. Lang:t('alerts.yes') .. '</span>' or '<span class="badge badge-danger">' .. Lang:t('alerts.no') .. '</span>', gang = PlayerData.GangLabel, gangrank = PlayerData.GangRank,
                gangboss = PlayerData.GangIsBoss and '<span class="badge badge-success">' .. Lang:t('alerts.yes') .. '</span>' or '<span class="badge badge-danger">' .. Lang:t('alerts.no') .. '</span>', charname = PlayerData.CharacterName
            })
        end
        cb(playerList)
    end
end)

RegisterNetEvent('919-admin:AddPlayer', function()
    local src = source
    TriggerClientEvent('919-admin:AddPlayer', -1, src, os.time())
end)

RegisterNetEvent('919-admin:server:RequestJobPageInfo', function()
    local src = source
    if AdminPanel.HasPermission(src, 'jobpage') then TriggerLatentClientEvent('919-admin:client:ReceiveJobPageInfo', src, 100000, Bridge.GetMasterEmployeeList()) end
end)

RegisterNetEvent('919-admin:server:RequestGangPageInfo', function()
    local src = source
    if AdminPanel.HasPermission(src, 'gangpage') then TriggerLatentClientEvent('919-admin:client:ReceiveGangPageInfo', src, 100000, Bridge.GetMasterGangList()) end
end)

RegisterNetEvent('919-admin:server:RequestBansInfo', function()
    local src = source
    if AdminPanel.HasPermission(src, 'banspage') then
        local results = MySQL.query.await('SELECT * FROM `' .. Config.DB.BansTable .. '`')
        local BansInfo = {}
        for k1, v1 in ipairs(results) do table.insert(BansInfo, { ID = v1.id, Name = v1.name, License = v1.license, Discord = v1.discord, IP = v1.ip, Reason = v1.reason, Expire = v1.expire, BannedBy = v1.bannedby }) end
        TriggerLatentClientEvent('919-admin:client:ReceiveBansInfo', src, 100000, BansInfo)
    end
end)

RegisterNetEvent('919-admin:server:ClearJSON', function(type)
    if type == 'admin' then
        AdminPanel.AdminChat = {}
        SaveResourceFile(GetCurrentResourceName(), 'json/adminchat.json', json.encode(AdminPanel.AdminChat), -1)
    elseif type == 'reports' then
        AdminPanel.Reports = {}
        SaveResourceFile(GetCurrentResourceName(), 'json/reports.json', json.encode(AdminPanel.Reports), -1)
    elseif type == 'logs' then
        AdminPanel.InterceptedLogs = {}
        SaveResourceFile(GetCurrentResourceName(), 'json/logs.json', json.encode(AdminPanel.InterceptedLogs), -1)
    end
end)

RegisterNetEvent('919-admin:server:RequestReportsInfo', function()
    local src = source
    if AdminPanel.HasPermission(src, 'viewreports') then TriggerLatentClientEvent('919-admin:client:ReceiveReportsInfo', src, 100000, AdminPanel.Reports) end
end)

RegisterNetEvent('919-admin:server:RequestAdminChat', function()
    local src = source
    if AdminPanel.HasPermission(src, 'adminchat') then TriggerLatentClientEvent('919-admin:client:ReceiveAdminChat', src, 100000, AdminPanel.AdminChat) end
end)

RegisterNetEvent('919-admin:server:RequestVehiclesInfo', function()
    local src = source
    if AdminPanel.HasPermission(src, 'vehiclesinfo') then
        local results = Bridge.GetVehiclesList()
        if results ~= nil then TriggerLatentClientEvent('919-admin:client:ReceiveVehiclesInfo', src, 100000, results) end
    end
end)

RegisterNetEvent('919-admin:server:RequestLeaderboardInfo', function()
    local src = source
    if AdminPanel.HasPermission(src, 'leaderboardinfo') then
        local money, vehicles = Bridge.GetLeaderboardInfo()
        TriggerLatentClientEvent('919-admin:client:ReceiveLeaderboardInfo', src, 100000, money, vehicles)
    end
end)

RegisterNetEvent('919-admin:server:RequestMapInfo', function()
    local src = source
    if AdminPanel.HasPermission(src, 'mapinfo') then
        local playerMapInfo = {}
        for _, strId in pairs(GetPlayers()) do
            local playerId = tonumber(strId)
            local playerData = Bridge.GetCharacterData(playerId)
            playerMapInfo[#playerMapInfo + 1] = { coords = GetEntityCoords(GetPlayerPed(playerId)), charname = playerData.CharacterName, name = GetPlayerName(playerId), id = playerId }
        end
        TriggerLatentClientEvent('919-admin:client:ReceivePlayerMap', src, 100000, playerMapInfo)
    end
end)

RegisterNetEvent('919-admin:server:RequestItemsInfo', function()
    local src = source
    if AdminPanel.HasPermission(src, 'itemsinfo') then
        local items = Bridge.GetItemsList()
        TriggerLatentClientEvent('919-admin:client:ReceiveItemsInfo', src, 100000, items)
    end
end)

RegisterNetEvent('919-admin:server:RequestCharacters', function()
    local src = source
    if AdminPanel.HasPermission(src, 'characterspage') then
        local results = MySQL.query.await('SELECT * FROM `' .. Config.DB.CharactersTable .. '`')
        TriggerClientEvent('919-admin:client:ReceiveCharacters', src, results)
    end
end)

RegisterNetEvent('919-admin:server:RequestNoClip', function()
    local src = source
    if AdminPanel.HasPermission(src, 'noclip') then TriggerClientEvent('919-admin:client:ToggleNoClip', src) end
end)

RegisterNetEvent('919-admin:server:AdminChatSend', function(message)
    local src = source
    if AdminPanel.HasPermission(src, 'adminchat') then
        local SenderName = GetPlayerName(src)
        local SentTime = os.time()
        table.insert(AdminPanel.AdminChat, { Sender = SenderName, TimeStamp = SentTime, Message = message })
        TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Admin chat send', 'red', SenderName .. ' Has sent the following message in the adminchat: ' .. message .. ' At: ' .. SentTime, false)

        for k, v in pairs(GetPlayers()) do
            v = tonumber(v)
            if AdminPanel.HasPermissionEx(v, 'adminchat') then TriggerLatentClientEvent('919-admin:client:ReceiveAdminChat', v, 100000, AdminPanel.AdminChat) end
        end
    end
end)

if Config.Framework == 'qbox' then
    RegisterNetEvent('919Admin:server:RequestVehicleKeys', function(vehNetId)
        local src = source
        local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
        exports.qbx_vehiclekeys:GiveKeys(src, vehicle, false)
    end)
end

RegisterNetEvent('919-admin:server:SendReport', function(subject, info, type)
    local src = source

    local CitizenId = Bridge.GetCharacterIdentifier(src)
    local reportCount = 0
    for k, v in pairs(AdminPanel.Reports) do if v.SenderCitizenID == CitizenId then reportCount = reportCount + 1 end end
    if reportCount >= Config.MaxReportsPerPlayer then return TriggerClientEvent('919-admin:client:ShowReportAlert', src, Lang:t('alerts.failedReportSend'), Lang:t('alerts.reportLimitReached')) end
    TriggerClientEvent('919-admin:client:ShowReportAlert', src, Lang:t('alerts.reportSent'), 'Your report was sent to server staff!')
    local sendername = GetPlayerName(src) .. ' (' .. Bridge.GetCharacterName(src) .. ')'
    local id = 1
    for k, v in pairs(AdminPanel.Reports) do id = id + 1 end
    AdminPanel.Reports[tostring(id)] = { ReportID = id, Claimed = nil, ReportTime = os.time(), SenderCitizenID = CitizenId, SenderID = src, SenderName = sendername, Subject = subject, Info = info, Type = type }
    TriggerEvent('qb-log:server:CreateLog', 'adminactions', Lang:t('alerts.reportSent'), 'red', sendername .. '' .. Lang:t('alerts.sentFollowingReport') .. ' ' .. subject .. ' ' .. Lang:t('alerts.message') .. ' ' .. info, false)
    for k, v in pairs(GetPlayers()) do
        v = tonumber(v)
        if AdminPanel.HasPermissionEx(v, 'viewreports') then TriggerClientEvent('919-admin:client:ShowReportAlert', v, Lang:t('alerts.newReport'), sendername .. ': ' .. subject .. ' Report ID: ' .. id) end
    end
end)

RegisterServerEvent('919-admin:server:ClaimReport', function(id)
    local src = source
    if AdminPanel.HasPermission(src, 'claimreport') then
        if AdminPanel.Reports[tostring(id)] then
            AdminPanel.Reports[tostring(id)].Claimed = GetPlayerName(src)
            TriggerEvent('qb-log:server:CreateLog', 'adminactions', Lang:t('alerts.reportClaimed'), 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** claimed report ID ' .. id, false)
            for k, v in pairs(GetPlayers()) do
                v = tonumber(v)
                if AdminPanel.HasPermission(v, 'viewreports') then
                    TriggerClientEvent('919-admin:client:ShowReportAlert', v, Lang:t('alerts.reportClaimed'), GetPlayerName(src) .. ' claimed Report ID ' .. id .. ' from ' .. AdminPanel.Reports[tostring(id)].SenderName .. '.')
                end
            end
            TriggerClientEvent('919-admin:client:ShowPanelAlert', AdminPanel.Reports[tostring(id)].SenderID, 'success',
                               '<strong>' .. Lang:t('alerts.report') .. '</strong>' .. Lang:t('alerts.reportClaimedByStaff') .. '<strong>' .. GetPlayerName(src) .. '</strong>.')
            TriggerLatentClientEvent('919-admin:client:ReceiveReportsInfo', src, 100000, AdminPanel.Reports)
        end
    end
end)

RegisterServerEvent('919-admin:server:DeleteReport', function(id)
    local src = source
    if AdminPanel.HasPermission(src, 'deletereport') then
        if AdminPanel.Reports[tostring(id)] then
            AdminPanel.Reports[tostring(id)] = nil
            TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Report Deleted', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** deleted report ID ' .. id, false)
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>SUCCESS:</strong> Deleted Report ID ' .. id .. '.')
            TriggerLatentClientEvent('919-admin:client:ReceiveReportsInfo', src, 100000, AdminPanel.Reports)
        end
    end
end)

RegisterNetEvent('919-admin:server:ResourceAction', function(resourceName, action)
    local src = source
    if AdminPanel.HasPermission(src, 'adminmenu') then
        if action == 'start' then
            if GetResourceState(resourceName) == 'stopped' then
                StartResource(resourceName)
                Wait(500)
                TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.startedResource') .. '</strong> ' .. resourceName)
            else
                TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.error') .. '</strong>' .. Lang:t('alerts.resourceAlready'))
            end
        elseif action == 'stop' then
            if GetResourceState(resourceName) == 'started' then
                StopResource(resourceName)
                Wait(500)
                TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.stoppedResource') .. '</strong> ' .. resourceName)
            else
                TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.error') .. '</strong>' .. Lang:t('alerts.resouceStoppedAlready'))
            end
        elseif action == 'restart' then
            if GetResourceState(resourceName) == 'started' then
                StopResource(resourceName)
                Wait(500)
                StartResource(resourceName)
                TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.RestartedResource') .. '</strong> ' .. resourceName)
            else
                TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.error') .. '</strong>' .. Lang:t('alerts.resouceRestartedAlready'))
            end
        end
        TriggerClientEvent('919-admin:client:ForceReloadResources', src)
    end
end)

RegisterNetEvent('919-admin:server:MonetaryAction', function(targetId, action, amount)
    local src = source
    if AdminPanel.HasPermission(src, 'givetakemoney') then
        if action == 'givecash' then
            Bridge.PlayerActions.AddMoney(targetId, amount)
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.gaveCash', { value = amount, value2 = GetPlayerName(targetId) }))
            TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Cash Given', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** added $' .. amount .. ' cash to ' .. GetPlayerName(targetId), false)
        elseif action == 'removecash' then
            Bridge.PlayerActions.RemoveMoney(targetId, amount)
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.removeCash', { value = amount, value2 = GetPlayerName(targetId) }))
            TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Cash Removed', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** removed $' .. amount .. ' cash from ' .. GetPlayerName(targetId), false)
        elseif action == 'givebank' then
            Bridge.PlayerActions.AddBank(targetId, amount)
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.gaveBank', { value = amount, value2 = GetPlayerName(targetId) }))
            TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Bank Given', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** added $' .. amount .. ' bank money to ' .. GetPlayerName(targetId), false)
        elseif action == 'removebank' then
            Bridge.PlayerActions.RemoveBank(targetId, amount)
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.removeBank', { value = amount, value2 = GetPlayerName(targetId) }))
            TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Bank Removed', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** removed $' .. amount .. ' bank money from ' .. GetPlayerName(targetId), false)
        end
    end
end)

RegisterNetEvent('919-admin:server:RequestViewPlayer', function(CitizenId)
    DebugTrace(CitizenId)
    local src = source
    local Player = Bridge.GetPlayerFromCharacterIdentifier(CitizenId)
    if Player then
        local sourcer = Player.source or Player.PlayerData.source
        TriggerClientEvent('919-admin:client:ViewPlayer', src, true, sourcer)
    else
        TriggerClientEvent('919-admin:client:ViewPlayer', src, false, Bridge.GetOfflinePlayerFromCharacterIdentifier(CitizenId))
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    TriggerClientEvent('919-admin:RemovePlayer', -1, src)
end)

RegisterNetEvent('919-admin:server:RefreshMenu', function(silent)
    local src = source
    TriggerClientEvent('919-admin:client:RefreshMenu', src, json.encode(Bridge.GetPlayerList()), silent)
end)

RegisterServerEvent('qb-log:server:CreateLog', function(name, title, color, message, tagEveryone)
    if (Config.Framework == 'esx' or Config.Framework == 'qbox') and name == 'adminactions' then
        local webHook = Config.LogsWebhook
        if webHook == '' then
            print('[919ADMIN] Webhook missing from server config!')
            return
        end
        local embedData = { { ['title'] = title, ['color'] = 16743168, ['footer'] = { ['text'] = os.date('%c') }, ['description'] = message, ['author'] = { ['name'] = '919Admin', ['icon_url'] = '' } } }
        PerformHttpRequest(webHook, function(err, text, headers) end, 'POST', json.encode({ username = 'Admin log!', embeds = embedData }), { ['Content-Type'] = 'application/json' })
    end
    table.insert(AdminPanel.InterceptedLogs, { time = os.time(), from = name, title = title, message = message })
end)

AdminPanel.CreateCallback('919-admin:server:HasPermission', function(source, cb, permission)
    if AdminPanel.HasPermission(source, permission) then
        if permission == 'playernames' then
            TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Player Names Toggled', 'red', '**STAFF MEMBER ' .. GetPlayerName(source) .. '** has toggled their player names.', false)
        elseif permission == 'playerblips' then
            TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Player Blips Toggled', 'red', '**STAFF MEMBER ' .. GetPlayerName(source) .. '** has toggled their player blips.', false)
        end
        return cb(true)
    end
end)


if Config.Framework == 'qbcore' then
    AdminPanel.CreateCallback('919-admin:server:HasPermissions', function(source, cb, group)
        local src = source
        local retval = false
        if QBCore.Functions.HasPermission(src, group) then retval = true end
        cb(retval)
    end)
elseif Config.Framework == 'qbox' then
    AdminPanel.CreateCallback('919-admin:server:HasPermissions', function(source, cb, group)
        local src = source
        local retval = false
        if exports.qbx_core:HasPermission(src, group) then retval = true end
        cb(retval)
    end)
elseif Config.Framework == 'esx' then
    AdminPanel.CreateCallback('919-admin:server:HasPermissions', function(source, cb, group)
        local src = source
        local retval = false
        local Player = ESX.GetPlayerFromId(source)
        if Player.group == group then retval = true end
        cb(retval)
    end)
end

AdminPanel.HasPermission = function(targetId, permName)
    local hasPerms = false
    for k, v in pairs(Config.Permissions) do
        if Config.Framework == 'qbcore' then
            if QBCore.Functions.HasPermission(targetId, k) then
                hasPerms = true
                for _, action in pairs(v.AllowedActions) do if action == permName then return true end end
            end
        elseif Config.Framework == 'qbox' then
            if exports.qbx_core:HasPermission(targetId, k) then
                hasPerms = true
                for _, action in pairs(v.AllowedActions) do if action == permName then return true end end
            end
        elseif Config.Framework == 'esx' then
            local Player = Bridge.GetPlayer(targetId)
            if k == Player.group then
                hasPerms = true
                for _, action in pairs(v.AllowedActions) do if action == permName then return true end end
            end
        end
    end

    if hasPerms then
        if permName ~= 'clearreports' and permName ~= 'clearadminchat' then TriggerClientEvent('919-admin:client:ShowPanelAlert', targetId, 'danger', '<strong>' .. Lang:t('alerts.error') .. '</strong> ' .. Lang:t('alerts.noPermission')) end
        TriggerClientEvent('919-admin:client:ResetMenu', targetId)
    end
    return false
end

AdminPanel.HasPermissionEx = function(targetId, permName)
    for k, v in pairs(Config.Permissions) do
        if Config.Framework == 'qbcore' then
            if QBCore.Functions.HasPermission(targetId, k) then for _, action in pairs(v.AllowedActions) do if action == permName then return true end end end
        elseif Config.Framework == 'qbox' then
            if exports.qbx_core:HasPermission(targetId, k) then for _, action in pairs(v.AllowedActions) do if action == permName then return true end end end
        elseif Config.Framework == 'esx' then
            local Player = Bridge.GetPlayer(targetId)
            if Player.group == k then for _, action in pairs(v.AllowedActions) do if action == permName then return true end end end
        end
    end

    TriggerClientEvent('919-admin:client:ResetMenu', targetId)
    return false
end

AdminPanel.GetRole = function(targetId)
    for k, v in ipairs(Config.RoleOrder) do
        if Config.Framework == 'qbcore' then
            if QBCore.Functions.HasPermission(targetId, v) then return v end
        elseif Config.Framework == 'qbox' then
            if exports.qbx_core:HasPermission(targetId, v) then return v end
        elseif Config.Framework == 'esx' then
            local Player = Bridge.GetPlayer(targetId)
            if Player then if Player.group == v then return v end end
        end
    end
    return nil
end

RegisterNetEvent('919-admin:server:RequestResourcePageInfo', function()
    local src = source
    if AdminPanel.HasPermission(src, 'resourcepage') then
        local resourceList = {}
        for i = 0, GetNumResources(), 1 do
            local resource_name = GetResourceByFindIndex(i)
            if resource_name then
                if resource_name ~= '_cfx_internal' and resource_name ~= 'fivem' then -- Ignore these two base resources. Others are ok.
                    table.insert(resourceList, { resource_name, GetResourceState(resource_name) })
                end
            end
        end
        TriggerLatentClientEvent('919-admin:client:ReceiveResourcePageInfo', src, 100000, resourceList)
    end
end)

RegisterNetEvent('919-admin:server:RequestCurrentLogs', function()
    local src = source
    if AdminPanel.HasPermission(src, 'serverlogs') then TriggerLatentClientEvent('919-admin:client:ReceiveCurrentLogs', src, 100000, AdminPanel.InterceptedLogs) end
end)

RegisterNetEvent('919-Admin:server:OpenInventory', function(target) TriggerClientEvent('inventory:client:RobPlayer:Admin', target, tonumber(target)) end)

RegisterNetEvent('919-admin:server:RequestServerMetrics', function()
    local src = source
    if AdminPanel.HasPermission(src, 'servermetrics') then
        CreateThread(function()
            local ServerMetrics = {}
            ServerMetrics.StaffCount = 0
            local results = MySQL.query.await('SELECT * FROM `' .. Config.DB.CharactersTable .. '`')
            ServerMetrics.CharacterCount = #results
            ServerMetrics.TotalCash = 0
            for k, v in pairs(results) do
                if v.money then
                    local money = json.decode(v.money)
                    if money then ServerMetrics.TotalCash = ServerMetrics.TotalCash + money.cash end
                elseif v.accounts then
                    local money = json.decode(v.accounts)
                    if money then for type, amount in pairs(money) do if type == 'money' then ServerMetrics.TotalCash = ServerMetrics.TotalCash + amount end end end
                end
            end
            ServerMetrics.TotalBank = 0
            for k, v in pairs(results) do
                if v.money then
                    local money = json.decode(v.money)
                    if money then ServerMetrics.TotalBank = ServerMetrics.TotalBank + money.bank end
                elseif v.accounts then
                    local money = json.decode(v.accounts)
                    if money then for type, amount in pairs(money) do if type == 'bank' then ServerMetrics.TotalBank = ServerMetrics.TotalBank + amount end end end
                end
            end
            ServerMetrics.TotalItems = 0
            for k, v in pairs(results) do
                if v.inventory then
                    local inv = json.decode(v.inventory)
                    if inv then
                        local count = 0
                        for k, v in pairs(inv) do count = count + 1 end
                        ServerMetrics.TotalItems = ServerMetrics.TotalItems + count
                    end
                end
            end
            results = MySQL.query.await('SELECT * FROM `' .. Config.DB.VehiclesTable .. '`', {})
            ServerMetrics.VehicleCount = #results
            results = MySQL.query.await('SELECT * FROM `' .. Config.DB.BansTable .. '`', {})
            ServerMetrics.BansCount = #results
            if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
                results = MySQL.query.await('SELECT DISTINCT `license` FROM `' .. Config.DB.CharactersTable .. '`')
            elseif Config.Framework == 'esx' then
                results = MySQL.query.await('SELECT DISTINCT `identifier` FROM `' .. Config.DB.CharactersTable .. '`')
            end
            ServerMetrics.UniquePlayers = #results
            TriggerLatentClientEvent('919-admin:client:ReceiveServerMetrics', src, 100000, ServerMetrics)
        end)
    end
end)

function comma_value(amount)
    local formatted = math.floor(amount)
    while true do
        formatted, k = string.gsub(formatted, '^(-?%d+)(%d%d%d)', '%1,%2')
        if (k == 0) then break end
    end
    return formatted
end

AdminPanel.GetAllPlayers = function(cb)
    ServerInformation.PlayerList = {}
    ServerInformation.StaffCount = 0
    ServerInformation.PlayerList = Bridge.GetPlayerList()
    for k, v in ipairs(GetPlayers()) do
        v = tonumber(v)
        local Player = Bridge.GetPlayer(v)
        if Player then
            local identifiers, steamIdentifier = GetPlayerIdentifiers(v)
            for _, v2 in pairs(identifiers) do
                if string.find(v2, 'license:') then steamIdentifier = v2 end
                if not Config.ShowIPInIdentifiers then if string.find(v2, 'ip:') then identifiers[_] = nil end end
            end
            local playerRole = 'user'
            if Config.Framework == 'qbcore' then
                for id, roleName in ipairs(Config.RoleOrder) do
                    if QBCore.Functions.HasPermission(v, roleName) then
                        playerRole = roleName
                        ServerInformation.StaffCount = ServerInformation.StaffCount + 1
                        break
                    end
                end
            elseif Config.Framework == 'qbox' then
                for id, roleName in ipairs(Config.RoleOrder) do
                    if exports.qbx_core:HasPermission(v, roleName) then
                        playerRole = roleName
                        ServerInformation.StaffCount = ServerInformation.StaffCount + 1
                        break
                    end
                end
            elseif Config.Framework == 'esx' then
                playerRole = Player.group
                if Player.group ~= 'user' then ServerInformation.StaffCount = ServerInformation.StaffCount + 1 end
            end
            LoadedRole[tonumber(v)] = playerRole
        end
    end
    if cb then cb() end
end

RegisterNetEvent('919-admin:server:GetPlayersForBlips', function()
    local src = source
    if Config.EnableNames then
        local tempPlayers = {}
        for _, v in pairs(GetPlayers()) do
            v = tonumber(v)
            local targetped = GetPlayerPed(v)
            local charname = Bridge.GetCharacterName(v)
            tempPlayers[#tempPlayers + 1] = { name = (charname .. ' | (' .. (GetPlayerName(v) or '') .. ')'), id = v, coords = GetEntityCoords(targetped), cid = charname, citizenid = '---', sources = targetped, sourceplayer = v }
        end
        -- Sort PlayersB list by source ID (1,2,3,4,5, etc) --
        table.sort(tempPlayers, function(a, b) return a.id < b.id end)
        PlayersB = tempPlayers
        TriggerClientEvent('919-admin:client:Show', src, PlayersB)
    end
end)