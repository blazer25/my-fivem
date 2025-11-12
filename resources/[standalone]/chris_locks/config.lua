--[[
    Chris Locks System
    Author: Chris Hepburn
    Description: Advanced player and business lock system for FiveM (Qbox / QB / OX compatible)
    Version: 1.0.0
]]

Config = {}

-- Framework detection preference order
Config.FrameworkPriority = {
    'qbx_core',
    'qb-core'
}

Config.InventoryResources = {
    'ox_inventory'
}

Config.Notification = {
    useOxLib = true,
    fallbackTitle = 'Locks'
}

Config.DefaultUnlockDuration = 300 -- seconds
Config.InteractionKey = 'E'
Config.Debug = false
Config.DebugPermission = 'chrislocks.admin'

-- Optional: preload static locks here. Locks added via commands persist in the database.
Config.StaticLocks = {
    --[[
    {
        id = 'example_password_door',
        type = 'password',
        coords = vec3(100.0, 100.0, 100.0),
        radius = 2.0,
        hidden = true,
        password = '1234',
        targetDoorId = 'example_door',
        unlockDuration = 120
    }
    ]]
}

Config.Locale = 'en'
