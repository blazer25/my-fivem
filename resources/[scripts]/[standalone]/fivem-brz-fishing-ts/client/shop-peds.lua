-- Shop PEDs
-- Spawns PEDs at illegal fish seller location only (equipment shop removed)

local shopPeds = {}

-- Illegal Fish Seller PED
local illegalFishPed = {
    model = `s_m_y_dealer_01`, -- Dealer model for shady character
    coords = vector4(1550.83, 6318.95, 24.06, 354.0),
}

-- Function to spawn a PED
local function spawnPed(pedData)
    lib.requestModel(pedData.model, 5000)
    
    local ped = CreatePed(4, pedData.model, pedData.coords.x, pedData.coords.y, pedData.coords.z - 1.0, pedData.coords.w, false, true)
    
    SetEntityAsMissionEntity(ped, true, true)
    SetPedFleeAttributes(ped, 0, false)
    SetPedCombatAttributes(ped, 46, true)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    
    -- Set scenario for idle animation
    TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_STAND_IMPATIENT', 0, true)
    
    table.insert(shopPeds, ped)
    
    return ped
end

-- Spawn shop PEDs
CreateThread(function()
    -- Wait for game to load
    Wait(1000)
    
    -- Spawn illegal fish seller PED
    spawnPed(illegalFishPed)
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for _, ped in ipairs(shopPeds) do
            if DoesEntityExist(ped) then
                DeleteEntity(ped)
            end
        end
        shopPeds = {}
    end
end)

