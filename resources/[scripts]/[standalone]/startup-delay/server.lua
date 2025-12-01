-- Startup delay script to stagger heavy resource loading and ensure scripts start
-- This helps reduce server load spikes during startup and ensures all resources load

local heavyResources = {
    -- Map manager first
    {resources = {'mapmanager'}, delay = 1000},
    
    -- Heavy map resources (load in batches with delays)
    {resources = {'[maps]'}, delay = 2000},
    {resources = {'mc_grapeseed', 'vortex_phonestore', 'Mirror-Park-Clubhouse'}, delay = 2000},
    {resources = {'forest_mansion', 'floresta', 'brnx_tunnelhideout', 'cityhall'}, delay = 2000},
    {resources = {'abs99_7sky', 'grizmowe_hideout', 'new_map', 'Ricky-VinewoodSign'}, delay = 2000},
    {resources = {'patoche_free_cardealer', 'bob74_ipl', 'anarchy_Cardealer', 'anarchy_MRPD'}, delay = 2000},
    {resources = {'anarchy_underground', 'anarchy_LsCustoms', 'vinewood_house', 'dip_hookies'}, delay = 2000},
    {resources = {'dip_mechanic', 'moreo_gym'}, delay = 2000},
    
    -- Heavy vehicle base resources
    {resources = {'onx-evp-a-shared', 'onx-evp-c-pack', 'onx-evp-b-wheels'}, delay = 2000},
}

-- Resources that need to be explicitly ensured (from script folders)
local scriptResources = {
    -- Life scripts
    'Renewed-Banking', 'Renewed-Weathersync', 'bcs_driveschool', 'bcs_questionare',
    'jpr-housingsystem', 'savana-storage', 'scully_emotemenu', 'solos-rentals', 'vehiclehandler',
    -- Job scripts
    'jim_mining', 'jim-recycle', 'kt-deliveries', 'savana-truckerjob',
    -- Criminal scripts
    'kq_lootareas', 'kq_club_heist', 'HouseRobbery', 'brutal_gangs', 'lation_247robbery', 'pl-atmrob',
    -- Other scripts
    'ars_hunting', 'qb-admin', 'pickle_prisons',
    -- Bridges
    'jim_bridge', 'qb-core-bridge',
    -- Standalone
    'cardboard-riddles', 'cdn-fuel', 'fivem-brz-fishing-ts', 'informational', 'jpr-shells',
    'kq_lasers', 'ls_minimapfix', 'mana_audio', 'mhacking', 'nu-blackmarket', 'safecracker', 'ultra-voltlab',
    -- Critical dependencies
    'qt-crafting-v2', 'lc_stores', 'md-drugs',
    -- JPR addons
    'DLCiplLoader', 'jpr-libsss',
}

CreateThread(function()
    -- Wait for core resources to initialize
    Wait(5000)
    
    print('^2[Startup-Delay]^7 Starting staggered heavy resource loading...')
    
    -- Load heavy resources in batches
    for i, batch in ipairs(heavyResources) do
        if i > 1 then
            Wait(batch.delay)
        end
        
        for _, resource in ipairs(batch.resources) do
            local state = GetResourceState(resource)
            if state ~= 'started' and state ~= 'starting' then
                print(string.format('^3[Startup-Delay]^7 Ensuring: %s', resource))
                StartResource(resource)
            end
        end
    end
    
    print('^2[Startup-Delay]^7 Heavy resource loading complete!')
    
    -- Wait for heavy resources to settle
    Wait(10000)
    
    -- Now ensure script resources individually with delays
    print('^2[Startup-Delay]^7 Ensuring script resources...')
    
    for i, resource in ipairs(scriptResources) do
        Wait(500) -- Small delay between each resource
        
        local state = GetResourceState(resource)
        if state ~= 'started' and state ~= 'starting' then
            print(string.format('^3[Startup-Delay]^7 Ensuring script: %s (state: %s)', resource, state))
            local success = StartResource(resource)
            if not success then
                print(string.format('^1[Startup-Delay]^7 Failed to start: %s', resource))
            end
        end
    end
    
    print('^2[Startup-Delay]^7 Script resource loading complete!')
end)

