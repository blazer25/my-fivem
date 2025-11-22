fx_version 'cerulean'
game 'gta5'

name 'Clothing/EUP Loader'
author 'Auto-Generated Clothing System'
description 'Complete FiveM Clothing/EUP Loader with auto-detection and merging'
version '1.0.0'

-- Clothing metadata files
data_file 'SHOP_PED_APPAREL_META_FILE' 'data/shop_ped_apparel.meta'
data_file 'PED_PERSONALITY_FILE' 'data/pedpersonality.meta'
data_file 'COMPONENT_SETS_FILE' 'data/componentsets.meta'
data_file 'PED_ACCESSORY_FILE' 'data/pedaccessories.meta'

-- Auto-include all meta files in data folder
files {
    'data/*.meta'
}

-- Stream all clothing models
-- YTD = Textures, YDD = Drawables, YFT = Fragments, YTF = Texture Fragments
this_is_a_map 'yes'

-- Dependency on appearance system
dependencies {
    'illenium-appearance'
}

-- Client script for debugging and validation
client_script 'client.lua'

-- Server script for build management
server_script 'server.lua'

-- Lua 5.4 support
lua54 'yes'

-- Escrow ignore for development
escrow_ignore {
    'data/*.meta',
    'scripts/*',
    'client.lua',
    'server.lua'
}
