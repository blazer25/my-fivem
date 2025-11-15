local Global = _G.DynamicHeist or {}
_G.DynamicHeist = Global

local Manager = Global.Manager
local json = json
local RESOURCE_NAME = GetCurrentResourceName()
local DATA_FILE = "data/heists.json"

local function ensureManager()
    if Manager then return end
    local attempts = 0
    while not Global.Manager do
        Citizen.Wait(50)
        attempts = attempts + 1
        if attempts > 200 then
            break
        end
    end
    Manager = Global.Manager
end

local function hasPermission(source)
    if source == 0 then return true end
    return IsPlayerAceAllowed(source, "heist.admin")
end

local function reply(source, message)
    if source == 0 then
        print("[HeistAdmin] " .. message)
    else
        TriggerClientEvent("heist:notify", source, message)
    end
end

local function getHeists()
    ensureManager()
    return Manager and Manager:GetHeists() or {}
end

local function getOrCreateHeist(heistId)
    local heists = getHeists()
    if not heists[heistId] then
        heists[heistId] = {
            label = heistId,
            tier = 1,
            location = vector3(0.0, 0.0, 0.0),
            radius = 3.0,
            requiredPolice = 0,
            requiredItems = {},
            cooldown = Config.GlobalCooldown.base,
            stages = {},
            rewards = {tier = 1, bonus = {}},
            responses = {alarm = "generic", dispatch = "generic"}
        }
    end
    return heists[heistId]
end

local function parseList(value)
    local items = {}
    if not value or value == "" then return items end
    for entry in string.gmatch(value, "([^,]+)") do
        local trimmed = entry:match("^%s*(.-)%s*$")
        if trimmed and trimmed ~= "" then
            table.insert(items, trimmed)
        end
    end
    return items
end

local function saveToDisk(source)
    ensureManager()
    if not Manager then
        reply(source, "Manager not ready; cannot save.")
        return
    end
    local serialized = Manager:SerializeHeists()
    local encoded = json.encode(serialized)
    SaveResourceFile(RESOURCE_NAME, DATA_FILE, encoded, -1)
    reply(source, "Heist configuration saved to disk.")
end

local function loadFromDisk(source)
    ensureManager()
    if not Manager then
        reply(source, "Manager not ready; cannot load.")
        return
    end
    local raw = LoadResourceFile(RESOURCE_NAME, DATA_FILE)
    if not raw or raw == "" then
        reply(source, "No heist data file found; using defaults.")
        return
    end
    local decoded = json.decode(raw)
    if not decoded then
        reply(source, "Failed to decode heist data file.")
        return
    end
    local restored = Manager:DeserializeHeists(decoded)
    Manager:SetHeists(restored, true)
    Manager:SyncHeists()
    reply(source, "Heist overrides loaded and synced.")
end

CreateThread(function()
    ensureManager()
    if Manager then
        loadFromDisk(0)
    end
end)

local function summarizeHeist(id, data)
    local stages = data.stages or {}
    return string.format("%s | Tier %s | Req PD %s | Radius %.1f | Stages %s | Cooldown %ss",
        id,
        data.tier or 1,
        data.requiredPolice or 0,
        data.radius or 0.0,
        #stages,
        data.cooldown or 0
    )
end

local function deleteHeist(heistId)
    local heists = getHeists()
    heists[heistId] = nil
end

