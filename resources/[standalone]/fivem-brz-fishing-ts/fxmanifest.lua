fx_version 'cerulean'
name 'brz-fishing'
author 'brz.gg'
lua54 'yes'
game 'gta5'

shared_scripts {
    'settings.js',
    '@ox_lib/init.lua',
}

ox_libs {
    'interface',
}

server_script 'dist/server/**/*.js'
server_script 'server/fish-config.lua'
server_script 'server/fishmarket.lua'
server_script 'server/fishing-rarity.lua'
server_script 'server/area-detection.lua'
server_script 'server/area-leveling.lua'
server_script 'server/equipment-validation.lua'

client_script 'dist/client/**/*.js'
client_script 'client/fishmarket.lua'
client_script 'client/fishingspots.lua'
client_script 'client/levels-ui.lua'
client_script 'client/shop-peds.lua'

ui_page 'nui/fishing.html'

files {
    'settings.js',
    'nui/*.html',
    'nui/dist/fishing.js',
    'nui/dist/dom/renderer.js'
}