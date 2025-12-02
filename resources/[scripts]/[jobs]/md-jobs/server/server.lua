------------------------
---- Event Handlers ----
------------------------

-- Automatic cleanup
AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() or Config.UseClientPeds then return end
    for _, job in pairs(Jobs) do
        local jobLabel = job.Blip.label or "Unknown Job"
        local closedShop = job.closedShops
        if closedShop ~= nil then
            for _, shop in pairs(closedShop) do
                local netId = shop.ped and shop.netId or nil -- Fall back if ped is nil
                if netId then
                    local ped = NetworkGetEntityFromNetworkId(netId)
                    if DoesEntityExist(ped) then
                        DeleteEntity(ped)
                    end
                end
            end
        end

        if job.CateringEnabled then
            local catering = job.catering
            if catering.npcNetId then
                local netId = catering.npcNetId
                local ped = NetworkGetEntityFromNetworkId(netId)
                if DoesEntityExist(ped) then
                    DeleteEntity(ped)
                end
            end
            if catering.Van.netId then
                local netId = catering.Van.netId
                local van = NetworkGetEntityFromNetworkId(netId)
                if DoesEntityExist(van) then
                    DeleteEntity(van)
                end
            end
        end
    end
end)
