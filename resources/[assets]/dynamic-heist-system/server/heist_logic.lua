local Global = _G.DynamicHeist or {}
_G.DynamicHeist = Global
local DynamicHeist = Global
DynamicHeist.Manager = DynamicHeist.Manager or {}

local Manager = DynamicHeist.Manager

Manager.states = Manager.states or {}
Manager.cooldowns = Manager.cooldowns or {}
Manager.playerData = Manager.playerData or {}
Manager.heistConfig = Manager.heistConfig

local function deepCopy(value)
    local valueType = type(value)
    if valueType ~= "table" then
        return value
    end
    local result = {}
    for k, v in pairs(value) do
        result[k] = deepCopy(v)
    end
    return result
end

local function serializeValue(value)
    local valueType = type(value)
    if valueType == "table" then
        local result = {}
        for k, v in pairs(value) do
            result[k] = serializeValue(v)
        end
        return result
    elseif valueType == "vector3" then
        return {x = value.x, y = value.y, z = value.z, __type = "vector3"}
    end
    return value
end

local function deserializeValue(value)
    if type(value) ~= "table" then
        return value
    end
    if value.__type == "vector3" then
        return vector3(value.x + 0.0, value.y + 0.0, value.z + 0.0)
    end
    local result = {}
    for k, v in pairs(value) do
        result[k] = deserializeValue(v)
    end
    return result
end

function Manager:GetHeists()
    if not self.heistConfig then
        self.heistConfig = deepCopy(Config.Heists or {})
    end
    return self.heistConfig
end

function Manager:GetHeist(heistId)
    local heists = self:GetHeists()
    return heists[heistId]
end

function Manager:SetHeist(heistId, data, skipSync)
    local heists = self:GetHeists()
    heists[heistId] = data
    if not skipSync then
        self:SyncHeists()
    end
end

function Manager:SetHeists(data, skipSync)
    self.heistConfig = data
    if not skipSync then
        self:SyncHeists()
    end
end

function Manager:SerializeHeists(sourceTable)
    return serializeValue(sourceTable or self:GetHeists())
end

function Manager:DeserializeHeists(payload)
    if not payload then return {} end
    return deserializeValue(payload)
end

function Manager:SyncHeists(target)
    local snapshot = self:SerializeHeists()
    if target then
        TriggerClientEvent("heist:syncConfig", target, snapshot)
    else
        TriggerClientEvent("heist:syncConfig", -1, snapshot)
    end
end
local QBCore, ESX = nil, nil

if Config.Framework == "qb" then
    local ok, obj = pcall(function()
        return exports["qb-core"]:GetCoreObject()
    end)
    if ok then
        QBCore = obj
    else
        print("[DynamicHeist] Unable to grab QBCore object, running in standalone mode.")
    end
elseif Config.Framework == "esx" then
    local ok, obj = pcall(function()
        return exports["es_extended"]:getSharedObject()
    end)
    if ok then
        ESX = obj
    else
        print("[DynamicHeist] Unable to grab ESX shared object, running in standalone mode.")
    end
end

local function debugLog(...)
    if Config.Debug then
        print("[DynamicHeist]", ...)
    end
end

local function fetchIdentifierByType(source, identifierType)
    if not source then return nil end
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local identifier = GetPlayerIdentifier(source, i)
        if identifier and identifier:find(identifierType) then
            return identifier
        end
    end
    return nil
end

local function getIdentifier(source)
    if not source then return "unknown" end
    local identifier = fetchIdentifierByType(source, "license")
    if identifier then return identifier end
    local fallback = GetPlayerIdentifier(source, 0)
    return fallback or ("player_" .. tostring(source))
end

