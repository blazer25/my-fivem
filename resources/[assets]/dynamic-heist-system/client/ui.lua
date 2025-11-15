local Global = _G.DynamicHeist or {}
_G.DynamicHeist = Global
local UI = {}

function UI.Draw3DText(coords, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(coords.x, coords.y, coords.z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

function UI.Notify(message)
    SetNotificationTextEntry("STRING")
    AddTextComponentSubstringPlayerName("~y~[Heist]~s~ " .. message)
    DrawNotification(false, true)
end

function UI.PlaySound(sound)
    PlaySoundFrontend(-1, sound or "NAV_LEFT_RIGHT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
end

function UI.Progress(label, duration, opts, cb)
    local ped = PlayerPedId()
    local remaining = duration
    UI.Notify(label)
    Citizen.CreateThread(function()
        while remaining > 0 do
            Citizen.Wait(1000)
            remaining = remaining - 1
        end
        ClearPedTasks(ped)
        if cb then cb() end
    end)
    local scenario = opts and opts.scenario
    if scenario then
        TaskStartScenarioInPlace(ped, scenario, 0, true)
    end
end

Global.UI = UI
