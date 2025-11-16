fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'cs'
description 'Unified heist & robbery system (stores, banks, jewellery)'
version '0.1.0'

dependencies {
    'ox_lib',
    'ox_inventory',
    'qbx_core'
    -- optional: 'ox_target', 'qb-target'
}

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

