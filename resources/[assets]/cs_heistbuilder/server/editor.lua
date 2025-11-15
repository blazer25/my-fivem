local Utils = CS_HEIST_SHARED_UTILS or {}
local Storage = CS_HEIST_SERVER.Storage

lib.callback.register('cs_heistbuilder:server:hasBuilderPerms', function(source)
    local allowed = Utils.hasBuilderPerms(source)
    local state = Player(source).state
    state:set('isHeistBuilderAdmin', allowed, true)
    return allowed
end)

RegisterNetEvent('cs_heistbuilder:server:saveHeist', function(payload)
    local src = source
    if not Utils.hasBuilderPerms(src) then return end
    if type(payload) ~= 'table' or not payload.id then
        TriggerClientEvent('cs_heistbuilder:client:saveResult', src, false, 'Invalid payload')
        return
    end

    payload.entryPoint = payload.entryPoint or Utils.serialiseVec(GetEntityCoords(GetPlayerPed(src)))
    payload.steps = payload.steps or {}
    payload.guards = payload.guards or {}
    payload.rewards = payload.rewards or {}
    payload.evidence = payload.evidence or {}

    Storage.saveHeist(payload)
    TriggerClientEvent('cs_heistbuilder:client:saveResult', src, true, ('Heist %s saved'):format(payload.id))
    local heists = Storage.getHeists()
    local list = {}
    for _, heist in pairs(heists) do
        list[#list + 1] = heist
    end
    TriggerClientEvent('cs_heistbuilder:client:syncHeists', -1, list)
end)

RegisterNetEvent('cs_heistbuilder:server:testHeist', function(heistId)
    local src = source
    if not Utils.hasBuilderPerms(src) then return end
    TriggerEvent('cs_heistbuilder:internal:startTest', src, heistId)
end)
