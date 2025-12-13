local event = {}

event.Name = "Monster Join"

event.Severity = "medium"

event.Enabled = true

event.Started = false

event.CanEnd = false

event.OneOff = false


local tpu = require 'utils.textpromptutils'

-- Need at least one non-antag dead player, and the Monster ruleset to be active
function event.Check()
    local validPlayer
    if not event.Monster
    or not event.Monster.Enabled
    or event.Monster.Strength == 0
    or event.Monster.FailReason ~= "" then
        return false
    end
    for client in Client.ClientList do
        if Megamod.CheckIsSpectating(client)
        and #Megamod.RuleSetManager.AntagStatus(client) == 0 then
            validPlayer = true
            break
        end
    end
    return validPlayer
end

event.ValidClients = {}

-- A thread that counts down the time left for a client to click "yes" or "no"
event.NoSelectTimer = nil

-- The Monster ruleset
event.Monster = nil
for ruleSet in Megamod.RuleSetManager.RuleSets do
    if ruleSet.Name == "Monster" then
        event.Monster = ruleSet
        break
    end
end

function event.PromptRandom()
    local selectedClient = event.ValidClients[math.random(#event.ValidClients)]
    local str = "Would you like to join the monsters and attack the station?\n(15 seconds to choose)"
    tpu.Prompt(str, { "Yes", "No" }, selectedClient, event.OnSelected, nil, false)
    event.NoSelectTimer = coroutine.create(function(timer)
        ::restart::
        if not Game.RoundStarted or not event.NoSelectTimer then return end
        if timer <= 0 then
            -- Act as if the client clicked "no"
            event.OnSelected(2, selectedClient)
            return
        end
        Timer.Wait(function()
            if not Game.RoundStarted or not event.NoSelectTimer then return end
            timer = timer - 1
            coroutine.resume(event.NoSelectTimer, timer)
        end, 1000)
        coroutine.yield()
        goto restart
    end)
    coroutine.resume(event.NoSelectTimer, 15)
end

function event.OnSelected(option, client)
    if not event.Started then return end
    -- This makes sure that the client isn't clicking an option after the timer has run out
    local IsValidClient = false
    for k, v in pairs(event.ValidClients) do
        if v == client then
            IsValidClient = true
            break
        end
    end
    if not IsValidClient then return end
    event.NoSelectTimer = nil
    option = option == 1
    if option then -- They clicked "yes"
        Megamod.Log("Setting client '" .. tostring(client.Name) .. "' to be a monster player.", true)
        if not event.Monster then
            for ruleSet in Megamod.RuleSetManager.RuleSets do
                if ruleSet.Name == "Monster" then
                    event.Monster = ruleSet
                    break
                end
            end
        end
        if not event.Monster then
            Megamod.Error("Couldn't find the Monster ruleset, aborting.")
            return
        end
        event.Monster.SelectedPlayers[client] = { event.Monster.AntagName, {} }
        local msg = Networking.Start("mm_monster")
        msg.WriteBoolean(true)
        Networking.Send(msg, client.Connection)
        for admin in Client.ClientList do
            if Megamod.Admins[admin.SteamID] then
                local msg = Networking.Start("mm_ruleset")
                msg.WriteByte(3)
                msg.WriteString(event.Monster.Name)
                msg.WriteByte(client.SessionId)
                msg.WriteString(event.Monster.AntagName)
                Networking.Send(msg, admin.Connection)
            end
        end
        event.CanEnd = true
        Megamod.EventManager.EndEvent(event.Name)
    elseif #event.ValidClients > 1 then  -- They clicked "no" and there are more clients to ask
        -- Don't ask this client again
        for k, v in pairs(event.ValidClients) do
            if v == client then
                table.remove(event.ValidClients, k)
                break
            end
        end
        -- Ask someone else
        event.PromptRandom()
    else -- No clients left to ask and everyone said "no"
        Megamod.Log("All clients declined to join the monsters.", true)
        event.CanEnd = true
        Megamod.EventManager.EndEvent(event.Name)
    end
end

function event.Start()
    event.Started = true
    for client in Client.ClientList do
        if client.InGame
        and Megamod.GetData(client, "Monster")
        and #Megamod.RuleSetManager.AntagStatus(client) == 0
        and Megamod.CheckIsSpectating(client)
        then
            table.insert(event.ValidClients, client)
        end
    end
    if #event.ValidClients > 0 then
        event.PromptRandom()
    else
        Megamod.Log("No valid clients to ask to join the monsters.", true)
        event.CanEnd = true
        Megamod.EventManager.EndEvent(event.Name)
    end
end

---@param fast boolean
function event.End(fast)
    event.NoSelectTimer = nil
    event.ValidClients = {}
    event.Started = false
    -- Don't reset event.Monster
end

return event
