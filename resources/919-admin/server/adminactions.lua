SendPlayerBack = {}
SendBack = {}
SpectatingPlayer = {}
Frozen = {}

RegisterServerEvent('919-admin:server:SetPosition', function(playerId, x, y, z)
    local src = source
    if AdminPanel.HasPermission(src, 'teleport') then SetEntityCoords(GetPlayerPed(playerId), x, y, z) end
end)

RegisterServerEvent('919-admin:server:KillPlayer', function(playerId)
    local src = source
    if AdminPanel.HasPermission(src, 'kill') then
        TriggerClientEvent('919-admin:client:KillPlayer', playerId)
        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.killed') .. ' ' .. GetPlayerName(playerId) .. '.')
        TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'KICK', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** ' .. Lang:t('alerts.killed') .. ' **' .. GetPlayerName(playerId) .. '** [' .. playerId .. ']', false)
    end
end)

RegisterServerEvent('919-admin:server:SavePlayer', function(playerId)
    local src = source
    if AdminPanel.HasPermission(src, 'savedata') then
        if Config.Framework == 'qbcore' then
            local TargetPlayer = QBCore.Functions.GetPlayer(playerId)
            TargetPlayer.Functions.Save()
        elseif Config.Framework == 'qbox' then
            exports.qbx_core:Save(playerId)
        end
        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.savedToDB', { value = GetPlayerName(playerId) }))
        TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'KICK', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '**' .. Lang:t('alerts.savedToDB', { value = GetPlayerName(playerId) }) .. '** [' .. playerId .. ']', false)
    end
end)

RegisterServerEvent('919-admin:server:RepairPlayerVehicle', function(playerId)
    local src = source
    if AdminPanel.HasPermission(src, 'repairplayervehicle') then
        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.repairedPlayerVehicle'))
        TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'KICK', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** ' .. Lang:t('alerts.repairedPlayerVehicle') .. '** [' .. playerId .. ']', false)
        TriggerClientEvent('919-admin:client:RepairVehicle', playerId)
    end
end)

RegisterServerEvent('919-admin:server:KickPlayer', function(playerId, reason)
    local src = source
    if AdminPanel.HasPermission(src, 'kick') then
        TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'KICK', 'red', Lang:t('alerts.kickedPlayer', { value = GetPlayerName(src), value2 = GetPlayerName(playerId), value3 = playerId, value4 = reason }), false)
        DropPlayer(playerId, Lang:t('alerts.YouBeenKicked') .. '\n' .. reason .. '\n\n🔸 ' .. Lang:t('alerts.joinDiscord') .. ' ' .. Config.ServerDiscord)
    end
end)

RegisterServerEvent('919-admin:server:Freeze', function(playerId)
    local src = source
    if AdminPanel.HasPermission(src, 'freeze') then
        if not Frozen[playerId] then
            Frozen[playerId] = true
            FreezeEntityPosition(GetPlayerPed(playerId), true)
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.froze') .. ' ' .. GetPlayerName(playerId) .. '.')
            TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Frozen', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** ' .. Lang:t('alerts.froze') .. ' **' .. GetPlayerName(playerId) .. '** [' .. playerId .. ']', false)
        else
            Frozen[playerId] = false
            FreezeEntityPosition(GetPlayerPed(playerId), false)
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.unfroze') .. ' ' .. GetPlayerName(playerId) .. '.')
            TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Frozen', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** ' .. Lang:t('alerts.unfroze') .. ' **' .. GetPlayerName(playerId) .. '** [' .. playerId .. ']', false)
        end
    end
end)

RegisterNetEvent('919-admin:server:BanPlayer', function(player, time, reason, citizenid)
    local src = source
    if AdminPanel.HasPermission(src, 'ban') then
        local time = tonumber(time)
        local banTime = tonumber(os.time() + time)
        if banTime > 2147483647 then banTime = 2147483647 end
        local timeTable = os.date('*t', banTime)
        if player ~= 'OFFLINE' then
            AdminPanel.OnlineBanPlayer(src, player, time, timeTable, reason)
        else
            if citizenid ~= nil then
                local result = MySQL.query.await('SELECT * FROM `' .. Config.DB.CharactersTable .. '` WHERE `citizenid` = ?', { citizenid })
                if result[1] then
                    local online = false
                    for k, v in pairs(GetPlayers()) do
                        v = tonumber(v)
                        if Config.Framework == 'qbcore' then
                            if QBCore.Functions.GetIdentifier(v, 'license') == result[1].license then -- Player is online but not on this character. so we"ll ban them online
                                AdminPanel.OnlineBanPlayer(src, v, time, timeTable, reason)
                                online = true
                                break
                            end
                        elseif Config.Framework == 'qbox' then
                            if GetPlayerIdentifierByType(v, 'license') == result[1].license then -- Player is online but not on this character. so we"ll ban them online
                                AdminPanel.OnlineBanPlayer(src, v, time, timeTable, reason)
                                online = true
                                break
                            end
                        else
                            if ESX.GetIdentifier(player) == result[1].Identifier then -- Player is online but not on this character. so we"ll ban them online
                                AdminPanel.OnlineBanPlayer(src, v, time, timeTable, reason)
                                online = true
                                break
                            end
                        end
                    end
                    if not online then
                        MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', { result[1].name, result[1].license, '', '', reason, banTime, GetPlayerName(src) })
                        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', 'Banned ' .. result[1].name .. ' (OFFLINE) for ' .. (time / 60 / 60) .. ' hours.')
                        if Config.AnnounceBan then
                            TriggerClientEvent('chat:addMessage', -1, {
                                template = '<div class="chat-message server"><strong>{0}</strong> ' .. Lang:t('alerts.bannedOffBy') .. ' <strong>{1}</strong> ' .. Lang:t('alerts.for1') .. ' {2} ' .. lang:t('alerts.bannedOffBy2') .. ' {3}</div>',
                                args = { result[1].name, GetPlayerName(src), time / 60 / 60, reason }
                            })
                        end
                        TriggerEvent('qb-log:server:CreateLog', 'bans', 'Player Banned', 'red', string.format('%s was banned by %s for %s (%s hours)', result[1].name, GetPlayerName(src), reason, time / 60 / 60), Config.TagEveryone)
                    end
                else
                    DebugTrace('Offline ban citizenid had no results. CitizenID: ' .. citizenid)
                end
            else
                DebugTrace('Tried to ban offline but citizenid was invalid. Scripting error.')
            end
        end
    end
end)

local function onPlayerConnecting(name, _, deferrals)
    local src = source --[[@as string]]
    local license = GetPlayerIdentifierByType(src, 'license2') or GetPlayerIdentifierByType(src, 'license')
    local discord = GetPlayerIdentifierByType(src, 'discord')

    deferrals.defer()

    -- Mandatory wait
    Wait(0)

    local result = MySQL.query.await('SELECT * FROM `bans` WHERE (`license` = ? OR `discord` = ?) AND `expire` > ?', { license, discord, os.time() })
    if result[1] then
        if result[1].expire >= 2147483647 then
            deferrals.done(Lang:t('alerts.bannedPermanent', { value = result[1].reason }))
            return
        else
            local timeTable = os.date('*t', result[1].expire)
            deferrals.done(Lang:t('alerts.bannedTemp', { value = result[1].reason, value2 = timeTable['day'], value3 = timeTable['month'], value4 = timeTable['year'], value5 = timeTable['hour'], value6 = timeTable['min'], value7 = Config.ServerDiscord }))
            return
        end
    end

    deferrals.done()
