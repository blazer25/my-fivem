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

-- TypeScript compiled files (optional - uncomment if built)
-- server_script 'dist/server/**/*.js'
server_script 'server/fish-config.lua'
server_script 'server/fishmarket.lua'
server_script 'server/fishing-rarity.lua'
server_script 'server/area-detection.lua'
server_script 'server/area-leveling.lua'

-- TypeScript compiled files (optional - uncomment if built)
-- client_script 'dist/client/**/*.js'
client_script 'client/fishing-rod.lua'
client_script 'client/fishmarket.lua'
client_script 'client/fishingspots.lua'
client_script 'client/levels-ui.lua'
client_script 'client/shop-peds.lua'

ui_page 'nui/fishing.html'

files {
    'settings.js',
    'nui/*.html',
    -- TypeScript compiled files (optional - uncomment if built)
    -- 'nui/dist/fishing.js',
    -- 'nui/dist/dom/renderer.js'
}