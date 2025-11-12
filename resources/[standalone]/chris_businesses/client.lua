-- ============================================
-- Chris Businesses - Client Logic
-- Dynamic Player-Owned Business System
-- ============================================

local isUIOpen = false
local currentBusinessId = nil
local businessBlips = {}
local businessZones = {}

-- Helper: Format number with commas
local function FormatNumber(num)
    if not num then return '0' end
    local formatted = tostring(num)
    local k
    while true do
        formatted, k = string.gsub(formatted, '^(-?%d+)(%d%d%d)', '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

-- Initialize businesses on resource start
CreateThread(function()
    Wait(2000)
    RefreshBusinesses()
    
    -- Ensure NUI is not focused on start
    SetNuiFocus(false, false)
end)

-- Refresh all businesses from server
function RefreshBusinesses()
    local businesses = lib.callback.await('chris_businesses:getBusinesses', false)
    if not businesses then return end
    
    -- Remove old blips and zones
    for id, blip in pairs(businessBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    businessBlips = {}
    
    for id, zone in pairs(businessZones) do
        exports.ox_target:removeZone(zone)
    end
    businessZones = {}
    
    -- Create blips and zones for each business
    for _, business in pairs(businesses) do
        if Config.UseBlips then
            CreateBusinessBlip(business)
        end
        CreateBusinessZones(business)
    end
end

-- Create business blip
function CreateBusinessBlip(business)
    local blip = AddBlipForCoord(business.coords.x, business.coords.y, business.coords.z)
    SetBlipSprite(blip, business.blip_sprite or 52)
    SetBlipColour(blip, business.blip_color or 2)
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(business.label)
    EndTextCommandSetBlipName(blip)
    businessBlips[business.id] = blip
end

-- Create business interaction zones
function CreateBusinessZones(business)
    local coords = business.coords
    
    -- Laptop/Management Zone
    local laptopZone = exports.ox_target:addBoxZone({
        coords = vector3(coords.x, coords.y, coords.z),
        size = vector3(1.5, 1.5, 2.0),
        rotation = 0,
        debug = Config.Debug,
        options = {
            {
                name = 'business_laptop_' .. business.id,
                icon = Config.Interactions.laptop.icon,
                label = Config.Interactions.laptop.label,
                distance = Config.Interactions.laptop.distance,
                onSelect = function()
                    OpenBusinessDashboard(business.id)
                end
            }
        }
    })
    businessZones['laptop_' .. business.id] = laptopZone
    
    -- Shop Zone (if business is open and has owner)
    if business.owner_identifier and business.is_open then
        local shopZone = exports.ox_target:addBoxZone({
            coords = vector3(coords.x, coords.y, coords.z),
            size = vector3(2.0, 2.0, 2.0),
            rotation = 0,
            debug = Config.Debug,
            options = {
                {
                    name = 'business_shop_' .. business.id,
                    icon = Config.Interactions.shop.icon,
                    label = Config.Interactions.shop.label,
                    distance = Config.Interactions.shop.distance,
                    onSelect = function()
                        OpenBusinessShop(business.id)
                    end
                }
            }
        })
        businessZones['shop_' .. business.id] = shopZone
    end
end

-- Open business dashboard
function OpenBusinessDashboard(businessId)
    if isUIOpen then
        lib.notify({
            title = 'Business System',
            description = 'Dashboard is already open',
            type = 'error'
        })
        return
    end
    
    -- Request business data from server
    local business = lib.callback.await('chris_businesses:getBusiness', false, businessId)
    
    currentBusinessId = businessId
    isUIOpen = true
    
    -- Open NUI (even if business is nil, so player can close it)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openDashboard',
        data = business -- Can be nil, React will handle it
    })
    
    -- If no business data, show error after a moment
    if not business then
        Wait(500)
        lib.notify({
            title = 'Business System',
            description = 'Unable to load business data. Press ESC to close.',
            type = 'error'
        })
    end
end

-- Close business dashboard
function CloseBusinessDashboard()
    if not isUIOpen then return end
    
    isUIOpen = false
    currentBusinessId = nil
    SetNuiFocus(false, false)
    
    SendNUIMessage({
        action = 'closeDashboard'
    })