end
AddEventHandler('playerConnecting', onPlayerConnecting)

AdminPanel.OnlineBanPlayer = function(source, player, time, timeTable, reason)
    local src = source
    local time = tonumber(time)
    local banTime = tonumber(os.time() + time)
    if banTime >= 2147483647 then banTime = 2147483647 end
    MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        GetPlayerName(player), GetPlayerIdentifierByType(player, 'license2') or GetPlayerIdentifierByType(player, 'license'), GetPlayerIdentifierByType(player, 'discord'), GetPlayerIdentifierByType(player, 'ip'), reason, banTime, GetPlayerName(src)
    })

    TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', 'Banned ' .. GetPlayerName(player) .. ' for ' .. (time / 60 / 60) .. ' hours.')
    if Config.AnnounceBan then
        TriggerClientEvent('chat:addMessage', -1,
                           { template = '<div class="chat-message server"><strong>{0}</strong> has been banned by <strong>{1}</strong> for {2} hours. Reason: {3}</div>', args = { GetPlayerName(player), GetPlayerName(src), time / 60 / 60, reason } })
    end
    TriggerEvent('qb-log:server:CreateLog', 'bans', 'Player Banned', 'red', string.format('%s was banned by %s for %s (%s hours)', GetPlayerName(player), GetPlayerName(src), reason, time / 60 / 60), Config.TagEveryone)
    if banTime >= 2147483647 then
        DropPlayer(player, Lang:t('alerts.bannedPermanent', { value = reason }) .. ' ' .. Config.ServerDiscord)
    else
        DropPlayer(player, Lang:t('alerts.bannedTemp', { value = reason, value2 = timeTable['day'], value3 = timeTable['month'], value4 = timeTable['year'], value5 = timeTable['hour'], value6 = timeTable['min'], value7 = Config.ServerDiscord }))
    end
end

AdminPanel.OnlineBanPlayerFromDiscord = function(player, time, reason)
    local time = tonumber(time)
    local banTime = tonumber(os.time() + time)
    local timeTable = os.date('*t', banTime)
    if banTime > 2147483647 then banTime = 2147483647 end

    MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        GetPlayerName(player), GetPlayerIdentifierByType(player, 'license2') or GetPlayerIdentifierByType(player, 'license'), GetPlayerIdentifierByType(player, 'discord'), GetPlayerIdentifierByType(player, 'ip'), reason, banTime, 'DISCORD COMMAND'
    })

    if Config.AnnounceBan then
        TriggerClientEvent('chat:addMessage', -1, { template = '<div class="chat-message server"><strong>{0}</strong> has been banned by discord admin command for {2} hours. Reason: {3}</div>', args = { GetPlayerName(player), time / 60 / 60, reason } })
    end
    TriggerEvent('qb-log:server:CreateLog', 'bans', 'Player Banned', 'red', string.format('%s was banned by discord admin command for %s (%s hours)', GetPlayerName(player), reason, time / 60 / 60), Config.TagEveryone)
    if banTime >= 2147483647 then
        DropPlayer(player, Lang:t('alerts.bannedPermanent', { value = reason }) .. ' ' .. Config.ServerDiscord)
    else
        DropPlayer(player, Lang:t('alerts.bannedTemp', { value = reason, value2 = timeTable['day'], value3 = timeTable['month'], value4 = timeTable['year'], value5 = timeTable['hour'], value6 = timeTable['min'], value7 = Config.ServerDiscord }))
    end
end

RegisterNetEvent('919-admin:server:WarnPlayer', function(player, reason, citizenid)
    local src = source
    if AdminPanel.HasPermission(src, 'warn') then
        if player ~= 'OFFLINE' then
            AdminPanel.OnlineWarnPlayer(src, player, reason)
        else
            if citizenid ~= nil then
                local result = MySQL.query.await('SELECT * FROM `' .. Config.DB.CharactersTable .. '` WHERE `citizenid` = ?', { citizenid })
                if result[1] then
                    local online = false
                    for k, v in pairs(GetPlayers()) do
                        v = tonumber(v)
                        if Config.Framework == 'qbcore' then
                            if QBCore.Functions.GetIdentifier(v, 'license') == result[1].license then
                                AdminPanel.OnlineWarnPlayer(src, v, reason)
                                online = true
                                break
                            end
                        elseif Config.Framework == 'qbox' then
                            if GetPlayerIdentifierByType(v, 'license') == result[1].license then
                                AdminPanel.OnlineWarnPlayer(src, v, reason)
                                online = true
                                break
                            end
                        else
                            if ESX.GetIdentifier(player) == result[1].Identifier then
                                AdminPanel.OnlineWarnPlayer(src, v, reason)
                                online = true
                                break
                            end
                        end
                    end
                    if not online then
                        MySQL.insert('INSERT INTO warns (name, license, reason, warnedby) VALUES (?, ?, ?, ?)', { result[1].name, result[1].license, reason, GetPlayerName(src) })
                        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.warnedPlayerOffline', { value = result[1].name }))
                        TriggerEvent('qb-log:server:CreateLog', 'warns', 'Player Warned', 'red', string.format('%s was warned by %s for %s', result[1].name, GetPlayerName(src), reason), false)
                    end
                else
                    DebugTrace('Offline warning citizenid had no results. CitizenID: ' .. citizenid)
                end
            else
                DebugTrace('Tried to warn offline but citizenid was invalid. Scripting error.')
            end
        end
    end
end)

AdminPanel.OnlineWarnPlayer = function(source, player, reason)
    local src = source
    local identifier = nil
    if Config.Framework == 'qbcore' then
        identifier = QBCore.Functions.GetIdentifier(player, 'license')
    elseif Config.Framework == 'qbox' then
        identifier = GetPlayerIdentifierByType(player, 'license')
    else
        identifier = ESX.GetIdentifier(player)
    end

    MySQL.insert('INSERT INTO warns (name, license, reason, warnedby) VALUES (?, ?, ?, ?)', { GetPlayerName(player), identifier, reason, GetPlayerName(src) })
    TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.warnedPlayerOnline', { value = GetPlayerName(player) }))
    TriggerEvent('qb-log:server:CreateLog', 'warns', 'Player Warned', 'red', string.format('%s was warned by %s for %s', GetPlayerName(player), GetPlayerName(src), reason), false)
    TriggerClientEvent('919-admin:client:WarnPlayer', player, GetPlayerName(src), reason)
end

