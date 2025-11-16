local UI = {}

function UI.showStepToast(step)
    lib.notify({
        title = step.label or 'Heist Step',
        description = ('%s (%s)'):format(step.type, step.status or 'In progress'),
        type = step.status == 'complete' and 'success' or 'inform'
    })
end

function UI.showAdminContext(options)
    lib.registerContext({
        id = 'hb_admin_panel',
        title = 'Heist Builder',
        options = options
    })
    lib.showContext('hb_admin_panel')
end

function UI.inputDialog(title, fields)
    return lib.inputDialog(title, fields)
end

CS_HEIST_CLIENT_UI = UI

return UI
