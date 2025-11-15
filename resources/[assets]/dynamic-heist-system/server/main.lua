-- main.lua (Server-side)
-- Entry point for server logic in the Dynamic Heist System

local Global = _G.DynamicHeist or {}
_G.DynamicHeist = Global
local Manager = Global.Manager

local function canUseCommand(source)
    if source == 0 then return true end
    return IsPlayerAceAllowed(source, "heist.admin")
end

local function resolveTarget(source, args)
    if source ~= 0 then
        return source
    end
    if args[2] then
        return tonumber(args[2])
    end
    return nil
end

RegisterCommand("start_heist", function(source, args)
    if not canUseCommand(source) then
        TriggerClientEvent("heist:notify", source, "You do not have permission to run heists manually.")
        return
    end
    if not Manager then
        print("[DynamicHeist] Manager not ready.")
        return
    end
    local heistId = args[1] or "fleeca"
    local target = resolveTarget(source, args)
    if not target then
        print("[DynamicHeist] Missing target player for console start.")
        return
    end
    Manager:StartHeist(target, heistId)
end)

RegisterNetEvent("heist:initiate", function(heistId)
    local src = source
    heistId = heistId or "fleeca"
    if not Manager then return end
    Manager:StartHeist(src, heistId)
end)

RegisterNetEvent("heist:notify_police", function(payload)
    local cfg = payload or {}
    TriggerEvent("heist:dispatch", cfg.heistId or "manual", cfg)
end)
