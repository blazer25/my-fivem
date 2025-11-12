--[[
    Chris Locks System
    Author: Chris Hepburn
    Description: Advanced player and business lock system for FiveM (Qbox / QB / OX compatible)
    Version: 1.0.0
]]

fx_version 'cerulean'
game 'gta5'

lua54 'yes'

name 'chris_locks'
author 'Chris Hepburn'
description 'Advanced lock system with password, item, and job support'
version '1.0.0'

shared_script '@ox_lib/init.lua'

shared_scripts {
    'config.lua',
    'locales/en.lua',
    'shared/utils.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

ui_page 'ui/dist/index.html'

files {
    'ui/dist/index.html',
    'ui/dist/assets/*.js',
    'ui/dist/assets/*.css'
}
