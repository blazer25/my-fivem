fx_version 'adamant'
game 'gta5'
author 'savana.tebex.io | lifeless0'
lua54 'yes'


escrow_ignore {
    'cfg/*.lua',
    'main/*.lua',
    'locales/*.lua',
    'utils/*.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
    'cfg/locale.lua',
    'locales/*.lua',
    'cfg/cfg.lua',
    'cfg/jobs.lua'
}

client_scripts {
    'utils/client.lua',
    'main/target.lua',
    'main/client.lua',
}

server_scripts {
    'utils/server.lua',
    'main/server.lua',
    '@oxmysql/lib/MySQL.lua',
    'version.lua'
}

ui_page 'html/index.html'

files {
    'html/css/*.*',
    'html/assets/*.*',
    'html/font/*.*',
    'html/*.*',    
}

dependencies {
    'oxmysql',
    'ox_lib'       
}

dependency '/assetpacks'