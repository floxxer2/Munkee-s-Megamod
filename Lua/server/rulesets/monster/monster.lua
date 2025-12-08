local rs = {}

rs.Name = "Monster"

rs.Chance = 15

rs.Enabled = true

rs.SelectedPlayers = {}

rs.Strength = 0

rs.AntagName = "Monster"

rs.FailReason = ""



-- ONLY set by admins using "lua" command
-- Reset on round end
local PERCEPTION_MULT_EXTRA_DEFAULT = 0
local NIGHTMARE_MODE_DEFAULT = false
rs.PerceptionMultExtra = PERCEPTION_MULT_EXTRA_DEFAULT
rs.NightmareMode = NIGHTMARE_MODE_DEFAULT

LuaUserData.MakeMethodAccessible(Descriptors["Barotrauma.EnemyAIController"], "GetPerceptionRange")

-- Mimics the original, but multiplies by the strength of the ruleset
Hook.Patch("Megamod.AIPerceptionPatch", "Barotrauma.EnemyAIController", "GetPerceptionRange", function(instance, ptable)
    ptable.PreventExecution = true
    local mult = 1 + rs.Strength + rs.PerceptionMultExtra

    local state = tonumber(instance["State"])
    if state == 14 or state == 16 then
        return 0.2 * mult
    end
    local previousState = tonumber(instance["PreviousState"])
    if previousState == 14 or previousState == 16 then
        return (ptable["range"] * 1.5) * mult
    end
    return ptable["range"] * mult
end, Hook.HookMethodType.Before)

-- Received when a client wants to control or leave a monster
Networking.Receive("mm_monster", function(message, sender)
    if not rs.SelectedPlayers[sender] then
        Megamod.Log("Client '" .. tostring(sender.Name) .. "' tried to send an invalid mm_monster net message.", true)
        return
    end
    local control = message.ReadBoolean()
    if control then
        local id = tonumber(message.ReadUInt64())
        local monster
        for char in Character.CharacterList do
            if char.ID == id
            and not char.IsHuman
            and not Megamod.BlacklistedPlayerMonsters[tostring(char.SpeciesName)] then
                monster = char
                break
            end
        end
        if not monster then
            Megamod.SendChatMessage(sender, "ERROR: Couldn't find the monster to control, please try again. If this persists, tell an admin!", Color(255, 0, 255, 255))
            Megamod.Error("Monster character not found, or was blacklisted. Aborting control swap.")
            return
        end
        sender.SetClientCharacter(monster)
    else
        -- Sends the client to freecam
        sender.SetClientCharacter(nil)
    end
end)

-- Strength x10, then +/- 5
rs.WaveStrength = 0

-- Use table.insert() / table.remove()
rs.SpawnedMonsters = {}

-- The species group of monsters that will be spawned
rs.CurrentGroup = nil

local MAX_MONSTERS_DEFAULT = 15
-- Hard cap
rs.MaxSpawnedMonsters = MAX_MONSTERS_DEFAULT

-- Kill tracking (used to decide if the monsters 'failed' to do their job)
rs.KillStacks = 0
rs.KillCount = 0
rs.LastKillTime = nil
rs.InitialKillTime = nil
-- How long (seconds) without a monster kill before we start decrementing the kill count until the ruleset fails
rs.FailAfterSeconds = 120 -- 2 minutes

--[[ [Group name] = {
    [Specices name] = { creature strength, min wave strength, max wave strength }
}]]
rs.SpawnTable = {
    crawler = {
        -- Could add hatchlings, but they can't actually damage the sub

        Crawler = { 3, 0, 45 },
        Crawler_Large2 = { 5, 5, 45 },
        AbyssalCrawler = { 8, 15, 45 },
        AbyssalCrawler2 = { 9, 15, 45 },
        Crawleralphamale = { 25, 20, 45 },
        Crawlerbroodmother = { 30, 25, 45 },
    },
    mudraptor = {
        Mudraptor_Hatchling = { 5, 20, 65 },
        Mudraptor_unarmored = { 7, 22, 65 },
        Mudraptor = { 9, 26, 65 },
        Nightraptor = { 12, 26, 65 },
        Mudraptor_veteran2 = { 15, 30, 65 },
        Mudraptor_veteran = { 16, 30, 65 },
        Mudrex = { 18, 32, 65 },
    },
    thresher = {
        Tigerthresher = { 8, 25, 100 },
        Lavathresher = { 12, 25, 100 },
        Abyssalthresher = { 12, 25, 100 },
        Bonethresher = { 14, 32, 100 },
    },
}

local weightedRandom = require 'utils.weightedrandom'

local function getCanSpawn(min, max)
    return (min <= rs.WaveStrength) and (max >= rs.WaveStrength)
end

