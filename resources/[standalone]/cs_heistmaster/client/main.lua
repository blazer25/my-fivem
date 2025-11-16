local Config = Config
local Heists = Config.Heists

local currentHeistId = nil
local currentStepIndex = 0
local guards = {}  -- [heistId] = { ped, ... }
local SpawnedClerks = {}  -- [heistId] = ped

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

    -- Cleanup clerk if exists
    if SpawnedClerks[heistId] then
        local clerkPed = SpawnedClerks[heistId]
        if DoesEntityExist(clerkPed) then
            DeletePed(clerkPed)
        end
        SpawnedClerks[heistId] = nil
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

                        -- Mini game removed - auto success
                        local hackDuration = step.time or 5000
                        lib.progressCircle({
                            duration = hackDuration,
                            label = step.label or 'Hacking...',
                            position = 'bottom',
                            useWhileDead = false,
                            canCancel = false,
                            disable = { move = true, car = true, combat = true },
                        })
                        success = true
                        ClearPedTasks(ped)

                    elseif step.action == 'drill' then
                        -- DO THEY HAVE THE KEY?
                        local keyName = "safe_key_"..heistId
                        local hasKey = false
                        
                        if exports['ox_inventory'] then
                            -- Client-side Search: Search(search, item) - no source needed
                            local searchResult = exports['ox_inventory']:Search('count', keyName)
                            
                            if Config.Debug then
                                debugPrint(('Key search result type: %s, value: %s'):format(
                                    type(searchResult), tostring(searchResult)
                                ))
                            end
                            
                            -- Search can return number or table, handle both
                            if type(searchResult) == 'number' then
                                hasKey = searchResult > 0
                            elseif type(searchResult) == 'table' then
                                -- Could be { [itemName] = count } or just the count directly
                                if searchResult[keyName] then
                                    hasKey = searchResult[keyName] > 0
                                elseif searchResult[1] then
                                    hasKey = searchResult[1] > 0
                                end
                            end
                        end

                        if Config.Debug then
                            debugPrint(('Drill step: checking for key %s, hasKey=%s'):format(keyName, tostring(hasKey)))
                        end

                        if hasKey then
                            -- USE KEY INSTEAD OF DRILL/LOCKPICK/THERMITE
                            lib.progressCircle({
                                duration = 3500,
                                label = "Unlocking safe with key...",
                                position = 'bottom',
                                disable = { move = true, car = true, combat = true },
                                canCancel = false
                            })

                            -- silent open (no cop alert)
                            TriggerServerEvent('cs_heistmaster:safeReward', heistId)
                            lib.notify({ 
                                title = 'Safe', 
                                description = 'You unlocked the safe silently!', 
                                type = 'success' 
                            })

                            -- remove key (server will handle removal)
                            TriggerServerEvent('cs_heistmaster:removeSafeKey', heistId)

                            success = true
                        else
                            -- Normal drilling (loud)
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
                            success = true
                        end

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

                        -- Mini game removed - auto success
                        local lootDuration = step.time or 3000
                        lib.progressCircle({
                            duration = lootDuration,
                            label = step.label or 'Looting...',
                            position = 'bottom',
                            useWhileDead = false,
                            canCancel = false,
                            disable = { move = true, car = true, combat = true },
                        })
                        success = true
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

------------------------------------------------------
-- CLERK AI HANDLER (STORE TYPES)
------------------------------------------------------

local function spawnClerkForHeist(heistId, clerkData)
    if SpawnedClerks[heistId] then
        return SpawnedClerks[heistId]  -- already spawned
    end

    local model = joaat(clerkData.npcModel)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local ped = CreatePed(4, model, clerkData.coords.x, clerkData.coords.y, clerkData.coords.z - 1.0, clerkData.coords.heading, false, false)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedFleeAttributes(ped, 0, 0)
    FreezeEntityPosition(ped, true)

    SpawnedClerks[heistId] = ped
    return ped
end

------------------------------------------------------
-- CLERK BEHAVIOUR LOOP
------------------------------------------------------

CreateThread(function()
    Wait(2000)

    while true do
        local ped = PlayerPedId()
        local pCoords = GetEntityCoords(ped)
        local hasGun = IsPedArmed(ped, 4)
        local aiming = IsPlayerFreeAiming(PlayerId())

        for id, heist in pairs(Heists) do
            if heist.heistType == 'store' and heist.clerk and heist.clerk.enabled then

                local clerkPed = SpawnedClerks[id]
                if not clerkPed then
                    clerkPed = spawnClerkForHeist(id, heist.clerk)
                end

                local clerkCoords = GetEntityCoords(clerkPed)
                local dist = #(pCoords - clerkCoords)

                -- too far to interact
                if dist > 10.0 then goto continue end

                -- aiming gun at clerk → SURRENDER
                if dist < 5.0 and hasGun and aiming then
                    if heist.clerk.surrenderAnim then
                        RequestAnimDict('missfbi5ig_22')
                        while not HasAnimDictLoaded('missfbi5ig_22') do Wait(0) end
                        TaskPlayAnim(clerkPed, 'missfbi5ig_22', 'hands_up_anxious_scared', 8.0, -8.0, -1, 1, 0, false, false, false)
                    end

                    -- SAFE KEY CHANCE
                    if not heist.clerk.keyGiven then
                        if math.random(1, 100) <= (heist.clerk.safeKeyChance or 0) then
                            heist.clerk.keyGiven = true

                            -- animation
                            RequestAnimDict("mp_common")
                            while not HasAnimDictLoaded("mp_common") do Wait(0) end
                            TaskPlayAnim(clerkPed, "mp_common", "givetake1_a", 8.0, -8.0, 2000, 1, 0, false, false, false)

                            -- give key to player
                            TriggerServerEvent("cs_heistmaster:giveSafeKey", id)

                            lib.notify({
                                title = "Clerk",
                                description = "The clerk gave you a safe key!",
                                type = "success"
                            })
                        end
                    end

                    -- PANIC CHANCE (silent alarm)
                    if math.random(1, 100) <= (heist.clerk.panicChance or 50) then
                        TriggerServerEvent('cs_heistmaster:clerkPanic', id)
                    end

                    -- show UI
                    lib.showTextUI("[E] Tell clerk to open the register")
                    if IsControlJustPressed(0, 38) then
                        lib.hideTextUI()
                        -- start heist normally
                        TriggerServerEvent('cs_heistmaster:requestStart', id)
                        Wait(1500)
                    end
                end

            end
            ::continue::
        end
        Wait(0)
    end
end)