end

-- Open business shop (for customers)
function OpenBusinessShop(businessId)
    local business = lib.callback.await('chris_businesses:getBusiness', false, businessId)
    if not business then
        lib.notify({
            title = 'Business System',
            description = 'Unable to load business data',
            type = 'error'
        })
        return
    end
    
    if not business.is_open then
        lib.notify({
            title = 'Business System',
            description = 'This business is currently closed',
            type = 'error'
        })
        return
    end
    
    -- Open shop NUI (simplified - would need separate shop UI)
    lib.notify({
        title = 'Business System',
        description = 'Shop interface coming soon',
        type = 'info'
    })
end

-- Handle business laptop item usage
exports('useBusinessLaptop', function()
    -- Get nearby businesses
    local playerCoords = GetEntityCoords(cache.ped)
    local businesses = lib.callback.await('chris_businesses:getBusinesses', false)
    
    if not businesses or #businesses == 0 then
        lib.notify({
            title = 'Business System',
            description = 'No businesses found in database. Add a business first!',
            type = 'error'
        })
        return
    end
    
    -- Find nearest business (increased distance to 50.0 units)
    local nearestBusiness = nil
    local nearestDistance = 999999.0
    local nearestDistanceValue = 999999.0
    
    for _, business in pairs(businesses) do
        if business.coords and business.coords.x and business.coords.y and business.coords.z then
            local distance = #(playerCoords - vector3(business.coords.x, business.coords.y, business.coords.z))
            if distance < nearestDistanceValue then
                nearestDistanceValue = distance
                nearestBusiness = business
                nearestDistance = distance
            end
        end
    end
    
    -- If within 50 units, open dashboard
    if nearestBusiness and nearestDistance < 50.0 then
        OpenBusinessDashboard(nearestBusiness.id)
    else
        -- Show business selection menu if not near any
        local options = {}
        for _, business in pairs(businesses) do
            if business.coords and business.coords.x then
                local distance = #(playerCoords - vector3(business.coords.x, business.coords.y, business.coords.z))
                table.insert(options, {
                    title = business.label or business.name,
                    description = string.format('ID: %s | Distance: %.1fm | Price: $%s', 
                        business.id, 
                        distance, 
                        FormatNumber(business.price or 0)),
                    onSelect = function()
                        OpenBusinessDashboard(business.id)
                    end
                })
            end
        end
        
        if #options > 0 then
            lib.registerContext({
                id = 'business_list',
                title = 'Business List',
                options = options
            })
            lib.showContext('business_list')
        else
            lib.notify({
                title = 'Business System',
                description = string.format('No businesses found. Nearest is %.1fm away. Use /openbusiness [id] to open directly.', nearestDistance or 0),
                type = 'error'
            })
        end
    end
end)

-- NUI Callbacks
RegisterNUICallback('closeDashboard', function(data, cb)
    CloseBusinessDashboard()
    cb('ok')
end)

RegisterNUICallback('getBusiness', function(data, cb)
    local businessId = data.businessId or currentBusinessId
    if not businessId then
        cb({success = false, error = 'No business ID provided'})
        return
    end
    
    local business = lib.callback.await('chris_businesses:getBusiness', false, businessId)
    cb({success = true, data = business})
end)

RegisterNUICallback('purchaseBusiness', function(data, cb)
    local businessId = data.businessId
    if not businessId then
        cb({success = false, error = 'No business ID provided'})
        return
    end
    
    local success, message = lib.callback.await('chris_businesses:purchaseBusiness', false, businessId)
    if success then
        lib.notify({
            title = 'Business System',
            description = message,
            type = 'success'
        })
        RefreshBusinesses()
    else
        lib.notify({
            title = 'Business System',
            description = message,
            type = 'error'
        })
    end
    
    cb({success = success, message = message})
end)

