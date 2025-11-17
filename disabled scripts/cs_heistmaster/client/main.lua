local Config = Config
local Heists = Config.Heists

-- ============================================================
-- STATE TRACKING
-- ============================================================

local currentHeistId = nil
local currentStepIndex = 0
local HeistClientState = {} -- [heistId] = "idle" | "active" | "cooldown"
local ActiveStep = {} -- [heistId] = stepNumber
local alreadyLooted = {} -- [heistId] = { [lootKey] = true }
local ClerkRuntimeState = {} -- [heistId] = { panicked = false, gaveKey = false, aggroTimer = 0 }

-- Entity tracking
local guards = {} -- [heistId] = { ped1, ped2, ... }
local SpawnedClerks = {} -- [heistId] = ped
local StepObjects = {} -- [heistId] = { [stepIndex] = object }

HeistState = HeistState or {} -- [heistId] = { ... }

-- Vault door tracking
VaultDoors = VaultDoors or {} -- [heistId] = door entity

-- ============================================================
-- HELPERS
-- ============================================================

local function debugPrint(...)
    if Config.Debug then
        print('[cs_heistmaster:client]', ...)
    end
end

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

-- ============================================================
-- TARGETING SYSTEM DETECTION & HELPERS
-- ============================================================

local useOxTarget = false
local useQbTarget = false

-- Detect which targeting system is available
CreateThread(function()
    -- Wait for resources to load and retry detection
    for i = 1, 10 do
        Wait(500)
        if GetResourceState('ox_target') == 'started' then
            useOxTarget = true
            debugPrint('Using ox_target for heist interactions')
            break
        elseif GetResourceState('qb-target') == 'started' then
            useQbTarget = true
            debugPrint('Using qb-target for heist interactions')
            break
        end
    end
    
    if not useOxTarget and not useQbTarget then
        debugPrint('WARNING: No targeting system found! Heist steps will not be interactable.')
        print('^1[cs_heistmaster] ERROR: No targeting system (ox_target or qb-target) found!^7')
    end
end)

-- Helper to remove target from object
local function removeTargetFromObject(object)
    if not DoesEntityExist(object) then return end
    
    if useOxTarget then
        exports.ox_target:removeLocalEntity(object)
    elseif useQbTarget then
        exports['qb-target']:RemoveTargetEntity(object)
    end
end

-- ============================================================
-- BANK GUARD SYSTEM (Start heist when guards are shot)
-- ============================================================

local BankGuards = {} -- [heistId] = { [guardIndex] = ped } - Track by index to prevent duplicates
local GuardSpawning = {} -- [heistId] = true (prevents concurrent spawns)
local GuardSpawnCooldown = {} -- [heistId] = timestamp (prevents frequent respawns)

