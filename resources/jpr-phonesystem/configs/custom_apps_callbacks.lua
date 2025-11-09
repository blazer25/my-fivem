if Config.InvoicesScript == "okokBilling" then
    RegisterNUICallback('openOKOKBilling', function(data, cb)
        TriggerEvent("okokBilling:ToggleMyInvoices")
    end)
end