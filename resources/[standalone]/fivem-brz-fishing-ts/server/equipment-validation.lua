-- Equipment Validation System
-- Checks if player has required level for equipment usage

---@param source number
---@param itemName string
---@return boolean canUse, string|nil errorMessage
local function canUseEquipment(source, itemName)
    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then return false, 'Player not found' end
    
    local item = exports.ox_inventory:Items()[itemName]
    if not item then return false, 'Item not found' end
    
    -- Check if item has level requirements
    if not item.metadata or not item.metadata.required_level then
        return true, nil -- No level requirement
    end
    
    -- Get required area and level
    local requiredArea = item.metadata.fishing_area
    local requiredLevel = item.metadata.required_level
    
    if not requiredLevel then
        return true, nil -- No level requirement
    end
    
    -- Get player's area level
    local playerLevel = 1
    if requiredArea then
        playerLevel = exports['fivem-brz-fishing-ts']:GetPlayerAreaLevel(source, requiredArea)
    else
        -- If no area specified, check all areas and use highest
        local riverLevel = exports['fivem-brz-fishing-ts']:GetPlayerAreaLevel(source, 'river')
        local lakeLevel = exports['fivem-brz-fishing-ts']:GetPlayerAreaLevel(source, 'lake')
        local seaLevel = exports['fivem-brz-fishing-ts']:GetPlayerAreaLevel(source, 'sea')
        playerLevel = math.max(riverLevel, lakeLevel, seaLevel)
    end
    
    if playerLevel < requiredLevel then
        local areaText = requiredArea and string.format(' %s', requiredArea:upper()) or ''
        return false, string.format('Requires%s Level %d (You are Level %d)', areaText, requiredLevel, playerLevel)
    end
    
    return true, nil
end

---@param source number
---@param itemName string
---@return boolean
function ValidateEquipmentUsage(source, itemName)
    local canUse, errorMsg = canUseEquipment(source, itemName)
    
    if not canUse and errorMsg then
        lib.notify(source, {
            title = 'Equipment Locked',
            description = errorMsg,
            type = 'error'
        })
    end
    
    return canUse
end

-- Export
exports('ValidateEquipmentUsage', ValidateEquipmentUsage)
exports('CanUseEquipment', canUseEquipment)

