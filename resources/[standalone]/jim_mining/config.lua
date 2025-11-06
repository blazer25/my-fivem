Config = {}

Config.Debug = false
Config.img = "nui://ox_inventory/web/images/"

-- Do you need a job to mine?
Config.RequireJob = true
Config.JobName = "miner"

-- Stone cracking and washing times (in ms)
Config.WashTime = 8000
Config.CrackTime = 8000

-- Crafting recipes (for the jewel bench)
Config.Crafting = {
    ['gold_ring'] = { ['goldbar'] = 1 },
    ['silver_ring'] = { ['silverbar'] = 1 },
    ['diamond_ring'] = { ['goldbar'] = 1, ['cut_diamond'] = 1 },
}

-- Items that can come from mining
Config.MineRewards = {
    { item = "stone", chance = 100 },
    { item = "ironore", chance = 40 },
    { item = "copperore", chance = 35 },
    { item = "goldore", chance = 15 },
    { item = "uncut_diamond", chance = 5 },
}

-- Items that can come from washing stones
Config.WashRewards = {
    { item = "ironore", chance = 25 },
    { item = "silverore", chance = 20 },
    { item = "uncut_emerald", chance = 10 },
    { item = "trash", chance = 45 },
}

-- Items from gold panning
Config.PanRewards = {
    { item = "goldore", chance = 10 },
    { item = "silverore", chance = 15 },
    { item = "trash", chance = 75 },
}
