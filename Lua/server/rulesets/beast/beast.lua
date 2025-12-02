local rs = {}

rs.Name = "Beast"

-- Chance to be drafted as either primary or secondary
rs.Chance = 7

rs.Enabled = true

-- key = client, value = {[1] = "role name", [2] = {special table for role functionality}}
rs.SelectedPlayers = {}

rs.Strength = 0

rs.AntagName = "Beast"

rs.FailReason = ""







function rs.Reset()
    rs.SelectedPlayers = {}
    rs.Strength = 0
end

function rs.RoleHelp(client)
    return false, ""
end

function rs.Check()
    if rs.Strength >= 10 or not Game.RoundStarted then return false end
    -- Can't be drafted if ANY other ruleset has been drafted this round
    for ruleSet in Megamod.RuleSetManager.RuleSets do
        if ruleSet.Strength > 0 or ruleSet.FailReason ~= "" then
            return false
        end
    end
    return true
end

function rs.CheckShouldFail()
    return false, ""
end

-- Temporary do-it-yourself solution until this ruleset is actually implemented
function rs.Draft()
    for client in Client.ClientList do
        if Megamod.CertifiedBeasters[client.SteamID] and Megamod.GetData(client, "Beast") then
            local text = "| You sense the darkness growing stronger. |\n" .. tostring(rs.Strength)
            Megamod.SendChatMessage(client, text, Color(255, 0, 255, 255))
        end
    end
    return true, ""
end

return rs
