CONFIG = {
    disablePoliceScannerAudio = false, -- controls if the police scanner audio should play when in an emergency vehicle
    disableGhostSirens = true, -- disables distant "ghost" sirens
    enableSirenCollision = true, -- disable if you're having collision issues with the siren
    checkIntervalSpeed = 250, -- how often in ms to check if a lightbar should ne attached / detached (lower number more responsive worse performance)
    debug = false, -- display debug prints
}

SIREN_SOUNDS_CONFIG = {
    horn = 'SIRENS_AIRHORN',
    primary = 'RESIDENT_VEHICLES_SIREN_WAIL_02',
    secondary = 'RESIDENT_VEHICLES_SIREN_QUICK_02',
    warning = 'VEHICLES_HORNS_POLICE_WARNING'
}
