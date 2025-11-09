return {
    ---@type boolean
    debug = true,

    ---@type string
    licenseScript = "qbx_idcard",
    -- "bcs_licensemanager" / "qb-license" / "esx_license" / "qbx_idcard" / "qbx_license" / "cs_license" / "ak47_qb_idcardv2"

    ---@type string
    accountType = "bank",                    -- "bank" or "money" or "cash". Default accountType
    accountTypeOptions = { "bank", "cash" }, -- Available account types

    ---@type boolean
    examProveAsLicense = false, -- If true, the exam will be given as a license

    ---@type string
    locale = 'en',

    ---@type string[]
    vehicles = {
        'enduro',
        'defiler',
        'blista',
        'aleutian',
        'phantom',
        'dinghy',
        'squalo',
        'seasparrow',
        'supervolito',
        'mammatus',
        'duster'
    },

    ---@type string[]
    licenses = {
        'driver_bike',
        'driver_car',
        'driver_truck',
        'driver_boat',
        'driver_helicopter',
        'driver_plane'
    },

    ---@type string[]
    theoryLicenses = {
        'theory_driver_bike',
        'theory_driver_car',
        'theory_driver_truck',
        'theory_driver_boat',
        'theory_driver_helicopter',
        'theory_driver_plane'
    },
}
