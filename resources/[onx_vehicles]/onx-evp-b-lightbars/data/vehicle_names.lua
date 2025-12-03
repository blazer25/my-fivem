function AddTextEntry(key, value)
Citizen.InvokeNative(GetHashKey("ADD_TEXT_ENTRY"), key, value)
end

Citizen.CreateThread(function()
--AddTextEntry('','')
--Lightbars
AddTextEntry('ONX_LBARMDN1A','Large Wisen Alliance')
AddTextEntry('ONX_LBARMDN1B','Medium Wisen Alliance')
AddTextEntry('ONX_LBARMDN1C','Small Wisen Alliance')
AddTextEntry('ONX_LBARMDN2A','Tidron Urgentrix')
AddTextEntry('ONX_LBARMDN3A','Large Tidron Junk-Bolt')
AddTextEntry('ONX_LBARMDN3B','Small Tidron Junk-Bolt')
AddTextEntry('ONX_LBAROS1A','Old School Tidron Optic')
AddTextEntry('ONX_LBAROS2A','Old School Tidron Aerodashi')
AddTextEntry('ONX_LBAROS2B','Old School Tidron Aerodashi w/ TA')
AddTextEntry('ONX_LBAROS3A','Old School Tidron RoadFalcon')
end)