RegisterNUICallback('sellBusiness', function(data, cb)
    local businessId = data.businessId
    local price = data.price
    
    if not businessId then
        cb({success = false, error = 'No business ID provided'})
        return
    end
    
    local success, message = lib.callback.await('chris_businesses:sellBusiness', false, businessId, price)
    if success then
        lib.notify({
            title = 'Business System',
            description = message,
            type = 'success'
        })
        RefreshBusinesses()
    else
        lib.notify({
            title = 'Business System',
            description = message,
            type = 'error'
        })
    end
    
    cb({success = success, message = message})
end)

RegisterNUICallback('hireEmployee', function(data, cb)
    local businessId = data.businessId
    local citizenid = data.citizenid
    local role = data.role or 'employee'
    
    if not businessId or not citizenid then
        cb({success = false, error = 'Missing required data'})
        return
    end
    
    local success, message = lib.callback.await('chris_businesses:hireEmployee', false, businessId, citizenid, role)
    if success then
        lib.notify({
            title = 'Business System',
            description = message,
            type = 'success'
        })
    else
        lib.notify({
            title = 'Business System',
            description = message,
            type = 'error'
        })
    end
    
    cb({success = success, message = message})
end)

RegisterNUICallback('fireEmployee', function(data, cb)
    local businessId = data.businessId
    local citizenid = data.citizenid
    
    if not businessId or not citizenid then
        cb({success = false, error = 'Missing required data'})
        return
    end
    
    local success, message = lib.callback.await('chris_businesses:fireEmployee', false, businessId, citizenid)
    if success then
        lib.notify({
            title = 'Business System',
            description = message,
            type = 'success'
        })
    else
        lib.notify({
            title = 'Business System',
            description = message,
            type = 'error'
        })
    end
    
    cb({success = success, message = message})
end)

RegisterNUICallback('updateSettings', function(data, cb)
    local businessId = data.businessId
    local settings = data.settings
    
    if not businessId or not settings then
        cb({success = false, error = 'Missing required data'})
        return
    end
    
    local success, message = lib.callback.await('chris_businesses:updateSettings', false, businessId, settings)
    if success then
        lib.notify({
            title = 'Business System',
            description = message,
            type = 'success'
        })
        RefreshBusinesses()
    else
        lib.notify({
            title = 'Business System',
            description = message,
            type = 'error'
        })
    end
    
    cb({success = success, message = message})
end)

RegisterNUICallback('depositMoney', function(data, cb)
    local businessId = data.businessId
    local amount = tonumber(data.amount)
    
    if not businessId or not amount or amount <= 0 then
        cb({success = false, error = 'Invalid amount'})
        return
    end
    
    local success, message = lib.callback.await('chris_businesses:depositMoney', false, businessId, amount)
    if success then
        lib.notify({
            title = 'Business System',
            description = message,
            type = 'success'
        })
    else
        lib.notify({
            title = 'Business System',
            description = message,
            type = 'error'
        })
    end
    
    cb({success = success, message = message})
end)

RegisterNUICallback('withdrawMoney', function(data, cb)
    local businessId = data.businessId
    local amount = tonumber(data.amount)
    
    if not businessId or not amount or amount <= 0 then
        cb({success = false, error = 'Invalid amount'})
        return
    end
    
    local success, message = lib.callback.await('chris_businesses:withdrawMoney', false, businessId, amount)
    if success then
        lib.notify({
            title = 'Business System',
            description = message,
            type = 'success'
        })
    else
        lib.notify({
            title = 'Business System',
            description = message,
            type = 'error'
        })
    end
    
    cb({success = success, message = message})
end)

-- Commands
RegisterCommand('buybusiness', function(source, args)
    local businessId = tonumber(args[1])
    if not businessId then
        lib.notify({
            title = 'Business System',
            description = 'Usage: /buybusiness [id]',
            type = 'error'
        })
        return
    end
    
    OpenBusinessDashboard(businessId)
end, false)

RegisterCommand('sellbusiness', function(source, args)
    local businessId = tonumber(args[1])
    local price = tonumber(args[2])
    
    if not businessId then
        lib.notify({
            title = 'Business System',
            description = 'Usage: /sellbusiness [id] [price]',
            type = 'error'
        })
        return
    end
    
    if price and price > 0 then
        local success, message = lib.callback.await('chris_businesses:sellBusiness', false, businessId, price)
        if success then
            lib.notify({
                title = 'Business System',
                description = message,
                type = 'success'
            })
        else
            lib.notify({
                title = 'Business System',
                description = message,
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'Business System',
            description = 'Please provide a valid price',
            type = 'error'
        })
    end
end, false)

