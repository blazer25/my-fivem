fx_version 'cerulean'
game 'gta5' 
lua54 'yes'
description 'unique library with our functions, automatically detect framework.'
author 'quantum development 2024'

shared_scripts {
    'shared.lua',
    'shared/framework.lua'
}

server_scripts {
    'server/*.lua',
    'sv_utils.lua'
}

client_scripts {
    'client/*.lua',
    'cl_utils.lua'
}

ui_page "web/index.html"

files {
    "web/*.*"
}

