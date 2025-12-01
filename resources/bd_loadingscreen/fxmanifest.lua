fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Chris (Customized)'
description 'Custom Loading Screen for Chris FiveM Server'
version '1.0.0'

loadscreen 'index.html'
loadscreen_manual_shutdown 'yes'
loadscreen_cursor 'yes'

client_script 'client.lua'
server_script 'server.lua'

files {
    'index.html',
    'css/style.css',
    'script/main.js',
    'logo/logo.png',
    'song/*',
    'img/*',
    'video/*'
}
