local defaultProducts = {
    [1] = {
        name = 'weed_smallbag',
        price = 320,
        amount = 80,
        info = {},
        type = 'item',
        slot = 1,
        minrep = 0
    },
    [2] = {
        name = 'coke_smallbag',
        price = 560,
        amount = 55,
        info = {},
        type = 'item',
        slot = 2,
        minrep = 80
    },
    [3] = {
        name = 'meth_smallbag',
        price = 710,
        amount = 40,
        info = {},
        type = 'item',
        slot = 3,
        minrep = 150
    }
}

return {
    dealers = {
        {
            name = 'tuner',
            label = 'Tuner Alley Plug',
            coords = vec4(156.1249, -3012.1111, 6.0219, 241.9173),
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
            item = 'weed_smallbag',
            minrep = 0,
            payout = 480
        },
        {
            item = 'coke_smallbag',
            minrep = 90,
            payout = 720
        },
        {
            item = 'meth_smallbag',
            minrep = 160,
            payout = 940
        },
    }
}