AdminPanel.OnlineWarnPlayerFromDiscord = function(player, reason)
    local identifier = nil
    if Config.Framework == 'qbcore' then
        identifier = QBCore.Functions.GetIdentifier(player, 'license')
    elseif Config.Framework == 'qbox' then
        identifier = GetPlayerIdentifierByType(player, 'license')
    else
        identifier = ESX.GetIdentifier(player)
    end

    MySQL.insert('INSERT INTO warns (name, license, reason, warnedby) VALUES (?, ?, ?, ?)', { GetPlayerName(player), identifier, reason, 'DISCORD COMMAND' })
    TriggerEvent('qb-log:server:CreateLog', 'warns', 'Player Warned', 'red', string.format('%s was warned by discord admin command for %s', GetPlayerName(player), reason), false)
    TriggerClientEvent('919-admin:client:WarnPlayer', player, 'DISCORD COMMAND', reason)
end

RegisterNetEvent('919-admin:server:ViewWarnings', function(player, citizenid)
    local src = source
    local license = nil
    if AdminPanel.HasPermission(src, 'checkwarns') then
        if player ~= 'OFFLINE' then
            if Config.Framework == 'qbcore' then
                license = QBCore.Functions.GetIdentifier(player, 'license')
            elseif Config.Framework == 'qbox' then
                license = GetPlayerIdentifierByType(player, 'license')
            else
                license = ESX.GetIdentifier(player)
            end
            DebugTrace('[919-admin:server:ViewWarnings] Got license (online): ' .. license)
        else
            if citizenid ~= nil then
                local result = MySQL.query.await('SELECT * FROM `' .. Config.DB.CharactersTable .. '` WHERE `citizenid` = ?', { citizenid })
                if result[1] then
                    license = result[1].license
                    DebugTrace('[919-admin:server:ViewWarnings] Got license (offline): ' .. license)
                else
                    DebugTrace('Offline view warnings citizenid had no results. CitizenID: ' .. citizenid)
                end
            else
                DebugTrace('Citizenid nil')
            end
        end
        if license ~= nil then
            local result = MySQL.query.await('SELECT * FROM `warns` WHERE `license` = ?', { license })
            if #result > 0 then
                TriggerClientEvent('919-admin:client:ViewWarnings', src, result)
                DebugTrace('[919-admin:server:ViewWarnings] Sending warnings')
            else
                if player ~= 'OFFLINE' then
                    TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.noWarnings') .. '</strong> ' .. Lang:t('alerts.noWarningsPlayer'))
                else
                    TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.noWarnings') .. '</strong> ' .. Lang:t('alerts.noWarningsPlayer'))
                end
            end
        else
            DebugTrace('Citizenid nil')
        end
    end
end)

RegisterNetEvent('919-admin:server:CuffPlayer', function(target)
    local src = source
    if AdminPanel.HasPermission(src, 'cuff') then
        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.cuffed'))
        TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Cuff Player', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** cuffed/uncuffed **' .. GetPlayerName(target) .. '** [' .. target .. ']', false)
        local targetTrigger = 'police:client:GetCuffed'
        if Config.Framework == 'esx' then targetTrigger = 'esx_policejob:handcuff' end
        TriggerClientEvent(targetTrigger, target)
    end
end)

RegisterServerEvent('919-admin:server:RevivePlayer', function(target)
    local src = source
    if AdminPanel.HasPermission(src, 'revive') then
        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.revivePlayer', { value = GetPlayerName(target) }))
        TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Revive', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** revived **' .. GetPlayerName(target) .. '** [' .. target .. ']', false)
        
        Config.ThirdParty.Revive(target)
    end
end)

RegisterServerEvent('919-admin:server:ReviveAll', function()
    local src = source
    if AdminPanel.HasPermission(src, 'reviveall') then
        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.revivedAll'))
        TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Revive', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** revived all players.', false)

        Config.ThirdParty.Revive(-1)
    end
end)

RegisterServerEvent('919-admin:server:MessageAll', function(message)
    local src = source
    if AdminPanel.HasPermission(src, 'messageall') then
        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.sentMessageAll'))
        TriggerClientEvent('chat:addMessage', -1, { color = { 255, 50, 50 }, multiline = true, args = { 'SYSTEM', message } })
    end
end)

RegisterServerEvent('919-admin:server:DeleteAllEntities', function(entityType)
    local src = source
    local entityTypeString = 'VEHICLES'

    if entityType == 1 then
        if not AdminPanel.HasPermission(src, 'massdv') then return end
    elseif entityType == 2 then
        entityTypeString = 'PEDS'
        if not AdminPanel.HasPermission(src, 'massdp') then return end
    end
    TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.DeletedAllEntities', { value = entityTypeString }))
    TriggerClientEvent('919-admin:client:DeleteAllEntities', -1, entityType)
end)

RegisterServerEvent('919-admin:server:SetWeather', function(weatherType)
    local src = source
    if AdminPanel.HasPermission(src, 'setweather') then
        if Config.Framework == 'qbcore' then
            exports['qb-weathersync']:setWeather(weatherType)
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.setWeather', { value = weatherType }))
        elseif Config.Framework == "qbox" then
            GlobalState.weather = {
                weather = tostring(weatherType),
                time = 9999999999
            }
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.setWeather', { value = weatherType }))
        elseif Config.Framework == 'esx' then
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'error', '<strong>' .. Lang:t('alerts.error') .. '</strong> This feature is currently unavailable!')
        end
    end
end)

RegisterServerEvent('919-admin:server:SetTime', function(hour, minute)
    local src = source
    if AdminPanel.HasPermission(src, 'settime') then
        if Config.Framework == 'qbcore' then
            exports['qb-weathersync']:setTime(tonumber(hour), 0)
            TriggerClientEvent('919-admin:client:ShowPanelAlert', 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.setTime', { value = hour }))
        elseif Config.Framework == 'qbox' then
            GlobalState.currentTime = {
                hour = tonumber(hour),
                minute = tonumber(minute),
            }
            TriggerClientEvent('919-admin:client:ShowPanelAlert', 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.setTime', { value = hour }))
        elseif Config.Framework == 'esx' then
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'error', '<strong>' .. Lang:t('alerts.error') .. '</strong> This feature is currently unavailable!')
        end
    end
end)

RegisterServerEvent('919-admin:server:FeedPlayer', function(target)
    local src = source
    if AdminPanel.HasPermission(src, 'foodandwater') then
        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.setMaxValues'))
        if Config.Framework == 'qbcore' then
            local Player = QBCore.Functions.GetPlayer(target)
            Player.Functions.SetMetaData('hunger', 100)
            Player.Functions.SetMetaData('thirst', 100)
            TriggerClientEvent('qb-hud:client:update:needs', target, Player.PlayerData.metadata['hunger'], Player.PlayerData.metadata['thirst'])
        elseif Config.Framework == "qbox" then
            local player = exports.qbx_core:GetPlayer(target)
            player.Functions.SetMetaData('hunger', 100)
            player.Functions.SetMetaData('thirst', 100)
            TriggerClientEvent('hud:client:UpdateNeeds', player.PlayerData.source, 100, 100)
        elseif Config.Framework == 'esx' then
            TriggerClientEvent('esx_status:set', target, 'hunger', 1000000)
            TriggerClientEvent('esx_status:set', target, 'thirst', 1000000)
        end
        TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Food & Water Max', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** fed and watered **' .. GetPlayerName(target) .. '** [' .. target .. ']', false)
    end
end)

