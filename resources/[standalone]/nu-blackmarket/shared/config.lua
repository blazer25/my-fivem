-- Nu-Blackmarket Configuration
Config = {}

-- Debug mode (set to false for production)
Config.Debug = true

-- Ped Configuration
Config.Ped = {
    model = `g_m_m_chigoon_01`, -- Black market dealer ped model
    coords = vector4(1400.3207, 3641.8157, 27.9513, 225.4040), -- Default location (can be changed)
    scenario = "WORLD_HUMAN_SMOKING", -- Ped animation/scenario
    freeze = true, -- Should the ped be frozen in place
    invincible = true, -- Should the ped be invincible
    blockevents = true -- Should the ped ignore events
}

-- ox_target Configuration
Config.Target = {
    icon = "fas fa-shopping-cart",
    label = "Browse Black Market",
    distance = 2.5, -- Interaction distance
    debug = false -- ox_target debug mode
}

-- Currency Configuration
Config.Currency = {
    type = "black_money", -- Use dirty money item in ox_inventory
    removeType = "removeItem" -- Not currently used but kept for clarity
}

-- UI Configuration
Config.UI = {
    title = "Black Market",
    subtitle = "Illegal goods and services",
    maxCartItems = 10, -- Maximum items in cart
    showPrices = true,
    enableSounds = true
}

-- Black Market Items Configuration
Config.Items = {
    {
        category = "supplies",
        categoryLabel = "Chemicals & Packaging",
        categoryIcon = "fas fa-flask",
        items = {
            {
                name = "empty_weed_bag",
                label = "Empty Baggies",
                description = "Packaging to portion street-ready product.",
                price = 65,
                image = "weed_baggy_empty.png",
                stock = 200,
                maxQuantity = 50
            },
            {
                name = "meth_tray",
                label = "Crystal Drying Trays",
                description = "Reusable trays for drying and cutting meth batches.",
                price = 350,
                image = "meth_tray.png",
                stock = 35,
                maxQuantity = 5
            },
            {
                name = "acetone",
                label = "Industrial Acetone",
                description = "Solvent used for cooking high-grade product.",
                price = 140,
                image = "acetone.png",
                stock = 80,
                maxQuantity = 10
            },
            {
                name = "ephedrine",
                label = "Ephedrine Powder",
                description = "Key precursor for crystal meth production.",
                price = 260,
                image = "ephedrine.png",
                stock = 60,
                maxQuantity = 8
            },
            {
                name = "hydrochloricacid",
                label = "Hydrochloric Acid",
                description = "Used to stabilize narcotic compounds.",
                price = 190,
                image = "hydrochloricacid.png",
                stock = 75,
                maxQuantity = 8
            },
            {
                name = "weed_nutrition",
                label = "Plant Nutrients",
                description = "Premium nutrition boost for hydro grows.",
                price = 95,
                image = "weed_nutrition.png",
                stock = 120,
                maxQuantity = 15
            }
        }
    },
    {
        category = "bulk",
        categoryLabel = "Bulk Product",
        categoryIcon = "fas fa-boxes-stacked",
        items = {
            {
                name = "weed_brick",
                label = "Weed Brick",
                description = "Compressed cannabis ready for cutting.",
                price = 2400,
                image = "weed_brick.png",
                stock = 18,
                maxQuantity = 2
            },
            {
                name = "coke_small_brick",
                label = "Kilo of Cocaine",
                description = "Refined cocaine block, perfect for distribution.",
                price = 3100,
                image = "coke_small_brick.png",
                stock = 12,
                maxQuantity = 1
            },
            {
                name = "coke_brick",
                label = "Pressed Cocaine Brick",
                description = "High-purity brick sourced from overseas.",
                price = 5400,
                image = "coke_brick.png",
                stock = 6,
                maxQuantity = 1
            },
            {
                name = "meth",
                label = "Crystal Meth",
                description = "Uncut crystals ready to be bagged.",
                price = 1150,
                image = "meth.png",
                stock = 40,
                maxQuantity = 6
            },
            {
                name = "meth_baggy",
                label = "Vacuum-Sealed Meth",
                description = "Bulk-ready methamphetamine pouches.",
                price = 1850,
                image = "meth_baggy.png",
                stock = 24,
                maxQuantity = 3
            },
            {
                name = "crack_baggy",
                label = "Cooked Crack Rocks",
                description = "Cooked, cooled, and ready for the block.",
                price = 950,
                image = "crack_baggy.png",
                stock = 30,
                maxQuantity = 5
            },
            {
                name = "xtcbaggy",
                label = "Press Tabs (XTC)",
                description = "Designer tablets sourced from Europe.",
                price = 1250,
                image = "xtc_baggy.png",
                stock = 28,
                maxQuantity = 4
            }
        }
    }
}

-- Job Restrictions (optional - leave empty table {} to allow all players)
Config.JobRestrictions = {
    -- Example: only allow certain jobs to access the black market
    -- "police", -- This would BLOCK police from accessing
    -- Add job names to block them from accessing the black market
}

-- Time Restrictions (optional)
Config.TimeRestrictions = {
    enabled = false, -- Set to true to enable time restrictions
    startHour = 22, -- 10 PM
    endHour = 6 -- 6 AM
}

-- Webhook Configuration (for logging purchases)
Config.Webhook = {
    enabled = true, -- Set to true to enable Discord logging
    url = "https://discord.com/api/webhooks/1436077269373161483/dq6lK1VBQi1dRpqQVE499rhdZZ5szTyyhDum1GYbhrsW_mDG86A4ySXDof3TOSNwgpr9", -- Your Discord webhook URL
    color = 16711680, -- Red color
    title = "Black Market Purchase",
    footer = "Nu-Blackmarket System"
}

-- Stock Refresh Configuration
Config.StockRefresh = {
    enabled = true, -- Should stock refresh automatically
    interval = 60, -- Minutes between stock refresh
    percentage = 0.5 -- Percentage of max stock to restore (0.5 = 50%)
} 