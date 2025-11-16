local Utils = CS_HEIST_SHARED_UTILS or {}
local StepTypes = CS_HEIST_STEP_TYPES or {}
local ClientUtils = CS_HEIST_CLIENT_UTILS or {}
local UI = CS_HEIST_CLIENT_UI or {}

local CachedHeists = {}
local ActiveHeist = nil
local stepMarkerThread = nil

local function requestHeists()
    CachedHeists = lib.callback.await('cs_heistbuilder:server:getHeists', false) or {}
end

local function stopStepMarker()
    if stepMarkerThread then
        if ActiveHeist then
            ActiveHeist.currentStep = nil
        end
        stepMarkerThread = nil
    end
end

local function startStepMarker(step)
    if stepMarkerThread then return end
    if not step.coords then return end
    
    stepMarkerThread = CreateThread(function()
        local stepCoords = Utils.toVector(step.coords)
        local radius = step.radius or 2.0
        
        while ActiveHeist and ActiveHeist.currentStep == step do
            local playerCoords = GetEntityCoords(cache.ped)
            ClientUtils.marker(1, stepCoords, { r = 255, g = 255, b = 0, a = 120 }, radius)
            Wait(0)
        end
        stepMarkerThread = nil
    end)
end

local function finishHeist(reason)
    if not ActiveHeist then return end
    stopStepMarker()
    ClientUtils.notify({ description = reason or 'Heist complete', type = 'success' })
    ActiveHeist = nil
end

local function waitForLocation(step, onReached)
    if not step.coords then
        onReached()
        return
    end
    
    local stepCoords = Utils.toVector(step.coords)
    local radius = step.radius or 2.0
    
    CreateThread(function()
        while ActiveHeist and ActiveHeist.currentStep == step do
            local playerCoords = GetEntityCoords(cache.ped)
            local distance = #(playerCoords - stepCoords)
            
            if distance <= radius then
                onReached()
                break
            end
            
            ClientUtils.showHelp(('Go to marked location (%.1fm)'):format(distance))
            Wait(0)
        end
    end)
end

local function advanceStep()
    if not ActiveHeist then return end
    stopStepMarker()
    
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

    ActiveHeist.currentStep = step
    startStepMarker(step)
    
    waitForLocation(step, function()
        if not ActiveHeist or ActiveHeist.currentStep ~= step then return end
        local runtime = ClientUtils.runtimeWrapper(ActiveHeist.data.id, ActiveHeist.stepIndex, function()
            stopStepMarker()
        end)
        handler.startClient(ActiveHeist.data.id, step, runtime)
    end)
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
