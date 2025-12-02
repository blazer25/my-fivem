local cateringHours = 1 -- how long the catering order is valid for in hours
local cateringDetails = {
    firstname = { 'John', 'Jane', 'Jim', 'Jill', 'Jack', 'Jessie', 'Jacob', 'Jennifer', 'Jason', 'Julie', 'Mike', 'Michelle', 'Matt', 'Mary', 'Mark', 'Maria', 'Megan', 'Mason', 'Melissa', 'Max', 'Molly', 'Miles', 'Mitch' },
    lastname  = { 'Smith', 'Johnson', 'Williams', 'Jones', 'Brown', 'Davis', 'Miller', 'Wilson', 'Moore', 'Taylor', 'Anderson', 'Thomas', 'Jackson', 'White', 'Harris', 'Martin', 'Thompson', 'Garcia', 'Martinez', 'Robinson', 'Clark', 'Rodriguez', 'Lewis', 'Lee', 'Walker', 'Hall', 'Allen', 'Young', 'Hernandez', 'King', 'Wright', 'Lopez', 'Hill', 'Scott', 'Green', 'Adams', 'Baker', 'Gonzalez', 'Nelson', 'Carter', 'Mitchell', 'Perez', 'Roberts', 'Turner', 'Phillips', 'Campbell', 'Parker', 'Evans', 'Edwards', 'Collins', 'Stewart', 'Sanchez', 'Morris', 'Rogers', 'Reed' },
    locations = {
        { loc = vector4(321.72, -559.07, 28.74, 28.78),    label = 'Pillbox Hospital',            model = 's_m_m_doctor_01' },
        { loc = vector4(-4.93, -1107.83, 29.0, 161.55),    label = 'Ammunation',                  model = 's_m_y_ammucity_01' },
        { loc = vector4(-1083.0, -248.0, 37.76, 0.0),      label = 'Weazel News',                 model = 'cs_priest' },
        { loc = vector4(433.9, -977.89, 30.71, 75.57),     label = 'Police Station',              model = 'cs_priest' },
        { loc = vector4(236.56, -409.57, 47.92, 337.28),   label = 'Courthouse',                  model = 's_m_m_janitor' },
        { loc = vector4(-1681.28, -290.94, 51.88, 231.5),  label = 'Sister Deloris Gospel Choir', model = 'cs_priest' },
        { loc = vector4(217.99, -1647.05, 29.79, 320.57),  label = 'Fire Department',             model = 's_m_y_fireman_01' },
        { loc = vector4(897.7, -174.69, 73.81, 236.47),    label = 'Taxi Depot',                  model = 's_m_m_janitor' },
        { loc = vector4(559.23, 2741.34, 42.2, 186.05),    label = 'Animal Shop',                 model = 's_m_m_janitor' },
        { loc = vector4(1216.86, 2727.55, 38.0, 177.02),   label = 'Larrys Auto Sales',           model = 'csb_cletus' },
        { loc = vector4(-1043.68, 4918.7, 208.32, 277.83), label = 'Children Of The Son',         model = 'a_m_y_acult_01' },
        { loc = vector4(1696.03, 4783.06, 42.0, 100.48),   label = 'Arcade',                      model = 's_m_y_clown_01' },
        { loc = vector4(-50.08, 6361.62, 31.51, 223.2),    label = 'Feed And Supplies',           model = 'a_m_m_salton_02' },
    }
}

-- this helps allow some jobs to have catering while others do not
local cater = {}
for jobName, jobConfig in pairs(Jobs) do
    if jobConfig.CateringEnabled then
        cater[jobName] = jobConfig.catering
    else
        cater[jobName] = false
    end
end
GlobalState.Cater = cater

-------------------------
---- Local Functions ----
-------------------------

