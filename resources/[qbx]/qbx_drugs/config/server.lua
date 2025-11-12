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
    policeCallChance = 25,
    policeDeliveryModifier = 0.05,
    deliveryRepGain = 2,
    deliveryRepLoss = 1,
    wrongAmountFee = 2,
    overdueDeliveryFee = 3,
    scamChance = 20,
    products = defaultDealerProducts,
    cornerSellingDrugsList = {
        'weed_smallbag',
        'coke_smallbag',
        'meth_smallbag'
    },
    cornerSellingDrugsPrice = {
        weed_smallbag = { min = 200, max = 275 },
        coke_smallbag = { min = 425, max = 575 },
        meth_smallbag = { min = 520, max = 700 },
    }
}

