fx_version 'cerulean'
game 'gta5'

description 'JPR - Libs'
version '1.0.0'

client_scripts {
    'client/*.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/styles/*.css',
    'html/script.js'
}

escrow_ignore {
    'client/*.lua'
}

lua54 'yes'

dependency '/assetpacks'