-- Clothing/EUP Loader - Client Script
-- Provides debugging and validation for loaded clothing

local clothingLoader = {}

-- Debug mode (set to false in production)
local DEBUG_MODE = false

-- Clothing validation cache
local validatedClothing = {
    male = {},
    female = {}
}

-- Initialize clothing loader
CreateThread(function()
    Wait(5000) -- Wait for other resources to load
    
    if DEBUG_MODE then
        print("^2[Clothing Loader]^7 Initializing clothing validation...")
        ValidateLoadedClothing()
    end
end)

-- Validate loaded clothing components
function ValidateLoadedClothing()
    local playerPed = PlayerPedId()
    local originalModel = GetEntityModel(playerPed)
    
    -- Test male freemode
    RequestModel(`mp_m_freemode_01`)
    while not HasModelLoaded(`mp_m_freemode_01`) do
        Wait(100)
    end
    
    SetPlayerModel(PlayerId(), `mp_m_freemode_01`)
    Wait(1000)
    
    ValidateComponentsForGender('male')
    
    -- Test female freemode
    RequestModel(`mp_f_freemode_01`)
    while not HasModelLoaded(`mp_f_freemode_01`) do
        Wait(100)
    end
    
    SetPlayerModel(PlayerId(), `mp_f_freemode_01`)
    Wait(1000)
    
    ValidateComponentsForGender('female')
    
    -- Restore original model
    if originalModel ~= `mp_m_freemode_01` and originalModel ~= `mp_f_freemode_01` then
        RequestModel(originalModel)
        while not HasModelLoaded(originalModel) do
            Wait(100)
        end
        SetPlayerModel(PlayerId(), originalModel)
    end
    
    print("^2[Clothing Loader]^7 Validation complete!")
end

-- Validate components for specific gender
function ValidateComponentsForGender(gender)
    local playerPed = PlayerPedId()
    local validComponents = {}
    
    -- Test each component type (0-11)
    for componentId = 0, 11 do
        local maxDrawables = GetNumberOfPedDrawableVariations(playerPed, componentId)
        validComponents[componentId] = {
            maxDrawables = maxDrawables,
            textures = {}
        }
        
        -- Test textures for each drawable
        for drawable = 0, math.min(maxDrawables - 1, 50) do -- Limit to 50 for performance
            local maxTextures = GetNumberOfPedTextureVariations(playerPed, componentId, drawable)
            validComponents[componentId].textures[drawable] = maxTextures
        end
    end
    
    validatedClothing[gender] = validComponents
    
    if DEBUG_MODE then
        print(string.format("^3[Clothing Loader]^7 %s components validated:", gender:upper()))
        for componentId, data in pairs(validComponents) do
            print(string.format("  Component %d: %d drawables", componentId, data.maxDrawables))
        end
    end
end

-- Export function to get validated clothing data
exports('GetValidatedClothing', function()
    return validatedClothing
end)

-- Export function to check if clothing is valid
exports('IsClothingValid', function(gender, componentId, drawable, texture)
    if not validatedClothing[gender] or not validatedClothing[gender][componentId] then
        return false
    end
    
    local component = validatedClothing[gender][componentId]
    if drawable >= component.maxDrawables then
        return false
    end
    
    if component.textures[drawable] and texture >= component.textures[drawable] then
        return false
    end
    
    return true
end)

-- Command to manually validate clothing (admin only)
RegisterCommand('validateclothing', function(source, args, rawCommand)
    if DEBUG_MODE then
        ValidateLoadedClothing()
        TriggerEvent('chat:addMessage', {
            color = {0, 255, 0},
            multiline = true,
            args = {"Clothing Loader", "Validation complete! Check console for details."}
        })
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"Clothing Loader", "Debug mode is disabled."}
        })
    end
end, false)

-- Event handler for appearance system integration
RegisterNetEvent('clothing_loader:applyOutfit', function(outfitData)
    local playerPed = PlayerPedId()
    
    if outfitData.components then
        for componentId, data in pairs(outfitData.components) do
            if IsClothingValid(outfitData.gender or 'male', componentId, data.drawable, data.texture) then
                SetPedComponentVariation(playerPed, componentId, data.drawable, data.texture, 0)
            else
                if DEBUG_MODE then
                    print(string.format("^1[Clothing Loader]^7 Invalid clothing: Component %d, Drawable %d, Texture %d", 
                        componentId, data.drawable, data.texture))
                end
            end
        end
    end
    
    if outfitData.props then
        for propId, data in pairs(outfitData.props) do
            if data.drawable ~= -1 then
                SetPedPropIndex(playerPed, propId, data.drawable, data.texture, true)
            else
                ClearPedProp(playerPed, propId)
            end
        end
    end
end)

-- Integration with illenium-appearance
CreateThread(function()
    Wait(5000) -- Wait for illenium-appearance to fully load
    
    if GetResourceState('illenium-appearance') == 'started' then
        -- Check if the export exists before trying to use it
        local success, result = pcall(function()
            return exports['illenium-appearance']
        end)
        
        if success and result then
            if DEBUG_MODE then
                print("^2[Clothing Loader]^7 Successfully integrated with illenium-appearance")
            end
        end
    end
end)
