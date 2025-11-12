-- Job Center
-- Tech Development - https://discord.gg/tHAbhd94vS

Config = {}

Config.Framework = 'qbcore' -- esx/qbcore

Config.Coords = {
    vector3(-266.547, -960.9688, 30.22313)
}

Config.Language = "en"

Config.Lang = {
    ['it'] = {
        ['open_menu'] = "Premi ~INPUT_CONTEXT~ per accedere al ~b~Centro Lavori",
        ['select_favourite'] = "Scegli il tuo lavoro",
        ['job'] = "Preferito",
        ['job2'] = "CENTRO",
        ['center'] = "LAVORI",
        ['select'] = "Seleziona",
        ['selected'] = "Selezionato"
    },
    ['en'] = {
        ['open_menu'] = "Press ~INPUT_CONTEXT~ to access the ~b~Job Center",
        ['select_favourite'] = "Select your Favourite",
        ['job'] = "Job",
        ['job2'] = "JOB",
        ['center'] = "CENTER",
        ['select'] = "Select",
        ['selected'] = "Selected"
    },
    ['fr'] = {
        ['open_menu'] = "Appuyez sur ~INPUT_CONTEXT~ pour accéder au ~b~Centre d'emploi",
        ['select_favourite'] = "Sélectionnez votre favori",
        ['job'] = "Emploi",
        ['job2'] = "CENTRE",
        ['center'] = "EMPLOI",
        ['select'] = "Sélectionner",
        ['selected'] = "Sélectionné"
    },
}

Config.Jobs = {
    {
        label = "Civilian",
        id = "unemployed",
        description = "Leave the workforce and live off the land.",
    },
    {
        label = "Real Estate",
        id = "realestate",
        description = "Broker property deals and manage housing across the city.",
    },
    {
        label = "Taxi",
        id = "taxi",
        description = "Drive passengers safely to their destinations whenever needed.",
    },
    {
        label = "Bus",
        id = "bus",
        description = "Operate scheduled routes around the city as a bus driver.",
    },
    {
        label = "Vehicle Dealer",
        id = "cardealer",
        description = "Sell premium vehicles and handle finance agreements.",
    },
    {
        label = "Mechanic",
        id = "mechanic",
        description = "Repair, upgrade, and customize vehicles in the workshop.",
    },
    {
        label = "Law Firm",
        id = "lawyer",
        description = "Represent clients in court and handle legal paperwork.",
    },
    {
        label = "Reporter",
        id = "reporter",
        description = "Capture the latest stories and keep the city informed.",
    },
    {
        label = "Trucker",
        id = "trucker",
        description = "Haul freight across San Andreas and keep businesses stocked.",
    },
    {
        label = "Towing",
        id = "tow",
        description = "Recover stranded vehicles and keep traffic flowing smoothly.",
    },
    {
        label = "Garbage",
        id = "garbage",
        description = "Collect the city's waste and maintain clean streets.",
    },
    {
        label = "Vineyard",
        id = "vineyard",
        description = "Harvest grapes and produce quality wine.",
    },
    {
        label = "Hotdog",
        id = "hotdog",
        description = "Serve hot meals on the go to hungry citizens.",
    },
    {
        label = "Miner",
        id = "miner",
        description = "Extract valuable minerals from the mines and supply the market.",
    },
}

ShowHelpNotification = function(text)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, true, -1)
end
