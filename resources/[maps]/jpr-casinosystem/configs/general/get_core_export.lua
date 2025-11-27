local function fetchCore(name)
    local resourceState = GetResourceState(name)
    if resourceState ~= 'started' and resourceState ~= 'starting' then return nil end

    local ok, core = pcall(function()
        return exports[name]:GetCoreObject()
    end)

    if ok then return core end
    return nil
end

-- Retry mechanism to wait for core to be ready
local core = nil
local attempts = 0
local maxAttempts = 50 -- Wait up to 5 seconds (50 * 100ms)

while not core and attempts < maxAttempts do
    core = fetchCore(Config.CoreName) or fetchCore('qb-core')
    if not core then
        Wait(100)
        attempts = attempts + 1
    end
end

if not core or not core.Functions then
    error('[JPR Casino] Unable to fetch core object. Ensure qbx_core or qb-core is running before jpr-casinosystem.')
end

_G.QBCore = core
TargetZonesCreated = TargetZonesCreated or {}

return core