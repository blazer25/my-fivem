fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'Heist Builder Premium Framework'
description 'Modular in-city heist builder for Qbox'
version '1.0.0'

shared_script '@ox_lib/init.lua'

shared_scripts {
    'shared/shared_utils.lua',
    'shared/heist_types.lua',
    'shared/config_heists.lua'
}

client_scripts {
    'client/utils.lua',
    'client/ui.lua',
    'client/police.lua',
    'client/editor.lua',
    'client/robbery.lua',
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/utils.lua',
    'server/reputation.lua',
    'server/police.lua',
    'server/editor.lua',
    'server/robbery.lua',
    'server/main.lua'
}

dependencies {
    'ox_lib',
    'ox_target',
    'ox_inventory',
    'qbx_core'
}
