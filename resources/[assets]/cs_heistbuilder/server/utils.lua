local Utils = CS_HEIST_SHARED_UTILS or {}
local Storage = {}
local HeistCache = {}

local resourceName = GetCurrentResourceName()
local resourcePath = GetResourcePath(resourceName)

local function normaliseRelativePath(path)
    path = (path or 'configs/heists'):gsub('\\', '/')
    path = path:gsub('^%./', '')
    path = path:gsub('/+$', '')
    local prefix = resourceName .. '/'
    if path:sub(1, #prefix) == prefix then
        path = path:sub(#prefix + 1)
    end
    if path == '' then
        path = 'configs/heists'
    end
    return path
end

local jsonDir = normaliseRelativePath(Config.Storage.JsonDirectory)
local absoluteDir = ('%s/%s'):format(resourcePath, jsonDir)
local isWindows = resourcePath:find('\\', 1, true) ~= nil
local isUsingJson = Config.Storage.Mode == 'json'
local jsonPrepared = false

local function ensureDir()
    if not isUsingJson or jsonPrepared then return end
    if isWindows then
        os.execute(('cmd /c if not exist \"%s\" mkdir \"%s\"'):format(absoluteDir, absoluteDir))
    else
        os.execute(('mkdir -p \"%s\"'):format(absoluteDir))
    end
    jsonPrepared = true
end

local function buildDirCommand(path, redirect)
    if isWindows then
        if redirect then
            return ('cmd /c dir \"%s\" /b > \"%s\"'):format(path, redirect)
        end
        return ('cmd /c dir \"%s\" /b'):format(path)
    else
        if redirect then
            return ('ls -1 \"%s\" > \"%s\"'):format(path, redirect)
        end
        return ('ls -1 \"%s\"'):format(path)
    end
end

local function captureDirectoryListing()
    local contents
    if io and io.popen then
        local handle = io.popen(buildDirCommand(absoluteDir))
        if handle then
            if type(handle.read) == 'function' then
                local ok, result = pcall(handle.read, handle, '*a')
                if ok then contents = result end
            end
            if handle.close then handle:close() end
        end
    end

    if contents and contents ~= '' then
        return contents
    end

    if not os.tmpname or not os.execute then
        return ''
    end

    local tmpPath = os.tmpname()
    if not tmpPath then return '' end

    if isWindows and not tmpPath:match('^%a:[\\/]') then
        local tempDir = os.getenv('TEMP') or os.getenv('TMP') or resourcePath
        tempDir = tempDir:gsub('[\\/]+$', '')
        tmpPath = ('%s\\%s'):format(tempDir, tmpPath:gsub('^\\', ''))
    end

    local command = buildDirCommand(absoluteDir, tmpPath)
    local ok = os.execute(command)
    if not ok then
        os.remove(tmpPath)
        return ''
    end

    local file = io.open(tmpPath, 'r')
    if not file then
        os.remove(tmpPath)
        return ''
    end

    contents = file:read('*a') or ''
    file:close()
    os.remove(tmpPath)
    return contents
end

local function getRelativeJsonPath(fileName)
    return ('%s/%s'):format(jsonDir, fileName)
end

local function readJsonFiles()
    ensureDir()
    local heists = {}
    local listing = captureDirectoryListing()
    if listing == '' then return heists end
    for file in listing:gmatch('[^\r\n]+') do
        if file:match('%.json$') then
            local content = LoadResourceFile(resourceName, getRelativeJsonPath(file))
            if content then
                local data = json.decode(content)
                if data then heists[#heists + 1] = data end
            end
        end
    end
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
    local rel = getRelativeJsonPath(('%s.json'):format(heist.id))
    SaveResourceFile(resourceName, rel, json.encode(heist, { indent = true }), -1)
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
        SaveResourceFile(resourceName, getRelativeJsonPath(('%s.json'):format(id)), '', 0)
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