local function getWave(monsterGroup)
    local wave = {}

    local function doStuff(tbl)
        local random = {}
        local total = 0
        for id, values in pairs(tbl) do
            local strength = values[1]
            local min = values[2]
            local max = values[3]
            if getCanSpawn(min, max) then
                random[{ id, strength }] = strength * 2 -- Somewhat biased towards larger monsters
            end
        end
        while true do
            local chosen = weightedRandom.Choose(random)
            if not chosen then break end                    -- No more monsters to choose from
            if total + chosen[2] <= rs.WaveStrength then    -- Total strength of spawned monsters cannot go over wave strength
                total = total + chosen[2]
                table.insert(wave, chosen[1])               -- Don't remove from random, so we can select the same monster multiple times
            else
                random[chosen] = nil                        -- This monster would go over the cap, so get rid of it
            end
        end
    end

    for group, tbl in pairs(rs.SpawnTable) do
        if group == monsterGroup then
            doStuff(tbl)
            break
        end
    end

    return wave
end

local function getPotentialGroups()
    local potential = {}
    for group, tbl in pairs(rs.SpawnTable) do
        for _, values in pairs(tbl) do
            if getCanSpawn(values[2], values[3]) then -- At least one monster in this group must be currently spawnable
                table.insert(potential, group)
                break
            end
        end
    end
    if #potential == 0 then
        Megamod.Error("Found no spawnable monster groups for wave strength " .. rs.WaveStrength .. ".")
    end
    return potential
end

local MAX_SPAWN_ATTEMPTS = 5

