Keys = {
    ['ESC'] = 322, ['F1'] = 288, ['F2'] = 289, ['F3'] = 170, ['F5'] = 166, ['F6'] = 167, ['F7'] = 168, ['F8'] = 169, ['F9'] = 56, ['F10'] = 57,
    ['~'] = 243, ['1'] = 157, ['2'] = 158, ['3'] = 160, ['4'] = 164, ['5'] = 165, ['6'] = 159, ['7'] = 161, ['8'] = 162, ['9'] = 163, ['-'] = 84, ['='] = 83, ['BACKSPACE'] = 177,
    ['TAB'] = 37, ['Q'] = 44, ['W'] = 32, ['E'] = 38, ['R'] = 45, ['T'] = 245, ['Y'] = 246, ['U'] = 303, ['P'] = 199, ['['] = 39, [']'] = 40, ['ENTER'] = 18,
    ['CAPS'] = 137, ['A'] = 34, ['S'] = 8, ['D'] = 9, ['F'] = 23, ['G'] = 47, ['H'] = 74, ['K'] = 311, ['L'] = 182,
    ['LEFTSHIFT'] = 21, ['Z'] = 20, ['X'] = 73, ['C'] = 26, ['V'] = 0, ['B'] = 29, ['N'] = 249, ['M'] = 244, [','] = 82, ['.'] = 81,
    ['LEFTCTRL'] = 36, ['LEFTALT'] = 19, ['SPACE'] = 22, ['RIGHTCTRL'] = 70,
    ['HOME'] = 213, ['PAGEUP'] = 10, ['PAGEDOWN'] = 11, ['DEL'] = 178,
    ['LEFT'] = 174, ['RIGHT'] = 175, ['TOP'] = 27, ['DOWN'] = 173,
}

Config = {}

Config.CoreName = "qb-core" ---- core name
Config.UseTargetSystem = true
Config.LetSystemManageRadar = true
Config.TargetScript = "qb-target" 
Config.SkillBarScript = "qb-skillbar"
Config.UsingOXTarget = false
Config.FadeScreenOut = true
Config.MenuScript = "qb-menu"
Config.Inventory = "qb-inventory"
Config.UsingNewQBInv = false -- if you using latest qbcore inventory versions, set to true
Config.JobManageScript = "qb-management"
Config.DebugOX = true -- if you use ox can be a good option
Config.InventoryImagesURL = "nui://jpr-inventory/html/images/" -- for getting inventory images, just need to follow inventory directory, if you want ox is: "nui://ox_inventory/web/images/" 
Config.TargetIcon = "fa-solid fa-house" --- target icon 
Config.PayTaxes = {
    enabled = true,
    interval = "INTERVAL 1 DAY",
    tax = 0.2, -- means 20% of house value
}
Config.TaxesOnSelling = 0.2 -- means 20% of house value

Config.RentingSystem = {
    enabled = true,
    intervalOfPayment = "INTERVAL 1 DAY",
    failedPaymentDaysToLoseHouse = 5,
    taxesData = { -- House price X main taxes X gov taxes X custom tax = final payment
        mainTax = 0.005, 
        govTax = 0.8, 
        customTax = 1.2
    } 
}

Config.AllowAnimations = true -- wine, whiskey, soda, bong
Config.PriceToVisit = 700

Config.ChangeStashCommand = 'changeStash'
Config.ChangeLogoutCommand = 'changeLogout'
Config.ChangeWardrobeCommand = 'changeWardrobe'
Config.RealEstateCommand = 'createNewHouse'
Config.RealEstateTierCommand = 'createNewTier'
Config.RealEstateDoorCommand = 'createNewDoors' 
Config.SellHouseCommand = 'sellHouse'
Config.DeleteHouseCommand = 'deleteHouse'
Config.RealEstateJob = 'realestate'
Config.ForceRefreshHousesCommand = 'refreshHouses'
Config.RealEstateManageCommand = 'manageHouses'

Config.HouseResetAfterSell = true
Config.MaxHousesPerApartment = 15
Config.AutoCloseDoor = true
Config.UseRealEstateAccounts = false
Config.MaxHousesPerPlayer = 8
Config.DiscordLogs = true
Config.DiscordWebhook = "https://discord.com/api/webhooks/1188151198335893665/pYJ93LfIGKywNFUnGNFvIcBpxxqxTkVZChOUl5Yq7UfNj6DisONfECrZTUFLNxwTxShN"

Config.AllowRobberySystem = true
Config.MinimumTime = 23
Config.MaximumTime = 6
Config.PoliceCountToRob = 2
Config.CallPoliceWhenRobbing = { --- IF THE HOUSE HAVE ALARM SYSTEM INSTALLED, NO MATHER THIS SETTINGS, IT WILL ALWAYS CALL COPS AND OWNER
    enabled = true, --- want to call police when someone stole house?
    alertOwner = true, --- alert house owner too?
    chance = 50, --- whats the chance to police gets a call?
}

Config.Extras = {
    alarm = 32500,
    securityCams = 6500
}

Config.AllowPoliceRaids = true
Config.DoorOpenedTime = 10 -- in minutes

Config.VehiclesTable = "player_vehicles"
Config.DoCarDamage = true

