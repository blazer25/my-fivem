fx_version 'cerulean'
game 'gta5'

author 'Tow Guardian'
description 'Tow Guardian Vehicle Pack'
version '1.0.0'

files {
    'Metas/vehicles.meta',
    'Metas/carvariations.meta',
    'Metas/carcols.meta',
    'Metas/handling.meta',
    'Metas/vehicle_names.lua'
}

data_file 'HANDLING_FILE' 'Metas/handling.meta'
data_file 'VEHICLE_METADATA_FILE' 'Metas/vehicles.meta'
data_file 'CARCOLS_FILE' 'Metas/carcols.meta'
data_file 'VEHICLE_VARIATION_FILE' 'Metas/carvariations.meta'

client_script 'Metas/vehicle_names.lua'

-- Vehicle files are in Vehicle Files/ folder - they can be moved to stream/ if needed