function rs.WavesTick()
    local removeKeys = {}
    -- // Tick rs.SpawnedMonsters //
    for k, tbl in pairs(rs.SpawnedMonsters) do
        if not tbl.monster or tbl.monster.IsDead then
            --print("Cleaned up '" .. tostring((tbl.monster and tbl.monster.SpeciesName) or "[a monster]") .. "'")
            table.insert(removeKeys, k)
        elseif tbl.stacks >= 5 then -- Monster has been idle for too long
            --print("Despawned '" .. tostring(tbl.monster.SpeciesName) .. "'")
            tbl.monster.DespawnNow(true)
            table.insert(removeKeys, k)
        else
            local idle =
                   tonumber(tbl.monster.AIController.State) == 0 -- Idle if in "idle" state
                or tonumber(tbl.monster.AIController.State) == 8    -- Idle if in "protecting" state
            if idle then
                tbl.stacks = tbl.stacks + 1
                --print("Idle detected: (" .. tostring(tbl.stacks) .. ") - '" .. tostring(tbl.monster) .. "'")
            else
                tbl.stacks = 0
            end
        end
    end
    for removeKey in removeKeys do
        rs.SpawnedMonsters[removeKey] = nil
    end

    -- // 20% chance to swap groups on every spawn wave //
    if not rs.CurrentGroup or math.random() <= 0.2 then
        local potentialGroups = getPotentialGroups()
        local swap = potentialGroups[math.random(#potentialGroups)]
        if swap then
            rs.CurrentGroup = swap
        end
        --print("Swapped group to " .. swap)
    end

    -- // Spawn monsters from the current group //
    -- Lower chance to spawn when there are more monsters, with a bunch of other crap too
    local chance = (1.7 * ((rs.MaxSpawnedMonsters - #rs.SpawnedMonsters) / rs.MaxSpawnedMonsters)) / 2
    if math.random() <= chance then
        -- Note that if wave strength is low enough, it might not roll anything to spawn
        local wave = getWave(rs.CurrentGroup)
        if #wave == 0 then return end -- Don't spawn the portal if the wave is empty

        local spawnAttempts = 0
        local function trySpawn()
            if spawnAttempts >= MAX_SPAWN_ATTEMPTS then
                Megamod.Log("Failed to find a spawn point for a monster wave " ..
                tostring(spawnAttempts) .. " times. Canceling wave...", true)
                return
            end

            local r = 10000
            local randTheta = math.rad(math.random(0, 360))
            -- Get a spawnpoint at a random point in a circle around the station
            local spawnPoint = Vector2(Submarine.MainSub.WorldPosition.X + (r * math.cos(randTheta)),
                Submarine.MainSub.WorldPosition.Y + (r * math.sin(randTheta)))
            -- Add a slight offset
            spawnPoint = Vector2.Add(spawnPoint, Vector2(math.random(-2500, 2500), math.random(-2500, 2500)))
            -- Spawn a "portal" thing as an indicator
            local prefab = ItemPrefab.GetItemPrefab("mm_rift")
            Entity.Spawner.AddItemToSpawnQueue(prefab, spawnPoint)

            -- Wait for the particle effect to appear
            Timer.Wait(function()
                -- Don't want to spawn in a sub
                if not Hull.FindHull(spawnPoint, nil, true, true) then
                    for _, id in pairs(wave) do
                        if #rs.SpawnedMonsters < rs.MaxSpawnedMonsters then
                            --print("Spawned '" .. id .. "'")
                            local char = Character.Create(id, spawnPoint, "", nil, 0, false, true, true, nil, true, true)
                            table.insert(rs.SpawnedMonsters, { monster = char, stacks = 0 })
                        else
                            break
                        end
                    end
                else
                    spawnAttempts = spawnAttempts + 1
                    trySpawn()
                end
            end, 5000)
        end
        trySpawn()
    end
    --[[print("*******")
    print("Monsters: ", #rs.SpawnedMonsters)
    print("Chance: ", chance)
    print("Wave Strength: ", rs.WaveStrength)
    print("Group: ", rs.CurrentGroup)
    print("*******")]]
end

local tick = 0
local loopRunning = false
local function loop()
    if not Game.RoundStarted or not loopRunning then
        tick = 0
        return
    end
    tick = tick + 1
    if (rs.NightmareMode and tick >= 1) -- Nightmare Mode = every 9-11 seconds
    or (not rs.NightmareMode and tick >= 12) then -- Normal mode = roughly every 2 minutes
        tick = 0
        rs.WavesTick()
    end
    Timer.Wait(function()
        return loop()
    end, math.random(9000, 11000))
end



function rs.Reset()
    for monsterClient, _ in pairs(rs.SelectedPlayers) do
        Megamod.SendChatMessage(monsterClient, "The monster ruleset has failed. You are no longer a monster.", Color(255, 0, 255, 255))
        local msg = Networking.Start("mm_monster")
        msg.WriteBoolean(false)
        Networking.Send(msg, monsterClient.Connection)
        if monsterClient.Character
        and not monsterClient.Character.IsDead
        and not monsterClient.Character.IsHuman then
            -- Send to spectator if they're still controlling something
            monsterClient.SetClientCharacter(nil)
        end
    end
    rs.SelectedPlayers = {}
    rs.Strength = 0
    rs.WaveStrength = 0
    rs.SpawnedMonsters = {}
    rs.CurrentGroup = nil
    loopRunning = false -- Stops the loop function, useful if we reset midround (i.e, ruleset failed)
    rs.KillStacks = 0
    rs.KillCount = 0
    rs.LastKillTime = nil
    rs.InitialKillTime = nil
    rs.MaxSpawnedMonsters = MAX_MONSTERS_DEFAULT
    rs.NightmareMode = NIGHTMARE_MODE_DEFAULT
    rs.PerceptionMultExtra = PERCEPTION_MULT_EXTRA_DEFAULT
end

function rs.RoleHelp(client)
    if rs.SelectedPlayers[client] then
        return true, rs.SelectedPlayers[client][3]
    end
    return false, ""
end

-- Can always be drafted
function rs.Check()
    return true
end

-- Track player deaths to see if monsters actually kill anyone
-- If a human player dies and the last damage source was a non-human character, count it as a monster kill
Hook.Add("character.death", "Megamod.Monster.KillTrack", function(char)
    if not Game.RoundStarted
    or not char.IsHuman
    or rs.Strength == 0
    or rs.FailReason ~= ""
    then return end
    local client = Util.FindClientCharacter(char)
    -- Ignore humans that are not player-controlled
    if not client then return end

    local src = char.LastDamageSource
    if src and LuaUserData.IsTargetType(src, "Barotrauma.Character") and not src.IsHuman then
        rs.KillStacks = rs.KillStacks + 1
        rs.KillCount = rs.KillCount + 1
        rs.LastKillTime = Timer.GetTime()
    end
end)

function rs.CheckShouldFail()
    -- Determine elapsed time since the ruleset started spawning or since the last kill
    local now = Timer.GetTime()
    local since = now - (rs.LastKillTime or rs.InitialKillTime or now)

    if rs.Strength >= 5 and since >= rs.FailAfterSeconds then
        rs.KillStacks = rs.KillStacks - 1
        rs.InitialKillTime = Timer.GetTime()
    end

    if rs.KillStacks <= -2 then
        return true, "Monsters didn't kill enough players (<0.5 kills/minute)."
    end

    return false, ""
end

function rs.Draft()
    -- Things when the ruleset is first drafted
    if rs.Strength == 1 then
        local str = "Some hostile Europan fauna has been detected approaching the station. They should retreat if we hold strong."
        local color = Color(255, 200, 50, 255)
        if math.random(1, 100) == 1 or rs.NightmareMode then
            rs.NightmareMode = true
            rs.MaxSpawnedMonsters = rs.MaxSpawnedMonsters * 2
            str = "RED ALERT! EXTREMELY HIGH CONCENTRATIONS OF HOSTILE EUROPAN FAUNA INCOMING. THIS MAY BE OUR LAST STAND."
            color = Color(210, 10, 100, 255)
        end
        for client in Client.ClientList do
            Megamod.SendChatMessage(client, str, color)
        end
        local prefab = ItemPrefab.GetItemPrefab("mm_notifalarm")
        Entity.Spawner.AddItemToSpawnQueue(prefab, Submarine.MainSub.WorldPosition)

        rs.InitialKillTime = Timer.GetTime()
        tick = 0
        loopRunning = true
        loop()
    end
    rs.WaveStrength = rs.Strength * 10 + math.random(-5, 5)
    if rs.WaveStrength < 0 then rs.WaveStrength = 0 end
    if rs.WaveStrength > 100 then rs.WaveStrength = 100 end
    return true, ""
end

return rs
