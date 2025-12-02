local event = {}

event.Name = "Chimera"

event.Severity = "medium"

event.Enabled = false -- #TODO#

event.Started = false

event.CanEnd = false

event.OneOff = false


local tpu = require 'utils.textpromptutils'

-- Need at least one non-antag dead player, and the Monster ruleset to be active
function event.Check()
    local monster
    local deadPlayer
    for ruleSet in Megamod.RuleSetManager.RuleSets do
        if ruleSet.Name == "Monster" then
            monster = ruleSet
            break
        end
    end
    for client in Client.ClientList do
        if client.InGame
        and not client.Character
        or client.Character.IsDead
        and #Megamod.RuleSetManager.AntagStatus(client) == 0 then
            deadPlayer = true
            break
        end
    end
    return deadPlayer
    and not (not monster
    or not monster.Enabled
    or monster.Strength == 0
    or monster.FailReason ~= "")
end

event.ValidClients = {}

-- A thread that counts down the time left for a client to click "yes" or "no"
event.NoSelectTimer = nil

-- Same spawning logic as the monster ruleset (in a circle around the station)
function event.SpawnAsChimera(client)
    Megamod.Log("Spawning client '" .. tostring(client.Name) .. "' as a husk chimera.", true)
    local r = 10000
    local randTheta = math.rad(math.random(0, 360))
    -- Get a spawnpoint at a random point in a circle around the station
    local spawnPoint = Vector2(Submarine.MainSub.WorldPosition.X + (r * math.cos(randTheta)),
        Submarine.MainSub.WorldPosition.Y + (r * math.sin(randTheta)))
    -- Add a slight offset
    spawnPoint = Vector2.Add(spawnPoint, Vector2(math.random(2500), math.random(2500)))

    local monster
    for ruleSet in Megamod.RuleSetManager.RuleSets do
        if ruleSet.Name == "Monster" then
            monster = ruleSet
            break
        end
    end
    if not monster then
        Megamod.Log("Couldn't find the monster ruleset, aborting chimera spawn.", true)
        return
    end
    monster.SelectedPlayers[client] = { "Husk Chimera", {}, "You are a giant monster. Destroy all humans." }
    local char = Character.Create("Husk_chimera", spawnPoint, "", nil, 0, true, true, true, nil, true, true)
    Megamod.GiveAntagOverlay(char)
    client.SetClientCharacter(char)
    event.CanEnd = true
    Megamod.EventManager.EndEvent(event.Name)
end

function event.PromptRandom()
    local selectedClient = event.ValidClients[math.random(#event.ValidClients)]
    local str = "Would you like to respawn as a husk chimera? This will make you an antagonist.\n(15 seconds to choose)"
    tpu.Prompt(str, { "Yes", "No" }, selectedClient, event.OnSelected, nil, false)
    event.NoSelectTimer = coroutine.create(function(timer)
        ::restart::
        if timer <= 0 then
            -- Act as if the client clicked "no"
            event.OnSelected(2, selectedClient)
            event.NoSelectTimer = nil
            return
        end
        Timer.Wait(function()
            if event.NoSelectTimer then
                timer = timer - 1
                coroutine.resume(event.NoSelectTimer, timer)
            end
        end, 1000)
        coroutine.yield()
        goto restart
    end)
    coroutine.resume(event.NoSelectTimer, 15)
end

function event.OnSelected(option, client)
    if not event.Started then return end
    -- This makes sure that the client isn't clicking an option after the
    -- timer has run out
    local isInValidClients = false
    for k, v in pairs(event.ValidClients) do
        if v == client then
            isInValidClients = true
            break
        end
    end
    if not isInValidClients then return end
    event.NoSelectTimer = nil
    option = option == 1
    if option then -- They clicked "yes"
        event.SpawnAsChimera(client)
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
        Megamod.Log("No clients spawned as a husk chimera.", true)
        event.CanEnd = true
        Megamod.EventManager.EndEvent(event.Name)
    end
end

function event.Start()
    event.Started = true
    for client in Client.ClientList do
        if client.InGame
        and #Megamod.RuleSetManager.AntagStatus(client) == 0
        and (not client.Character or client.Character.IsDead)
        then
            table.insert(event.ValidClients, client)
        end
    end
    if #event.ValidClients > 0 then
        event.PromptRandom()
    else
        Megamod.Log("No valid clients to spawn as a husk chimera.", true)
        event.CanEnd = true
        Megamod.EventManager.EndEvent(event.Name)
    end
end

---@param fast boolean
function event.End(fast)
    event.NoSelectTimer = nil
    event.ValidClients = {}
    event.Started = false
end

return event
