fx_version 'cerulean'
game 'gta5'
author 'ONX'
description 'WiseGuy Emergency Vehicles Pack Lightbars'
version '1.3.0'
lua54 'yes'

data_file 'HANDLING_FILE' 'data/handling.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/vehicles.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/carvariations.meta'

files {
  'data/*.meta'
}

shared_scripts {
  'shared/config.lua', --unencrypted
  'shared/utils.lua',
}

client_scripts {
  'data/vehicle_names.lua',
  'client/utils.lua',
  'client/public.lua', --unencrypted
  'client/client.lua',
}

server_scripts {
  'server/server.lua',
  'server/public.lua', --unencrypted
  'version.lua',
}

escrow_ignore {
  'shared/config.lua',
  'client/public.lua',
  'server/public.lua',
  'data/*.meta',
  'stream/*.ytd',
  'data/*.lua',
}
dependency '/assetpacks'