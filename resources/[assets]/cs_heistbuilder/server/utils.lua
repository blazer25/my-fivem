local Utils = CS_HEIST_SHARED_UTILS or {}
local Storage = {}
local HeistCache = {}

local resourcePath = GetResourcePath(GetCurrentResourceName())
local jsonDir = Config.Storage.JsonDirectory or 'configs/heists'
local absoluteDir = ('%s/%s'):format(resourcePath, jsonDir)
local isUsingJson = Config.Storage.Mode == 'json'
local jsonPrepared = false

local function ensureDir()
    if not isUsingJson or jsonPrepared then return end
    os.execute(('mkdir \"%s\" 2>nul'):format(absoluteDir))
    jsonPrepared = true
end

local function readJsonFiles()
    ensureDir()
    local heists = {}
    local handle = io.popen(('dir \"%s\" /b'):format(absoluteDir))
    if not handle then return heists end
    for file in handle:read('*a'):gmatch('[^\r\n]+') do
        if file:match('%.json$') then
            local content = LoadResourceFile(GetCurrentResourceName(), ('configs/heists/%s'):format(file))
            if content then
                local data = json.decode(content)
                if data then heists[#heists + 1] = data end
            end
        end
    end
    handle:close()
    return heists
end

local function fetchMysql()
    local heists = MySQL.query.await(('SELECT * FROM %s'):format(Config.Storage.MySQLTable))
    local parsed = {}
    if heists then
        for _, row in ipairs(heists) do
            local data = json.decode(row.data)
            if data then parsed[#parsed + 1] = data end
        end
    end
    return parsed
end

function Storage.loadAll()
    local data = isUsingJson and readJsonFiles() or fetchMysql()
    HeistCache = {}
    for _, heist in ipairs(data or {}) do
        if heist and heist.id then
            HeistCache[heist.id] = heist
        end
    end
    if (not next(HeistCache)) and type(Config.Heists) == 'table' then
        for _, heist in ipairs(Config.Heists) do
            if heist.id then
                HeistCache[heist.id] = heist
            end
        end
    end
    return HeistCache
end

local function saveJson(heist)
    ensureDir()
    local rel = ('configs/heists/%s.json'):format(heist.id)
    SaveResourceFile(GetCurrentResourceName(), rel, json.encode(heist, { indent = true }), -1)
end

local function saveMysql(heist)
    MySQL.insert(([[
        INSERT INTO %s (heist_id, data) VALUES (?, ?) ON DUPLICATE KEY UPDATE data = VALUES(data)
    ]]):format(Config.Storage.MySQLTable), {
        heist.id,
        json.encode(heist)
    })
end

function Storage.saveHeist(heist)
    if isUsingJson then
        saveJson(heist)
    else
        saveMysql(heist)
    end
    HeistCache[heist.id] = heist
end

function Storage.getHeists()
    return HeistCache
end

function Storage.removeHeist(id)
    HeistCache[id] = nil
    if isUsingJson then
        SaveResourceFile(GetCurrentResourceName(), ('configs/heists/%s.json'):format(id), '', 0)
    else
        MySQL.update(('DELETE FROM %s WHERE heist_id = ?'):format(Config.Storage.MySQLTable), { id })
    end
end

local function getIdentifier(source)
    if exports['qbx_core'] and exports['qbx_core'].GetPlayer then
        local player = exports['qbx_core']:GetPlayer(source)
        if player then return player.PlayerData.citizenid end
    end
    for _, identifier in ipairs(GetPlayerIdentifiers(source)) do
        if identifier:find('license:') then
            return identifier
        end
    end
    return ('temp_%s'):format(source)
end

CS_HEIST_SERVER = {
    Storage = Storage,
    Heists = HeistCache,
    Utils = Utils,
    GetIdentifier = getIdentifier
}

return Storage
