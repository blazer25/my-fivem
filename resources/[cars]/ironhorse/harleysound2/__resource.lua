resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"

files {
	'audioconfig/harleysound_game.dat151.rel',
	'audioconfig/harleysound_sounds.dat54.rel',
	'sfx/dlc_harleysound/harleysound.awc',
	'sfx/dlc_harleysound/harleysound_npc.awc'
}

data_file 'AUDIO_GAMEDATA' 'audioconfig/harleysound_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audioconfig/harleysound_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'sfx/dlc_harleysound'

client_script {
    'vehicle_names.lua'
}

