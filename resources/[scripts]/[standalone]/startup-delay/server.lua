-- Startup delay script to stagger heavy resource loading
-- This helps reduce server load spikes during startup

local heavyResources = {
    -- Heavy map resources (load in batches with delays)
    {resources = {'mapmanager'}, delay = 1000},
    {resources = {'[maps]', 'mc_grapeseed', 'vortex_phonestore', 'Mirror-Park-Clubhouse'}, delay = 2000},
    {resources = {'forest_mansion', 'floresta', 'brnx_tunnelhideout', 'cityhall'}, delay = 2000},
    {resources = {'abs99_7sky', 'grizmowe_hideout', 'new_map', 'Ricky-VinewoodSign'}, delay = 2000},
    {resources = {'patoche_free_cardealer', 'bob74_ipl', 'anarchy_Cardealer', 'anarchy_MRPD'}, delay = 2000},
    {resources = {'anarchy_underground', 'anarchy_LsCustoms', 'vinewood_house', 'dip_hookies'}, delay = 2000},
    {resources = {'dip_mechanic', 'moreo_gym'}, delay = 2000},
    
    -- Heavy vehicle resources
    {resources = {'onx-evp-a-shared', 'onx-evp-c-pack', 'onx-evp-b-wheels'}, delay = 3000},
    {resources = {'[onx_vehicles]'}, delay = 3000},
    {resources = {'[cars]'}, delay = 3000},
    {resources = {'[carsounds]'}, delay = 2000},
    
    -- Heavy asset resources
    {resources = {'[assets]'}, delay = 3000},
    {resources = {'[eup]'}, delay = 2000},
    
    -- Note: Script folders are ensured in server.cfg, not here
    -- StartResource() doesn't work on folder ensures
}

CreateThread(function()
    -- Wait a bit for core resources to initialize
    Wait(5000)
    
    print('^2[Startup-Delay]^7 Starting staggered heavy resource loading...')
    
    for i, batch in ipairs(heavyResources) do
        -- Wait before this batch
        if i > 1 then
            Wait(batch.delay)
        end
        
        -- Ensure all resources in this batch
        for _, resource in ipairs(batch.resources) do
            local state = GetResourceState(resource)
            if state ~= 'started' and state ~= 'starting' then
                print(string.format('^3[Startup-Delay]^7 Ensuring: %s', resource))
                StartResource(resource)
            end
        end
    end
    
    print('^2[Startup-Delay]^7 Heavy resource loading complete!')
end)