RegisterCommand("heistadmin", function(source, args)
    if not hasPermission(source) then
        reply(source, "You do not have permission to use heistadmin.")
        return
    end
    ensureManager()
    if not Manager then
        reply(source, "Heist manager unavailable.")
        return
    end
    local sub = args[1] and args[1]:lower() or "help"
    if sub == "list" then
        for id, data in pairs(getHeists()) do
            reply(source, summarizeHeist(id, data))
        end
        reply(source, "Use /heistadmin info <id> for details.")
        return
    elseif sub == "info" then
        local heistId = args[2]
        if not heistId then
            reply(source, "Usage: /heistadmin info <heistId>")
            return
        end
        local heist = getHeists()[heistId]
        if not heist then
            reply(source, ("Heist %s not found."):format(heistId))
            return
        end
        reply(source, summarizeHeist(heistId, heist))
        reply(source, ("Items: %s"):format(table.concat(heist.requiredItems or {}, ", ")))
        reply(source, ("Responses: alarm=%s dispatch=%s"):format(
            heist.responses and heist.responses.alarm or "none",
            heist.responses and heist.responses.dispatch or "none"
        ))
        for idx, stage in ipairs(heist.stages or {}) do
            reply(source, ("Stage %s: %s (%ss) [%s]"):format(idx, stage.label or stage.type, stage.duration or 0, stage.type))
        end
        return
    elseif sub == "create" then
        local heistId = args[2]
        if not heistId then
            reply(source, "Usage: /heistadmin create <heistId>")
            return
        end
        local heist = getOrCreateHeist(heistId)
        Manager:SyncHeists()
        reply(source, ("Heist %s ready for editing."):format(heist.label))
        return
    elseif sub == "delete" then
        local heistId = args[2]
        if not heistId then
            reply(source, "Usage: /heistadmin delete <heistId>")
            return
        end
        deleteHeist(heistId)
        Manager:SyncHeists()
        reply(source, ("Deleted heist %s"):format(heistId))
        return
    elseif sub == "setpos" then
        local heistId = args[2]
        local radius = args[3] and tonumber(args[3]) or nil
        if not heistId then
            reply(source, "Usage: /heistadmin setpos <heistId> [radius]")
            return
        end
        if source == 0 then
            reply(source, "Cannot set position from console.")
            return
        end
        local ped = GetPlayerPed(source)
        if not DoesEntityExist(ped) then
            reply(source, "Player ped missing.")
            return
        end
        local coords = GetEntityCoords(ped)
        local heist = getOrCreateHeist(heistId)
        heist.location = vector3(coords.x, coords.y, coords.z)
        if radius then heist.radius = radius end
        Manager:SyncHeists()
        reply(source, ("Set %s location (%.2f, %.2f, %.2f) radius %.1f"):format(
            heistId, coords.x, coords.y, coords.z, heist.radius
        ))
        return
    elseif sub == "set" then
        local heistId, field, value = args[2], args[3], args[4]
        if not heistId or not field or not value then
            reply(source, "Usage: /heistadmin set <heistId> <field> <value>")
            return
        end
        local heist = getOrCreateHeist(heistId)
        field = field:lower()
        if field == "label" then
            heist.label = table.concat(args, " ", 4)
        elseif field == "tier" or field == "requiredpolice" or field == "radius" or field == "cooldown" then
            local numberValue = tonumber(value)
            if not numberValue then
                reply(source, "Value must be numeric.")
                return
            end
            if field == "tier" then
                heist.tier = math.max(1, math.floor(numberValue))
            elseif field == "requiredpolice" then
                heist.requiredPolice = math.max(0, math.floor(numberValue))
            elseif field == "radius" then
                heist.radius = numberValue
            elseif field == "cooldown" then
                heist.cooldown = math.max(0, numberValue)
            end
        else
            reply(source, ("Unknown field %s"):format(field))
            return
        end
        Manager:SyncHeists()
        reply(source, ("Updated %s field %s"):format(heistId, field))
        return
    elseif sub == "stageadd" then
        local heistId, stageType, duration = args[2], args[3], tonumber(args[4] or "0")
        if not heistId or not stageType or duration <= 0 then
            reply(source, "Usage: /heistadmin stageadd <heistId> <type> <duration> <label...>")
            return
        end
        local label = table.concat(args, " ", 5)
        if label == "" then label = stageType end
        local heist = getOrCreateHeist(heistId)
        heist.stages = heist.stages or {}
        table.insert(heist.stages, {
            type = stageType,
            label = label,
            duration = duration
        })
        Manager:SyncHeists()
        reply(source, ("Added stage to %s: %s (%ss)"):format(heistId, label, duration))
        return
    elseif sub == "stagedel" then
        local heistId, index = args[2], tonumber(args[3] or "-1")
        if not heistId or index < 1 then
            reply(source, "Usage: /heistadmin stagedel <heistId> <index>")
            return
        end
        local heist = getHeists()[heistId]
        if not heist or not heist.stages or not heist.stages[index] then
            reply(source, "Stage not found.")
            return
        end
        table.remove(heist.stages, index)
        Manager:SyncHeists()
        reply(source, ("Removed stage %s from %s"):format(index, heistId))
        return
    elseif sub == "items" then
        local heistId = args[2]
        if not heistId then
            reply(source, "Usage: /heistadmin items <heistId> <item1,item2,...>")
            return
        end
        local heist = getOrCreateHeist(heistId)
        local items = table.concat(args, " ", 3)
        heist.requiredItems = parseList(items)
        Manager:SyncHeists()
        reply(source, ("Updated required items for %s"):format(heistId))
        return
    elseif sub == "responses" then
        local heistId, alarm, dispatch = args[2], args[3], args[4]
        if not heistId or not alarm then
            reply(source, "Usage: /heistadmin responses <heistId> <alarm> [dispatch]")
            return
        end
        local heist = getOrCreateHeist(heistId)
        heist.responses = heist.responses or {}
        heist.responses.alarm = alarm
        heist.responses.dispatch = dispatch or heist.responses.dispatch or "generic"
        Manager:SyncHeists()
        reply(source, ("Updated responses for %s"):format(heistId))
        return
    elseif sub == "rewards" then
        local heistId, tier = args[2], tonumber(args[3] or "0")
        if not heistId or tier <= 0 then
            reply(source, "Usage: /heistadmin rewards <heistId> <tier> [bonus1,bonus2]")
            return
        end
        local heist = getOrCreateHeist(heistId)
        heist.rewards = heist.rewards or {}
        heist.rewards.tier = tier
        if args[4] then
            heist.rewards.bonus = parseList(table.concat(args, " ", 4))
        end
        Manager:SyncHeists()
        reply(source, ("Updated rewards for %s"):format(heistId))
        return
    elseif sub == "save" then
        saveToDisk(source)
        return
    elseif sub == "reload" then
        loadFromDisk(source)
        return
    else
        reply(source, "Heist Admin Commands:")
        reply(source, "/heistadmin list | info <id> | create <id> | delete <id>")
        reply(source, "/heistadmin setpos <id> [radius] | set <id> <field> <value>")
        reply(source, "/heistadmin items <id> item1,item2 | stageadd/stagedel")
        reply(source, "/heistadmin responses <id> <alarm> [dispatch]")
        reply(source, "/heistadmin rewards <id> <tier> [bonus...]")
        reply(source, "/heistadmin save | reload")
        return
    end
end, true)

