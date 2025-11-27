local maps = {
    'abs99_7sky',
    'grizmowe_hideout',
    'new_map',
    'Ricky-VinewoodSign',
    'patoche_free_cardealer',
    'anarchy_Cardealer',
    'anarchy_MRPD',
    'anarchy_underground',
    'anarchy_LsCustoms',
    'jpr-casinosystem',
    'jpr-libsss',
    'DLCiplLoader',
    'vinewood_house',
    'dip_hookies',
    'dip_mechanic',
    'forest_mansion',
    'floresta',
    'Mirror-Park-Clubhouse',
    'anarchy_rexdiner',
    'anarchy_TrapHouse',
    'henhouse_milo',
    'anarchy_LittleHouse',
    'anarchy_Townhall',
    'int_yellowjack',
    'thunder_medicalcenter',
    'mc_grapeseed'

}

CreateThread(function()
    Wait(8000) -- wait 8 seconds for other scripts to load
    for _, map in ipairs(maps) do
        local state = GetResourceState(map)
        if not state:find("start") then
            print(("[Mapforcer] Attempting to start missing map: %s (current state: %s)"):format(map, state))
            local success = StartResource(map)
            if success then
                print(("[Mapforcer] ✅ Successfully started %s"):format(map))
            else
                print(("[Mapforcer] ❌ Failed to start %s"):format(map))
            end
        else
            print(("[Mapforcer] ✅ Map already running: %s"):format(map))
        end
    end
    print("[Mapforcer] Check complete.")
end)
