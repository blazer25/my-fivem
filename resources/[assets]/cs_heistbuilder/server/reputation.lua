local Reputation = {}
local Utils = CS_HEIST_SHARED_UTILS or {}
local repFile = 'data/reputation.json'
local cache = {}

local function load()
    local content = LoadResourceFile(GetCurrentResourceName(), repFile)
    if content then
        cache = json.decode(content) or {}
    else
        cache = {}
    end
end

local function save()
    SaveResourceFile(GetCurrentResourceName(), repFile, json.encode(cache, { indent = true }), -1)
end

function Reputation.get(identifier)
    if not Config.Reputation.Enabled then return 0 end
    return cache[identifier] or Config.Reputation.Default or 0
end

function Reputation.add(identifier, amount)
    if not Config.Reputation.Enabled then return 0 end
    cache[identifier] = Reputation.get(identifier) + amount
    save()
    return cache[identifier]
end

function Reputation.set(identifier, amount)
    cache[identifier] = amount
    save()
end

function Reputation.canAccess(identifier, requirement)
    if not Config.Reputation.Enabled then return true end
    if not requirement or requirement <= 0 then return true end
    return Reputation.get(identifier) >= requirement
end

load()

CS_HEIST_REPUTATION = Reputation

return Reputation