Config.DisableSellingBlips = false
Config.BlipSprite = 40
Config.BlipOfficeSprite = 475
Config.BlipSellingSprite = 350
Config.BlipOfficeSellingSprite = 476
Config.BlipColourOwner = 2
Config.BlipColourHolder = 7
Config.BlipColourSelling = 3
Config.BlipScale = 0.7
Config.BlipLabelOwner = "Own House"
Config.BlipLabelHolder = "Friends House"
Config.BlipLabelSelling = "House Available"
Config.BlipLabelOfficeSelling = "Office Available"

Config.GarageMarker = 24
Config.GarageColorMarker = {r = 255, g = 0, b = 0}
Config.GaragerSizeMarker = {x = 0.3, y = 0.3, z = 0.3}
Config.TargetVehicleIcon = "fa-solid fa-square-parking"
Config.AntiSpamVehicles = false ---- and two identical vehicles in the server at same moment ( anti spam)
Config.ShowAllVehiclesOnMenu = false -- if this is true, show all owned vehicles, if is false, just house parked vehicles
Config.MaxPlayers = 256

Config.FreezePlayerToForceLoad = false
Config.FreezeTime = 2000

Config.MinZOffset = 30 -- this is for shells system

Config.VehicleBlackList = {"bus"}

Config.FurnitureOutline = {
    enabled = true,
    color = {101, 43, 44},
    rotateModeColor = {222, 155, 40},
}

Config.FurnitureMarker = {
    enabled = true,
    color = {101, 43, 44},
    rotateModeColor = {222, 155, 40},
}

Config.GeneralMaxFurnitureRange = 50 -- once reached, will close furniture mode (MLO have their own property, this means, this setting is not valid for MLO)
Config.AllowMLOFurniture = true

Config.RotateKey = 170 -- F3

