--[[
    ███╗   ██╗ █████╗ ███████╗███████╗        ██████╗ ███████╗██████╗ ███████╗ ██████╗ █████╗ ██╗     ███████╗██████╗ 
    ████╗  ██║██╔══██╗██╔════╝██╔════╝        ██╔══██╗██╔════╝██╔══██╗██╔════╝██╔════╝██╔══██╗██║     ██╔════╝██╔══██╗
    ██╔██╗ ██║███████║███████╗███████╗        ██████╔╝█████╗  ██║  ██║███████╗██║     ███████║██║     █████╗  ██████╔╝
    ██║╚██╗██║██╔══██║╚════██║╚════██║        ██╔═══╝ ██╔══╝  ██║  ██║╚════██║██║     ██╔══██║██║     ██╔══╝  ██╔══██╗
    ██║ ╚████║██║  ██║███████║███████║███████╗██║     ███████╗██████╔╝███████║╚██████╗██║  ██║███████╗███████╗██║  ██║
    ╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝     ╚══════╝╚═════╝ ╚══════╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝      
    
    https://discord.gg/nass 

    Please support the development of this script by joining our discord server.
]]

Config = {}
Config.locale = Locales["en"]

Config.commands = {
    openMenu = {
        enabled = true,
        command = "scale"
    },
    resetScale = {
        enabled = true,
        command = "resetscale"
    }
}

Config.permissions = {
    enabled = false, -- Set to false to allow everyone to use ped scaling
    defaultPermissions = {
        openSelf = true, -- Everyone can open their own scale menu
        openOther = false, -- Only admins can open others' scale menu (when permissions enabled)
        resetSelf = true, -- Everyone can reset their own scale
        resetOther = false, -- Only admins can reset others' scale (when permissions enabled)
    },
    acePermissions = {
        ["nass_fighting.scaler"] = {
            openSelf = true,
            openOther = true,
            resetSelf = true,
            resetOther = true,
        }
    }
}

Config.scaling = {
    min = 0.1, -- Minimum scale (10% of normal size - very small)
    max = 2.0, -- Maximum scale (200% of normal size - very tall)
    scaleSpeed = { --Not fully implemented yet, need to add some extra math for a more realisitc scaling effect
        enabled = false, --Make larger peds move faster and smaller peds move slower
        inverse = true, --Flip it around, so smaller peds move faster and larger peds move slower
    },
}