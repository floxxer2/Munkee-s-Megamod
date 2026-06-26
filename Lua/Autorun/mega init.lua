--do require 'utils.automation.auto' return end

local json = require 'utils.json'
local weightedRandom = require 'utils.weightedrandom'

Megamod = {}
---@type string
Megamod.Path = ...

-- NOTE: For some reason, Steam IDs are strings, NOT numbers

-- People allowed to play as Beasts
Megamod.CertifiedBeasters = {
    ["76561199139073814"] = true, -- munkee
    ["76561198951804184"] = true, -- Hex
    ["76561198174656237"] = true, -- Pepsi-Cola
    ["76561199598407172"] = true, -- Fish
}

-- No need to hide this, vanilla Baro tells everyone who the admins are anyway
Megamod.Admins = {
    ["76561199139073814"] = true, -- munkee
    ["76561198951804184"] = true, -- Hex
}

-- Monsters that you can't control as a monster antagonist
-- Humans are always blacklisted
Megamod.BlacklistedPlayerMonsters = {
    ["Truebeast"] = true
}

-- Static/Dynamic/Kinematic
Megamod.PhysicsBodyTypes = LuaUserData.CreateEnumTable("FarseerPhysics.BodyType")
Megamod.GameMain = LuaUserData.CreateStatic("Barotrauma.GameMain")

LuaUserData.RegisterType("Megamod.MegamodShared")
Megamod.CS_Shared = LuaUserData.CreateStatic("Megamod.MegamodShared")

if CLIENT then
    Megamod_Client = {}
    ---@type Barotrauma.GameMain
    ---@type string
    Megamod_Client.Path = Megamod.Path

    Megamod_Client.AmAntag = false

    LuaUserData.RegisterType("CompleteDarkness.CompleteDarknessMod")
    ---@type CompleteDarkness.CompleteDarknessMod
    Megamod_Client.LightMapOverride = LuaUserData.CreateStatic("CompleteDarkness.CompleteDarknessMod")

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
        dofile(Megamod_Client.Path .. "/Lua/client/controlpanel.lua")
        dofile(Megamod_Client.Path .. "/Lua/client/dimelocator.lua")
        --dofile(Megamod_Client.Path .. "/Lua/client/chemistry.lua")
        dofile(Megamod_Client.Path .. "/Lua/client/monster.lua")
        dofile(Megamod_Client.Path .. "/Lua/client/vision.lua")
        dofile(Megamod_Client.Path .. "/Lua/client/configmenu.lua")
        dofile(Megamod_Client.Path .. "/Lua/client/keybinds.lua")
        dofile(Megamod_Client.Path .. "/Lua/client/invis.lua")
    end, 1)
end

-- Workshop Lua init
do
    local autorunPaths
    local jsonPath = Megamod.Path .. "/Lua/utils/automation/autorunpaths.json"
    if File.Exists(jsonPath) then
        autorunPaths = json.decode(File.Read(jsonPath))
    else
        error("No autorun path JSON file detected!")
        return
    end

    for modName, autorunPath in pairs(autorunPaths) do
        for file in File.GetFiles(Megamod.Path .. "/Lua/workshop/" .. autorunPath .. "/MEGAMOD_AUTORUN") do
            loadfile(file)(Megamod.Path .. "/Lua/workshop/" .. modName)
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
                -- Zero skill required
                instance.SkillRequirementMultiplier = 0
                -- Double fabrication speed
                instance.FabricationSpeed = instance.FabricationSpeed * 2
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

