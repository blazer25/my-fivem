Config = {}

Config.Debug = false

Config.Framework = "qb" -- qb | esx | standalone

Config.GlobalCooldown = {
    base = 30 * 60,
    min = 10 * 60,
    max = 60 * 60,
    deltaOnSuccess = 5 * 60,
    deltaOnFail = -10 * 60
}

Config.PoliceScaling = {
    thresholds = {
        {count = 0, tier = 1},
        {count = 2, tier = 2},
        {count = 4, tier = 3},
        {count = 6, tier = 4},
        {count = 8, tier = 5},
        {count = 10, tier = 6}
    },
    slowResponseThreshold = 420,
    fastResponseThreshold = 180,
    cooldownIncrease = 5 * 60,
    cooldownDecrease = 5 * 60
}

Config.Evidence = {
    dnaChance = 0.35,
    fingerprintChance = 0.55,
    hairChance = 0.15,
    tamperLogChance = 0.75,
    mitigationItems = {
        gloves = 0.5,
        mask = 0.25,
        bleach = 0.2,
        jammer = 0.1
    }
}

Config.LootTiers = {
    [1] = {
        cash = {min = 1500, max = 5000},
        markedBills = {min = 1, max = 3},
        contraband = {"cheap_usb"}
    },
    [2] = {
        cash = {min = 4000, max = 12000},
        markedBills = {min = 3, max = 6},
        valuables = {"gold_watch", "art_frame"},
        contraband = {"mid_usb"}
    },
    [3] = {
        cash = {min = 8000, max = 20000},
        markedBills = {min = 5, max = 10},
        valuables = {"gold_bar", "diamond_necklace"},
        contraband = {"encrypted_drive"}
    },
    [4] = {
        cash = {min = 15000, max = 40000},
        markedBills = {min = 10, max = 20},
        valuables = {"rare_art", "prototype_chip"},
        contraband = {"military_blueprint"}
    },
    [5] = {
        cash = {min = 40000, max = 90000},
        markedBills = {min = 25, max = 40},
        valuables = {"artifact_mask"},
        contraband = {"nano_keycard"},
        cyber = {"encrypted_drive", "mainframe_core"}
    },
    [6] = {
        cash = {min = 90000, max = 200000},
        markedBills = {min = 35, max = 60},
        valuables = {"crown_jewels"},
        contraband = {"quantum_chip"},
        cyber = {"supercomputer_node"}
    }
}

Config.Progression = {
    tiers = {
        [1] = {reputation = 0},
        [2] = {reputation = 100},
        [3] = {reputation = 250},
        [4] = {reputation = 450},
        [5] = {reputation = 700},
        [6] = {reputation = 1000}
    },
    reputationGain = {
        success = {base = 25, bonusPerTier = 5},
        fail = -15,
        surrender = -30
    },
    decayPerHour = 5
}

Config.Heists = {
    fleeca = {
        label = "Fleeca Bank",
        tier = 2,
        location = vector3(252.3, 228.4, 101.68),
        radius = 3.0,
        requiredPolice = 2,
        requiredItems = {"drill", "green_laptop"},
        cooldown = 30 * 60,
        stages = {
            {type = "hack", label = "Bypass security panel", duration = 45},
            {type = "drill", label = "Drill safety deposit", duration = 60},
            {type = "loot", label = "Grab the cash", duration = 30}
        },
        rewards = {tier = 2, bonus = {"fleeca_blueprint"}},
        responses = {alarm = "fleeca_panel", dispatch = "bank_small"}
    },
    jewellery = {
        label = "Vangelico Jewellery",
        tier = 3,
        location = vector3(-629.0, -238.5, 38.0),
        radius = 4.0,
        requiredPolice = 4,
        requiredItems = {"smash_tool", "signal_jammer"},
        cooldown = 45 * 60,
        stages = {
            {type = "disable_alarm", label = "Kill alarm box", duration = 30},
            {type = "smash", label = "Smash display cases", duration = 50},
            {type = "loot", label = "Collect jewels", duration = 40}
        },
        rewards = {tier = 3, bonus = {"rare_gem"}},
        responses = {alarm = "silent", dispatch = "jewellery"}
    },
    warehouse = {
        label = "Chemical Warehouse",
        tier = 3,
        location = vector3(874.9, -2164.1, 32.3),
        radius = 5.0,
        requiredPolice = 0,
        gangResponse = true,
        requiredItems = {"forklift_key", "crowbar"},
        cooldown = 35 * 60,
        stages = {
            {type = "stealth", label = "Sneak past gang guards", duration = 35},
            {type = "load", label = "Load crates", duration = 60}
        },
        rewards = {tier = 3, bonus = {"chemical_crate"}},
        responses = {alarm = "gang_radio", dispatch = "gang"}
    },
    scrapyard = {
        label = "Scrap Yard Metals",
        tier = 1,
        location = vector3(2365.5, 3127.4, 48.1),
        radius = 5.0,
        requiredPolice = 0,
        requiredItems = {"cutting_torch"},
        cooldown = 20 * 60,
        stages = {
            {type = "cut", label = "Cut copper wiring", duration = 40},
            {type = "load", label = "Load van", duration = 30}
        },
        rewards = {tier = 1, bonus = {"scrap_bundle"}},
        responses = {alarm = "civ_call", dispatch = "none"}
    },
    armored = {
        label = "Armored Truck",
        tier = 4,
        location = vector3(-132.4, -613.8, 168.8),
        radius = 15.0,
        requiredPolice = 5,
        requiredItems = {"c4_charge", "thermite"},
        cooldown = 60 * 60,
        stages = {
            {type = "intercept", label = "Stop the truck", duration = 30},
            {type = "thermite", label = "Melt door bolts", duration = 40},
            {type = "loot", label = "Secure the vault crates", duration = 35}
        },
        rewards = {tier = 4, bonus = {"bond_crate"}},
        responses = {alarm = "panic_button", dispatch = "armored"}
    },
    mansion = {
        label = "Rockford Mansion",
        tier = 5,
        location = vector3(-811.4, 174.7, 76.7),
        radius = 6.0,
        requiredPolice = 6,
        requiredItems = {"silent_drill", "grappling_hook", "mask"},
        cooldown = 75 * 60,
        stages = {
            {type = "infiltrate", label = "Disable cameras", duration = 45},
            {type = "safe_crack", label = "Crack the panic-room safe", duration = 60},
            {type = "data", label = "Steal bitcoin wallet", duration = 50}
        },
        rewards = {tier = 5, bonus = {"heirloom", "encrypted_drive"}},
        responses = {alarm = "private_security", dispatch = "mansion"}
    }
}
