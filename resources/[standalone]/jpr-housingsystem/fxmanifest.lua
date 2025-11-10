fx_version 'adamant'

game 'gta5'
version '3.4'

ui_page 'html/index.html'

shared_scripts {
    'configs/main_config.lua',
    'configs/get_framework_config.lua'
}

client_scripts {
    'configs/main_config.lua',
    'configs/mlo_doors_config.lua',
    'configs/furniture_config.lua',
    'configs/default_gta_entities.lua',
    'configs/client_config.lua',
    'mainSystem/client/client.lua',
    'mloSystem/integration/mlo_system.lua',
    'mloSystem/client/mlo_system_client.lua',
    'shellSystem/loader.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'configs/main_config.lua',
    'configs/mlo_doors_config.lua',
    'configs/furniture_config.lua',
    'configs/server_config.lua',
    'mainSystem/server/server.lua',
    'mloSystem/server/mlo_system_server.lua',
}

files {
    'html/*.html',
    'html/css/*.css',
    'html/css/fonts/*.otf',
    'html/js/*.js',
    'html/img/*.png',
    'html/img/previews/*.png',
}

exports {
    'isInHouse',
    'PlayerHaveAnyHouse',
    'AddKeyHolder',
    'GiveStarterApartment',
}

lua54 'yes'

escrow_ignore {
	'configs/main_config.lua',
    'configs/mlo_doors_config.lua',
    'configs/furniture_config.lua',
    'configs/client_config.lua',
    'configs/server_config.lua',
    'configs/get_framework_config.lua',
    'configs/default_gta_entities.lua',
}
dependency '/assetpacks'