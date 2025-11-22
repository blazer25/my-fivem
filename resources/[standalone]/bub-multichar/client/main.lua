local config = require 'config.client'
local defaultSpawn = require 'config.shared'.defaultSpawn

local previewCam = nil
local randomLocation = config.characters.locations[math.random(1, #config.characters.locations)]

local randomPeds = {
    {
        model = `mp_m_freemode_01`,
        headOverlays = {
            beard = {color = 0, style = 0, secondColor = 0, opacity = 1},
            complexion = {color = 0, style = 0, secondColor = 0, opacity = 0},
            bodyBlemishes = {color = 0, style = 0, secondColor = 0, opacity = 0},
            blush = {color = 0, style = 0, secondColor = 0, opacity = 0},
            lipstick = {color = 0, style = 0, secondColor = 0, opacity = 0},
            blemishes = {color = 0, style = 0, secondColor = 0, opacity = 0},
            eyebrows = {color = 0, style = 0, secondColor = 0, opacity = 1},
            makeUp = {color = 0, style = 0, secondColor = 0, opacity = 0},
            sunDamage = {color = 0, style = 0, secondColor = 0, opacity = 0},
            moleAndFreckles = {color = 0, style = 0, secondColor = 0, opacity = 0},
            chestHair = {color = 0, style = 0, secondColor = 0, opacity = 1},
            ageing = {color = 0, style = 0, secondColor = 0, opacity = 1},
        },
        components = {
            {texture = 0, drawable = 0, component_id = 0},
            {texture = 0, drawable = 0, component_id = 1},
            {texture = 0, drawable = 0, component_id = 2},
            {texture = 0, drawable = 0, component_id = 5},
            {texture = 0, drawable = 0, component_id = 7},
            {texture = 0, drawable = 0, component_id = 9},
            {texture = 0, drawable = 0, component_id = 10},
            {texture = 0, drawable = 15, component_id = 11},
            {texture = 0, drawable = 15, component_id = 8},
            {texture = 0, drawable = 15, component_id = 3},
            {texture = 0, drawable = 34, component_id = 6},
            {texture = 0, drawable = 61, component_id = 4},
        },
        props = {
            {prop_id = 0, drawable = -1, texture = -1},
            {prop_id = 1, drawable = -1, texture = -1},
            {prop_id = 2, drawable = -1, texture = -1},
            {prop_id = 6, drawable = -1, texture = -1},
            {prop_id = 7, drawable = -1, texture = -1},
        }
    },
    {
        model = `mp_f_freemode_01`,
        headBlend = {
            shapeMix = 0.3,
            skinFirst = 0,
            shapeFirst = 31,
            skinSecond = 0,
            shapeSecond = 0,
            skinMix = 0,
            thirdMix = 0,
            shapeThird = 0,
            skinThird = 0,
        },
        hair = {
            color = 0,
            style = 15,
            texture = 0,
            highlight = 0
        },
        headOverlays = {
            chestHair = {secondColor = 0, opacity = 0, color = 0, style = 0},
            bodyBlemishes = {secondColor = 0, opacity = 0, color = 0, style = 0},
            beard = {secondColor = 0, opacity = 0, color = 0, style = 0},
            lipstick = {secondColor = 0, opacity = 0, color = 0, style = 0},
            complexion = {secondColor = 0, opacity = 0, color = 0, style = 0},
            blemishes = {secondColor = 0, opacity = 0, color = 0, style = 0},
            moleAndFreckles = {secondColor = 0, opacity = 0, color = 0, style = 0},
            makeUp = {secondColor = 0, opacity = 0, color = 0, style = 0},
            ageing = {secondColor = 0, opacity = 1, color = 0, style = 0},
            eyebrows = {secondColor = 0, opacity = 1, color = 0, style = 0},
            blush = {secondColor = 0, opacity = 0, color = 0, style = 0},
            sunDamage = {secondColor = 0, opacity = 0, color = 0, style = 0},
        },
        components = {
            {drawable = 0, component_id = 0, texture = 0},
            {drawable = 0, component_id = 1, texture = 0},
            {drawable = 0, component_id = 2, texture = 0},
            {drawable = 0, component_id = 5, texture = 0},
            {drawable = 0, component_id = 7, texture = 0},
            {drawable = 0, component_id = 9, texture = 0},
            {drawable = 0, component_id = 10, texture = 0},
            {drawable = 15, component_id = 3, texture = 0},
            {drawable = 15, component_id = 11, texture = 3},
            {drawable = 14, component_id = 8, texture = 0},
            {drawable = 15, component_id = 4, texture = 3},
            {drawable = 35, component_id = 6, texture = 0},
        },
        props = {
            {prop_id = 0, drawable = -1, texture = -1},
            {prop_id = 1, drawable = -1, texture = -1},
            {prop_id = 2, drawable = -1, texture = -1},
            {prop_id = 6, drawable = -1, texture = -1},
            {prop_id = 7, drawable = -1, texture = -1},
        }
    }
}

local function setupPreviewCam()
    DoScreenFadeIn(1000)
    SetTimecycleModifier('hud_def_blur')
    SetTimecycleModifierStrength(1.0)
    FreezeEntityPosition(cache.ped, false)
    previewCam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', randomLocation.camCoords.x, randomLocation.camCoords.y, randomLocation.camCoords.z, -6.0, 0.0, randomLocation.camCoords.w, 40.0, false, 0)
    SetCamActive(previewCam, true)
    SetCamUseShallowDofMode(previewCam, true)
    SetCamNearDof(previewCam, 0.4)
    SetCamFarDof(previewCam, 1.8)
    SetCamDofStrength(previewCam, 0.7)
    RenderScriptCams(true, false, 1, true, true)
    CreateThread(function()
        while DoesCamExist(previewCam) do
            SetUseHiDof()
            Wait(0)
        end
    end)
end

local function destroyPreviewCam()
    if not previewCam then return end

    SetTimecycleModifier('default')
    SetCamActive(previewCam, false)
    DestroyCam(previewCam, true)
    RenderScriptCams(false, false, 1, true, true)
    FreezeEntityPosition(cache.ped, false)
end

local function randomPed()
    local ped = randomPeds[math.random(1, #randomPeds)]
    lib.requestModel(ped.model, config.loadingModelsTimeout)
    SetPlayerModel(cache.playerId, ped.model)
    
    -- Try to apply appearance if illenium-appearance is available
    if GetResourceState('illenium-appearance') == 'started' then
        pcall(function() 
            exports['illenium-appearance']:setPedAppearance(PlayerPedId(), ped) 
        end)
    end
    
    SetModelAsNoLongerNeeded(ped.model)
end

---@param citizenId? string
local function previewPed(citizenId)
    if not citizenId then 
        randomPed() 
        return 
    end

    local clothing, model = lib.callback.await('bub-multichar:server:getPreviewPedData', false, citizenId)
    
    -- If we have model data, use it
    if model then
        lib.requestModel(model, config.loadingModelsTimeout)
        SetPlayerModel(cache.playerId, model)
        
        -- Try to apply appearance if we have clothing data and illenium-appearance is available
        if clothing and GetResourceState('illenium-appearance') == 'started' then
            local success, err = pcall(function() 
                local appearanceData = type(clothing) == 'string' and json.decode(clothing) or clothing
                if appearanceData then
                    exports['illenium-appearance']:setPedAppearance(PlayerPedId(), appearanceData) 
                end
            end)
            if not success then
                print("^3[bub-multichar] Could not apply appearance: " .. tostring(err) .. "^7")
            end
        end
        
        SetModelAsNoLongerNeeded(model)
    else
        -- No model data, use random ped
        randomPed()
    end
end

-- @param str string
-- @return string?
local function capString(str)
  return str:gsub("(%w)([%w']*)", function(first, rest)
    return first:upper() .. rest:lower()
  end)
end

local function spawnDefault() -- We use a callback to make the server wait on this to be done
    DoScreenFadeOut(500)

    while not IsScreenFadedOut() do
        Wait(0)
    end

    destroyPreviewCam()

    pcall(function() exports.spawnmanager:spawnPlayer({
        x = defaultSpawn.x,
        y = defaultSpawn.y,
        z = defaultSpawn.z,
        heading = defaultSpawn.w
    }) end)

    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
    TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)

    while not IsScreenFadedIn() do
        Wait(0)
    end
    -- Trigger appearance menu if available
    if GetResourceState('illenium-appearance') == 'started' then
        TriggerEvent('illenium-appearance:client:startAppearance')
    elseif GetResourceState('qb-clothes') == 'started' then
        TriggerEvent('qb-clothes:client:CreateFirstCharacter')
    else
        -- No appearance system, just fade in
        DoScreenFadeIn(500)
    end
end

local playerDataReady = false

-- Listen for player data to be ready
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    playerDataReady = true
end)

local function spawnLastLocation()
    DoScreenFadeOut(500)

    while not IsScreenFadedOut() do
        Wait(0)
    end

    destroyPreviewCam()

    -- Wait for PlayerData to be available (with timeout)
    local maxWait = 100 -- 10 seconds max wait
    local waited = 0
    playerDataReady = false
    
    -- Wait for either PlayerData to be available or OnPlayerLoaded event
    while (not QBX or not QBX.PlayerData or not QBX.PlayerData.position) and not playerDataReady and waited < maxWait do
        Wait(100)
        waited = waited + 1
    end

    local spawnPos = defaultSpawn
    if QBX and QBX.PlayerData and QBX.PlayerData.position then
        spawnPos = {
            x = QBX.PlayerData.position.x,
            y = QBX.PlayerData.position.y,
            z = QBX.PlayerData.position.z,
            w = QBX.PlayerData.position.w or 0.0
        }
    end

    -- Spawn player
    pcall(function() 
        exports.spawnmanager:spawnPlayer({
            x = spawnPos.x,
            y = spawnPos.y,
            z = spawnPos.z,
            heading = spawnPos.w
        }) 
    end)

    -- Wait for spawn to complete
    Wait(1000)
    
    -- Ensure we're in the correct position
    local ped = PlayerPedId()
    SetEntityCoords(ped, spawnPos.x, spawnPos.y, spawnPos.z, false, false, false, false)
    SetEntityHeading(ped, spawnPos.w)

    -- Trigger loaded events
    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
    TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)

    -- Wait a bit more for everything to sync
    Wait(500)
    
    -- Fade in
    DoScreenFadeIn(1000)
    
    while not IsScreenFadedIn() do
        Wait(0)
    end
end

---@param cid integer
---@return boolean
local function createCharacter(cid, character)
  previewPed()

  DoScreenFadeOut(150)
  local newData = lib.callback.await('bub-multichar:server:createCharacter', false, {
    firstname = capString(character.firstName),
    lastname = capString(character.lastName),
    nationality = capString(character.nationality),
    gender = character.gender == 'Male' and 0 or 1,
    birthdate = character.birthdate,
    cid = cid
  })

  spawnDefault()
  destroyPreviewCam()
  return true
end

local function chooseCharacter()
    randomLocation = config.characters.locations[math.random(1, #config.characters.locations)]
    SetFollowPedCamViewMode(2)

    DoScreenFadeOut(500)

    while not IsScreenFadedOut() and cache.ped ~= PlayerPedId()  do
        Wait(0)
    end

	FreezeEntityPosition(cache.ped, true)
	Wait(1000)
    SetEntityCoords(cache.ped, randomLocation.pedCoords.x, randomLocation.pedCoords.y, randomLocation.pedCoords.z, false, false, false, false)
    SetEntityHeading(cache.ped, randomLocation.pedCoords.w)
	lib.callback.await('bub-multichar:server:setCharBucket')
	Wait(1500)
	ShutdownLoadingScreen()
	ShutdownLoadingScreenNui()
	setupPreviewCam()

	---@type PlayerEntity[], integer
	local characters, amount = lib.callback.await('bub-multichar:server:getCharacters')
	SetNuiFocus(true, true)
	SendNUIMessage({
		action = 'showMultiChar',
		data = {
			characters = characters,
            allowedCharacters = amount
		}
	})

	SetTimecycleModifier('default')
end

RegisterNuiCallback('selectCharacter', function(data, cb)
  previewPed(data.citizenid)
  cb(1)
end)

RegisterNuiCallback('playCharacter', function(data, cb)
  SetNuiFocus(false, false)
  DoScreenFadeOut(500)
  
  -- Wait for fade out
  while not IsScreenFadedOut() do
    Wait(0)
  end
  
  -- Load character on server
  local success = lib.callback.await('bub-multichar:server:loadCharacter', false, data.citizenid)
  
  if not success then
    print("^1[bub-multichar] Failed to load character!^7")
    DoScreenFadeIn(500)
    cb(0)
    return
  end
  
  -- Wait a bit for player data to sync
  Wait(500)
  
  destroyPreviewCam()
  spawnLastLocation()
  cb(1)
end)

RegisterNuiCallback('deleteCharacter', function(data, cb)
  SetNuiFocus(false, false)
  TriggerServerEvent('bub-multichar:server:deleteCharacter', data.citizenid)
  destroyPreviewCam()
  chooseCharacter()
  cb(1)
end)

RegisterNuiCallback('createCharacter', function(data, cb)
  SetNuiFocus(false, false)
  local success = createCharacter(data.cid, data.character)
  if success then return end
  cb(success)
end)

RegisterNetEvent('qbx_core:client:playerLoggedOut', function()
  if GetInvokingResource() then return end -- Make sure this can only be triggered from the server
  chooseCharacter()
end)

-- Register event for external resources to trigger character selection
RegisterNetEvent('bub-multichar:client:chooseChar', function()
  if GetInvokingResource() then return end -- Make sure this can only be triggered from the server
  chooseCharacter()
end)

CreateThread(function()
  local model = `a_m_y_bevhills_01`
  while true do
    Wait(0)
    if NetworkIsSessionStarted() then
      pcall(function() exports.spawnmanager:setAutoSpawn(false) end)
      Wait(250)
      lib.requestModel(model, config.loadingModelsTimeout)
      SetPlayerModel(cache.playerId, model)
      chooseCharacter()
      break
    end
  end
end)
