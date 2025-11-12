BOUTIQUE = BOUTIQUE or {}
BOUTIQUE.Config = BOUTIQUE.Config or {}

BOUTIQUE.Config = {
    title = "Spawn",
    subtitle = "Selector",
    serverLogo = "https://cdn.discordapp.com/attachments/885459782100738071/1370799137959968828/logopng.png?ex=6820cfae&is=681f7e2e&hm=88640bcb7316cbbd613a002ebbbf7141b433e036aff609d94dac3fbb0127d009&",
    color = '#FF5B5B',
    fallbackSpawnIndex = 2,
    spawns = {
        {
            name = "Last Location",
            adress = "Where you logged out",
            smalldescription = "Resume from your previous spot",
            description = "Spawn exactly where you left off the last time you were in the city.",
            image = "https://images.hdqwalls.com/wallpapers/gta-v-city-lights-4k-r0.jpg",
            top = 10,
            left = 50,
            useLastLocation = true,
        },
        {
            name = "Airport",
            adress = "Los Santos International Airport",
            smalldescription = "Arrivals terminal at LSIA",
            description = "Touch down at Los Santos International Airport and start your journey in the city with easy access to transport.",
            image = "https://img.gta5-mods.com/q85-w800/images/airport-police-station/777759-LSIA-GTAV-exterior1.jpg",
            top = 69,
            left = 86,
            position = vector4(-1038.0, -2738.0, 20.0, 330.0),
        },
        {
            name = "Paleto Bay",
            adress = "Paleto Bay Motel",
            smalldescription = "Paleto Bay motel reception",
            description = "Wake up to ocean views in Paleto Bay and enjoy a quieter start to your day on the north coast.",
            image = "https://img.gta5-mods.com/q75/images/paleto-bay-station-bus/a140e5-GTA5%202015-11-03%2016-14-17-52.jpg",
            top = 55,
            left = 18,
            position = vector4(-106.0, 6314.0, 31.0, 136.0),
        },
        {
            name = "Sandy Shores",
            adress = "Sandy Shores trailer",
            smalldescription = "Trailer home in Sandy Shores",
            description = "Start out in the heart of the desert with quick access to Blaine County jobs and activities.",
            image = "https://img.gta5-mods.com/q75/images/sandy-shores-enhancement/912986-GTA5%202015-11-22%2017-16-49-49.jpg",
            top = 30,
            left = 37,
            position = vector4(1784.0, 3646.0, 34.0, 300.0),
        }
    },
    translate = {
        selectSpawn = 'Spawn Here'
    }
}