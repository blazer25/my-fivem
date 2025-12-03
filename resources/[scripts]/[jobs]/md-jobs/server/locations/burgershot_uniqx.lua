--https://www.gta5-mods.com/maps/mlo-burgershot-2023-add-on-sp-fivem
local jobloc = 'burgershot'

Jobs['burgershot'] = {
    CateringEnabled = true,
    closedShopsEnabled = true,
    automaticJobDuty = true,
    polyzone = {
        vec3(-1198.80, -905.50, 13.83),
        vec3(-1187.70, -899.27, 13.83),
        vec3(-1184.82, -901.46, 13.83),
        vec3(-1175.33, -894.91, 13.85),
        vec3(-1186.88, -877.51, 13.85),
        vec3(-1208.55, -891.59, 12.97)
    },
    Blip = {
        { sprite = 106, color = 2, scale = 0.5, label = 'Burger Shot', loc = vector3(-1190.53, -890.00, 13.89) },
    },
    closedShops = {
        { ped = 'csb_burgerdrug', loc = vector4(-1196.36, -893.66, 13.89, 340), label = 'Burgershot Shop' }
    },
    closedShopItems = {
        bs_fries = { name = 'bs_fries', price = 5 },
        bs_nuggets = { name = 'bs_nuggets', price = 5 },
        bs_heartstopper = { name = 'bs_heartstopper', price = 5 },
        bs_bleeder = { name = 'bs_bleeder', price = 5 },
        bs_torpedo = { name = 'bs_torpedo', price = 5 },
        bs_moneyshot = { name = 'bs_moneyshot', price = 5 },
        bs_heartstopper_meal = { name = 'bs_heartstopper_meal', price = 5 },
        bs_nugget_meal = { name = 'bs_nugget_meal', price = 5 },
        bs_torpedo_meal = { name = 'bs_torpedo_meal', price = 5 },
        bs_moneyshot_meal = { name = 'bs_moneyshot_meal', price = 5 },
        sprunk = { name = 'sprunk', price = 5 },
        ecola = { name = 'ecola', price = 5 },
    },
    craftingStations = {
        soda = {
            { anim = 'uncuff', give = {}, take = { ecola = 1 },  progtext = 'Pouring' },
            { anim = 'uncuff', give = {}, take = { sprunk = 1 }, progtext = 'Pouring' },
        },
        coffee = {
            { anim = 'uncuff', give = {}, take = { coffee = 1 }, progtext = 'Pouring' }
        },
        fryer = {
            { anim = 'uncuff', give = { frozen_fries = 1, cooking_oil = 1 },   take = { bs_fries = 1 },   progtext = 'Cooking' },
            { anim = 'uncuff', give = { frozen_nuggets = 1, cooking_oil = 1 }, take = { bs_nuggets = 1 }, progtext = 'Cooking' }
        },
        cuttingboard = {
            { anim = 'uncuff', give = { tomato = 1 }, take = { sliced_tomato = 1 }, progtext = 'Chopping' },
            { anim = 'uncuff', give = { onion = 1 },  take = { sliced_onion = 1 },  progtext = 'Chopping' }
        },
        grill = {
            { anim = 'uncuff', give = { burger_patty = 1 }, take = { burger_meat = 1 },    progtext = 'Grilling' },
            { anim = 'uncuff', give = { raw_chicken = 1 },  take = { cooked_chicken = 1 }, progtext = 'Cooking' }
        },
        assembly = {
            { anim = 'uncuff', give = { burger_bun = 1, burger_meat = 1, sliced_tomato = 1, lettuce = 1, sliced_onion = 1, burger_cheese = 1 },    take = { bs_heartstopper = 1 },      progtext = 'Using' },
            { anim = 'uncuff', give = { burger_bun = 1, burger_meat = 1, sliced_tomato = 1, lettuce = 1, sliced_onion = 1, burger_cheese = 1 },    take = { bs_bleeder = 1 },           progtext = 'Using' },
            { anim = 'uncuff', give = { burger_bun = 1, cooked_chicken = 1, sliced_tomato = 1, lettuce = 1, sliced_onion = 1, burger_cheese = 1 }, take = { bs_torpedo = 1 },           progtext = 'Using' },
            { anim = 'uncuff', give = { burger_bun = 1, burger_meat = 1, sliced_tomato = 1, lettuce = 1, sliced_onion = 1, burger_cheese = 1 },    take = { bs_moneyshot = 1 },         progtext = 'Using' },
            { anim = 'uncuff', give = { bs_heartstopper = 1, bs_fries = 1, sprunk = 1 },                                                           take = { bs_heartstopper_meal = 1 }, progtext = 'Using' },
            { anim = 'uncuff', give = { bs_moneyshot = 1, bs_fries = 1, ecola = 1 },                                                               take = { bs_moneyshot_meal = 1 },    progtext = 'Using' },
            { anim = 'uncuff', give = { bs_nuggets = 1, bs_fries = 1, sprunk = 1 },                                                                take = { bs_nugget_meal = 1 },       progtext = 'Using' },
            { anim = 'uncuff', give = { bs_torpedo = 1, bs_fries = 1, ecola = 1 },                                                                 take = { bs_torpedo_meal = 1 },      progtext = 'Using' }
        }
    },
    catering = {
        commission = 0.75,
        items = {
            { name = 'bs_bleeder',           minPrice = 20, maxPrice = 30, maxAmount = 30 },
            { name = 'bs_fries',             minPrice = 20, maxPrice = 30, maxAmount = 30 },
            { name = 'bs_heartstopper',      minPrice = 20, maxPrice = 30, maxAmount = 30 },
            { name = 'bs_heartstopper_meal', minPrice = 30, maxPrice = 45, maxAmount = 20 },
            { name = 'bs_moneyshot',         minPrice = 20, maxPrice = 30, maxAmount = 30 },
            { name = 'bs_moneyshot_meal',    minPrice = 30, maxPrice = 45, maxAmount = 20 },
            { name = 'bs_nuggets',           minPrice = 20, maxPrice = 30, maxAmount = 30 },
            { name = 'bs_nugget_meal',       minPrice = 30, maxPrice = 45, maxAmount = 20 },
            { name = 'bs_torpedo',           minPrice = 20, maxPrice = 30, maxAmount = 30 },
            { name = 'bs_torpedo_meal',      minPrice = 30, maxPrice = 45, maxAmount = 20 },
            { name = 'ecola',                minPrice = 5,  maxPrice = 10, maxAmount = 30 },
            { name = 'sprunk',               minPrice = 5,  maxPrice = 10, maxAmount = 30 },
        },

        Van = {
            burgershot = { model = 'burrito', label = 'Burrito', plate = 'BSCater', livery = 3, loc = vec4(-1205.79, -901.60, 13.41, 34) },
        }

    },
    shops = {
    },
    locations = {
        Crafter = {
            {
                CraftData = { type = 'soda', targetLabel = 'Pour Drinks', menuLabel = 'Pour Drinks' },
                loc = vector3(-1190.82, -898.10, 13.89),
                l = 1.0,
                w = 0.75,
                lwr = 0.5,
                upr = 0.5,
                r = 217,
                job = jobloc
            },
            {
                CraftData = { type = 'coffee', targetLabel = 'Pour Coffee', menuLabel = 'Pour Coffee' },
                loc = vector3(-1193.03, -896.32, 13.89),
                l = 1.0,
                w = 0.75,
                lwr = 0.5,
                upr = 0.5,
                r = 159,
                job = jobloc
            },
            {
                CraftData = { type = 'fryer', targetLabel = 'Fry', menuLabel = 'Fry' },
                loc = vector3(-1194.95, -899.61, 13.89),
                l = 1.0,
                w = 0.75,
                lwr = 0.75,
                upr = 0.75,
                r = 158,
                job = jobloc
            },
            {
                CraftData = { type = 'grill', targetLabel = 'Grill', menuLabel = 'Grill' },
                loc = vector3(-1195.24, -898.21, 13.89),
                l = 2.0,
                w = 0.7,
                lwr = 0.5,
                upr = 0.5,
                r = 341,
                job = jobloc
            },
            {
                CraftData = { type = 'cuttingboard', targetLabel = 'Chop', menuLabel = 'Chop' },
                loc = vector3(-1196.87, -897.72, 13.89),
                l = 2.5,
                w = 2.5,
                lwr = 0.5,
                upr = 0.5,
                r = 351,
                job = jobloc
            },
            {
                CraftData = { type = 'assembly', targetLabel = 'Assemble', menuLabel = 'Assemble' },
                loc = vector3(-1200.08, -894.82, 13.89),
                l = 2.7,
                w = 1.4,
                lwr = 0.5,
                upr = 0.5,
                r = 121,
                job = jobloc
            },
        },
        Stores = {
        },
        Tills = {
            { loc = vector3(-1197.79, -893.26, 13.89), l = 1.0, w = 1.0, lwr = 0.5, upr = 0.5, r = 344, commission = 0.2, job = jobloc },
            { loc = vector3(-1195.74, -893.82, 13.89), l = 1.0, w = 1.0, lwr = 0.5, upr = 0.5, r = 352, commission = 0.2, job = jobloc },
            { loc = vector3(-1193.62, -894.45, 13.89), l = 1.0, w = 1.0, lwr = 0.5, upr = 0.5, r = 344, commission = 0.2, job = jobloc },
            { loc = vector3(-1191.69, -894.97, 13.89), l = 1.0, w = 1.0, lwr = 0.5, upr = 0.5, r = 343, commission = 0.2, job = jobloc }
        },
        trays = { -- storages to place things for people
            { label = 'Grab Food', loc = vector3(-1192.69, -893.55, 15.12), l = 1.0, w = 1.0, lwr = 0.5, upr = 0.5, r = 177, slots = 6, weight = 30000, job = jobloc },
            { label = 'Grab Food', loc = vector3(-1196.87, -892.79, 15.22), l = 1.0, w = 1.0, lwr = 0.5, upr = 0.5, r = 326, slots = 6, weight = 30000, job = jobloc },
            { label = 'Grab Food', loc = vector3(-1195.00, -893.25, 15.21), l = 1.0, w = 1.0, lwr = 0.5, upr = 0.5, r = 259, slots = 6, weight = 30000, job = jobloc },
            { label = 'Grab Food', loc = vector3(-1190.80, -894.41, 15.41), l = 1.0, w = 1.0, lwr = 0.5, upr = 0.5, r = 271, slots = 6, weight = 30000, job = jobloc },
        },
        stash = { -- storages to place things
            { label = 'Store Products', loc = vector3(-1194.27, -895.92, 13.89), l = 1.0, w = 1.0, lwr = 0.5, upr = 0.5, r = 167, slots = 100, weight = 600000, job = jobloc },
            { label = 'Store Products', loc = vector3(-1195.39, -895.60, 13.89), l = 1.0, w = 1.0, lwr = 0.5, upr = 0.5, r = 161, slots = 100, weight = 600000, job = jobloc },
        },

    },
    consumables = {
        bs_bleeder = { anim = 'eat', label = 'Eating', add = { hunger = 10 } },
        bs_fries = { anim = 'eat', label = 'Eating', add = { hunger = 5 } },
        bs_heartstopper = { anim = 'eat', label = 'Eating', add = { hunger = 10 } },
        bs_heartstopper_meal = { anim = 'eat', label = 'Consuming', add = { hunger = 25, thirst = 10 } },
        bs_moneyshot = { anim = 'eat', label = 'Eating', add = { hunger = 10 } },
        bs_moneyshot_meal = { anim = 'eat', label = 'Eating', add = { hunger = 25, thirst = 10 } },
        bs_nuggets = { anim = 'eat', label = 'Eating', add = { hunger = 10 } },
        bs_nugget_meal = { anim = 'eat', label = 'Eating', add = { hunger = 25, thirst = 10 } },
        bs_torpedo = { anim = 'eat', label = 'Eating', add = { hunger = 10 } },
        bs_torpedo_meal = { anim = 'eat', label = 'Eating', add = { hunger = 25, thirst = 10 } },
        ecola = { anim = 'drink', label = 'Drinking', add = { thirst = 10 } },
        sprunk = { anim = 'drink', label = 'Drinking', add = { thirst = 10 } },
    },
}
