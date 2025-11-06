lib.callback.register('g9:getCleaner', function(source)
    local src = source
    local player = G9Series:getPlayer(src)
    local identifier = G9Series:getIdentifier(player)
    local data =MySQL.Sync.fetchAll('SELECT identifier, level, xp FROM g9_cleaner WHERE identifier = ?', { identifier })
    if data[1] then
        return {
            level = data[1].level,
            xp = data[1].xp
        }
    else
        MySQL.Async.execute('INSERT INTO g9_cleaner (identifier,level,xp) VALUES (@identifier, @level, @xp)', {
            ['@identifier'] = identifier,
            ['@level'] = 1,
            ['@xp'] = 0
        })
        Wait(1000)
        local ndata = MySQL.Sync.fetchAll('SELECT identifier, level, xp FROM g9_cleaner WHERE identifier = ?', { identifier })
        return {
            level = ndata[1].level,
            xp = ndata[1].xp
        }

    end
end)

lib.callback.register('g9:addXpMoney', function(source, data)
    local src = source
    local player = G9Series:getPlayer(src)
    local identifier = G9Series:getIdentifier(player)

    local result = MySQL.Sync.fetchAll('SELECT level, xp FROM g9_cleaner WHERE identifier = ?', { identifier })

    if result and result[1] then
        local currentXp = result[1].xp
        local newXp = currentXp + data.xp
        local nextLevel = result[1].level
        local reqXp = jobs.jobSettings["levelSettings"][nextLevel].nextLevel
        if newXp >= reqXp then
            local newLevel = jobs.jobSettings["levelSettings"][nextLevel].level + 1
            MySQL.Sync.execute('UPDATE g9_cleaner SET xp = ? WHERE identifier = ?', { newXp, identifier })
            MySQL.Sync.execute('UPDATE g9_cleaner SET level = ? WHERE identifier = ?', { newLevel, identifier })
            G9Series:addMoney(src, 'bank', data.money)
            return 'levelUp'
        else
            MySQL.Sync.execute('UPDATE g9_cleaner SET xp = ? WHERE identifier = ?', { newXp, identifier })
            G9Series:addMoney(src, 'bank', data.money)
        end
    end

    

    return true
end)


lib.callback.register('g9:fine', function(source) 
    local src = source
    local player = G9Series:getPlayer(src)
    G9Series:removeMoney(src, 'bank', cfg.carFine)
end)
