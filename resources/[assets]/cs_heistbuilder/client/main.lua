local Utils = CS_HEIST_SHARED_UTILS or {}
local StepTypes = CS_HEIST_STEP_TYPES or {}
local ClientUtils = CS_HEIST_CLIENT_UTILS or {}
local UI = CS_HEIST_CLIENT_UI or {}

local CachedHeists = {}
local ActiveHeist = nil

local function requestHeists()
    CachedHeists = lib.callback.await('cs_heistbuilder:server:getHeists', false) or {}
end

local function finishHeist(reason)
    if not ActiveHeist then return end
    ClientUtils.notify({ description = reason or 'Heist complete', type = 'success' })
    ActiveHeist = nil
end

local function advanceStep()
    if not ActiveHeist then return end
    ActiveHeist.stepIndex = ActiveHeist.stepIndex + 1
    local step = ActiveHeist.data.steps[ActiveHeist.stepIndex]
    if not step then
        finishHeist('All stages done. Escape!')
        return
    end
    UI.showStepToast(step)

    local handler = StepTypes[step.type]
    if not handler or not handler.startClient then
        ClientUtils.notify({ description = ('Missing handler for %s'):format(step.type), type = 'error' })
        TriggerServerEvent('cs_heistbuilder:server:stepResult', ActiveHeist.data.id, ActiveHeist.stepIndex, false, { reason = 'missing_handler' })
        return
    end

    local runtime = ClientUtils.runtimeWrapper(ActiveHeist.data.id, ActiveHeist.stepIndex)
    handler.startClient(ActiveHeist.data.id, step, runtime)
end

RegisterNetEvent('cs_heistbuilder:client:startHeist', function(heist)
    ActiveHeist = {
        data = heist,
        stepIndex = 0
    }
    ClientUtils.notify({ description = ('Heist "%s" started'):format(heist.label), type = 'success' })
    advanceStep()
end)

RegisterNetEvent('cs_heistbuilder:client:nextStep', function()
    advanceStep()
end)

RegisterNetEvent('cs_heistbuilder:client:abort', function(reason)
    finishHeist(reason or 'Heist aborted')
end)

RegisterNetEvent('cs_heistbuilder:client:syncHeists', function(heists)
    CachedHeists = heists
end)

RegisterNetEvent('cs_heistbuilder:client:reward', function(payload)
    ClientUtils.notify({ description = payload and payload.message or 'Rewards granted', type = 'success' })
end)

RegisterCommand('heistpanel', function()
    requestHeists()
    local options = {}
    for _, heist in ipairs(CachedHeists) do
        options[#options + 1] = {
            title = heist.label,
            description = ('Tier %s | PD %s | Cooldown %sm'):format(heist.tier, heist.requiredPolice, heist.cooldownMinutes),
            onSelect = function()
                TriggerServerEvent('cs_heistbuilder:server:requestHeist', heist.id)
            end
        }
    end
    if #options == 0 then
        ClientUtils.notify({ description = 'No heists registered yet', type = 'inform' })
        return
    end
    UI.showAdminContext(options)
end)

AddStateBagChangeHandler('isHeistBuilderAdmin', nil, function(bagName, key, value)
    if bagName == ('player:%s'):format(cache.serverId) then
        LocalPlayer.state['isHeistBuilderAdmin'] = value
    end
end)

requestHeists()