Config.Tiers = {
    -- office
    ["lowBankOffice"] = {
        doorCoords = vector4(-1579.43, -565.02, 108.52, 283.55),
        defaultStash = vector3(-1567.71, -587.1, 108.52),
        defaultWardrobe = vector3(-1564.86, -572.42, 108.52),
        defaultLogout = vector3(-1561.04, -568.1, 108.52),
        managementCoords = vector3(-1556.1, -574.7, 108.52),
        isOffice = true,
        whiskey = {coords = vector4(-1560.19, -574.18, 108.52, 22.64), command = "e whiskey", label = "whiskey"},
        iplList = {
            {ipl = "ex_sm_13_office_02b", price = 2000, name = "rich", interiorID = 241921, default = true}, -- dont change any name field - IMPORTANT
            {ipl = "ex_sm_13_office_02c", name = "cool", interiorID = 242177, price = 3000},
            {ipl = "ex_sm_13_office_02a", name = "contrast", interiorID = 241665, price = 4000},
            {ipl = "ex_sm_13_office_01a", name = "warm", interiorID = 240897, price = 5000},
            {ipl = "ex_sm_13_office_01b", name = "classical", interiorID = 241153, price = 6000},
            {ipl = "ex_sm_13_office_01c", name = "vintage", interiorID = 241409, price = 7000},
            {ipl = "ex_sm_13_office_03a", name = "ice", interiorID = 242433, price = 8000},
            {ipl = "ex_sm_13_office_03b", name = "conservative", interiorID = 242689, price = 9000},
            {ipl = "ex_sm_13_office_03c", name = "polished", interiorID = 242945, price = 10000}
        },
        previewImage = "officeShell",
    },
    -- appartment 
    ["highEndAppartment"] = {
        doorCoords = vector4(-785.3, 314.3, 187.91, 7.06),
        defaultStash = vector3(-796.35, 328.33, 187.31),
        defaultWardrobe = vector3(-797.74, 328.4, 190.71),
        defaultLogout = vector3(-800.11, 337.88, 190.71),
        managementCoords = vector3(-788.96, 320.68, 187.31),
        theme = "modern", -- modern, moody, vibrant, sharp, monochrome, seductive, regal, aqua
        colors = true,
        previewImage = "highEndAppartment",
    },
    ["highMediumAppartment"] = {
        doorCoords = vector4(-1452.92, -537.25, 74.04, 113.68),
        defaultStash = vector3(-1465.89, -525.98, 73.44),
        defaultWardrobe = vector3(-1449.92, -549.13, 72.84),
        defaultLogout = vector3(-1457.87, -550.38, 72.88),
        managementCoords = vector3(-1458.75, -527.9, 74.04),
        bong = {coords = vector4(-1466.41, -545.1, 73.28, 166.71), command = "e bong", label = "bong"},
        whiskey = {coords = vector4(-1462.33, -549.16, 73.24, 232.87), command = "e whiskey", label = "whiskey"},
        wine = {coords = vector4(-1472.81, -539.48, 73.44, 71.88), command = "e wine", label = "wine"},
        fridge = {coords = vector4(-1470.64, -534.76, 73.44, 317.38), fridgeItems = {interactions = {"beer", "soda", "champagne"}, interactionsCommands = {"e beer", "e soda", "e champagne"}}, label = "frigorifico"},
        previewImage = "highMediumAppartment",
    },
    ["lowMediumAppartment"] = {
        doorCoords = vector4(-893.36, -428.22, 121.61, 119.02),
        defaultStash = vector3(-899.57, -441.7, 121.62),
        defaultWardrobe = vector3(-909.87, -445.54, 115.41),
        defaultLogout = vector3(-913.04, -440.95, 115.4),
        managementCoords = vector3(-912.84, -453.41, 120.2),
        bong = {coords = vector4(-1466.41, -545.1, 73.28, 166.71), command = "e bong", label = "bong"},
        whiskey = {coords = vector4(-912.34, -436.24, 120.2, 311.91), command = "e whiskey", label = "whiskey"},
        wine = {coords = vector4(-908.57, -443.2, 120.2, 265.99), command = "e wine", label = "wine"},
        fridge = {coords = vector4(-900.22, -446.11, 120.2, 294.43), fridgeItems = {interactions = {"beer", "soda", "champagne"}, interactionsCommands = {"e beer", "e soda", "e champagne"}}, label = "frigorifico"},
        previewImage = "lowMediumAppartment",
    },
    -- mlo
    ["mloMichael"] = {
        doorCoords = vector4(-815.79, 178.56, 72.15, 289.64),
        defaultStash = vector3(-807.75, 181.21, 72.15),
        defaultWardrobe = vector3(-811.49, 175.19, 76.75),
        defaultLogout = vector3(-813.16, 181.91, 76.75),
        managementCoords = vector3(-804.64, 177.58, 72.83),
        whiskey = {coords = vector4(-800.34, 183.57, 72.61, 25.73), command = "e whiskey", label = "whiskey"},
        fridge = {coords = vector4(-803.45, 185.76, 72.61, 25.41), fridgeItems = {interactions = {"beer", "soda", "champagne"}, interactionsCommands = {"e beer", "e soda", "e champagne"}}, label = "frigorifico"},
        previewImage = "mloMichael",
        isMLO = true,
    },
    ["mloFranklin"] = {
        doorCoords = vector4(7.76, 538.74, 176.03, 148.44),
        defaultStash = vector3(0.21, 526.72, 170.62),
        defaultWardrobe = vector3(9.4, 528.69, 170.63),
        defaultLogout = vector3(9.74, 530.42, 174.64),
        managementCoords = vector3(6.7, 538.13, 176.03),
        fridge = {coords = vector4(-11.85, 516.66, 174.63, 62.47), fridgeItems = {interactions = {"beer", "soda", "champagne"}, interactionsCommands = {"e beer", "e soda", "e champagne"}}, label = "frigorifico"},
        previewImage = "mloFranklin",
        isMLO = true,
    },
    -- shells
    ["ApartmentLowShell"] = {
        doorCoords = vector4(4.693, -6.015, 1.11, 358.63), -- "offsets"
        defaultStash = vector3(0.0, 0.0, 0.0), -- auto generated
        defaultWardrobe = vector3(0.0, 0.0, 0.0), -- auto generated
        defaultLogout = vector3(0.0, 0.0, 0.0), -- auto generated
        managementCoords = vector3(0.0, 0.0, 0.0), -- auto generated
        previewImage = "shell_v16low",
        model = "shell_v16low",
        isShell = true,
    },
    ["ApartmentMidShell"] = {
        doorCoords = vector4(1.561, -14.305, 1.147, 2.263), -- "offsets"
        defaultStash = vector3(0.0, 0.0, 0.0), -- auto generated
        defaultWardrobe = vector3(0.0, 0.0, 0.0), -- auto generated
        defaultLogout = vector3(0.0, 0.0, 0.0), -- auto generated
        managementCoords = vector3(0.0, 0.0, 0.0), -- auto generated
        previewImage = "shell_v16mid",
        model = "shell_v16mid",
        isShell = true,
    },
    ["TrevorShell"] = {
        doorCoords = vector4(0.374, -3.789, 2.428, 358.63), -- "offsets"
        defaultStash = vector3(0.0, 0.0, 0.0), -- auto generated
        defaultWardrobe = vector3(0.0, 0.0, 0.0), -- auto generated
        defaultLogout = vector3(0.0, 0.0, 0.0), -- auto generated
        managementCoords = vector3(0.0, 0.0, 0.0), -- auto generated
        previewImage = "shell_trevor",
        model = "shell_trevor",
        isShell = true,
    },
    ["CaravanShell"] = {
        doorCoords = vector4(-1.4, -2.1, 3.3, 358.633972), -- "offsets"
        defaultStash = vector3(0.0, 0.0, 0.0), -- auto generated
        defaultWardrobe = vector3(0.0, 0.0, 0.0), -- auto generated
        defaultLogout = vector3(0.0, 0.0, 0.0), -- auto generated
        managementCoords = vector3(0.0, 0.0, 0.0), -- auto generated
        previewImage = "shell_trailer",
        model = "shell_trailer",
        isShell = true,
    },
    ["LesterShell"] = {
        doorCoords = vector4(-1.780, -0.795, 1.1, 270.30), -- "offsets"
        defaultStash = vector3(0.0, 0.0, 0.0), -- auto generated
        defaultWardrobe = vector3(0.0, 0.0, 0.0), -- auto generated
        defaultLogout = vector3(0.0, 0.0, 0.0), -- auto generated
        managementCoords = vector3(0.0, 0.0, 0.0), -- auto generated
        previewImage = "shell_lester",
        model = "shell_lester",
        isShell = true,
    },
    ["RanchShell"] = {
        doorCoords = vector4(-1.257, -5.469, 2.5, 270.57), -- "offsets"
        defaultStash = vector3(0.0, 0.0, 0.0), -- auto generated
        defaultWardrobe = vector3(0.0, 0.0, 0.0), -- auto generated
        defaultLogout = vector3(0.0, 0.0, 0.0), -- auto generated
        managementCoords = vector3(0.0, 0.0, 0.0), -- auto generated
        previewImage = "madrazoRanch",
        model = "shell_ranch",
        isShell = true,
    },
    ["FurniMotelModern"] = {
        doorCoords = vector4(4.98, 4.35, 1.16, 179.79), -- "offsets"
        defaultStash = vector3(0.0, 0.0, 0.0), -- auto generated
        defaultWardrobe = vector3(0.0, 0.0, 0.0), -- auto generated
        defaultLogout = vector3(0.0, 0.0, 0.0), -- auto generated
        managementCoords = vector3(0.0, 0.0, 0.0), -- auto generated
        previewImage = "modernhotel_shell",
        model = "modernhotel_shell",
        isShell = true,
    },
    ["FranklinAunt"] = {
        doorCoords = vector4(-0.36, -5.89, 1.70, 358.21), -- "offsets"
        defaultStash = vector3(0.0, 0.0, 0.0), -- auto generated
        defaultWardrobe = vector3(0.0, 0.0, 0.0), -- auto generated
        defaultLogout = vector3(0.0, 0.0, 0.0), -- auto generated
        managementCoords = vector3(0.0, 0.0, 0.0), -- auto generated
        previewImage = "shell_frankaunt",
        model = "shell_frankaunt",
        isShell = true,
    },
    ["Warehouse1"] = {
        doorCoords = vector4(-8.95, 0.51, 1.04, 268.82), -- "offsets"
        defaultStash = vector3(0.0, 0.0, 0.0), -- auto generated
        defaultWardrobe = vector3(0.0, 0.0, 0.0), -- auto generated
        defaultLogout = vector3(0.0, 0.0, 0.0), -- auto generated
        managementCoords = vector3(0.0, 0.0, 0.0), -- auto generated
        previewImage = "shell_warehouse1",
        model = "shell_warehouse1",
        isShell = true,
    },
    -- houses
    ["highEndStyle2"] = {
        doorCoords = vector4(-859.87, 691.01, 152.86, 184.99),
        defaultStash = vector3(-859.12, 674.9, 149.06),
        defaultWardrobe = vector3(-855.37, 680.35, 149.05),
        defaultLogout = vector3(-852.01, 676.96, 149.08),
        managementCoords = vector3(-859.42, 679.79, 152.65),
        bong = {coords = vector4(-855.33, 674.52, 152.48, 260.93), command = "e bong", label = "bong"},
        whiskey = {coords = vector4(-859.17, 675.06, 152.45, 126.24), command = "e whiskey", label = "whiskey"},
        wine = {coords = vector4(-856.97, 687.05, 152.85, 195.59), command = "e wine", label = "wine"},
        fridge = {coords = vector4(-857.42, 688.51, 152.85, 354.97), fridgeItems = {interactions = {"beer", "soda", "champagne"}, interactionsCommands = {"e beer", "e soda", "e champagne"}}, label = "frigorifico"},
        previewImage = "highEndStyle2",
    },
    ["highEnd"] = {
        doorCoords = vector4(-758.52, 618.88, 144.15, 106.55),
        defaultStash = vector3(-773.56, 613.26, 140.33),
        defaultWardrobe = vector3(-767.04, 611.16, 140.33),
        defaultLogout = vector3(-772.44, 606.45, 140.35),
        managementCoords = vector3(-768.74, 614.7, 143.92),
        bong = {coords = vector4(-772.74, 609.52, 143.75, 204.89), command = "e bong", label = "bong"},
        whiskey = {coords = vector4(-773.35, 613.44, 143.73, 19.19), command = "e whiskey", label = "whiskey"},
        wine = {coords = vector4(-760.94, 614.27, 144.14, 117.3), command = "e wine", label = "wine"},
        fridge = {coords = vector4(-759.37, 614.98, 144.14, 281.88), fridgeItems = {interactions = {"beer", "soda", "champagne"}, interactionsCommands = {"e beer", "e soda", "e champagne"}}, label = "frigorifico"},
        previewImage = "highEnd",
    },
    ["madrazoRanch"] = {
        doorCoords = vector4(1396.39, 1142.09, 114.33, 274.08),
        defaultStash = vector3(1399.99, 1139.85, 114.33),
        defaultWardrobe = vector3(1401.85, 1134.91, 114.33),
        defaultLogout = vector3(1397.26, 1131.73, 114.33),
        managementCoords = vector3(1399.16, 1161.22, 114.33),
        whiskey = {coords = vector4(1402.01, 1130.75, 114.33, 204.46), command = "e whiskey", label = "whiskey"},
        fridge = {coords = vector4(1394.72, 1150.03, 114.33, 37.7), fridgeItems = {interactions = {"beer", "soda", "champagne"}, interactionsCommands = {"e beer", "e soda", "e champagne"}}, label = "frigorifico"},
        previewImage = "madrazoRanch",
    },
    ["miniInterior"] = {
        doorCoords = vector4(-1902.06, -572.25, 19.1, 141.18),
        defaultStash = vector3(-1911.45, -569.47, 19.1),
        defaultWardrobe = vector3(-1909.39, -571.24, 19.1),
        defaultLogout = vector3(-1906.31, -577.26, 19.09),
        managementCoords = vector3(-1904.66, -570.88, 19.1),
        previewImage = "miniInterior",
    },
    ["motelRoom"] = {
        doorCoords = vector4(151.61, -1007.17, -99.1, 317.99),
        defaultStash = vector3(151.31, -1003.44, -99.1),
        defaultWardrobe = vector3(151.85, -1000.65, -99.1),
        defaultLogout = vector3(154.34, -1003.27, -99.1),
        managementCoords = vector3(153.65, -1007.09, -99.1),
        previewImage = "motelRoom",
    },
    ["mediumEnd"] = {
        doorCoords = vector4(346.45, -1013.01, -99.2, 356.76),
        defaultStash = vector3(346.2, -1001.87, -99.2),
        defaultWardrobe = vector3(350.77, -993.59, -99.19),
        defaultLogout = vector3(349.79, -997.49, -99.19),
        managementCoords = vector3(339.75, -1000.37, -99.2),
        whiskey = {coords = vector4(342.39, -1001.58, -99.2, 88.72), command = "e whiskey", label = "whiskey"},
        previewImage = "mediumEnd",
    },
    ["lowEnd"] = {
        doorCoords = vector4(265.88, -1007.22, -101.01, 355.37),
        defaultStash = vector3(265.89, -999.34, -99.01),
        defaultWardrobe = vector3(259.44, -1004.1, -99.01),
        defaultLogout = vector3(263.24, -1003.87, -98.32),
        managementCoords = vector3(262.46, -999.88, -99.01),
        bong = {coords = vector4(259.08, -995.95, -99.01, 108.69), command = "e bong", label = "bong"},
        previewImage = "lowEnd",
    },
    -- garages
    ["modGarage"] = {
        isGarage = true,
        doorCoords = vector3(-138.79, -588.21, 167.1),
        slots = {
            vector4(-151.83, -598.23, 167.1, 238.95),
            vector4(-148.37, -594.66, 167.1, 208.2),
            vector4(-144.15, -590.91, 167.1, 174.87)
        },
        previewImage = "modGarage",
    },
    ["importGarage"] = {
        isGarage = true,
        doorCoords = vector3(970.41, -2987.23, -39.65),
        slots = {
            vector4(989.71, -2992.45, -39.65, 193.83),
            vector4(996.19, -2993.08, -39.65, 165.4),
            vector4(1001.11, -2992.51, -39.65, 153.1),
        },
        previewImage = "importGarage",
    },
    ["lowGarage"] = {
        isGarage = true,
        doorCoords = vector3(179.12, -1000.14, -99.1),
        slots = {
            vector4(171.16, -1004.44, -99.1, 180.58),
            vector4(174.91, -1003.64, -99.1, 179.68)
        },
        previewImage = "lowGarage",
    },
    ["ExclusiveGarage"] = {
        isGarage = true,
        doorCoords = vector3(-1066.96, -86.05, -90.2),
        slots = {
            vector4(-1078.89, -68.17, -90.52, 248.39), --
            vector4(-1078.89, -72.71, -90.52, 270.06),
            vector4(-1078.89, -76.67, -90.52, 270.06),
            vector4(-1078.89, -80.83, -90.52, 270.06),
            vector4(-1078.89, -84.98, -90.52, 270.06), -- -1lvl (5 parking spaces)
            vector4(-1078.89, -85.02, -94.92, 270.06), -- 
            vector4(-1078.89, -80.95, -94.92, 270.06),
            vector4(-1078.89, -76.69, -94.92, 270.06),
            vector4(-1078.89, -72.87, -94.92, 270.06),
            vector4(-1078.89, -68.37, -94.92, 244.1),
            vector4(-1066.26, -64.34, -94.92, 90.16),
            vector4(-1066.27, -68.61, -94.92, 90.16),
            vector4(-1066.27, -72.82, -94.92, 90.16),
            vector4(-1066.27, -76.66, -94.92, 90.16),
            vector4(-1066.27, -81.01, -94.92, 68.26), -- -2lvl (10 parking spaces)
            vector4(-1078.89, -85.02, -99.32, 270.06), -- 
            vector4(-1078.89, -80.95, -99.32, 270.06),
            vector4(-1078.89, -76.69, -99.32, 270.06),
            vector4(-1078.89, -72.87, -99.32, 270.06),
            vector4(-1078.89, -68.37, -99.32, 244.1),
            vector4(-1066.26, -64.34, -99.32, 90.16),
            vector4(-1066.27, -68.61, -99.32, 90.16),
            vector4(-1066.27, -72.82, -99.32, 90.16),
            vector4(-1066.27, -76.66, -99.32, 90.16),
            vector4(-1066.27, -81.01, -99.32, 68.26), -- -3lvl (10 parking spaces)
        },
        previewImage = "ExclusiveGarage",
    },
    ["midGarage"] = {
        isGarage = true,
        doorCoords = vector3(207.18, -998.93, -99.1),
        slots = {
            vector4(203.67, -1000.36, -99.1, 185.06),
            vector4(200.71, -1000.38, -99.1, 179.39),
            vector4(197.37, -1000.32, -99.1, 179.85),
            vector4(193.29, -1000.11, -99.1, 179.07)
        },
        previewImage = "midGarage",
    },
    ["highGarage"] = {
        isGarage = true,
        doorCoords = vector3(238.43, -1004.79, -99.1),
        slots = {
            vector4(233.35, -998.1, -99.1, 56.17),
            vector4(233.44, -994.47, -99.1, 50.37),
            vector4(233.43, -990.96, -99.1, 41.23),
            vector4(233.61, -986.08, -99.1, 35.72),
            vector4(233.55, -981.42, -99.1, 33.23),
            vector4(224.45, -979.51, -99.1, 245.75),
            vector4(223.85, -985.28, -99.1, 258.25),
            vector4(223.89, -991.75, -99.1, 214.6),
            vector4(223.74, -997.82, -99.1, 223.84),
            vector4(224.22, -1002.92, -99.1, 244.8),
        },
        previewImage = "highGarage",
    },
    ["neonGarage"] = {
        isGarage = true,
        isNeon = true,
        doorCoords = vector3(529.51, -2637.73, -49.1),
        slots = {
            vector4(524.55, -2632.34, -49.1, 110.53),
            vector4(525.04, -2628.17, -49.1, 120.84),
            vector4(525.22, -2624.29, -49.1, 128.26),
            vector4(525.18, -2620.31, -49.1, 141.39),
            vector4(525.16, -2615.45, -49.1, 144.87),
            vector4(514.96, -2634.25, -49.1, 219.16),
            vector4(515.05, -2629.99, -49.1, 218.46),
            vector4(514.86, -2625.51, -49.1, 228.37),
            vector4(514.87, -2620.13, -49.1, 220.39),
            vector4(514.98, -2615.91, -49.1, 222.72),
            vector4(514.85, -2611.6, -49.1, 230.18),
            vector4(523.71, -2611.21, -49.1, 93.58),
        },
        defaultNeon = 3, -- 1 to 8
        previewImage = "neon1",
    }
}

