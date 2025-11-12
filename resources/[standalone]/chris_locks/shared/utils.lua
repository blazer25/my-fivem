--[[
    Chris Locks System
    Author: Chris Hepburn
    Description: Advanced player and business lock system for FiveM (Qbox / QB / OX compatible)
    Version: 1.0.0
]]

local locale = Config.Locale or 'en'
local translations = Locales and Locales[locale] or {}

local function _(key, ...)
    local text = translations[key]
    if text then
        if select('#', ...) > 0 then
            return text:format(...)
        end
        return text
    end
    return key
end

local function resourceActive(name)
    return GetResourceState(name) == 'started'
end

local function notify(source, message, type)
    if Config.Notification.useOxLib and resourceActive('ox_lib') and lib then
        if source == 0 then
            if lib.print and lib.print.info then
                lib.print.info(message)
            else
                print(('[chris_locks] %s'):format(message))
            end
        else
            if lib.notify then
                lib.notify(source, {
                    title = Config.Notification.fallbackTitle,
                    description = message,
                    type = type or 'inform'
                })
            else
                TriggerClientEvent('ox_lib:notify', source, {
                    title = Config.Notification.fallbackTitle,
                    description = message,
                    type = type or 'inform'
                })
            end
        end
    else
        if source == 0 then
            print(('[chris_locks] %s'):format(message))
        else
            TriggerClientEvent('chat:addMessage', source, {
                color = { 0, 153, 204 },
                multiline = true,
                args = { Config.Notification.fallbackTitle, message }
            })
        end
    end
end

return {
    _ = _,
    notify = notify,
    resourceActive = resourceActive,
}
