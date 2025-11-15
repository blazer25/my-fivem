local Utils = CS_HEIST_SHARED_UTILS or {}
local ClientUtils = CS_HEIST_CLIENT_UTILS or {}
local UI = CS_HEIST_CLIENT_UI or {}

local draft = nil
local previewThread = nil

local function ensurePerms()
    return lib.callback.await('cs_heistbuilder:server:hasBuilderPerms', false)
end

local function startPreview()
    if previewThread then return end
    previewThread = CreateThread(function()
        while draft do
            if draft.entryPoint then
                ClientUtils.marker(1, Utils.toVector(draft.entryPoint), { r = 0, g = 255, b = 120, a = 120 }, 1.0)
            end
            if draft.steps then
                for _, step in ipairs(draft.steps) do
                    if step.coords then
                        ClientUtils.marker(25, Utils.toVector(step.coords), { r = 255, g = 255, b = 0, a = 80 }, step.radius or 0.8)
                    end
                end
            end
            if draft.guards then
                for _, guard in ipairs(draft.guards) do
                    ClientUtils.marker(1, Utils.toVector(guard.coords), { r = 255, g = 0, b = 0, a = 120 }, 0.7)
                end
            end
            Wait(0)
        end
        previewThread = nil
    end)
end

local function stopPreview()
    draft = nil
end

local function ensureDraft(id)
    if not draft then
        draft = {
            id = id,
            label = id,
            tier = 1,
            requiredPolice = 2,
            cooldownMinutes = 30,
            minPlayers = 1,
            maxPlayers = 4,
            entryPoint = nil,
            escapeRadius = 50.0,
            steps = {},
            guards = {},
            rewards = {},
            evidence = {}
        }
        startPreview()
    end
    if id then draft.id = id end
    return draft
end

local function captureCoords(message)
    lib.notify({ description = message or 'Look towards target and press ENTER', type = 'inform' })
    local coords = GetEntityCoords(cache.ped)
    local heading = GetEntityHeading(cache.ped)
    return { x = coords.x, y = coords.y, z = coords.z, w = heading }
end

local function captureLookCoords()
    local coords = ClientUtils.getLookCoords(10.0)
    local heading = GetEntityHeading(cache.ped)
    return { x = coords.x, y = coords.y, z = coords.z, w = heading }
end

local function addStep(stepType)
    if not CS_HEIST_STEP_TYPES[stepType] then
        ClientUtils.notify({ description = ('Unknown step type: %s'):format(stepType), type = 'error' })
        return
    end
    local inputs = UI.inputDialog('Add Step: ' .. stepType, {
        { type = 'input', label = 'Label', default = CS_HEIST_STEP_TYPES[stepType].label or stepType },
        { type = 'number', label = 'Duration (seconds)', default = 10 }
    })
    if not inputs then return end
    local label, duration = inputs[1], tonumber(inputs[2]) or 10
    local coords = captureLookCoords()
    draft.steps[#draft.steps + 1] = {
        type = stepType,
        label = label,
        duration = duration,
        coords = coords
    }
    ClientUtils.notify({ description = ('Step %s added'):format(stepType), type = 'success' })
end

local function addGuard(weapon)
    weapon = weapon or 'WEAPON_CARBINERIFLE'
    local coords = captureLookCoords()
    draft.guards[#draft.guards + 1] = {
        weapon = weapon,
        coords = coords,
        model = 's_m_m_highsec_01'
    }
    ClientUtils.notify({ description = 'Guard spawn added', type = 'success' })
end

local function addLoot(typeLabel)
    local inputs = UI.inputDialog('Add Loot', {
        { type = 'input', label = 'Item/Cash Type', default = typeLabel or 'cash' },
        { type = 'number', label = 'Amount', default = 1000 }
    })
    if not inputs then return end
    draft.rewards[#draft.rewards + 1] = {
        type = inputs[1],
        amount = tonumber(inputs[2]) or 1000
    }
    ClientUtils.notify({ description = 'Loot definition added', type = 'success' })
end

local function saveDraft()
    TriggerServerEvent('cs_heistbuilder:server:saveHeist', draft)
end

local function testDraft()
    TriggerServerEvent('cs_heistbuilder:server:testHeist', draft.id)
end

RegisterNetEvent('cs_heistbuilder:client:saveResult', function(success, message)
    ClientUtils.notify({ description = message or (success and 'Saved' or 'Failed'), type = success and 'success' or 'error' })
end)

RegisterCommand('hb', function(_, args)
    if not ensurePerms() then
        ClientUtils.notify({ description = 'You do not have permission to use Heist Builder', type = 'error' })
        return
    end

    local action = args[1] and args[1]:lower() or 'help'
    if action == 'create' then
        local id = args[2] or ('hb_' .. Utils.randomId(4):lower())
        ensureDraft(id)
        ClientUtils.notify({ description = ('Draft %s created'):format(id), type = 'success' })
    elseif action == 'setlabel' and draft then
        draft.label = table.concat(args, ' ', 2)
        ClientUtils.notify({ description = 'Label updated', type = 'success' })
    elseif action == 'setentry' and draft then
        draft.entryPoint = captureCoords('Entry position stamped')
        ClientUtils.notify({ description = 'Entry point set', type = 'success' })
    elseif action == 'addstep' and draft then
        addStep(args[2] or 'hack_panel')
    elseif action == 'addguard' and draft then
        addGuard(args[2])
    elseif action == 'addloot' and draft then
        addLoot(args[2])
    elseif action == 'save' and draft then
        saveDraft()
    elseif action == 'test' and draft then
        testDraft()
    elseif action == 'help' then
        UI.showAdminContext({
            { title = '/hb create <id>', description = 'Start new draft' },
            { title = '/hb setlabel <name>', description = 'Rename draft' },
            { title = '/hb setentry', description = 'Use current coords for entry' },
            { title = '/hb addstep <type>', description = 'Add heist step at look coords' },
            { title = '/hb addguard <weapon>', description = 'Add guard spawn' },
            { title = '/hb addloot <type>', description = 'Add payout entry' },
            { title = '/hb save', description = 'Persist heist to storage' },
            { title = '/hb test', description = 'Quickly start heist' }
        })
    else
        ClientUtils.notify({ description = 'Set up a draft first with /hb create <id>', type = 'inform' })
    end
end)

return true
