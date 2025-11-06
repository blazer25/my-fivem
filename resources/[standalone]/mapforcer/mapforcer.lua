local maps = {
    'abs99_7sky',
    'grizmowe_hideout',
    'new_map',
    'Ricky-VinewoodSign',
    'patoche_free_cardealer'
}

CreateThread(function()
    Wait(5000) -- wait 5 seconds after startup
    for _, map in ipairs(maps) do
        if not GetResourceState(map):find("start") then
            print(("[Mapforcer] Starting missing map: %s"):format(map))
            ExecuteCommand(("start %s"):format(map))
        else
            print(("[Mapforcer] Map already running: %s"):format(map))
        end
    end
end)
