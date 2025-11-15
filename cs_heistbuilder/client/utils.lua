local ClientUtils = {}
local Utils = CS_HEIST_SHARED_UTILS or {}

local cinematicSounds = {
    drill = { dict = 'DLC_HEIST_FLEECA_SOUNDSET', sound = 'Drill_Pin_Break' },
    alarm = { dict = 'DLC_HEIST_FLEECA_SOUNDSET', sound = 'alarm_loop' },
    success = { dict = 'HUD_AWARDS', sound = 'FLIGHT_SCHOOL_GOLD' }
}

function ClientUtils.playSound(name, coords)
    local sound = cinematicSounds[name]
    if not sound then return end
    if coords then
        PlaySoundFromCoord(-1, sound.sound, coords.x, coords.y, coords.z, sound.dict, false, 0, false)
    else
        PlaySoundFrontend(-1, sound.sound, sound.dict, true)
    end
end

function ClientUtils.showHelp(text)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

function ClientUtils.marker(id, coords, colour, scale)
    DrawMarker(id or 1, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, scale, scale, scale, colour.r, colour.g, colour.b, colour.a or 128, false, true, 2, false, nil, nil, false)
end

function ClientUtils.notify(opts)
    opts = opts or {}
    lib.notify({
        title = opts.title or 'Heist Builder',
        description = opts.description or 'Unknown',
        type = opts.type or 'inform'
    })
end

function ClientUtils.progress(opts)
    opts = opts or {}
    return lib.progressCircle({
        duration = (opts.duration or 8.0) * 1000,
        label = opts.label or 'Working',
        position = 'middle',
        useWhileDead = false,
        canCancel = opts.canCancel ~= false,
        disable = opts.disable or { move = true, car = true, combat = true }
    })
end

function ClientUtils.getLookCoords(distance)
    distance = distance or 5.0
    local ped = cache.ped
    local rot = GetGameplayCamRot(2)
    local coordA = GetGameplayCamCoord()
    local direction = -vector3(
        math.sin(math.rad(rot.z)) * math.cos(math.rad(rot.x)),
        math.cos(math.rad(rot.z)) * math.cos(math.rad(rot.x)),
        math.sin(math.rad(rot.x))
    )
    local target = coordA + direction * distance
    local _, hit, endCoords = GetShapeTestResult(StartShapeTestRay(coordA.x, coordA.y, coordA.z, target.x, target.y, target.z, -1, ped, 0))
    if hit then
        return endCoords
    end
    return target
end

function ClientUtils.sceneCamera(coords, lookAt, duration)
    duration = duration or 4000
    local cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 45.0)
    PointCamAtCoord(cam, lookAt.x, lookAt.y, lookAt.z)
    RenderScriptCams(true, true, 0, true, true)
    Wait(duration)
    RenderScriptCams(false, true, 1000, true, true)
    DestroyCam(cam)
end

function ClientUtils.ensureWeapon(weapon)
    if HasPedGotWeapon(cache.ped, weapon, false) then return end
    GiveWeaponToPed(cache.ped, weapon, 30, false, true)
end

ClientUtils.runtimeWrapper = function(heistId, stepIndex)
    local self = { heistId = heistId, stepIndex = stepIndex }
    function self:complete(success, payload)
        TriggerServerEvent('cs_heistbuilder:server:stepResult', self.heistId, self.stepIndex, success ~= false, payload or {})
    end
    return self
end

CS_HEIST_CLIENT_UTILS = ClientUtils

return ClientUtils
