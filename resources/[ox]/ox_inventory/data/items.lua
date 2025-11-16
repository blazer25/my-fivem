return {
    ['testburger'] = {
        label = 'Test Burger',
        weight = 220,
        degrade = 60,
        client = {
            image = 'burger_chicken.png',
            status = { hunger = 200000 },
            anim = 'eating',
            prop = 'burger',
            usetime = 2500,
            export = 'ox_inventory_examples.testburger'
        },
        server = {
            export = 'ox_inventory_examples.testburger',
            test = 'what an amazingly delicious burger, amirite?'
        },
        buttons = {
            {
                label = 'Lick it',
                action = function(slot)
                    print('You licked the burger')
                end
            },
            {
                label = 'Squeeze it',
                action = function(slot)
                    print('You squeezed the burger :(')
                end
            },
            {
                label = 'What do you call a vegan burger?',
                group = 'Hamburger Puns',
                action = function(slot)
                    print('A misteak.')
                end
            },
            {
                label = 'What do frogs like to eat with their hamburgers?',
                group = 'Hamburger Puns',
                action = function(slot)
                    print('French flies.')
                end
            },
            {
                label = 'Why were the burger and fries running?',
                group = 'Hamburger Puns',
                action = function(slot)
                    print('Because they\'re fast food.')
                end
            }
        },
        consume = 0.3
    },

    ['bandage'] = {
        label = 'Bandage',
        weight = 115,
    },

    ['burger'] = {
        label = 'Burger',
        weight = 220,
        client = {
            status = { hunger = 200000 },
            anim = 'eating',
            prop = 'burger',
            usetime = 2500,
            notification = 'You ate a delicious burger'
        },
    },

    ['sprunk'] = {
        label = 'Sprunk',
        weight = 350,
        client = {
            status = { thirst = 200000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_ld_can_01`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
            usetime = 2500,
            notification = 'You quenched your thirst with a sprunk'
        }
    },

    ['parachute'] = {
        label = 'Parachute',
        weight = 8000,
        stack = false,
        client = {
            anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
            usetime = 1500
        }
    },

    ['garbage'] = {
        label = 'Garbage',
    },

    ['paperbag'] = {
        label = 'Paper Bag',
        weight = 1,
        stack = false,
        close = false,
        consume = 0
    },

    ['panties'] = {
        label = 'Knickers',
        weight = 10,
        consume = 0,
        client = {
            status = { thirst = -100000, stress = -25000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_cs_panties_02`, pos = vec3(0.03, 0.0, 0.02), rot = vec3(0.0, -13.5, -1.5) },
            usetime = 2500,
        }
    },

    ['lockpick'] = {
        label = 'Lockpick',
        weight = 160,
    },

    ['phone'] = {
        label = 'Phone',
        weight = 190,
        stack = false,
        consume = 0,
        client = {
            add = function(total)
                if total > 0 then
                    pcall(function() return exports.npwd:setPhoneDisabled(false) end)
                end
            end,

            remove = function(total)
                if total < 1 then
                    pcall(function() return exports.npwd:setPhoneDisabled(true) end)
                end
            end
        }
    },

    ['mustard'] = {
        label = 'Mustard',
        weight = 500,
        client = {
            status = { hunger = 25000, thirst = 25000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_food_mustard`, pos = vec3(0.01, 0.0, -0.07), rot = vec3(1.0, 1.0, -1.5) },
            usetime = 2500,
            notification = 'You... drank mustard'
        }
    },

    ['water'] = {
        label = 'Water',
        weight = 500,
        client = {
            status = { thirst = 200000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_ld_flow_bottle`, pos = vec3(0.03, 0.03, 0.02), rot = vec3(0.0, 0.0, -1.5) },
            usetime = 2500,
            cancel = true,
            notification = 'You drank some refreshing water'
        }
    },

    ['armour'] = {
        label = 'Bulletproof Vest',
        weight = 3000,
        stack = false,
        client = {
            anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
            usetime = 3500
        }
    },

    ['clothing'] = {
        label = 'Clothing',
        consume = 0,
    },

    ['money'] = {
        label = 'Money',
    },

    ['black_money'] = {
        label = 'Dirty Money',
    },

    ['id_card'] = {
        label = 'Identification Card',
    },

    ['driver_license'] = {
        label = 'Drivers License',
    },

    ['weaponlicense'] = {
        label = 'Weapon License',
    },

    ['lawyerpass'] = {
        label = 'Lawyer Pass',
    },

    ['radio'] = {
        label = 'Radio',
        weight = 1000,
        allowArmed = true,
        consume = 0,
        client = {
            event = 'mm_radio:client:use'
        }
    },

    ['jammer'] = {
        label = 'Radio Jammer',
        weight = 10000,
        allowArmed = true,
        client = {
            event = 'mm_radio:client:usejammer'
        }
    },

    ['radiocell'] = {
        label = 'AAA Cells',
        weight = 1000,
        stack = true,
        allowArmed = true,
        client = {
            event = 'mm_radio:client:recharge'
        }
    },

    ['advancedlockpick'] = {
        label = 'Advanced Lockpick',
        weight = 500,
    },

    ['screwdriverset'] = {
        label = 'Screwdriver Set',
        weight = 500,
    },

    ['electronickit'] = {
        label = 'Electronic Kit',
        weight = 500,
    },

    ['cleaningkit'] = {
        label = 'Cleaning Kit',
        weight = 500,
    },

    ['repairkit'] = {
        label = 'Repair Kit',
        weight = 2500,
    },

    ['advancedrepairkit'] = {
        label = 'Advanced Repair Kit',
        weight = 4000,
    },

    ['diamond_ring'] = {
        label = 'Diamond',
        weight = 1500,
    },

    ['rolex'] = {
        label = 'Golden Watch',
        weight = 1500,
    },

    ['goldbar'] = {
        label = 'Gold Bar',
        weight = 1500,
    },

    ['goldchain'] = {
        label = 'Golden Chain',
        weight = 1500,
    },

    ['crack_baggy'] = {
        label = 'Crack Baggy',
        weight = 100,
    },

    ['cokebaggy'] = {
        label = 'Bag of Coke',
        weight = 100,
    },

    ['coke_brick'] = {
        label = 'Coke Brick',
        weight = 2000,
    },

    ['coke_small_brick'] = {
        label = 'Coke Package',
        weight = 1000,
    },

    ['xtcbaggy'] = {
        label = 'Bag of Ecstasy',
        weight = 100,
    },

    ['meth'] = {
        label = 'Methamphetamine',
        weight = 100,
    },

    ['oxy'] = {
        label = 'Oxycodone',
        weight = 100,
    },

    ['weed_ak47'] = {
        label = 'AK47 2g',
        weight = 200,
    },

    ['weed_ak47_seed'] = {
        label = 'AK47 Seed',
        weight = 1,
    },

    ['weed_skunk'] = {
        label = 'Skunk 2g',
        weight = 200,
    },

    ['weed_skunk_seed'] = {
        label = 'Skunk Seed',
        weight = 1,
    },

    ['weed_amnesia'] = {
        label = 'Amnesia 2g',
        weight = 200,
    },

    ['weed_amnesia_seed'] = {
        label = 'Amnesia Seed',
        weight = 1,
    },

    ['weed_og-kush'] = {
        label = 'OGKush 2g',
        weight = 200,
    },

    ['weed_og-kush_seed'] = {
        label = 'OGKush Seed',
        weight = 1,
    },

    ['weed_white-widow'] = {
        label = 'OGKush 2g',
        weight = 200,
    },

    ['weed_white-widow_seed'] = {
        label = 'White Widow Seed',
        weight = 1,
    },

    ['weed_purple-haze'] = {
        label = 'Purple Haze 2g',
        weight = 200,
    },

    ['weed_purple-haze_seed'] = {
        label = 'Purple Haze Seed',
        weight = 1,
    },

    ['weed_brick'] = {
        label = 'Weed Brick',
        weight = 2000,
    },

    ['weed_nutrition'] = {
        label = 'Plant Fertilizer',
        weight = 2000,
    },

    ['joint'] = {
        label = 'Joint',
        weight = 200,
    },

    ['rolling_paper'] = {
        label = 'Rolling Paper',
        weight = 0,
    },

    ['empty_weed_bag'] = {
        label = 'Empty Weed Bag',
        weight = 0,
    },

    ['firstaid'] = {
        label = 'First Aid',
        weight = 2500,
    },

    ['ifaks'] = {
        label = 'Individual First Aid Kit',
        weight = 2500,
    },

    ['painkillers'] = {
        label = 'Painkillers',
        weight = 400,
    },

    ['firework1'] = {
        label = '2Brothers',
        weight = 1000,
    },

    ['firework2'] = {
        label = 'Poppelers',
        weight = 1000,
    },

    ['firework3'] = {
        label = 'WipeOut',
        weight = 1000,
    },

    ['firework4'] = {
        label = 'Weeping Willow',
        weight = 1000,
    },

    ['steel'] = {
        label = 'Steel',
        weight = 100,
    },

    ['rubber'] = {
        label = 'Rubber',
        weight = 100,
    },

    ['metalscrap'] = {
        label = 'Metal Scrap',
        weight = 100,
    },

    ['iron'] = {
        label = 'Iron',
        weight = 100,
    },

    ['copper'] = {
        label = 'Copper',
        weight = 100,
    },

    ['aluminum'] = {
        label = 'Aluminium',
        weight = 100,
    },

    ['plastic'] = {
        label = 'Plastic',
        weight = 100,
    },

    ['glass'] = {
        label = 'Glass',
        weight = 100,
    },

    ['gatecrack'] = {
        label = 'Gatecrack',
        weight = 1000,
    },

    ['cryptostick'] = {
        label = 'Crypto Stick',
        weight = 100,
    },

    ['trojan_usb'] = {
        label = 'Trojan USB',
        weight = 100,
    },

    ['toaster'] = {
        label = 'Toaster',
        weight = 5000,
    },

    ['small_tv'] = {
        label = 'Small TV',
        weight = 100,
    },

    ['security_card_01'] = {
        label = 'Security Card A',
        weight = 100,
    },

    ['security_card_02'] = {
        label = 'Security Card B',
        weight = 100,
    },

    ['drill'] = {
        label = 'Drill',
        weight = 5000,
    },

    ['thermite'] = {
        label = 'Thermite',
        weight = 1000,
    },

    ['diving_gear'] = {
        label = 'Diving Gear',
        weight = 30000,
    },

    ['diving_fill'] = {
        label = 'Diving Tube',
        weight = 3000,
    },

    ['antipatharia_coral'] = {
        label = 'Antipatharia',
        weight = 1000,
    },

    ['dendrogyra_coral'] = {
        label = 'Dendrogyra',
        weight = 1000,
    },

    ['jerry_can'] = {
        label = 'Jerrycan',
        weight = 3000,
    },

    ['nitrous'] = {
        label = 'Nitrous',
        weight = 1000,
    },

    ['wine'] = {
        label = 'Wine',
        weight = 500,
    },

    ['grape'] = {
        label = 'Grape',
        weight = 10,
    },

    ['grapejuice'] = {
        label = 'Grape Juice',
        weight = 200,
    },

    ['coffee'] = {
        label = 'Coffee',
        weight = 200,
    },

    ['vodka'] = {
        label = 'Vodka',
        weight = 500,
    },

    ['whiskey'] = {
        label = 'Whiskey',
        weight = 200,
    },

    ['beer'] = {
        label = 'Beer',
        weight = 200,
    },

    ['sandwich'] = {
        label = 'Sandwich',
        weight = 200,
    },

    ['walking_stick'] = {
        label = 'Walking Stick',
        weight = 1000,
    },

    ['lighter'] = {
        label = 'Lighter',
        weight = 200,
    },

    ['binoculars'] = {
        label = 'Binoculars',
        weight = 800,
    },

    ['stickynote'] = {
        label = 'Sticky Note',
        weight = 0,
    },

    ['empty_evidence_bag'] = {
        label = 'Empty Evidence Bag',
        weight = 200,
    },

    ['filled_evidence_bag'] = {
        label = 'Filled Evidence Bag',
        weight = 200,
    },

    ['harness'] = {
        label = 'Harness',
        weight = 200,
    },

    ['handcuffs'] = {
        label = 'Handcuffs',
        weight = 200,
    },
    -- JIM-MINING --
    iron = { label = 'Iron', weight = 100, stack = true, description = "Handy piece of metal that you can probably use for something",
        client = { image = 'iron.png', }
    },
    aluminum = { label = 'Aluminum', weight = 100, stack = true, description = "Nice piece of metal that you can probably use for something",
        client = { image = 'aluminum.png', }
    },
    rubber = { label = 'Rubber', weight = 100, stack = true, description = "Rubber, I believe you can make your own rubber ducky with it :D",
        client = { image = 'rubber.png', }
    },
    glass = { label = 'Glass', weight = 100, stack = true, description = "It is very fragile, watch out",
        client = { image = 'glass.png', }
    },
    copper = { label = 'Copper', weight = 100, stack = true, description = "Nice piece of metal that you can probably use for something",
        client = { image = 'copper.png', }
    },
    steel = { label = 'Steel', weight = 100, stack = true, description = "Nice piece of metal that you can probably use for something",
        client = { image = 'steel.png', }
    },
    plastic = { label = 'Plastic', weight = 100, stack = true, description = "RECYCLE! - Greta Thunberg 2019",
        client = { image = 'plastic.png', }
    },
    metalscrap = { label = 'Metal Scrap', weight = 100, stack = true, description = "You can probably make something nice out of this",
        client = { image = 'metalscrap.png', }
    },

    bottle = { name = "bottle", label = "Empty Bottle", weight = 10, stack = true,  description = "A glass bottle",
        client = { image = "bottle.png", }
    },
    can = { name = "can", label = "Empty Can", weight = 10, stack = true, description = "An empty can, good for recycling",
        client = { image = "can.png", }
    },

    -- Jim-mining stuff
    stone = { label = "Stone", weight = 2000, stack = true, close = false, description = "Stone woo",
        client = { image = "stone.png", }
    },

    uncut_emerald = { label = "Uncut Emerald", weight = 100, stack = true, close = false, description = "A rough Emerald",
        client = { image = "uncut_emerald.png", }
    },
    uncut_ruby = { label = "Uncut Ruby", weight = 100, stack = true, close = false, description = "A rough Ruby",
        client = { image = "uncut_ruby.png", }
    },
    uncut_diamond = { label = "Uncut Diamond", weight = 100, stack = true, close = false, description = "A rough Diamond",
        client = { image = "uncut_diamond.png", }
    },
    uncut_sapphire = { label = "Uncut Sapphire", weight = 100, stack = true, close = false, description = "A rough Sapphire",
        client = { image = "uncut_sapphire.png", }
    },

    emerald = { label = "Emerald", weight = 150, stack = true, close = false, description = "A shiny Emerald gemstone!",
        client = { image = "emerald.png", }
    },
    ruby = { label = "Ruby", weight = 150, stack = true, close = false, description = "A shiny Ruby gemstone!",
        client = { image = "ruby.png", }
    },
    diamond = { label = "Diamond", weight = 150, stack = true, close = false, description = "A shiny Diamond gemstone!",
        client = { image = "diamond.png", }
    },
    sapphire = { label = "Sapphire", weight = 150, stack = true, close = false, description = "A shiny Sapphire gemstone!",
        client = { image = "sapphire.png", }
    },

    gold_ring = { label = "Gold Ring", weight = 200, stack = true, close = false, description = "A diamond ring seems like the jackpot to me!",
        client = { image = "gold_ring.png", }
    },
    diamond_ring = { label = "Diamond Ring", weight = 200, stack = true, close = true, description = "A diamond ring seems like the jackpot to me!",
        client = { image = "diamond_ring.png", }
    },
    ruby_ring = { label = "Ruby Ring", weight = 200, stack = true, close = false, description = "",
        client = { image = "ruby_ring.png", }
    },
    sapphire_ring = { label = "Sapphire Ring", weight = 200, stack = true, close = false, description = "",
        client = { image = "sapphire_ring.png", }
    },
    emerald_ring = { label = "Emerald Ring", weight = 200, stack = true, close = false, description = "",
        client = { image = "emerald_ring.png", }
    },

    silver_ring = { label = "Silver Ring", weight = 200, stack = true, close = false, description = "",
        client = { image = "silver_ring.png", }
    },
    diamond_ring_silver = { label = "Diamond Ring Silver", weight = 200, stack = true, close = false, description = "",
        client = { image = "diamond_ring_silver.png", }
    },
    ruby_ring_silver = { label = "Ruby Ring Silver", weight = 200, stack = true, close = false, description = "",
        client = { image = "ruby_ring_silver.png", }
    },
    sapphire_ring_silver = { label = "Sapphire Ring Silver", weight = 200, stack = true, close = false, description = "A sparkling ring of sapphire.",
        client = { image = "sapphire_ring_silver.png", }
    },
    emerald_ring_silver = { label = "Emerald Ring Silver", weight = 200, stack = true, close = false, description = "",
        client = { image = "emerald_ring_silver.png", }
    },
    goldchain = { label = "Golden Chain", weight = 200, stack = true, close = true, description = "A golden chain seems like the jackpot to me!",
        client = { image = "goldchain.png", }
    },
    diamond_necklace = { label = "Diamond Necklace", weight = 200, stack = true, close = false, description = "",
        client = { image = "diamond_necklace.png", }
    },
    ruby_necklace = { label = "Ruby Necklace", weight = 200, stack = true, close = false, description = "",
        client = { image = "ruby_necklace.png", }
    },
    sapphire_necklace = { label = "Sapphire Necklace", weight = 200, stack = true, close = false, description = "",
        client = { image = "sapphire_necklace.png", }
    },
    emerald_necklace = { label = "Emerald Necklace", weight = 200, stack = true, close = false, description = "",
        client = { image = "emerald_necklace.png", }
    },

    silverchain = { label = "Silver Chain", weight = 200, stack = true, close = false, description = "",
        client = { image = "silverchain.png", }
    },
    diamond_necklace_silver = { label = "Diamond Necklace Silver", weight = 200, stack = true, close = false, description = "",
        client = { image = "diamond_necklace_silver.png", }
    },
    ruby_necklace_silver = { label = "Ruby Necklace Silver", weight = 200, stack = true, close = false, description = "",
        client = { image = "ruby_necklace_silver.png", }
    },
    sapphire_necklace_silver = { label = "Sapphire Necklace Silver", weight = 200, stack = true, close = false, description = "",
        client = { image = "sapphire_necklace_silver.png", }
    },
    emerald_necklace_silver = { label = "Emerald Necklace Silver", weight = 200, stack = true, close = false, description = "",
        client = { image = "emerald_necklace_silver.png", }
    },

    goldearring = { label = "Golden Earrings", weight = 200, stack = true, close = false, description = "Golden earrings for your Golden Girl",
        client = { image = "gold_earring.png", }
    },
    diamond_earring = { label = "Diamond Earrings", weight = 200, stack = true, close = false, description = "",
        client = { image = "diamond_earring.png", }
    },
    ruby_earring = { label = "Ruby Earrings", weight = 200, stack = true, close = false, description = "",
        client = { image = "ruby_earring.png", }
    },
    sapphire_earring = { label = "Sapphire Earrings", weight = 200, stack = true, close = false, description = "",
        client = { image = "sapphire_earring.png", }
    },
    emerald_earring = { label = "Emerald Earrings", weight = 200, stack = true, close = false, description = "",
        client = { image = "emerald_earring.png", }
    },

    silverearring = { label = "Silver Earrings", weight = 200, stack = true, close = false, description = "",
        client = { image = "silver_earring.png", }
    },
    diamond_earring_silver = { label = "Diamond Earrings Silver", weight = 200, stack = true, close = false, description = "",
        client = { image = "diamond_earring_silver.png", }
    },
    ruby_earring_silver = { label = "Ruby Earrings Silver", weight = 200, stack = true, close = false, description = "",
        client = { image = "ruby_earring_silver.png", }
    },
    sapphire_earring_silver = { label = "Sapphire Earrings Silver", weight = 200, stack = true, close = false, description = "",
        client = { image = "sapphire_earring_silver.png", }
    },
    emerald_earring_silver = { label = "Emerald Earrings Silver", weight = 200, stack = true, close = false, description = "",
        client = { image = "emerald_earring_silver.png", }
    },
    carbon = { label = "Carbon", weight = 1000, stack = true, close = false, description = "Carbon, a base ore.",
        client = { image = "carbon.png", }
    },
    ironore = { label = "Iron Ore", weight = 1000, stack = true, close = false, description = "Iron, a base ore.",
        client = { image = "ironore.png", }
    },
    copperore = { label = "Copper Ore", weight = 1000, stack = true, close = false, description = "Copper, a base ore.",
        client = { image = "copperore.png", }
    },
    goldore = { label = "Gold Ore", weight = 1000, stack = true, close = false, description = "Gold Ore",
        client = { image = "goldore.png", }
    },
    silverore = { label = "Silver Ore", weight = 1000, stack = true, close = false, description = "Silver Ore",
        client = { image = "silverore.png", }
    },
    goldingot = { label = "Gold Ingot", weight = 1000, stack = true, close = false, description = "",
        client = { image = "goldingot.png", }
    },
    silveringot = { label = "Silver Ingot", weight = 1000, stack = true, close = false, description = "",
        client = { image = "silveringot.png", }
    },
    pickaxe = { label = "Pickaxe", weight = 1000, stack = false, close = false, description = "",
        client = { image = "pickaxe.png", }
    },
    miningdrill = { label = "Mining Drill", weight = 1000, stack = false, close = false, description = "",
        client = { image = "miningdrill.png", }
    },
    mininglaser = { label = "Mining Laser", weight = 900, stack = false, close = false, description = "",
        client = { image = "mininglaser.png", }
    },
    drillbit = { label = "Drill Bit", weight = 10, stack = true, close = false, description = "",
        client = { image = "drillbit.png", }
    },
    goldpan = { label = "Gold Panning Tray", weight = 10, stack = true, close = false, description = "Don't worry you'll hit gold eventually!",
        client = { image = "goldpan.png", }
    },
    ['water_bottle'] = {
    label = 'Water Bottle',
    weight = 200,
    stack = true,
    close = true,
    description = 'Refresh yourself with some water.'
},

    ['casinochips'] = {
        label = 'Casino Chips',
        weight = 0,
        stack = true,
        close = true,
        description = 'Casino chips used for gambling.'
    },

    ['casino_member'] = {
        label = 'Casino Member Card',
        weight = 10,
        stack = false,
        close = true,
        description = 'A membership card for the Diamond Casino.'
    },

    ['casino_vip'] = {
        label = 'Casino VIP Card',
        weight = 10,
        stack = false,
        close = true,
        description = 'A VIP membership card for the Diamond Casino.'
    },

    ['business_laptop'] = {
        label = 'Business Laptop',
        weight = 2000,
        stack = false,
        close = true,
        description = 'A laptop for managing your businesses. Use it near a business to access the management dashboard.',
        client = {
            export = 'chris_businesses.useBusinessLaptop'
        }
    },
    ['rentalpapers'] = {
        label = "Rental Papers",
        weight = 0,
        stack = false,
        close = false,
        description = "Rental Papers",
        client = {
            image = "rentalpapers.png",
        },
    },
    ['fishingrod1'] = {
        label = 'Fishing Rod',
        consume = 0,
        stack = false,
        weight = 80,
        client = {
            image = 'fishingrod.png'
        }
    },
    ['commonbait'] = {
        label = 'Common bait',
        consume = 1,
        stack = true,
        weight = 5,
        client = {
            image = 'commonbait.png'
        }
    },
    ['fish'] = {
        label = 'Common Fish',
        weight = 5,
        client = {
            image = 'fish.png',
        },
        stack = true,
        consume = 0,
    },
    ['dolphin'] = {
        label = 'Dolphin',
        weight = 50,
        client = {
            image = 'dolphin.png',
        },
        stack = true,
        consume = 0,
    },
    ['hammershark'] = {
        label = 'Hammer Shark',
        weight = 50,
        client = {
            image = 'hammershark.png',
        },
        stack = true,
        consume = 0,
    },
    ['tigershark'] = {
        label = 'Tiger Shark',
        weight = 50,
        client = {
            image = 'tigershark.png',
        },
        stack = true,
        consume = 0,
    },
    ['killerwhale'] = {
        label = 'Killer Whale',
        weight = 50,
        client = {
            image = 'killerwhale.png',
        },
        stack = true,
        consume = 0,
    },
    ['humpback'] = {
        label = 'Humpback',
        weight = 200,
        client = {
            image = 'humpback.png',
        },
        stack = true,
        consume = 0,
    },
    ['stingray'] = {
        label = 'Stingray',
        weight = 20,
        client = {
            image = 'stingray.png',
        },
        stack = true,
        consume = 0,
    },
    ['weed_smallbag'] = {
        label = 'Weed Baggie',
        weight = 100,
        stack = true,
        consume = 0,
        client = {
            image = 'weed_baggy.png',
        },
        description = 'A small bag of cannabis ready for street deals.'
    },
    ['coke_smallbag'] = {
        label = 'Cocaine Baggie',
        weight = 100,
        stack = true,
        consume = 0,
        client = {
            image = 'cocaine_baggy.png',
        },
        description = 'A small bag of cocaine ready for street deals.'
    },
    ['meth_smallbag'] = {
        label = 'Meth Baggie',
        weight = 100,
        stack = true,
        consume = 0,
        client = {
            image = 'meth_baggy.png',
        },
        description = 'A small bag of meth ready for street deals.'
    },
    ['extended_clip'] = {
        label = 'Extended Magazine',
        weight = 250,
        stack = true,
        close = true,
        consume = 0,
        description = 'High-capacity magazine compatible with most black market builds.',
        client = {
            image = 'at_clip_extended.png'
        }
    },
    ['suppressor'] = {
        label = 'Threaded Suppressor',
        weight = 200,
        stack = true,
        close = true,
        consume = 0,
        description = 'Reduces muzzle flash and sound signature on supported firearms.',
        client = {
            image = 'at_suppressor.png'
        }
    },
    ['flashlight_attachment'] = {
        label = 'Weapon Flashlight',
        weight = 180,
        stack = true,
        close = true,
        consume = 0,
        description = 'Rail-mounted flashlight for low-light engagements.',
        client = {
            image = 'flashlight_attachment.png'
        }
    },
    ['keycard_scrambler'] = {
        label = 'Keycard Scrambler',
        weight = 150,
        stack = false,
        close = true,
        consume = 0,
        description = 'Temporary bypass tool for magnetic keycard readers.',
        client = {
            image = 'security_card_01.png'
        }
    },
    ['door_override_chip'] = {
        label = 'Door Override Chip',
        weight = 80,
        stack = false,
        close = true,
        consume = 0,
        description = 'Single-use microchip that convinces smart locks to open.',
        client = {
            image = 'tunerchip.png'
        }
    },
    ['fake_id'] = {
        label = 'Forged ID',
        weight = 10,
        stack = true,
        close = true,
        consume = 0,
        description = 'A convincing fake identification card.',
        client = {
            image = 'id_card.png'
        }
    },
    ['credit_cloner'] = {
        label = 'Credit Cloner',
        weight = 200,
        stack = false,
        close = true,
        consume = 0,
        description = 'Portable skimmer for duplicating payment cards.',
        client = {
            image = 'usb.png'
        }
    },
    ['burner_phone'] = {
        label = 'Burner Phone',
        weight = 150,
        stack = false,
        close = true,
        consume = 0,
        description = 'Disposable phone with wiped IMEI and prepaid minutes.',
        client = {
            image = 'phone.png'
        }
    },
    ['vpn_device'] = {
        label = 'Encrypted VPN Hub',
        weight = 120,
        stack = false,
        close = true,
        consume = 0,
        description = 'Allows access to darknet marketplaces and secure comms.',
        client = {
            image = 'cryptostick.png'
        }
    },
    ['forged_pass'] = {
        label = 'Forged Access Pass',
        weight = 12,
        stack = true,
        close = true,
        consume = 0,
        description = 'Spoofs restricted door access until revoked.',
        client = {
            image = 'passport.png'
        }
    },
    ['blackmarket_pass'] = {
        label = 'Blackmarket Credential',
        weight = 8,
        stack = false,
        close = true,
        consume = 0,
        description = 'Proof of membership for underground suppliers.',
        client = {
            image = 'certificate.png'
        }
    },
    ['forged_license'] = {
        label = 'Forged Business License',
        weight = 8,
        stack = true,
        close = true,
        consume = 0,
        description = 'Lets the holder masquerade as a legitimate enterprise.',
        client = {
            image = 'driver_license.png'
        }
    },
    ['stolen_art'] = {
        label = 'Stolen Artwork',
        weight = 3200,
        stack = false,
        close = true,
        consume = 0,
        description = 'Priceless art piece fenced on the black market.',
        client = {
            image = 'painting.png'
        }
    },
    ['mystery_package'] = {
        label = 'Mystery Package',
        weight = 600,
        stack = true,
        close = true,
        consume = 0,
        description = 'Sealed crate containing a random illicit good.',
        client = {
            image = 'antiquevase.png'
        }
    },
    ['reinforced_armor_vest'] = {
        label = 'Reinforced Armor Vest',
        weight = 6500,
        stack = false,
        close = true,
        consume = 0,
        description = 'Up-armored tactical vest offering extended durability.',
        client = {
            image = 'armor.png'
        }
    },
    ['illegal_radio'] = {
        label = 'Encrypted Radio',
        weight = 500,
        stack = false,
        close = true,
        consume = 0,
        description = 'Radio tuned to encrypted underworld frequencies.',
        client = {
            image = 'radio.png'
        }
    },
    ['nightvision_goggles'] = {
        label = 'Night Vision Goggles',
        weight = 900,
        stack = false,
        close = true,
        consume = 0,
        description = 'Helmet-mounted NVG rig for low-light operations.',
        client = {
            image = 'helmet.png'
        }
    },
    ['silencer_kit'] = {
        label = 'Silencer Fabrication Kit',
        weight = 220,
        stack = true,
        close = true,
        consume = 0,
        description = 'Includes jigs and baffles to craft custom suppressors.',
        client = {
            image = 'at_suppressor.png'
        }
    },
    ['custom_ammo'] = {
        label = 'Custom Ammunition',
        weight = 160,
        stack = true,
        close = true,
        consume = 0,
        description = 'Armor-piercing or specialty rounds, limited batches.',
        client = {
            image = 'ammo-9.png'
        }
    },
    ['c4_charge'] = {
        label = 'C4 Charge',
        weight = 1400,
        stack = false,
        close = true,
        consume = 0,
        description = 'Remote-detonated explosive charge for breaching.',
        client = {
            image = 'WEAPON_STICKYBOMB.png'
        }
    },
    ['emp_device'] = {
        label = 'EMP Device',
        weight = 900,
        stack = false,
        close = true,
        consume = 0,
        description = 'Short-range electromagnetic pulse emitter.',
        client = {
            image = 'ammo-emp.png'
        }
    },
    ['handcuff_keys'] = {
        label = 'Handcuff Keys',
        weight = 40,
        stack = true,
        close = true,
        consume = 0,
        description = 'Universal cuffs key for quick escapes.',
        client = {
            image = 'WEAPON_HANDCUFFS.PNG'
        }
    },
    ['animal_tracker'] = { label = 'Animal Tracker', weight = 200, stack = false, allowArmed = true, client = { image = 'animal_tracker.png' } },
    ['campfire'] = { label = 'Campfire', weight = 200, stack = false, allowArmed = true, client = { image = 'campfire.png' } },
    ['huntingbait'] = { label = 'Hunting Bait', weight = 100, stack = true, allowArmed = true, client = { image = 'huntingbait.png' } },
    ['cooked_meat'] = { label = 'Cooked Meat', weight = 200, client = { image = 'cooked_meat.png' } },
    ['raw_meat'] = { label = 'Raw Meat', weight = 200, client = { image = 'raw_meat.png' } },
    ['skin_deer_ruined'] = { label = 'Tattered Deer Pelt', weight = 200, stack = false, client = { image = 'skin_deer_ruined.png' } },
    ['skin_deer_low'] = { label = 'Worn Deer Pelt', weight = 200, client = { image = 'skin_deer_low.png' } },
    ['skin_deer_medium'] = { label = 'Supple Deer Pelt', weight = 200, client = { image = 'skin_deer_medium.png' } },
    ['skin_deer_good'] = { label = 'Prime Deer Pelt', weight = 200, client = { image = 'skin_deer_good.png' } },
    ['skin_deer_perfect'] = { label = 'Flawless Deer Pelt', weight = 200, client = { image = 'skin_deer_perfect.png' } },
    ['deer_horn'] = { label = 'Deer Horn', weight = 1000, client = { image = 'deer_horn.png' } },

    -- cs_heistmaster safe keys
    ['safe_key_store_247_grove'] = {
        label = 'Store Safe Key',
        weight = 0,
        stack = false,
        close = true,
        description = 'A small key that unlocks the backroom safe.',
        consume = 0,
        client = {
            image = 'key.png'
        }
    },
}

