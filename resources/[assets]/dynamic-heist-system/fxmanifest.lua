-- fxmanifest.lua
fx_version 'cerulean'
game 'gta5'

name 'Dynamic Heist System'
description 'A dynamic heist system for FiveM servers'
author 'Future Engineer'
version '1.1.0'

client_scripts {
    'client/main.lua',
    'client/ui.lua',
    'client/animations.lua'
}

server_scripts {
    'server/main.lua',
    'server/heist_logic.lua',
    'server/police_alerts.lua'
}

shared_script 'config/config.lua'

files {
    'assets/hacking_ui/*',
    'assets/drill_animation/*'
}