Config.AppartmentsInteriorPrices = { -- price for changing shells
    modern = 500,
    moody = 600,
    vibrant = 700,
    sharp = 800,
    monochrome = 900,
    seductive = 488,
    regal = 462,
    aqua = 562
}

Config.NeonInteriorPrices = { -- price for changing shells
    neon1 = 500,
    neon2 = 600,
    neon3 = 700,
    neon4 = 800,
    neon5 = 900,
    neon6 = 488,
    neon7 = 462,
    neon8 = 562
}

Config.Houses = {
    ["Testing House"] = { -- House name, MUST BE UNIQUE OTHER WISE WILL HAVE ERRORS
        houseName = "Testing House", -- House name, MUST BE UNIQUE OTHER WISE WILL HAVE ERRORS
        price = 20000, -- House price
        doorCoords = vector4(119.33, 564.12, 183.96, 19.58), -- House door coords
        doorInside = Config.Tiers["highEnd"], -- House inside infos
        houseGarage = {
            enabled = true, -- House garage enabled ?
            isNonInteriorGarage = false, -- This garage have interior ? (false = yes, no = true)
            coords = vector3(128.1, 565.98, 183.97), -- House garage door
            doorInside = Config.Tiers["modGarage"], -- House garage inside infos
            storeCar = vector3(131.78, 567.3, 183.61), -- House garage car storage
            spawnCar = vector4(131.93, 567.38, 183.59, 0.83), -- House garage car spawn
        },
        stars = 4, -- House rating
        pool = true, -- House have a pool?
        garden = true, -- House have a garden?
        camerasystem = true, -- House have a camera?
        canVisit = true, -- House can be visited?
        stashLevel = 1, -- What level is default level of stash?
        stashName = "testingStash", -- Stash name, must be unique, if same name houses can share their stash
        shared = false, -- is it a appartment?
        description = "Modern House with pool, garen, camara system and visiting options! Cheap!" -- House description
    },

    ["StartingApartment"] = { -- House name, MUST BE UNIQUE OTHER WISE WILL HAVE ERRORS
        houseName = "StartingApartment", -- House name, MUST BE UNIQUE OTHER WISE WILL HAVE ERRORS
        price = 80000, -- House price
        doorCoords = vector4(-667.07, -1105.23, 14.63, 66.36), -- House door coords
        doorInside = Config.Tiers["lowEnd"], -- House inside infos
        houseGarage = {
            enabled = false, -- House garage enabled ?
            isNonInteriorGarage = false, -- This garage have interior ? (false = yes, no = true)
            coords = vector3(128.1, 565.98, 183.97), -- House garage door
            doorInside = Config.Tiers["lowGarage"], -- House garage inside infos
            storeCar = vector3(131.78, 567.3, 183.61), -- House garage car storage
            spawnCar = vector4(131.93, 567.38, 183.59, 0.83), -- House garage car spawn
        },
        stars = 3, -- House rating
        pool = false, -- House have a pool?
        garden = false, -- House have a garden?
        camerasystem = true, -- House have a camera?
        canVisit = true, -- House can be visited?
        stashLevel = 1, -- What level is default level of stash?
        stashName = "StartingApartmentStash", -- Stash name, must be unique, if same name houses can share their stash
        shared = true, -- is it a appartment?
        description = "Modern Apartment! Cheap!", -- House description
        isAnStartingApartment = true,
    },

    ["mloTestingHouse"] = { -- House name, MUST BE UNIQUE OTHER WISE WILL HAVE ERRORS
        houseName = "mloTestingHouse", -- House name, MUST BE UNIQUE OTHER WISE WILL HAVE ERRORS
        price = 125000, -- House price
        maxFurnitureRange = 45,
        doorCoords = vector4(-816.86, 178.08, 72.23, 205.72), -- House door coords
        doorInside = Config.Tiers["mloMichael"], -- House inside infos
        houseGarage = {
            enabled = true, -- House garage enabled ?
            isNonInteriorGarage = true, -- This garage have interior ? (false = yes, no = true)
            coords = vector3(-815.35, 183.06, 72.43), -- House garage door
            doorInside = Config.Tiers["modGarage"], -- House garage inside infos
            storeCar = vector3(-812.13, 187.36, 72.47), -- House garage car storage
            spawnCar = vector4(-811.69, 187.62, 72.48, 117.85), -- House garage car spawn
        },
        stars = 4, -- House rating
        pool = true, -- House have a pool?
        garden = true, -- House have a garden?
        camerasystem = true, -- House have a camera?
        canVisit = true, -- House can be visited?
        stashLevel = 1, -- What level is default level of stash?
        stashName = "mloTestingHouse", -- Stash name, must be unique, if same name houses can share their stash
        mlo = true, -- is it a MLO?
        description = "Modern House with pool, garen, camara system and visiting options! Cheap!" -- House description
    },

    ["mloTestingHouse2"] = { -- House name, MUST BE UNIQUE OTHER WISE WILL HAVE ERRORS
        houseName = "mloTestingHouse2", -- House name, MUST BE UNIQUE OTHER WISE WILL HAVE ERRORS
        price = 125000, -- House price
        maxFurnitureRange = 45,
        doorCoords = vector4(8.37, 539.73, 176.03, 341.19), -- House door coords
        doorInside = Config.Tiers["mloFranklin"], -- House inside infos
        houseGarage = {
            enabled = true, -- House garage enabled ?
            isNonInteriorGarage = false, -- This garage have interior ? (false = yes, no = true)
            coords = vector3(25.02, 541.02, 176.03), -- House garage door
            doorInside = Config.Tiers["modGarage"], -- House garage inside infos
            storeCar = vector3(22.56, 544.11, 176.03), -- House garage car storage
            spawnCar = vector4(14.44, 549.54, 176.3, 49.25), -- House garage car spawn
        },
        stars = 5, -- House rating
        pool = true, -- House have a pool?
        garden = true, -- House have a garden?
        camerasystem = true, -- House have a camera?
        canVisit = true, -- House can be visited?
        stashLevel = 1, -- What level is default level of stash?
        stashName = "mloTestingHouse2", -- Stash name, must be unique, if same name houses can share their stash
        mlo = true, -- is it a MLO?
        description = "Modern House with pool, garen, camara system and visiting options! Cheap!" -- House description
    },
}