function SpawnBankGuards(heistId)
    local heist = Config.Heists[heistId]
    if not heist or not heist.guards or #heist.guards == 0 then 
        debugPrint(('SpawnBankGuards: No guards config for heist %s'):format(heistId))
        return 
    end

    -- CRITICAL FIX: Prevent concurrent spawns for the same heist with stronger lock
    if GuardSpawning[heistId] then
        debugPrint(('SpawnBankGuards: Spawn already in progress for heist %s, skipping'):format(heistId))
        return
    end
    
    -- SPAWN COOLDOWN: Check if we're in cooldown (30 seconds minimum)
    local currentTime = GetGameTimer()
    if GuardSpawnCooldown[heistId] and (currentTime - GuardSpawnCooldown[heistId]) < 30000 then
        local remainingTime = math.ceil((30000 - (currentTime - GuardSpawnCooldown[heistId])) / 1000)
        debugPrint(('SpawnBankGuards: Cooldown active for heist %s (%d seconds remaining)'):format(heistId, remainingTime))
        return
    end

    -- Initialize guard table if needed
    if not BankGuards[heistId] then
        BankGuards[heistId] = {}
    end

    -- CRITICAL FIX: Check if ANY guard exists for this heist first (prevent mass spawning)
    local anyGuardExists = false
    for guardIndex, ped in pairs(BankGuards[heistId]) do
        if ped and DoesEntityExist(ped) then
            anyGuardExists = true
            break
        end
    end
    
    -- If any guard exists, verify all locations are filled before spawning more
    if anyGuardExists then
        local allGuardsValid = true
        for guardIndex = 1, #heist.guards do
            local existingGuard = BankGuards[heistId][guardIndex]
            if not existingGuard or not DoesEntityExist(existingGuard) then
                allGuardsValid = false
                break
            end
        end
        
        if allGuardsValid then
            debugPrint(('All bank guards already exist for heist %s, skipping spawn'):format(heistId))
            return
        end
    end

    -- Check each guard spawn location individually - only spawn if guard doesn't exist at that location
    local guardsToSpawn = {}
    for guardIndex, g in ipairs(heist.guards) do
        local existingGuard = BankGuards[heistId][guardIndex]
        
        -- Only spawn if guard doesn't exist or is invalid at this location
        if not existingGuard or not DoesEntityExist(existingGuard) then
            -- Cleanup invalid reference
            if existingGuard and not DoesEntityExist(existingGuard) then
                BankGuards[heistId][guardIndex] = nil
            end
            
            table.insert(guardsToSpawn, { index = guardIndex, data = g })
        else
            debugPrint(('Bank guard at location %d already exists for heist %s, skipping'):format(guardIndex, heistId))
        end
    end

    -- If all guards already exist, skip spawning
    if #guardsToSpawn == 0 then
        debugPrint(('All bank guards already exist for heist %s, skipping spawn'):format(heistId))
        return
    end

    -- Mark as spawning to prevent concurrent attempts
    GuardSpawning[heistId] = true
    debugPrint(('SpawnBankGuards: Starting spawn for heist %s (%d guards to spawn)'):format(heistId, #guardsToSpawn))

    -- Spawn only the guards that don't exist
    for _, guardInfo in ipairs(guardsToSpawn) do
        local guardIndex = guardInfo.index
        local g = guardInfo.data
        
        local model = joaat(g.model or 's_m_m_security_01')
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(10) end

        local baseCoords = vecFromTable(g.coords, g.coords.w or 0.0)
        
        -- FIX: Randomize spawn position slightly to prevent clipping (0.3m radius)
        local randomOffset = math.random() * 0.3
        local randomAngle = math.random() * 360.0
        local spawnX = baseCoords.x + (math.cos(math.rad(randomAngle)) * randomOffset)
        local spawnY = baseCoords.y + (math.sin(math.rad(randomAngle)) * randomOffset)
        local spawnZ = baseCoords.z
        local spawnHeading = baseCoords.w or 0.0
        
        -- Spawn guard slightly away and make them walk to position (more natural)
        local ped = CreatePed(4, model, spawnX, spawnY, spawnZ, spawnHeading, true, true)
        
        SetEntityAsMissionEntity(ped, true, true)
        SetPedArmour(ped, g.armor or 50)
        SetPedAccuracy(ped, g.accuracy or 50)
        GiveWeaponToPed(ped, joaat(g.weapon or 'weapon_pistol'), 250, false, true)

        SetPedRelationshipGroupHash(ped, joaat('BANK_GUARD'))
        SetRelationshipBetweenGroups(1, joaat('BANK_GUARD'), joaat('PLAYER')) -- Neutral initially
        SetRelationshipBetweenGroups(1, joaat('PLAYER'), joaat('BANK_GUARD'))
        SetPedCanRagdoll(ped, true)
        SetPedFleeAttributes(ped, 0, false)
        SetPedCombatRange(ped, 0)
        SetPedAlertness(ped, 0) -- Start passive
        SetPedCombatAttributes(ped, 46, true)
        SetBlockingOfNonTemporaryEvents(ped, false) -- Allow them to react

        -- OPTIONAL: Make guard walk to exact position if spawned away
        if randomOffset > 0.1 then
            TaskGoStraightToCoord(ped, baseCoords.x, baseCoords.y, baseCoords.z, 1.0, 5000, spawnHeading, 0.1)
        else
            -- If close enough, just set heading
            SetEntityHeading(ped, spawnHeading)
        end

        -- Store guard by index to prevent duplicates at same location
        BankGuards[heistId][guardIndex] = ped
        debugPrint(('SpawnBankGuards: Guard spawned at location %d for heist %s (entity: %s)'):format(guardIndex, heistId, tostring(ped)))
    end
    
    -- Set spawn cooldown timestamp
    GuardSpawnCooldown[heistId] = GetGameTimer()
    debugPrint(('SpawnBankGuards: Spawn complete for heist %s, cooldown set'):format(heistId))
    
    -- Clear spawning lock
    GuardSpawning[heistId] = nil
end

function IsBankGuard(entity)
    for heistId, guardTable in pairs(BankGuards) do
        for guardIndex, ped in pairs(guardTable) do
            if entity == ped then
                return heistId
            end
        end
    end
    return false
end

-- Track which heists have been auto-started to prevent double-triggering
local BankHeistStarted = {} -- [heistId] = true
local StoreHeistStarted = {} -- [heistId] = true

-- Improved bank guard damage detection with dual event system
local function handleGuardDamage(victim, attacker)
    if not DoesEntityExist(victim) or not DoesEntityExist(attacker) then return end
    if attacker ~= PlayerPedId() then return end

    local heistId = IsBankGuard(victim)
    if not heistId then return end

    -- Prevent double-triggering
    if BankHeistStarted[heistId] then return end

    local state = HeistClientState[heistId] or "idle"
    if state ~= "idle" then return end -- Already started

    -- Mark as started to prevent duplicate triggers
    BankHeistStarted[heistId] = true

    -- START HEIST (server will handle anti-spam for multiple players)
    debugPrint(('Bank heist auto-started by damaging guard: %s'):format(heistId))
    TriggerServerEvent("cs_heistmaster:requestStart", heistId)

    -- Make guards aggressive after start (with delay to ensure heist initialized)
    CreateThread(function()
        Wait(1000) -- Wait for heist to initialize
        if BankGuards[heistId] then
            for guardIndex, ped in pairs(BankGuards[heistId]) do
                if DoesEntityExist(ped) then
                    SetPedAlertness(ped, 3)
                    SetPedCombatAttributes(ped, 46, true)
                    SetPedCombatRange(ped, 2)
                    SetPedCombatMovement(ped, 2)
                    SetRelationshipBetweenGroups(5, joaat('BANK_GUARD'), joaat('PLAYER'))
                    SetRelationshipBetweenGroups(5, joaat('PLAYER'), joaat('BANK_GUARD'))
                    TaskCombatPed(ped, PlayerPedId(), 0, 16)
                end
            end
        end
    end)
end

-- Primary: gameEventTriggered
AddEventHandler('gameEventTriggered', function(event, args)
    if event ~= "CEventNetworkEntityDamage" then return end
    local victim = args[1]
    local attacker = args[2]
    handleGuardDamage(victim, attacker)
end)

-- Fallback: EntityDamaged event
AddEventHandler('entityDamaged', function(victim, attacker, damage)
    handleGuardDamage(victim, attacker)
end)

-- ============================================================
-- STORE CLERK SYSTEM (Start heist when aiming gun at clerk)
-- ============================================================

local StoreClerks = {}
local ClerkSpawning = {} -- [heistId] = true (prevents concurrent spawns)
local ClerkSpawnCooldown = {} -- [heistId] = timestamp (prevents frequent respawns)

function SpawnClerk(heistId)
    local heist = Config.Heists[heistId]
    if not heist or not heist.clerk or not heist.clerk.enabled then 
        debugPrint(('SpawnClerk: No clerk config for heist %s'):format(heistId))
        return 
    end

    -- Prevent concurrent spawns for the same heist
    if ClerkSpawning[heistId] then
        debugPrint(('SpawnClerk: Spawn already in progress for heist %s, skipping'):format(heistId))
        return
    end
    
    -- SPAWN COOLDOWN: Check if we're in cooldown (30 seconds minimum)
    local currentTime = GetGameTimer()
    if ClerkSpawnCooldown[heistId] and (currentTime - ClerkSpawnCooldown[heistId]) < 30000 then
        local remainingTime = math.ceil((30000 - (currentTime - ClerkSpawnCooldown[heistId])) / 1000)
        debugPrint(('SpawnClerk: Cooldown active for heist %s (%d seconds remaining)'):format(heistId, remainingTime))
        return
    end

    -- Check if clerk already exists and is valid - don't respawn if it does
    local existingClerk = StoreClerks[heistId]
    if existingClerk and DoesEntityExist(existingClerk) and not IsEntityDead(existingClerk) then
        debugPrint(('SpawnClerk: Clerk already exists and is alive for heist %s (entity: %s), skipping spawn'):format(heistId, tostring(existingClerk)))
        return -- Clerk already exists and is alive, don't respawn
    end

    -- Mark as spawning to prevent concurrent attempts
    ClerkSpawning[heistId] = true
    debugPrint(('SpawnClerk: Starting spawn for heist %s'):format(heistId))

    -- Cleanup invalid clerk reference if it exists
    if existingClerk then
        if DoesEntityExist(existingClerk) then
            debugPrint(('SpawnClerk: Deleting existing invalid clerk for heist %s'):format(heistId))
            DeletePed(existingClerk)
        end
        StoreClerks[heistId] = nil
        SpawnedClerks[heistId] = nil
    end

    local modelName = heist.clerk.npcModel or 'mp_m_shopkeep_01'
    local model = joaat(modelName)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end

    local coords = vecFromTable(heist.clerk.coords, heist.clerk.coords.heading or 0.0)
    local ped = CreatePed(4, model, coords.x, coords.y, coords.z, coords.w or 0.0, true, true)

    SetEntityAsMissionEntity(ped, true, true)
    SetPedCanRagdoll(ped, true)
    SetPedFleeAttributes(ped, 0, false)
    SetPedDropsWeaponsWhenDead(ped, false)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, false) -- Allow movement if needed
    
    -- Start scenario at register
    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_STAND_IMPATIENT", 0, true)

    StoreClerks[heistId] = ped
    SpawnedClerks[heistId] = ped -- Keep compatibility with existing code
    
    -- Set spawn cooldown timestamp
    ClerkSpawnCooldown[heistId] = GetGameTimer()
    debugPrint(('SpawnClerk: Clerk spawned successfully for heist %s (entity: %s), cooldown set'):format(heistId, tostring(ped)))
    
    -- Clear spawning lock
    ClerkSpawning[heistId] = nil
end

-- Track intimidation progress to prevent interruption
local ClerkIntimidationActive = {} -- [heistId] = true

-- Detect aiming a gun at clerk (improved distance-based detection)
CreateThread(function()
    while true do
        Wait(150)

        local player = PlayerPedId()
        if not DoesEntityExist(player) then goto continue_store_loop end

        -- Check if player has weapon and is aiming
        if not IsPedArmed(player, 4) then goto continue_store_loop end
        if not IsPlayerFreeAiming(PlayerId()) then goto continue_store_loop end

        local playerCoords = GetEntityCoords(player)

        for heistId, clerkPed in pairs(StoreClerks) do
            if not DoesEntityExist(clerkPed) then goto continue_clerk_check end

            -- Prevent double-triggering
            if StoreHeistStarted[heistId] or ClerkIntimidationActive[heistId] then goto continue_clerk_check end

            local state = HeistClientState[heistId] or "idle"
            if state ~= "idle" then goto continue_clerk_check end -- Already started

            -- Check distance (12 meters as specified)
            local clerkCoords = GetEntityCoords(clerkPed)
            local dist = #(playerCoords - clerkCoords)
            if dist > 12.0 then goto continue_clerk_check end

            -- Check if player is aiming at clerk
            local aiming, target = GetEntityPlayerIsFreeAimingAt(PlayerId())
            if not aiming or not IsEntityAPed(target) or target ~= clerkPed then goto continue_clerk_check end

            -- Mark intimidation as active to prevent duplicate triggers
            ClerkIntimidationActive[heistId] = true

            -- PATCH A+++: 4-second intimidation delay with progress circle
            local intimidationDuration = 4000
            
            -- Clear tasks BEFORE detection to prevent scenario interruption
            ClearPedTasksImmediately(clerkPed)
            Wait(100) -- Small delay for task clearing
            
            -- Show progress circle for intimidation
            local progressResult = lib.progressCircle({
                duration = intimidationDuration,
                label = "Intimidating clerk...",
                position = 'bottom',
                disable = { move = true, car = true, combat = true },
                canCancel = true
            })
            
            -- If player cancels, reset intimidation state
            if not progressResult then
                ClerkIntimidationActive[heistId] = nil
                goto continue_clerk_check
            end
            
            -- Mark as started to prevent duplicate triggers
            StoreHeistStarted[heistId] = true

            -- Clerk surrenders with proper animation (missminuteman_1ig_2, handsup_base)
            RequestAnimDict('missminuteman_1ig_2')
            while not HasAnimDictLoaded('missminuteman_1ig_2') do Wait(10) end
            
            -- Play surrender animation
            TaskPlayAnim(clerkPed, 'missminuteman_1ig_2', 'handsup_base', 8.0, -8.0, -1, 49, 0.0, false, false, false)
            
            -- Start heist
            debugPrint(('Store heist auto-started by aiming at clerk: %s'):format(heistId))
            TriggerServerEvent("cs_heistmaster:requestStart", heistId)

            -- Optional: key chance
            local heist = Config.Heists[heistId]
            if heist and heist.clerk and (heist.clerk.safeKeyChance or 0) > 0 then
                if math.random(1, 100) <= heist.clerk.safeKeyChance then
                    TriggerServerEvent("cs_heistmaster:giveSafeKey", heistId)
                    lib.notify({
                        title = "Clerk",
                        description = "The clerk gave you a safe key!",
                        type = "success"
                    })
                end
            end

            -- PATCH A+++: Delayed clerk panic alarm (5-second delay)
            if not ClerkRuntimeState[heistId] then
                ClerkRuntimeState[heistId] = { panicked = false }
            end
            
            local rt = ClerkRuntimeState[heistId]
            if not rt.panicked then
                local panicChance = (heist and heist.clerk and heist.clerk.panicChance) or 50
                if math.random(1, 100) <= panicChance then
                    rt.panicked = true
                    -- Delay panic alarm by 5 seconds to simulate delayed panic
                    CreateThread(function()
                        Wait(5000) -- 5-second delay
                        TriggerServerEvent("cs_heistmaster:clerkPanic", heistId)
                    end)
                end
            end

            -- Clear intimidation state
            ClerkIntimidationActive[heistId] = nil
            Wait(5000) -- Prevent spam
            ::continue_clerk_check::
        end
        ::continue_store_loop::
    end
end)

-- A.3: Allow Register Smash Start If Clerk Is Dead
CreateThread(function()
    while true do
        Wait(200)

        local player = PlayerPedId()
        if not DoesEntityExist(player) then goto continue_smash_loop end

        for heistId, heist in pairs(Heists) do
            if heist.heistType ~= 'store' then goto continue_smash_heist end
            if not heist.clerk or not heist.clerk.enabled then goto continue_smash_heist end

            -- Prevent double-triggering
            if StoreHeistStarted[heistId] then goto continue_smash_heist end

            local state = HeistClientState[heistId] or "idle"
            if state ~= "idle" then goto continue_smash_heist end -- Already started

            -- Check if clerk is missing or dead
            local clerkPed = StoreClerks[heistId]
            if clerkPed and DoesEntityExist(clerkPed) and not IsEntityDead(clerkPed) then
                goto continue_smash_heist -- Clerk is alive, use normal aiming system
            end

            -- Clerk is dead/missing - check if player is near register and armed
            if not IsPedArmed(player, 4) then goto continue_smash_heist end

            -- Find first smash step (register)
            local registerStep = nil
            for _, step in ipairs(heist.steps or {}) do
                if step.action == 'smash' then
                    registerStep = step
                    break
                end
            end

            if not registerStep then goto continue_smash_heist end

            local playerCoords = GetEntityCoords(player)
            local registerPos = vecFromTable(registerStep.coords)
            local dist = #(playerCoords - registerPos)

            if dist < 2.0 then
                -- Show prompt and allow smash to start
                if IsControlJustPressed(0, 38) then -- E key
                    -- Mark as started
                    StoreHeistStarted[heistId] = true

                    -- Start heist
                    debugPrint(('Store heist auto-started by smashing register (clerk dead): %s'):format(heistId))
                    TriggerServerEvent("cs_heistmaster:requestStart", heistId)

                    Wait(2000) -- Prevent spam
                end
            end

            ::continue_smash_heist::
        end
        ::continue_smash_loop::
    end
end)


-- ============================================================
-- H) SYNCHRONIZATION - Server Events
-- ============================================================

