

fx_version 'cerulean'
game 'gta5'

author 'amazonium.' -- aka Sinatra
description '919DESIGN Admin Panel'
version '1.12'
lua54 'yes'

ui_page 'html/index.html'

files {
	'html/**',
    'json/reports.json',
    'json/adminchat.json',
    'json/logs.json',
}

shared_scripts {
    'locales/locale.lua',
    'locales/en.lua', -- Can change to other languages available in locales folder
    'config.lua',
    'bridge/qbcore.lua',
    'bridge/esx18.lua',
    'bridge/qbox.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config_server.lua',
    'server/main.lua',
    'server/adminactions.lua',
    'server/discord_bot_locked.lua',
    'server/discord_bot.lua',
}

client_scripts {
    'client/main.lua',
    'client/functions.lua',
    'client/clientactions.lua',
    'client/nuicallbacks.lua',
    'client/freecam/utils.lua',
    'client/freecam/config.lua',
    'client/freecam/camera.lua',
    'client/freecam/main.lua',
    'client/noclip.lua',
    'client/devmode.lua',
}

escrow_ignore {
    -- Main Files
    'config.lua',
    'config_server.lua',
    'server/main.lua',
    'server/adminactions.lua',
    'server/discord_bot.lua',

    -- Compatibility Stuff
    'bridge/qbcore.lua',
    'bridge/esx18.lua',
    'bridge/qbox.lua',

    -- NoClip Stuff
    'client/freecam/utils.lua',
    'client/freecam/config.lua',
    'client/freecam/camera.lua',
    'client/freecam/main.lua',
    'client/noclip.lua',

    -- Locale Stuff
    'locales/locale.lua',
    'locales/en.lua',
    'locales/de.lua',
    'locales/nl.lua',
}

dependencies { 'oxmysql' }
dependency '/assetpacks'