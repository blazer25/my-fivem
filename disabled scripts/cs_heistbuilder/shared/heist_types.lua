local HeistStepTypes = {}
local Utils = CS_HEIST_SHARED_UTILS or {}
local isServer = IsDuplicityVersion()

local function clientOnly(fn)
    if isServer then
        return function() end
    end
    return fn
end

local function serverOnly(fn)
    if isServer then
        return fn
    end
    return function() end
end

local function doClientProgress(runtime, opts)
    if isServer then return end
    local duration = (opts and opts.duration or 10.0) * 1000
    local label = opts and opts.label or 'Processing'
    local anim = opts and opts.anim
    local disable = opts and opts.disable or { car = true, move = true, combat = true }

    if anim and anim.dict then
        lib.requestAnimDict(anim.dict, 5000)
        TaskPlayAnim(cache.ped, anim.dict, anim.clip or 'idle', 1.0, 1.0, duration, anim.flags or 1, 0, false, false, false)
    end

    local success = lib.progressCircle({
        duration = duration,
        position = 'middle',
        label = label,
        useWhileDead = false,
        disable = disable,
        canCancel = false
    })

    if anim and anim.dict then
        StopAnimTask(cache.ped, anim.dict, anim.clip or 'idle', 1.0)
    end

    runtime:complete(success, opts and opts.payload or {})
end

local function doClientThermite(runtime, opts)
    if isServer then return end
    opts = opts or {}
    local coords = opts.coords or GetEntityCoords(cache.ped)
    local ptfx = 'scr_ornate_heist'
    local asset = 'scr_heist_ornate_thermal_burn'
    lib.requestNamedPtfxAsset(ptfx)
    UseParticleFxAssetNextCall(ptfx)
    local fx = StartParticleFxLoopedAtCoord(asset, coords.x, coords.y, coords.z + 0.1, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
    PlaySoundFromCoord(-1, 'Drill_Pin_Break', coords.x, coords.y, coords.z, 'DLC_HEIST_FLEECA_SOUNDSET', false, 0, false)
    doClientProgress(runtime, {
        duration = opts.duration or 12.0,
        label = opts.label or 'Melting bolts',
        payload = { heat = true }
    })
    StopParticleFxLooped(fx, 0)
    RemoveNamedPtfxAsset(ptfx)
end

local function doClientDrill(runtime, opts)
    if isServer then return end
    opts = opts or {}
    local drillProp = `hei_prop_heist_drill`
    RequestModel(drillProp)
    while not HasModelLoaded(drillProp) do Wait(0) end
    local ped = cache.ped
    local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.5, -0.5)
    local prop = CreateObject(drillProp, coords.x, coords.y, coords.z, true, true, true)
    AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, 57005), 0.16, 0.04, -0.02, 90.0, 90.0, 180.0, true, true, false, true, 1, true)
    TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_CONST_DRILL', 0, true)
    doClientProgress(runtime, {
        duration = opts.duration or 15.0,
        label = opts.label or 'Drilling',
        payload = { noise = true }
    })
    ClearPedTasks(ped)
    DeleteObject(prop)
end

local function doClientLoot(runtime, opts)
    if isServer then return end
    opts = opts or {}
    local dict = 'anim@heists@ornate_bank@grab_cash'
    lib.requestAnimDict(dict)
    TaskPlayAnim(cache.ped, dict, 'grab', 8.0, -8.0, (opts.duration or 8.0) * 1000, 1, 0, false, false, false)
    doClientProgress(runtime, {
        duration = opts.duration or 8.0,
        label = opts.label or 'Bagging loot',
        payload = { loot = opts.loot or 'cash' }
    })
    StopAnimTask(cache.ped, dict, 'grab', 1.0)
end

HeistStepTypes['hack_panel'] = {
    label = 'Hack Security Panel',
    startClient = clientOnly(function(heistId, stepData, runtime)
        doClientProgress(runtime, {
            duration = stepData.duration or 10.0,
            label = stepData.label or 'Bypassing security',
            payload = { difficulty = stepData.difficulty or 'medium' }
        })
    end),
    startServer = serverOnly(function(source, stepData)
        -- server validates hack and maybe reduce alarm level
        return {
            hacked = true,
            difficulty = stepData.difficulty or 'medium'
        }
    end)
}

