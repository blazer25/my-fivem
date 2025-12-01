QT = {}
QT.PlayerInfo = {}
State = {}
State.ServerCallbacks = {}

function QT.AddCommand(name, handler, restricted)
    RegisterCommand(name, function(source, args, rawCommand)
        handler(args)  
    end, restricted)
end

RegisterNetEvent("qt-onPlayerLoad")
 AddEventHandler("qt-onPlayerLoad", function(xPlayer)
    local playerName = GetPlayerName(xPlayer)
    QT.PlayerInfo[xPlayer] = {
        accname = playerName, 
        ped = GetPlayerPed(xPlayer),  
        ip = GetPlayerEndpoint(xPlayer),
        identifier = QT.GetIdentifier("steam", xPlayer),
        rockstar = QT.GetIdentifier("license", xPlayer)
    }
end)

function QT.GetIdentifier(type, id)
    local identifiers = {}
    local numIdentifiers = GetNumPlayerIdentifiers(id)

    for a = 0, numIdentifiers do
        table.insert(identifiers, GetPlayerIdentifier(id, a))
    end

    for b = 1, #identifiers do
        if string.find(identifiers[b], type, 1) then
            return identifiers[b]
        end
    end
    return false
end

function QT.GetPlayerNameByID(playerID)
    local playerName = QT.PlayerInfo[playerID].accname
    if playerName then
        return playerName
    else
        return print("Player with id not found")
    end
end

QT.RegisterServerCall = function(name, cb)
     State.ServerCallbacks[name] = cb
end

QT.TriggerServerCall = function(name, requestId, source, cb, ...)
    if State.ServerCallbacks[name] then
        State.ServerCallbacks[name](source, cb, ...)
    else
      print(('[^ERROR^7] Server core call ^5"%s"^0 does not exist.^1'):format(name))
    end
end

RegisterServerEvent('qt:RegisterCallback')
  AddEventHandler('qt:RegisterCallback', function(name, requestId, ...)
  local playerId = source

  QT.TriggerServerCall(name, requestId, playerId, function(...)
    TriggerClientEvent('qt:serverCallback', playerId, requestId, ...)
  end, ...)
end)
