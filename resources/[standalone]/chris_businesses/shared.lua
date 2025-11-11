-- ============================================
-- Chris Businesses - Shared Logic
-- Framework detection and helper functions
-- ============================================

-- Framework Detection
local Framework = GetResourceState('qbx_core') == 'started' and 'qbx' or GetResourceState('qb-core') == 'started' and 'qb' or 'unknown'

if Framework == 'unknown' then
    print('^1[Chris Businesses]^7 Error: No supported framework detected (qbx_core or qb-core)')
end

-- Framework Functions
FrameworkFunctions = {}

if Framework == 'qbx' then
    FrameworkFunctions.GetPlayer = function(source)
        return exports.qbx_core:GetPlayer(source)
    end
    
    FrameworkFunctions.GetPlayerByCitizenId = function(citizenid)
        return exports.qbx_core:GetPlayerByCitizenId(citizenid)
    end
    
    FrameworkFunctions.GetJobs = function()
        return exports.qbx_core:GetJobs()
    end
    
    FrameworkFunctions.GetGangs = function()
        return exports.qbx_core:GetGangs()
    end
    
    FrameworkFunctions.GetIdentifier = function(Player)
        return Player.PlayerData.citizenid
    end
    
    FrameworkFunctions.GetPlayerName = function(Player)
        return ("%s %s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)
    end
    
    FrameworkFunctions.GetMoney = function(Player, type)
        return Player.PlayerData.money[type] or 0
    end
    
    FrameworkFunctions.AddMoney = function(Player, type, amount, reason)
        Player.Functions.AddMoney(type, amount, reason)
    end
    
    FrameworkFunctions.RemoveMoney = function(Player, type, amount, reason)
        return Player.Functions.RemoveMoney(type, amount, reason)
    end
    
    FrameworkFunctions.HasItem = function(Player, item)
        return exports.ox_inventory:GetItemCount(Player.PlayerData.source, item) > 0
    end
    
elseif Framework == 'qb' then
    local QBCore = exports['qb-core']:GetCoreObject()
    
    FrameworkFunctions.GetPlayer = function(source)
        return QBCore.Functions.GetPlayer(source)
    end
    
    FrameworkFunctions.GetPlayerByCitizenId = function(citizenid)
        return QBCore.Functions.GetPlayerByCitizenId(citizenid)
    end
    
    FrameworkFunctions.GetJobs = function()
        return QBCore.Shared.Jobs
    end
    
    FrameworkFunctions.GetGangs = function()
        return QBCore.Shared.Gangs
    end
    
    FrameworkFunctions.GetIdentifier = function(Player)
        return Player.PlayerData.citizenid
    end
    
    FrameworkFunctions.GetPlayerName = function(Player)
        return ("%s %s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)
    end
    
    FrameworkFunctions.GetMoney = function(Player, type)
        return Player.PlayerData.money[type] or 0
    end
    
    FrameworkFunctions.AddMoney = function(Player, type, amount, reason)
        Player.Functions.AddMoney(type, amount, reason)
    end
    
    FrameworkFunctions.RemoveMoney = function(Player, type, amount, reason)
        return Player.Functions.RemoveMoney(type, amount, reason)
    end
    
    FrameworkFunctions.HasItem = function(Player, item)
        return exports.ox_inventory:GetItemCount(Player.PlayerData.source, item) > 0
    end
end

-- Permission Checking
function HasPermission(business, citizenid, permission)
    if not business or not citizenid then return false end
    
    -- Owner always has all permissions
    if business.owner_identifier == citizenid then
        return true
    end
    
    -- Check employee permissions
    local employees = business.employees or {}
    if type(employees) == 'string' then
        employees = json.decode(employees)
    end
    
    for _, emp in pairs(employees) do
        if emp.citizenid == citizenid then
            local role = emp.role or 'employee'
            local roleConfig = Config.Roles[role]
            if roleConfig and roleConfig.permissions[permission] then
                return true
            end
        end
    end
    
    return false
end

-- Check if player is owner
function IsOwner(business, citizenid)
    if not business or not citizenid then return false end
    return business.owner_identifier == citizenid
end

-- Check if player is employee
function IsEmployee(business, citizenid)
    if not business or not citizenid then return false end
    
    local employees = business.employees or {}
    if type(employees) == 'string' then
        employees = json.decode(employees)
    end
    
    for _, emp in pairs(employees) do
        if emp.citizenid == citizenid then
            return true, emp.role
        end
    end
    
    return false, nil
end

-- Get player role in business
function GetPlayerRole(business, citizenid)
    if IsOwner(business, citizenid) then
        return 'owner'
    end
    
    local isEmp, role = IsEmployee(business, citizenid)
    if isEmp then
        return role
    end
    
    return nil
end

-- Format currency
function FormatCurrency(amount)
    if not amount then return '$0' end
    local formatted = tostring(amount)
    local k
    while true do
        formatted, k = string.gsub(formatted, '^(-?%d+)(%d%d%d)', '%1,%2')
        if k == 0 then break end
    end
    return ('$%s'):format(formatted)
end

-- Validate business data
function ValidateBusinessData(data)
    if not data.name or data.name == '' then
        return false, 'Business name is required'
    end
    
    if not data.coords or not data.coords.x or not data.coords.y or not data.coords.z then
        return false, 'Valid coordinates are required'
    end
    
    if not data.business_type or not Config.BusinessTypes[data.business_type] then
        return false, 'Valid business type is required'
    end
    
    return true, nil
end