Config.Locales = { -- All translations in Lua files
    ["1"] = "View property information",
    ["2"] = "Enter the house",
    ["3"] = "Exit the house",
    ["4"] = "House management",
    ["5"] = "Try ",
    ["6"] = "Open",
    ["7"] = "Stash",
    ["8"] = "Wardrobe",
    ["9"] = "Logout",
    ["10"] = "You have removed the keys from ",
    ["11"] = "You don't have enough money, amount: ",
    ["12"] = "Operation completed successfully",
    ["13"] = "An error occurred",
    ["14"] = "Visit",
    ["15"] = "You rang the doorbell successfully",
    ["16"] = "There doesn't appear to be anyone at home",
    ["17"] = "Someone is ringing the doorbell",
    ["18"] = "Check doorbell",
    ["19"] = "Doorbell",
    ["20"] = "No one is outside",
    ["21"] = "Close menu",
    ["22"] = "Enter the garage",
    ["23"] = "Exit the garage",
    ["24"] = "Store vehicle",
    ["25"] = "Garage is full",
    ["26"] = "This vehicle is not yours",
    ["27"] = "Saved successfully",
    ["28"] = "Use vehicle",
    ["29"] = "An identical vehicle already exists on the streets",
    ["30"] = "Visit garage",
    ["31"] = "You can't do this",
    ["32"] = "Check cameras",
    ["33"] = "Exit cameras",
    ["34"] = "Property tax payment, name, and amount: ",
    ["35"] = "You owe property tax payments, name, and amount: ",
    ["36"] = "€",
    ["37"] = "Create a new house",
    ["38"] = "Only players with a real estate agency job can use this command",
    ["39"] = "whiskey",
    ["40"] = "wine",
    ["41"] = "Unknown",
    ["42"] = "This vehicle is already stored!",
    ["43"] = "Sell your current house",
    ["44"] = "Do the command again to confirm your action",
    ["45"] = "This house is not ours",
    ["46"] = "You are not inside any house",
    ["47"] = "An error ocorred",
    ["48"] = "Delete closest house",
    ["49"] = "No house near you ( Go to house entrie door )",
    ["50"] = "You successfully sold the house",
    ["51"] = "House deleted with success",
    ["52"] = "This house is not created by Real Estate or is already bought",
    ["53"] = "Rob house",
    ["54"] = "Not enough police on server, needs: ",
    ["55"] = "Robbery started",
    ["56"] = "House robbery in progress",
    ["57"] = "You cant do this now, minimum hours: ",
    ["58"] = "Too bad, try again",
    ["59"] = "Nice, now pay attention...",
    ["60"] = "Someone is lockpicking your house, house on GPS",
    ["61"] = "Money has been returned, house limit reached: ",
    ["62"] = "Tried to bought a house when he already is on limit.",
    ["63"] = "Bought a house, named: ",
    ["64"] = "Sold a house",
    ["65"] = "Deleted a house",
    ["66"] = "Created a house named: ",
    ["67"] = "Used wardrobe of house: ",
    ["68"] = "Used stash of house, stash name: ",
    ["69"] = "Used house management of house: ",
    ["70"] = "Upgraded stash of house: ",
    ["71"] = "Upgraded theme of house: ",
    ["72"] = "Upgraded theme of office: ",
    ["73"] = "Upgraded theme of garage: ",
    ["74"] = "Switched texture of appartment: ",
    ["75"] = "Have their key deleted from house: ",
    ["76"] = "Used logout option",
    ["77"] = "Have a new key of house: ",
    ["78"] = "Is robbing house: ",
    ["79"] = "An error occurred, please try again!",
    ["80"] = "House name already exists!",
    ["81"] = "You cant rob this type of house.",
    ["82"] = "Leaving property, closing door.",
    ["83"] = "This building is full.",
    ["84"] = "Try interaction",
    ["85"] = "[~g~E~w~] Open interactions",
    ["86"] = "This vehicle is blacklisted",
    ["87"] = "Furniture purchased with success!",
    ["88"] = "This prop have problems!",
    ["89"] = "Interact with house doors!",
    ["90"] = "🚪🔓",
    ["91"] = "🚪🔐",
    ["92"] = "🚪🔐",
    ["93"] = "🚪🔓",
    ["94"] = "Sorry, we cant do this now",
    ["95"] = "You got too far from house",
    ["96"] = "Error loading the shell",
    ["97"] = "Dont forget to update your housing markers (stash, logout, wardrobe) using right commands",
    ["98"] = "Sell house: ",
    ["99"] = "Create a new tier",
    ["100"] = "Created a tier named: ",
    ["101"] = "Tier name already exists!",
    ["102"] = "Create a new door",
    ["103"] = "Created a new door",
    ["104"] = "All done.",
    ["105"] = "This is only possible for emergency services!",
    ["106"] = "Join raided house",
    ["107"] = "An raid is already on process, please wait.",
    ["108"] = "The door is now open.",
    ["109"] = "It failed try again",
    ["110"] = "Cant raid this type of houses",
    ["111"] = "Police officers cant perform this actions",
    ["112"] = "You got an invite to visit an house/garage, to accept press [E]",
    ["113"] = "Invite expired",
    ["114"] = "Property renting payment, name and amount: ",
    ["115"] = "You owe property renting payments, name, amount and tries: ",
    ["116"] = "You lost your house due to lack of rent payment.",
    ["117"] = "You successfully sold the house, as rental, you do not receive money.",
    ["118"] = "No vehicle inside the garage",
    ["119"] = "Entity Information",
    ["120"] = "Model hash:",
    ["121"] = "Object name:",
    ["122"] = "Entity ID:",
    ["123"] = "Net ID:",
    ["124"] = "Unkown",
    ["125"] = "Distance:",
    ["126"] = "Heading:",
    ["127"] = "Press [~r~E~w~] to \n add the door to MLO house.\n Press [~r~BACKSPACE~w~] to cancel",
}

