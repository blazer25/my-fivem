-- Fish Market Selling Script
-- Players can sell fish at the fish market for money

local FishPrices = {
    -- Original fish
    ['fish'] = 75,
    ['dolphin'] = 300,
    ['hammershark'] = 300,
    ['tigershark'] = 650,
    ['stingray'] = 650,
    ['killerwhale'] = 1750,
    ['humpback'] = 4000,
    
    -- Illegal Fish (Very high prices, high risk)
    ['paddlefish'] = 5000,
    ['sawfish'] = 6000,
    ['eel'] = 3000,
    ['hammerheadshark'] = 8000,
    ['seaturtle'] = 10000,
    ['leopardshark'] = 7000,
    ['blueshark'] = 9000,
    ['greatwhiteshark'] = 15000,
    
    -- Diving Items
    ['pearl'] = 500,
    ['coral'] = 200,
    ['treasure_chest'] = 5000,
}

local FishMarketZones = {
    { coords = vec3(-1847.98, -1193.15, 14.30), radius = 3.0 },
    { coords = vec3(-1598.84, 5200.18, 4.31), radius = 3.0 },
}

local IllegalFishZones = {
    { coords = vec3(1550.83, 6318.95, 24.06), radius = 3.0 },
}

local function isPlayerAtFishMarket(source)
    local ped = GetPlayerPed(source)
    if not ped or ped == 0 then return false end
    
    local playerCoords = GetEntityCoords(ped)
    
    for _, zone in ipairs(FishMarketZones) do
        local distance = #(playerCoords - zone.coords)
        if distance <= zone.radius then
            return true
        end
    end
    
    return false
end

local function isPlayerAtIllegalFishSeller(source)
    local ped = GetPlayerPed(source)
    if not ped or ped == 0 then return false end
    
    local playerCoords = GetEntityCoords(ped)
    
    for _, zone in ipairs(IllegalFishZones) do
        local distance = #(playerCoords - zone.coords)
        if distance <= zone.radius then
            return true
        end
    end
    
    return false
end

-- List of illegal fish items
local IllegalFish = {
    'paddlefish', 'sawfish', 'eel', 'hammerheadshark', 'seaturtle', 
    'leopardshark', 'blueshark', 'greatwhiteshark'
}

local function isIllegalFish(itemName)
    for _, illegal in ipairs(IllegalFish) do
        if illegal == itemName then
            return true
        end
    end
    return false
end

RegisterNetEvent('brz-fishing:sellFish', function(itemName, count)
    local src = source
    
    local atFishMarket = isPlayerAtFishMarket(src)
    local atIllegalSeller = isPlayerAtIllegalFishSeller(src)
    local isIllegal = isIllegalFish(itemName)
    
    -- Check location validity
    if not atFishMarket and not atIllegalSeller then
        lib.notify(src, {
            title = 'Fish Market',
            description = 'You must be at a fish market to sell fish',
            type = 'error'
        })
        return
    end
    
    -- If at illegal seller, only allow illegal fish
    if atIllegalSeller and not isIllegal then
        lib.notify(src, {
            title = 'Illegal Fish Buyer',
            description = 'This buyer only accepts illegal fish',
            type = 'error'
        })
        return
    end
    
    -- If at regular fish market, don't allow illegal fish
    if atFishMarket and isIllegal then
        lib.notify(src, {
            title = 'Fish Market',
            description = 'Illegal fish cannot be sold here. Find a special buyer.',
            type = 'error'
        })
        return
    end
    
    local price = FishPrices[itemName]
    if not price then
        lib.notify(src, {
            title = 'Fish Market',
            description = 'This item cannot be sold here',
            type = 'error'
        })
        return
    end
    
    local playerInv = exports.ox_inventory:GetInventory(src, 'player')
    if not playerInv then return end
    
    local hasItem = exports.ox_inventory:GetItem(src, itemName, nil, true)
    if not hasItem or hasItem < count then
        lib.notify(src, {
            title = 'Fish Market',
            description = 'You don\'t have enough of this fish',
            type = 'error'
        })
        return
    end
    
    local totalPrice = price * count
    
    if exports.ox_inventory:RemoveItem(src, itemName, count) then
        local Player = exports.qbx_core:GetPlayer(src)
        if Player then
            Player.Functions.AddMoney('cash', totalPrice)
            local title = atIllegalSeller and 'Illegal Fish Buyer' or 'Fish Market'
            lib.notify(src, {
                title = title,
                description = string.format('Sold %dx %s for $%s', count, exports.ox_inventory:Items()[itemName].label, totalPrice),
                type = 'success'
            })
        end
    else
        lib.notify(src, {
            title = 'Fish Market',
            description = 'Failed to sell fish',
            type = 'error'
        })
    end
end)

-- Export for other scripts
exports('GetFishPrice', function(itemName)
    return FishPrices[itemName]
end)

exports('GetFishMarketZones', function()
    return FishMarketZones
end)

exports('GetIllegalFishZones', function()
    return IllegalFishZones
end)

-- Send fish prices to client
RegisterNetEvent('brz-fishing:requestFishPrices', function()
    local src = source
    TriggerClientEvent('brz-fishing:receiveFishPrices', src, FishPrices)
end)

