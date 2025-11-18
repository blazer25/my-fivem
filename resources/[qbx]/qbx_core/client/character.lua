local config = require 'config.client'
local defaultSpawn = require 'config.shared'.defaultSpawn

if config.characters.useExternalCharacters then return end

local previewCam
local randomLocation = config.characters.locations[math.random(1, #config.characters.locations)]

-- randomPeds removed - ByteLabs handles all appearance

-- NetworkStartSoloTutorialSession() -- Disabled for ByteLabs compatibility

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
    SetCamUseShallowDofMode(previewCam, false)
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

-- previewPed and randomPed removed - ByteLabs handles all appearance

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
    -- Check if fivem-appearance resource is ready
    local appearanceState = GetResourceState('fivem-appearance')
    if appearanceState ~= 'started' then
        print('[qbx_core] ERROR: fivem-appearance resource is not started. Current state: ' .. (appearanceState or 'missing'))
        -- Wait for resource to be ready
        while GetResourceState('fivem-appearance') ~= 'started' do
            Wait(100)
        end
    end

    DoScreenFadeOut(500)

    while not IsScreenFadedOut() do
        Wait(0)
    end

    destroyPreviewCam()

    -- Manually set player position instead of using spawnPlayer to avoid setting default model
    local ped = PlayerPedId()
    SetEntityCoordsNoOffset(ped, defaultSpawn.x, defaultSpawn.y, defaultSpawn.z, false, false, false)
    SetEntityHeading(ped, defaultSpawn.w)
    NetworkResurrectLocalPlayer(defaultSpawn.x, defaultSpawn.y, defaultSpawn.z, defaultSpawn.w, true, true)
    
    -- Wait a brief moment for position to be set
    Wait(200)

    -- Open fivem-appearance creator using startPlayerCustomization with callback
    -- This is the correct export for fivem-appearance (not startPlayerCreator)
    local success, err = pcall(function()
        exports['fivem-appearance']:startPlayerCustomization(function(appearance)
            -- This callback runs when the creator is closed (either saved or cancelled)
            if appearance then
                -- Character was saved - save appearance to server if needed
                -- fivem-appearance already applied it to the ped
                print('[qbx_core] Character appearance saved')
            else
                -- Character was cancelled - appearance was reverted
                print('[qbx_core] Character customization cancelled')
            end
            
            -- Unfreeze player after creator closes
            FreezeEntityPosition(ped, false)
            SetEntityInvincible(ped, false)
            
            -- Fade in after creator closes
            DoScreenFadeIn(500)
            while not IsScreenFadedIn() do
                Wait(0)
            end
            
            -- Load player data after character creation is complete
            TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
            TriggerEvent('QBCore:Client:OnPlayerLoaded')
            TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
            TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
        end)
    end)
    
    if not success then
        print('[qbx_core] ERROR: Failed to open fivem-appearance creator: ' .. tostring(err))
        print('[qbx_core] Make sure fivem-appearance is properly installed and exports are available')
        FreezeEntityPosition(ped, false)
        SetEntityInvincible(ped, false)
        DoScreenFadeIn(500)
        TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
        TriggerEvent('QBCore:Client:OnPlayerLoaded')
    end
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

---@param cid integer
---@return boolean
local function createCharacter(cid)
    -- previewPed removed - ByteLabs handles appearance

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

    if GetResourceState('lSpawnSelector') == 'started' then
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

    destroyPreviewCam()
    return true
end

local function chooseCharacter()
    ---@type PlayerEntity[], integer
    local characters, amount = lib.callback.await('qbx_core:server:getCharacters')
    local firstCharacterCitizenId = characters[1] and characters[1].citizenid

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
    SetEntityVisible(cache.ped, true, false)

    -- NetworkStartSoloTutorialSession() -- Disabled for ByteLabs compatibility

    -- while not NetworkIsInTutorialSession() do
    --     Wait(0)
    -- end

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
                    -- previewPed removed - ByteLabs handles appearance
                else
                    local success = createCharacter(i)
                    if success then return end

                    -- previewPed removed - ByteLabs handles appearance
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
    -- Check if fivem-appearance resource is ready
    local appearanceState = GetResourceState('fivem-appearance')
    if appearanceState ~= 'started' then
        print('[qbx_core] ERROR: fivem-appearance resource is not started. Current state: ' .. (appearanceState or 'missing'))
        -- Wait for resource to be ready
        while GetResourceState('fivem-appearance') ~= 'started' do
            Wait(100)
        end
    end

    DoScreenFadeOut(500)
    Wait(2000)
    
    local ped = cache.ped or PlayerPedId()
    SetEntityCoordsNoOffset(ped, defaultSpawn.x, defaultSpawn.y, defaultSpawn.z, false, false, false)
    SetEntityHeading(ped, defaultSpawn.w)
    NetworkResurrectLocalPlayer(defaultSpawn.x, defaultSpawn.y, defaultSpawn.z, defaultSpawn.w, true, true)
    
    Wait(500)
    destroyPreviewCam()
    SetEntityVisible(ped, true, false)
    Wait(500)

    -- Open fivem-appearance creator using startPlayerCustomization with callback
    -- This is the correct export for fivem-appearance (not startPlayerCreator)
    local success, err = pcall(function()
        exports['fivem-appearance']:startPlayerCustomization(function(appearance)
            -- This callback runs when the creator is closed (either saved or cancelled)
            if appearance then
                -- Character was saved - save appearance to server if needed
                -- fivem-appearance already applied it to the ped
                print('[qbx_core] Character appearance saved')
            else
                -- Character was cancelled - appearance was reverted
                print('[qbx_core] Character customization cancelled')
            end
            
            -- Unfreeze player after creator closes
            FreezeEntityPosition(ped, false)
            SetEntityInvincible(ped, false)
            
            -- Fade in after creator closes
            DoScreenFadeIn(250)
            while not IsScreenFadedIn() do
                Wait(0)
            end
            
            TriggerEvent('qb-weathersync:client:EnableSync')
            TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
            TriggerEvent('QBCore:Client:OnPlayerLoaded')
            TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
            TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
        end)
    end)
    
    if not success then
        print('[qbx_core] ERROR: Failed to open fivem-appearance creator: ' .. tostring(err))
        print('[qbx_core] Make sure fivem-appearance is properly installed and exports are available')
        FreezeEntityPosition(ped, false)
        SetEntityInvincible(ped, false)
        DoScreenFadeIn(250)
        TriggerEvent('qb-weathersync:client:EnableSync')
        TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
        TriggerEvent('QBCore:Client:OnPlayerLoaded')
    end
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
    -- Tutorial session disabled for ByteLabs compatibility
    -- while NetworkIsInTutorialSession() do
    --     SetEntityInvincible(PlayerPedId(), true)
    --     Wait(250)
    -- end
    -- SetEntityInvincible(PlayerPedId(), false)
end)