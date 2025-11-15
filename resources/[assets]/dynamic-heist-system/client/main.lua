local Global = _G.DynamicHeist or {}
_G.DynamicHeist = Global

local Client = {
    activeHeist = nil,
    stage = 0,
    isBusy = false,
    cooldowns = {},
    heists = nil
}

local function getUI()
    return Global.UI
end

local function getAnimations()
    return Global.Animations
end

local function decodeValue(value)
    local valueType = type(value)
    if valueType == "table" then
        if value.__type == "vector3" then
            return vector3(value.x + 0.0, value.y + 0.0, value.z + 0.0)
        end
        local result = {}
        for k, v in pairs(value) do
            result[k] = decodeValue(v)
        end
        return result
    end
    return value
end

local function setHeists(payload)
    Client.heists = decodeValue(payload or {})
end

local function getHeists()
    return Client.heists or Config.Heists
end

local stagePresets = {
    hack = {anim = "c4", scenario = "WORLD_HUMAN_STAND_IMPATIENT"},
    drill = {anim = "drill", scenario = "WORLD_HUMAN_CONST_DRILL"},
    loot = {anim = "loot", scenario = "WORLD_HUMAN_GARDENER_LEAF_BLOWER"},
    disable_alarm = {anim = "c4", scenario = "WORLD_HUMAN_STAND_FIRE"},
    smash = {anim = "loot", scenario = "WORLD_HUMAN_HAMMERING"},
    load = {scenario = "WORLD_HUMAN_CONST_DRILL"},
    cut = {anim = "drill", scenario = "WORLD_HUMAN_CONST_DRILL"},
    thermite = {anim = "thermite", scenario = "WORLD_HUMAN_WELDING"},
    infiltrate = {scenario = "WORLD_HUMAN_GUARD_STAND"},
    safe_crack = {anim = "vault", scenario = "PROP_HUMAN_ATM"},
    data = {anim = "hack", scenario = "WORLD_HUMAN_STAND_FIRE"}
}

local function playStageAnimation(stageType)
    local preset = stagePresets[stageType] or {}
    local anims = getAnimations()
    if anims and preset.anim then
        anims.PlayPreset(preset.anim)
    elseif preset.scenario then
        TaskStartScenarioInPlace(PlayerPedId(), preset.scenario, 0, true)
    else
        TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_STAND_IMPATIENT", 0, true)
    end
    return preset
end

function Client:Begin(heistId, heistConfig)
    self.activeHeist = {
        id = heistId,
        config = heistConfig
    }
    self.stage = 1
    self:StartStage()
end

function Client:StartStage()
    if not self.activeHeist then return end
    local stageConfig = self.activeHeist.config.stages[self.stage]
    if not stageConfig then return end
    self.isBusy = true
    playStageAnimation(stageConfig.type)
    local ui = getUI()
    local heistId = self.activeHeist.id
    local stageIndex = self.stage
    if ui then
        ui.Progress(stageConfig.label, stageConfig.duration, nil, function()
            Client.isBusy = false
            TriggerServerEvent("heist:stageComplete", heistId, stageIndex, true, {stage = stageConfig.type})
        end)
    else
        Citizen.CreateThread(function()
            Citizen.Wait(stageConfig.duration * 1000)
            TriggerServerEvent("heist:stageComplete", heistId, stageIndex, true, {stage = stageConfig.type})
            Client.isBusy = false
        end)
    end
end

function Client:Reset()
    self.activeHeist = nil
    self.stage = 0
    self.isBusy = false
    local anims = getAnimations()
    if anims then
        anims.Stop()
    else
        ClearPedTasks(PlayerPedId())
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())
        local heistPool = getHeists()
        for heistId, heist in pairs(heistPool) do
            if not Client.activeHeist and (Client.cooldowns[heistId] or 0) <= 0 then
                local distance = #(playerCoords - heist.location)
                if distance <= heist.radius then
                    local ui = getUI()
                    if ui then
                        ui.Draw3DText(heist.location, ("~g~Press E to start %s"):format(heist.label))
                    end
                    if IsControlJustReleased(0, 38) then
                        TriggerServerEvent("heist:requestStart", heistId)
                        Citizen.Wait(1000)
                    end
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    TriggerServerEvent("heist:requestConfig")
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        for heistId, seconds in pairs(Client.cooldowns) do
            if seconds > 0 then
                Client.cooldowns[heistId] = math.max(0, seconds - 1)
            end
        end
    end
end)

RegisterNetEvent("heist:notify", function(message)
    local ui = getUI()
    if ui then
        ui.Notify(message)
    else
        SetNotificationTextEntry("STRING")
        AddTextComponentSubstringPlayerName("~y~[Heist]~s~ " .. message)
        DrawNotification(false, true)
    end
end)

RegisterNetEvent("heist:syncConfig", function(payload)
    setHeists(payload)
end)

RegisterNetEvent("heist:begin", function(heistId, heistConfig)
    Client:Begin(heistId, heistConfig)
    local ui = getUI()
    if ui then
        ui.Notify(("Heist started: %s"):format(heistConfig.label))
    end
end)

RegisterNetEvent("heist:stage", function(_, stageIndex, stageConfig)
    Client.stage = stageIndex
    Client.activeHeist.config.stages[stageIndex] = stageConfig
    Client:StartStage()
end)

RegisterNetEvent("heist:complete", function(_, loot)
    local ui = getUI()
    local bonusText = "None"
    if loot.bonus and #loot.bonus > 0 then
        bonusText = table.concat(loot.bonus, ", ")
    end
    if ui then
        ui.Notify(("Heist complete! Looted $%s cash + %s marked bills"):format(loot.cash, loot.markedBills))
    end
    TriggerEvent("chat:addMessage", {
        color = {0, 255, 0},
        args = {"Heist", ("Rewards: %s cash, %s marked bills, bonus: %s"):format(loot.cash, loot.markedBills, bonusText)}
    })
    Client:Reset()
end)

RegisterNetEvent("heist:receiveLoot", function(loot)
    TriggerEvent("chat:addMessage", {
        color = {255, 200, 0},
        args = {"Heist", ("Standalone payout ready: $%s cash, redeem via your economy handler."):format(loot.cash)}
    })
end)

RegisterNetEvent("heist:fail", function(_, reason)
    local ui = getUI()
    if ui then
        ui.Notify(("Heist failed: %s"):format(reason or "Unknown"))
    end
    Client:Reset()
end)

RegisterNetEvent("heist:cooldownUpdate", function(heistId, seconds)
    Client.cooldowns[heistId] = seconds
end)

RegisterNetEvent("heist:policeAlert", function(data)
    if not IsPlayerAceAllowed(PlayerId(), "heist.police") then return end
    local coords = data.coords or vector3(0.0, 0.0, 0.0)
    local message = ("Dispatch: %s (%s) Stage: %s"):format(data.label or "Unknown", data.alarm or "General", data.stage or "-")
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, true)
    SetNewWaypoint(coords.x, coords.y)
end)