RegisterServerEvent('919-admin:server:RelieveStress', function(target)
    local src = source
    if AdminPanel.HasPermission(src, 'relievestress') then
        if Config.Framework == 'qbcore' then
            local Player = QBCore.Functions.GetPlayer(target)
            Player.Functions.SetMetaData('stress', 0)
            TriggerClientEvent('qb-hud:client:update:needs', target, Player.PlayerData.metadata['hunger'], Player.PlayerData.metadata['thirst'])
            TriggerClientEvent('hud:client:UpdateStress', target, 0)
        elseif Config.Framework == "qbox" then
            local player = exports.qbx_core:GetPlayer(target)
            player.Functions.SetMetaData('stress', 0)
            TriggerClientEvent('hud:client:UpdateNeeds', player.PlayerData.source, 100, 100)
            TriggerClientEvent('hud:client:UpdateStress', target, 0)
        end
        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.stressRelieved'))
        TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Relieve Stress', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** relieved stress of **' .. GetPlayerName(target) .. '** [' .. target .. ']', false)
    end
end)

RegisterNetEvent('919-admin:server:SetPedModel', function(player, model)
    local src = source
    if AdminPanel.HasPermission(src, 'setpedmodel') then TriggerClientEvent('919-admin:client:SetPedModel', player, model) end
end)

RegisterNetEvent('919-admin:server:RequestSpectate', function(player)
    local src = source
    if AdminPanel.HasPermission(src, 'spectate') then
        local coords = GetEntityCoords(GetPlayerPed(player))
        SpectatingPlayer[src] = player
        TriggerClientEvent('919-admin:client:RequestSpectate', src, player, coords, GetPlayerName(player))
        TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Spectate', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** started spectating **' .. GetPlayerName(player) .. '** [' .. player .. ']', false)
    end
end)

RegisterNetEvent('919-admin:server:requestNextSpectate', function()
    local src = source
    if AdminPanel.HasPermission(src, 'spectate') and SpectatingPlayer[src] then
        local foundPlayer = false
        local i = SpectatingPlayer[src] + 1
        local crashCounter = 0
        local Player = nil
        repeat
            Player = Bridge.GetPlayer(i)
            if Player ~= nil then
                if i == src then
                else
                    local coords = GetEntityCoords(GetPlayerPed(i))
                    TriggerClientEvent('919-admin:client:RequestSpectate', src, i, coords, GetPlayerName(i))
                    TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Spectate', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** started spectating **' .. GetPlayerName(i) .. '** [' .. i .. ']', false)
                    SpectatingPlayer[src] = i
                    foundPlayer = true
                    crashCounter = 0
                    break
                end
            end
            i = i + 1
            if i >= 200 then
                i = 1
                crashCounter = crashCounter + 1
                if crashCounter > 1 then break end
            end
        until i == 200
        if not foundPlayer then
            Bridge.Notify(src, Lang:t('notify.noPlayerFound'), 'error')
        end
    end
end)

RegisterNetEvent('919-admin:server:requestPrevSpectate', function()
    local src = source
    if AdminPanel.HasPermission(src, 'spectate') and SpectatingPlayer[src] then
        local foundPlayer = false
        local i = SpectatingPlayer[src] - 1
        local crashCounter = 0
        local Player = nil
        repeat
            Player = Bridge.GetPlayer(i)
            if (Player ~= nil) and i ~= src then
                local coords = GetEntityCoords(GetPlayerPed(i))
                TriggerClientEvent('919-admin:client:RequestSpectate', src, i, coords, GetPlayerName(i))
                TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Spectate', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** started spectating **' .. GetPlayerName(i) .. '** [' .. i .. ']', false)
                SpectatingPlayer[src] = i
                foundPlayer = true
                crashCounter = 0
                break
            end
            i = i - 1
            if i <= 0 then
                i = 200
                crashCounter = crashCounter + 1
                if crashCounter > 1 then break end
            end
        until i == 0
        if not foundPlayer then
            Bridge.Notify(src, Lang:t('notify.noPlayerFound'), 'error')
        end
    end
end)

function ExtractIdentifiers(src)
    local identifiers = { steam = '', ip = '', discord = '', license = '', xbl = '', live = '' }

    -- Loop over all identifiers
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)

        -- Convert it to a nice table.
        if string.find(id, 'steam') then
            identifiers.steam = id
        elseif string.find(id, 'ip') then
            identifiers.ip = id
        elseif string.find(id, 'discord') then
            identifiers.discord = id
        elseif string.find(id, 'license') then
            identifiers.license = id
        elseif string.find(id, 'xbl') then
            identifiers.xbl = id
        elseif string.find(id, 'live') then
            identifiers.live = id
        end
    end

    return identifiers
end

RegisterNetEvent('919-admin:server:ScreenshotSubmit', function(playerId)
    local src = source
    if AdminPanel.HasPermission(src, 'screenshot') then
        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.screenshotting'))
        local ids = ExtractIdentifiers(playerId)
        if GetResourceState('discord-screenshot') ~= 'started' then
            print('^1[ERROR]^7 discord-screenshot resource is not started. Please make sure it is started and running.')
            return
        end
        exports['discord-screenshot']:requestCustomClientScreenshotUploadToDiscord(playerId, Config.ScreenshotWebhook, { encoding = 'png', quality = 1 }, {
            username = Config.ServerName .. ' SS Bot', avatar_url = '', content = '', embeds = {
                {
                    color = 16711680, author = { name = '[' .. Config.ServerName .. ' SS Bot]', icon_url = '' }, title = 'Requested Screenshot',
                    description = '**__Player Identifiers:__** \n\n' .. '**Server ID:** `' .. playerId .. '`\n\n' .. '**Username:** `' .. GetPlayerName(playerId) .. '`\n\n' .. '**IP:** `' .. ids.ip .. '`\n\n' .. '**Steam:** `' .. ids.steam .. '`\n\n'
                        .. '**License:** `' .. ids.license .. '`\n\n' .. '**Xbl:** `' .. ids.xbl .. '`\n\n' .. '**Live:** `' .. ids.live .. '`\n\n' .. '**Discord:** `' .. ids.discord .. '`\n\n',
                    footer = { text = '[' .. playerId .. ']' .. GetPlayerName(playerId) }
                }
            }
        });
    end
end)

