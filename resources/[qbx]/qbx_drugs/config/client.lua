local useTargetConvar = GetConvar('UseTarget', 'false')
local targetDetected = GetResourceState('ox_target') == 'started' or GetResourceState('qb-target') == 'started'

return {
    useTarget = useTargetConvar == 'true' or targetDetected,
    successChance = 65,
    robberyChance = 15,
    minimumDrugSalePolice = 2,
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
            label = 'Del Perro Pier Parking',
            coords = vec3(-1615.47, -1083.63, 13.02),
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
