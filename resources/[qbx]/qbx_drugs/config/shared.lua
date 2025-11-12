local defaultProducts = {
    [1] = {
        name = 'weed_smallbag',
        price = 250,
        amount = 150,
        info = {},
        type = 'item',
        slot = 1,
        minrep = 0
    },
    [2] = {
        name = 'coke_smallbag',
        price = 450,
        amount = 120,
        info = {},
        type = 'item',
        slot = 2,
        minrep = 50
    },
    [3] = {
        name = 'meth_smallbag',
        price = 600,
        amount = 90,
        info = {},
        type = 'item',
        slot = 3,
        minrep = 100
    },
    [4] = {
        name = 'weed_brick',
        price = 2500,
        amount = 25,
        info = {},
        type = 'item',
        slot = 4,
        minrep = 125
    },
    [5] = {
        name = 'coke_brick',
        price = 4200,
        amount = 15,
        info = {},
        type = 'item',
        slot = 5,
        minrep = 175
    },
    [6] = {
        name = 'meth_brick',
        price = 5200,
        amount = 10,
        info = {},
        type = 'item',
        slot = 6,
        minrep = 225
    }
}

return {
    dealers = {
        {
            name = 'tuner',
            label = 'Tuner Alley Plug',
            coords = vec4(154.56, -3014.47, 7.04, 269.87),
            blip = {
                enabled = true,
                sprite = 514,
                colour = 25,
                scale = 0.85,
                label = 'Illicit Supplier'
            },
            ped = {
                model = `g_m_m_cartelguards_01`,
                scenario = 'WORLD_HUMAN_SMOKING'
            },
            time = { min = 20, max = 5 },
            products = defaultProducts
        }
    },
    deliveryItems = {
        {
            item = 'weed_brick',
            minrep = 0,
            payout = 1250
        },
        {
            item = 'coke_brick',
            minrep = 50,
            payout = 2000
        },
        {
            item = 'meth_brick',
            minrep = 150,
            payout = 2750
        },
    }
}