HeistStepTypes['disable_alarm'] = {
    label = 'Disable Alarm Grid',
    startClient = clientOnly(function(_, stepData, runtime)
        doClientProgress(runtime, {
            duration = stepData.duration or 7.5,
            label = stepData.label or 'Cutting alarm grid',
            payload = { alarmDisabled = true }
        })
    end),
    startServer = serverOnly(function(_, stepData)
        return { alarmDisabled = true, window = stepData.window or 60 }
    end)
}

HeistStepTypes['cut_power'] = {
    label = 'Cut Power',
    startClient = clientOnly(function(_, stepData, runtime)
        doClientThermite(runtime, {
            duration = stepData.duration or 9.0,
            label = stepData.label or 'Severing power lines'
        })
    end),
    startServer = serverOnly(function(_, stepData)
        return { blackoutSeconds = stepData.blackoutSeconds or 90 }
    end)
}

HeistStepTypes['drill_boxes'] = {
    label = 'Drill Lockboxes',
    startClient = clientOnly(function(_, stepData, runtime)
        doClientDrill(runtime, {
            duration = stepData.duration or 16.0,
            label = stepData.label or 'Opening deposit boxes'
        })
    end),
    startServer = serverOnly(function(_, stepData)
        return { opened = stepData.lockboxes or 1 }
    end)
}

HeistStepTypes['grab_loot'] = {
    label = 'Grab Loot',
    startClient = clientOnly(function(_, stepData, runtime)
        doClientLoot(runtime, {
            duration = stepData.duration or 8.0,
            loot = stepData.lootType or 'cash',
            label = stepData.label or 'Collecting loot'
        })
    end),
    startServer = serverOnly(function(_, stepData)
        return { lootType = stepData.lootType or 'cash', amount = stepData.amount or 1 }
    end)
}

HeistStepTypes['thermal_charge'] = {
    label = 'Thermite Vault',
    startClient = clientOnly(function(_, stepData, runtime)
        doClientThermite(runtime, {
            duration = stepData.duration or 12.0,
            label = stepData.label or 'Thermite in progress'
        })
    end),
    startServer = serverOnly(function(_, stepData)
        return { breached = true, burn = stepData.burn or 'door' }
    end)
}

HeistStepTypes['safe_crack'] = {
    label = 'Crack Safe',
    startClient = clientOnly(function(_, stepData, runtime)
        doClientProgress(runtime, {
            duration = stepData.duration or 14.0,
            label = stepData.label or 'Listening to tumblers',
            payload = { safe = true }
        })
    end),
    startServer = serverOnly(function(_, stepData)
        return { code = stepData.code or Utils.randomId(4) }
    end)
}

HeistStepTypes['escape'] = {
    label = 'Escape Radius',
    startClient = clientOnly(function(_, stepData, runtime)
        local coords = stepData.coords and Utils.toVector(stepData.coords) or GetEntityCoords(cache.ped)
        local radius = stepData.radius or 25.0
        lib.notify({ description = ('Reach the escape zone (%.1fm)'):format(radius), type = 'inform' })
        local finished = false
        CreateThread(function()
            while not finished do
                local playerCoords = GetEntityCoords(cache.ped)
                DrawMarker(1, coords.x, coords.y, coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, radius, radius, 1.0, 0, 255, 128, 80, false, false, 2, false, nil, nil, false)
                if #(playerCoords - coords) <= radius then
                    finished = true
                    runtime:complete(true, { escaped = true })
                    break
                end
                Wait(0)
            end
        end)
    end),
    startServer = serverOnly(function(_, stepData)
        return { escapeRadius = stepData.radius or 25.0 }
    end)
}

CS_HEIST_STEP_TYPES = HeistStepTypes

return HeistStepTypes