local function getCurrentPoliceCount()
    local count = 0
    if QBCore then
        local players = QBCore.Functions.GetQBPlayers and QBCore.Functions.GetQBPlayers() or QBCore.Functions.GetPlayers()
        if type(players) == "table" then
            for _, player in pairs(players) do
                local pdata = player.PlayerData or player
                local job = pdata.job or {}
                if job.name == "police" and job.onduty ~= false then
                    count = count + 1
                end
            end
        end
    elseif ESX and ESX.GetExtendedPlayers then
        local players = ESX.GetExtendedPlayers("job", "police")
        if type(players) == "table" then
            count = #players
        end
    else
        -- Standalone fallback – count everyone with ace permission "heist.police"
        for _, playerId in ipairs(GetPlayers()) do
            if IsPlayerAceAllowed(playerId, "heist.police") then
                count = count + 1
            end
        end
    end
    return count
end

local function getTierUnlockedForPolice(count)
    local tier = 1
    for _, threshold in ipairs(Config.PoliceScaling.thresholds) do
        if count >= threshold.count then
            tier = threshold.tier
        end
    end
    return tier
end

local function getPlayerReputation(source)
    local identifier = getIdentifier(source)
    local data = Manager.playerData[identifier] or {reputation = 0}
    Manager.playerData[identifier] = data
    return data.reputation
end

local function modifyPlayerReputation(source, amount)
    local identifier = getIdentifier(source)
    local data = Manager.playerData[identifier] or {reputation = 0}
    data.reputation = math.max(0, data.reputation + amount)
    Manager.playerData[identifier] = data
    debugLog(("Player %s reputation now %s"):format(identifier, data.reputation))
    return data.reputation
end

local function tierRequirementMet(tier, reputation)
    local requirement = Config.Progression.tiers[tier]
    if not requirement then return true end
    return reputation >= (requirement.reputation or 0)
end

local function applyGlobalCooldownAdjustment(success, responseTime)
    local delta = success and Config.GlobalCooldown.deltaOnSuccess or Config.GlobalCooldown.deltaOnFail
    if responseTime then
        if responseTime >= Config.PoliceScaling.slowResponseThreshold then
            delta = delta - Config.PoliceScaling.cooldownDecrease
        elseif responseTime <= Config.PoliceScaling.fastResponseThreshold then
            delta = delta + Config.PoliceScaling.cooldownIncrease
        end
    end
    Config.GlobalCooldown.base = math.max(
        Config.GlobalCooldown.min,
        math.min(Config.GlobalCooldown.max, Config.GlobalCooldown.base + delta)
    )
end

local function mitigationFactor(metadata)
    if not metadata or not metadata.mitigation then return 1.0 end
    local factor = 1.0
    for item, _ in pairs(metadata.mitigation) do
        local reduction = Config.Evidence.mitigationItems[item]
        if reduction then
            factor = factor - reduction
        end
    end
    return math.max(0.2, factor)
end

local function generateEvidence(heistId, source, metadata)
    if not Config.Evidence then return end
    local factor = mitigationFactor(metadata)
    local drops = {}
    if math.random() < (Config.Evidence.dnaChance * factor) then
        table.insert(drops, "dna_sample")
    end
    if math.random() < (Config.Evidence.fingerprintChance * factor) then
        table.insert(drops, "latent_prints")
    end
    if math.random() < (Config.Evidence.hairChance * factor) then
        table.insert(drops, "hair_fiber")
    end
    if math.random() < (Config.Evidence.tamperLogChance * factor) then
        table.insert(drops, "tamper_log")
    end
    if #drops == 0 then return end
    TriggerEvent("heist:evidenceGenerated", heistId, source, drops)
    if DynamicHeist.Alerts and DynamicHeist.Alerts.RecordEvidence then
        DynamicHeist.Alerts.RecordEvidence(heistId, source, drops)
    end
end

local function getHeistCooldown(heistId)
    local entry = Manager.cooldowns[heistId]
    if not entry then return 0 end
    local remaining = entry.endsAt - os.time()
    return math.max(0, remaining)
end

local function setHeistCooldown(heistId, duration)
    Manager.cooldowns[heistId] = {endsAt = os.time() + duration}
end

