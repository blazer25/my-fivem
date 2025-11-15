-- fxmanifest.lua
fx_version 'cerulean'
game 'gta5'

name 'Dynamic Heist System'
description 'A dynamic heist system for FiveM servers'
author 'Future Engineer'
version '1.1.0'

client_scripts {
    'client/ui.lua',
    'client/animations.lua',
    'client/main.lua'
}

server_scripts {
    'server/heist_logic.lua',
    'server/police_alerts.lua',
    'server/main.lua',
    'server/admin.lua'
}

shared_script 'config/config.lua'

files {
    'assets/hacking_ui/*',
    'assets/drill_animation/*'
}