--- Generate random catering details
--- @return table - the catering details
local function generateDetail()
    local firstName   = cateringDetails.firstname[math.random(#cateringDetails.firstname)]
    local lastName    = cateringDetails.lastname[math.random(#cateringDetails.lastname)]
    local locationSet = cateringDetails.locations[math.random(#cateringDetails.locations)]
    local dueTime     = (os.time() + 3600) * cateringHours
    return {
        firstname = firstName,
        lastname  = lastName,
        location  = locationSet,
        dueby     = dueTime
    }
end

--- Get the weight of an item
--- @param item string the item name
--- @return number - the weight of the item
local function getWeight(item)
    if Config.Inv == 'ox' then
        local inventoryItems = exports.ox_inventory:Items()
        if inventoryItems[item] then
            return inventoryItems[item].weight
        end
    elseif Config.Inv == 'qb' then
        if QBCore.Shared.Items[item] then
            return QBCore.Shared.Items[item].weight
        end
    end
    return 0
end

--- Handle money distribution for catering
--- @param job string the player source
--- @param price number the total price
--- @param employeeList table list of employees (cid/name)
local function handleMoney(job, price, employeeList)
    local onlineEmployees = {}
    for _, emp in pairs(employeeList) do
        local empSrc = GetSource(emp.cid)
        if empSrc ~= -1 and DoesPlayerExist(tostring(empSrc)) then
            table.insert(onlineEmployees, empSrc)
        end
    end

    local commissionRate  = Jobs[job].catering.commission or 0
    local commissionTotal = math.floor(price * commissionRate)
    local commissionPer   = math.floor(commissionTotal / #onlineEmployees)
    local netRevenue      = math.floor(price - commissionTotal)

    for _, empSrc in pairs(onlineEmployees) do
        AddMoney(empSrc, commissionPer)
    end

    Log('Catering Order Commission paid: ' .. job, 'catering')
    AddJobMoney(job, netRevenue)
end

--- Generate a new catering order
--- @param src number the player source
--- @param job string the job name
--- @return boolean - success?
local function generateCatering(src, job)
    local existingOrders = MySQL.query.await(
        'SELECT * FROM mdjobs_catering WHERE job = ?', { job }
    )
    if existingOrders[1] then
        Notifys(src, L.cater.already, 'error')
        return false
    end
    local employees     = { { name = GetName(src), cid = GetCid(src) } }
    local itemsToCreate = math.random(1, 5)
    local orderItems    = {}
    local orderTotals   = { price = 0, amount = 0 }
    local details       = generateDetail()
    local currentWeight = 0
    repeat
        Wait(100)
        local itemConfig = Jobs[job].catering.items[math.random(#Jobs[job].catering.items)]
        local quantity   = math.random(1, itemConfig.maxAmount)
        currentWeight    = currentWeight + getWeight(itemConfig.name) * quantity

        if currentWeight > Config.MaxCateringWeight then
            itemsToCreate = 0
        end
        if itemsToCreate == 0 then break end
        local itemPrice = math.random(itemConfig.minPrice, itemConfig.maxPrice) * quantity
        local merged    = false
        for _, entry in ipairs(orderItems) do
            if entry.item == itemConfig.name then
                entry.amount = entry.amount + quantity
                entry.price  = entry.price + itemPrice
                merged       = true
                break
            end
        end
        if not merged then
            table.insert(orderItems, {
                item   = itemConfig.name,
                amount = quantity,
                price  = itemPrice
            })
        end
        orderTotals.amount = orderTotals.amount + quantity
        orderTotals.price  = orderTotals.price + itemPrice
        itemsToCreate      = itemsToCreate - 1
    until itemsToCreate == 0
    MySQL.query.await(
        'INSERT INTO mdjobs_catering (data, job, time, totals, details, employees) VALUES (?, ?, ?, ?, ?, ?)',
        {
            json.encode(orderItems),
            job,
            os.time(),
            json.encode(orderTotals),
            json.encode(details),
            json.encode(employees)
        }
    )
    Log('Catering Order Created: ' .. job .. ' Name:' .. GetName(src), 'catering')
    return true
end

--- Get the distance between two vec3 points
---@param a vector3 the first point
---@param b vector3 the second point
---@return number - the distance between points
local function getDistance(a, b)
    if not a or not b then
        return -1
    end
    local dx = (a.x or 0) - (b.x or 0)
    local dy = (a.y or 0) - (b.y or 0)
    local dz = (a.z or 0) - (b.z or 0)
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

--- Check if the catering van can be returned (and optionally delete it)
--- @param job string the name of the job
--- @param delete? boolean (optional) delete the entity if it can be returned
local function canReturnVan(job, delete)
    local vanId = Jobs[job].catering.Van.netId
    local van = NetworkGetEntityFromNetworkId(vanId)
    local vanConfig = Jobs[job].catering.Van[job]
    if DoesEntityExist(van) and getDistance(GetEntityCoords(van), vanConfig.loc) < 10.0 then
        if delete then
            DeleteEntity(van)
            Jobs[job].catering.Van.netId = nil
        end
        return true
    end
    return false
end

--- Stop/Cancel a catering order
--- @param src number the originator's player id
--- @param job string the job to cancel catering for
--- @return boolean - if the cancellation was successful
local function stopCatering(src, job)
    local currentOrder = MySQL.query.await('SELECT * FROM mdjobs_catering WHERE job = ?', { job })
    if not currentOrder[1] then return false end

    local totalsData     = json.decode(currentOrder[1].totals)
    local orderItems     = json.decode(currentOrder[1].data)
    local details        = json.decode(currentOrder[1].details)
    local employeeList   = json.decode(currentOrder[1].employees)
    local delivered      = currentOrder[1].delivered
    local customerRecord = {
        name  = details.firstname .. ' ' .. details.lastname,
        label = details.location.label
    }
    local vanReturned    = canReturnVan(job, true)

    if delivered then
        local price = totalsData.price
        if not vanReturned then
            local fee = math.floor(price * Config.VehicleReturnFee)
            price = math.floor(price - fee)
        end
        handleMoney(job, price, employeeList)
    end

    MySQL.query.await('DELETE FROM mdjobs_catering WHERE job = ?', { job })
    MySQL.query.await(
        'INSERT INTO mdjobs_completed_catering (job, receipt, employees, totals, customer, delivered, vehicle_returned) VALUES (?, ?, ?, ?, ?, ?, ?)',
        {
            job,
            json.encode(orderItems),
            currentOrder[1].employees,
            json.encode(totalsData),
            json.encode(customerRecord),
            delivered,
            vanReturned
        }
    )

    local npcNetId
    if not Config.UseClientPeds then
        npcNetId = Jobs[job].catering.npcNetId
        if npcNetId then
            local npcPed = NetworkGetEntityFromNetworkId(npcNetId)
            if DoesEntityExist(npcPed) then
                FreezeEntityPosition(npcPed, false)
                SetEntityOrphanMode(npcPed, 0) -- Allow ped to be cleaned up
            end
            Jobs[job].catering.npcNetId = nil
        end
    end

    local vanId = Jobs[job].catering.Van.netId
    if vanId then
        local van = NetworkGetEntityFromNetworkId(vanId)
        if DoesEntityExist(van) then
            DeleteEntity(van)
        end
        Jobs[job].catering.Van.netId = nil
    end

    local canceled = not delivered or not vanReturned
    for _, emp in pairs(employeeList) do
        local empSrc = GetSource(emp.cid)
        if empSrc ~= -1 and DoesPlayerExist(tostring(empSrc)) then
            TriggerClientEvent('md-jobs:client:endCatering', empSrc, job, npcNetId)
            if canceled then
                Notifys(empSrc, L.cater.manage.canceled, 'error')
            else
                Notifys(empSrc, L.cater.manage.complete, 'success')
            end
        end
    end

    Log(Format('[%s] Catering Order %s By %s (%s)', job, canceled and "Canceled" or "Ended", GetName(src), src),
        'catering')
    return true
end

--- Spawn and track a catering van
--- @param job string the job to spawn for
--- @return number | nil - the netId of the van (or nil if spawning fails)
local function spawnVan(job)
    local vanConfig = Jobs[job].catering.Van[job]
    local vehicleNetId = SpawnVehicle(vanConfig.model, vanConfig.loc, vanConfig.plate, vanConfig.livery)
    Jobs[job].catering.Van.netId = vehicleNetId

    CreateThread(function()
        if not vehicleNetId then return end

        --- Updates the stored player list
        --- @return table - an array of playerIds to update
        local function getEmployeesList()
            local currentOrder = MySQL.query.await('SELECT * FROM mdjobs_catering WHERE job = ?', { job })
            if not currentOrder[1] then return {} end
            local employeeList = json.decode(currentOrder[1].employees)
            local playerIds = {}
            for _, emp in pairs(employeeList) do
                local empSrc = GetSource(emp.cid)
                if empSrc ~= -1 and DoesPlayerExist(tostring(empSrc)) then
                    table.insert(playerIds, empSrc)
                end
            end
            return playerIds
        end

        local counter = 0
        local playerList = getEmployeesList()
        local van = NetworkGetEntityFromNetworkId(vehicleNetId)
        local blipColor = Jobs[job].Blip[1].color
        local blipLabel = Jobs[job].Blip[1].label .. ' Company Vehicle'
        while DoesEntityExist(van) do
            counter += 1
            if counter >= 60 then -- Every 2 minutes
                playerList = getEmployeesList()
                counter = 0
            end
            local coords = GetEntityCoords(van)
            for _, player in pairs(playerList) do
                if DoesPlayerExist(player) then
                    TriggerClientEvent('md-jobs:client:trackVan', player, job, coords, {
                        sprite = 67,
                        display = 4,
                        scale = 0.8,
                        color = blipColor,
                        label = blipLabel
                    })
                end
            end
            Wait(5000)
        end

        playerList = getEmployeesList()
        for _, player in pairs(playerList) do
            TriggerClientEvent('md-jobs:client:untrackVan', player, job)
        end
    end)

    return vehicleNetId
end

------------------------
---- Event Handlers ----
------------------------

RegisterNetEvent('md-jobs:server:startCatering', function(job)
    local src = source
    if not src or not job or GetJobName(src) ~= job then return end
    local result = MySQL.query.await(
        'SELECT * FROM mdjobs_catering WHERE job = ?', { job }
    )
    local info = result[1]
    if not info then
        Notifys(src, L.cater.no_cater, 'error')
        return
    end

    local employees = json.decode(info.employees)
    if not IsCateringEmployee(src, job, employees) then
        Notifys(src, L.cater.manage.not_on_order, 'error')
        return
    end

    if info.delivered then
        Notifys(src, L.cater.manage.cancel_return, 'error')
        return
    end

    info.details  = json.decode(info.details)
    local details = info.details
    if details.dueby - os.time() < 0 then
        Notifys(src, L.cater.manage.too_late, 'error')
        stopCatering(src, job)
        return
    end

    local npcNetId -- Populates if using server sided peds, else nil
    if not Config.UseClientPeds then
        npcNetId = Jobs[job].catering.npcNetId
        if not npcNetId or not DoesEntityExist(NetworkGetEntityFromNetworkId(npcNetId)) then
            npcNetId = SpawnPed(details.location.model, details.location.loc)
            if npcNetId then
                Jobs[job].catering.npcNetId = npcNetId
            else
                print("[ERR] - Failed to create catering delivery ped")
            end
        end
    end

    local vehicleNetId
    if Jobs[job].catering.Van.netId then
        local van = NetworkGetEntityFromNetworkId(Jobs[job].catering.Van.netId)
        if DoesEntityExist(van) then
            vehicleNetId = -1 -- Prevent duplicate spawn
        else
            vehicleNetId = spawnVan(job)
        end
    else
        vehicleNetId = spawnVan(job)
    end

    local blipColor = Jobs[job].Blip[1].color
    local blipLabel = Jobs[job].Blip[1].label .. 'Catering Order'
    local blipConfig = {
        sprite = 280,
        display = 2,
        scale = 0.8,
        color = blipColor,
        label = blipLabel
    }

    for _, emp in ipairs(employees) do
        local empSrc = GetSource(emp.cid)
        if empSrc ~= -1 and DoesPlayerExist(tostring(empSrc)) then
            TriggerClientEvent('md-jobs:client:cateringStarted', empSrc, job, info, npcNetId, vehicleNetId, blipConfig)
        end
    end

    Log('Catering Order Delivery Started for job ' .. job .. ' by ' .. GetName(src), 'catering')
end)

RegisterNetEvent('md-jobs:server:deliverCatering', function(job)
    local src = source
    if not src or not job or GetJobName(src) ~= job then return end
    local currentOrder = MySQL.query.await('SELECT * FROM mdjobs_catering WHERE job = ?', { job })
    if not currentOrder[1] then return end
    local employeeList = json.decode(currentOrder[1].employees)
    local orderItems   = json.decode(currentOrder[1].data)
    if not IsCateringEmployee(src, job, employeeList) then return end
    local neededCount, haveCount = 0, 0
    for _, itemEntry in pairs(orderItems) do
        if HasItem(src, itemEntry.item, itemEntry.amount) then
            haveCount = haveCount + 1
        end
        neededCount = neededCount + 1
    end
    if neededCount ~= haveCount then
        Notifys(src, L.cater.dontHave, 'error')
        return
    end
    for _, itemEntry in pairs(orderItems) do
        RemoveItem(src, itemEntry.item, itemEntry.amount)
    end

    MySQL.query('UPDATE mdjobs_catering SET delivered = ? WHERE job = ?', { 1, job })

    local npcNetId
    if not Config.UseClientPeds then
        npcNetId = Jobs[job].catering.npcNetId
        if npcNetId then
            local npcPed = NetworkGetEntityFromNetworkId(npcNetId)
            if DoesEntityExist(npcPed) then
                FreezeEntityPosition(npcPed, false)
                SetEntityOrphanMode(npcPed, 0) -- Allow ped to be cleaned up
            end
            Jobs[job].catering.npcNetId = nil
        end
    end

    local blipColor = Jobs[job].Blip[1].color
    local blipLabel = Jobs[job].Blip[1].label .. 'Company Vehicle Parking'
    local returnCoords = Jobs[job].catering.Van[job].loc
    local model = GetEntityModel(NetworkGetEntityFromNetworkId(Jobs[job].catering.Van.netId))
    local blipConfig = {
        sprite = 357,
        display = 4,
        scale = 0.8,
        color = blipColor,
        label = blipLabel
    }
    for _, emp in pairs(employeeList) do
        local empSrc = GetSource(emp.cid)
        if empSrc ~= -1 and DoesPlayerExist(tostring(empSrc)) then
            TriggerClientEvent('md-jobs:client:endDelivery', empSrc, job, npcNetId, model, returnCoords, blipConfig)
            Notifys(empSrc, L.cater.manage.delivered, 'success')
        end
    end

    Log(Format('[%s] Catering Order Delivered By %s (%s)', job, GetName(src), src), 'catering')
end)

----------------------------
---- Callback Functions ----
----------------------------

lib.callback.register('md-jobs:server:createCatering', function(source, job)
    if not source or not job or GetJobName(source) ~= job then
        return false
    end
    return generateCatering(source, job)
end)

lib.callback.register('md-jobs:server:checkCatering', function(source, job)
    if not source or not job or GetJobName(source) ~= job then
        return false
    end

    local result = MySQL.query.await(
        'SELECT * FROM mdjobs_catering WHERE job = ?', { job }
    )
    if not result then
        return
    end
    Log('Catering Order Checked: ' .. job .. ' Name:' .. GetName(source), 'catering')
    return result[1], os.time()
end)

lib.callback.register('md-jobs:server:addtoCatering', function(source, job)
    if not source or not job or GetJobName(source) ~= job then
        return
    end
    local dbResult = MySQL.query.await(
        'SELECT * FROM mdjobs_catering WHERE job = ?', { job }
    )
    if not dbResult[1] then
        Notifys(source, L.cater.no_cater, 'error')
        return false
    end
    local existingEmployees = json.decode(dbResult[1].employees)
    local delivered         = dbResult[1].delivered
    if IsCateringEmployee(source, job, existingEmployees) then
        Notifys(source, L.cater.already_on, 'error')
        return false
    end
    local newEmployeeList = {}
    for _, emp in ipairs(existingEmployees) do
        table.insert(newEmployeeList, { cid = emp.cid, name = emp.name })
    end
    table.insert(newEmployeeList, { cid = GetCid(source), name = GetName(source) })
    MySQL.query(
        'UPDATE mdjobs_catering SET employees = ? WHERE job = ?',
        { json.encode(newEmployeeList), job }
    )
    if Jobs[job].catering.Van.netId then
        local npcNetId
        if not Config.UseClientPeds then
            npcNetId = Jobs[job].catering.npcNetId
            if npcNetId then
                local npcPed = NetworkGetEntityFromNetworkId(npcNetId)
                if DoesEntityExist(npcPed) then
                    FreezeEntityPosition(npcPed, false)
                    SetEntityOrphanMode(npcPed, 0) -- Allow ped to be cleaned up
                end
                Jobs[job].catering.npcNetId = nil
            end
        end
        local vehicleNetId = Jobs[job].catering.Van.netId
        local blipColor = Jobs[job].Blip[1].color
        local blipLabel = Jobs[job].Blip[1].label
        if delivered then
            local returnCoords = Jobs[job].catering.Van[job].loc
            local model = GetEntityModel(NetworkGetEntityFromNetworkId(vehicleNetId))
            blipLabel = Jobs[job].Blip[1].label .. ' Company Vehicle Parking'
            local blipConfig = {
                sprite = 357,
                display = 4,
                scale = 0.8,
                color = blipColor,
                label = blipLabel
            }

            TriggerClientEvent('md-jobs:client:endDelivery', source, job, npcNetId, model, returnCoords, blipConfig)
            Notifys(source, L.cater.manage.delivered, 'success')
        else
            local info       = dbResult[1]
            info.details     = json.decode(info.details)
            blipLabel        = Jobs[job].Blip[1].label .. ' Company Vehicle'
            local blipConfig = {
                sprite = 67,
                display = 4,
                scale = 0.8,
                color = blipColor,
                label = blipLabel
            }
            TriggerClientEvent('md-jobs:client:cateringStarted', source, job, info, npcNetId, vehicleNetId, blipConfig)
        end
    end
    Log('Catering Order Added Employee: ' .. job .. ' Name:' .. GetName(source), 'catering')
    return true
end)

lib.callback.register('md-jobs:server:getCateringHistory', function(source, job)
    if not source or not job or GetJobName(source) ~= job then
        return
    end
    local history = MySQL.query.await(
        'SELECT * FROM mdjobs_completed_catering WHERE job = ? ORDER BY id DESC', { job }
    )
    if not history[1] then
        return
    end
    Log('Catering Order History Checked: ' .. job .. ' Name:' .. GetName(source), 'catering')
    return history
end)

lib.callback.register('md-jobs:server:endCatering', function(source)
    if not source then return false end
    local job = GetJobName(source)
    if not IsCateringEmployee(source, job) then
        Notifys(source, L.cater.manage.not_on_order, 'error')
        return
    end
    return stopCatering(source, job)
end)

lib.callback.register('md-jobs:server:isCatering', function(source, job)
    if not source or not job or GetJobName(source) ~= job or not IsCateringEmployee(source, job) then
        return false
    end
    return true
end)