local function rollLoot(heistConfig)
    local tier = heistConfig.rewards and heistConfig.rewards.tier or heistConfig.tier or 1
    local lootTier = Config.LootTiers[tier] or Config.LootTiers[1]
    local bundle = {
        cash = math.random(lootTier.cash.min, lootTier.cash.max),
        markedBills = math.random(lootTier.markedBills.min, lootTier.markedBills.max),
        valuables = lootTier.valuables,
        contraband = lootTier.contraband,
        cyber = lootTier.cyber,
        bonus = heistConfig.rewards and heistConfig.rewards.bonus or {}
    }
    return bundle
end

local function giveRewards(source, loot)
    if QBCore then
        local player = QBCore.Functions.GetPlayer(source)
        if player then
            player.Functions.AddMoney("cash", loot.cash, "dynamic-heist")
            if loot.markedBills and loot.markedBills > 0 then
                player.Functions.AddItem("markedbills", loot.markedBills)
            end
            local function giveItemList(list)
                if not list then return end
                for _, item in ipairs(list) do
                    player.Functions.AddItem(item, 1)
                end
            end
            giveItemList(loot.valuables)
            giveItemList(loot.contraband)
            giveItemList(loot.bonus)
            giveItemList(loot.cyber)
        end
    elseif ESX then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            xPlayer.addMoney(loot.cash)
            if loot.markedBills and loot.markedBills > 0 then
                xPlayer.addInventoryItem("markedbills", loot.markedBills)
            end
            local function giveItemList(list)
                if not list then return end
                for _, item in ipairs(list) do
                    xPlayer.addInventoryItem(item, 1)
                end
            end
            giveItemList(loot.valuables)
            giveItemList(loot.contraband)
            giveItemList(loot.bonus)
            giveItemList(loot.cyber)
        end
    else
        TriggerClientEvent("heist:receiveLoot", source, loot)
    end
end

local function broadcastPoliceAlert(heistId, heistConfig, stageLabel)
    if not DynamicHeist.Alerts or not DynamicHeist.Alerts.Send then
        print("[DynamicHeist] Police Alerts module missing, skipping dispatch data.")
        return
    end
    DynamicHeist.Alerts.Send({
        heistId = heistId,
        label = heistConfig.label,
        alarm = heistConfig.responses and heistConfig.responses.alarm or "generic",
        dispatchType = heistConfig.responses and heistConfig.responses.dispatch or "generic",
        coords = heistConfig.location,
        stage = stageLabel
    })
end

local function sendCooldownUpdate(source, heistId)
    local remaining = getHeistCooldown(heistId)
    TriggerClientEvent("heist:cooldownUpdate", source, heistId, remaining)
end

function Manager:CanStartHeist(source, heistId)
    if not heistId then
        return false, "Missing heist id"
    end
    local heistConfig = self:GetHeist(heistId)
    if not heistConfig then
        return false, "Unknown heist"
    end
    if self.states[heistId] and self.states[heistId].active then
        return false, "Heist already in progress"
    end
    if getHeistCooldown(heistId) > 0 then
        return false, "Heist cooling down"
    end
    local policeCount = getCurrentPoliceCount()
    if not heistConfig.gangResponse and policeCount < (heistConfig.requiredPolice or 0) then
        return false, ("Need %s police on duty."):format(heistConfig.requiredPolice or 0)
    end
    local tierUnlocked = getTierUnlockedForPolice(policeCount)
    if heistConfig.tier > tierUnlocked then
        return false, "Police presence too low for this heist"
    end
    local reputation = getPlayerReputation(source)
    if not tierRequirementMet(heistConfig.tier, reputation) then
        return false, "Reputation too low for this tier"
    end
    return true, heistConfig
end

