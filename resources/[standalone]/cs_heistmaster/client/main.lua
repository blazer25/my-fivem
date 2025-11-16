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
                    if step.action == 'hack' then
                        success = lib.skillCheck(step.difficulty or { 'medium', 'medium', 'hard' })

                    elseif step.action == 'drill' then
                        local duration = (step.time or 20000)
                        lib.progressCircle({
                            duration = duration,
                            label = step.label or 'Drilling...',
                            position = 'bottom',
                            useWhileDead = false,
                            canCancel = false,
                            disable = { move = true, car = true, combat = true },
                        })

                    elseif step.action == 'smash' then
                        -- simple smash animation + progress
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
                        success = lib.skillCheck(step.difficulty or { 'easy', 'medium' })

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
-- Interaction zones (ox_target / qb-target / E prompt)
------------------------------------------------------

CreateThread(function()
    Wait(2000)

    for id, heist in pairs(Heists) do
        local startPos = vecFromTable(heist.start)

        if exports['ox_target'] then
            exports['ox_target']:addBoxZone({
                coords = startPos,
                size = vec3(1.5, 1.5, 1.5),
                rotation = 0.0,
                debug = Config.Debug,
                options = {
                    {
                        name = ('cs_heistmaster_%s'):format(id),
                        icon = 'fa-solid fa-sack-dollar',
                        label = ('Start %s'):format(heist.label),
                        onSelect = function()
                            TriggerServerEvent('cs_heistmaster:requestStart', id)
                        end,
                    }
                }
            })

        elseif exports['qb-target'] then
            exports['qb-target']:AddCircleZone(
                ('cs_heistmaster_%s'):format(id),
                startPos,
                1.5,
                {
                    name = ('cs_heistmaster_%s'):format(id),
                    debugPoly = Config.Debug,
                },
                {
                    options = {
                        {
                            icon = 'fa-solid fa-sack-dollar',
                            label = ('Start %s'):format(heist.label),
                            action = function()
                                TriggerServerEvent('cs_heistmaster:requestStart', id)
                            end,
                        }
                    },
                    distance = 2.0
                }
            )

        else
            -- fallback: E prompt + marker
            CreateThread(function()
                while true do
                    local ped = PlayerPedId()
                    local pCoords = GetEntityCoords(ped)
                    local dist = #(pCoords - startPos)

                    if dist < 20.0 then
                        DrawMarker(
                            1,
                            startPos.x, startPos.y, startPos.z - 1.0,
                            0.0, 0.0, 0.0,
                            0.0, 0.0, 0.0,
                            1.0, 1.0, 1.0,
                            0, 200, 50, 150,
                            false, true, 2, false, nil, nil, false
                        )
                    end

                    if dist < 2.0 then
                        lib.showTextUI(('[E] Start %s'):format(heist.label))
                        if IsControlJustPressed(0, 38) then
                            lib.hideTextUI()
                            TriggerServerEvent('cs_heistmaster:requestStart', id)
                            Wait(1000)
                        end
                    else
                        lib.hideTextUI()
                    end

                    Wait(0)
                end
            end)
        end
    end
end)