RegisterNetEvent('cs_heistmaster:client:setHeistState', function(heistId, state)
    HeistClientState[heistId] = state
    if state == "active" then
        currentHeistId = heistId
    elseif state ~= "active" and currentHeistId == heistId then
        currentHeistId = nil
    end
    debugPrint(('Heist state set: %s = %s'):format(heistId, state))
end)

RegisterNetEvent("cs_heistmaster:client:setStep", function(heistId, step)
    ActiveStep[heistId] = step
    debugPrint(('Step set: %s = %s'):format(heistId, step))
end)

-- PATCH C: Sync loot completion from server (for co-op)
RegisterNetEvent('cs_heistmaster:client:syncLootCompletion', function(heistId, lootKey)
    if not alreadyLooted[heistId] then
        alreadyLooted[heistId] = {}
    end
    alreadyLooted[heistId][lootKey] = true
    debugPrint(('Loot completion synced: %s - %s'):format(heistId, lootKey))
end)

RegisterNetEvent('cs_heistmaster:client:forceStart', function(heistId)
    TriggerServerEvent('cs_heistmaster:requestStart', heistId)
end)

-- ============================================================
-- VAULT DOOR SYSTEM - Simple & Clean
-- ============================================================

local function deleteDefaultVaultDoor(coords)
    local model1 = `v_ilev_bk_vaultdoor`
    local model2 = `v_ilev_gb_vauldr`
        local objects = GetGamePool('CObject')
        
        for _, obj in ipairs(objects) do
            if DoesEntityExist(obj) then
                local objModel = GetEntityModel(obj)
                local objCoords = GetEntityCoords(obj)
            local dist = #(coords - objCoords)
            
            if (objModel == model1 or objModel == model2) and dist < 10.0 then
                local isOurDoor = false
                for heistId, customDoor in pairs(VaultDoors) do
                    if customDoor == obj then
                        isOurDoor = true
                        break
            end
        end
        
                if not isOurDoor then
                    SetEntityAsMissionEntity(obj, true, true)
                    DeleteEntity(obj)
                    end
                end
            end
        end
end

RegisterNetEvent('cs_heistmaster:client:spawnVaultDoor', function(heistId, coordsTable, heading, modelName, isOpen)
    local coords = vector3(coordsTable.x, coordsTable.y, coordsTable.z)
    
    -- Delete default doors
    deleteDefaultVaultDoor(coords)
    Wait(100)
    
    -- Cleanup existing door
    if VaultDoors[heistId] and DoesEntityExist(VaultDoors[heistId]) then
        DeleteEntity(VaultDoors[heistId])
        VaultDoors[heistId] = nil
    end
    
    local model = joaat(modelName or 'v_ilev_gb_vauldr')
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end
    
    -- Spawn door
    local door = CreateObject(model, coords.x, coords.y, coords.z, true, true, false)
    SetEntityHeading(door, heading or 250.0)
    SetEntityCollision(door, true, true)
    FreezeEntityPosition(door, true)
    SetEntityAsMissionEntity(door, true, true)
    
    VaultDoors[heistId] = door
    
    if isOpen then
        local openHeading = (heading or 250.0) + 110.0
        SetEntityHeading(door, openHeading)
        SetEntityCollision(door, false, false)
    end
    
    debugPrint(('Vault door spawned: %s at %s (heading: %.2f)'):format(heistId, tostring(coords), heading or 250.0))
end)

