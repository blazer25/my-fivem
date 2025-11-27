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

    -- Brutal Gangs Items
    spraycan = {
        label = "Spray Can",
        weight = 1,
        stack = true,
        close = false,
        client = { image = "spraycan.png", }
    },
    sprayremover = {
        label = "Spray Remover",
        weight = 1,
        stack = true,
        close = false,
        client = { image = "sprayremover.png", }
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

    -- Drug items
    ['weed_skunk_seed'] = {
        label = 'Skunk Seed',
        weight = 200,
        stack = true,
        close = false,
        client = {
            image = 'weed_seed.png'
        },
    },

    ['weed_ogkush_seed'] = {
        label = 'OG Kush Seed',
        weight = 200,
        stack = true,
        close = false,
        client = {
            image = 'weed_seed.png'
        },
    },

    ['weed_amnesia_seed'] = {
        label = 'Amensia Seed',
        weight = 200,
        stack = true,
        close = false,
        client = {
            image = 'weed_seed.png'
        },
    },

    ['weed_ak47_seed'] = {
        label = 'AK47 Seed',
        weight = 200,
        stack = true,
        close = false,
        client = {
            image = 'weed_seed.png'
        },
    },

    ['weed_purplehaze_seed'] = {
        label = 'Purple Haze Seed',
        weight = 200,
        stack = true,
        close = false,
        client = {
            image = 'weed_seed.png'
        },
    },

    ['weed_whitewidow_seed'] = {
        label = 'White Widow Seed',
        weight = 200,
        stack = true,
        close = false,
        client = {
            image = 'weed_seed.png'
        },
    },

    ['weed_whitewidow'] = {
        label = 'White Widow 2g',
        weight = 200,
        stack = true,
        close = false,
        client = {
            image = 'weed_baggy.png'
        },
    },

    ['weed_skunk'] = {
        label = 'Skunk 2g',
        weight = 200,
        stack = true,
        close = false,
        client = {
            image = 'weed_baggy.png'
        },
    },

    ['weed_purplehaze'] = {
        label = 'Purple Haze 2g',
        weight = 200,
        stack = true,
        close = false,
        client = {
            image = 'weed_baggy.png'
        },
    },

    ['weed_ogkush'] = {
        label = 'OG Kush 2g',
        weight = 200,
        stack = true,
        close = false,
        client = {
            image = 'weed_baggy.png'
        },
    },

    ['weed_amnesia'] = {
        label = 'Amnesia 2g',
        weight = 200,
        stack = true,
        close = false,
        client = {
            image = 'weed_baggy.png'
        },
    },

    ['weed_ak47'] = {
        label = 'AK47 2g',
        weight = 200,
        stack = true,
        close = false,
        client = {
            image = 'weed_baggy.png'
        },
    },

    ['coke'] = {
        label = 'Raw Cocaine',
        weight = 1000,
        stack = true,
        close = false,
        client = {
            image = 'coke.png'
        },
    },

    ['coca_leaf'] = {
        label = 'Cocaine leaves',
        weight = 1500,
        stack = true,
        close = false,
        client = {
            image = 'coca_leaf.png'
        },
    },

    ['bakingsoda'] = {
        label = 'Baking Soda',
        weight = 300,
        stack = true,
        close = false,
        client = {
            image = 'bakingsoda.png'
        },
    },

    ['loosecoke'] = {
        label = 'Loose Coke',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'loosecoke.png'
        },
    },

    ['loosecokestagetwo'] = {
        label = 'Loose Coke',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'loosecokestagetwo.png'
        },
    },

    ['loosecokestagethree'] = {
        label = 'Loose Coke',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'loosecokestagethree.png'
        },
    },

    ['cokebaggy'] = {
        label = 'Bag of Cocaine',
        weight = 0,
        stack = true,
        close = true,
        client = {
            image = 'cocaine_baggy.png'
        },
    },

    ['cokebaggystagetwo'] = {
        label = 'Bag Of Cocaine',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'cocaine_baggystagetwo.png'
        },
    },

    ['cokebaggystagethree'] = {
        label = 'Bag Of Cocaine',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'cocaine_baggystagethree.png'
        },
    },

    ['cokestagetwo'] = {
        label = 'Raw Cocaine',
        weight = 100,
        stack = true,
        close = false,
        client = {
            image = 'cokestagetwo.png'
        },
    },

    ['cokestagethree'] = {
        label = 'Raw Cocaine',
        weight = 100,
        stack = true,
        close = false,
        client = {
            image = 'cokestagethree.png'
        },
    },

    ['empty_weed_bag'] = {
        label = 'Empty Weed Bag',
        weight = 0,
        stack = true,
        close = true,
        client = {
            image = 'weed_baggy_empty.png'
        },
    },

    ['baggedcracked'] = {
        label = 'Bag Of Crack',
        weight = 250,
        stack = true,
        close = false,
        client = {
            image = 'crackbag1.png'
        },
    },

    ['baggedcrackedstagetwo'] = {
        label = 'Better Bag Of Crack',
        weight = 250,
        stack = true,
        close = false,
        client = {
            image = 'crackbag2.png'
        },
    },

    ['baggedcrackedstagethree'] = {
        label = 'Best Bag Of Crack',
        weight = 250,
        stack = true,
        close = false,
        client = {
            image = 'crackbag3.png'
        },
    },

    ['crackrock'] = {
        label = 'Crack Rock',
        weight = 250,
        stack = true,
        close = false,
        client = {
            image = 'crackrock1.png'
        },
    },

    ['crackrockstagetwo'] = {
        label = 'Better Crack Rock',
        weight = 250,
        stack = true,
        close = false,
        client = {
            image = 'crackrock2.png'
        },
    },

    ['crackrockstagethree'] = {
        label = 'Best Crack Rock',
        weight = 250,
        stack = true,
        close = false,
        client = {
            image = 'crackrock3.png'
        },
    },

    ['poppyresin'] = {
        label = 'Poppy resin',
        weight = 2000,
        stack = true,
        close = false,
        client = {
            image = 'poppyresin.png'
        },
    },

    ['heroin'] = {
        label = 'Heroin Powder',
        weight = 500,
        stack = true,
        close = false,
        client = {
            image = 'heroinpowder.png'
        },
    },

    ['heroinstagetwo'] = {
        label = 'Heroin Powder',
        weight = 250,
        stack = true,
        close = false,
        client = {
            image = 'heroinpowderstagetwo.png'
        },
    },

    ['heroinstagethree'] = {
        label = 'Heroin Powder',
        weight = 250,
        stack = true,
        close = false,
        client = {
            image = 'heroinpowderstagethree.png'
        },
    },

    ['heroincut'] = {
        label = 'Cut Heroin',
        weight = 250,
        stack = true,
        close = false,
        client = {
            image = 'heroincut.png'
        },
    },

    ['heroincutstagetwo'] = {
        label = 'Cut Heroin',
        weight = 250,
        stack = true,
        close = false,
        client = {
            image = 'heroincut2.png'
        },
    },

    ['heroincutstagethree'] = {
        label = 'Cut Heroin',
        weight = 250,
        stack = true,
        close = false,
        client = {
            image = 'heroincut3.png'
        },
    },

    ['heroinlabkit'] = {
        label = 'Heroin Lab Kit',
        weight = 250,
        stack = true,
        close = false,
        client = {
            image = 'labkit.png'
        },
    },

    ['heroinvial'] = {
        label = 'Vial Of Heroin',
        weight = 250,
        stack = true,
        close = false,
        client = {
            image = 'heroin.png'
        },
    },

    ['heroinvialstagetwo'] = {
        label = 'Vial of Heroin',
        weight = 250,
        stack = true,
        close = false,
        client = {
            image = 'heroinstagetwo.png'
        },
    },

    ['heroinvialstagethree'] = {
        label = 'Vial Of Heroin',
        weight = 250,
        stack = true,
        close = false,
        client = {
            image = 'heroinstagethree.png'
        },
    },

    ['heroin_ready'] = {
        label = 'Heroin Syringe',
        weight = 250,
        stack = true,
        close = false,
        client = {
            image = 'heroin_ready.png'
        },
    },

    ['heroin_readystagetwo'] = {
        label = 'Heroin Syringe',
        weight = 250,
        stack = true,
        close = false,
        client = {
            image = 'heroin_readystagetwo.png'
        },
    },

    ['heroin_readystagethree'] = {
        label = 'Heroin Syringe',
        weight = 250,
        stack = true,
        close = false,
        client = {
            image = 'heroin_readystagethree.png'
        },
    },

    ['emptyvial'] = {
        label = 'empty vial',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'emptyvial.png'
        },
    },

    ['needle'] = {
        label = 'Syringe',
        weight = 250,
        stack = true,
        close = false,
        client = {
            image = 'syringe.png'
        },
    },

    ['leancup'] = {
        label = 'Empty Cup',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'leancup.png'
        },
    },

    ['cupoflean'] = {
        label = 'Lean Cup',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'cupoflean.png'
        },
    },

    ['cupofdextro'] = {
        label = 'Dextro Cup',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'cupofdextro.png'
        },
    },

    ['mdlean'] = {
        label = 'Sizzurup',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'Sizzurup.png'
        },
    },

    ['mdreddextro'] = {
        label = 'Red Dextro',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'reddextro.png'
        },
    },

    ['lysergic_acid'] = {
        label = 'Lysergic Acid',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'lysergic_acid.png'
        },
    },

    ['diethylamide'] = {
        label = 'Diethylamide',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'diethylamide.png'
        },
    },

    ['lsd_one_vial'] = {
        label = 'Tier 1 LSD Vial',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'lsd_one_vial.png'
        },
    },

    ['lsd_vial_two'] = {
        label = 'Tier 2 LSD Vial',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'lsd_vial_two.png'
        },
    },

    ['lsd_vial_three'] = {
        label = 'Tier 3 LSD Vial',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'lsd_vial_three.png'
        },
    },

    ['lsd_vial_four'] = {
        label = 'Tier 4 LSD Vial',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'lsd_vial_four.png'
        },
    },

    ['lsd_vial_five'] = {
        label = 'Tier 5 LSD Vial',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'lsd_vial_five.png'
        },
    },

    ['lsd_vial_six'] = {
        label = 'Tier 6 LSD Vial',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'lsd_vial_six.png'
        },
    },

    ['tab_paper'] = {
        label = 'Tab Paper',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'tab_paper.png'
        },
    },

    ['smileyfacesheet'] = {
        label = 'Smiley Face Sheet',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'smileysheet.png'
        },
    },

    ['wildcherrysheet'] = {
        label = 'Wild Cherry Sheet',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'wildcherrysheet.png'
        },
    },

    ['yinyangsheet'] = {
        label = 'Yin and Yang Sheet',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'yinyangsheet.png'
        },
    },

    ['pineapplesheet'] = {
        label = 'Pineapple Sheet',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'pineapplesheet.png'
        },
    },

    ['bart_tabs'] = {
        label = 'Cluckin Tabs',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'bart_tabs.png'
        },
    },

    ['bartsheet'] = {
        label = 'Cluckin Sheet',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'bartsheet.png'
        },
    },

    ['gratefuldeadsheet'] = {
        label = 'Maze Sheet',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'gratefuldeadsheet.png'
        },
    },

    ['smiley_tabs'] = {
        label = 'Smiley tabs',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'smiley_tabs.png'
        },
    },

    ['wildcherry_tabs'] = {
        label = 'Wild Cherry Tabs',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'wildcherry_tabs.png'
        },
    },

    ['yinyang_tabs'] = {
        label = 'Yin and Yang Tabs',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'yinyang_tabs.png'
        },
    },

    ['pineapple_tabs'] = {
        label = 'Pineapple Tabs',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'pineapple_tabs.png'
        },
    },

    ['gratefuldead_tabs'] = {
        label = 'Maze Tabs',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'gratefuldead_tabs.png'
        },
    },

    ['lsdlabkit'] = {
        label = 'LSD Mixing Table',
        weight = 1000,
        stack = true,
        close = true,
        client = {
            image = 'labkit.png'
        },
    },

    ['cactusbulb'] = {
        label = 'Cactus Bulb',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'cactusbulb.png'
        },
    },

    ['driedmescaline'] = {
        label = 'Mescaline',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'driedmescaline.png'
        },
    },

    ['ephedrine'] = {
        label = 'Ephedrine',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'ephedrine.png'
        },
    },

    ['acetone'] = {
        label = 'Acetone',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'acetone.png'
        },
    },

    ['methbags'] = {
        label = 'Meth',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'methbags.png'
        },
    },

    ['prescription_pad'] = {
        label = 'Prescription Pad',
        weight = 10,
        stack = true,
        close = false,
        client = {
            image = 'prescriptionpad.png'
        },
    },

    ['vicodin_prescription'] = {
        label = 'Vicie Prescription',
        weight = 250,
        stack = true,
        close = false,
        client = {
            image = 'adderalprescription.png'
        },
    },

    ['adderal_prescription'] = {
        label = 'Mdderal Prescription',
        weight = 250,
        stack = true,
        close = false,
        client = {
            image = 'adderalprescription.png'
        },
    },

    ['morphine_prescription'] = {
        label = 'Morphin Prescription',
        weight = 250,
        stack = true,
        close = false,
        client = {
            image = 'adderalprescription.png'
        },
    },

    ['xanax_prescription'] = {
        label = 'Zany Prescription',
        weight = 250,
        stack = true,
        close = false,
        client = {
            image = 'adderalprescription.png'
        },
    },

    ['adderal'] = {
        label = 'Madderal',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'adderal.png'
        },
    },

    ['vicodin'] = {
        label = 'Vicie',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'vicodin.png'
        },
    },

    ['morphine'] = {
        label = 'Morphin',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'morphine.png'
        },
    },

    ['xanax'] = {
        label = 'Zany',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'xanax.png'
        },
    },

    ['adderalbottle'] = {
        label = 'Madderal Bottle',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'pillbottle.png'
        },
    },

    ['vicodinbottle'] = {
        label = 'Vicie Bottle',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'pillbottle.png'
        },
    },

    ['morphinebottle'] = {
        label = 'Morphin Bottle',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'pillbottle.png'
        },
    },

    ['xanaxbottle'] = {
        label = 'Zany Bottle',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'pillbottle.png'
        },
    },

    ['shrooms'] = {
        label = 'Shrooms',
        weight = 250,
        stack = true,
        close = false,
        client = {
            image = 'shrooms.png'
        },
    },

    ['wetcannabis'] = {
        label = 'Wet Cannabis',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'wetcannabis.png'
        },
    },

    ['drycannabis'] = {
        label = 'Dry Cannabis',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'driedcannabis.png'
        },
    },

    ['weedgrinder'] = {
        label = 'Weed Grinder',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'weedgrinder.png'
        },
    },

    ['mdbutter'] = {
        label = 'Butter',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'butter.png'
        },
    },

    ['cannabutter'] = {
        label = 'Canna-Butter',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'cannabutter.png'
        },
    },

    ['specialbrownie'] = {
        label = 'Special Brownie',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'specialbrownie.png'
        },
    },

    ['specialcookie'] = {
        label = 'Special Cookie',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'specialcookie.png'
        },
    },

    ['specialmuffin'] = {
        label = 'Special Muffin',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'specialmuffin.png'
        },
    },

    ['specialchocolate'] = {
        label = 'Special Chocolate',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'specialchocolate.png'
        },
    },

    ['grindedweed'] = {
        label = 'Keef',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'keef.png'
        },
    },

    ['flour'] = {
        label = 'Flour',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'flour.png'
        },
    },

    ['chocolate'] = {
        label = 'Chocolate',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'chocolate.png'
        },
    },

    ['blunt'] = {
        label = 'Blunts',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'blunt.png'
        },
    },

    ['butane'] = {
        label = 'Butane',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'butane.png'
        },
    },

    ['butanetorch'] = {
        label = 'Butane Torch',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'butanetorch.png'
        },
    },

    ['dabrig'] = {
        label = 'Dab Rig',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'dabrig2.png'
        },
    },

    ['mdwoods'] = {
        label = 'MDWOODS',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'mdwoods.png'
        },
    },

    ['ciggie'] = {
        label = 'Ciggie',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'ciggie.png'
        },
    },

    ['tobacco'] = {
        label = 'Tobacco',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'tobacco.png'
        },
    },

    ['shatter'] = {
        label = 'Shatter',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'shatter.png'
        },
    },

    ['bluntwrap'] = {
        label = 'Blunt Wrap',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'bluntwrap.png'
        },
    },

    ['leanbluntwrap'] = {
        label = 'Lean Blunt Wrap',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'leanbluntwrap.png'
        },
    },

    ['dextrobluntwrap'] = {
        label = 'Dextro Blunt Wrap',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'dextrobluntwrap.png'
        },
    },

    ['leanblunts'] = {
        label = 'Lean Blunts',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'leanblunts.png'
        },
    },

    ['dextroblunts'] = {
        label = 'Dextro Blunts',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'dextroblunts.png'
        },
    },

    ['chewyblunt'] = {
        label = 'Chewy',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'blunt.png'
        },
    },

    ['cokeburner'] = {
        label = 'Coke Burner',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'gta5phone.png'
        },
    },

    ['crackburner'] = {
        label = 'Crack Burner',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'gta5phone.png'
        },
    },

    ['heroinburner'] = {
        label = 'Heroin Burner',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'gta5phone.png'
        },
    },

    ['lsdburner'] = {
        label = 'LSD Burner',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'gta5phone.png'
        },
    },

    ['xtcburner'] = {
        label = 'XTC Burner',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'gta5phone.png'
        },
    },

    ['isosafrole'] = {
        label = 'isosafrole',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'isosafrole.png'
        },
    },

    ['mdp2p'] = {
        label = 'mdp2p',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'mdp2p.png'
        },
    },

    ['raw_xtc'] = {
        label = 'Raw XTC',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'raw_xtc.png'
        },
    },

    ['singlepress'] = {
        label = 'Single Pill Press',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'pillpress.png'
        },
    },

    ['dualpress'] = {
        label = 'Dual Pill Press',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'pillpress.png'
        },
    },

    ['triplepress'] = {
        label = 'Triple Pill Press',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'pillpress.png'
        },
    },

    ['quadpress'] = {
        label = 'Quad Pill Press',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'pillpress.png'
        },
    },

    ['white_xtc'] = {
        label = 'White XTC',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'unstamped_white.png'
        },
    },

    ['white_xtc2'] = {
        label = 'White XTC',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'unstamped_white2.png'
        },
    },

    ['white_xtc3'] = {
        label = 'White XTC',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'unstamped_white3.png'
        },
    },

    ['white_xtc4'] = {
        label = 'White XTC',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'unstamped_white4.png'
        },
    },

    ['red_xtc'] = {
        label = 'Red XTC',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'unstamped_red.png'
        },
    },

    ['red_xtc2'] = {
        label = 'Red XTC',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'unstamped_red2.png'
        },
    },

    ['red_xtc3'] = {
        label = 'Red XTC',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'unstamped_red3.png'
        },
    },

    ['red_xtc4'] = {
        label = 'Red XTC',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'unstamped_red4.png'
        },
    },

    ['orange_xtc'] = {
        label = 'Orange XTC',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'unstamped_orange.png'
        },
    },

    ['orange_xtc2'] = {
        label = 'Orange XTC',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'unstamped_orange2.png'
        },
    },

    ['orange_xtc3'] = {
        label = 'Orange XTC',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'unstamped_orange3.png'
        },
    },

    ['orange_xtc4'] = {
        label = 'Orange XTC',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'unstamped_orange4.png'
        },
    },

    ['blue_xtc'] = {
        label = 'Blue XTC',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'unstamped_blue.png'
        },
    },

    ['blue_xtc2'] = {
        label = 'Blue XTC',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'unstamped_blue2.png'
        },
    },

    ['blue_xtc3'] = {
        label = 'Blue XTC',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'unstamped_blue3.png'
        },
    },

    ['blue_xtc4'] = {
        label = 'Blue XTC',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'unstamped_blue4.png'
        },
    },

    ['white_playboys'] = {
        label = 'White Fruit',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'playboy_white.png'
        },
    },

    ['white_playboys2'] = {
        label = 'White Fruit',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'playboy_white2.png'
        },
    },

    ['white_playboys3'] = {
        label = 'White Fruit',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'playboy_white3.png'
        },
    },

    ['white_playboys4'] = {
        label = 'White Fruit',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'playboy_white4.png'
        },
    },

    ['blue_playboys'] = {
        label = 'blue Fruit',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'playboy_blue.png'
        },
    },

    ['blue_playboys2'] = {
        label = 'blue Fruit',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'playboy_blue2.png'
        },
    },

    ['blue_playboys3'] = {
        label = 'blue Fruit',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'playboy_blue3.png'
        },
    },

    ['blue_playboys4'] = {
        label = 'blue Fruit',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'playboy_blue4.png'
        },
    },

    ['red_playboys'] = {
        label = 'red Fruit',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'playboy_red.png'
        },
    },

    ['red_playboys2'] = {
        label = 'red Fruit',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'playboy_red2.png'
        },
    },

    ['red_playboys3'] = {
        label = 'red Fruit',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'playboy_red3.png'
        },
    },

    ['red_playboys4'] = {
        label = 'red Fruit',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'playboy_red4.png'
        },
    },

    ['orange_playboys'] = {
        label = 'orange Fruit',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'playboy_orange.png'
        },
    },

    ['orange_playboys2'] = {
        label = 'orange Fruit',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'playboy_orange2.png'
        },
    },

    ['orange_playboys3'] = {
        label = 'orange Fruit',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'playboy_orange3.png'
        },
    },

    ['orange_playboys4'] = {
        label = 'orange Fruit',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'playboy_orange4.png'
        },
    },

    ['white_aliens'] = {
        label = 'White aliens',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'alien_white.png'
        },
    },

    ['white_aliens2'] = {
        label = 'White aliens',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'alien_white2.png'
        },
    },

    ['white_aliens3'] = {
        label = 'White aliens',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'alien_white3.png'
        },
    },

    ['white_aliens4'] = {
        label = 'White aliens',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'alien_white4.png'
        },
    },

    ['blue_aliens'] = {
        label = 'blue aliens',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'alien_blue.png'
        },
    },

    ['blue_aliens2'] = {
        label = 'blue aliens',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'alien_blue2.png'
        },
    },

    ['blue_aliens3'] = {
        label = 'blue aliens',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'alien_blue3.png'
        },
    },

    ['blue_aliens4'] = {
        label = 'blue aliens',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'alien_blue4.png'
        },
    },

    ['red_aliens'] = {
        label = 'red aliens',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'alien_red.png'
        },
    },

    ['red_aliens2'] = {
        label = 'red aliens',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'alien_red2.png'
        },
    },

    ['red_aliens3'] = {
        label = 'red aliens',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'alien_red3.png'
        },
    },

    ['red_aliens4'] = {
        label = 'red aliens',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'alien_red4.png'
        },
    },

    ['orange_aliens'] = {
        label = 'orange aliens',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'alien_orange.png'
        },
    },

    ['orange_aliens2'] = {
        label = 'orange aliens',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'alien_orange2.png'
        },
    },

    ['orange_aliens3'] = {
        label = 'orange aliens',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'alien_orange3.png'
        },
    },

    ['orange_aliens4'] = {
        label = 'orange aliens',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'alien_orange4.png'
        },
    },

    ['white_pl'] = {
        label = 'White pl',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'PL_white.png'
        },
    },

    ['white_pl2'] = {
        label = 'White pl',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'PL_white2.png'
        },
    },

    ['white_pl3'] = {
        label = 'White pl',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'PL_white3.png'
        },
    },

    ['white_pl4'] = {
        label = 'White pl',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'PL_white4.png'
        },
    },

    ['blue_pl'] = {
        label = 'blue pl',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'PL_blue.png'
        },
    },

    ['blue_pl2'] = {
        label = 'blue pl',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'PL_blue2.png'
        },
    },

    ['blue_pl3'] = {
        label = 'blue pl',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'PL_blue3.png'
        },
    },

    ['blue_pl4'] = {
        label = 'blue pl',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'PL_blue4.png'
        },
    },

    ['red_pl'] = {
        label = 'red pl',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'PL_red.png'
        },
    },

    ['red_pl2'] = {
        label = 'red pl',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'PL_red2.png'
        },
    },

    ['red_pl3'] = {
        label = 'red pl',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'PL_red3.png'
        },
    },

    ['red_pl4'] = {
        label = 'red pl',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'PL_red4.png'
        },
    },

    ['orange_pl'] = {
        label = 'orange pl',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'PL_orange.png'
        },
    },

    ['orange_pl2'] = {
        label = 'orange pl',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'PL_orange2.png'
        },
    },

    ['orange_pl3'] = {
        label = 'orange pl',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'PL_orange3.png'
        },
    },

    ['orange_pl4'] = {
        label = 'orange pl',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'PL_orange4.png'
        },
    },

    ['white_trolls'] = {
        label = 'White trolls',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'troll_white.png'
        },
    },

    ['white_trolls2'] = {
        label = 'White trolls',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'troll_white2.png'
        },
    },

    ['white_trolls3'] = {
        label = 'White trolls',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'troll_white3.png'
        },
    },

    ['white_trolls4'] = {
        label = 'White trolls',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'troll_white4.png'
        },
    },

    ['blue_trolls'] = {
        label = 'blue trolls',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'troll_blue.png'
        },
    },

    ['blue_trolls2'] = {
        label = 'blue trolls',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'troll_blue2.png'
        },
    },

    ['blue_trolls3'] = {
        label = 'blue trolls',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'troll_blue3.png'
        },
    },

    ['blue_trolls4'] = {
        label = 'blue trolls',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'troll_blue4.png'
        },
    },

    ['red_trolls'] = {
        label = 'red trolls',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'troll_red.png'
        },
    },

    ['red_trolls2'] = {
        label = 'red trolls',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'troll_red2.png'
        },
    },

    ['red_trolls3'] = {
        label = 'red trolls',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'troll_red3.png'
        },
    },

    ['red_trolls4'] = {
        label = 'red trolls',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'troll_red4.png'
        },
    },

    ['orange_trolls'] = {
        label = 'orange trolls',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'troll_orange.png'
        },
    },

    ['orange_trolls2'] = {
        label = 'orange trolls',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'troll_orange2.png'
        },
    },

    ['orange_trolls3'] = {
        label = 'orange trolls',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'troll_orange3.png'
        },
    },

    ['orange_trolls4'] = {
        label = 'orange trolls',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'troll_orange4.png'
        },
    },

    ['white_cats'] = {
        label = 'White cats',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'kitty_white.png'
        },
    },

    ['white_cats2'] = {
        label = 'White cats',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'kitty_white2.png'
        },
    },

    ['white_cats3'] = {
        label = 'White cats',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'kitty_white3.png'
        },
    },

    ['white_cats4'] = {
        label = 'White cats',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'kitty_white4.png'
        },
    },

    ['blue_cats'] = {
        label = 'blue cats',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'kitty_blue.png'
        },
    },

    ['blue_cats2'] = {
        label = 'blue cats',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'kitty_blue2.png'
        },
    },

    ['blue_cats3'] = {
        label = 'blue cats',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'kitty_blue3.png'
        },
    },

    ['blue_cats4'] = {
        label = 'blue cats',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'kitty_blue4.png'
        },
    },

    ['red_cats'] = {
        label = 'red cats',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'kitty_red.png'
        },
    },

    ['red_cats2'] = {
        label = 'red cats',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'kitty_red2.png'
        },
    },

    ['red_cats3'] = {
        label = 'red cats',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'kitty_red3.png'
        },
    },

    ['red_cats4'] = {
        label = 'red cats',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'kitty_red4.png'
        },
    },

    ['orange_cats'] = {
        label = 'orange cats',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'kitty_orange.png'
        },
    },

    ['orange_cats2'] = {
        label = 'orange cats',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'kitty_orange2.png'
        },
    },

    ['orange_cats3'] = {
        label = 'orange cats',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'kitty_orange3.png'
        },
    },

    ['orange_cats4'] = {
        label = 'orange cats',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'kitty_orange4.png'
        },
    },

    ['blue_uninflated_balloon'] = {
        label = 'Blue Uninflated Balloon',
        description = '',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'blue_uninflated_balloon.png'
        },
    },

    ['cracker'] = {
        label = 'Cracker',
        description = '',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'cracker.png'
        },
    },

    ['green_uninflated_balloon'] = {
        label = 'Green Uninflated Balloon',
        description = '',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'green_uninflated_balloon.png'
        },
    },

    ['orange_uninflated_balloon'] = {
        label = 'Orange Uninflated Balloon',
        description = '',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'orange_uninflated_balloon.png'
        },
    },

    ['purple_uninflated_balloon'] = {
        label = 'Purple Uninflated Balloon',
        description = '',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'purple_uninflated_balloon.png'
        },
    },

    ['red_uninflated_balloon'] = {
        label = 'Red Uninflated Balloon',
        description = '',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'red_uninflated_balloon.png'
        },
    },

    ['whipped_cream_cannister'] = {
        label = 'Whipped Cream Cannister',
        description = '',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'whipped_cream_cannister.png'
        },
    },

    ['white_uninflated_balloon'] = {
        label = 'White Uninflated Balloon',
        description = '',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'white_uninflated_balloon.png'
        },
    },

    ['yellow_uninflated_balloon'] = {
        label = 'Yellow Uninflated Balloon',
        description = '',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'yellow_uninflated_balloon.png'
        },
    },

    ['cardboard'] = {
        label = 'Cardboard Note',
        weight = 1,
        stack = false,
        close = true,
        description = 'A dirty piece of cardboard with something written on it.',
        consume = 0,
        client = {
            event = 'cardboard:read'
        },
    },

    ['cardboard-location'] = {
        label = 'Cardboard Note (Location)',
        weight = 1,
        stack = false,
        close = true,
        description = 'A dirty piece of cardboard with something written on it.',
        consume = 0,
        client = {
            event = 'cardboard:read'
        },
    },

    -- JG-Mechanic Items
    -- Servicing Items
    ['engine_oil'] = {
        label = 'Engine Oil',
        weight = 1000,
    },

    ['tyre_replacement'] = {
        label = 'Tyre Replacement',
        weight = 1000,
    },

    ['clutch_replacement'] = {
        label = 'Clutch Replacement',
        weight = 1000,
    },

    ['air_filter'] = {
        label = 'Air Filter',
        weight = 100,
    },

    ['spark_plug'] = {
        label = 'Spark Plug',
        weight = 1000,
    },

    ['brakepad_replacement'] = {
        label = 'Brakepad Replacement',
        weight = 1000,
    },

    ['suspension_parts'] = {
        label = 'Suspension Parts',
        weight = 1000,
    },

    -- Engine Items
    ['i4_engine'] = {
        label = 'I4 Engine',
        weight = 1000,
    },

    ['v6_engine'] = {
        label = 'V6 Engine',
        weight = 1000,
    },

    ['v8_engine'] = {
        label = 'V8 Engine',
        weight = 1000,
    },

    ['v12_engine'] = {
        label = 'V12 Engine',
        weight = 1000,
    },

    ['turbocharger'] = {
        label = 'Turbocharger',
        weight = 1000,
    },

    -- Electric Engine Items
    ['ev_motor'] = {
        label = 'EV Motor',
        weight = 1000,
    },

    ['ev_battery'] = {
        label = 'EV Battery',
        weight = 1000,
    },

    ['ev_coolant'] = {
        label = 'EV Coolant',
        weight = 1000,
    },

    -- Drivetrain Items
    ['awd_drivetrain'] = {
        label = 'AWD Drivetrain',
        weight = 1000,
    },

    ['rwd_drivetrain'] = {
        label = 'RWD Drivetrain',
        weight = 1000,
    },

    ['fwd_drivetrain'] = {
        label = 'FWD Drivetrain',
        weight = 1000,
    },

    -- Tuning Items
    ['slick_tyres'] = {
        label = 'Slick Tyres',
        weight = 1000,
    },

    ['semi_slick_tyres'] = {
        label = 'Semi Slick Tyres',
        weight = 1000,
    },

    ['offroad_tyres'] = {
        label = 'Offroad Tyres',
        weight = 1000,
    },

    ['drift_tuning_kit'] = {
        label = 'Drift Tuning Kit',
        weight = 1000,
    },

    ['ceramic_brakes'] = {
        label = 'Ceramic Brakes',
        weight = 1000,
    },

    -- Cosmetic Items
    ['lighting_controller'] = {
        label = 'Lighting Controller',
        weight = 100,
        client = {
            event = 'jg-mechanic:client:show-lighting-controller',
        },
    },

    ['stancing_kit'] = {
        label = 'Stancer Kit',
        weight = 100,
        client = {
            event = 'jg-mechanic:client:show-stancer-kit',
        },
    },

    ['cosmetic_part'] = {
        label = 'Cosmetic Parts',
        weight = 100,
    },

    ['respray_kit'] = {
        label = 'Respray Kit',
        weight = 1000,
    },

    ['vehicle_wheels'] = {
        label = 'Vehicle Wheels Set',
        weight = 1000,
    },

    ['tyre_smoke_kit'] = {
        label = 'Tyre Smoke Kit',
        weight = 1000,
    },

    ['bulletproof_tyres'] = {
        label = 'Bulletproof Tyres',
        weight = 1000,
    },

    ['extras_kit'] = {
        label = 'Extras Kit',
        weight = 1000,
    },

    -- Nitrous & Cleaning Items
    ['nitrous_bottle'] = {
        label = 'Nitrous Bottle',
        weight = 1000,
        client = {
            event = 'jg-mechanic:client:use-nitrous-bottle',
        },
    },

    ['empty_nitrous_bottle'] = {
        label = 'Empty Nitrous Bottle',
        weight = 1000,
    },

    ['nitrous_install_kit'] = {
        label = 'Nitrous Install Kit',
        weight = 1000,
    },

    ['cleaning_kit'] = {
        label = 'Cleaning Kit',
        weight = 1000,
        client = {
            event = 'jg-mechanic:client:clean-vehicle',
        },
    },

    ['repair_kit'] = {
        label = 'Repair Kit',
        weight = 1000,
        client = {
            event = 'jg-mechanic:client:repair-vehicle',
        },
    },

    ['duct_tape'] = {
        label = 'Duct Tape',
        weight = 1000,
        client = {
            event = 'jg-mechanic:client:use-duct-tape',
        },
    },

    -- Performance Item
    ['performance_part'] = {
        label = 'Performance Parts',
        weight = 1000,
    },

    -- Mechanic Tablet Item
    ['mechanic_tablet'] = {
        label = 'Mechanic Tablet',
        weight = 1000,
        client = {
            event = 'jg-mechanic:client:use-tablet',
        },
    },

    -- Gearbox
    ['manual_gearbox'] = {
        label = 'Manual Gearbox',
        weight = 1000,
    },

    -- BRZ Fishing Items
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

    -- Tiered Fishing Equipment
    ['fishingrod2'] = {
        label = 'Advanced Fishing Rod',
        consume = 0,
        stack = false,
        weight = 90,
        description = 'A better quality rod that makes fishing easier and increases rare catch chances',
        client = {
            image = 'fishingrod.png'
        }
    },
    ['fishingrod3'] = {
        label = 'Professional Fishing Rod',
        consume = 0,
        stack = false,
        weight = 100,
        description = 'Top-tier fishing rod for serious anglers. Significantly increases rare and legendary catch chances',
        client = {
            image = 'fishingrod.png'
        }
    },
    ['premiumbait'] = {
        label = 'Premium Bait',
        consume = 1,
        stack = true,
        weight = 8,
        description = 'High-quality bait that attracts rare and epic fish',
        client = {
            image = 'commonbait.png'
        }
    },
    ['legendarybait'] = {
        label = 'Legendary Bait',
        consume = 1,
        stack = true,
        weight = 10,
        description = 'The finest bait money can buy. Greatly increases your chance of catching legendary fish',
        client = {
            image = 'commonbait.png'
        }
    },

    -- Bait Types with Level Requirements
    ['bread'] = {
        label = 'Bread',
        weight = 10,
        stack = true,
        description = 'Basic bait. Requires River Level 1',
        client = {
            image = 'bread.png',
        },
        metadata = {
            fishing_area = 'river',
            required_level = 1,
        }
    },
    ['earthworm'] = {
        label = 'Earthworm',
        weight = 10,
        stack = true,
        description = 'Basic bait. Requires River Level 1',
        client = {
            image = 'earthworm.png',
        },
        metadata = {
            fishing_area = 'river',
            required_level = 1,
        }
    },
    ['dough'] = {
        label = 'Dough',
        weight = 10,
        stack = true,
        description = 'Intermediate bait. Requires River Level 3',
        client = {
            image = 'dough.png',
        },
        metadata = {
            fishing_area = 'river',
            required_level = 3,
        }
    },
    ['grub'] = {
        label = 'Grub',
        weight = 10,
        stack = true,
        description = 'Intermediate bait. Requires River Level 4',
        client = {
            image = 'grub.png',
        },
        metadata = {
            fishing_area = 'river',
            required_level = 4,
        }
    },
    ['caddis_fly'] = {
        label = 'Caddis Fly',
        weight = 10,
        stack = true,
        description = 'Advanced bait. Requires River Level 5',
        client = {
            image = 'caddis_fly.png',
        },
        metadata = {
            fishing_area = 'river',
            required_level = 5,
        }
    },
    ['cheese'] = {
        label = 'Cheese',
        weight = 10,
        stack = true,
        description = 'Basic bait. Requires Lake Level 1',
        client = {
            image = 'cheese.png',
        },
        metadata = {
            fishing_area = 'lake',
            required_level = 1,
        }
    },
    ['fly'] = {
        label = 'Fly',
        weight = 10,
        stack = true,
        description = 'Intermediate bait. Requires Lake Level 3',
        client = {
            image = 'fly.png',
        },
        metadata = {
            fishing_area = 'lake',
            required_level = 3,
        }
    },
    ['dragonfly'] = {
        label = 'Dragonfly',
        weight = 10,
        stack = true,
        description = 'Advanced bait. Requires Lake Level 6',
        client = {
            image = 'dragonfly.png',
        },
        metadata = {
            fishing_area = 'lake',
            required_level = 6,
        }
    },
    ['grasshoper'] = {
        label = 'Grasshoper',
        weight = 10,
        stack = true,
        description = 'Advanced bait. Requires Lake Level 7',
        client = {
            image = 'grasshoper.png',
        },
        metadata = {
            fishing_area = 'lake',
            required_level = 7,
        }
    },
    ['shrimp'] = {
        label = 'Shrimp',
        weight = 10,
        stack = true,
        description = 'Sea bait. Requires Sea Level 5',
        client = {
            image = 'shrimp.png',
        },
        metadata = {
            fishing_area = 'sea',
            required_level = 5,
        }
    },
    ['leech'] = {
        label = 'Leech',
        weight = 10,
        stack = true,
        description = 'Advanced bait. Requires River Level 7',
        client = {
            image = 'leech.png',
        },
        metadata = {
            fishing_area = 'river',
            required_level = 7,
        }
    },
    ['snail'] = {
        label = 'Snail',
        weight = 10,
        stack = true,
        description = 'Intermediate bait. Requires Lake Level 4',
        client = {
            image = 'snail.png',
        },
        metadata = {
            fishing_area = 'lake',
            required_level = 4,
        }
    },
    ['liver'] = {
        label = 'Liver',
        weight = 10,
        stack = true,
        description = 'Advanced bait. Requires Sea Level 8',
        client = {
            image = 'liver.png',
        },
        metadata = {
            fishing_area = 'sea',
            required_level = 8,
        }
    },

    -- Fishing Lines with Level Requirements
    ['express_fishing_super_line'] = {
        label = 'Express Super Line 0.1mm',
        weight = 70,
        stack = true,
        description = 'Ultra-thin line. Requires Level 1 in any area',
        client = {
            image = 'express_fishing_super_line.png',
        },
        metadata = {
            required_level = 1,
        }
    },
    ['syberia_indiana_green'] = {
        label = 'Indiana Green 0.14mm',
        weight = 70,
        stack = true,
        description = 'Thin line. Requires Level 2',
        client = {
            image = 'syberia_indiana_green.png',
        },
        metadata = {
            required_level = 2,
        }
    },
    ['syberia_indiana_white'] = {
        label = 'Indiana White 0.18mm',
        weight = 70,
        stack = true,
        description = 'Thin line. Requires Level 2',
        client = {
            image = 'syberia_indiana_white.png',
        },
        metadata = {
            required_level = 2,
        }
    },
    ['simmons_mono_original'] = {
        label = 'Simmons Original 0.25mm',
        weight = 70,
        stack = true,
        description = 'Standard line. Requires Level 3',
        client = {
            image = 'simmons_mono_original.png',
        },
        metadata = {
            required_level = 3,
        }
    },
    ['simmons_mono_ss'] = {
        label = 'Simmons SS 0.28mm',
        weight = 70,
        stack = true,
        description = 'Standard line. Requires Level 4',
        client = {
            image = 'simmons_mono_ss.png',
        },
        metadata = {
            required_level = 4,
        }
    },
    ['syberia_indiana_green_2'] = {
        label = 'Indiana Green 0.32mm',
        weight = 70,
        stack = true,
        description = 'Medium line. Requires Level 5',
        client = {
            image = 'syberia_indiana_green_2.png',
        },
        metadata = {
            required_level = 5,
        }
    },
    ['syberia_indiana_white_2'] = {
        label = 'Indiana White 0.36mm',
        weight = 70,
        stack = true,
        description = 'Medium line. Requires Level 5',
        client = {
            image = 'syberia_indiana_white_2.png',
        },
        metadata = {
            required_level = 5,
        }
    },
    ['snake_power_line_clr'] = {
        label = 'Snake Power Line 0.41mm',
        weight = 70,
        stack = true,
        description = 'Medium line. Requires Level 6',
        client = {
            image = 'snake_power_line_clr.png',
        },
        metadata = {
            required_level = 6,
        }
    },
    ['simmons_mono_original_2'] = {
        label = 'Simmons Original 0.48mm',
        weight = 70,
        stack = true,
        description = 'Heavy line. Requires Level 7',
        client = {
            image = 'simmons_mono_original_2.png',
        },
        metadata = {
            required_level = 7,
        }
    },
    ['simmons_mono_ss_2'] = {
        label = 'Simmons SS 0.52mm',
        weight = 70,
        stack = true,
        description = 'Heavy line. Requires Level 7',
        client = {
            image = 'simmons_mono_ss_2.png',
        },
        metadata = {
            required_level = 7,
        }
    },
    ['snake_power_line_clr_2'] = {
        label = 'Snake Power Line 0.65mm',
        weight = 70,
        stack = true,
        description = 'Extra heavy line. Requires Level 8',
        client = {
            image = 'snake_power_line_clr_2.png',
        },
        metadata = {
            required_level = 8,
        }
    },
    ['solid_hipower_nylon'] = {
        label = 'HiPower Nylon 0.8mm',
        weight = 70,
        stack = true,
        description = 'Ultra heavy line. Requires Level 9',
        client = {
            image = 'solid_hipower_nylon.png',
        },
        metadata = {
            required_level = 9,
        }
    },
    ['solid_hipower_nylon_lime'] = {
        label = 'HiPower Nylon L 0.85mm',
        weight = 70,
        stack = true,
        description = 'Ultra heavy line. Requires Level 9',
        client = {
            image = 'solid_hipower_nylon_lime.png',
        },
        metadata = {
            required_level = 9,
        }
    },
    ['solid_hipower_nylon_orange'] = {
        label = 'HiPower Nylon O 0.9mm',
        weight = 70,
        stack = true,
        description = 'Ultra heavy line. Requires Level 10',
        client = {
            image = 'solid_hipower_nylon_orange.png',
        },
        metadata = {
            required_level = 10,
        }
    },
    ['solid_hipower_nylon_2'] = {
        label = 'HiPower Nylon 1.05mm',
        weight = 70,
        stack = true,
        description = 'Maximum strength line. Requires Level 11',
        client = {
            image = 'solid_hipower_nylon_2.png',
        },
        metadata = {
            required_level = 11,
        }
    },
    ['solid_hipower_nylon_lime_2'] = {
        label = 'HiPower Nylon L 1.15mm',
        weight = 70,
        stack = true,
        description = 'Maximum strength line. Requires Level 12',
        client = {
            image = 'solid_hipower_nylon_lime_2.png',
        },
        metadata = {
            required_level = 12,
        }
    },
    ['solid_hipower_nylon_orange_2'] = {
        label = 'HiPower Nylon O 1.25mm',
        weight = 70,
        stack = true,
        description = 'Maximum strength line. Requires Level 13',
        client = {
            image = 'solid_hipower_nylon_orange_2.png',
        },
        metadata = {
            required_level = 13,
        }
    },

    -- Fishing Rods
    ['ufe_telerod_370'] = {
        label = 'UFE Telerod 370',
        weight = 150,
        stack = false,
        description = 'Professional fishing rod',
        client = {
            image = 'ufe_telerod_370.png',
        }
    },
    ['carptack_feeder_master_250'] = {
        label = 'Carptack Feeder Master 250',
        weight = 150,
        stack = false,
        description = 'Professional fishing rod',
        client = {
            image = 'carptack_feeder_master_250.png',
        }
    },
    ['sakura_tsubarea_tsa_552_xul'] = {
        label = 'Sakura Tsubarea TSA 552 XUL',
        weight = 150,
        stack = false,
        description = 'Professional fishing rod',
        client = {
            image = 'sakura_tsubarea_tsa_552_xul.png',
        }
    },
    ['carpex_hybid_carp_270'] = {
        label = 'Carpex Hybid Carp 270',
        weight = 150,
        stack = false,
        description = 'Professional fishing rod',
        client = {
            image = 'carpex_hybid_carp_270.png',
        }
    },
    ['ufe_float_x5_300'] = {
        label = 'UFE Float X5 300',
        weight = 150,
        stack = false,
        description = 'Professional fishing rod',
        client = {
            image = 'ufe_float_x5_300.png',
        }
    },
    ['predatek_fast_perch_210'] = {
        label = 'Predatek Fast Perch 210',
        weight = 150,
        stack = false,
        description = 'Professional fishing rod',
        client = {
            image = 'predatek_fast_perch_210.png',
        }
    },
    ['sakura_ionizer_bass_insb_701_ml'] = {
        label = 'Sakura Ionizer Bass INSB 701',
        weight = 150,
        stack = false,
        description = 'Professional fishing rod',
        client = {
            image = 'sakura_ionizer_bass_insb_701_ml.png',
        }
    },
    ['sakura_redbird_rds_602_l'] = {
        label = 'Sakura Redbird RDS 602 L',
        weight = 150,
        stack = false,
        description = 'Professional fishing rod',
        client = {
            image = 'sakura_redbird_rds_602_l.png',
        }
    },
    ['carpex_cobalt_carp_360'] = {
        label = 'Carpex Cobalt Carp 360',
        weight = 150,
        stack = false,
        description = 'Professional fishing rod',
        client = {
            image = 'carpex_cobalt_carp_360.png',
        }
    },
    ['sakura_salt_sniper_salss_611_mj1'] = {
        label = 'Sakura Salt Sniper SALSS 611',
        weight = 150,
        stack = false,
        description = 'Professional fishing rod',
        client = {
            image = 'sakura_salt_sniper_salss_611_mj1.png',
        }
    },
    ['sakura_speciz_spes_light_602_zander'] = {
        label = 'Sakura Speciz Spes Light 602',
        weight = 150,
        stack = false,
        description = 'Professional fishing rod',
        client = {
            image = 'sakura_speciz_spes_light_602_zander.png',
        }
    },
    ['sakura_redbird_rds_662'] = {
        label = 'Sakura Redbird RDS 662',
        weight = 150,
        stack = false,
        description = 'Professional fishing rod',
        client = {
            image = 'sakura_redbird_rds_662.png',
        }
    },
    ['sakura_salt_sniper_salss_902_h'] = {
        label = 'Sakura Salt Sniper SALSS 902',
        weight = 150,
        stack = false,
        description = 'Professional fishing rod',
        client = {
            image = 'sakura_salt_sniper_salss_902_h.png',
        }
    },
    ['predatek_seahunter_230'] = {
        label = 'Predatek Seahunter 230',
        weight = 150,
        stack = false,
        description = 'Professional fishing rod',
        client = {
            image = 'predatek_seahunter_230.png',
        }
    },
    ['sakura_shukan_shuc_661_lj'] = {
        label = 'Sakura Shukan Shuc 661 LJ',
        weight = 150,
        stack = false,
        description = 'Professional fishing rod',
        client = {
            image = 'sakura_shukan_shuc_661_lj.png',
        }
    },
    ['ufe_powercatch_270'] = {
        label = 'UFE Powercatch 270',
        weight = 150,
        stack = false,
        description = 'Professional fishing rod',
        client = {
            image = 'ufe_powercatch_270.png',
        }
    },
    ['predatek_pilk_200'] = {
        label = 'Predatek Pilk 200',
        weight = 150,
        stack = false,
        description = 'Professional fishing rod',
        client = {
            image = 'predatek_pilk_200.png',
        }
    },
    ['robinson_carbonic_nordic_pilk_300'] = {
        label = 'Robinson Carbonic Nordic Pilk',
        weight = 150,
        stack = false,
        description = 'Professional fishing rod',
        client = {
            image = 'robinson_carbonic_nordic_pilk_300.png',
        }
    },
    ['carptack_bottom_cast_360'] = {
        label = 'Carptack Bottom Cast 360',
        weight = 150,
        stack = false,
        description = 'Professional fishing rod',
        client = {
            image = 'carptack_bottom_cast_360.png',
        }
    },
    ['seax_salfighter_170'] = {
        label = 'Seax Salfighter 170',
        weight = 150,
        stack = false,
        description = 'Professional fishing rod',
        client = {
            image = 'seax_salfighter_170.png',
        }
    },

    -- Fishing Reels
    ['ufe_canta_1000'] = {
        label = 'UFE Canta 1000',
        weight = 100,
        stack = false,
        description = 'Fishing reel',
        client = {
            image = 'ufe_canta_1000.png',
        }
    },
    ['ufe_barracuda_2000bt'] = {
        label = 'UFE Barracuda 2000BT',
        weight = 100,
        stack = false,
        description = 'Fishing reel',
        client = {
            image = 'ufe_barracuda_2000bt.png',
        }
    },
    ['sakura_alpax_4508'] = {
        label = 'Sakura Alpax 4508',
        weight = 100,
        stack = false,
        description = 'Fishing reel',
        client = {
            image = 'sakura_alpax_4508.png',
        }
    },
    ['sakura_alpax_8508'] = {
        label = 'Sakura Alpax 8508',
        weight = 100,
        stack = false,
        description = 'Fishing reel',
        client = {
            image = 'sakura_alpax_8508.png',
        }
    },
    ['ufe_belona_4000'] = {
        label = 'UFE Belona 4000',
        weight = 100,
        stack = false,
        description = 'Fishing reel',
        client = {
            image = 'ufe_belona_4000.png',
        }
    },
    ['ufe_bigspin_8000b'] = {
        label = 'UFE Bigspin 8000B',
        weight = 100,
        stack = false,
        description = 'Fishing reel',
        client = {
            image = 'ufe_bigspin_8000b.png',
        }
    },
    ['ufe_batara_8000g'] = {
        label = 'UFE Batara 8000G',
        weight = 100,
        stack = false,
        description = 'Fishing reel',
        client = {
            image = 'ufe_batara_8000g.png',
        }
    },
    ['ufe_batara_1000r'] = {
        label = 'UFE Batara 1000R',
        weight = 100,
        stack = false,
        description = 'Fishing reel',
        client = {
            image = 'ufe_batara_1000r.png',
        }
    },
    ['robinson_big_runner_807qd'] = {
        label = 'Robinson Big Runner 807QD',
        weight = 100,
        stack = false,
        description = 'Fishing reel',
        client = {
            image = 'robinson_big_runner_807qd.png',
        }
    },
    ['spooler_catchpro_4000fd'] = {
        label = 'Spooler Catchpro 4000FD',
        weight = 100,
        stack = false,
        description = 'Fishing reel',
        client = {
            image = 'spooler_catchpro_4000fd.png',
        }
    },
    ['ufe_opensea_8000_x'] = {
        label = 'UFE Opensea 8000-X',
        weight = 100,
        stack = false,
        description = 'Fishing reel',
        client = {
            image = 'ufe_opensea_8000-x.png',
        }
    },
    ['spooler_catchpro_8000fd'] = {
        label = 'Spooler Catchpro 8000FD',
        weight = 100,
        stack = false,
        description = 'Fishing reel',
        client = {
            image = 'spooler_catchpro_8000fd.png',
        }
    },
    ['spooler_catchpro_14000fd'] = {
        label = 'Spooler Catchpro 14000FD',
        weight = 100,
        stack = false,
        description = 'Fishing reel',
        client = {
            image = 'spooler_catchpro_14000fd.png',
        }
    },

    -- Fishing Hooks
    ['ufa_bait_hook'] = {
        label = 'UFA Bait',
        weight = 40,
        stack = true,
        description = 'Fishing hook',
        client = {
            image = 'ufa_bait_hook.png',
        }
    },
    ['ufa_sproat_hook'] = {
        label = 'UFA Sproat',
        weight = 40,
        stack = true,
        description = 'Fishing hook',
        client = {
            image = 'ufa_sproat_hook.png',
        }
    },
    ['captack_claw_xl_hook'] = {
        label = 'Captack Claw XL',
        weight = 40,
        stack = true,
        description = 'Fishing hook',
        client = {
            image = 'captack_claw_xl_hook.png',
        }
    },
    ['ufa_sproat_g_hook'] = {
        label = 'UFA Sproat-G',
        weight = 40,
        stack = true,
        description = 'Fishing hook',
        client = {
            image = 'ufa_sproat_g_hook.png',
        }
    },
    ['carptack_carp_ss_hook'] = {
        label = 'Carptack Carp S&S',
        weight = 40,
        stack = true,
        description = 'Fishing hook',
        client = {
            image = 'carptack_carp_ss_hook.png',
        }
    },
    ['ufa_wide_gap_bl_hook'] = {
        label = 'UFA Wide Gap BL',
        weight = 40,
        stack = true,
        description = 'Fishing hook',
        client = {
            image = 'ufa_wide_gap_bl_hook.png',
        }
    },
    ['ufa_aberdeen_hook'] = {
        label = 'UFA Aberdeen',
        weight = 40,
        stack = true,
        description = 'Fishing hook',
        client = {
            image = 'ufa_aberdeen_hook.png',
        }
    },
    ['ufa_octopus_bl_hook'] = {
        label = 'UFA Octopus BL',
        weight = 40,
        stack = true,
        description = 'Fishing hook',
        client = {
            image = 'ufa_octopus_bl_hook.png',
        }
    },
    ['ufa_livebait_hook'] = {
        label = 'UFA Livebait',
        weight = 40,
        stack = true,
        description = 'Fishing hook',
        client = {
            image = 'ufa_livebait_hook.png',
        }
    },
    ['carptack_micro_barb_hook'] = {
        label = 'Carptack Micro Barb',
        weight = 40,
        stack = true,
        description = 'Fishing hook',
        client = {
            image = 'carptack_micro_barb_hook.png',
        }
    },
    ['carptack_carp_hook'] = {
        label = 'Carptack Carp',
        weight = 40,
        stack = true,
        description = 'Fishing hook',
        client = {
            image = 'carptack_carp_hook.png',
        }
    },
    ['ufa_fusion_bl_hook'] = {
        label = 'UFA Fusion BL',
        weight = 40,
        stack = true,
        description = 'Fishing hook',
        client = {
            image = 'ufa_fusion_bl_hook.png',
        }
    },
    ['predatek_octopus_hook'] = {
        label = 'Predatek Octopus',
        weight = 40,
        stack = true,
        description = 'Fishing hook',
        client = {
            image = 'predatek_octopus_hook.png',
        }
    },
    ['predatek_fusion_hook'] = {
        label = 'Predatek Fusion',
        weight = 40,
        stack = true,
        description = 'Fishing hook',
        client = {
            image = 'predatek_fusion_hook.png',
        }
    },

    -- Scuba Gear
    ['scuba'] = {
        label = 'Scuba gear',
        weight = 300,
        stack = false,
        description = 'Scuba gear for underwater diving',
        client = {
            image = 'scuba.png',
        }
    },

    -- River Fish
    ['alligator_gar'] = {
        label = 'Alligator Gar',
        weight = 550,
        stack = true,
        description = 'An alligator gar fish. Found in rivers.',
        client = {
            image = 'alligator_gar.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['amur_pike'] = {
        label = 'Amur Pike',
        weight = 750,
        stack = true,
        description = 'An Amur Pike fish. Found in rivers.',
        client = {
            image = 'amur_pike.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['barbel'] = {
        label = 'Barbel',
        weight = 600,
        stack = true,
        description = 'A Barbel fish. Found in rivers.',
        client = {
            image = 'barbel.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['brook_trout'] = {
        label = 'Brook Trout',
        weight = 700,
        stack = true,
        description = 'A Brook Trout fish. Found in rivers.',
        client = {
            image = 'brook_trout.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['brown_trout'] = {
        label = 'Brown Trout',
        weight = 230,
        stack = true,
        description = 'A Brown Trout fish. Found in rivers.',
        client = {
            image = 'brown_trout.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['bull_trout'] = {
        label = 'Bull Trout',
        weight = 200,
        stack = true,
        description = 'A Bull Trout fish. Found in rivers.',
        client = {
            image = 'bull_trout.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['chub'] = {
        label = 'Chub',
        weight = 150,
        stack = true,
        description = 'A Chub fish. Found in rivers.',
        client = {
            image = 'chub.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['chum_salmon'] = {
        label = 'Chum Salmon',
        weight = 600,
        stack = true,
        description = 'A Chum Salmon fish. Found in rivers.',
        client = {
            image = 'chum_salmon.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['coho_salmon'] = {
        label = 'Coho Salmon',
        weight = 500,
        stack = true,
        description = 'A Coho Salmon fish. Found in rivers.',
        client = {
            image = 'coho_salmon.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['common_bleak'] = {
        label = 'Common Bleak',
        weight = 10,
        stack = true,
        description = 'A Common Bleak fish. Found in rivers.',
        client = {
            image = 'common_bleak.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['common_bream'] = {
        label = 'Common Bream',
        weight = 400,
        stack = true,
        description = 'A Common Bream fish. Found in rivers.',
        client = {
            image = 'common_bream.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['common_carp'] = {
        label = 'Common Carp',
        weight = 700,
        stack = true,
        description = 'A Common Carp fish. Found in rivers.',
        client = {
            image = 'common_carp.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['crucian_carp'] = {
        label = 'Crucian Carp',
        weight = 140,
        stack = true,
        description = 'A Crucian Carp fish. Found in rivers.',
        client = {
            image = 'crucian_carp.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['european_eel'] = {
        label = 'European Eel',
        weight = 300,
        stack = true,
        description = 'A European Eel fish. Found in rivers.',
        client = {
            image = 'european_eel.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['grayling'] = {
        label = 'Grayling',
        weight = 80,
        stack = true,
        description = 'A Grayling fish. Found in rivers.',
        client = {
            image = 'grayling.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['huchen'] = {
        label = 'Huchen',
        weight = 1500,
        stack = true,
        description = 'A Huchen fish. Found in rivers.',
        client = {
            image = 'huchen.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['ide'] = {
        label = 'Ide',
        weight = 100,
        stack = true,
        description = 'An Ide fish. Found in rivers.',
        client = {
            image = 'ide.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['lake_sturgeon'] = {
        label = 'Lake Sturgeon',
        weight = 1600,
        stack = true,
        description = 'A Lake Sturgeon fish. Found in rivers and lakes.',
        client = {
            image = 'lake_sturgeon.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['largemouth_bass'] = {
        label = 'Largemouth Bass',
        weight = 100,
        stack = true,
        description = 'A Largemouth Bass fish. Found in rivers and lakes.',
        client = {
            image = 'largemouth_bass.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['mirror_carp'] = {
        label = 'Mirror Carp',
        weight = 700,
        stack = true,
        description = 'A Mirror Carp fish. Found in rivers.',
        client = {
            image = 'mirror_carp.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['northern_pike'] = {
        label = 'Northern Pike',
        weight = 500,
        stack = true,
        description = 'A Northern Pike fish. Found in rivers and lakes.',
        client = {
            image = 'northern_pike.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['pink_salmon'] = {
        label = 'Pink Salmon',
        weight = 200,
        stack = true,
        description = 'A Pink Salmon fish. Found in rivers.',
        client = {
            image = 'pink_salmon.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['prussian_carp'] = {
        label = 'Prussian Carp',
        weight = 90,
        stack = true,
        description = 'A Prussian Carp fish. Found in rivers.',
        client = {
            image = 'prussian_carp.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['rainbow_trout'] = {
        label = 'Rainbow Trout',
        weight = 100,
        stack = true,
        description = 'A Rainbow Trout fish. Found in rivers and lakes.',
        client = {
            image = 'rainbow_trout.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['roach'] = {
        label = 'Roach',
        weight = 50,
        stack = true,
        description = 'A Roach fish. Found in rivers.',
        client = {
            image = 'roach.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['silver_carp'] = {
        label = 'Silver Carp',
        weight = 1000,
        stack = true,
        description = 'A Silver Carp fish. Found in rivers.',
        client = {
            image = 'silver_carp.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['smallmouth_bass'] = {
        label = 'Smallmouth Bass',
        weight = 150,
        stack = true,
        description = 'A Smallmouth Bass fish. Found in rivers and lakes.',
        client = {
            image = 'smallmouth_bass.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['tench'] = {
        label = 'Tench',
        weight = 250,
        stack = true,
        description = 'A Tench fish. Found in rivers.',
        client = {
            image = 'tench.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['white_sturgeon'] = {
        label = 'White Sturgeon',
        weight = 800,
        stack = true,
        description = 'A White Sturgeon fish. Found in rivers.',
        client = {
            image = 'white_sturgeon.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['yellow_perch'] = {
        label = 'Yellow Perch',
        weight = 40,
        stack = true,
        description = 'A Yellow Perch fish. Found in rivers and lakes.',
        client = {
            image = 'yellow_perch.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['zander'] = {
        label = 'Zander',
        weight = 200,
        stack = true,
        description = 'A Zander fish. Found in rivers.',
        client = {
            image = 'zander.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['black_grayling'] = {
        label = 'Black Grayling',
        weight = 120,
        stack = true,
        description = 'A Black Grayling fish. Found in rivers.',
        client = {
            image = 'black_grayling.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['grass_carp'] = {
        label = 'Grass Carp',
        weight = 120,
        stack = true,
        description = 'A Grass Carp fish. Found in rivers.',
        client = {
            image = 'grass_carp.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['grass_pickerel'] = {
        label = 'Grass Pickerel',
        weight = 90,
        stack = true,
        description = 'A Grass Pickerel fish. Found in rivers.',
        client = {
            image = 'grass_pickerel.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['redfin_pickerel'] = {
        label = 'Redfin Pickerel',
        weight = 40,
        stack = true,
        description = 'A Redfin Pickerel fish. Found in rivers.',
        client = {
            image = 'redfin_pickerel.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['wels_catfish'] = {
        label = 'Wels Catfish',
        weight = 400,
        stack = true,
        description = 'A Wels Catfish fish. Found in rivers.',
        client = {
            image = 'wels_catfish.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['beluga_sturgeon'] = {
        label = 'Beluga Sturgeon',
        weight = 264,
        stack = true,
        description = 'A Beluga Sturgeon fish. Found in rivers.',
        client = {
            image = 'beluga_sturgeon.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['giant_freshwater_stingray'] = {
        label = 'Giant Freshwater Stingray',
        weight = 350,
        stack = true,
        description = 'A Giant Freshwater Stingray. Found in rivers.',
        client = {
            image = 'giant_freshwater_stingray.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['pink_river_dolphin'] = {
        label = 'Pink River Dolphin',
        weight = 1550,
        stack = true,
        description = 'A Pink River Dolphin. Found in rivers.',
        client = {
            image = 'pink_river_dolphin.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['pufferfish'] = {
        label = 'Pufferfish',
        weight = 150,
        stack = true,
        description = 'A Pufferfish. Found in rivers and lakes.',
        client = {
            image = 'pufferfish.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['pumpkinseed'] = {
        label = 'Pumpkinseed',
        weight = 40,
        stack = true,
        description = 'A Pumpkinseed fish. Found in rivers and lakes.',
        client = {
            image = 'pumpkinseed.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['bluegill'] = {
        label = 'Bluegill',
        weight = 120,
        stack = true,
        description = 'A Bluegill fish. Found in rivers and lakes.',
        client = {
            image = 'bluegill.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['golden_trout'] = {
        label = 'Golden Trout',
        weight = 40,
        stack = true,
        description = 'A Golden Trout fish. Found in rivers.',
        client = {
            image = 'golden_trout.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['sockeye_salmon'] = {
        label = 'Sockeye Salmon',
        weight = 300,
        stack = true,
        description = 'A Sockeye Salmon fish. Found in rivers.',
        client = {
            image = 'sockeye_salmon.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },
    ['skeleton'] = {
        label = 'Skeleton',
        weight = 10,
        stack = true,
        description = 'A Skeleton. Rare find in rivers.',
        client = {
            image = 'skeleton.png',
        },
        metadata = {
            fishing_area = 'river',
        }
    },

    -- Sea Fish
    ['atlantic_cod'] = {
        label = 'Atlantic Cod',
        weight = 200,
        stack = true,
        description = 'An Atlantic Cod fish. Found in sea.',
        client = {
            image = 'atlantic_cod.png',
        },
        metadata = {
            fishing_area = 'sea',
        }
    },
    ['atlantic_salmon'] = {
        label = 'Atlantic Salmon',
        weight = 300,
        stack = true,
        description = 'An Atlantic Salmon fish. Found in sea.',
        client = {
            image = 'atlantic_salmon.png',
        },
        metadata = {
            fishing_area = 'sea',
        }
    },
    ['blacktip_reef_shark'] = {
        label = 'Blacktip Reef Shark',
        weight = 800,
        stack = true,
        description = 'A Blacktip Reef Shark. Found in sea.',
        client = {
            image = 'blacktip_reef_shark.png',
        },
        metadata = {
            fishing_area = 'sea',
        }
    },
    ['blue_marlin'] = {
        label = 'Blue Marlin',
        weight = 2000,
        stack = true,
        description = 'A Blue Marlin fish. Found in sea.',
        client = {
            image = 'blue_marlin.png',
        },
        metadata = {
            fishing_area = 'sea',
        }
    },
    ['bluefin_tuna'] = {
        label = 'Bluefin Tuna',
        weight = 1500,
        stack = true,
        description = 'A Bluefin Tuna fish. Found in sea.',
        client = {
            image = 'bluefin_tuna.png',
        },
        metadata = {
            fishing_area = 'sea',
        }
    },
    ['european_bass'] = {
        label = 'European Bass',
        weight = 200,
        stack = true,
        description = 'A European Bass fish. Found in sea.',
        client = {
            image = 'european_bass.png',
        },
        metadata = {
            fishing_area = 'sea',
        }
    },
    ['european_flounder'] = {
        label = 'European Flounder',
        weight = 100,
        stack = true,
        description = 'A European Flounder fish. Found in sea.',
        client = {
            image = 'european_flounder.png',
        },
        metadata = {
            fishing_area = 'sea',
        }
    },
    ['european_perch'] = {
        label = 'European Perch',
        weight = 50,
        stack = true,
        description = 'A European Perch fish. Found in sea.',
        client = {
            image = 'european_perch.png',
        },
        metadata = {
            fishing_area = 'sea',
        }
    },
    ['european_sea_sturgeon'] = {
        label = 'European Sea Sturgeon',
        weight = 1800,
        stack = true,
        description = 'A European Sea Sturgeon fish. Found in sea.',
        client = {
            image = 'european_sea_sturgeon.png',
        },
        metadata = {
            fishing_area = 'sea',
        }
    },
    ['garfish'] = {
        label = 'Garfish',
        weight = 80,
        stack = true,
        description = 'A Garfish. Found in sea.',
        client = {
            image = 'garfish.png',
        },
        metadata = {
            fishing_area = 'sea',
        }
    },
    ['giant_grouper'] = {
        label = 'Giant Grouper',
        weight = 1200,
        stack = true,
        description = 'A Giant Grouper fish. Found in sea.',
        client = {
            image = 'giant_grouper.png',
        },
        metadata = {
            fishing_area = 'sea',
        }
    },
    ['giant_trevally'] = {
        label = 'Giant Trevally',
        weight = 600,
        stack = true,
        description = 'A Giant Trevally fish. Found in sea.',
        client = {
            image = 'giant_trevally.png',
        },
        metadata = {
            fishing_area = 'sea',
        }
    },
    ['great_barracuda'] = {
        label = 'Great Barracuda',
        weight = 500,
        stack = true,
        description = 'A Great Barracuda fish. Found in sea.',
        client = {
            image = 'great_barracuda.png',
        },
        metadata = {
            fishing_area = 'sea',
        }
    },
    ['grey_snapper'] = {
        label = 'Grey Snapper',
        weight = 150,
        stack = true,
        description = 'A Grey Snapper fish. Found in sea.',
        client = {
            image = 'grey_snapper.png',
        },
        metadata = {
            fishing_area = 'sea',
        }
    },
    ['indian_threadfish'] = {
        label = 'Indian Threadfish',
        weight = 400,
        stack = true,
        description = 'An Indian Threadfish. Found in sea.',
        client = {
            image = 'indian_threadfish.png',
        },
        metadata = {
            fishing_area = 'sea',
        }
    },
    ['mahi_mahi'] = {
        label = 'Mahi Mahi',
        weight = 300,
        stack = true,
        description = 'A Mahi Mahi fish. Found in sea.',
        client = {
            image = 'mahi_mahi.png',
        },
        metadata = {
            fishing_area = 'sea',
        }
    },
    ['malabar_grouper'] = {
        label = 'Malabar Grouper',
        weight = 1000,
        stack = true,
        description = 'A Malabar Grouper fish. Found in sea.',
        client = {
            image = 'malabar_grouper.png',
        },
        metadata = {
            fishing_area = 'sea',
        }
    },
    ['red_lionfish'] = {
        label = 'Red Lionfish',
        weight = 200,
        stack = true,
        description = 'A Red Lionfish. Found in sea.',
        client = {
            image = 'red_lionfish.png',
        },
        metadata = {
            fishing_area = 'sea',
        }
    },
    ['sea_trout'] = {
        label = 'Sea Trout',
        weight = 250,
        stack = true,
        description = 'A Sea Trout fish. Found in sea.',
        client = {
            image = 'sea_trout.png',
        },
        metadata = {
            fishing_area = 'sea',
        }
    },
    ['yellowfin_tuna'] = {
        label = 'Yellowfin Tuna',
        weight = 1300,
        stack = true,
        description = 'A Yellowfin Tuna fish. Found in sea.',
        client = {
            image = 'yellowfin_tuna.png',
        },
        metadata = {
            fishing_area = 'sea',
        }
    },
    ['yellowtail_barracuda'] = {
        label = 'Yellowtail Barracuda',
        weight = 400,
        stack = true,
        description = 'A Yellowtail Barracuda fish. Found in sea.',
        client = {
            image = 'yellowtail_barracuda.png',
        },
        metadata = {
            fishing_area = 'sea',
        }
    },

    -- Illegal Fish (all areas, higher risk)
    ['paddlefish'] = {
        label = 'Paddlefish',
        weight = 500,
        stack = true,
        description = 'An illegal Paddlefish. High risk catch.',
        client = {
            image = 'paddlefish.png',
        },
        metadata = {
            fishing_area = 'all',
            illegal = true,
        }
    },
    ['sawfish'] = {
        label = 'Sawfish',
        weight = 600,
        stack = true,
        description = 'An illegal Sawfish. High risk catch.',
        client = {
            image = 'sawfish.png',
        },
        metadata = {
            fishing_area = 'all',
            illegal = true,
        }
    },
    ['eel'] = {
        label = 'Eel',
        weight = 200,
        stack = true,
        description = 'An illegal Eel. High risk catch.',
        client = {
            image = 'eel.png',
        },
        metadata = {
            fishing_area = 'all',
            illegal = true,
        }
    },
    ['hammerheadshark'] = {
        label = 'Hammerhead Shark',
        weight = 1000,
        stack = true,
        description = 'An illegal Hammerhead Shark. High risk catch.',
        client = {
            image = 'hammerheadshark.png',
        },
        metadata = {
            fishing_area = 'all',
            illegal = true,
        }
    },
    ['seaturtle'] = {
        label = 'Sea Turtle',
        weight = 800,
        stack = true,
        description = 'An illegal Sea Turtle. High risk catch.',
        client = {
            image = 'seaturtle.png',
        },
        metadata = {
            fishing_area = 'all',
            illegal = true,
        }
    },
    ['leopardshark'] = {
        label = 'Leopard Shark',
        weight = 700,
        stack = true,
        description = 'An illegal Leopard Shark. High risk catch.',
        client = {
            image = 'leopardshark.png',
        },
        metadata = {
            fishing_area = 'all',
            illegal = true,
        }
    },
    ['blueshark'] = {
        label = 'Blue Shark',
        weight = 900,
        stack = true,
        description = 'An illegal Blue Shark. High risk catch.',
        client = {
            image = 'blueshark.png',
        },
        metadata = {
            fishing_area = 'all',
            illegal = true,
        }
    },
    ['greatwhiteshark'] = {
        label = 'Great White Shark',
        weight = 2000,
        stack = true,
        description = 'An illegal Great White Shark. High risk catch.',
        client = {
            image = 'greatwhiteshark.png',
        },
        metadata = {
            fishing_area = 'all',
            illegal = true,
        }
    },

    -- Diving Items
    ['diving_mask'] = {
        label = 'Diving Mask',
        weight = 50,
        stack = false,
        description = 'A diving mask for underwater exploration',
        client = {
            image = 'diving_mask.png',
        }
    },
    ['diving_fins'] = {
        label = 'Diving Fins',
        weight = 100,
        stack = false,
        description = 'Diving fins for underwater swimming',
        client = {
            image = 'diving_fins.png',
        }
    },
    ['diving_tank'] = {
        label = 'Diving Tank',
        weight = 200,
        stack = false,
        description = 'Oxygen tank for extended diving',
        client = {
            image = 'diving_tank.png',
        }
    },
    ['underwater_camera'] = {
        label = 'Underwater Camera',
        weight = 150,
        stack = false,
        description = 'Camera for underwater photography',
        client = {
            image = 'underwater_camera.png',
        }
    },
    ['treasure_chest'] = {
        label = 'Treasure Chest',
        weight = 500,
        stack = false,
        description = 'A treasure chest found underwater',
        client = {
            image = 'treasure_chest.png',
        }
    },
    ['pearl'] = {
        label = 'Pearl',
        weight = 10,
        stack = true,
        description = 'A valuable pearl found underwater',
        client = {
            image = 'pearl.png',
        }
    },
    ['coral'] = {
        label = 'Coral',
        weight = 50,
        stack = true,
        description = 'Coral found underwater',
        client = {
            image = 'coral.png',
        }
    },
    -- LB Tablet Item
['tablet'] = {
    label = 'Tablet',
    weight = 500,
    stack = false,
    close = false,
    client = {
        image = 'inventoryitem.png',
    }
},
}
