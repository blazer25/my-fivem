-- ============================================
-- Chris Businesses - Server Logic
-- Dynamic Player-Owned Business System
-- ============================================

local cachedBusinesses = {}

-- Initialize database tables
CreateThread(function()
    Wait(1000)
    
    -- Create businesses table
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `chris_businesses` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `name` VARCHAR(100) NOT NULL,
            `label` VARCHAR(100) NOT NULL,
            `owner_identifier` VARCHAR(60) DEFAULT NULL,
            `owner_name` VARCHAR(100) DEFAULT NULL,
            `coords` JSON NOT NULL,
            `stock` JSON DEFAULT NULL,
            `balance` INT DEFAULT 0,
            `price` INT DEFAULT 0,
            `for_sale` BOOLEAN DEFAULT TRUE,
            `employees` JSON DEFAULT NULL,
            `business_type` VARCHAR(50) DEFAULT 'general',
            `blip_sprite` INT DEFAULT 52,
            `blip_color` INT DEFAULT 2,
            `is_open` BOOLEAN DEFAULT TRUE,
            `settings` JSON DEFAULT NULL,
            `interior_coords` JSON DEFAULT NULL,
            `mlo_name` VARCHAR(100) DEFAULT NULL,
            `activity_config` JSON DEFAULT NULL,
            `integration_data` JSON DEFAULT NULL,
            `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX `idx_owner` (`owner_identifier`),
            INDEX `idx_for_sale` (`for_sale`),
            INDEX `idx_business_type` (`business_type`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ]])
    
    -- Create transactions table
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `chris_transactions` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `business_id` INT NOT NULL,
            `type` VARCHAR(50) NOT NULL,
            `amount` INT NOT NULL,
            `description` VARCHAR(255) DEFAULT NULL,
            `citizenid` VARCHAR(60) DEFAULT NULL,
            `metadata` JSON DEFAULT NULL,
            `timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX `idx_business` (`business_id`),
            INDEX `idx_citizenid` (`citizenid`),
            INDEX `idx_timestamp` (`timestamp`),
            FOREIGN KEY (`business_id`) REFERENCES `chris_businesses`(`id`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ]])
    
    -- Create employees table
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `chris_employees` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `business_id` INT NOT NULL,
            `citizenid` VARCHAR(60) NOT NULL,
            `name` VARCHAR(100) NOT NULL,
            `role` VARCHAR(50) NOT NULL DEFAULT 'employee',
            `permissions` JSON DEFAULT NULL,
            `salary` INT DEFAULT 0,
            `hired_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            `last_paid` TIMESTAMP DEFAULT NULL,
            UNIQUE KEY `unique_employee` (`business_id`, `citizenid`),
            INDEX `idx_citizenid` (`citizenid`),
            INDEX `idx_business` (`business_id`),
            FOREIGN KEY (`business_id`) REFERENCES `chris_businesses`(`id`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ]])
    
    -- Load all businesses into cache
    local businesses = MySQL.query.await('SELECT * FROM chris_businesses', {})
    if businesses then
        for _, business in pairs(businesses) do
            if business.coords then
                business.coords = json.decode(business.coords)
            end
            if business.stock then
                business.stock = json.decode(business.stock)
            end
            if business.employees then
                business.employees = json.decode(business.employees)
            end
            if business.settings then
                business.settings = json.decode(business.settings)
            end
            cachedBusinesses[business.id] = business
        end
    end
    
    -- Create Renewed-Banking accounts for existing businesses
    if Config.Banking.Enabled and Config.Banking.AutoCreateAccounts then
        for id, business in pairs(cachedBusinesses) do
            if business.owner_identifier then
                local accountName = Config.Banking.AccountPrefix .. business.id
                CreateBusinessBankAccount(accountName, business.label, business.owner_identifier)
            end
        end
    end
end)

-- Helper: Get Player Object
local function GetPlayer(source)
    return FrameworkFunctions.GetPlayer(source)
end

-- Helper: Get Player Identifier
local function GetIdentifier(source)
    local Player = GetPlayer(source)
    if not Player then return nil end
    return FrameworkFunctions.GetIdentifier(Player)
end

-- Helper: Get Player Name
local function GetPlayerName(source)
    local Player = GetPlayer(source)
    if not Player then return 'Unknown' end
    return FrameworkFunctions.GetPlayerName(Player)
end

-- Helper: Create Business Bank Account
function CreateBusinessBankAccount(accountName, label, ownerCitizenid)
    if not Config.Banking.Enabled then return end
    
    local bankingResource = GetResourceState('Renewed-Banking')
    if bankingResource ~= 'started' then
        if Config.Debug then
            print('^3[Chris Businesses]^7 Renewed-Banking not found, skipping account creation')
        end
        return
    end
    
    -- Check if account exists
    local accountMoney = exports['Renewed-Banking']:getAccountMoney(accountName)
    if accountMoney == false then
        -- Create new account
        TriggerEvent('Renewed-Banking:server:createNewAccount', accountName)
        Wait(100)
    end
end

-- Helper: Get Business Bank Account Name
local function GetBusinessAccountName(businessId)
    return Config.Banking.AccountPrefix .. businessId
end

-- Helper: Log Transaction
local function LogTransaction(businessId, transactionType, amount, description, citizenid, metadata)
    MySQL.insert('INSERT INTO chris_transactions (business_id, type, amount, description, citizenid, metadata) VALUES (?, ?, ?, ?, ?, ?)', {
        businessId,
        transactionType,
        amount,
        description,
        citizenid,
        json.encode(metadata or {})
    })
end

-- Helper: Send Discord Webhook
local function SendWebhook(title, description, color)
    if not Config.Webhook.Enabled or Config.Webhook.Url == '' then return end
    
    local embed = {
        {
            title = title,
            description = description,
            color = color or Config.Webhook.Color,
            footer = {
                text = Config.Webhook.Footer
            },
            timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ')
        }
    }
    
    PerformHttpRequest(Config.Webhook.Url, function(err, text, headers) end, 'POST', json.encode({
        username = 'Chris Businesses',
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end

-- Get all businesses
lib.callback.register('chris_businesses:getBusinesses', function(source)
    local businesses = {}
    for id, business in pairs(cachedBusinesses) do
        businesses[#businesses + 1] = {
            id = business.id,
            name = business.name,
            label = business.label,
            owner_identifier = business.owner_identifier,
            owner_name = business.owner_name,
            coords = business.coords,
            price = business.price,
            for_sale = business.for_sale == 1,
            business_type = business.business_type,
            blip_sprite = business.blip_sprite,
            blip_color = business.blip_color,
            is_open = business.is_open == 1
        }
    end
    return businesses
end)

-- Get business by ID
lib.callback.register('chris_businesses:getBusiness', function(source, businessId)
    local business = cachedBusinesses[businessId]
    if not business then return nil end
    
    local citizenid = GetIdentifier(source)
    if not citizenid then return nil end
    
    -- Check if player has business laptop (server-side validation)
    local hasLaptop = exports.ox_inventory:Search(source, 'count', Config.LaptopItem) > 0
    if not hasLaptop then
        return nil -- Don't return business data if no laptop
    end
    
    -- Check permissions
    local role = GetPlayerRole(business, citizenid)
    if not role and not business.for_sale then
        return nil -- No access
    end
    
    -- Get business balance from bank account
    local balance = 0
    if Config.Banking.Enabled and business.owner_identifier then
        local accountName = GetBusinessAccountName(businessId)
        balance = exports['Renewed-Banking']:getAccountMoney(accountName) or 0
    else
        balance = business.balance or 0
    end
    
    -- Get stock from ox_inventory if enabled
    local stock = {}
    if Config.Stock.useOxInventory then
        local storageId = 'business_' .. businessId
        local inventory = exports.ox_inventory:GetInventory(storageId)
        if inventory then
            for slot, item in pairs(inventory.items) do
                if item then
                    stock[#stock + 1] = {
                        name = item.name,
                        count = item.count,
                        label = item.label,
                        metadata = item.metadata
                    }
                end
            end
        end
    else
        stock = business.stock or {}
    end
    
    -- Get employees
    local employees = MySQL.query.await('SELECT * FROM chris_employees WHERE business_id = ?', {businessId}) or {}
    
    -- Get recent transactions
    local transactions = MySQL.query.await('SELECT * FROM chris_transactions WHERE business_id = ? ORDER BY timestamp DESC LIMIT 50', {businessId}) or {}
    
    return {
        id = business.id,
        name = business.name,
        label = business.label,
        owner_identifier = business.owner_identifier,
        owner_name = business.owner_name,
        coords = business.coords,
        price = business.price,
        for_sale = business.for_sale == 1,
        business_type = business.business_type,
        blip_sprite = business.blip_sprite,
        blip_color = business.blip_color,
        is_open = business.is_open == 1,
        balance = balance,
        stock = stock,
        employees = employees,
        transactions = transactions,
        role = role,
        settings = business.settings or Config.DefaultSettings
    }
end)

-- Purchase business
lib.callback.register('chris_businesses:purchaseBusiness', function(source, businessId)
    local Player = GetPlayer(source)
    if not Player then return false, 'Player not found' end
    
    local citizenid = FrameworkFunctions.GetIdentifier(Player)
    local business = cachedBusinesses[businessId]
    
    if not business then
        return false, 'Business not found'
    end
    
    if not business.for_sale or business.for_sale == 0 then
        return false, 'Business is not for sale'
    end
    
    if business.owner_identifier then
        return false, 'Business is already owned'
    end
    
    local price = business.price or 0
    if price <= 0 then
        return false, 'Invalid business price'
    end
    
    -- Check if player has enough money
    local bankMoney = FrameworkFunctions.GetMoney(Player, 'bank')
    if bankMoney < price then
        return false, 'Insufficient funds'
    end
    
    -- Remove money from player
    if not FrameworkFunctions.RemoveMoney(Player, 'bank', price, 'Business Purchase: ' .. business.label) then
        return false, 'Failed to process payment'
    end
    
    -- Update business ownership
    local playerName = FrameworkFunctions.GetPlayerName(Player)
    MySQL.update('UPDATE chris_businesses SET owner_identifier = ?, owner_name = ?, for_sale = 0 WHERE id = ?', {
        citizenid,
        playerName,
        businessId
    })
    
    business.owner_identifier = citizenid
    business.owner_name = playerName
    business.for_sale = 0
    
    -- Create bank account for business
    if Config.Banking.Enabled then
        local accountName = GetBusinessAccountName(businessId)
        CreateBusinessBankAccount(accountName, business.label, citizenid)
    end
    
    -- Log transaction
    LogTransaction(businessId, Config.TransactionTypes.PURCHASE, price, 'Business Purchase', citizenid, {
        business_name = business.label,
        previous_owner = nil
    })
    
    -- Send webhook
    SendWebhook('Business Purchased', string.format('%s purchased %s for $%s', playerName, business.label, FormatCurrency(price)), 3066993)
    
    -- Notify client
    TriggerClientEvent('chris_businesses:client:businessUpdated', -1, businessId)
    
    return true, 'Business purchased successfully'
end)

-- Sell business
lib.callback.register('chris_businesses:sellBusiness', function(source, businessId, price)
    local Player = GetPlayer(source)
    if not Player then return false, 'Player not found' end
    
    local citizenid = FrameworkFunctions.GetIdentifier(Player)
    local business = cachedBusinesses[businessId]
    
    if not business then
        return false, 'Business not found'
    end
    
    if not IsOwner(business, citizenid) then
        return false, 'You do not own this business'
    end
    
    if price and price > 0 then
        -- List for sale
        MySQL.update('UPDATE chris_businesses SET for_sale = 1, price = ? WHERE id = ?', {price, businessId})
        business.for_sale = 1
        business.price = price
        
        SendWebhook('Business Listed for Sale', string.format('%s listed %s for sale at $%s', business.owner_name, business.label, FormatCurrency(price)), 16776960)
        
        return true, 'Business listed for sale'
    else
        -- Transfer ownership to system (remove owner)
        MySQL.update('UPDATE chris_businesses SET owner_identifier = NULL, owner_name = NULL, for_sale = 1 WHERE id = ?', {businessId})
        business.owner_identifier = nil
        business.owner_name = nil
        business.for_sale = 1
        
        SendWebhook('Business Sold', string.format('%s sold %s back to the system', business.owner_name, business.label), 16711680)
        
        return true, 'Business sold'
    end
end)

-- Hire employee
lib.callback.register('chris_businesses:hireEmployee', function(source, businessId, targetCitizenid, role)
    local Player = GetPlayer(source)
    if not Player then return false, 'Player not found' end
    
    local citizenid = FrameworkFunctions.GetIdentifier(Player)
    local business = cachedBusinesses[businessId]
    
    if not business then
        return false, 'Business not found'
    end
    
    if not HasPermission(business, citizenid, 'manage_employees') then
        return false, 'You do not have permission to manage employees'
    end
    
    -- Check if target is already an employee
    local existing = MySQL.query.await('SELECT * FROM chris_employees WHERE business_id = ? AND citizenid = ?', {businessId, targetCitizenid})
    if existing and #existing > 0 then
        return false, 'Player is already an employee'
    end
    
    -- Get target player name
    local targetPlayer = FrameworkFunctions.GetPlayerByCitizenId(targetCitizenid)
    if not targetPlayer then
        return false, 'Target player not found'
    end
    
    local targetName = FrameworkFunctions.GetPlayerName(targetPlayer)
    
    -- Validate role
    if not Config.Roles[role] then
        role = 'employee'
    end
    
    -- Check max employees
    local businessType = Config.BusinessTypes[business.business_type]
    if businessType then
        local employeeCount = MySQL.query.await('SELECT COUNT(*) as count FROM chris_employees WHERE business_id = ?', {businessId})
        if employeeCount and employeeCount[1] and employeeCount[1].count >= businessType.maxEmployees then
            return false, 'Maximum employees reached'
        end
    end
    
    -- Add employee
    MySQL.insert('INSERT INTO chris_employees (business_id, citizenid, name, role, permissions) VALUES (?, ?, ?, ?, ?)', {
        businessId,
        targetCitizenid,
        targetName,
        role,
        json.encode(Config.Roles[role].permissions)
    })
    
    -- Update business employees JSON
    local employees = MySQL.query.await('SELECT * FROM chris_employees WHERE business_id = ?', {businessId}) or {}
    MySQL.update('UPDATE chris_businesses SET employees = ? WHERE id = ?', {
        json.encode(employees),
        businessId
    })
    
    LogTransaction(businessId, 'employee_hired', 0, 'Hired ' .. targetName .. ' as ' .. role, citizenid, {
        employee_citizenid = targetCitizenid,
        role = role
    })
    
    SendWebhook('Employee Hired', string.format('%s hired %s as %s at %s', FrameworkFunctions.GetPlayerName(Player), targetName, role, business.label), 3066993)
    
    return true, 'Employee hired successfully'
end)

-- Fire employee
lib.callback.register('chris_businesses:fireEmployee', function(source, businessId, employeeCitizenid)
    local Player = GetPlayer(source)
    if not Player then return false, 'Player not found' end
    
    local citizenid = FrameworkFunctions.GetIdentifier(Player)
    local business = cachedBusinesses[businessId]
    
    if not business then
        return false, 'Business not found'
    end
    
    if not HasPermission(business, citizenid, 'manage_employees') then
        return false, 'You do not have permission to manage employees'
    end
    
    -- Get employee info
    local employee = MySQL.query.await('SELECT * FROM chris_employees WHERE business_id = ? AND citizenid = ?', {businessId, employeeCitizenid})
    if not employee or #employee == 0 then
        return false, 'Employee not found'
    end
    
    -- Remove employee
    MySQL.query('DELETE FROM chris_employees WHERE business_id = ? AND citizenid = ?', {businessId, employeeCitizenid})
    
    -- Update business employees JSON
    local employees = MySQL.query.await('SELECT * FROM chris_employees WHERE business_id = ?', {businessId}) or {}
    MySQL.update('UPDATE chris_businesses SET employees = ? WHERE id = ?', {
        json.encode(employees),
        businessId
    })
    
    LogTransaction(businessId, 'employee_fired', 0, 'Fired ' .. employee[1].name, citizenid, {
        employee_citizenid = employeeCitizenid
    })
    
    SendWebhook('Employee Fired', string.format('%s fired %s from %s', FrameworkFunctions.GetPlayerName(Player), employee[1].name, business.label), 16711680)
    
    return true, 'Employee fired successfully'
end)

-- Update business settings
lib.callback.register('chris_businesses:updateSettings', function(source, businessId, settings)
    local Player = GetPlayer(source)
    if not Player then return false, 'Player not found' end
    
    local citizenid = FrameworkFunctions.GetIdentifier(Player)
    local business = cachedBusinesses[businessId]
    
    if not business then
        return false, 'Business not found'
    end
    
    if not HasPermission(business, citizenid, 'manage_settings') then
        return false, 'You do not have permission to manage settings'
    end
    
    -- Update settings
    local currentSettings = business.settings or Config.DefaultSettings
    for k, v in pairs(settings) do
        currentSettings[k] = v
    end
    
    MySQL.update('UPDATE chris_businesses SET settings = ?, is_open = ? WHERE id = ?', {
        json.encode(currentSettings),
        currentSettings.isOpen and 1 or 0,
        businessId
    })
    
    business.settings = currentSettings
    business.is_open = currentSettings.isOpen and 1 or 0
    
    -- Update blip if needed
    if settings.blip_color or settings.blip_sprite then
        if settings.blip_color then
            business.blip_color = settings.blip_color
        end
        if settings.blip_sprite then
            business.blip_sprite = settings.blip_sprite
        end
        MySQL.update('UPDATE chris_businesses SET blip_color = ?, blip_sprite = ? WHERE id = ?', {
            business.blip_color,
            business.blip_sprite,
            businessId
        })
        TriggerClientEvent('chris_businesses:client:businessUpdated', -1, businessId)
    end
    
    return true, 'Settings updated successfully'
end)

-- Deposit money
lib.callback.register('chris_businesses:depositMoney', function(source, businessId, amount)
    local Player = GetPlayer(source)
    if not Player then return false, 'Player not found' end
    
    local citizenid = FrameworkFunctions.GetIdentifier(Player)
    local business = cachedBusinesses[businessId]
    
    if not business then
        return false, 'Business not found'
    end
    
    if not HasPermission(business, citizenid, 'manage_finances') then
        return false, 'You do not have permission to manage finances'
    end
    
    if amount <= 0 then
        return false, 'Invalid amount'
    end
    
    -- Check player bank balance
    local bankMoney = FrameworkFunctions.GetMoney(Player, 'bank')
    if bankMoney < amount then
        return false, 'Insufficient funds'
    end
    
    -- Remove from player
    if not FrameworkFunctions.RemoveMoney(Player, 'bank', amount, 'Business Deposit: ' .. business.label) then
        return false, 'Failed to process deposit'
    end
    
    -- Add to business account
    if Config.Banking.Enabled then
        local accountName = GetBusinessAccountName(businessId)
        exports['Renewed-Banking']:addAccountMoney(accountName, amount)
        exports['Renewed-Banking']:handleTransaction(accountName, business.label, amount, 'Deposit from ' .. FrameworkFunctions.GetPlayerName(Player), FrameworkFunctions.GetPlayerName(Player), business.label, 'deposit')
    else
        MySQL.update('UPDATE chris_businesses SET balance = balance + ? WHERE id = ?', {amount, businessId})
        business.balance = (business.balance or 0) + amount
    end
    
    LogTransaction(businessId, Config.TransactionTypes.DEPOSIT, amount, 'Deposit from ' .. FrameworkFunctions.GetPlayerName(Player), citizenid)
    
    return true, 'Deposit successful'
end)

-- Withdraw money
lib.callback.register('chris_businesses:withdrawMoney', function(source, businessId, amount)
    local Player = GetPlayer(source)
    if not Player then return false, 'Player not found' end
    
    local citizenid = FrameworkFunctions.GetIdentifier(Player)
    local business = cachedBusinesses[businessId]
    
    if not business then
        return false, 'Business not found'
    end
    
    if not HasPermission(business, citizenid, 'manage_finances') then
        return false, 'You do not have permission to manage finances'
    end
    
    if amount <= 0 then
        return false, 'Invalid amount'
    end
    
    -- Check business balance
    local balance = 0
    if Config.Banking.Enabled then
        local accountName = GetBusinessAccountName(businessId)
        balance = exports['Renewed-Banking']:getAccountMoney(accountName) or 0
    else
        balance = business.balance or 0
    end
    
    if balance < amount then
        return false, 'Insufficient business funds'
    end
    
    -- Remove from business
    if Config.Banking.Enabled then
        local accountName = GetBusinessAccountName(businessId)
        exports['Renewed-Banking']:removeAccountMoney(accountName, amount)
        exports['Renewed-Banking']:handleTransaction(accountName, business.label, amount, 'Withdrawal to ' .. FrameworkFunctions.GetPlayerName(Player), business.label, FrameworkFunctions.GetPlayerName(Player), 'withdraw')
    else
        MySQL.update('UPDATE chris_businesses SET balance = balance - ? WHERE id = ?', {amount, businessId})
        business.balance = (business.balance or 0) - amount
    end
    
    -- Add to player
    FrameworkFunctions.AddMoney(Player, 'bank', amount, 'Business Withdrawal: ' .. business.label)
    
    LogTransaction(businessId, Config.TransactionTypes.WITHDRAW, amount, 'Withdrawal to ' .. FrameworkFunctions.GetPlayerName(Player), citizenid)
    
    return true, 'Withdrawal successful'
end)

-- Purchase item from business (storefront)
lib.callback.register('chris_businesses:purchaseItem', function(source, businessId, itemName, quantity, price)
    local Player = GetPlayer(source)
    if not Player then return false, 'Player not found' end
    
    local business = cachedBusinesses[businessId]
    if not business then
        return false, 'Business not found'
    end
    
    if business.is_open == 0 then
        return false, 'Business is closed'
    end
    
    if not business.owner_identifier then
        return false, 'Business has no owner'
    end
    
    -- Check stock
    local stock = {}
    if Config.Stock.useOxInventory then
        local storageId = 'business_' .. businessId
        local inventory = exports.ox_inventory:GetInventory(storageId)
        if inventory then
            local itemCount = exports.ox_inventory:GetItemCount(storageId, itemName)
            if itemCount < quantity then
                return false, 'Insufficient stock'
            end
        else
            return false, 'Business storage not found'
        end
    else
        stock = business.stock or {}
        local itemStock = 0
        for _, item in pairs(stock) do
            if item.name == itemName then
                itemStock = item.count or 0
                break
            end
        end
        if itemStock < quantity then
            return false, 'Insufficient stock'
        end
    end
    
    -- Check player money
    local totalPrice = price * quantity
    local cash = FrameworkFunctions.GetMoney(Player, 'cash')
    if cash < totalPrice then
        return false, 'Insufficient funds'
    end
    
    -- Remove money from player
    if not FrameworkFunctions.RemoveMoney(Player, 'cash', totalPrice, 'Purchase: ' .. itemName) then
        return false, 'Payment failed'
    end
    
    -- Remove item from stock
    if Config.Stock.useOxInventory then
        local storageId = 'business_' .. businessId
        exports.ox_inventory:RemoveItem(storageId, itemName, quantity)
    else
        -- Update stock JSON
        for i, item in pairs(stock) do
            if item.name == itemName then
                item.count = (item.count or 0) - quantity
                if item.count <= 0 then
                    table.remove(stock, i)
                end
                break
            end
        end
        MySQL.update('UPDATE chris_businesses SET stock = ? WHERE id = ?', {json.encode(stock), businessId})
        business.stock = stock
    end
    
    -- Add item to player
    exports.ox_inventory:AddItem(source, itemName, quantity)
    
    -- Add money to business account
    if Config.Banking.Enabled then
        local accountName = GetBusinessAccountName(businessId)
        exports['Renewed-Banking']:addAccountMoney(accountName, totalPrice)
        exports['Renewed-Banking']:handleTransaction(accountName, business.label, totalPrice, 'Sale: ' .. itemName .. ' x' .. quantity, FrameworkFunctions.GetPlayerName(Player), business.label, 'deposit')
    else
        MySQL.update('UPDATE chris_businesses SET balance = balance + ? WHERE id = ?', {totalPrice, businessId})
        business.balance = (business.balance or 0) + totalPrice
    end
    
    LogTransaction(businessId, Config.TransactionTypes.SALE, totalPrice, 'Sale: ' .. itemName .. ' x' .. quantity, FrameworkFunctions.GetIdentifier(Player), {
        item = itemName,
        quantity = quantity,
        price = price
    })
    
    return true, 'Purchase successful'
end)

-- Admin: Add business
RegisterCommand('addbusiness', function(source, args)
    local Player = GetPlayer(source)
    if not Player then return end
    
    -- Check admin (simplified - should use proper permission system)
    local citizenid = FrameworkFunctions.GetIdentifier(Player)
    
    -- Get business data from args or use defaults
    local name = args[1] or 'New Business'
    local label = args[2] or name
    local businessType = args[3] or 'general'
    local price = tonumber(args[4]) or 50000
    
    -- Use player's current position (would need client to send coords)
    lib.notify(source, {
        title = 'Business System',
        description = 'Use /addbusinessat [name] [label] [type] [price] while at the location',
        type = 'info'
    })
end, false)

-- Admin: Remove business
RegisterCommand('removebusiness', function(source, args)
    local businessId = tonumber(args[1])
    if not businessId then
        lib.notify(source, {
            title = 'Business System',
            description = 'Usage: /removebusiness [id]',
            type = 'error'
        })
        return
    end
    
    local business = cachedBusinesses[businessId]
    if not business then
        lib.notify(source, {
            title = 'Business System',
            description = 'Business not found',
            type = 'error'
        })
        return
    end
    
    MySQL.query('DELETE FROM chris_businesses WHERE id = ?', {businessId})
    cachedBusinesses[businessId] = nil
    
    lib.notify(source, {
        title = 'Business System',
        description = 'Business removed',
        type = 'success'
    })
    
    TriggerClientEvent('chris_businesses:client:businessRemoved', -1, businessId)
end, false)

-- Exports
exports('GetOwnedBusinesses', function(citizenid)
    local businesses = {}
    for id, business in pairs(cachedBusinesses) do
        if business.owner_identifier == citizenid then
            businesses[#businesses + 1] = business
        end
    end
    return businesses
end)

exports('AddBusinessStock', function(businessId, item, amount)
    if Config.Stock.useOxInventory then
        local storageId = 'business_' .. businessId
        exports.ox_inventory:AddItem(storageId, item, amount)
    else
        local business = cachedBusinesses[businessId]
        if business then
            local stock = business.stock or {}
            local found = false
            for _, s in pairs(stock) do
                if s.name == item then
                    s.count = (s.count or 0) + amount
                    found = true
                    break
                end
            end
            if not found then
                stock[#stock + 1] = {name = item, count = amount}
            end
            MySQL.update('UPDATE chris_businesses SET stock = ? WHERE id = ?', {json.encode(stock), businessId})
            business.stock = stock
        end
    end
end)

exports('PayEmployee', function(businessId, citizenid, amount)
    local business = cachedBusinesses[businessId]
    if not business then return false end
    
    local balance = 0
    if Config.Banking.Enabled then
        local accountName = GetBusinessAccountName(businessId)
        balance = exports['Renewed-Banking']:getAccountMoney(accountName) or 0
    else
        balance = business.balance or 0
    end
    
    if balance < amount then return false end
    
    local targetPlayer = FrameworkFunctions.GetPlayerByCitizenId(citizenid)
    if not targetPlayer then return false end
    
    if Config.Banking.Enabled then
        local accountName = GetBusinessAccountName(businessId)
        exports['Renewed-Banking']:removeAccountMoney(accountName, amount)
    else
        MySQL.update('UPDATE chris_businesses SET balance = balance - ? WHERE id = ?', {amount, businessId})
        business.balance = (business.balance or 0) - amount
    end
    
    FrameworkFunctions.AddMoney(targetPlayer, 'bank', amount, 'Employee Payment: ' .. business.label)
    
    LogTransaction(businessId, Config.TransactionTypes.EMPLOYEE_PAY, amount, 'Payment to employee', citizenid)
    
    return true
end)