local function animateVaultDoorOpen(heistId)
    local door = VaultDoors[heistId]
    if not door or not DoesEntityExist(door) then return end
    
    local startHeading = GetEntityHeading(door)
    local endHeading = startHeading + 110.0
    
    FreezeEntityPosition(door, false)
    SetEntityCollision(door, false, false)
    
    for i = 0, 100 do
        local t = i / 100.0
        local eased = t < 0.5 and 2.0 * t * t or -1.0 + (4.0 - 2.0 * t) * t
        local heading = startHeading + (endHeading - startHeading) * eased
        SetEntityHeading(door, heading)
        
        if i == 0 then
            local dCoords = GetEntityCoords(door)
            UseParticleFxAssetNextCall("core")
            StartParticleFxNonLoopedAtCoord("ent_dst_electrical", dCoords.x, dCoords.y, dCoords.z, 0.0, 0.0, 0.0, 1.0, false, false, false)
            PlaySoundFromCoord(-1, "VAULT_DOOR_OPEN", dCoords.x, dCoords.y, dCoords.z, "dlc_heist_fleeca_bank_door_sounds", false, 1.0, false)
        end
        
        Wait(15)
    end
    
    FreezeEntityPosition(door, true)
end

RegisterNetEvent('cs_heistmaster:client:openVaultDoor', function(heistId)
    animateVaultDoorOpen(heistId)
end)

RegisterNetEvent('cs_heistmaster:client:resetVaultDoor', function(heistId, coordsTable, heading, modelName)
    local heist = Config.Heists[heistId]
    if not heist or not heist.vault or not heist.vault.coords then return end
    
    local coords = vector3(heist.vault.coords.x, heist.vault.coords.y, heist.vault.coords.z)
    local model = joaat(modelName or heist.vault.doorModel or 'v_ilev_gb_vauldr')
    
    if VaultDoors[heistId] and DoesEntityExist(VaultDoors[heistId]) then
        DeleteEntity(VaultDoors[heistId])
        VaultDoors[heistId] = nil
    end
    
    deleteDefaultVaultDoor(coords)
    Wait(100)
    
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end
    
    local door = CreateObject(model, coords.x, coords.y, coords.z, true, true, false)
    SetEntityHeading(door, heist.vault.heading or heading or 250.0)
    SetEntityCollision(door, true, true)
    FreezeEntityPosition(door, true)
    SetEntityAsMissionEntity(door, true, true)
    VaultDoors[heistId] = door
    
    debugPrint(('Vault door reset: %s at %s (heading: %.2f)'):format(heistId, tostring(coords), heist.vault.heading or heading or 250.0))
end)

-- Continuous monitoring to prevent default doors from respawning
CreateThread(function()
    Wait(3000)
    while true do
    Wait(5000)
        
        local playerCoords = GetEntityCoords(PlayerPedId())
        
        for heistId, heist in pairs(Config.Heists) do
            if (heist.heistType == 'fleeca' or heist.heistType == 'bank') and heist.vault and heist.vault.coords then
                local vaultCoords = vector3(heist.vault.coords.x, heist.vault.coords.y, heist.vault.coords.z)
                local dist = #(playerCoords - vaultCoords)
                
                if dist < 100.0 then
                    deleteDefaultVaultDoor(vaultCoords)
                end
            end
        end
    end
end)

-- ============================================================
-- D) GUARDS SYSTEM
-- ============================================================

RegisterNetEvent('cs_heistmaster:client:spawnGuards', function(heistId, guardList)
    if not guardList or #guardList == 0 then return end
    
    -- Cleanup existing guards for this heist
    if guards[heistId] then
        for _, ped in ipairs(guards[heistId]) do
            if DoesEntityExist(ped) then DeletePed(ped) end
        end
    end
    
    guards[heistId] = {}
    
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
                SetPedRelationshipGroupHash(ped, joaat('GUARD'))
                SetRelationshipBetweenGroups(5, joaat('GUARD'), joaat('PLAYER'))
                SetRelationshipBetweenGroups(5, joaat('PLAYER'), joaat('GUARD'))
                
                GiveWeaponToPed(ped, joaat(data.weapon or 'weapon_pistol'), 250, false, true)
                SetPedCombatAbility(ped, 100)
                SetPedCombatAttributes(ped, 46, true)
                
                -- Make guards attack player on sight
                TaskCombatPed(ped, PlayerPedId(), 0, 16)
                
                table.insert(guards[heistId], ped)
                debugPrint(('Guard spawned for heist: %s'):format(heistId))
            end
        end
    end
end)


-- ============================================================
-- ALERT & ALARM HANDLER
-- ============================================================

-- A.5: Track active alarms to prevent restarting
local ActiveAlarms = {} -- [heistId] = true

local function handleStepAlert(heistId, heist, step, stepIndex)
    local alertType = step.alert or 'none'
    
    -- Force loud alert on first step (stepIndex == 1)
    if stepIndex == 1 then
        alertType = "loud"
        -- Force alarm sound on first step
        if step.alarmSound == nil then
            step.alarmSound = true
        end
        debugPrint(('Forcing loud alert on first step for heist: %s'):format(heistId))
    end
    
    -- Trigger alarm sound if configured
    if step.alarmSound and not ActiveAlarms[heistId] then
        PrepareAlarm("JEWEL_STORE_HEIST_ALARMS")
        StartAlarm("JEWEL_STORE_HEIST_ALARMS", true)
        ActiveAlarms[heistId] = true
        debugPrint(('Alarm started for heist: %s'):format(heistId))
    end
    
    -- Always trigger police alert if not silent/none
    if alertType ~= 'none' and alertType ~= 'silent' then
        TriggerServerEvent('cs_heistmaster:alertPolice', heistId, alertType)
    end
end

-- ============================================================
-- ACTION HANDLER FUNCTIONS (Called from target options)
-- ============================================================

local function handleHackAction(heistId, heist, step, stepIndex)
    local ped = PlayerPedId()
    local lootKey = ('step_%s_%s'):format(stepIndex, heistId)
    
    -- PATCH A+++: Check if already completed with better notification
    if alreadyLooted[heistId] and alreadyLooted[heistId][lootKey] then
        lib.notify({
            title = 'Already Completed',
            description = 'This step has already been completed.',
            type = 'info'
        })
        return false
    end
    
    -- Trigger alert/alarm (force loud on first step)
    handleStepAlert(heistId, heist, step, stepIndex)
    
    RequestAnimDict('anim@heists@prison_heiststation@cop_reactions')
    while not HasAnimDictLoaded('anim@heists@prison_heiststation@cop_reactions') do Wait(0) end
    
    TaskPlayAnim(ped, 'anim@heists@prison_heiststation@cop_reactions', 'console_peek_a', 8.0, -8.0, -1, 1, 0.0, false, false, false)
    
    -- Skill check
    local difficulty = step.difficulty or { 'easy', 'medium', 'hard' }
    local inputs = step.inputs or nil
    local result = lib.skillCheck(difficulty, inputs)
    
    if result then
        local hackDuration = step.time or 5000
        local progressResult = lib.progressCircle({
            duration = hackDuration,
            label = step.label or 'Hacking...',
            position = 'bottom',
            useWhileDead = false,
            canCancel = true,
            disable = { move = true, car = true, combat = true },
        })
        
        ClearPedTasks(ped)
        
        if not progressResult then
            TriggerServerEvent('cs_heistmaster:abortHeist', heistId)
            return false
        end
        
        -- Mark as completed
        alreadyLooted[heistId] = alreadyLooted[heistId] or {}
        alreadyLooted[heistId][lootKey] = true
        
        -- Step delay: Wait 2 seconds before allowing next step
        Wait(2000)
        
        TriggerServerEvent("cs_heistmaster:server:completeStep", heistId, stepIndex)
        return true
    else
        ClearPedTasks(ped)
        lib.notify({
            description = 'Hack failed!',
            type = 'error'
        })
        return false
    end
end

