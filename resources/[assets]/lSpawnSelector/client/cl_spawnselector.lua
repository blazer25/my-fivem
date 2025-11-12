BOUTIQUE = BOUTIQUE or {}
BOUTIQUE.Config = BOUTIQUE.Config or {}

local function getFallbackSpawn()
    local index = BOUTIQUE.Config.fallbackSpawnIndex or 1
    return BOUTIQUE.Config.spawns[index]
end

local function getLastLocation()
    local playerData = exports['qbx_core'] and exports['qbx_core']:GetPlayerData() or nil
    if not playerData then return nil end

    local position = playerData.position or playerData.lastLocation
    if not position or not position.x or not position.y or not position.z then return nil end

    local heading = position.w or position.heading or position.h or 0.0
    return vector4(position.x, position.y, position.z, heading)
end

local function notify(message, notifyType)
    if lib and lib.notify then
        lib.notify({
            title = BOUTIQUE.Config.title or 'Spawn',
            description = message,
            type = notifyType or 'inform'
        })
    else
        TriggerEvent('QBCore:Notify', message, notifyType or 'inform')
    end
end

local function spawnPlayerAt(position, ped)
    local pPed = ped or PlayerPedId()
    TriggerEvent("CORE.UI:Close")
    TeleportToWp(pPed, position, position.w)
    Wait(1000)
    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
    TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
end

AddEventHandler("spawnselector:open", function()
    OpenUI(true, "spawnselector", {}, {
        title = BOUTIQUE.Config.title,
        subtitle = BOUTIQUE.Config.subtitle,
        serverLogo = BOUTIQUE.Config.serverLogo,
        color = BOUTIQUE.Config.color,
        spawns = BOUTIQUE.Config.spawns,
        translate = BOUTIQUE.Config.translate
    })
end)

RegisterNetEvent('CORE.UI:spawnselector:spawn', function(data)
    if not data then return end

    local spawnIndex = data.spawn
    if spawnIndex == nil then return end

    local selection = BOUTIQUE.Config.spawns[spawnIndex + 1]
    if not selection then return end

    local ped = PlayerPedId()

    if selection.useLastLocation then
        local lastLocation = getLastLocation()
        if lastLocation then
            spawnPlayerAt(lastLocation, ped)
            return
        else
            notify('No previous location found. Spawning you at the default location.', 'error')
            selection = getFallbackSpawn()
        end
    end

    if selection and selection.position then
        spawnPlayerAt(selection.position, ped)
    else
        notify('Unable to determine a spawn location. Please try again in a moment.', 'error')
    end
end)