-- Changing damage
do
    local BASE_MULT = 2.25

    -- Time (in seconds) until an instance of damage is ignored
    local RECENT_DAMAGE_TIMEOUT = 3

    local SPECIAL_AFFLICTION_THRESHOLD = 275

    local recentDamage = {}
    Hook.Add("roundEnd", "Megamod.Damage.RoundEnd", function()
        recentDamage = {}
    end)

    -- Convert ragdoll limbs into the medical doll limbs / vice versa
    local limbMap = {
        -- Head
        h = {
            LimbType.Head,
            LimbType.Jaw,
        },
        -- Torso
        t = {
            LimbType.Torso,
            LimbType.Waist,
        },
        -- Left Arm
        la = {
            LimbType.LeftArm,
            LimbType.LeftForearm,
            LimbType.LeftHand,
        },
        -- Right Arm
        ra = {
            LimbType.RightArm,
            LimbType.RightForearm,
            LimbType.RightHand,
        },
        -- Left Leg
        ll = {
            LimbType.LeftFoot,
            LimbType.LeftLeg,
            LimbType.LeftThigh,
        },
        -- Right Leg
        rl = {
            LimbType.RightFoot,
            LimbType.RightLeg,
            LimbType.RightThigh,
        },
    }

    local specialAfflictions = {
        {
            id = "mm_armfracture",
            chance = 1,
            limbs = {
                "la",
                "ra",
            },
        },
        {
            id = "mm_legfracture",
            chance = 1,
            limbs = {
                "ll",
                "rl",
            },
        },
        {
            id = "mm_cardiactamponade",
            chance = 1,
            limbs = {
                "t",
            },
        },
    }

    -- #DEBUG#
    local lastTime = Timer.GetTime()

    -- 65% damage resistance
    local unconsciousDamageReduction = 0.65
    unconsciousDamageReduction = 1 - unconsciousDamageReduction
    -- Increase or reduce damage based on vitality,
    -- and add special afflictions
    local function onDamaged(character, afflictions, hitLimb, attacker)
        -- Can't loop through afflictions twice for some reason
        local afflictions2 = {}
        local totalVitalityDecrease = 0
        for affliction in afflictions do
            -- Ignore non-damaging afflictions i.e. steroids
            local vitalityDecrease = affliction.GetVitalityDecrease(character.CharacterHealth)
            -- Ignore small bursts of damage that can get super laggy
            if vitalityDecrease > 5 then
                if affliction.MultiplyByMaxVitality then
                    vitalityDecrease = vitalityDecrease * (character.MaxVitality / 100)
                end
                totalVitalityDecrease = totalVitalityDecrease + vitalityDecrease
                table.insert(afflictions2, { affliction = affliction, vitalityDecrease = vitalityDecrease })
            end
        end
        totalVitalityDecrease = totalVitalityDecrease * BASE_MULT
        -- Reduce damage by 65% if vitality <0
        for entry in afflictions2 do
            local mult = BASE_MULT
            local affliction = entry.affliction
            local vitalityDecrease = entry.vitalityDecrease * mult

            if character.Vitality <= 0 then
                -- Already below 0, fully reduce damage
                mult = mult * unconsciousDamageReduction
            elseif character.Vitality - totalVitalityDecrease <= 0 then
                -- This damage would take us below 0, reduce the overkill
                local overkill = vitalityDecrease - character.Vitality
                if overkill > 0 then
                    local frac = math.min(overkill / vitalityDecrease, 1)
                    mult = BASE_MULT - (BASE_MULT - unconsciousDamageReduction) * frac
                end
            end

            local newStrength = affliction.Strength * mult
            affliction.SetStrength(newStrength)
        end

        -- Client and server seem to have a slight desync on what the
        -- actual vitality decrease of afflictions is, so we just
        -- calculate the rest of this only server-side
        if CLIENT then return end

        -- Ignore some specific afflictions that are way too laggy
        -- This mostly covers cases where a valid aff (i.e. gunshot) is in the same instance of damage
        -- as an invalid one (i.e. burn), such as with incendiary ammunition in EHA
        if #afflictions2 <= 1 then
            for entry in afflictions2 do
                local id = tostring(entry.affliction.Prefab.Identifier)
                if id == "burn"
                or id == "oxygenlow"
                or id == "bloodloss"
                or not entry.affliction.Prefab.LimbSpecific
                or tostring(entry.affliction.GetType()) == "poison" -- Limb-based poisons?
                then
                    return
                end
            end
        end

        -- Ignore non-damaging afflictions
        if totalVitalityDecrease <= 0.0001 then return end

        local now = Timer.GetTime()
        if not recentDamage[character] then
            recentDamage[character] = {
                tvd = totalVitalityDecrease,
                damages = {
                    {
                        vd = totalVitalityDecrease,
                        now = now,
                    }
                },
            }
        else
            recentDamage[character].tvd = recentDamage[character].tvd + totalVitalityDecrease
            table.insert(recentDamage[character].damages, {
                vd = totalVitalityDecrease,
                now = now,
            })
        end
        -- Total Vitality Decrease
        local tvd = recentDamage[character].tvd


        do -- #DEBUG#
            local debug = tostring(character.DisplayName) ~= "munkee"
            for entry in afflictions2 do
                local id = tostring(entry.affliction.Prefab.Identifier)
                if id == "oxygenlow" or id == "bloodloss" then
                    debug = false
                end
            end
            if debug and lastTime and now - lastTime > 0.3 then
                print(tvd)
                lastTime = now
            end
        end


        -- Add special afflictions if the victim has taken too much damage in a short timeframe
        if tvd >= SPECIAL_AFFLICTION_THRESHOLD then
            -- #DEBUG#
            print("Trying to give a special affliction to " .. tostring(character.DisplayName))
            local potentialAfflictions = {}
            for specialAffliction in specialAfflictions do
                local validLimb = false
                if #specialAffliction.limbs > 0 then
                    for limb in specialAffliction.limbs do
                        for limbType in limbMap[limb] do
                            if tonumber(limbType) == tonumber(hitLimb.type) then
                                validLimb = true
                                break
                            end
                        end
                    end
                else
                    -- There are no required limbs, so all limbs are valid
                    validLimb = true
                end
                if validLimb then
                    -- Don't add the same affliction on the same limb
                    if Megamod.GetAfflictionStrengthLimb(character, hitLimb.type, specialAffliction.id, 0) == 0 then
                        potentialAfflictions[specialAffliction] = specialAffliction.chance
                    end
                end
            end
            -- Check if there is at least one valid potential affliction
            local atLeastOne = false
            for _, _ in pairs(potentialAfflictions) do
                atLeastOne = true
                break
            end
            if not atLeastOne then
                -- #DEBUG#
                print("There was no valid special affliction to give to " .. tostring(character.DisplayName))
                return
            end
            -- Success, we are adding a special affliction

            recentDamage[character] = {
                tvd = 0,
                damages = {}
            }

            local afflictionToAdd = weightedRandom.Choose(potentialAfflictions)
            Megamod.SetAfflictionLimb(character, afflictionToAdd.id, hitLimb.type, 1, attacker, 0)
        end
    end

    -- These prevent the specified patches from being duplicated when Lua is reloaded
    Hook.Remove("character.damageLimb", "Megamod.DamagePatch")
    Hook.Remove("character.applyDamage", "Megamod.DamagePatch2")
    Hook.Remove("think", "Megamod.Damage.Think")

    -- Timeout damage buildup
    if SERVER then
        local timer = 0
        Hook.Add("think", "Megamod.Damage.Think", function()
            timer = timer + 1
            -- Once every second
            if timer >= 1000 then
                timer = 0
                local now = Timer.GetTime()
                local removeKeys = {}
                for char, tbl in pairs(recentDamage) do
                    if not char or char.Removed == true or char.IsDead == true then
                        table.insert(removeKeys, char)
                    else
                        for i = #tbl.damages, 1, -1 do
                            local damageInstance = tbl.damages[i]
                            if now - damageInstance.now >= RECENT_DAMAGE_TIMEOUT then
                                tbl.tvd = tbl.tvd - damageInstance.vd
                                if tbl.tvd < 0 then tbl.tvd = 0 end
                                table.remove(tbl.damages, i)
                            end
                        end
                    end
                end
                for key in removeKeys do
                    recentDamage[key] = nil
                end
            end
        end)
    end

    Hook.Add("character.damageLimb", "Megamod.DamagePatch", function(
        character,
        worldPosition,
        hitLimb,
        afflictions,
        stun,
        playSound,
        attackImpulse,
        attacker,
        damageMultiplier,
        allowStacking,
        penetration,
        shouldImplode
        )
        if character == nil
            or character.IsDead
            or not character.IsHuman
            or afflictions == nil
            or hitLimb == nil
            or hitLimb.IsSevered
            or attacker == nil
        then return end
        onDamaged(character, afflictions, hitLimb, attacker)
    end)
    Hook.Add("character.applyDamage", "Megamod.DamagePatch2", function(characterHealth, attackResult, hitLimb)
        if characterHealth == nil
            or characterHealth.Character == nil
            or characterHealth.Character.IsDead
            or not characterHealth.Character.IsHuman
            or attackResult == nil
            or attackResult.Afflictions == nil
            or #attackResult.Afflictions <= 0
            or hitLimb == nil
            or hitLimb.IsSevered
        then return end
        onDamaged(characterHealth.Character, attackResult.Afflictions, hitLimb, nil)
    end)
