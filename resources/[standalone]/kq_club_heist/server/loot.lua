
function GetLootKey(key)
    return 'kq_club_heist_loot_' .. key
end

function RemoveLoot()
    if GetResourceState('kq_lootareas') ~= 'started' then
        return
    end
    
    for k, loot in pairs(Config.loot) do
        local areaKey = GetLootKey(k)
        local success, err = pcall(function()
            if exports['kq_lootareas'] and exports['kq_lootareas'].DeleteArea then
                exports['kq_lootareas']:DeleteArea(areaKey)
            end
        end)
        if not success then
            print('^3[KQ_CLUB_HEIST] Warning: Could not delete area ' .. areaKey .. ': ' .. tostring(err) .. '^7')
        end
    end
end

function PrepareLoot()
    for k, loot in pairs(Config.loot) do
        SpawnLoot(loot, k)
    end
end

function SpawnLoot(loot, key)
    if GetResourceState('kq_lootareas') ~= 'started' then
        print('^1[KQ_CLUB_HEIST] ERROR: kq_lootareas is not started! Cannot spawn loot.^7')
        return
    end
    
    if not exports['kq_lootareas'] or not exports['kq_lootareas'].CreateArea then
        print('^1[KQ_CLUB_HEIST] ERROR: kq_lootareas exports not available!^7')
        return
    end
    
    local areaKey = GetLootKey(key)
    
    -- Try to delete existing area first
    local success, err = pcall(function()
        if exports['kq_lootareas'].DeleteArea then
            exports['kq_lootareas']:DeleteArea(areaKey)
        end
    end)

    if loot.chance < math.random(0, 100) then
        return
    end

    local lootArea = {
        name = 'Club heist ' .. loot.label,
        renderDistance = 25.0,
        coords = loot.coords,
        radius = loot.radius + 0.0,
        amount = loot.amount,
        regrowTime = 9999999999, -- never respawn loot automatically

        items = {
            {
                item = loot.item.name,
                chance = 100,
                amount = {
                    min = loot.item.min,
                    max = loot.item.max,
                },
            }
        },

        props = {
            {
                hash = loot.model,
                textureVariation = 0,
                chance = 100,
                minimumDistanceBetween = 0.2,
                offset = vector3(0.0, 0.0, 0.0),

                rotation = loot.rotation or nil,

                forceZCoordinate = true,
                animation = {
                    duration = 0.7, -- in seconds
                    dict = 'mp_take_money_mg',
                    anim = 'put_cash_into_bag_loop',
                    flag = 17,
                },
                labelSingular = loot.label,
                labelPlurar = loot.label,
                collectMessage = L('Steal the {NAME}'):gsub('{NAME}', loot.label),
                icon = 'fas fa-hand',

                requiredItems = loot.requiredItems,
            },
        },
    }

    success, err = pcall(function()
        exports['kq_lootareas']:CreateArea(areaKey, lootArea)
    end)
    
    if not success then
        print('^1[KQ_CLUB_HEIST] ERROR creating loot area ' .. areaKey .. ': ' .. tostring(err) .. '^7')
    end
end

-- Wait for kq_lootareas to be ready before removing loot
CreateThread(function()
    local attempts = 0
    while GetResourceState('kq_lootareas') ~= 'started' do
        Wait(100)
        attempts = attempts + 1
        if attempts > 50 then
            print('^1[KQ_CLUB_HEIST] ERROR: kq_lootareas not started after 5 seconds!^7')
            return
        end
    end
    
    -- Wait a bit more for exports to be available
    Wait(500)
    RemoveLoot()
end)
