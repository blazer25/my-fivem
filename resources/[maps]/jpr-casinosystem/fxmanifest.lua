fx_version 'cerulean'
game 'gta5'

shared_script '@ox_lib/init.lua'

shared_scripts {
    'configs/general/main_config.lua',
    'configs/general/*.lua',
    "configs/slots/*.lua",
    "configs/luckywheel/*.lua",
    "configs/insideTrack/*.lua",
    "configs/blackjack/*.lua",
    "configs/roulette/*.lua",
    "configs/poker/*.lua",
}

client_scripts {
    "mainSystem/slots/client/*.lua",
    "mainSystem/luckywheel/client/*.lua",
    "mainSystem/insideTrack/client/*.lua",
    "mainSystem/blackjack/client/*.lua",
    "mainSystem/roulette/client/*.lua",
    "mainSystem/poker/client/*.lua",
    "mainSystem/misc/client/*.lua",
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    "mainSystem/slots/server/*.lua",
    "mainSystem/luckywheel/server/*.lua",
    "mainSystem/insideTrack/server/*.lua",
    "mainSystem/blackjack/server/*.lua",
    "mainSystem/roulette/server/*.lua",
    "mainSystem/poker/server/*.lua",
    "mainSystem/misc/server/*.lua",
}

escrow_ignore {
    'configs/general/main_config.lua',
    'configs/general/*.lua',
    "configs/slots/*.lua",
    "configs/luckywheel/*.lua",
    "configs/insideTrack/*.lua",
    "configs/blackjack/*.lua",
    "configs/roulette/*.lua",
    "configs/poker/*.lua",
}

lua54 'yes'
--use_experimental_fxv2_oal 'yes'

dependencies {
    'ox_lib',
    'oxmysql',
    'qbx_core',
}

dependency '/assetpacks'