RegisterNetEvent('919-admin:server:SaveCar', function(mods, modelname, hash, plate, senderId)
    local src = source
    local Player = Bridge.GetPlayer(src)
    local result = MySQL.query.await('SELECT plate FROM `' .. Config.DB.VehiclesTable .. '` WHERE plate = ?', { plate })
    if result[1] == nil then
        MySQL.insert('INSERT INTO `' .. Config.DB.VehiclesTable .. '` (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, ?)',
                     { Player.PlayerData.license or Player.getIdentifier(), Player.PlayerData.citizenid or Player.getIdentifier(), modelname, hash, json.encode(mods), plate, 0 })
        Bridge.Notify(src, Lang:t('notify.VehicleYours'), 'success')
        if senderId then
            TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Admin Car', 'red', '**STAFF MEMBER ' .. GetPlayerName(senderId) .. '** has added a ' .. modelname .. ' (' .. plate .. ') to the garage of ' .. GetPlayerName(src), false)
            TriggerClientEvent('919-admin:client:ShowPanelAlert', senderId, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.addedVehicle', { value = modelname }))
        end
    else
        if senderId then TriggerClientEvent('919-admin:client:ShowPanelAlert', senderId, 'danger', '<strong>' .. Lang:t('alerts.error') .. '</strong> ' .. Lang:t('alerts.playerOwnsAlready')) end
        Bridge.Notify(src, Lang:t('notify.vehicleAlreadyYours'), 'error')
    end
end)

RegisterServerEvent('919-admin:server:RequestVehicleSpawn', function(modelName)
    local src = source
    if AdminPanel.HasPermission(src, 'spawncar') then TriggerClientEvent('919Admin:Command:SpawnVehicle', src, modelName) end
end)

RegisterServerEvent('919-admin:server:DeleteCharacter', function(citizenId)
    local src = source
    if AdminPanel.HasPermission(src, 'deletecharacter') then
        MySQL.query('SELECT * FROM  `' .. Config.DB.CharactersTable .. '` WHERE citizenid = ? LIMIT 1', { citizenId }, function(result)
            if result[1] then
                MySQL.query('DELETE FROM `' .. Config.DB.CharactersTable .. '` WHERE citizenid = ? LIMIT 1', { citizenId }, function(rowsAffected)
                    if rowsAffected then
                        local charInfo = json.decode(result[1].charinfo) or { firstname = result[1].firstname, lastname = result[1].lastname }
                        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.deletedCharacter'))
                        TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Character Deleted', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** deleted ' .. result[1].name .. '\'s character ' .. charInfo.firstname .. ' ' .. charInfo.lastname, false)
                    else
                        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'danger', '<strong>' .. Lang:t('alerts.error') .. '</strong> ' .. Lang:t('alerts.noRowsDeleted'))
                    end
                    local results = MySQL.query.await('SELECT * FROM `' .. Config.DB.CharactersTable .. '`')
                    TriggerClientEvent('919-admin:client:ReceiveCharacters', src, results)
                end)
            else
                TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'danger', '<strong>' .. Lang:t('alerts.error') .. '</strong> ' .. Lang:t('alerts.cantFindLicense'))
            end
        end)
    end
end)

RegisterServerEvent('919-admin:server:UnbanPlayer', function(license)
    local src = source
    if AdminPanel.HasPermission(src, 'unban') then
        MySQL.query('SELECT * FROM `bans` WHERE license = ? LIMIT 1', { license }, function(result)
            if result[1] then
                MySQL.query('DELETE FROM `bans` WHERE license = ? LIMIT 1', { license }, function(rowsAffected)
                    if rowsAffected then
                        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.unbanned'))
                        TriggerEvent('qb-log:server:CreateLog', 'bans', 'Player Unbanned', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** unbanned ' .. result[1].name, false)
                    else
                        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'danger', '<strong>' .. Lang:t('alerts.error') .. '</strong> ' .. Lang:t('alerts.noRowsDeleted'))
                    end
                    local results = MySQL.query.await('SELECT * FROM `bans`')
                    local BansInfo = {}
                    for k1, v1 in ipairs(results) do table.insert(BansInfo, { ID = v1.id, Name = v1.name, License = v1.license, Discord = v1.discord, IP = v1.ip, Reason = v1.reason, Expire = v1.expire, BannedBy = v1.bannedby }) end
                    TriggerClientEvent('919-admin:client:ReceiveBansInfo', src, BansInfo)
                end)
            else
                TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'danger', '<strong>' .. Lang:t('alerts.error') .. '</strong> ' .. Lang:t('alerts.cantFindLicense'))
            end
        end)
    end
end)

RegisterServerEvent('919-admin:server:ClearInventory', function(targetId)
    local src = source
    if AdminPanel.HasPermission(src, 'clearinventory') then
        Bridge.ClearPlayerInventory(targetId)
        TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Inventory Cleared', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** has cleared the inventory of ' .. GetPlayerName(targetId), false)
        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.clearedInventory'))
    end
end)

RegisterServerEvent('919-admin:server:SetJob', function(targetId, job, grade)
    local src = source
    if AdminPanel.HasPermission(src, 'setjob') then
        Bridge.SetPlayerJob(targetId, job, grade)
        TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Set Job', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** set the job of ' .. GetPlayerName(targetId) .. ' to ' .. job .. ' (' .. grade .. ')', false)
        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.jobSet', { value = job, value2 = grade }))
    end
end)

RegisterServerEvent('919-admin:server:SetGang', function(targetId, gang, grade)
    local src = source
    if AdminPanel.HasPermission(src, 'setgang') then
        Bridge.SetPlayerGang(targetId, gang, grade)
        TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Set Gang', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** set the gang of ' .. GetPlayerName(targetId) .. ' to ' .. gang .. ' (' .. grade .. ')', false)
        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.jobSet', { value = gang, value2 = grade }))
    end
end)

local function addItem(targetId, item, amount)
    if (Config.Inventory == 'autodetect' and GetResourceState('ox_inventory') == 'started') or Config.Inventory == 'ox_inventory' then
        exports.ox_inventory:AddItem(targetId, item, amount)
    elseif (Config.Inventory == 'autodetect' and GetResourceState('qs-inventory') == 'started') or Config.Inventory == 'qs-inventory' then
        exports['qs-inventory']:AddItem(targetId, item, amount)
    elseif (Config.Inventory == 'autodetect' and GetResourceState('ps-inventory') == 'started') or Config.Inventory == 'ps-inventory' then
        exports['ps-inventory']:AddItem(targetId, item, amount)
    elseif (Config.Inventory == 'autodetect' and GetResourceState('lj-inventory') == 'started') or Config.Inventory == 'lj-inventory' then
        exports['lj-inventory']:AddItem(targetId, item, amount)
    elseif (Config.Inventory == 'autodetect' and GetResourceState('codem-inventory') == 'started') or Config.Inventory == 'codem-inventory' then
        exports['codem-inventory']:AddItem(targetId, item, amount)
    elseif (Config.Inventory == 'autodetect' and GetResourceState('core_inventory') == 'started') or Config.Inventory == 'core_inventory' then
        exports.core_inventory:addItem(targetId, item, amount)
    else
        if Config.Framework == 'qbcore' then
            local targetPlayer = QBCore.Functions.GetPlayer(targetId)
            if targetPlayer then targetPlayer.Functions.AddItem(item, amount) end
        elseif Config.Framework == 'esx' then
            local targetPlayer = ESX.GetPlayerFromId(tonumber(targetId))
            if targetPlayer then targetPlayer.addInventoryItem(item, amount) end
        end
    end
