local Config = Config
local Heists = Config.Heists

local currentHeistId = nil
local currentStepIndex = 0
local guards = {}  -- [heistId] = { ped, ... }

local function debugPrint(...)
    if Config.Debug then
        print('[cs_heistmaster:client]', ...)
    end
end

------------------------------------------------------
-- Helpers
------------------------------------------------------

local function vecFromTable(t, defaultW)
    if not t then return vec3(0.0, 0.0, 0.0) end
    if t.w or defaultW then
        return vec4(t.x + 0.0, t.y + 0.0, t.z + 0.0, (t.w or defaultW or 0.0) + 0.0)
    end
    return vec3(t.x + 0.0, t.y + 0.0, t.z + 0.0)
end

local function loadModel(model)
    local hash = (type(model) == 'string') and joaat(model) or model
    if not IsModelInCdimage(hash) then return nil end
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(0) end
    return hash
end

------------------------------------------------------
-- Guards
------------------------------------------------------

RegisterNetEvent('cs_heistmaster:client:spawnGuards', function(heistId, guardList)
    if not guardList or #guardList == 0 then return end
    guards[heistId] = guards[heistId] or {}

    for _, data in ipairs(guardList) do
        if data.coords then
            local c = vecFromTable(data.coords, data.coords.w or 0.0)
            local mHash = loadModel(data.model or 's_m_m_security_01')
            if mHash then
                local ped = CreatePed(4, mHash, c.x, c.y, c.z, c.w, true, true)

                SetEntityAsMissionEntity(ped, true, true)
                SetPedArmour(ped, data.armor or 50)
                SetPedAccuracy(ped, data.accuracy or 30)
                SetPedFleeAttributes(ped, 0, false)
                SetPedCombatAttributes(ped, 46, true)
                SetPedCombatRange(ped, 2)
                SetPedCombatMovement(ped, 2)

                GiveWeaponToPed(ped, joaat(data.weapon or 'weapon_pistol'), 250, false, true)

                table.insert(guards[heistId], ped)
            end
        end
    end
end)

RegisterNetEvent('cs_heistmaster:client:cleanupHeist', function(heistId)
    if guards[heistId] then
        for _, ped in ipairs(guards[heistId]) do
            if DoesEntityExist(ped) then DeletePed(ped) end
        end
        guards[heistId] = nil
    end

    if currentHeistId == heistId then
        currentHeistId = nil
        currentStepIndex = 0
        lib.hideTextUI()
    end
end)

------------------------------------------------------
-- Alert and alarm handler
------------------------------------------------------

local function handleStepAlert(heistId, heist, step)
    local alertType = step.alert or 'none'
    if alertType ~= 'none' then
        TriggerServerEvent('cs_heistmaster:alertPolice', heistId, alertType)
    end

    if step.alarmSound then
        -- simple world alarm: you can replace with your own sound system
        -- This just plays a local siren for now
        PlaySoundFrontend(-1, 'Bed', 'WastedSounds', true)
    end
end

------------------------------------------------------
-- Step runner
------------------------------------------------------

