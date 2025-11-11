-- ============================================
-- Chris Businesses - Configuration
-- Dynamic Player-Owned Business System
-- ============================================

Config = {}

-- General Settings
Config.DefaultTax = 0.05 -- 5% default tax rate
Config.LaptopItem = 'business_laptop' -- Item name for business laptop
Config.AutoPayInterval = 60 -- Minutes between auto-pay for employees
Config.EnableForSale = true -- Allow businesses to be listed for sale
Config.UseBlips = true -- Show business blips on map
Config.Debug = false -- Enable debug mode

-- Renewed-Banking Integration
Config.Banking = {
    Enabled = true, -- Use Renewed-Banking for business accounts
    AutoCreateAccounts = true, -- Automatically create bank accounts for businesses
    AccountPrefix = 'business_' -- Prefix for business account names
}

-- Discord Webhook (optional)
Config.Webhook = {
    Enabled = false, -- Set to true to enable Discord logging
    Url = '', -- Your Discord webhook URL
    Color = 3066993, -- Green color for embeds
    Footer = 'Chris Businesses System'
}

-- Business Types Configuration
Config.BusinessTypes = {
    ['general'] = {
        label = 'General Store',
        blip = {
            sprite = 52,
            color = 2,
            scale = 0.8
        },
        defaultPrice = 50000,
        maxEmployees = 5,
        taxRate = 0.05
    },
    ['restaurant'] = {
        label = 'Restaurant',
        blip = {
            sprite = 93,
            color = 5,
            scale = 0.8
        },
        defaultPrice = 75000,
        maxEmployees = 8,
        taxRate = 0.05
    },
    ['mechanic'] = {
        label = 'Mechanic Shop',
        blip = {
            sprite = 72,
            color = 1,
            scale = 0.8
        },
        defaultPrice = 100000,
        maxEmployees = 6,
        taxRate = 0.05
    },
    ['nightclub'] = {
        label = 'Nightclub',
        blip = {
            sprite = 93,
            color = 27,
            scale = 0.9
        },
        defaultPrice = 200000,
        maxEmployees = 10,
        taxRate = 0.05
    },
    ['tattoo'] = {
        label = 'Tattoo Shop',
        blip = {
            sprite = 75,
            color = 1,
            scale = 0.8
        },
        defaultPrice = 60000,
        maxEmployees = 4,
        taxRate = 0.05
    },
    ['247'] = {
        label = '24/7 Store',
        blip = {
            sprite = 52,
            color = 2,
            scale = 0.8
        },
        defaultPrice = 40000,
        maxEmployees = 3,
        taxRate = 0.05
    }
}

-- Employee Roles & Permissions
Config.Roles = {
    ['owner'] = {
        label = 'Owner',
        permissions = {
            manage_employees = true,
            manage_stock = true,
            manage_finances = true,
            manage_settings = true,
            view_reports = true
        }
    },
    ['manager'] = {
        label = 'Manager',
        permissions = {
            manage_employees = true,
            manage_stock = true,
            manage_finances = true,
            manage_settings = false,
            view_reports = true
        }
    },
    ['employee'] = {
        label = 'Employee',
        permissions = {
            manage_employees = false,
            manage_stock = false,
            manage_finances = false,
            manage_settings = false,
            view_reports = false
        }
    }
}

-- Default Business Settings
Config.DefaultSettings = {
    isOpen = true,
    allowPublicSale = true,
    autoRestock = false,
    restockThreshold = 10, -- Restock when stock < 10
    employeePayPercentage = 0.0, -- Percentage of profit to employees
    taxRate = 0.05
}

-- Admin Commands
Config.AdminGroups = {
    'admin',
    'god'
}

-- Interaction Settings
Config.Interactions = {
    laptop = {
        distance = 2.0,
        icon = 'fas fa-laptop',
        label = 'Open Business Dashboard'
    },
    shop = {
        distance = 2.5,
        icon = 'fas fa-shopping-cart',
        label = 'Browse Store'
    },
    storage = {
        distance = 2.0,
        icon = 'fas fa-box',
        label = 'Access Storage'
    }
}

-- Stock Management
Config.Stock = {
    useOxInventory = true, -- Use ox_inventory for stock management
    defaultStorage = 'business_storage', -- Storage type for businesses
    maxItems = 100 -- Maximum items per business
}

-- Transaction Types
Config.TransactionTypes = {
    PURCHASE = 'purchase',
    SALE = 'sale',
    DEPOSIT = 'deposit',
    WITHDRAW = 'withdraw',
    EMPLOYEE_PAY = 'employee_pay',
    STOCK_PURCHASE = 'stock_purchase',
    TAX = 'tax',
    TRANSFER = 'transfer'
}

