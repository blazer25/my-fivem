Config = {}

Config.Debug = true

Config.PoliceJobs = { 'police', 'sasp', 'bcso' }  -- adjust for your server

Config.Heists = {

    ----------------------------------------------------------------
    -- 24/7 STORE ROBBERY (GROVE STREET)
    ----------------------------------------------------------------
    store_247_grove = {
        label = "24/7 Robbery - Grove Street",

        requiredPolice = 0,
        cooldown = 20 * 60,         -- seconds
        requiredItem = 'weapon_crowbar',  -- nil = no item required

        start = { x = -46.40, y = -1758.21, z = 29.42 },  -- where you start the robbery

        steps = {
            {
                action = "smash",
                label = "Smash the Register",
                coords = { x = -46.66, y = -1757.92, z = 29.42 },
                radius = 1.5,
                time = 4000, -- ms
            },
            {
                action = "loot",
                label = "Grab the Cash",
                coords = { x = -46.66, y = -1757.92, z = 29.42 },
                radius = 1.5,
                difficulty = { 'easy', 'easy', 'medium' },
            },
            {
                action = "escape",
                label = "Escape the Area",
                coords = { x = -46.40, y = -1758.21, z = 29.42 },
                radius = 80.0,
            },
        },

        rewards = {
            cash = { min = 2500, max = 5500 },
            items = {
                { name = 'stolen_goods', chance = 30, min = 1, max = 2 },
            }
        }
    },

    ----------------------------------------------------------------
    -- FLEECA BANK (LEGION)
    ----------------------------------------------------------------
    fleeca_legion = {
        label = "Fleeca Bank - Legion",

        requiredPolice = 3,
        cooldown = 45 * 60,
        requiredItem = 'heist_laptop',

        start = { x = 148.9, y = -1040.1, z = 29.37 },

        guards = {
            {
                coords = { x = 147.6, y = -1045.1, z = 29.37, w = 340.0 },
                model = 's_m_m_security_01',
                weapon = 'weapon_pistol',
                armor = 50,
                accuracy = 35,
            },
            {
                coords = { x = 144.9, y = -1041.9, z = 29.37, w = 250.0 },
                model = 's_m_m_security_01',
                weapon = 'weapon_pistol',
                armor = 50,
                accuracy = 35,
            },
        },

        steps = {
            {
                action = "hack",
                label = "Hack Security Panel",
                coords = { x = 146.9, y = -1046.1, z = 29.37 },
                radius = 1.5,
                difficulty = { 'easy', 'medium', 'hard' },
            },
            {
                action = "drill",
                label = "Drill the Vault Door",
                coords = { x = 148.0, y = -1044.7, z = 29.37 },
                radius = 1.5,
                time = 30000, -- ms
            },
            {
                action = "loot",
                label = "Loot the Vault",
                coords = { x = 151.4, y = -1040.7, z = 29.37 },
                radius = 3.0,
            },
            {
                action = "escape",
                label = "Escape the Area",
                coords = { x = 148.9, y = -1040.1, z = 29.37 },
                radius = 120.0,
            },
        },

        rewards = {
            cash = { min = 55000, max = 90000 },
            items = {
                { name = 'markedbills', chance = 70, min = 6, max = 12 },
                { name = 'gold_bar',    chance = 40, min = 1, max = 3 },
            }
        }
    },

    ----------------------------------------------------------------
    -- JEWELLERY STORE (VANGELICO)
    ----------------------------------------------------------------
    jewellery_vangelico = {
        label = "Vangelico Jewellery Store",

        requiredPolice = 4,
        cooldown = 60 * 60,
        requiredItem = nil,

        start = { x = -623.39, y = -230.30, z = 38.06 },

        steps = {
            {
                action = "smash",
                label = "Break the Display Cases",
                coords = { x = -624.42, y = -231.05, z = 38.06 },
                radius = 5.0,
                time = 5000,
            },
            {
                action = "loot",
                label = "Grab the Jewels",
                coords = { x = -622.55, y = -229.15, z = 38.06 },
                radius = 5.0,
            },
            {
                action = "escape",
                label = "Escape with the Jewels",
                coords = { x = -623.39, y = -230.30, z = 38.06 },
                radius = 140.0,
            },
        },

        rewards = {
            cash = { min = 15000, max = 35000 },
            items = {
                { name = 'diamond',    chance = 60, min = 1, max = 3 },
                { name = 'gold_chain', chance = 70, min = 2, max = 5 },
            }
        }
    },

}

return Config

