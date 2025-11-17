Config = {}

Config.Debug = true

Config.PoliceJobs = { 'police', 'sasp', 'bcso' }  -- adjust for your server

Config.Heists = {

    ----------------------------------------------------------------
    -- 24/7 STORE ROBBERY (GROVE STREET)
    ----------------------------------------------------------------
    store_247_grove = {
        heistType = 'store',  -- NEW
        label = "24/7 Robbery - Grove Street",

        requiredPolice = 0,
        cooldown = 20 * 60,         -- seconds
        requiredItem = 'weapon_crowbar',  -- nil = no item required

        start = { x = -46.40, y = -1758.21, z = 29.42 },  -- where you start the robbery

        clerk = {
            enabled = true,
            npcModel = 'mp_m_shopkeep_01', -- default clerk model
            coords = { x = -47.24, y = -1759.01, z = 29.42, heading = 45.0 },
            panicChance = 60,   -- % chance clerk secretly hits silent alarm
            surrenderAnim = true,
            safeKeyChance = 100 -- optional future update: clerk gives safe key
        },

        steps = {
            {
                action = "smash",
                label = "Smash the Register",
                coords = { x = -46.66, y = -1757.92, z = 29.42 },
                radius = 1.5,
                time = 4000, -- ms
                alert = "loud",         -- NEW: instantly alerts police, plays alarm
                alarmSound = true       -- NEW: trigger alarm SFX on this step
            },
            {
                action = "loot",
                label = "Grab the Cash",
                coords = { x = -46.66, y = -1757.92, z = 29.42 },
                radius = 1.5,
                difficulty = { 'easy', 'easy', 'medium' },
                alert = "silent"        -- maybe they don't get alerted if you're quick
            },
            {
                action = "drill",
                label = "Crack the Safe",
                coords = { x = -43.4578, y = -1748.3510, z = 29.4210 }, -- in offcie -43.4578, -1748.3510, 29.4210, 58.7212
                radius = 1.5,
                time = 60000, -- Extended to 60 seconds to allow police response time
                alert = "loud",
                alarmSound = true
            },
        },

        rewards = {
            items = {
                { name = 'black_money', chance = 100, min = 2000, max = 2500 }, -- Register cash: ~2k
            }
        },
        
        safeReward = {
            items = {
                { name = 'black_money', chance = 100, min = 3500, max = 4000 }, -- Safe cash: ~3.5-4k (total ~6k)
            }
        }
    },

    ----------------------------------------------------------------
    -- FLEECA BANK (LEGION)
    ----------------------------------------------------------------
    fleeca_legion = {
        heistType = 'fleeca',  -- NEW
        label = "Fleeca Bank - Legion",

        requiredPolice = 0,
        cooldown = 45 * 60,
        requiredItem = 'business_laptop',

        start = { x = 148.9, y = -1040.1, z = 29.37 },

        vault = {
            coords = { x = 147.034, y = -1046.515, z = 29.367 },  -- Adjusted coordinates - moved from wall
            heading = 250.0,  -- Closed position - aligns door flush with wall (vanilla interior)
            doorModel = 'v_ilev_gb_vauldr',  -- NEW: the vault door model to spawn
        },

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
                alert = "silent"      -- chance-based silent
            },
            {
                action = "drill",
                label = "Drill the Vault Door",
                coords = { x = 148.0, y = -1044.7, z = 29.37 },
                radius = 1.5,
                time = 30000, -- ms
                alert = "loud",       -- definitely alerts cops
                alarmSound = true
            },
            {
                action = "loot",
                label = "Loot the Vault",
                coords = { x = 151.4, y = -1040.7, z = 29.37 },
                radius = 3.0,
                alert = "silent"
            },
        },

        rewards = {
            items = {
                { name = 'black_money', chance = 100, min = 55000, max = 90000 },
                { name = 'markedbills', chance = 70, min = 6, max = 12 },
                { name = 'gold_bar',    chance = 40, min = 1, max = 3 },
            }
        }
    },

    ----------------------------------------------------------------
    -- JEWELLERY STORE (VANGELICO)
    ----------------------------------------------------------------
    jewellery_vangelico = {
        heistType = 'jewellery',  -- NEW
        label = "Vangelico Jewellery Store",

        requiredPolice = 0,
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
        },

        rewards = {
            items = {
                { name = 'black_money', chance = 100, min = 15000, max = 35000 },
                { name = 'diamond',    chance = 60, min = 1, max = 3 },
                { name = 'gold_chain', chance = 70, min = 2, max = 5 },
            }
        }
    },

}

return Config