RegisterCommand('openbusiness', function(source, args)
    local businessId = tonumber(args[1])
    if not businessId then
        -- Show list of all businesses if no ID provided
        local businesses = lib.callback.await('chris_businesses:getBusinesses', false)
        if not businesses or #businesses == 0 then
            lib.notify({
                title = 'Business System',
                description = 'No businesses found. Add a business to the database first!',
                type = 'error'
            })
            return
        end
        
        local options = {}
        for _, business in pairs(businesses) do
            table.insert(options, {
                title = business.label or business.name,
                description = string.format('ID: %s | Type: %s | Price: $%s | %s', 
                    business.id,
                    business.business_type or 'general',
                    FormatNumber(business.price or 0),
                    business.for_sale and 'For Sale' or 'Owned'
                ),
                onSelect = function()
                    OpenBusinessDashboard(business.id)
                end
            })
        end
        
        lib.registerContext({
            id = 'business_list_cmd',
            title = 'Select Business',
            options = options
        })
        lib.showContext('business_list_cmd')
        return
    end
    
    OpenBusinessDashboard(businessId)
end, false)

-- Debug command to list all businesses
RegisterCommand('listbusinesses', function()
    local businesses = lib.callback.await('chris_businesses:getBusinesses', false)
    if not businesses or #businesses == 0 then
        print('^1[Business System]^7 No businesses found in database!')
        lib.notify({
            title = 'Business System',
            description = 'No businesses found. Add one to the database!',
            type = 'error'
        })
        return
    end
    
    print('^2[Business System]^7 Found ' .. #businesses .. ' business(es):')
    for _, business in pairs(businesses) do
        print(string.format('^3ID: %s^7 | ^2%s^7 | Coords: %.1f, %.1f, %.1f | Price: $%s', 
            business.id,
            business.label or business.name,
            business.coords and business.coords.x or 0,
            business.coords and business.coords.y or 0,
            business.coords and business.coords.z or 0,
            FormatNumber(business.price or 0)
        ))
    end
end, false)

-- Network Events
RegisterNetEvent('chris_businesses:client:businessUpdated', function(businessId)
    RefreshBusinesses()
end)

RegisterNetEvent('chris_businesses:client:businessRemoved', function(businessId)
    if businessBlips[businessId] then
        if DoesBlipExist(businessBlips[businessId]) then
            RemoveBlip(businessBlips[businessId])
        end
        businessBlips[businessId] = nil
    end
    
    if businessZones['laptop_' .. businessId] then
        exports.ox_target:removeZone(businessZones['laptop_' .. businessId])
        businessZones['laptop_' .. businessId] = nil
    end
    
    if businessZones['shop_' .. businessId] then
        exports.ox_target:removeZone(businessZones['shop_' .. businessId])
        businessZones['shop_' .. businessId] = nil
    end
end)

-- Handle ESC key to close UI (ALWAYS allow ESC to close)
CreateThread(function()
    while true do
        if isUIOpen then
            DisableControlAction(0, 322, true) -- ESC
            DisableControlAction(0, 177, true) -- Backspace
            
            if IsDisabledControlJustPressed(0, 322) or IsControlJustPressed(0, 322) then
                CloseBusinessDashboard()
            end
        end
        Wait(0)
    end
end)

-- Safety: Auto-close if NUI focus is on but dashboard should be closed
CreateThread(function()
    while true do
        Wait(1000)
        if not isUIOpen and IsNuiFocused() then
            -- NUI is focused but dashboard should be closed - release focus
            SetNuiFocus(false, false)
        end
    end
end)

-- Export functions
exports('OpenBusinessDashboard', OpenBusinessDashboard)
exports('CloseBusinessDashboard', CloseBusinessDashboard)
exports('RefreshBusinesses', RefreshBusinesses)