local function handleDrillAction(heistId, heist, step, stepIndex)
    local ped = PlayerPedId()
    local lootKey = ('step_%s_%s'):format(stepIndex, heistId)
    
    -- PATCH A+++: Check if already completed with better notification
    if alreadyLooted[heistId] and alreadyLooted[heistId][lootKey] then
        lib.notify({
            title = 'Already Completed',
            description = 'This step has already been completed.',
            type = 'info'
        })
        return false
    end
    
    -- For safe drilling, check server-side if safe was already opened
    -- This prevents multiple players from opening the same safe
    if heist.heistType == 'store' then
        -- Check with server if safe is already opened
        local safeCheck = lib.callback.await('cs_heistmaster:checkSafeOpened', false, heistId)
        if safeCheck then
            lib.notify({
                title = 'Safe Already Opened',
                description = 'This safe has already been opened by another player.',
                type = 'info'
            })
            return false
        end
    end
    
    -- Trigger alert/alarm (force loud on first step)
    handleStepAlert(heistId, heist, step, stepIndex)
    
    -- Check for safe key
    local keyName = "safe_key_"..heistId
    local hasKey = false
    
    if exports['ox_inventory'] then
        local searchResult = exports['ox_inventory']:Search('count', keyName)
        if type(searchResult) == 'number' then
            hasKey = searchResult > 0
        elseif type(searchResult) == 'table' then
            if searchResult[keyName] then
                hasKey = searchResult[keyName] > 0
            end
        end
    end
    
    if hasKey then
        -- PATCH A+++: Use key insertion/lockpicking animation (extended to 15 seconds for police response time)
        local unlockDuration = 15000
        
        -- Request and play key insertion animation
        RequestAnimDict('veh@break_in@0h@p_m_one@')
        while not HasAnimDictLoaded('veh@break_in@0h@p_m_one@') do Wait(0) end
        
        TaskPlayAnim(ped, 'veh@break_in@0h@p_m_one@', 'low_force_entry_ds', 8.0, -8.0, unlockDuration, 1, 0.0, false, false, false)
        
        local progressResult = lib.progressCircle({
            duration = unlockDuration,
            label = "Unlocking safe with key...",
            position = 'bottom',
            disable = { move = true, car = true, combat = true },
            canCancel = true
        })
        
        ClearPedTasks(ped)
        
        if not progressResult then
            TriggerServerEvent('cs_heistmaster:abortHeist', heistId)
            return false
        end
        
        TriggerServerEvent('cs_heistmaster:safeReward', heistId)
        TriggerServerEvent('cs_heistmaster:removeSafeKey', heistId)
        lib.notify({
            title = 'Safe',
            description = 'You unlocked the safe silently!',
            type = 'success'
        })
        
        -- Mark as completed
        alreadyLooted[heistId] = alreadyLooted[heistId] or {}
        alreadyLooted[heistId][lootKey] = true
        
        -- Step delay: Wait 2 seconds before allowing next step
        Wait(2000)
        
        TriggerServerEvent("cs_heistmaster:server:completeStep", heistId, stepIndex)
        return true
    else
        -- PATCH A+++: Run full drill animation (use config time, default 60 seconds for store safes)
        local duration = step.time or 60000
        -- Use the time from config (now 60 seconds to allow police response)
        RequestAnimDict('anim@heists@fleeca_bank@drilling')
        while not HasAnimDictLoaded('anim@heists@fleeca_bank@drilling') do Wait(0) end
        
        TaskPlayAnim(ped, 'anim@heists@fleeca_bank@drilling', 'drill_straight_idle', 8.0, -8.0, duration, 1, 0.0, false, false, false)
        
        local progressResult = lib.progressCircle({
            duration = duration,
            label = step.label or 'Drilling...',
            position = 'bottom',
            useWhileDead = false,
            canCancel = true,
            disable = { move = true, car = true, combat = true },
        })
        
        ClearPedTasks(ped)
        
        if not progressResult then
            TriggerServerEvent('cs_heistmaster:abortHeist', heistId)
            return false
        end
        
        -- Give safe reward for store heists
        if heist.heistType == 'store' then
            TriggerServerEvent('cs_heistmaster:safeReward', heistId)
        end
        
        -- Step 2: Open Door After Drilling - for Fleeca heists
        if heist.heistType == 'fleeca' then
            -- Optional delay before door opens
            Wait(1000)
            -- Trigger server event to open vault door
            TriggerServerEvent("cs_heistmaster:server:setVaultOpen", heistId)
        end
        
        -- Mark as completed
        alreadyLooted[heistId] = alreadyLooted[heistId] or {}
        alreadyLooted[heistId][lootKey] = true
        
        -- Step delay: Wait 2 seconds before allowing next step
        Wait(2000)
        
        TriggerServerEvent("cs_heistmaster:server:completeStep", heistId, stepIndex)
        return true
    end
end

