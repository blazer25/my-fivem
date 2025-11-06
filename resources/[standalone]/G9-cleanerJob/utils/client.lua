G9Series = {}

function G9Series:getPlayerName() 
    if framework then
        return core.Functions.GetPlayerData().charinfo.firstname .. ' ' .. core.Functions.GetPlayerData().charinfo.lastname
    elseif not framework then
        return core.GetPlayerData().name
    else
        return nil
    end
end