-- Fish Market Client Script
-- Handles interactions at fish market locations

local FishMarketZones = {
    { coords = vec3(-1847.98, -1193.15, 14.30), radius = 3.0 },
    { coords = vec3(-1598.84, 5200.18, 4.31), radius = 3.0 },
}

local IllegalFishZones = {
    { coords = vec3(1550.83, 6318.95, 24.06), radius = 3.0 },
}

-- Get all fish prices from server (will be populated via event)
local FishPrices = {}

-- Illegal fish items
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

local function isPlayerAtFishMarket()
    local playerCoords = GetEntityCoords(cache.ped)
    
    for _, zone in ipairs(FishMarketZones) do
        local distance = #(playerCoords - zone.coords)
        if distance <= zone.radius then
            return true
        end
    end
    
    return false
end

local function isPlayerAtIllegalFishSeller()
    local playerCoords = GetEntityCoords(cache.ped)
    
    for _, zone in ipairs(IllegalFishZones) do
        local distance = #(playerCoords - zone.coords)
        if distance <= zone.radius then
            return true
        end
    end
    
    return false
end

-- Request fish prices from server
CreateThread(function()
    Wait(1000)
    TriggerServerEvent('brz-fishing:requestFishPrices')
end)

RegisterNetEvent('brz-fishing:receiveFishPrices', function(prices)
    FishPrices = prices
end)

-- Create target zones for fish market
CreateThread(function()
    for _, zone in ipairs(FishMarketZones) do
        exports.ox_target:addSphereZone({
            coords = zone.coords,
            radius = zone.radius,
            debug = false,
            options = {
                {
                    name = 'fishmarket_sell',
                    icon = 'fas fa-fish',
                    label = 'Sell Fish',
                    onSelect = function()
                        openFishMarketMenu()
                    end,
                    canInteract = function()
                        return isPlayerAtFishMarket()
                    end
                }
            }
        })
    end
    
    -- Create target zones for illegal fish seller
    for _, zone in ipairs(IllegalFishZones) do
        exports.ox_target:addSphereZone({
            coords = zone.coords,
            radius = zone.radius,
            debug = false,
            options = {
                {
                    name = 'illegalfish_sell',
                    icon = 'fas fa-fish',
                    label = 'Sell Illegal Fish',
                    onSelect = function()
                        openIllegalFishMenu()
                    end,
                    canInteract = function()
                        return isPlayerAtIllegalFishSeller()
                    end
                }
            }
        })
    end
end)

function openFishMarketMenu()
    if not isPlayerAtFishMarket() then
        lib.notify({
            title = 'Fish Market',
            description = 'You must be at a fish market',
            type = 'error'
        })
        return
    end
    
    local inventory = exports.ox_inventory:GetPlayerItems()
    if not inventory then return end
    
    local fishItems = {}
    local items = exports.ox_inventory:Items()
    
    for _, item in pairs(inventory) do
        -- Only show non-illegal fish at regular fish market
        if FishPrices[item.name] and not isIllegalFish(item.name) then
            table.insert(fishItems, {
                title = items[item.name].label,
                description = string.format('Price: $%d each | You have: %d', FishPrices[item.name], item.count),
                metadata = {
                    { label = 'Price per fish', value = '$' .. FishPrices[item.name] },
                    { label = 'You have', value = item.count },
                    { label = 'Total value', value = '$' .. (FishPrices[item.name] * item.count) }
                },
                onSelect = function()
                    sellFishDialog(item.name, item.count, FishPrices[item.name])
                end
            })
        end
    end
    
    if #fishItems == 0 then
        lib.notify({
            title = 'Fish Market',
            description = 'You don\'t have any fish to sell',
            type = 'inform'
        })
        return
    end
    
    lib.registerContext({
        id = 'fishmarket_menu',
        title = 'Fish Market',
        options = fishItems
    })
    
    lib.showContext('fishmarket_menu')
end

function openIllegalFishMenu()
    if not isPlayerAtIllegalFishSeller() then
        lib.notify({
            title = 'Illegal Fish Buyer',
            description = 'You must be at an illegal fish buyer',
            type = 'error'
        })
        return
    end
    
    local inventory = exports.ox_inventory:GetPlayerItems()
    if not inventory then return end
    
    local fishItems = {}
    local items = exports.ox_inventory:Items()
    
    for _, item in pairs(inventory) do
        -- Only show illegal fish at illegal seller
        if FishPrices[item.name] and isIllegalFish(item.name) then
            table.insert(fishItems, {
                title = items[item.name].label,
                description = string.format('Price: $%d each | You have: %d', FishPrices[item.name], item.count),
                metadata = {
                    { label = 'Price per fish', value = '$' .. FishPrices[item.name] },
                    { label = 'You have', value = item.count },
                    { label = 'Total value', value = '$' .. (FishPrices[item.name] * item.count) }
                },
                onSelect = function()
                    sellFishDialog(item.name, item.count, FishPrices[item.name])
                end
            })
        end
    end
    
    if #fishItems == 0 then
        lib.notify({
            title = 'Illegal Fish Buyer',
            description = 'You don\'t have any illegal fish to sell',
            type = 'inform'
        })
        return
    end
    
    lib.registerContext({
        id = 'illegalfish_menu',
        title = 'Illegal Fish Buyer',
        options = fishItems
    })
    
    lib.showContext('illegalfish_menu')
end

function sellFishDialog(itemName, maxCount, pricePerFish)
    local input = lib.inputDialog('Sell Fish', {
        {
            type = 'number',
            label = 'Amount to sell',
            description = string.format('Price: $%d each | Max: %d', pricePerFish, maxCount),
            required = true,
            default = maxCount,
            min = 1,
            max = maxCount
        }
    })
    
    if not input or not input[1] then return end
    
    local count = math.floor(input[1])
    if count < 1 or count > maxCount then
        lib.notify({
            title = 'Fish Market',
            description = 'Invalid amount',
            type = 'error'
        })
        return
    end
    
    TriggerServerEvent('brz-fishing:sellFish', itemName, count)
end

-- Command to open fish market menu
RegisterCommand('fishmarket', function()
    if isPlayerAtFishMarket() then
        openFishMarketMenu()
    else
        lib.notify({
            title = 'Fish Market',
            description = 'You must be at a fish market to sell fish',
            type = 'error'
        })
    end
end, false)