end

local function removeItem(targetId, item, amount)
    if (Config.Inventory == 'autodetect' and GetResourceState('ox_inventory') == 'started') or Config.Inventory == 'ox_inventory' then
        exports.ox_inventory:RemoveItem(targetId, item, amount)
    elseif (Config.Inventory == 'autodetect' and GetResourceState('qs-inventory') == 'started') or Config.Inventory == 'qs-inventory' then
        exports['qs-inventory']:RemoveItem(targetId, item, amount)
    elseif (Config.Inventory == 'autodetect' and GetResourceState('ps-inventory') == 'started') or Config.Inventory == 'ps-inventory' then
        exports['ps-inventory']:RemoveItem(targetId, item, amount)
    elseif (Config.Inventory == 'autodetect' and GetResourceState('lj-inventory') == 'started') or Config.Inventory == 'lj-inventory' then
        exports['lj-inventory']:RemoveItem(targetId, item, amount)
    elseif (Config.Inventory == 'autodetect' and GetResourceState('codem-inventory') == 'started') or Config.Inventory == 'codem-inventory' then
        exports['codem-inventory']:RemoveItem(targetId, item, amount)
    elseif (Config.Inventory == 'autodetect' and GetResourceState('core_inventory') == 'started') or Config.Inventory == 'core_inventory' then
        exports.core_inventory:removeItem(targetId, item, amount)
    else
        if Config.Framework == 'qbcore' then
            local targetPlayer = QBCore.Functions.GetPlayer(targetId)
            if targetPlayer then targetPlayer.Functions.RemoveItem(item, amount) end
        elseif Config.Framework == 'esx' then
            local targetPlayer = ESX.GetPlayerFromId(tonumber(targetId))
            if targetPlayer then targetPlayer.removeInventoryItem(item, amount) end
        end
    end
end

local function handleItemAction(action, targetId, item, amount)
    local itemList = Bridge.GetItemsList()
    if itemList[item] ~= nil then
        if action == 'add' then
            addItem(targetId, item, amount)
        elseif action == 'remove' then
            removeItem(targetId, item, amount)
        end
        return true, ''
    else
        return false, 'invalid item'
    end
end

RegisterServerEvent('919-admin:server:GiveItem', function(targetId, item, amount)
    local src = source
    if AdminPanel.HasPermission(src, 'giveitem') then
        amount = tonumber(amount)
        if not amount or amount < 1 then amount = 1 end

        if targetId == 'self' or targetId == nil or targetId == '' or targetId == ' ' then targetId = source end

        local success, errorMsg = handleItemAction('add', targetId, item, amount)
        if success then
            TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Item Given', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** gave ' .. item .. ' (x' .. amount .. ') to ' .. GetPlayerName(targetId), false)
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.gaveItem', { value = item }))
            Bridge.Notify(targetId, Lang:t('notify.givenItem', { value = item }), 'success')
        else
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'danger', '<strong>' .. Lang:t('alerts.error') .. '</strong> ' .. Lang:t('alerts.invalidItem'))
        end
    end
end)

AdminPanel.GiveItemFromDiscord = function(targetId, item, amount)
    local success, errorMsg = handleItemAction('add', targetId, item, amount)
    if success then
        TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Item Given', 'red', '**DISCORD** gave ' .. item .. ' (x' .. amount .. ') to ' .. GetPlayerName(targetId), false)
        Bridge.Notify(targetId, Lang:t('notify.givenItem', { value = item }), 'success')
    end
    return success, errorMsg
end

AdminPanel.RemoveItemFromDiscord = function(targetId, item, amount)
    local success, errorMsg = handleItemAction('remove', targetId, item, amount)
    if success then
        TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Item Removed', 'red', '**DISCORD** removed ' .. item .. ' (x' .. amount .. ') from ' .. GetPlayerName(targetId), false)
        Bridge.Notify(targetId, Lang:t('notify.removedItem', { value = item }), 'error')
    end
    return success, errorMsg
end

RegisterServerEvent('919-admin:server:FireJob', function(targetId)
    local src = source
    if AdminPanel.HasPermission(src, 'firejob') then
        Bridge.SetPlayerJob(targetId, 'unemployed', 0)
        TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Set Job', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** fired ' .. GetPlayerName(targetId) .. ' from their job.', false)
        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.firedJob'))
    end
end)

RegisterServerEvent('919-admin:server:FireGang', function(targetId)
    local src = source
    if AdminPanel.HasPermission(src, 'firegang') then
        Bridge.SetPlayerGang(targetId, 'none', 0)
        TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Fired From Gang', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** removed ' .. GetPlayerName(targetId) .. ' from their gang.', false)
        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.firedGang'))
    end
end)

RegisterServerEvent('919-admin:server:FireJobByCitizenId', function(citizenId)
    local src = source
    if AdminPanel.HasPermission(src, 'firejob') then
        if Config.Framework == 'qbox' then
            exports.qbx_core:SetJob(citizenId, 'unemployed', 0)
            TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Set Job', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** removed ' .. citizenId .. ' from their job.', false)
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.firedJob'))
            return
        end

        local targetPlayer = Bridge.GetPlayerFromCharacterIdentifier(citizenId)
        if targetPlayer then
            if Config.Framework == 'qbcore' then
                targetPlayer.Functions.SetJob('unemployed', 0)
                targetPlayer.Functions.Save()
                TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Set Job', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** removed ' .. GetPlayerName(targetPlayer.PlayerData.source) .. ' from their job.', false)
            elseif Config.Framework == 'esx' then
                targetPlayer.setJob('unemployed', 0)
            end
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.firedJob'))
        else -- Player is offline, so we"re going to formulate the default JSON for unemployed and set it to the offline character
            if Config.Framework == 'qbcore' then
                PlayerData = {}
                PlayerData.job = {}
                PlayerData.job.name = 'unemployed'
                PlayerData.job.label = 'Civilian'
                PlayerData.job.payment = 10
                if QBCore.Shared.ForceJobDefaultDutyAtLogin or PlayerData.job.onduty == nil then PlayerData.job.onduty = QBCore.Shared.Jobs[PlayerData.job.name].defaultDuty end
                PlayerData.job.isboss = false
                PlayerData.job.grade = {}
                PlayerData.job.grade.name = 'Freelancer'
                PlayerData.job.grade.level = 0

                MySQL.update('UPDATE `' .. Config.DB.CharactersTable .. '` SET `job` = ? WHERE `citizenid` = ?', { json.encode(PlayerData.job), citizenId }, function(rowsAffected)
                    if rowsAffected ~= 0 and rowsAffected ~= nil then
                        TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Set Job', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** removed (OFFLINE) Citizen ID ' .. citizenId .. ' from their job.', false)
                        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.firedJob'))
                    end
                end)
            elseif Config.Framework == 'esx' then
                MySQL.update('UPDATE `' .. Config.DB.CharactersTable .. '` SET `job` = ? WHERE `identifier` = ?', { 'unemployed', citizenId }, function(rowsAffected)
                    if rowsAffected ~= 0 and rowsAffected ~= nil then
                        TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Set Job', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** removed (OFFLINE) Citizen ID ' .. citizenId .. ' from their job.', false)
                        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.firedJob'))
                    end
                end)
            end
        end
    end