local function handleSmashAction(heistId, heist, step, stepIndex)
    local ped = PlayerPedId()
    local lootKey = ('step_%s_%s'):format(stepIndex, heistId)
    
    -- PATCH A+++: Check if already completed with better notification
    if alreadyLooted[heistId] and alreadyLooted[heistId][lootKey] then
        lib.notify({
            title = 'Already Completed',
            description = 'This step has already been completed.',
            type = 'info'
        })
        return false
    end
    
    -- For store heists, require a melee weapon/tool (realistic - use what player has)
    local smashWeapon = nil
    local smashWeaponHash = nil
    local weaponLabel = "tool"
    
    if heist.heistType == 'store' then
        -- List of suitable melee weapons/tools for smashing
        local suitableWeapons = {
            { hash = joaat('WEAPON_CROWBAR'), name = 'crowbar', label = 'Crowbar' },
            { hash = joaat('WEAPON_HAMMER'), name = 'hammer', label = 'Hammer' },
            { hash = joaat('WEAPON_WRENCH'), name = 'wrench', label = 'Wrench' },
            { hash = joaat('WEAPON_BAT'), name = 'bat', label = 'Bat' },
            { hash = joaat('WEAPON_HATCHET'), name = 'hatchet', label = 'Hatchet' },
            { hash = joaat('WEAPON_MACHETE'), name = 'machete', label = 'Machete' },
            { hash = joaat('WEAPON_NIGHTSTICK'), name = 'nightstick', label = 'Nightstick' },
        }
        
        -- First check what weapon is currently equipped
        local currentWeaponHash = GetSelectedPedWeapon(ped)
        for _, weapon in ipairs(suitableWeapons) do
            if currentWeaponHash == weapon.hash then
                smashWeapon = weapon
                smashWeaponHash = weapon.hash
                weaponLabel = weapon.label
                debugPrint(('Smash weapon: Found equipped %s'):format(weapon.name))
                break
            end
        end
        
        -- If no suitable weapon equipped, check inventory
        if not smashWeapon then
            for _, weapon in ipairs(suitableWeapons) do
                local hasWeapon = false
                
                -- Check if player has weapon in inventory
                if exports['ox_inventory'] then
                    local searchResult = exports['ox_inventory']:Search('count', weapon.name)
                    if searchResult then
                        if type(searchResult) == 'number' then
                            hasWeapon = searchResult > 0
                        elseif type(searchResult) == 'table' then
                            if searchResult[weapon.name] then
                                hasWeapon = searchResult[weapon.name] > 0
                            end
                        end
                    end
                    
                    -- Fallback: try GetItemCount
                    if not hasWeapon then
                        local count = exports['ox_inventory']:GetItemCount(weapon.name)
                        hasWeapon = count and count > 0 or false
                    end
                elseif exports['qb-core'] then
                    local QBCore = exports['qb-core']:GetCoreObject()
                    if QBCore and QBCore.Functions then
                        hasWeapon = QBCore.Functions.HasItem(weapon.name) or false
                    end
                elseif exports['qbx_core'] then
                    hasWeapon = exports.qbx_core:HasItem(weapon.name) or false
                end
                
                if hasWeapon then
                    smashWeapon = weapon
                    smashWeaponHash = weapon.hash
                    weaponLabel = weapon.label
                    debugPrint(('Smash weapon: Found in inventory %s'):format(weapon.name))
                    break
                end
            end
        end
        
        if not smashWeapon then
            lib.notify({
                title = 'Missing Tool',
                description = 'You need a tool (crowbar, hammer, wrench, etc.) to smash this!',
                type = 'error'
            })
            return false
        end
    end
    
    -- Trigger alert/alarm (force loud on first step)
    handleStepAlert(heistId, heist, step, stepIndex)
    
    -- Store current weapon to restore later
    local currentWeapon = GetSelectedPedWeapon(ped)
    local weaponWasEquipped = smashWeaponHash and (currentWeapon == smashWeaponHash) or false
    
    -- Equip the smash weapon if not already equipped (for store heists)
    if smashWeaponHash and not weaponWasEquipped then
        -- Check if player has the weapon (don't give it if they don't have it)
        if HasPedGotWeapon(ped, smashWeaponHash, false) then
            SetCurrentPedWeapon(ped, smashWeaponHash, true)
        else
            -- If they have it in inventory but not as weapon, give it temporarily
            GiveWeaponToPed(ped, smashWeaponHash, 1, false, true)
            SetCurrentPedWeapon(ped, smashWeaponHash, true)
        end
    end
    
    -- Use appropriate animation based on weapon type
    local animDict = 'melee@large_wpn@streamed_core'
    local animName = 'ground_attack_on_spot'
    
    -- Different animations for different weapon types (if weapon detected)
    if smashWeaponHash then
        if smashWeaponHash == joaat('WEAPON_HAMMER') then
            animDict = 'amb@world_human_hammering@male@base'
            animName = 'base'
        elseif smashWeaponHash == joaat('WEAPON_WRENCH') then
            animDict = 'amb@world_human_welding@male@base'
            animName = 'base'
        end
    end
    
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do Wait(0) end
    
    TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, step.time or 4000, 1, 0.0, false, false, false)
    
    local progressResult = lib.progressCircle({
        duration = step.time or 4000,
        label = step.label or ('Smashing with ' .. weaponLabel:lower() .. '...'),
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
    })
    
    ClearPedTasks(ped)
    
    -- Restore previous weapon (for store heists with detected weapon)
    if smashWeaponHash and not weaponWasEquipped then
        -- Only remove if we gave it temporarily (player didn't have it before)
        if not HasPedGotWeapon(ped, smashWeaponHash, false) then
            -- We gave it temporarily, but if player has it in inventory, keep it
            -- Otherwise restore previous weapon
            if currentWeapon ~= 0 then
                SetCurrentPedWeapon(ped, currentWeapon, true)
            else
                SetCurrentPedWeapon(ped, joaat('WEAPON_UNARMED'), true)
            end
        else
            -- Player has the weapon, restore their previous weapon
            if currentWeapon ~= 0 and currentWeapon ~= smashWeaponHash then
                SetCurrentPedWeapon(ped, currentWeapon, true)
            end
        end
    end
    
    if not progressResult then
        TriggerServerEvent('cs_heistmaster:abortHeist', heistId)
        return false
    end
    
    -- Mark as completed
    alreadyLooted[heistId] = alreadyLooted[heistId] or {}
    alreadyLooted[heistId][lootKey] = true
    TriggerServerEvent("cs_heistmaster:server:completeStep", heistId, stepIndex)
    return true
end

local function handleLootAction(heistId, heist, step, stepIndex)
    local ped = PlayerPedId()
    local lootKey = ('step_%s_%s'):format(stepIndex, heistId)
    
    -- Check if already looted
    if alreadyLooted[heistId] and alreadyLooted[heistId][lootKey] then
        lib.notify({
            description = 'This has already been looted.',
            type = 'error'
        })
        return false
    end
    
    RequestAnimDict('anim@heists@ornate_bank@grab_cash')
    while not HasAnimDictLoaded('anim@heists@ornate_bank@grab_cash') do Wait(0) end
    
    TaskPlayAnim(ped, 'anim@heists@ornate_bank@grab_cash', 'grab', 8.0, -8.0, -1, 1, 0.0, false, false, false)
    
    local lootDuration = step.time or 3000
    local progressResult = lib.progressCircle({
        duration = lootDuration,
        label = step.label or 'Looting...',
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
    })
    
    ClearPedTasks(ped)
    
    if not progressResult then
        TriggerServerEvent('cs_heistmaster:abortHeist', heistId)
        return false
    end
    
    -- Mark as looted and request reward
    alreadyLooted[heistId] = alreadyLooted[heistId] or {}
    alreadyLooted[heistId][lootKey] = true
    TriggerServerEvent('cs_heistmaster:server:giveLoot', heistId, lootKey)
    
    -- Step delay: Wait 2 seconds before allowing next step
    Wait(2000)
    
    TriggerServerEvent("cs_heistmaster:server:completeStep", heistId, stepIndex)
    return true
end

-- Client event handler for step actions (for qb-target)
RegisterNetEvent('cs_heistmaster:client:doStepAction', function(data)
    local heistId = data.heistId
    local stepIndex = data.stepIndex
    local heist = Heists[heistId]
    if not heist or not heist.steps[stepIndex] then return end
    
    -- Check if this is the active step (qb-target doesn't support canInteract)
    if ActiveStep[heistId] ~= stepIndex then
        lib.notify({
            description = 'This step is not active yet.',
            type = 'error'
        })
        return
    end
    
    local step = heist.steps[stepIndex]
    local lootKey = ('step_%s_%s'):format(stepIndex, heistId)
    
    -- Check if already completed
    if alreadyLooted[heistId] and alreadyLooted[heistId][lootKey] then
        lib.notify({
            description = 'This has already been completed.',
            type = 'error'
        })
        return
    end
    
    local success = false
    
    if step.action == 'hack' then
        success = handleHackAction(heistId, heist, step, stepIndex)
    elseif step.action == 'drill' then
        success = handleDrillAction(heistId, heist, step, stepIndex)
    elseif step.action == 'smash' then
        success = handleSmashAction(heistId, heist, step, stepIndex)
    elseif step.action == 'loot' then
        success = handleLootAction(heistId, heist, step, stepIndex)
    end
    
    if success then
        local nextStepIndex = stepIndex + 1
        local nextStep = heist.steps[nextStepIndex]
        
        if not nextStep then
            -- Finished all steps
            TriggerServerEvent('cs_heistmaster:finishHeist', heistId)
        else
            lib.notify({
                description = 'Objective complete. Move to the next location.',
                type = 'success'
            })
        end
    end
end)

-- ============================================================
-- STEP OBJECT SPAWNING & TARGET SETUP (Defined before event handler)
-- ============================================================

local function spawnStepObjects(heistId, heist)
    if not StepObjects[heistId] then
        StepObjects[heistId] = {}
    end
    
    -- Cleanup existing objects first
    for stepIndex, obj in pairs(StepObjects[heistId]) do
        if DoesEntityExist(obj) then
            removeTargetFromObject(obj)
            DeleteEntity(obj)
        end
    end
    StepObjects[heistId] = {}
    
    -- Spawn invisible object for each step
    for stepIndex, step in ipairs(heist.steps or {}) do
        if step.action ~= 'escape' then -- Escape steps don't need objects
            local stepCoords = vecFromTable(step.coords)
            
            -- Use zone-based approach for ox_target, object-based for qb-target
            if useOxTarget then
                -- ox_target supports sphere zones which are better than invisible objects
                local lootKey = ('step_%s_%s'):format(stepIndex, heistId)
                local icon = 'fas fa-hand'
                local label = step.label or 'Interact'
                
                if step.action == 'hack' then
                    icon = 'fas fa-keyboard'
                    label = step.label or 'Hack Security Panel'
                elseif step.action == 'drill' then
                    icon = 'fas fa-screwdriver'
                    label = step.label or 'Drill Safe/Vault'
                elseif step.action == 'loot' then
                    icon = 'fas fa-hand-holding'
                    label = step.label or 'Loot Register/Vault'
                elseif step.action == 'smash' then
                    icon = 'fas fa-hammer'
                    label = step.label or 'Smash Register/Display'
                end
                
                local zoneId = exports.ox_target:addSphereZone({
                    coords = stepCoords,
                    radius = 1.5,
                    debug = Config.Debug,
                    options = {
                        {
                            label = label,
                            icon = icon,
                            distance = 2.0,
                            canInteract = function()
                                -- Always show target option if step is active and not completed
                                -- Item checks happen in the action handler, not here
                                return ActiveStep[heistId] == stepIndex and 
                                       (not alreadyLooted[heistId] or not alreadyLooted[heistId][lootKey])
                            end,
                            onSelect = function()
                                local success = false
                                if step.action == 'hack' then
                                    success = handleHackAction(heistId, heist, step, stepIndex)
                                elseif step.action == 'drill' then
                                    success = handleDrillAction(heistId, heist, step, stepIndex)
                                elseif step.action == 'smash' then
                                    success = handleSmashAction(heistId, heist, step, stepIndex)
                                elseif step.action == 'loot' then
                                    success = handleLootAction(heistId, heist, step, stepIndex)
                                end
                                
                                if success then
                                    local nextStepIndex = stepIndex + 1
                                    local nextStep = heist.steps[nextStepIndex]
                                    
                                    if not nextStep then
                                        TriggerServerEvent('cs_heistmaster:finishHeist', heistId)
                                    else
                                        lib.notify({
                                            description = 'Objective complete. Move to the next location.',
                                            type = 'success'
                                        })
                                    end
                                end
                            end
                        }
                    }
                })
                
                -- Store zone ID for cleanup (ox_target returns zone ID)
                StepObjects[heistId][stepIndex] = zoneId
            else
                -- qb-target requires an entity, so create invisible object
                local modelHash = joaat('prop_mp_placement') -- Small invisible prop
                if not IsModelInCdimage(modelHash) then
                    modelHash = joaat('prop_atm_01') -- Fallback to ATM model
                end
                
                RequestModel(modelHash)
                while not HasModelLoaded(modelHash) do Wait(10) end
                
                local obj = CreateObjectNoOffset(modelHash, stepCoords.x, stepCoords.y, stepCoords.z, false, false, false)
                SetEntityAlpha(obj, 0, false) -- Make invisible
                FreezeEntityPosition(obj, true)
                SetEntityCollision(obj, false, false)
                
                StepObjects[heistId][stepIndex] = obj
                
                -- Add target option for qb-target
                local lootKey = ('step_%s_%s'):format(stepIndex, heistId)
                local icon = 'fas fa-hand'
                local label = step.label or 'Interact'
                
                if step.action == 'hack' then
                    icon = 'fas fa-keyboard'
                    label = step.label or 'Hack Security Panel'
                elseif step.action == 'drill' then
                    icon = 'fas fa-screwdriver'
                    label = step.label or 'Drill Safe/Vault'
                elseif step.action == 'loot' then
                    icon = 'fas fa-hand-holding'
                    label = step.label or 'Loot Register/Vault'
                elseif step.action == 'smash' then
                    icon = 'fas fa-hammer'
                    label = step.label or 'Smash Register/Display'
                end
                
                exports['qb-target']:AddTargetEntity(obj, {
                    options = {
                        {
                            type = "client",
                            event = "cs_heistmaster:client:doStepAction",
                            label = label,
                            icon = icon,
                            action = step.action,
                            heistId = heistId,
                            stepIndex = stepIndex
                        }
                    },
                    distance = 2.0
                })
            end
            
            debugPrint(('Step target spawned for heist %s, step %s'):format(heistId, stepIndex))
        end
    end
end

local function cleanupStepObjects(heistId)
    if StepObjects[heistId] then
        for stepIndex, objOrZoneId in pairs(StepObjects[heistId]) do
            if useOxTarget then
                -- ox_target zones are removed by ID
                local zoneId = objOrZoneId
                if zoneId then
                    exports.ox_target:removeZone(zoneId)
                end
            elseif useQbTarget then
                -- qb-target uses entities
                if DoesEntityExist(objOrZoneId) then
                    removeTargetFromObject(objOrZoneId)
                    DeleteEntity(objOrZoneId)
                end
            end
        end
        StepObjects[heistId] = nil
    end
end

-- ============================================================
-- C) STEP PROGRESSION & ACTIONS
-- ============================================================

local function runHeistThread(heistId, heist)
    CreateThread(function()
        local heistStartPos = vecFromTable(heist.start)
        local maxDistance = 80.0 -- Abort if player goes too far
        
        while currentHeistId == heistId do
            local ped = PlayerPedId()
            if not ped or ped == 0 then
                -- F) Player logged out
                TriggerServerEvent('cs_heistmaster:abortHeist', heistId)
                break
            end
            
            local pCoords = GetEntityCoords(ped)
            
            -- F) ABORT CONDITIONS
            if IsEntityDead(ped) then
                TriggerServerEvent('cs_heistmaster:abortHeist', heistId)
                break
            end
            
            local distFromStart = #(pCoords - heistStartPos)
            if distFromStart > maxDistance then
                lib.notify({
                    description = 'You left the heist area!',
                    type = 'error'
                })
                TriggerServerEvent('cs_heistmaster:abortHeist', heistId)
                break
            end
            
            -- Check for escape step (escape steps don't use target objects)
            local stepIndex = ActiveStep[heistId] or 1
            local step = heist.steps[stepIndex]
            
            if step and step.action == 'escape' then
                local escapePos = vecFromTable(step.coords)
                local distFromEscape = #(pCoords - escapePos)
                local escapeRadius = step.radius or 5.0
                
                if distFromEscape <= escapeRadius then
                    -- Player is at escape point, finish heist
                    TriggerServerEvent("cs_heistmaster:server:completeStep", heistId, stepIndex)
                    TriggerServerEvent('cs_heistmaster:finishHeist', heistId)
                    currentHeistId = nil
                    break
                end
            end
            
            Wait(1000) -- Check escape step every second
        end
    end)
