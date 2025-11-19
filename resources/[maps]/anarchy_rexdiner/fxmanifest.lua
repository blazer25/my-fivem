fx_version 'cerulean'
games { 'gta5' }

author 'anxy'
description 'AS MLO Rex Diner & Al\'s Garage'
version '2.0'
lua54 'yes'
this_is_a_map 'yes'

file "audio/as_rex_diner_game.dat151.rel"
file "audio/as_rex_garage_game.dat151.rel"

data_file "AUDIO_GAMEDATA" "audio/as_rex_diner_game.dat"
data_file "AUDIO_GAMEDATA" "audio/as_rex_garage_game.dat"

escrow_ignore {
    'stream/**/*.ytd',
    'stream/**/*.ymap',
    'stream/**/*.ytyp'
}