end)

RegisterServerEvent('919-admin:server:FireGangByCitizenId', function(citizenId)
    local src = source
    if AdminPanel.HasPermission(src, 'firegang') then
        if Config.Framework == 'qbox' then
            exports.qbx_core:SetGang(citizenId, 'unemployed', 0)
            TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Set Job Grade', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** removed ' .. citizenId .. ' from their gang.', false)
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.firedGang'))
            return
        end

        if Config.Framework == 'qbcore' then
            local targetPlayer = QBCore.Functions.GetPlayerByCitizenId(citizenId)
            if targetPlayer then
                targetPlayer.Functions.SetGang('none', 0)
                targetPlayer.Functions.Save()
                TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Set Job Grade', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** removed ' .. GetPlayerName(targetPlayer.PlayerData.source) .. ' from their gang.', false)
                TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.firedGang'))
            else -- Player is offline, so we"re going to formulate the default JSON for unemployed and set it to the offline character
                PlayerData = {}
                PlayerData.gang = {}
                PlayerData.gang.name = 'none'
                PlayerData.gang.label = 'No Gang Affiliaton'
                PlayerData.gang.isboss = false
                PlayerData.gang.grade = {}
                PlayerData.gang.grade.name = 'none'
                PlayerData.gang.grade.level = 0
                MySQL.update('UPDATE `' .. Config.DB.CharactersTable .. '` SET `gang` = ? WHERE `citizenid` = ?', { json.encode(PlayerData.gang), citizenId }, function(rowsAffected)
                    if rowsAffected ~= 0 and rowsAffected ~= nil then
                        TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Fired From Gang', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** removed (OFFLINE) Citizen ID ' .. citizenId .. ' from their gang.', false)
                        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.firedGang'))
                    end
                end)
            end
        end
    end
end)

RegisterServerEvent('919-admin:server:SetGangGradeByCitizenId', function(citizenId, grade)
    local src = source
    if AdminPanel.HasPermission(src, 'setgang') then
        if Config.Framework == 'qbox' then
            local playerData = exports.qbx_core:GetPlayerByCitizenId(citizenId) or exports.qbx_core:GetOfflinePlayer(citizenId)
            exports.qbx_core:SetJob(citizenId, playerData.job.name, grade)
            TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Set Gang Grade', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** set gang grade of ' .. citizenId .. ' to ' .. grade .. '.', false)
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.gangGradeSet', { value = grade }))
            return
        end

        if Config.Framework == 'qbcore' then
            local targetPlayer = QBCore.Functions.GetPlayerByCitizenId(citizenId)
            if targetPlayer then
                if QBCore.Shared.Gangs[targetPlayer.PlayerData.gang.name].grades[grade] ~= nil then
                    targetPlayer.Functions.SetGang(targetPlayer.PlayerData.gang.name, grade)
                    targetPlayer.Functions.Save()
                    TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Set Gang Grade', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** set gang grade of ' .. GetPlayerName(targetPlayer.PlayerData.source) .. ' to ' .. grade .. '.', false)
                    TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> Set gang grade of ' .. GetPlayerName(targetId) .. ' to ' .. grade)
                else
                    TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'danger', '<strong>' .. Lang:t('alerts.error') .. '</strong> ' .. Lang:t('alerts.invalidgangGrade'))
                end
            else
                local result = MySQL.query.await('SELECT `gang` FROM ' .. Config.DB.CharactersTable .. ' WHERE citizenid = ?', { citizenId })
                if result ~= nil then
                    local gangInfo = json.decode(result[1].gang)
                    if gangInfo.grade ~= nil then
                        if QBCore.Shared.Gangs[gangInfo.name].grades[grade] ~= nil then
                            gangInfo.isboss = (QBCore.Shared.Gangs[gangInfo.name].grades[grade].isboss and true or false) -- We dont need a "payment" here because gangs dont have a salary.
                            gangInfo.grade.name = QBCore.Shared.Gangs[gangInfo.name].grades[grade].name -- We only need isboss, grade.name information from framework
                            gangInfo.grade.level = tonumber(grade)
                            MySQL.update('UPDATE `' .. Config.DB.CharactersTable .. '` SET `gang` = ? WHERE `citizenid` = ?', { json.encode(gangInfo), citizenId }, function(rowsAffected)
                                if rowsAffected ~= 0 and rowsAffected ~= nil then
                                    TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Set Gang Grade', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** set citizen id ' .. citizenId .. ' to gang grade ' .. grade .. ' (OFFLINE)', false)
                                    TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.gangGradeSet', { value = grade }))
                                else
                                    TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'danger', '<strong>' .. Lang:t('alerts.error') .. '</strong> ' .. Lang:t('alerts.databaseError'))
                                end
                            end)
                        else
                            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'danger', '<strong>' .. Lang:t('alerts.error') .. '</strong> ' .. Lang:t('alerts.invalidgangGrade'))
                        end
                    else
                        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'danger', '<strong>' .. Lang:t('alerts.error') .. '</strong> ' .. Lang:t('alerts.databaseError2'))
                    end
                else
                    TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'danger', '<strong>' .. Lang:t('alerts.error') .. '</strong> ' .. Lang:t('alerts.databaseError3'))
                end
            end
        end
    end
end)

