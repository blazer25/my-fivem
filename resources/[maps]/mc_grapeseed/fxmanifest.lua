lua54 'yes'
fx_version 'cerulean'

game 'gta5'
this_is_a_map 'yes'

author 'Apollo Developments'
description 'M.C Grapeseed'
version '1.0.0'

files {
    'audio/apollo_mc_grapeseed/8A5E2BDD_game.dat151.rel',
    'audio/apollo_mcg_grapeseed/5D527EB_game.dat151.rel',
    'audio/apollo_grapeseeddoors/grapeseeddoor_game.dat151.rel',
}

data_file 'AUDIO_GAMEDATA' 'audio/apollo_mc_grapeseed/8A5E2BDD_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/apollo_mcg_grapeseed/5D527EB_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/apollo_grapeseeddoors/grapeseeddoor_game.dat'



client_scripts { 
    'client.lua',
    'apollo_grapeseed_entityset_mods.lua',
}


escrow_ignore {
    'stream/unlocked/*.ydr',
    'stream/unlocked/*.ydd',
    'stream/unlocked_logos/*.ydr',
    'stream/ytd/*.ytd',
    'client.lua',
    'apollo_grapeseed_entityset_mods.lua',
}
    
dependency '/assetpacks'