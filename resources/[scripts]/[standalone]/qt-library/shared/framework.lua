AddEventHandler('onServerResourceStart', function(resourceName)
	if resourceName == Shared.FrameworkNames.esx or resourceName == GetCurrentResourceName then
        ESX = exports[Shared.FrameworkNames.esx]:getSharedObject()
    elseif resourceName == Shared.FrameworkNames.qb or resourceName == GetCurrentResourceName then
        QBCore = exports[Shared.FrameworkNames.qb]:GetCoreObject()
	end
end)