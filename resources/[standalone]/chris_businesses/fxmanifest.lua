fx_version 'cerulean'
game 'gta5'

author 'Chris Stone'
description 'Dynamic Player-Owned Business System for Qbox'
version '1.0.0'

shared_script '@ox_lib/init.lua'
shared_scripts {
    'shared.lua',
    'config.lua'
}

client_script 'client.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

ui_page 'web/dist/index.html'

files {
    'web/dist/index.html',
    'web/dist/**/*'
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'

