--do require 'utils.automation.auto' return end

local path = ...

Megamod = {}
---@type string
Megamod.Path = path

-- NOTE: For some reason, Steam IDs are strings, NOT numbers

-- People allowed to play as Beasts
Megamod.CertifiedBeasters = {
    ["76561199139073814"] = true, -- munkee
}

-- No need to hide this, vanilla Baro tells everyone who the admins are anyway
Megamod.Admins = {
    ["76561199139073814"] = true, -- munkee
}

Megamod.BlacklistedPlayerMonsters = {
    Truebeast = true
}

-- Static/Dynamic/Kinematic
Megamod.PhysicsBodyTypes = LuaUserData.CreateEnumTable("FarseerPhysics.BodyType")
Megamod.GameMain = LuaUserData.CreateStatic("Barotrauma.GameMain")

if CLIENT then
    Megamod_Client = {}
    ---@type Barotrauma.GameMain
    ---@type string
    Megamod_Client.Path = path

    -- NOTE: Nil return on and near runtime
    ---@return Barotrauma.Networking.Client
    function Megamod_Client.GetSelfClient()
        return Megamod.GameMain.Client.MyClient
    end
    -- Client is nil on runtime, so we wait for it to be set
    Timer.Wait(function()
        -- If false, don't display admin stuff like the control panel
        Megamod_Client.IsAdmin = nil
        if Megamod_Client.GetSelfClient() then
            -- Client true = we're on the public TBG server, check if we're an admin
            Megamod_Client.IsAdmin = Megamod.Admins[tostring(Megamod_Client.GetSelfClient().SteamID)] or false
        else
            -- Client false = we're on a local TBG testing server, assume we're an admin
            Megamod_Client.IsAdmin = true
        end
        -- Also, note that IsAdmin isn't harmful to be true when we're
        -- not actually an admin, as the server checks admin status where necessary
        -- It would just give you access to some blank, unusable things

        -- These have to initialized after the shared stuff and IsAdmin
        dofile(Megamod_Client.Path .. "/Lua/client/client.lua")
        dofile(Megamod_Client.Path .. "/Lua/client/hunt.lua")
        dofile(Megamod_Client.Path .. "/Lua/client/controlpanel.lua") -- This has the side-effect of making the "control panel" option the last in the list
        dofile(Megamod_Client.Path .. "/Lua/client/dimelocator.lua")
        dofile(Megamod_Client.Path .. "/Lua/client/monster.lua")
        dofile(Megamod_Client.Path .. "/Lua/client/configmenu.lua")
    end, 1)
end