function Manager:StartHeist(source, heistId)
    local allowed, dataOrReason = self:CanStartHeist(source, heistId)
    if not allowed then
        TriggerClientEvent("heist:notify", source, dataOrReason)
        sendCooldownUpdate(source, heistId)
        return false
    end
    local config = dataOrReason
    self.states[heistId] = {
        active = true,
        startedAt = os.time(),
        stage = 1,
        participants = {[source] = true},
        heistId = heistId,
        owner = source
    }
    local cooldownDuration = math.max(config.cooldown or 0, Config.GlobalCooldown.base)
    setHeistCooldown(heistId, cooldownDuration)
    broadcastPoliceAlert(heistId, config, config.stages[1].label)
    TriggerClientEvent("heist:begin", source, heistId, config)
    TriggerEvent("heist:onStart", heistId, source, config)
    debugLog(("Player %s started heist %s"):format(source, heistId))
    return true
end

function Manager:AdvanceStage(source, heistId, stageIndex, success, metadata)
    local state = self.states[heistId]
    if not state or not state.active then
        TriggerClientEvent("heist:notify", source, "Heist no longer active")
        return
    end
    local config = self:GetHeist(heistId)
    if not config then return end
    if stageIndex ~= state.stage then
        debugLog("Stage mismatch", stageIndex, state.stage)
        return
    end
    if not success then
        self:FailHeist(heistId, "Action failed", metadata)
        return
    end
    local nextStage = stageIndex + 1
    if nextStage > #config.stages then
        self:CompleteHeist(heistId, source, metadata)
        return
    end
    state.stage = nextStage
    broadcastPoliceAlert(heistId, config, config.stages[nextStage].label)
    TriggerClientEvent("heist:stage", source, heistId, nextStage, config.stages[nextStage])
end

function Manager:CompleteHeist(heistId, source, metadata)
    local state = self.states[heistId]
    if not state then return end
    local config = self:GetHeist(heistId)
    if not config then return end
    state.active = false
    local loot = rollLoot(config)
    giveRewards(source, loot)
    TriggerEvent("heist:lootGranted", source, heistId, loot)
    if loot.bonus and #loot.bonus > 0 then
        TriggerEvent("heist:unlockBlackmarket", source, loot.bonus)
    end
    TriggerClientEvent("heist:complete", source, heistId, loot, metadata)
    TriggerEvent("heist:onComplete", heistId, state.owner, loot, metadata)
    generateEvidence(heistId, source, metadata)
    modifyPlayerReputation(source, Config.Progression.reputationGain.success.base + (config.tier * Config.Progression.reputationGain.success.bonusPerTier))
    applyGlobalCooldownAdjustment(true)
    debugLog(("Heist %s completed by player %s"):format(heistId, source))
end

function Manager:FailHeist(heistId, reason, metadata)
    local state = self.states[heistId]
    if not state then return end
    state.active = false
    applyGlobalCooldownAdjustment(false)
    TriggerEvent("heist:onFail", heistId, reason, metadata)
    for src in pairs(state.participants) do
        TriggerClientEvent("heist:fail", src, heistId, reason)
        modifyPlayerReputation(src, Config.Progression.reputationGain.fail)
        generateEvidence(heistId, src, metadata)
    end
end

RegisterNetEvent("heist:requestStart", function(heistId)
    local src = source
    heistId = heistId or "fleeca"
    Manager:StartHeist(src, heistId)
end)

RegisterNetEvent("heist:stageComplete", function(heistId, stageIndex, success, metadata)
    local src = source
    Manager:AdvanceStage(src, heistId, stageIndex, success, metadata)
end)

RegisterNetEvent("heist:abort", function(heistId, reason)
    local src = source
    local state = Manager.states[heistId]
    if not state or not state.participants[src] then return end
    Manager:FailHeist(heistId, reason or "Player aborted")
end)

RegisterNetEvent("heist:requestConfig", function()
    local src = source
    Manager:SyncHeists(src)
end)

exports("GetHeistReputation", function(source)
    return getPlayerReputation(source)
end)

exports("GetActiveHeists", function()
    return Manager.states
end)

DynamicHeist.Manager = Manager
