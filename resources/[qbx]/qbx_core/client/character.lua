local config = require 'config.client'
local defaultSpawn = require 'config.shared'.defaultSpawn

if config.characters.useExternalCharacters then return end

local previewCam
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

NetworkStartSoloTutorialSession()

local nationalities = {}

if config.characters.limitNationalities then
    local nationalityList = lib.load('data.nationalities')

    CreateThread(function()
        for i = 1, #nationalityList do
            nationalities[#nationalities + 1] = { value = nationalityList[i] }
        end
    end)
end

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
    DisplayRadar(true)
    previewCam = nil
end

local function randomPed()
    local ped = randomPeds[math.random(1, #randomPeds)]
    lib.requestModel(ped.model, config.loadingModelsTimeout)
    SetPlayerModel(cache.playerId, ped.model)
    local playerPed = PlayerPedId()
    
    -- Set head blend data if available
    if ped.headBlend then
        SetPedHeadBlendData(playerPed, ped.headBlend.shapeFirst, ped.headBlend.shapeSecond, ped.headBlend.shapeThird,
            ped.headBlend.skinFirst, ped.headBlend.skinSecond, ped.headBlend.skinThird,
            ped.headBlend.shapeMix, ped.headBlend.skinMix, ped.headBlend.thirdMix, false)
    end
    
    -- Set hair if available
    if ped.hair then
        SetPedComponentVariation(playerPed, 2, ped.hair.style, ped.hair.texture, 0)
        SetPedHairColor(playerPed, ped.hair.color, ped.hair.highlight)
    end
    
    -- Set head overlays
    if ped.headOverlays then
        for overlayName, overlayData in pairs(ped.headOverlays) do
            local overlayId = ({
                blemishes = 0, beard = 1, eyebrows = 2, ageing = 3, makeUp = 4, blush = 5,
                complexion = 6, sunDamage = 7, lipstick = 8, moleAndFreckles = 9, chestHair = 10,
                bodyBlemishes = 11
            })[overlayName]
            if overlayId ~= nil then
                SetPedHeadOverlay(playerPed, overlayId, overlayData.style, overlayData.opacity)
                if overlayData.color then
                    SetPedHeadOverlayColor(playerPed, overlayId, 1, overlayData.color, overlayData.secondColor or 0)
                end
            end
        end
    end
    
    -- Set components
    if ped.components then
        for _, component in ipairs(ped.components) do
            SetPedComponentVariation(playerPed, component.component_id, component.drawable, component.texture, 0)
        end
    end
    
    -- Set props
    if ped.props then
        for _, prop in ipairs(ped.props) do
            if prop.drawable == -1 then
                ClearPedProp(playerPed, prop.prop_id)
            else
                SetPedPropIndex(playerPed, prop.prop_id, prop.drawable, prop.texture, true)
            end
        end
    end
    
    SetModelAsNoLongerNeeded(ped.model)
end

---@param citizenId? string
local function previewPed(citizenId)
    if not citizenId then randomPed() return end

    local clothing, model = lib.callback.await('qbx_core:server:getPreviewPedData', false, citizenId)
    if model and clothing then
        lib.requestModel(model, config.loadingModelsTimeout)
        SetPlayerModel(cache.playerId, model)
        local playerPed = PlayerPedId()
        local appearance = json.decode(clothing)
        
        -- Use illenium-appearance export if available, otherwise use native functions
        if GetResourceState('illenium-appearance') == 'started' then
            local success, result = pcall(function()
                return exports['illenium-appearance']:setPedAppearance(playerPed, appearance)
            end)
            if not success then
                -- Fallback to native functions if export fails
                if appearance.headBlend then
                    SetPedHeadBlendData(playerPed, appearance.headBlend.shapeFirst, appearance.headBlend.shapeSecond, appearance.headBlend.shapeThird,
                        appearance.headBlend.skinFirst, appearance.headBlend.skinSecond, appearance.headBlend.skinThird,
                        appearance.headBlend.shapeMix, appearance.headBlend.skinMix, appearance.headBlend.thirdMix, false)
                end
                if appearance.components then
                    for _, component in ipairs(appearance.components) do
                        SetPedComponentVariation(playerPed, component.component_id, component.drawable, component.texture, 0)
                    end
                end
                if appearance.props then
                    for _, prop in ipairs(appearance.props) do
                        if prop.drawable == -1 then
                            ClearPedProp(playerPed, prop.prop_id)
                        else
                            SetPedPropIndex(playerPed, prop.prop_id, prop.drawable, prop.texture, true)
                        end
                    end
                end
            end
        else
            -- Use native functions if illenium-appearance is not available
            if appearance.headBlend then
                SetPedHeadBlendData(playerPed, appearance.headBlend.shapeFirst, appearance.headBlend.shapeSecond, appearance.headBlend.shapeThird,
                    appearance.headBlend.skinFirst, appearance.headBlend.skinSecond, appearance.headBlend.skinThird,
                    appearance.headBlend.shapeMix, appearance.headBlend.skinMix, appearance.headBlend.thirdMix, false)
            end
            if appearance.components then
                for _, component in ipairs(appearance.components) do
                    SetPedComponentVariation(playerPed, component.component_id, component.drawable, component.texture, 0)
                end
            end
            if appearance.props then
                for _, prop in ipairs(appearance.props) do
                    if prop.drawable == -1 then
                        ClearPedProp(playerPed, prop.prop_id)
                    else
                        SetPedPropIndex(playerPed, prop.prop_id, prop.drawable, prop.texture, true)
                    end
                end
            end
        end
        SetModelAsNoLongerNeeded(model)
    else
        randomPed()
    end
end

---@return CharacterRegistration?
local function characterDialog()
    local nationalityOption = config.characters.limitNationalities and {
        type = 'select',
        required = true,
        icon = 'user-shield',
        label = locale('info.nationality'),
        default = 'American',
        searchable = true,
        options = nationalities
    } or {
        type = 'input',
        required = true,
        icon = 'user-shield',
        label = locale('info.nationality'),
        placeholder = 'Duck'
    }

    return lib.inputDialog(locale('info.character_registration_title'), {
        {
            type = 'input',
            required = true,
            icon = 'user-pen',
            label = locale('info.first_name'),
            placeholder = 'Hank'
        },
        {
            type = 'input',
            required = true,
            icon = 'user-pen',
            label = locale('info.last_name'),
            placeholder = 'Jordan'
        },
        nationalityOption,
        {
            type = 'select',
            required = true,
            icon = 'circle-user',
            label = locale('info.gender'),
            placeholder = locale('info.select_gender'),
            options = {
                {
                    value = locale('info.char_male')
                },
                {
                    value = locale('info.char_female')
                }
            }
        },
        {
            type = 'date',
            required = true,
            icon = 'calendar-days',
            label = locale('info.birth_date'),
            format = config.characters.dateFormat,
            returnString = true,
            min = config.characters.dateMin,
            max = config.characters.dateMax,
            default = config.characters.dateMax
        }
    })
end

---@param dialog string[]
---@param input integer
---@return boolean
local function checkStrings(dialog, input)
    local str = dialog[input]
    if config.characters.profanityWords[str:lower()] then return false end

    local split = {string.strsplit(' ', str)}
    if #split > 5 then return false end

    for i = 1, #split do
        local word = split[i]
        if config.characters.profanityWords[word:lower()] then return false end
    end

    return true
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
    -- Appearance menu is now handled during character creation, not here
end

local function spawnLastLocation()
    DoScreenFadeOut(500)

    while not IsScreenFadedOut() do
        Wait(0)
    end

    destroyPreviewCam()

    pcall(function() exports.spawnmanager:spawnPlayer({
        x = QBX.PlayerData.position.x,
        y = QBX.PlayerData.position.y,
        z = QBX.PlayerData.position.z,
        heading = QBX.PlayerData.position.w
    }) end)

    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
    TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)

    while not IsScreenFadedIn() do
        Wait(0)
    end
end

-- Track if appearance is being customized
local isCustomizingAppearance = false
local appearanceCompleted = false

-- Event handler for appearance completion
RegisterNetEvent('qbx_core:client:appearanceCompleted', function()
    appearanceCompleted = true
    isCustomizingAppearance = false
end)

-- Event handler for appearance cancellation
RegisterNetEvent('qbx_core:client:appearanceCancelled', function()
    appearanceCompleted = false
    isCustomizingAppearance = false
end)

---@param cid integer
---@return boolean
local function createCharacter(cid)
    previewPed()

    :: noMatch ::

    local dialog = characterDialog()

    if not dialog then return false end

    for input = 1, 3 do -- Run through first 3 inputs, aka first name, last name and nationality
        if not checkStrings(dialog, input) then
            Notify(locale('error.no_match_character_registration'), 'error', 10000)
            goto noMatch
            break
        end
    end

    DoScreenFadeOut(150)
    local newData = lib.callback.await('qbx_core:server:createCharacter', false, {
        firstname = capString(dialog[1]),
        lastname = capString(dialog[2]),
        nationality = capString(dialog[3]),
        gender = dialog[4] == locale('info.char_male') and 0 or 1,
        birthdate = dialog[5],
        cid = cid
    })

    if not newData then return false end

    -- Wait for fade out to complete
    while not IsScreenFadedOut() do
        Wait(0)
    end

    -- Destroy preview cam before appearance menu
    destroyPreviewCam()

    -- Determine gender for appearance system
    local gender = dialog[4] == locale('info.char_male') and 'Male' or 'Female'
    
    -- Wait a moment for character data to be fully loaded
    Wait(1000)
    
    -- Trigger the appearance creation event (illenium-appearance listens for this)
    if GetResourceState('illenium-appearance') == 'started' then
        -- Fade in screen before opening appearance menu
        DoScreenFadeIn(500)
        Wait(500)
        
        -- Set flag to track appearance customization
        isCustomizingAppearance = true
        appearanceCompleted = false
        
        -- Trigger appearance menu - it will handle its own completion
        TriggerEvent('qb-clothes:client:CreateFirstCharacter')
        
        -- Wait for appearance to be completed (with reasonable timeout)
        local timeout = 0
        local maxTimeout = 600000 -- 10 minute timeout
        while isCustomizingAppearance and timeout < maxTimeout do
            Wait(100)
            timeout = timeout + 100
        end
        
        -- Wait a bit more to ensure appearance menu UI is fully closed
        Wait(1000)
        
        -- Ensure appearance menu is closed before proceeding
        -- Force close any open NUI if still open (illenium-appearance should handle this, but just in case)
        SetNuiFocus(false, false)
        Wait(500)
    else
        -- If illenium-appearance is not available, fade in and proceed to spawn
        DoScreenFadeIn(500)
        Wait(1000)
    end
    
    -- Ensure screen is faded in before spawning
    if not IsScreenFadedIn() then
        DoScreenFadeIn(500)
        while not IsScreenFadedIn() do
            Wait(0)
        end
    end
    
    -- Now proceed with spawn logic (only after appearance menu is closed)
    if GetResourceState('lSpawnSelector') == 'started' then
        -- Small delay to ensure appearance menu is fully closed
        Wait(500)
        TriggerEvent('spawnselector:open')
    elseif GetResourceState('qbx_spawn') == 'missing' then
        spawnDefault()
    else
        if config.characters.startingApartment then
            TriggerEvent('apartments:client:setupSpawnUI', newData)
        else
            TriggerEvent('qbx_core:client:spawnNoApartments')
        end
    end

    return true
end

local function chooseCharacter()
    ---@type PlayerEntity[], integer
    local characters, amount = lib.callback.await('qbx_core:server:getCharacters')
    local firstCharacterCitizenId = characters[1] and characters[1].citizenid
    previewPed(firstCharacterCitizenId)

    randomLocation = config.characters.locations[math.random(1, #config.characters.locations)]
    SetFollowPedCamViewMode(2)
    DisplayRadar(false)

    DoScreenFadeOut(500)

    while not IsScreenFadedOut() and cache.ped ~= PlayerPedId()  do
        Wait(0)
    end

    FreezeEntityPosition(cache.ped, true)
    Wait(1000)
    SetEntityCoords(cache.ped, randomLocation.pedCoords.x, randomLocation.pedCoords.y, randomLocation.pedCoords.z, false, false, false, false)
    SetEntityHeading(cache.ped, randomLocation.pedCoords.w)

    NetworkStartSoloTutorialSession()

    while not NetworkIsInTutorialSession() do
        Wait(0)
    end

    Wait(1500)
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    setupPreviewCam()

    local options = {}
    for i = 1, amount do
        local character = characters[i]
        local name = character and ('%s %s'):format(character.charinfo.firstname, character.charinfo.lastname)
        options[i] = {
            title = character and ('%s %s - %s'):format(character.charinfo.firstname, character.charinfo.lastname, character.citizenid) or locale('info.multichar_new_character', i),
            metadata = character and {
                Name = name,
                Gender = character.charinfo.gender == 0 and locale('info.char_male') or locale('info.char_female'),
                Birthdate = character.charinfo.birthdate,
                Nationality = character.charinfo.nationality,
                ['Account Number'] = character.charinfo.account,
                Bank = lib.math.groupdigits(character.money.bank),
                Cash = lib.math.groupdigits(character.money.cash),
                Job = character.job.label,
                ['Job Grade'] = character.job.grade.name,
                Gang = character.gang.label,
                ['Gang Grade'] = character.gang.grade.name,
                ['Phone Number'] = character.charinfo.phone
            } or nil,
            icon = 'user',
            onSelect = function()
                if character then
                    lib.showContext('qbx_core_multichar_character_'..i)
                    previewPed(character.citizenid)
                else
                    local success = createCharacter(i)
                    if success then return end

                    previewPed(firstCharacterCitizenId)
                    lib.showContext('qbx_core_multichar_characters')
                end
            end
        }

        if character then
            lib.registerContext({
                id = 'qbx_core_multichar_character_'..i,
                title = ('%s %s - %s'):format(character.charinfo.firstname, character.charinfo.lastname, character.citizenid),
                canClose = false,
                menu = 'qbx_core_multichar_characters',
                options = {
                    {
                        title = locale('info.play'),
                        description = locale('info.play_description', name),
                        icon = 'play',
                        onSelect = function()
                            DoScreenFadeOut(10)
                            lib.callback.await('qbx_core:server:loadCharacter', false, character.citizenid)
                            if GetResourceState('lSpawnSelector') == 'started' then
                                TriggerEvent('spawnselector:open')
                            elseif GetResourceState('qbx_apartments'):find('start') then
                                TriggerEvent('apartments:client:setupSpawnUI', character.citizenid)
                            elseif GetResourceState('qbx_spawn'):find('start') then
                                TriggerEvent('qb-spawn:client:setupSpawns', character.citizenid)
                                TriggerEvent('qb-spawn:client:openUI', true)
                            else
                                spawnLastLocation()
                            end
                            destroyPreviewCam()
                        end
                    },
                    config.characters.enableDeleteButton and {
                        title = locale('info.delete_character'),
                        description = locale('info.delete_character_description', name),
                        icon = 'trash',
                        onSelect = function()
                            local alert = lib.alertDialog({
                                header = locale('info.delete_character'),
                                content = locale('info.confirm_delete'),
                                centered = true,
                                cancel = true
                            })
                            if alert == 'confirm' then
                                local success = lib.callback.await('qbx_core:server:deleteCharacter', false, character.citizenid)
                                Notify(success and locale('success.character_deleted') or locale('error.character_delete_failed'), success and 'success' or 'error')

                                destroyPreviewCam()
                                chooseCharacter()
                            else
                                lib.showContext('qbx_core_multichar_character_'..i)
                            end
                        end
                    } or nil
                }
            })
        end
    end

    lib.registerContext({
        id = 'qbx_core_multichar_characters',
        title = locale('info.multichar_title'),
        canClose = false,
        options = options
    })

    SetTimecycleModifier('default')
    lib.showContext('qbx_core_multichar_characters')
end

RegisterNetEvent('qbx_core:client:spawnNoApartments', function() -- This event is only for no starting apartments
    DoScreenFadeOut(500)
    Wait(2000)
    SetEntityCoords(cache.ped, defaultSpawn.x, defaultSpawn.y, defaultSpawn.z, false, false, false, false)
    SetEntityHeading(cache.ped, defaultSpawn.w)
    Wait(500)
    destroyPreviewCam()
    SetEntityVisible(cache.ped, true, false)
    Wait(500)
    DoScreenFadeIn(250)
    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
    TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
    TriggerEvent('qb-weathersync:client:EnableSync')
    -- Appearance menu is now handled during character creation, not here
end)

RegisterNetEvent('qbx_core:client:playerLoggedOut', function()
    if GetInvokingResource() then return end -- Make sure this can only be triggered from the server
    chooseCharacter()
end)

CreateThread(function()
    while true do
        Wait(0)
        if NetworkIsSessionStarted() then
            pcall(function() exports.spawnmanager:setAutoSpawn(false) end)
            Wait(250)
            chooseCharacter()
            break
        end
    end
    -- since people apparently die during char select. Since SetEntityInvincible is notoriously unreliable, we'll just loop it to be safe. shrug
    while NetworkIsInTutorialSession() do
        SetEntityInvincible(PlayerPedId(), true)
        Wait(250)
    end
    SetEntityInvincible(PlayerPedId(), false)
end)