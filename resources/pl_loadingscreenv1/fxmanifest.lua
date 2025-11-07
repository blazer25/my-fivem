fx_version 'cerulean'
game 'gta5'

author 'Pulse Scripts'
description 'Loading Screen V1'
version '1.0.1'

lua54 'yes'

loadscreen 'web/index.html'

shared_script 'config.lua'
server_script 'server.lua'

files {
    'web/index.html',
    'web/style.css',
    'web/script.js',
    'web/config.js',
    'web/assets/avatars/*.jfif',
    'web/assets/logo/*.png',
    'web/assets/video/background.mp4',
    'assets/video/background.webm',
    'web/assets/background.jpg',
    'web/assets/music/*.mp3',
}

loadscreen_manual_shutdown 'yes'

loadscreen_cursor 'yes'

escrow_ignore {
    'web/config.js',
    'web/assets/avatars/*.jfif',
    'web/assets/logo/*.png',
     'web/assets/music/*.mp3',
    'web/assets/video/*.mp4',
    'web/assets/background.jpg',
    'config.lua',
    'server.lua'
}



dependency '/assetpacks'