end

-- ============================================================
-- START HEIST EVENT HANDLER (After function definitions)
-- ============================================================

RegisterNetEvent('cs_heistmaster:client:startHeist', function(heistId, heistData)
    -- Allow multiple players to have the same heist active (co-op support)
    -- Don't overwrite if already active, just ensure state is set
    if not Heists[heistId] then
        Heists[heistId] = heistData
    end
    
    -- Only set currentHeistId if this player doesn't have another heist active
    if not currentHeistId then
        currentHeistId = heistId
        currentStepIndex = 1
    end
    
    HeistClientState[heistId] = "active"
    
    -- Initialize step tracking if not already set
    if not ActiveStep[heistId] then
        ActiveStep[heistId] = 1
    end
    
    -- Initialize loot tracking if not already set
    if not alreadyLooted[heistId] then
        alreadyLooted[heistId] = {}
    end
    
    debugPrint('Heist started/joined:', heistId)
    
    lib.notify({
        title = heistData.label,
        description = 'Heist started. Follow the objectives.',
        type = 'success'
    })
    
    -- Vault door is spawned by server via sync event, do not auto-spawn here
    
    -- Spawn step objects with target options
    CreateThread(function()
        -- Wait for targeting system to be detected
        local attempts = 0
        while not useOxTarget and not useQbTarget and attempts < 20 do
            Wait(100)
            attempts = attempts + 1
        end
        
        if useOxTarget or useQbTarget then
            Wait(200) -- Small delay to ensure targeting system is ready
            spawnStepObjects(heistId, heistData)
        else
            debugPrint('ERROR: Cannot spawn step objects - targeting system not available')
            lib.notify({
                title = 'Error',
                description = 'Targeting system not available. Heist steps may not work.',
                type = 'error'
            })
        end
    end)
    
    -- Start the heist thread (only if not already running)
    if currentHeistId == heistId then
        runHeistThread(heistId, heistData)
    end
end)

-- ============================================================
-- SPAWN GUARDS AND CLERKS ON RESOURCE START / REJOIN
-- ============================================================

local SpawnAllInProgress = false -- Prevent concurrent calls

