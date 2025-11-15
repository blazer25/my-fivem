local activeBlips = {}

local function createBlip(data)
    local blip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
    SetBlipSprite(blip, data.sprite or 161)
    SetBlipColour(blip, data.colour or 1)
    SetBlipScale(blip, 1.0)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(data.label or 'Heist Alert')
    EndTextCommandSetBlipName(blip)
    if data.duration then
        SetTimeout(data.duration * 1000, function()
            if DoesBlipExist(blip) then RemoveBlip(blip) end
        end)
    end
    activeBlips[#activeBlips + 1] = blip
end

RegisterNetEvent('cs_heistbuilder:client:dispatch', function(payload)
    payload = payload or {}
    if not payload.coords then return end
    createBlip(payload)
    lib.notify({
        title = payload.title or 'Heist Dispatch',
        description = payload.message or 'Respond immediately!',
        type = 'error'
    })
    if payload.evidence then
        lib.notify({
            description = ('Evidence flagged: %s'):format(payload.evidence),
            type = 'warning'
        })
    end
end)

RegisterNetEvent('cs_heistbuilder:client:lastKnown', function(coords, seconds)
    lib.notify({ description = 'Last known suspect location updated', type = 'inform' })
    createBlip({ coords = coords, sprite = 480, colour = 5, duration = seconds or 30, label = 'Last Known' })
end)

return true