RegisterServerEvent('919-admin:server:SetJobGradeByCitizenId', function(citizenId, grade)
    local src = source
    if AdminPanel.HasPermission(src, 'setjob') then
        if Config.Framework == 'qbox' then
            local playerData = exports.qbx_core:GetPlayerByCitizenId(citizenId) or exports.qbx_core:GetOfflinePlayer(citizenId)
            exports.qbx_core:SetJob(citizenId, playerData.job.name, grade)
            TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Set Job', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** set job grade of ' .. GetPlayerName(targetPlayer.PlayerData.source) .. ' to ' .. grade .. '.', false)
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> Set job grade of ' .. GetPlayerName(targetId) .. ' to ' .. grade)
            return
        end

        local targetPlayer = Bridge.GetPlayerFromCharacterIdentifier(citizenId)
        if targetPlayer then
            if Config.Framework == 'qbcore' then
                if QBCore.Shared.Jobs[targetPlayer.PlayerData.job.name].grades[grade] ~= nil then
                    targetPlayer.Functions.SetJob(targetPlayer.PlayerData.job.name, grade)
                    targetPlayer.Functions.Save()
                    TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Set Job', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** set job grade of ' .. GetPlayerName(targetPlayer.PlayerData.source) .. ' to ' .. grade .. '.', false)
                    TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> Set job grade of ' .. GetPlayerName(targetId) .. ' to ' .. grade)
                else
                    TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'danger', '<strong>' .. Lang:t('alerts.error') .. '</strong> Invalid job grade.')
                end
            elseif Config.Framework == 'esx' then
                targetPlayer.setJob(targetPlayer.getJob().name, grade)
                TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Set Job', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** set job grade of ' .. GetPlayerName(targetPlayer.PlayerData.source) .. ' to ' .. grade .. '.', false)
                TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> Set job grade of ' .. GetPlayerName(targetId) .. ' to ' .. grade)
            end
        else
            local result = nil
            if Config.Framework == 'qbcore' then
                result = MySQL.query.await('SELECT `job` FROM `' .. Config.DB.CharactersTable .. '` WHERE citizenid = ?', { citizenId })
            elseif Config.Framework == 'esx' then
                result = MySQL.query.await('SELECT `job` FROM `' .. Config.DB.CharactersTable .. '` WHERE identifier = ?', { citizenId })
            end
            if result ~= nil then
                jobInfo = result[1].job
                if Config.Framework == 'qbcore' then
                    jobInfo = json.decode(result[1].job)
                    if QBCore.Shared.Jobs[jobInfo.name].grades[grade] ~= nil then
                        jobInfo.payment = QBCore.Shared.Jobs[jobInfo.name].grades[grade].payment
                        jobInfo.isboss = (QBCore.Shared.Jobs[jobInfo.name].grades[grade].isboss and true or false)
                        jobInfo.grade.name = QBCore.Shared.Jobs[jobInfo.name].grades[grade].name
                        jobInfo.grade.level = tonumber(grade)
                        MySQL.update('UPDATE `' .. Config.DB.CharactersTable .. '` SET `job` = ? WHERE `citizenid` = ?', { json.encode(jobInfo), citizenId }, function(rowsAffected)
                            if rowsAffected ~= 0 and rowsAffected ~= nil then
                                TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Set Job Grade', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** set citizen id ' .. citizenId .. ' to job grade ' .. grade .. ' (OFFLINE)', false)
                                TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.jobGradeSet', { value = grade }))
                            else
                                TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'danger', '<strong>' .. Lang:t('alerts.error') .. '</strong> ' .. Lang:t('alerts.databaseError'))
                            end
                        end)
                    else
                        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'danger', '<strong>' .. Lang:t('alerts.error') .. '</strong> ' .. Lang:t('alerts.invalidJobGrade'))
                    end
                elseif Config.Framework == 'esx' then
                    MySQL.update('UPDATE `' .. Config.DB.CharactersTable .. '` SET `job_grade` = ? WHERE `identifier` = ?', { jobInfo.grade.level, citizenId }, function(rowsAffected)
                        if rowsAffected ~= 0 and rowsAffected ~= nil then
                            TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Set Job Grade', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** set citizen id ' .. citizenId .. ' to job grade ' .. grade .. ' (OFFLINE)', false)
                            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.jobGradeSet', { value = grade }))
                        else
                            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'danger', '<strong>' .. Lang:t('alerts.error') .. '</strong> ' .. Lang:t('alerts.databaseError'))
                        end
                    end)
                end
            else
                TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'danger', '<strong>' .. Lang:t('alerts.error') .. '</strong> ' .. Lang:t('alerts.databaseError3'))
            end
        end
    end
end)

RegisterServerEvent('919-admin:server:AddVehicleToGarage', function(targetId)
    local src = source
    if AdminPanel.HasPermission(src, 'savecar') then TriggerClientEvent('919-admin:client:SaveCar', targetId, src) end
end)

RegisterServerEvent('919-admin:server:BringPlayer', function(targetId)
    local src = source
    if AdminPanel.HasPermission(src, 'teleport') then
        SendPlayerBack[targetId] = GetEntityCoords(GetPlayerPed(targetId))
        local coords = GetEntityCoords(GetPlayerPed(src))
        SetEntityCoords(GetPlayerPed(targetId), coords)
        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.teleportToYou', { value = GetPlayerName(targetId) }))
        TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Teleport', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** brought **' .. GetPlayerName(targetId) .. '** [' .. targetId .. '] to them', false)
    end
end)

RegisterServerEvent('919-admin:server:SendPlayerBack', function(targetId)
    local src = source
    if AdminPanel.HasPermission(src, 'teleport') then
        if SendPlayerBack[targetId] then
            SetEntityCoords(GetPlayerPed(targetId), SendPlayerBack[targetId])
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.teleportedBack', { value = GetPlayerName(targetId) }))
            SendPlayerBack[targetId] = nil
        else
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'danger', '<strong>' .. Lang:t('alerts.error') .. '</strong> ' .. Lang:t('alerts.noPosition'))
        end
    end
end)

RegisterServerEvent('919-admin:server:SendBackSelf', function()
    local src = source
    if AdminPanel.HasPermission(src, 'teleport') then
        if SendBack[src] then
            SetEntityCoords(GetPlayerPed(src), SendBack[src])
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.sentSelfBack'))
            SendBack[src] = nil
        else
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'danger', '<strong>' .. Lang:t('alerts.error') .. '</strong> ' .. Lang:t('alerts.noPosition'))
        end
    end
end)

RegisterServerEvent('919-admin:server:GotoPlayer', function(targetId)
    local src = source
    if AdminPanel.HasPermission(src, 'teleport') then
        SendBack[src] = GetEntityCoords(GetPlayerPed(src))
        local coords = GetEntityCoords(GetPlayerPed(targetId))
        SetEntityCoords(GetPlayerPed(src), coords.x, coords.y, coords.z)
        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.teleportedTo', { value = GetPlayerName(targetId) }))
        TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Teleport', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** teleported to **' .. GetPlayerName(targetId) .. '** [' .. targetId .. ']', false)
    end
end)

AdminPanel.CreateCallback('919-admin:server:GetPlayerPositions', function(source, cb)
    local PlayerPositions = {}
    for _, playerId in pairs(GetPlayers()) do table.insert(PlayerPositions, { pos = GetEntityCoords(GetPlayerPed(playerId)), name = GetPlayerName(playerId), id = playerId }) end
    cb(PlayerPositions)
end)

RegisterServerEvent('919-admin:server:SetPermissions', function(targetId, group)
    if Config.Framework == 'qbcore' then
        QBCore.Functions.AddPermission(targetId, group.rank)
    elseif Config.Framework == 'qbox' then
        exports.qbx_core:AddPermission(targetId, group.rank)
    elseif Config.Framework == 'esx' then
        local Player = ESX.GetPlayerFromId(targetId)
        Player.setGroup(group)
    end
    Bridge.Notify(targetId, Lang:t('alerts.permissionsSet', { value = group.label }))
end)

RegisterServerEvent('919-admin:server:OpenSkinMenu', function(targetId)
    local src = source
    if AdminPanel.HasPermission(src, 'clothing') then
        TriggerClientEvent('919-admin:client:ShowPanelAlert', source, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.skinMenuOpened', { value = GetPlayerName(targetId) }))
        if Config.ThirdParty.Clothing then Config.ThirdParty.Clothing(targetId) end
        TriggerEvent('qb-log:server:CreateLog', 'adminactions', 'Skin Menu', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** opened skin menu for ' .. GetPlayerName(targetId), false)
    end
end)