local function runHeistThread(heistId, heist)
    CreateThread(function()
        while currentHeistId == heistId do
            local step = heist.steps[currentStepIndex]
            if not step then break end

            local stepPos = vecFromTable(step.coords)
            local ped = PlayerPedId()
            local pCoords = GetEntityCoords(ped)
            local dist = #(pCoords - stepPos)

            -- draw marker when near
            if dist < 25.0 then
                DrawMarker(
                    1,
                    stepPos.x, stepPos.y, stepPos.z - 1.0,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    1.0, 1.0, 1.0,
                    255, 165, 0, 150,
                    false, true, 2, false, nil, nil, false
                )
            end

            if dist < (step.radius or 1.5) then
                lib.showTextUI(('[E] %s'):format(step.label or 'Do step'))

                if IsControlJustPressed(0, 38) then
                    lib.hideTextUI()
                    local success = true

                    --------------------------------------------------
                    -- ACTION BEHAVIOUR
                    --------------------------------------------------
                    -- NEW: trigger alert/alarm once we start the step
                    handleStepAlert(heistId, heist, step)

                    if step.action == 'hack' then
                        RequestAnimDict('anim@heists@prison_heiststation@cop_reactions')
                        while not HasAnimDictLoaded('anim@heists@prison_heiststation@cop_reactions') do Wait(0) end

                        TaskPlayAnim(ped, 'anim@heists@prison_heiststation@cop_reactions', 'console_peek_a', 8.0, -8.0, -1, 1, 0.0, false, false, false)

                        success = lib.skillCheck(step.difficulty or { 'medium', 'medium', 'hard' })
                        ClearPedTasks(ped)

                    elseif step.action == 'drill' then
                        local duration = (step.time or 20000)
                        RequestAnimDict('anim@heists@fleeca_bank@drilling')
                        while not HasAnimDictLoaded('anim@heists@fleeca_bank@drilling') do Wait(0) end

                        TaskPlayAnim(ped, 'anim@heists@fleeca_bank@drilling', 'drill_straight_idle', 8.0, -8.0, duration, 1, 0.0, false, false, false)

                        lib.progressCircle({
                            duration = duration,
                            label = step.label or 'Drilling...',
                            position = 'bottom',
                            useWhileDead = false,
                            canCancel = false,
                            disable = { move = true, car = true, combat = true },
                        })

                        ClearPedTasks(ped)

                    elseif step.action == 'smash' then
                        RequestAnimDict('melee@unarmed@streamed_core_fps')
                        while not HasAnimDictLoaded('melee@unarmed@streamed_core_fps') do Wait(0) end

                        TaskPlayAnim(ped, 'melee@unarmed@streamed_core_fps', 'ground_attack_0', 8.0, -8.0, step.time or 4000, 0, 0.0, false, false, false)

                        lib.progressCircle({
                            duration = step.time or 4000,
                            label = step.label or 'Smashing...',
                            position = 'bottom',
                            useWhileDead = false,
                            canCancel = false,
                            disable = { move = true, car = true, combat = true },
                        })

                        ClearPedTasks(ped)

                    elseif step.action == 'loot' then
                        RequestAnimDict('anim@heists@ornate_bank@grab_cash')
                        while not HasAnimDictLoaded('anim@heists@ornate_bank@grab_cash') do Wait(0) end

                        TaskPlayAnim(ped, 'anim@heists@ornate_bank@grab_cash', 'grab', 8.0, -8.0, -1, 1, 0.0, false, false, false)

                        success = lib.skillCheck(step.difficulty or { 'easy', 'medium' })
                        ClearPedTasks(ped)

                    elseif step.action == 'escape' then
                        -- must get away from the start point
                        local centerPos = vecFromTable(heist.start)
                        local escapeRadius = step.radius or 120.0
                        local distFromStart = #(pCoords - centerPos)
                        if distFromStart < escapeRadius then
                            success = false
                            lib.notify({
                                description = 'You need to get further away from the area!',
                                type = 'error'
                            })
                        end
                    end

                    --------------------------------------------------
                    -- HANDLE SUCCESS / FAIL
                    --------------------------------------------------
                    if success then
                        currentStepIndex = currentStepIndex + 1
                        local nextStep = heist.steps[currentStepIndex]

                        if not nextStep then
                            -- finished heist
                            TriggerServerEvent('cs_heistmaster:finishHeist', heistId)
                            currentHeistId = nil
                            break
                        else
                            lib.notify({
                                description = 'Objective complete. Move to the next location.',
                                type = 'success'
                            })
                        end
                    else
                        lib.notify({
                            description = 'You failed the objective!',
                            type = 'error'
                        })
                        TriggerServerEvent('cs_heistmaster:abortHeist', heistId)
                        currentHeistId = nil
                        break
                    end
                end
            else
                lib.hideTextUI()
            end

            Wait(0)
        end
    end)
end

------------------------------------------------------
-- Start heist from server
------------------------------------------------------