Config.MaxLevelStash = 6 ---- max stash level
Config.StashLevel = { ---- all stash levels, benefits and price, yes you can add a new one changing above this line to maxium value and under this line add a new level
    ["1"] = {
        slots = 15,
        kg = 150000,
        price = 0
    },
    ["2"] = {
        slots = 25,
        kg = 200000,
        price = 50000
    },
    ["3"] = {
        slots = 45,
        kg = 260000,
        price = 80000
    },
    ["4"] = {
        slots = 55,
        kg = 310000,
        price = 100000
    },
    ["5"] = {
        slots = 75,
        kg = 380000,
        price = 120000
    },
    ["6"] = {
        slots = 85,
        kg = 450000,
        price = 140000
    },
}

Config.CustomStashLevels = { -- if you want to set some house different than default (default is Config.StashLevel)
    ["mloTestingHouse"] = {
        MaxLevelStash = 3,
        StashLevel = {
            ["1"] = {
                slots = 15,
                kg = 150000,
                price = 0
            },
            ["2"] = {
                slots = 25,
                kg = 200000,
                price = 50000
            },
            ["3"] = {
                slots = 45,
                kg = 260000,
                price = 80000
            },
        }
    },
}

if Config.TargetScript == "ox-target" then
    Config.TargetScript = "ox_target"
end