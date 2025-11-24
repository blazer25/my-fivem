local shared = require 'config.shared'

local function deepCopy(value)
    if type(value) ~= 'table' then return value end
    local copy = {}
    for k, v in pairs(value) do
        copy[k] = deepCopy(v)
    end
    return copy
end

local defaultDealerProducts = deepCopy(shared.dealers[1].products or {})

return {
    useMarkedBills = true,
    policeCallChance = 30,
    policeDeliveryModifier = 0.06,
    deliveryRepGain = 3,
    deliveryRepLoss = 2,
    wrongAmountFee = 2.5,
    overdueDeliveryFee = 3.5,
    scamChance = 18,
    products = defaultDealerProducts,
    cornerSellingDrugsList = {
        'weed_smallbag',
        'coke_smallbag',
        'meth_smallbag'
    },
    cornerSellingDrugsPrice = {
        weed_smallbag = { min = 340, max = 430 },
        coke_smallbag = { min = 600, max = 780 },
        meth_smallbag = { min = 720, max = 910 },
    },
    -- Drug tier system for realistic progression and weighted selection
    drugTiers = {
        weed_smallbag = {
            tier = 1,
            successRate = 90, -- Easiest to sell (low-tier)
            requestWeight = 10 -- Most common requests (10x more likely than meth)
        },
        coke_smallbag = {
            tier = 2,
            successRate = 75, -- Medium difficulty
            requestWeight = 5 -- Moderate requests (5x more likely than meth)
        },
        meth_smallbag = {
            tier = 3,
            successRate = 60, -- Hardest to sell (high-tier)
            requestWeight = 2 -- Rare requests (base weight)
        }
    }
}

