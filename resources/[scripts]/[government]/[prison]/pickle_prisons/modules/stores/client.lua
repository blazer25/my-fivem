StoreInteractions = {}

function CleanupStores()
    for i=1, #StoreInteractions do
        DeleteInteraction(StoreInteractions[i])
        StoreInteractions[i] = nil
    end
end

-- Helper function to safely get item label
local function GetItemLabel(itemName)
    if not itemName then return itemName or "Unknown Item" end
    
    -- Try Inventory.Items first
    if Inventory.Items and Inventory.Items[itemName] then
        return Inventory.Items[itemName].label
    end
    
    -- Try lowercase version
    local lowerName = itemName:lower()
    if Inventory.Items and Inventory.Items[lowerName] then
        return Inventory.Items[lowerName].label
    end
    
    -- Try ox_inventory directly
    if GetResourceState('ox_inventory') == 'started' then
        local oxItem = exports.ox_inventory:Items(lowerName)
        if oxItem and oxItem.label then
            return oxItem.label
        end
    end
    
    -- Fallback to formatted item name
    return itemName:gsub("_", " "):gsub("^%l", string.upper)
end

function StoreSelectItem(index, itemIndex)
    local prisonIndex = Prison.index
    local prison = Config.Prisons[prisonIndex]
    local store = prison.stores[index]
    local item = store.catalog[itemIndex]
    local options = {}
    for i=1, #item.required do 
        local required = item.required[i]
        local title
        local description
        if required.type ~= "cash" then
            title = GetItemLabel(required.name)
            description = "x" .. required.amount
        else
            title = "$" .. required.amount
        end
        local option = {
            title = title,
            description = description
        }
        options[#options + 1] = option
    end
    options[#options + 1] = {
        title = _L("confirm_transaction"),
        description = _L("confirm_transaction_desc"),
        onSelect = function()
            TriggerServerEvent("pickle_prisons:storeTransaction", prisonIndex, index, itemIndex)
        end
    }
    local id = 'prison_store_' .. prisonIndex .. "_" .. index .. "_" .. itemIndex
    lib.registerContext({
        id = id,
        title = store.label,
        options = options
    })
    lib.showContext(id)
end

function DisplayStore(index)
    local options = {}
    local prisonIndex = Prison.index
    local prison = Config.Prisons[prisonIndex]
    local store = prison.stores[index]
    for i=1, #store.catalog do 
        local item = store.catalog[i]
        local description
        if not item.required or #item.required > 1 or item.required[1].type ~= "cash" then
            description = item.description
        else
            description = "$" .. item.required[1].amount .. " - " .. item.description
        end
        local option = {
            title = GetItemLabel(item.name),
            description = description,
            onSelect = function()
                StoreSelectItem(index, i)
            end
        }
        options[#options + 1] = option
    end
    if #options < 1 then return end
    local id = 'prison_store_' .. prisonIndex .. "_" .. index
    lib.registerContext({
        id = id,
        title = store.label,
        options = options
    })
    lib.showContext(id)
end

RegisterNetEvent("pickle_prisons:enterPrison", function()
    CleanupStores()
    local index = Prison.index
    local prison = Config.Prisons[index]
    for i=1, #prison.stores do 
        local store = prison.stores[i]
        StoreInteractions[i] = CreateInteraction({
            label = store.label,
            model = store.model,
            coords = store.coords,
            heading = store.heading
        }, function(selected)
            DisplayStore(i)
        end) 
    end
end)

RegisterNetEvent("pickle_prisons:leavePrison", function()
    CleanupStores()
end)