-- Workshop Lua init
do
    local fileTbls = {}
    for dir in File.GetDirectories(path .. "/Lua/workshop") do
        local s = dir:reverse():gsub("\\", "/"):find("/")
        local modName = dir:sub(#dir - s + 2)
        for dir2 in File.GetDirectories(dir) do
            local priority
            if File.Exists(dir2 .. "/priority.txt") then
                priority = tonumber(File.Read(dir2 .. "/priority.txt"))
            end
            for dir3 in File.GetDirectories(dir2) do
                if dir3:sub(-7) == "Autorun" then
                    for file in File.GetFiles(dir3) do
                        table.insert(fileTbls, { file = file, modName = modName, priority = priority })
                    end
                end
            end
        end
    end
    -- Load prioritized mods first
    for tbl in fileTbls do
        if tbl.priority then
            loadfile(tbl.file)(path .. "/Lua/workshop/" .. tbl.modName)
        end
    end
    -- Then load other mods
    for tbl in fileTbls do
        if not tbl.priority then
            loadfile(tbl.file)(path .. "/Lua/workshop/" .. tbl.modName)
        end
    end
end


-- Shared patches -->

-- Destroy the beacon station
Hook.Patch("Megamod.RemoveBeaconStations", "Barotrauma.Level", "CreateBeaconStation", function(instance, ptable)
    if instance.BeaconStation then
        instance.BeaconStation.Dispose()
    end
end, Hook.HookMethodType.After)

-- Destroy the start/end outposts
Hook.Patch("Megamod.RemoveOutposts", "Barotrauma.Level", "Generate",
    { "System.Boolean", "Barotrauma.Location", "Barotrauma.Location" }, function(instance, ptable)
    if instance.StartOutpost then
        instance.StartOutpost.Dispose()
    end
    if instance.EndOutpost then
        instance.EndOutpost.Dispose()
    end
end, Hook.HookMethodType.After)

-- Prevent some random crap from spawning on roundstart (???)
Hook.Patch("Megamod.NoCargoCrates", "Barotrauma.AutoItemPlacer", "SpawnStartItems", function(instance, ptable)
    ptable.PreventExecution = true
end, Hook.HookMethodType.Before)
Hook.Patch("Megamod.NoCargoCrates2", "Barotrauma.CargoManager", "DeliverItemsToSub", function(instance, ptable)
    ptable.PreventExecution = true
end, Hook.HookMethodType.Before)

-- Ignore recipes for items, everyone can craft everything
Hook.Patch("Megamod.NoFabricationRecipes", "Barotrauma.Character", "HasRecipeForItem", function(instance, ptable)
    ptable.PreventExecution = true
    return true
end, Hook.HookMethodType.Before)

-- When a fabricator component is created...
Hook.Patch("Megamod.FabricatorChange", "Barotrauma.Items.Components.Fabricator", "OnItemLoaded",
    function(instance, ptable)
        -- This ensures that it doesn't run in the sub editor
        Timer.Wait(function()
            if not Game.RoundStarted then return end
            local fabricatorID = tostring(instance.item.Prefab.Identifier)
            -- Don't modify rift engines/transformers
            if fabricatorID ~= "riftengine" and fabricatorID ~= "riftengine2" then
                -- Reduce required skill to 20% of the original
                instance.SkillRequirementMultiplier = instance.SkillRequirementMultiplier * 0.2
                -- Reduce required time to 20% of the original
                instance.FabricationSpeed = instance.FabricationSpeed * 1.8
            end
        end, 10000)
    end, Hook.HookMethodType.Before)

-- Debug script to undo the above fabricator change if it's accidentally applied in the sub editor
--[[for k, v in pairs(Item.ItemList) do
    local c = v.GetComponentString("Fabricator")
    if c then
        print(tostring(v))
        c.SkillRequirementMultiplier = 1
        c.FabricationSpeed = 1
    end
end]]

-- Basically just using the "disablecrewai" command on all humans that spawn
-- Don't care about NPC humans, we don't use them
Hook.Patch("Megamod.NoHumanAI", "Barotrauma.AICharacter", "SetAI", function(instance, ptable)
    if instance["IsHuman"] then
        ptable["aiController"]["Enabled"] = false
    end
end, Hook.HookMethodType.Before)

-- Remove random NPC conversations
Hook.Patch("Megamod.NoConversations", "Barotrauma.CrewManager", "CreateRandomConversation", function(instance, ptable)
    ptable.PreventExecution = true
end, Hook.HookMethodType.Before)

LuaUserData.MakeFieldAccessible(Descriptors["Barotrauma.MonsterEvent"], "disallowed")
-- Prevent vanilla monster spawning logic
Hook.Patch("Megamod.NoVanillaMonsters", "Barotrauma.MonsterEvent", "Update", function(instance, ptable)
    -- This is basically the same as unticking boxes in the "Monster Spawns" box in server settings
    instance.disallowed = true
end, Hook.HookMethodType.Before)


if SERVER then
    -- Add a normal hook "megamod.terminalWrite," called every time something is entered on a terminal component
    -- This was adapted from Traitormod
    Hook.Patch("Megamod.TerminalPatch", "Barotrauma.Items.Components.Terminal", "ServerEventRead", function(instance, ptable)
        local msg = ptable["msg"]
        local client = ptable["c"]

        local rewindBit = msg.BitPosition
        local output = msg.ReadString()
        msg.BitPosition = rewindBit      -- this is so the game can still read the net message, as you cant read the same bit twice

        local item = instance.Item

        Hook.Call("megamod.terminalWrite", item, client, output)
    end, Hook.HookMethodType.Before)

    -- Prevent human player characters from despawning, important for
    -- hypomaxims, as that relies on the body still being there
    Hook.Add("character.death", "Megamod.CharacterDeath", function(character)
        -- Only happens during serious rounds
        if not character or character.IsHuman or not Util.FindClientCharacter(character) or Megamod.RuleSetManager.RoundType ~= 1 then return end
        character.EnableDespawn = false
    end)

    -- Make invisibility go away on taking damage
    Hook.Add("character.applyDamage", "Megamod.CharacterDamage", function(characterHealth, attackResult, hitLimb, allowStacking)
        local char = characterHealth.Character
        char.InvisibleTimer = 0
        HF.SetAffliction(char, "mm_invis", 0)
    end)

    -- Need to wait for the server to fully start up
    -- (NOT USEFUL FOR PUBLIC SERVERS DUE TO HOW BARO WORKS)
    if not Game.ServerSettings.IsPublic then
        Timer.Wait(function()
            Game.ExecuteCommand("enablecheats")
        end, 5000)
    end

    -- Omniscience table (structured with table.insert()),
    -- clients in this receive Megamod logs in chat
    Megamod.Omni = {}

    -- Network Tweaks (https://steamcommunity.com/sharedfiles/filedetails/?id=3329396988)
    -- It's small enough to reasonably just do this instead of including the whole mod
    NetConfig.MaxHealthUpdateInterval = 0
    NetConfig.LowPrioCharacterPositionUpdateInterval = 0
    NetConfig.MaxEventPacketsPerUpdate = 8
    -- No longer necessary, changed (fixed?) by barodevs
    --NetConfig.RoundStartSyncDuration = 60
    --NetConfig.EventRemovalTime = 40
    --NetConfig.OldReceivedEventKickTime = 50
    --NetConfig.OldEventKickTime = 60
    NetConfig.SparseHullUpdateInterval = 5
    NetConfig.HullUpdateInterval = 0.5
    LuaUserData.MakePropertyAccessible(Descriptors["Barotrauma.Networking.ServerSettings"], "MinimumMidRoundSyncTimeout")
    -- set() in MinimumMidRoundSyncTimeout is now privated, must be for good reason
    --[[if Game.ServerSettings and Game.ServerSettings.MinimumMidRoundSyncTimeout == 10 then
        Game.ServerSettings.MinimumMidRoundSyncTimeout = 100
    end]]
end

-- Vanilla settings
Game.OverrideTraitors(true) -- No vanilla traitors
Game.EnableControlHusk(true) -- Players who turn into husks control the husk

-- Shared toolbox
require 'shared.mega'

if SERVER then
    -- Server-side toolbox
    require 'server.mega'
end

-- Shared modules

-- Chat commands
Megamod.Commands = require 'shared.commands'

-- Sub stuff
Megamod.Subs = require 'shared.subs'

if SERVER then
    -- Midround spawn
    Megamod.MidRoundSpawn = require 'server.modules.midroundspawn'

    -- Escape portal, saving loot between rounds
    Megamod.EscapePortal = require 'server.modules.escapeportal'

    -- Reviving people via cloning & hypomaxim
    Megamod.Cloning = require 'server.modules.cloning'

    -- Events, good or bad
    Megamod.EventManager = require 'server.modules.eventmanager'

    -- Rulesets determine antagonists (this shit is WAY too complicated)
    Megamod.RuleSetManager = require 'server.modules.rulesetmanager'

    -- "Teleport Science" aka Telescience, used for all things portals, including ending the round
    Megamod.Telesci = require 'server.modules.telescience'

    -- Plants
    Megamod.Botany = require 'server.modules.botany'

    -- Syringes, reagents, etc
    Megamod.Chemistry = require 'server.modules.chemistry'

    -- The station's AI player, who acts as Big Brother in the sky
    Megamod.StationAI = require 'server.modules.stationai'

    -- Scientists do research to unlock stuff
    Megamod.Research = require 'server.modules.research'

    -- Map stuff
    Megamod.Map = require 'server.modules.map'

    -- Check if people have CL Lua
    Megamod.LuaCheck = require 'server.modules.luacheck'

    -- Discord integration (send messages to the Discord server)
    Megamod.Discord = require 'server.modules.discord'
end