local function SpawnAllHeistElements()
    -- Prevent concurrent spawn attempts
    if SpawnAllInProgress then
        debugPrint('SpawnAllHeistElements already in progress, skipping')
        return
    end
    
    SpawnAllInProgress = true
    
    -- CRITICAL: Use Config.Heists if Heists table is empty (for initial spawn)
    local heistSource = next(Heists) and Heists or Config.Heists
    debugPrint(('SpawnAllHeistElements: Using %s heists'):format(next(Heists) and 'Heists table' or 'Config.Heists'))
    
    for heistId, heist in pairs(heistSource) do
        -- Spawn bank guards for bank heists (fleeca, etc.) - only if they don't exist
        if (heist.heistType == 'fleeca' or heist.heistType == 'bank') and heist.guards then
            -- CRITICAL FIX: Stronger check to prevent duplicate spawning
            if GuardSpawning[heistId] then
                debugPrint(('SpawnAllHeistElements: Guard spawn in progress for heist %s, skipping'):format(heistId))
                goto continue_heist_loop
            end
            
            -- FIX: Check each guard location individually - only spawn if guards are missing
            local needsSpawn = false
            if not BankGuards[heistId] or not next(BankGuards[heistId]) then
                debugPrint(('SpawnAllHeistElements: No guards tracked for heist %s, will spawn'):format(heistId))
                needsSpawn = true
            else
                -- Check if any guard location is missing or invalid
                for guardIndex = 1, #heist.guards do
                    local existingGuard = BankGuards[heistId][guardIndex]
                    if not existingGuard or not DoesEntityExist(existingGuard) or IsEntityDead(existingGuard) then
                        debugPrint(('SpawnAllHeistElements: Guard missing/invalid at location %d for heist %s, will spawn'):format(guardIndex, heistId))
                        needsSpawn = true
                        break
                    end
                end
            end
            if needsSpawn then
                SpawnBankGuards(heistId)
            else
                debugPrint(('SpawnAllHeistElements: All guards exist for heist %s, skipping spawn'):format(heistId))
            end
        end
        ::continue_heist_loop::
        
        -- Spawn clerks for store heists - only if they don't exist
        if heist.heistType == 'store' and heist.clerk and heist.clerk.enabled then
            -- Robust check: verify clerk doesn't exist or is dead before spawning
            local existingClerk = StoreClerks[heistId]
            if not existingClerk or not DoesEntityExist(existingClerk) or IsEntityDead(existingClerk) then
                debugPrint(('SpawnAllHeistElements: Clerk missing/dead for heist %s, will spawn'):format(heistId))
                SpawnClerk(heistId)
            else
                debugPrint(('SpawnAllHeistElements: Clerk exists for heist %s (entity: %s), skipping spawn'):format(heistId, tostring(existingClerk)))
            end
        end
        
        -- Vault doors are handled by server sync, do not auto-spawn here
    end
    
    SpawnAllInProgress = false
end


-- DEBUG: Command to manually find and register vault door

-- Initial spawn (only once on resource start)
local hasInitialSpawned = false
CreateThread(function()
    Wait(2000) -- Wait for config to load
    if not hasInitialSpawned then
        hasInitialSpawned = true
        SpawnAllHeistElements()
    end
end)

-- Respawn on player loaded / resource restart (only spawn missing NPCs)
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    Wait(3000) -- Wait for everything to load
    -- Only spawn if NPCs are missing (SpawnAllHeistElements checks existence)
    SpawnAllHeistElements()
end)

-- Also handle qbx_core if used
AddEventHandler('qbx_core:client:playerLoaded', function()
    Wait(3000) -- Wait for everything to load
    -- Only spawn if NPCs are missing (SpawnAllHeistElements checks existence)
    SpawnAllHeistElements()
end)

-- Respawn after cleanup
RegisterNetEvent('cs_heistmaster:client:cleanupHeist', function(heistId)
    -- Cleanup guards (server-spawned)
    if guards[heistId] then
        for _, ped in ipairs(guards[heistId]) do
            if DoesEntityExist(ped) then DeletePed(ped) end
        end
        guards[heistId] = nil
    end
    
    -- FIX: Cleanup bank guards on heist end/abort to prevent duplicates
    -- NOTE: Guards should persist after heist ends (they're part of the bank, not the heist)
    -- Only cleanup if explicitly needed (e.g., heist abort or resource restart)
    if BankGuards[heistId] then
        debugPrint(('cleanupHeist: Cleaning up bank guards for heist %s'):format(heistId))
        for guardIndex, ped in pairs(BankGuards[heistId]) do
            if DoesEntityExist(ped) then
                DeletePed(ped)
                debugPrint(('cleanupHeist: Bank guard %d deleted for heist: %s'):format(guardIndex, heistId))
            end
        end
        BankGuards[heistId] = nil
        GuardSpawning[heistId] = nil -- Clear spawn lock
        GuardSpawnCooldown[heistId] = nil -- Clear cooldown
    end
    
    -- Cleanup clerk (will respawn after cooldown)
    -- NOTE: Clerk should only be deleted if heist ends/aborts, not during normal gameplay
    local clerkPed = StoreClerks[heistId] or SpawnedClerks[heistId]
    if clerkPed and DoesEntityExist(clerkPed) then
        debugPrint(('cleanupHeist: Deleting clerk for heist %s (entity: %s)'):format(heistId, tostring(clerkPed)))
        DeletePed(clerkPed)
    end
    
    -- Clear all clerk references
    StoreClerks[heistId] = nil
    SpawnedClerks[heistId] = nil
    ClerkSpawning[heistId] = nil -- Clear spawn lock
    ClerkSpawnCooldown[heistId] = nil -- Clear cooldown (will be set again on respawn)
    
    -- CRITICAL: Do NOT touch vault doors for fleeca/bank heists in cleanup
    -- Vault doors must stay open until cooldown finishes, then server will reset them
    local heist = Config.Heists[heistId]
    if heist and (heist.heistType == 'fleeca' or heist.heistType == 'bank') then
        -- Do NOT touch VaultDoors[heistId] here - door stays open until cooldown
        debugPrint(('cleanupHeist: Leaving vault door open for heist %s (will reset on cooldown)'):format(heistId))
    else
        -- For other heist types, you can delete their door if needed
        if VaultDoors[heistId] and DoesEntityExist(VaultDoors[heistId]) then
            DeleteEntity(VaultDoors[heistId])
            VaultDoors[heistId] = nil
            debugPrint(('cleanupHeist: Deleted vault door for non-fleeca/bank heist %s'):format(heistId))
        end
    end
    
    -- Reset state
    ClerkRuntimeState[heistId] = nil
    alreadyLooted[heistId] = nil
    BankHeistStarted[heistId] = nil -- Reset start flag for next heist
    StoreHeistStarted[heistId] = nil -- Reset start flag for next heist
    
    if currentHeistId == heistId then
        currentHeistId = nil
        currentStepIndex = 0
    end
    
    debugPrint(('Heist cleaned up: %s'):format(heistId))
    
    -- Cleanup step objects
    cleanupStepObjects(heistId)
    
    -- A.5: Stop alarm if active
    if ActiveAlarms[heistId] then
        StopAlarm("JEWEL_STORE_HEIST_ALARMS", true)
        ActiveAlarms[heistId] = nil
        debugPrint(('Alarm stopped for heist: %s'):format(heistId))
    end
    
    -- A.4: Delay clerk respawn until cooldown ends
    local heist = Heists[heistId]
    if heist then
        -- DON'T respawn bank guards on cleanup - they should persist and only respawn if missing
        -- Guards are managed by SpawnAllHeistElements which checks if they exist
        
        -- A.4: Delay clerk respawn until cooldown ends
        if heist.heistType == 'store' and heist.clerk and heist.clerk.enabled then
            local cooldownMs = (heist.cooldown or 0) * 1000
            CreateThread(function()
                Wait(cooldownMs)
                -- Check if heist is still in cooldown before respawning
                local state = HeistClientState[heistId] or "idle"
                if state == "cooldown" or state == "idle" then
                    -- Only respawn if clerk doesn't exist or is dead
                    local existingClerk = StoreClerks[heistId]
                    if not existingClerk or not DoesEntityExist(existingClerk) or IsEntityDead(existingClerk) then
                        debugPrint(('cleanupHeist: Respawning clerk after cooldown for heist %s'):format(heistId))
                        SpawnClerk(heistId)
                    else
                        debugPrint(('cleanupHeist: Clerk still exists for heist %s, skipping respawn'):format(heistId))
                    end
                else
                    debugPrint(('cleanupHeist: Heist %s not in cooldown/idle state (%s), skipping clerk respawn'):format(heistId, state))
                end
            end)
        end
        
        -- DON'T respawn vault doors on cleanup - they should persist and only respawn if missing
        -- Vault doors are managed by SpawnAllHeistElements which checks if they exist
    end
end)
