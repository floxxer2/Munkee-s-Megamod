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



Networking.Receive("mm_beastwater", function(message, client)
    if not Megamod.CertifiedBeasters[client.SteamID]
    or not client.Character
    or client.Character.IsDead == true
    or tostring(client.Character.SpeciesName) ~= "Truebeast" then
        Megamod.Log("Client '" .. tostring(client.Name) .. "' sent an invalid mm_beastwater net message.")
        return
    end

    local bool = message.ReadBoolean()
    Megamod.CS_Shared.ForceInWater = bool

    local msg = Networking.Start("mm_beastwater")
    msg.WriteBoolean(bool)
    for client in Client.ClientList do
        Networking.Send(msg, client.Connection)
    end
end)
local function beastWaterLoop()
    local msg = Networking.Start("mm_beastwater")
    msg.WriteBoolean(Megamod.CS_Shared.ForceInWater)
    for client in Client.ClientList do
        Networking.Send(msg, client.Connection)
    end
    Timer.Wait(function()
        beastWaterLoop()
    end, 5000)
end
beastWaterLoop()

-- For whatever reason, the beast in "force swim" mode can't swim up, so we
-- need to do that manually
Networking.Receive("mm_beastmove", function(message, client)
    local shiftDown = message.ReadBoolean()
    if not Megamod.CertifiedBeasters[client.SteamID]
    or not client.Character
    or client.Character.IsDead == true
    or tostring(client.Character.SpeciesName) ~= "Truebeast"
    or not Megamod.CS_Shared.ForceInWater then
        Megamod.Log("Client '" .. tostring(client.Name) .. "' sent an invalid mm_beastmove net message.")
        return
    end

    local vector = Vector2(0, 4)
    if shiftDown then
        vector = Vector2(0, 12)
    end
    client.Character.AnimController.Collider.ApplyLinearImpulse(vector, 10)
end)

Networking.Receive("mm_beastrotate", function(message, client)
    local dir = message.ReadSingle()
    if not Megamod.CertifiedBeasters[client.SteamID]
    or not client.Character
    or client.Character.IsDead == true
    or tostring(client.Character.SpeciesName) ~= "Truebeast"
    or not Megamod.CS_Shared.ForceInWater then
        Megamod.Log("Client '" .. tostring(client.Name) .. "' sent an invalid mm_beastmove net message.")
        return
    end

    client.Character.AnimController.Collider.SmoothRotate(dir, 10, true)
end)



function rs.Reset()
    rs.SelectedPlayers = {}
    rs.Strength = 0
end

function rs.RoleHelp(client)
    return false, ""
end

function rs.Check()
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
