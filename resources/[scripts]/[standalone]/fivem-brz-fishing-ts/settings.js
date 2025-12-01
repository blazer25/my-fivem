const SETTINGS = {
  INVENTORY_SYSTEM: "ox_inventory", // OPTIONS: esx_inventory, ox_inventory or qbCore
  NOTIFICATION_SYSTEM: "oxLib", // oxLib or qbCore or esx
  DEFAULT_LANG: "en-us",
  MAXIMUM_LINE_TENSION: 100,
  LINE_TENSION_INCREASE_RATE: 5,
  TENSION_RECOVER_RATE: 1,
  PULL_DISTANCE_RATE_PER_TICK: 10,
  ROD_CAST_CHALLENGE_VELOCITY: 1,
  ROD_CAST_CHALLENGE_INTERVAL: 1,
  ROD_CAST_CHALLENGE_ACCELERATION: 0.0001,
  BAIT_HOLD_CHALLENGE_TIME: 500,
  DYNAMIC_MINIGAME_POSITION: true,
  // Catch rate percentages by rarity
  CATCH_RATES: {
    common: 60,      // 60% chance
    uncommon: 25,    // 25% chance
    rare: 10,        // 10% chance
    epic: 4,         // 4% chance
    legendary: 1,    // 1% chance
  },
  
  // XP requirements per level (same for all areas, or can be customized)
  XP_PER_LEVEL: {
    1: 0,      // Starting level
    2: 100,    // 100 XP to reach level 2
    3: 250,    // 250 XP to reach level 3
    4: 450,    // 450 XP to reach level 4
    5: 700,    // 700 XP to reach level 5
    6: 1000,   // 1000 XP to reach level 6
    7: 1400,   // 1400 XP to reach level 7
    8: 1900,   // 1900 XP to reach level 8
    9: 2500,   // 2500 XP to reach level 9
    10: 3200,  // 3200 XP to reach level 10
    11: 4000,  // 4000 XP to reach level 11
    12: 5000,  // 5000 XP to reach level 12
    13: 6200,  // 6200 XP to reach level 13
    14: 7600,  // 7600 XP to reach level 14
    15: 9200,  // 9200 XP to reach level 15
  },
  
  // XP awarded per catch based on rarity
  XP_PER_CATCH: {
    common: 10,      // Common fish = 10 XP
    uncommon: 25,    // Uncommon = 25 XP
    rare: 50,        // Rare = 50 XP
    epic: 100,       // Epic = 100 XP
    legendary: 250,  // Legendary = 250 XP
  },
  
  // Area multipliers (Sea gives more XP per catch)
  AREA_XP_MULTIPLIER: {
    river: 1.0,   // River = base XP
    lake: 1.2,    // Lake = 20% bonus
    sea: 1.5,     // Sea = 50% bonus (harder)
  },
  
  // Fishing area zones (coordinates for River, Lake, Sea)
  FISHING_AREAS: {
    river: [
      { coords: [0, 0, 0], radius: 50 }, // Will be populated with actual river coordinates
    ],
    lake: [
      { coords: [0, 0, 0], radius: 50 }, // Will be populated with actual lake coordinates
    ],
    sea: [
      { coords: [-3500.0, -1000.0, 1.0], radius: 200 }, // Deep sea areas
      { coords: [-2000.0, 6000.0, 1.0], radius: 200 },
    ],
  },
  FISHES: {
    fish: {
      itemName: "fish",
      type: "common",
      hash: 802685111,
    },
    dolphin: {
      itemName: "dolphin",
      type: "uncommon",
      hash: -1950698411,
    },
    hammerShark: {
      itemName: "hammershark",
      type: "uncommon",
      hash: 1015224100,
    },
    tigerShark: {
      itemName: "tigershark",
      type: "rare",
      hash: 113504370,
    },
    killerWhale: {
      itemName: "killerwhale",
      type: "epic",
      hash: -1920284487,
    },
    humpBack: {
      itemName: "humpback",
      type: "legendary",
      hash: 1193010354,
    },
    stingray: {
      itemName: "stingray",
      type: "rare",
      hash: "a_c_stingray",
    },
  },
  
  // Fish by Area (for area-specific fishing) - simplified to original fish set
  FISHES_BY_AREA: {
    river: [
      'fish'
    ],
    lake: [
      'fish'
    ],
    sea: [
      'fish', 'dolphin', 'hammershark', 'tigershark', 'stingray', 'killerwhale', 'humpback'
    ],
    all: [
      'fish', 'dolphin', 'hammershark', 'tigershark', 'stingray', 'killerwhale', 'humpback'
    ]
  },
};

const LOCALE_OVERRIDES = {
  // "en-us": {
  //   fish_pull_hint: "My custom hint",
  // },
};

if (typeof exports !== "undefined") {
  exports("SETTINGS", SETTINGS);
  exports("LOCALE_OVERRIDES", LOCALE_OVERRIDES);
}

if (typeof window !== "undefined") {
  window.SETTINGS = SETTINGS;
  window.LOCALE_OVERRIDES = LOCALE_OVERRIDES;
}
