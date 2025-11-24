local config = require 'config.server'

local function getAvailableDrugs(source)
    local availableDrugs = {}
    local player = exports.qbx_core:GetPlayer(source)

    if not player then return nil end

    for i = 1, #config.cornerSellingDrugsList do
        local itemName = config.cornerSellingDrugsList[i]
        local itemCount = exports.ox_inventory:Search(source, 'count', itemName)
        if itemCount > 0 then
            availableDrugs[#availableDrugs + 1] = {
                item = itemName,
                amount = itemCount,
                label = exports.ox_inventory:Items()[itemName].label
            }
        end
    end
    return table.type(availableDrugs) ~= 'empty' and availableDrugs or nil
end

lib.callback.register('qb-drugs:server:getDrugOffer', function(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return nil end
    local availableDrugs = getAvailableDrugs(player.PlayerData.source)
    if availableDrugs == nil then return nil end

    -- Weighted random selection based on drug tiers (weed most common, meth rare)
    local weightedDrugs = {}
    local totalWeight = 0
    
    for i = 1, #availableDrugs do
        local drugItem = availableDrugs[i].item
        local tier = config.drugTiers[drugItem]
        local weight = tier and tier.requestWeight or 1
        totalWeight = totalWeight + weight
        weightedDrugs[#weightedDrugs + 1] = {
            drug = availableDrugs[i],
            weight = weight,
            index = i
        }
    end
    
    -- Select drug based on weighted probability
    local randomWeight = math.random(1, totalWeight)
    local chosenDrug = nil
    local chosenIndex = 1
    local cumulativeWeight = 0
    
    for i = 1, #weightedDrugs do
        cumulativeWeight = cumulativeWeight + weightedDrugs[i].weight
        if randomWeight <= cumulativeWeight then
            chosenDrug = weightedDrugs[i].drug
            chosenIndex = weightedDrugs[i].index
            break
        end
    end
    
    -- Fallback to random if something went wrong
    if not chosenDrug then
        local randomDrug = math.random(1, #availableDrugs)
        chosenDrug = availableDrugs[randomDrug]
        chosenIndex = randomDrug
    end
    
    local offeredAmount = math.random(1, chosenDrug.amount > 15 and 15 or chosenDrug.amount)
    local basePrice = math.random(config.cornerSellingDrugsPrice[chosenDrug.item].min, config.cornerSellingDrugsPrice[chosenDrug.item].max)
    local totalPrice = config.scamChance >= math.random(1, 100) and basePrice * offeredAmount or math.random(3, 10) * offeredAmount

    return { chosen = chosenDrug, idx = chosenIndex, amount = offeredAmount, total = totalPrice }
end)

RegisterNetEvent('qb-drugs:server:giveStealItems', function(drugType, amount)
    local availableDrugs = getAvailableDrugs(source)
    local player = exports.qbx_core:GetPlayer(source)

    if not availableDrugs or not player then return end

    exports.ox_inventory:AddItem(player.PlayerData.source, availableDrugs[drugType].item, amount)
end)

RegisterNetEvent('qb-drugs:server:sellCornerDrugs', function(drugType, amount, price)
    local player = exports.qbx_core:GetPlayer(source)
    local availableDrugs = getAvailableDrugs(player.PlayerData.source)

    if not availableDrugs or not player then return end

    local item = availableDrugs[drugType].item

    local hasItem = player.Functions.GetItemByName(item)
    if hasItem.amount >= amount then
        exports.qbx_core:Notify(player.PlayerData.source, locale('success.offer_accepted'), 'success')
        exports.ox_inventory:RemoveItem(player.PlayerData.source, item, amount)
        player.Functions.AddMoney('cash', price, 'sold-cornerdrugs')
        if config.policeCallChance >= math.random(1, 100) then
            TriggerEvent('police:server:policeAlert', locale('info.possible_drug_dealing'), nil, player.PlayerData.source)
        end
    else
        TriggerClientEvent('qb-drugs:client:cornerselling', player.PlayerData.source)
    end
end)

RegisterNetEvent('qb-drugs:server:robCornerDrugs', function(drugType, amount)
    local player = exports.qbx_core:GetPlayer(source)
    local availableDrugs = getAvailableDrugs(player.PlayerData.source)

    if not availableDrugs or not player then return end

    local item = availableDrugs[drugType].item

    exports.ox_inventory:RemoveItem(player.PlayerData.source, item, amount)
end)
