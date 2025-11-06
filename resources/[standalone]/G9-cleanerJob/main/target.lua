RequestModel(GetHashKey(cfg.company.ped))
while not HasModelLoaded(GetHashKey(cfg.company.ped)) do
    Wait(0)
end
local ped = CreatePed(4, GetHashKey(cfg.company.ped), cfg.company.location.x, cfg.company.location.y, cfg.company.location.z - 1, cfg.company.location.w, false, false)
SetEntityHeading(ped, cfg.company.location.w)
FreezeEntityPosition(ped, true)
SetEntityInvincible(ped, true)
SetBlockingOfNonTemporaryEvents(ped, true)
SetPedDiesWhenInjured(ped, false)
SetPedCanRagdoll(ped, false)

if cfg.useTarget then        
        if GetResourceState('ox_target') == 'started' then
            local options = {
                {
                    label = 'Cleaner Boss',
                    icon = "fas fa-briefcase",
                    onSelect = function()
                        open()
                    end,
                }
            }
            exports.ox_target:addSphereZone({
                coords = GetEntityCoords(ped),
                radius = 0.35,
                options = options,
                debug = false,
            })
        else
            exports['qb-target']:AddTargetEntity(ped, {
                options = {
                    {
                        label = 'Cleaner Boss',
                        icon = "fas fa-briefcase",
                        action = function()
                            open()
                        end,
                    }
                },
                distance = 2.0
            })
        end
    else
        local coord = vector3(cfg.company.location.x, cfg.company.location.y, cfg.company.location.z)
        lib.zones.sphere({
            coords = coord,
            radius = 2,
            onEnter = function()
                lib.showTextUI('[E] Cleaner Boss')
            end,
            onExit = function()
                lib.hideTextUI()
            end,
            inside = function()
                if IsControlJustPressed(0, 38) then
                        lib.hideTextUI()                        
                        open()
                        lib.showTextUI('[E] Cleaner Boss')
                end
            end,
        })
end