RegisterNetEvent('cs_heistmaster:client:startHeist', function(heistId, heistData)
    currentHeistId = heistId
    currentStepIndex = 1
    Heists[heistId] = heistData

    debugPrint('Heist started:', heistId)

    lib.notify({
        title = heistData.label,
        description = 'Heist started. Follow the objectives.',
        type = 'inform'
    })

    runHeistThread(heistId, heistData)
end)

-- Used by /heist_start test command to show available ID error properly
RegisterNetEvent('cs_heistmaster:client:forceStart', function(heistId)
    TriggerServerEvent('cs_heistmaster:requestStart', heistId)
end)

------------------------------------------------------
-- NATURAL START SYSTEM (NO THIRD-EYE)
------------------------------------------------------

CreateThread(function()
    Wait(2000)

    while true do
        local ped = PlayerPedId()
        local pCoords = GetEntityCoords(ped)
        local isArmedGun = IsPedArmed(ped, 4)  -- firearms
        local isArmedMelee = IsPedArmed(ped, 1) -- melee
        local isAiming = IsPlayerFreeAiming(PlayerId())

        local anyPrompt = false

        -- Don't show start prompts while a heist is already running
        if not currentHeistId then
            for id, heist in pairs(Heists) do
                local steps = heist.steps
                if steps and steps[1] and steps[1].coords then
                    local entryPos = vecFromTable(steps[1].coords)
                    local dist = #(pCoords - entryPos)

                    local hType = heist.heistType or 'generic'

                    -- STORE ROBBERIES
                    -- Stand near the first step (register area), armed, to start
                    if hType == 'store' then
                        if dist < 2.0 and (isArmedGun or isArmedMelee) then
                            anyPrompt = true
                            if isAiming and isArmedGun then
                                -- aiming gun at clerk/register
                                lib.showTextUI(('[E] Threaten the clerk at %s'):format(heist.label))
                            else
                                -- up close with weapon (crowbar/melee)
                                lib.showTextUI(('[E] Smash the register at %s'):format(heist.label))
                            end

                            if IsControlJustPressed(0, 38) then -- E
                                lib.hideTextUI()
                                TriggerServerEvent('cs_heistmaster:requestStart', id)
                                Wait(1200)
                            end
                        end

                    -- FLEECA-STYLE BANKS
                    -- Stand at the panel and "connect laptop"
                    elseif hType == 'fleeca' then
                        if dist < 1.5 then
                            anyPrompt = true
                            lib.showTextUI(('[E] Connect laptop to security panel (%s)'):format(heist.label))

                            if IsControlJustPressed(0, 38) then
                                lib.hideTextUI()
                                -- Server already checks requiredItem (heist_laptop), so just request start.
                                TriggerServerEvent('cs_heistmaster:requestStart', id)
                                Wait(1200)
                            end
                        end

                    -- JEWELLERY HEIST
                    -- Stand near first glass case, armed, to "smash glass"
                    elseif hType == 'jewellery' then
                        if dist < 2.0 and (isArmedGun or isArmedMelee) then
                            anyPrompt = true
                            lib.showTextUI(('[E] Smash the glass and start the heist (%s)'):format(heist.label))

                            if IsControlJustPressed(0, 38) then
                                lib.hideTextUI()
                                TriggerServerEvent('cs_heistmaster:requestStart', id)
                                Wait(1200)
                            end
                        end

                    -- fallback generic: E at start position
                    else
                        local startPos = heist.start and vecFromTable(heist.start) or entryPos
                        local distStart = #(pCoords - startPos)

                        if distStart < 2.0 then
                            anyPrompt = true
                            lib.showTextUI(('[E] Start %s'):format(heist.label))
                            if IsControlJustPressed(0, 38) then
                                lib.hideTextUI()
                                TriggerServerEvent('cs_heistmaster:requestStart', id)
                                Wait(1200)
                            end
                        end
                    end
                end
            end
        end

        if not anyPrompt then
            lib.hideTextUI()
        end

        Wait(0)
    end
end)

