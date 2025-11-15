local Global = _G.DynamicHeist or {}
_G.DynamicHeist = Global
local Animations = {}
local activeDict, activeAnim = nil, nil

local animationSets = {
    drill = {dict = "anim@heists@fleeca_bank@drilling", name = "drill_straight_idle", flag = 49},
    thermite = {dict = "anim@heists@ornate_bank@thermal_charge", name = "thermal_charge", flag = 49},
    c4 = {dict = "anim@heists@ornate_bank@bomb", name = "plant_bomb", flag = 49},
    vault = {dict = "anim@heists@ornate_bank@vault_open", name = "vault_open", flag = 49},
    zip = {dict = "anim@heists@humane_labs@finale@keycards", name = "ped_a_enter_loop", flag = 49},
    loot = {dict = "anim@heists@ornate_bank@grab_cash_heels", name = "grab", flag = 49}
}

local function loadAnimDict(dict)
    if HasAnimDictLoaded(dict) then return end
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(10)
    end
end

function Animations.PlayPreset(preset)
    local anim = animationSets[preset]
    if not anim then return end
    loadAnimDict(anim.dict)
    TaskPlayAnim(PlayerPedId(), anim.dict, anim.name, 8.0, -8.0, -1, anim.flag or 1, 0, false, false, false)
    activeDict, activeAnim = anim.dict, anim.name
end

function Animations.PlayScenario(scenario)
    TaskStartScenarioInPlace(PlayerPedId(), scenario, 0, true)
    activeDict, activeAnim = nil, nil
end

function Animations.Stop()
    local ped = PlayerPedId()
    ClearPedTasks(ped)
    if activeDict then
        RemoveAnimDict(activeDict)
        activeDict = nil
    end
end

Global.Animations = Animations
