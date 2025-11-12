config = {}

-- target resource (only one of these can be true)
-------------------------------------------------------
config.qbtarget = true  
config.oxtarget = false  
-------------------------------------------------------


config.pedmodel = 'a_m_m_prolhost_01' -- ped model hash

config.scenario = 'WORLD_HUMAN_CLIPBOARD' -- scenario for ped to play, false to disable

config.locations = {
    ['airport'] = {
        ped = true, -- if false uses boxzone (below)

        coords = vector4(-1035.0924, -2733.2678, 20.1693, 157.2091),

        blip = {
            sprite = 227,
            colour = 2,
            scale = 0.8,
            shortRange = true,
            label = 'Vehicle Rentals'
        },
        
        -------- boxzone (only used if ped is false) --------

        length = 1.0,  
        width = 1.0,   
        minZ = 30.81,  
        maxZ = 30.81,  
        debug = false, 

        -----------------------------------------------------
        vehicles = {
            ['asea']        = {     -- vehicle model name
                price = 250,        -- ['vehicle'] = price
                image = 'https://i.imgur.com/gpw2CNy.png',      -- image for menu, false for no image
            },
            ['sentinel']    = {
                price = 500, 
                image = 'https://i.imgur.com/LheKlzT.png',
            },
            ['bison']       = {
                price = 1000, 
                image = 'https://i.imgur.com/uOvGpSy.png',
            },
            ['patriot']     = {
                price = 1500, 
                image = 'https://i.imgur.com/LsqIPvJ.png',
            },
            ['stretch']     = {
                price = 2000, 
                image = 'https://i.imgur.com/pZeUmzV.png',
            },

        },

        vehiclespawncoords = vector4(-1029.6068, -2724.4490, 20.1663, 240.0500), -- where vehicle spawns when rented

    },

    -- add as many locations as you'd like with any type of vehicle (air, water, land) follow same format as above
}

