Config = Config or {}

Config.Debug = false

Config.Storage = {
    Mode = 'json', -- json or mysql
    JsonDirectory = 'configs/heists',
    MySQLTable = 'heistbuilder_heists'
}

Config.Reputation = {
    Enabled = true,
    Default = 0,
    Rewards = {
        success = 15,
        fail = -8,
        assist = 5
    }
}

Config.Evidence = {
    dnaChance = 35,
    printChance = 40,
    casingChance = 25,
    fibreChance = 20
}

Config.Dispatch = {
    resource = 'qbx_police',
    event = 'police:client:dispatch',
    lastKnownBlipTime = 30
}

Config.RewardPools = {
    cash = {
        min = 4500,
        max = 8000
    },
    items = {
        { item = 'markedbills', min = 1, max = 3 },
        { item = 'goldbar', min = 1, max = 2 }
    }
}

Config.Heists = {
    {
        id = 'fleeca_boulevard',
        label = 'Fleeca: Boulevar Del Perro',
        type = 'bank',
        tier = 2,
        minPlayers = 2,
        maxPlayers = 4,
        requiredPolice = 3,
        cooldownMinutes = 45,
        entryPoint = { x = -354.42, y = -55.17, z = 49.04 },
        escapeRadius = 50.0,
        reputationRequired = 200,
        steps = {
            { type = 'cut_power', label = 'Isolate Bank Feed', radius = 5.0, duration = 9.0 },
            { type = 'hack_panel', label = 'Hack Teller Panel', difficulty = 'hard', duration = 12.0 },
            { type = 'disable_alarm', label = 'Spoof Vault Alarm', duration = 8.0 },
            { type = 'thermal_charge', label = 'Breach Vault Door', duration = 14.0 },
            { type = 'drill_boxes', label = 'Drill Deposit Boxes', lockboxes = 6, duration = 18.0 },
            { type = 'grab_loot', label = 'Secure Cash Bags', lootType = 'cash', amount = 6 },
            { type = 'escape', label = 'Escape', radius = 60.0 }
        },
        guards = {
            { weapon = 'WEAPON_CARBINERIFLE', coords = { x = -353.41, y = -44.21, z = 49.04, w = 160.0 }, model = 's_m_m_security_01' }
        },
        rewards = {
            cash = { min = 120000, max = 180000 },
            items = {
                { item = 'goldbar', count = 2 },
                { item = 'markedbills', count = 5 }
            }
        },
        evidence = {
            dna = true,
            cctv = true,
            fibres = true
        }
    },
    -- 24/7 Stores
    {
        id = 'store_247_grove_street',
        label = '24/7 Store - Grove Street',
        type = 'store',
        tier = 1,
        minPlayers = 1,
        maxPlayers = 4,
        requiredPolice = 0,
        cooldownMinutes = 15,
        entryPoint = { x = 24.47, y = -1346.62, z = 29.50 },
        escapeRadius = 50.0,
        reputationRequired = 0,
        guards = {
            { weapon = 'WEAPON_PISTOL', coords = { x = 28.20, y = -1339.25, z = 29.50, w = 180.0 }, model = 's_m_m_security_01' }
        },
        tellers = {
            { coords = { x = 25.80, y = -1346.62, z = 29.50, w = 270.0 }, model = 's_f_y_shop_low' },
            { coords = { x = 23.20, y = -1346.62, z = 29.50, w = 90.0 }, model = 's_f_y_shop_low' }
        },
        cashRegisters = {
            { coords = { x = 24.47, y = -1344.62, z = 29.50 }, model = `prop_till_01`, minCash = 500, maxCash = 1500 },
            { coords = { x = 24.47, y = -1348.62, z = 29.50 }, model = `prop_till_01`, minCash = 500, maxCash = 1500 }
        },
        rewards = {
            cash = { min = 1000, max = 3000 }
        }
    },
    {
        id = 'store_247_rockford_hills',
        label = '24/7 Store - Rockford Hills',
        type = 'store',
        tier = 1,
        minPlayers = 1,
        maxPlayers = 4,
        requiredPolice = 0,
        cooldownMinutes = 15,
        entryPoint = { x = -48.55, y = -1757.50, z = 29.42 },
        escapeRadius = 50.0,
        reputationRequired = 0,
        guards = {
            { weapon = 'WEAPON_PISTOL', coords = { x = -44.50, y = -1750.20, z = 29.42, w = 50.0 }, model = 's_m_m_security_01' }
        },
        tellers = {
            { coords = { x = -47.20, y = -1756.62, z = 29.42, w = 140.0 }, model = 's_f_y_shop_low' }
        },
        cashRegisters = {
            { coords = { x = -48.55, y = -1755.62, z = 29.42 }, model = `prop_till_01`, minCash = 500, maxCash = 1500 },
            { coords = { x = -48.55, y = -1759.62, z = 29.42 }, model = `prop_till_01`, minCash = 500, maxCash = 1500 }
        },
        rewards = {
            cash = { min = 1000, max = 3000 }
        }
    },
    {
        id = 'store_247_sandy_shores',
        label = '24/7 Store - Sandy Shores',
        type = 'store',
        tier = 1,
        minPlayers = 1,
        maxPlayers = 4,
        requiredPolice = 0,
        cooldownMinutes = 15,
        entryPoint = { x = 1728.16, y = 6415.76, z = 35.04 },
        escapeRadius = 50.0,
        reputationRequired = 0,
        guards = {
            { weapon = 'WEAPON_PISTOL', coords = { x = 1732.20, y = 6422.25, z = 35.04, w = 240.0 }, model = 's_m_m_security_01' }
        },
        tellers = {
            { coords = { x = 1729.80, y = 6415.62, z = 35.04, w = 330.0 }, model = 's_f_y_shop_low' }
        },
        cashRegisters = {
            { coords = { x = 1728.16, y = 6416.62, z = 35.04 }, model = `prop_till_01`, minCash = 500, maxCash = 1500 },
            { coords = { x = 1728.16, y = 6414.62, z = 35.04 }, model = `prop_till_01`, minCash = 500, maxCash = 1500 }
        },
        rewards = {
            cash = { min = 1000, max = 3000 }
        }
    },
    {
        id = 'store_247_paleto_bay',
        label = '24/7 Store - Paleto Bay',
        type = 'store',
        tier = 1,
        minPlayers = 1,
        maxPlayers = 4,
        requiredPolice = 0,
        cooldownMinutes = 15,
        entryPoint = { x = 1697.39, y = 4922.52, z = 42.06 },
        escapeRadius = 50.0,
        reputationRequired = 0,
        guards = {
            { weapon = 'WEAPON_PISTOL', coords = { x = 1701.50, y = 4929.25, z = 42.06, w = 135.0 }, model = 's_m_m_security_01' }
        },
        tellers = {
            { coords = { x = 1699.20, y = 4922.62, z = 42.06, w = 225.0 }, model = 's_f_y_shop_low' }
        },
        cashRegisters = {
            { coords = { x = 1697.39, y = 4923.62, z = 42.06 }, model = `prop_till_01`, minCash = 500, maxCash = 1500 },
            { coords = { x = 1697.39, y = 4921.62, z = 42.06 }, model = `prop_till_01`, minCash = 500, maxCash = 1500 }
        },
        rewards = {
            cash = { min = 1000, max = 3000 }
        }
    },
    {
        id = 'store_247_north_rockford',
        label = '24/7 Store - North Rockford',
        type = 'store',
        tier = 1,
        minPlayers = 1,
        maxPlayers = 4,
        requiredPolice = 0,
        cooldownMinutes = 15,
        entryPoint = { x = 2549.40, y = 384.80, z = 108.62 },
        escapeRadius = 50.0,
        reputationRequired = 0,
        guards = {
            { weapon = 'WEAPON_PISTOL', coords = { x = 2553.50, y = 391.25, z = 108.62, w = 320.0 }, model = 's_m_m_security_01' }
        },
        tellers = {
            { coords = { x = 2551.20, y = 385.62, z = 108.62, w = 50.0 }, model = 's_f_y_shop_low' }
        },
        cashRegisters = {
            { coords = { x = 2549.40, y = 386.62, z = 108.62 }, model = `prop_till_01`, minCash = 500, maxCash = 1500 },
            { coords = { x = 2549.40, y = 384.62, z = 108.62 }, model = `prop_till_01`, minCash = 500, maxCash = 1500 }
        },
        rewards = {
            cash = { min = 1000, max = 3000 }
        }
    },
    {
        id = 'store_247_vespucci',
        label = '24/7 Store - Vespucci',
        type = 'store',
        tier = 1,
        minPlayers = 1,
        maxPlayers = 4,
        requiredPolice = 0,
        cooldownMinutes = 15,
        entryPoint = { x = -3242.97, y = 1000.01, z = 12.83 },
        escapeRadius = 50.0,
        reputationRequired = 0,
        guards = {
            { weapon = 'WEAPON_PISTOL', coords = { x = -3238.50, y = 1006.25, z = 12.83, w = 180.0 }, model = 's_m_m_security_01' }
        },
        tellers = {
            { coords = { x = -3241.20, y = 1000.62, z = 12.83, w = 270.0 }, model = 's_f_y_shop_low' }
        },
        cashRegisters = {
            { coords = { x = -3242.97, y = 1001.62, z = 12.83 }, model = `prop_till_01`, minCash = 500, maxCash = 1500 },
            { coords = { x = -3242.97, y = 999.62, z = 12.83 }, model = `prop_till_01`, minCash = 500, maxCash = 1500 }
        },
        rewards = {
            cash = { min = 1000, max = 3000 }
        }
    },
    {
        id = 'store_247_ineseno',
        label = '24/7 Store - Ineseno Road',
        type = 'store',
        tier = 1,
        minPlayers = 1,
        maxPlayers = 4,
        requiredPolice = 0,
        cooldownMinutes = 15,
        entryPoint = { x = -1819.53, y = 793.57, z = 138.08 },
        escapeRadius = 50.0,
        reputationRequired = 0,
        guards = {
            { weapon = 'WEAPON_PISTOL', coords = { x = -1815.50, y = 799.25, z = 138.08, w = 135.0 }, model = 's_m_m_security_01' }
        },
        tellers = {
            { coords = { x = -1818.20, y = 794.62, z = 138.08, w = 225.0 }, model = 's_f_y_shop_low' }
        },
        cashRegisters = {
            { coords = { x = -1819.53, y = 795.62, z = 138.08 }, model = `prop_till_01`, minCash = 500, maxCash = 1500 },
            { coords = { x = -1819.53, y = 793.62, z = 138.08 }, model = `prop_till_01`, minCash = 500, maxCash = 1500 }
        },
        rewards = {
            cash = { min = 1000, max = 3000 }
        }
    },
    {
        id = 'store_247_great_ocean',
        label = '24/7 Store - Great Ocean Highway',
        type = 'store',
        tier = 1,
        minPlayers = 1,
        maxPlayers = 4,
        requiredPolice = 0,
        cooldownMinutes = 15,
        entryPoint = { x = -706.06, y = -913.97, z = 19.22 },
        escapeRadius = 50.0,
        reputationRequired = 0,
        guards = {
            { weapon = 'WEAPON_PISTOL', coords = { x = -702.50, y = -907.25, z = 19.22, w = 50.0 }, model = 's_m_m_security_01' }
        },
        tellers = {
            { coords = { x = -705.20, y = -913.62, z = 19.22, w = 140.0 }, model = 's_f_y_shop_low' }
        },
        cashRegisters = {
            { coords = { x = -706.06, y = -912.62, z = 19.22 }, model = `prop_till_01`, minCash = 500, maxCash = 1500 },
            { coords = { x = -706.06, y = -914.62, z = 19.22 }, model = `prop_till_01`, minCash = 500, maxCash = 1500 }
        },
        rewards = {
            cash = { min = 1000, max = 3000 }
        }
    },
    -- Clothing Stores
    {
        id = 'store_clothing_ponsonbys',
        label = 'Ponsonbys - Rockford Hills',
        type = 'store',
        tier = 1,
        minPlayers = 1,
        maxPlayers = 4,
        requiredPolice = 0,
        cooldownMinutes = 20,
        entryPoint = { x = -1450.59, y = -236.70, z = 49.81 },
        escapeRadius = 50.0,
        reputationRequired = 0,
        guards = {
            { weapon = 'WEAPON_PISTOL', coords = { x = -1446.50, y = -230.25, z = 49.81, w = 320.0 }, model = 's_m_m_security_01' }
        },
        tellers = {
            { coords = { x = -1449.20, y = -236.62, z = 49.81, w = 50.0 }, model = 's_f_y_shop_low' },
            { coords = { x = -1451.80, y = -236.62, z = 49.81, w = 230.0 }, model = 's_f_y_shop_low' }
        },
        cashRegisters = {
            { coords = { x = -1450.59, y = -235.62, z = 49.81 }, model = `prop_till_01`, minCash = 800, maxCash = 2000 },
            { coords = { x = -1450.59, y = -237.62, z = 49.81 }, model = `prop_till_01`, minCash = 800, maxCash = 2000 }
        },
        rewards = {
            cash = { min = 1600, max = 4000 }
        }
    },
    {
        id = 'store_clothing_binco_davis',
        label = 'Binco - Davis',
        type = 'store',
        tier = 1,
        minPlayers = 1,
        maxPlayers = 4,
        requiredPolice = 0,
        cooldownMinutes = 20,
        entryPoint = { x = 72.25, y = -1399.10, z = 29.38 },
        escapeRadius = 50.0,
        reputationRequired = 0,
        guards = {
            { weapon = 'WEAPON_PISTOL', coords = { x = 76.50, y = -1393.25, z = 29.38, w = 180.0 }, model = 's_m_m_security_01' }
        },
        tellers = {
            { coords = { x = 73.80, y = -1399.62, z = 29.38, w = 270.0 }, model = 's_f_y_shop_low' },
            { coords = { x = 71.20, y = -1399.62, z = 29.38, w = 90.0 }, model = 's_f_y_shop_low' }
        },
        cashRegisters = {
            { coords = { x = 72.25, y = -1398.62, z = 29.38 }, model = `prop_till_01`, minCash = 800, maxCash = 2000 },
            { coords = { x = 72.25, y = -1400.62, z = 29.38 }, model = `prop_till_01`, minCash = 800, maxCash = 2000 }
        },
        rewards = {
            cash = { min = 1600, max = 4000 }
        }
    },
    {
        id = 'store_clothing_binco_hawick',
        label = 'Binco - Hawick',
        type = 'store',
        tier = 1,
        minPlayers = 1,
        maxPlayers = 4,
        requiredPolice = 0,
        cooldownMinutes = 20,
        entryPoint = { x = -822.19, y = -1071.93, z = 11.33 },
        escapeRadius = 50.0,
        reputationRequired = 0,
        guards = {
            { weapon = 'WEAPON_PISTOL', coords = { x = -818.50, y = -1066.25, z = 11.33, w = 50.0 }, model = 's_m_m_security_01' }
        },
        tellers = {
            { coords = { x = -821.20, y = -1072.62, z = 11.33, w = 140.0 }, model = 's_f_y_shop_low' }
        },
        cashRegisters = {
            { coords = { x = -822.19, y = -1071.62, z = 11.33 }, model = `prop_till_01`, minCash = 800, maxCash = 2000 },
            { coords = { x = -822.19, y = -1073.62, z = 11.33 }, model = `prop_till_01`, minCash = 800, maxCash = 2000 }
        },
        rewards = {
            cash = { min = 1600, max = 4000 }
        }
    },
    {
        id = 'store_clothing_suburban',
        label = 'Suburban - Burton',
        type = 'store',
        tier = 1,
        minPlayers = 1,
        maxPlayers = 4,
        requiredPolice = 0,
        cooldownMinutes = 20,
        entryPoint = { x = -1193.43, y = -767.28, z = 17.32 },
        escapeRadius = 50.0,
        reputationRequired = 0,
        guards = {
            { weapon = 'WEAPON_PISTOL', coords = { x = -1189.50, y = -761.25, z = 17.32, w = 140.0 }, model = 's_m_m_security_01' }
        },
        tellers = {
            { coords = { x = -1192.20, y = -767.62, z = 17.32, w = 230.0 }, model = 's_f_y_shop_low' },
            { coords = { x = -1194.80, y = -767.62, z = 17.32, w = 320.0 }, model = 's_f_y_shop_low' }
        },
        cashRegisters = {
            { coords = { x = -1193.43, y = -766.62, z = 17.32 }, model = `prop_till_01`, minCash = 800, maxCash = 2000 },
            { coords = { x = -1193.43, y = -768.62, z = 17.32 }, model = `prop_till_01`, minCash = 800, maxCash = 2000 }
        },
        rewards = {
            cash = { min = 1600, max = 4000 }
        }
    },
    {
        id = 'store_clothing_suburban_route',
        label = 'Suburban - Route 68',
        type = 'store',
        tier = 1,
        minPlayers = 1,
        maxPlayers = 4,
        requiredPolice = 0,
        cooldownMinutes = 20,
        entryPoint = { x = 617.20, y = 2759.23, z = 42.09 },
        escapeRadius = 50.0,
        reputationRequired = 0,
        guards = {
            { weapon = 'WEAPON_PISTOL', coords = { x = 621.50, y = 2765.25, z = 42.09, w = 225.0 }, model = 's_m_m_security_01' }
        },
        tellers = {
            { coords = { x = 618.80, y = 2759.62, z = 42.09, w = 315.0 }, model = 's_f_y_shop_low' }
        },
        cashRegisters = {
            { coords = { x = 617.20, y = 2760.62, z = 42.09 }, model = `prop_till_01`, minCash = 800, maxCash = 2000 },
            { coords = { x = 617.20, y = 2758.62, z = 42.09 }, model = `prop_till_01`, minCash = 800, maxCash = 2000 }
        },
        rewards = {
            cash = { min = 1600, max = 4000 }
        }
    },
    {
        id = 'store_clothing_discount',
        label = 'Discount Store - Strawberry',
        type = 'store',
        tier = 1,
        minPlayers = 1,
        maxPlayers = 4,
        requiredPolice = 0,
        cooldownMinutes = 20,
        entryPoint = { x = 127.83, y = -223.12, z = 54.56 },
        escapeRadius = 50.0,
        reputationRequired = 0,
        guards = {
            { weapon = 'WEAPON_PISTOL', coords = { x = 132.50, y = -217.25, z = 54.56, w = 320.0 }, model = 's_m_m_security_01' }
        },
        tellers = {
            { coords = { x = 129.80, y = -223.62, z = 54.56, w = 50.0 }, model = 's_f_y_shop_low' }
        },
        cashRegisters = {
            { coords = { x = 127.83, y = -222.62, z = 54.56 }, model = `prop_till_01`, minCash = 800, maxCash = 2000 },
            { coords = { x = 127.83, y = -224.62, z = 54.56 }, model = `prop_till_01`, minCash = 800, maxCash = 2000 }
        },
        rewards = {
            cash = { min = 1600, max = 4000 }
        }
    },
    {
        id = 'store_clothing_paleto',
        label = 'Discount Store - Paleto Bay',
        type = 'store',
        tier = 1,
        minPlayers = 1,
        maxPlayers = 4,
        requiredPolice = 0,
        cooldownMinutes = 20,
        entryPoint = { x = 5.81, y = 6511.01, z = 31.88 },
        escapeRadius = 50.0,
        reputationRequired = 0,
        guards = {
            { weapon = 'WEAPON_PISTOL', coords = { x = 10.50, y = 6517.25, z = 31.88, w = 135.0 }, model = 's_m_m_security_01' }
        },
        tellers = {
            { coords = { x = 7.80, y = 6511.62, z = 31.88, w = 225.0 }, model = 's_f_y_shop_low' }
        },
        cashRegisters = {
            { coords = { x = 5.81, y = 6512.62, z = 31.88 }, model = `prop_till_01`, minCash = 800, maxCash = 2000 },
            { coords = { x = 5.81, y = 6510.62, z = 31.88 }, model = `prop_till_01`, minCash = 800, maxCash = 2000 }
        },
        rewards = {
            cash = { min = 1600, max = 4000 }
        }
    }
}

return Config
