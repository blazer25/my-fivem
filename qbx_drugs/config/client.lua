local useTargetConvar = GetConvar('UseTarget', 'false')
local targetDetected = GetResourceState('ox_target') == 'started' or GetResourceState('qb-target') == 'started'

return {
    useTarget = useTargetConvar == 'true' or targetDetected,
    successChance = 85, -- Base success chance (increased for faster turnover)
    robberyChance = 15,
    minimumDrugSalePolice = 2,
    -- Drug tier configuration for realistic progression
    -- Each drug has its own success rate and request weight
    drugTiers = {
        weed_smallbag = {
            tier = 1,
            successRate = 90, -- Easiest to sell (low-tier)
            requestWeight = 10 -- Most common requests
        },
        coke_smallbag = {
            tier = 2,
            successRate = 75, -- Medium difficulty
            requestWeight = 5 -- Moderate requests
        },
        meth_smallbag = {
            tier = 3,
            successRate = 60, -- Hardest to sell (high-tier)
            requestWeight = 2 -- Rare requests
        }
    },
    -- Cooldown settings
    postSaleCooldownMin = 1000, -- Reduced from 4000
    postSaleCooldownMax = 2000, -- Reduced from 7000
    lastPedCleanupInterval = 10, -- Clear lastPed array every 10 interactions
    deliveryLocations = {
        {
            label = 'Innocence Boulevard Lot',
            coords = vec3(42.65, -1004.72, 29.28),
        },
        {
            label = 'Popular Street Garage',
            coords = vec3(831.76, -810.55, 26.33),
        },
        {
            label = 'Mirror Park Cul-de-sac',
            coords = vec3(1261.92, -566.37, 68.49),
        },
        {
            label = 'Weazel Plaza Forecourt',
            coords = vec3(-576.42, -932.05, 28.86),
        },
        {
            label = 'Vinewood Bowl Lot',
            coords = vec3(681.81, 566.28, 129.24),
        },
        {
            label = 'Grapeseed Barn',
            coords = vec3(2540.13, 4675.28, 33.9),
        },
    }
}
