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
    }
}