end

if SERVER then
    LuaUserData.RegisterType("Megamod.MegamodServer")
    Megamod.CS_Server = LuaUserData.CreateStatic("Megamod.MegamodServer")

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
        if not character or not character.IsHuman or not Util.FindClientCharacter(character) or Megamod.RuleSetManager.RoundType ~= 1 then return end
        character.EnableDespawn = false
    end)

    Hook.Add("roundEnd", "Megamod.RoundEndBeast", function()
        Megamod.CS_Shared.ForceInWater = false
    end)

    -- Need to wait for the server to fully start up
    Timer.Wait(function()
        Game.ExecuteCommand("enablecheats")
    end, 5000)

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
    --LuaUserData.MakePropertyAccessible(Descriptors["Barotrauma.Networking.ServerSettings"], "MinimumMidRoundSyncTimeout")
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
    --Megamod.Chemistry = require 'server.modules.chemistry'

    -- The station's AI player, who acts as Big Brother in the sky
    Megamod.StationAI = require 'server.modules.stationai'

    -- Scientists do research to unlock stuff
    Megamod.Research = require 'server.modules.research'

    -- Map stuff
    Megamod.Map = require 'server.modules.map'

    -- Check if people have CL Lua
    Megamod.LuaCheck = require 'server.modules.luacheck'

    -- Stat tracking, like playtime, kills/deaths, etc
    --Megamod.Stats = require 'server.modules.stats'

    -- Discord integration (send messages to the Discord server)
    Megamod.Discord = require 'server.modules.discord'
end
