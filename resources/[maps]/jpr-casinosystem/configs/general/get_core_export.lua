local core = exports[Config.CoreName]:GetCoreObject()

if not core then
    error(('[JPR Casino] Unable to fetch core object from export %s'):format(Config.CoreName))
end

_G.QBCore = core
TargetZonesCreated = TargetZonesCreated or {}

return core