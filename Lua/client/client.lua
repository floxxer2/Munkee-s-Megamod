-- Misc stuff that doesn't deserve its own file

function Megamod_Client.GetSound(file, isStream) return Megamod.GameMain.SoundManager.LoadSound(file, isStream) end

-- Set all subs to static and tell the server we need to sync sub positions
Hook.Add("roundStart", "Megamod.RoundStart", function()
    for sub in Submarine.Loaded do
        Megamod.Subs.SetSubBodyType(sub, "static")
    end
    Timer.Wait(function()
        local msg = Networking.Start("mm_subpos")
        Networking.Send(msg)
    end, 5000)
end)
Networking.Receive("mm_subpos", function(message)
    local amountSubs = message.ReadByte()
    for i = 1, amountSubs do
        local id = message.ReadUInt16()
        local pos = Vector2(message.ReadInt64(), message.ReadInt64())
        local undockFromStatic = message.ReadBoolean()
        for sub in Submarine.Loaded do
            if sub.ID == id then
                sub.SetPosition(pos, nil, undockFromStatic)
                break
            end
        end
    end
end)

do
    local TIMER_START = 15
    local timers = {}
    -- Reset timers between rounds
    Hook.Add("roundEnd", "Megamod_Client.EscapePortal.RoundEnd", function() timers = {} end)
    -- Makes escaping characters look a lot nicer
    Hook.Add("megamod.escapeportal", "Megamod_Client.EscapePortal.Portal", function(effect, deltaTime, item, targets, worldPosition)
        for target in targets do
            if target and target.IsHuman and not target.IsDead then
                local client = Util.FindClientCharacter(target)
                if not client then return end
                -- Antags can't use the escape portal
                if client == Megamod_Client.GetSelfClient() and Megamod_Client.AmAntag then
                    return
                end

                if not timers[target] then
                    timers[target] = TIMER_START
                    return
                else
                    -- Ragdolls tend to bounce around, so the max speed for them is higher
                    local speedLimit = 0.1
                    if target.Vitality < 5 or target.IsRagdolled then
                        speedLimit = 1
                    end
                    -- Don't tick the timer if the target is still moving
                    if timers[target] >= 0 and target.CurrentSpeed < speedLimit then
                        timers[target] = timers[target] - 1
                        return
                    elseif timers[target] <= 0 then
                        timers[target] = nil
                        -- Don't return
                    else
                        timers[target] = TIMER_START
                        return
                    end
                end

                target.TeleportTo(Vector2(0, -1000000))
            end
        end
    end)
end

-- When someone is revived via cloning, set their team to 1 client-side
-- This makes their name normal-colored, instead of red like they're a pirate
Networking.Receive("mm_setteam", function(message)
    local charID = message.ReadUInt64()
    for char in Character.CharacterList do
        if char.ID == charID then
            char.TeamID = 1
            break
        end
    end
end)

do
    -- Used to make sure all messages are displayed
    local counter = 0
    -- Only use for short messages, the lifetime is fixed at ~4 seconds
    Networking.Receive("mm_selfmsg", function(message)
        local bool = message.ReadBoolean()
        local str = message.ReadString()
        local color = message.ReadColorR8G8B8()
        if bool then
            if not Character.Controlled then return end
            -- Message hovering above own character
            Character.Controlled.AddMessage(str, color, true, tostring(counter), 0)
            counter = counter + 1
            if counter >= 25 then counter = 0 end
        else
            -- Message at top of screen like husk warnings
            GUI.AddMessage(str, color, 5)
        end
    end)
end

-- Sent to you when you become an antagonist of any variety
Networking.Receive("mm_antag", function(message)
    Megamod_Client.AmAntag = message.ReadBoolean()
end)

Hook.Add("roundEnd", "Megamod_Client.EscapePortal.RoundEnd", function() Megamod_Client.AmAntag = false end)

-- We need to know if we're a antag if we reload CL Lua or join midround
Timer.Wait(function()
    local msg = Networking.Start("mm_antag")
    Networking.Send(msg)
end, 100)

-- Sent to you when you become a traitor / need to sync being a traitor
-- IsTraitor allows vanilla traitor features, such as sabotage and hidden fabricator recipes
Networking.Receive("mm_traitor", function(message)
    if not Character.Controlled or not Character.Controlled.IsHuman then return end
    Character.Controlled.IsTraitor = message.ReadBoolean()
end)

-- We need to know if we're a traitor if we reload CL Lua or join midround
Timer.Wait(function()
    local msg = Networking.Start("mm_traitor")
    Networking.Send(msg)
end, 100)

-- 1984
Networking.Receive("mm_luacheck", function(message)
    local str = message.ReadString()
    -- Send message back to server
    local message2 = Networking.Start("mm_luacheck")
    message2.WriteString(str)
    Networking.Send(message2)
end)

local closestHull
local closestHullDist = math.huge
HULL_UPDATE_TIMER_BASE = 15
local hullUpdateTimer = HULL_UPDATE_TIMER_BASE
-- Draw a line towards the station if we're a monster outside
Hook.Patch("Megamod.SubmarineIndicator", "Barotrauma.GUI", "Draw", function(instance, ptable)
    if Character.Controlled
    and not Character.Controlled.IsDead
    and not Character.Controlled.IsHuman
    and not Character.Controlled.CurrentHull
    then
        local from = Character.Controlled.AnimController.MainLimb.WorldPosition
        hullUpdateTimer = hullUpdateTimer - 1
        if not closestHull or hullUpdateTimer <= 0 then
            hullUpdateTimer = HULL_UPDATE_TIMER_BASE
            local selHull
            local closestDist = math.huge
            for hull in Hull.HullList do
                local dist = Vector2.Distance(from, hull.WorldPosition)
                if dist < closestDist then
                    selHull = hull
                    closestDist = dist
                    closestHullDist = dist
                end
            end
            closestHull = selHull
        end
        if closestHullDist < 1000 then return end
        local angle = math.deg(Megamod.AngleBetweenVector2(from, closestHull.WorldPosition))
        local inner = Megamod.FunnyMaths(from, angle, 200)
        local outer = Megamod.FunnyMaths(from, angle, 300)
        GUI.DrawLine(
                ptable["spriteBatch"],
                Megamod.WorldToScreen(inner), Megamod.WorldToScreen(outer),
                Color(255, 0, 255, math.random(150, 255)),
                0, 1
            )
        GUI.DrawString(ptable["spriteBatch"], Megamod.WorldToScreen(inner),
            string.format("Station (%s)", tostring(closestHull.DisplayName)), Color(255, 0, 255, 255), Color.Black * 0.5, 0, GUI.Style.SmallFont)
    end
end, Hook.HookMethodType.Before)

LuaUserData.MakeMethodAccessible(Descriptors["Barotrauma.Items.Components.StatusHUD"], "DrawCharacterInfo")
-- Prevent using the health scanner on any non-human or invisible human
Hook.Patch("Megamod.NoHealthScanMonsters", "Barotrauma.Items.Components.StatusHUD", "DrawCharacterInfo", function(instance, ptable)
    if not ptable["target"].IsHuman or ptable["target"].InvisibleTimer > 0 then
        ptable.PreventExecution = true
    end
end, Hook.HookMethodType.Before)

LuaUserData.MakeMethodAccessible(Descriptors["Barotrauma.Items.Components.MiniMap"], "VisibleOnItemFinder")
-- Prevent using the item finder functionality of status monitors
Hook.Patch("Megamod.NoItemFinder", "Barotrauma.Items.Components.MiniMap", "VisibleOnItemFinder", function(instance, ptable)
    ptable.PreventExecution = true
    return false
end, Hook.HookMethodType.Before)

-- Prevent ID card monitoring on status monitors
Hook.Patch("Megamod.NoIDCardMonitoring", "Barotrauma.Items.Components.MiniMap", "UpdateIDCards", function(instance, ptable)
    ptable.PreventExecution = true
end, Hook.HookMethodType.Before)

-- Remove the report buttons next to the chatbox
Hook.Patch("Megamod.RemoveReportButtons", "Barotrauma.CrewManager", "CreateReportButtons", function(instance, ptable)
    ptable.PreventExecution = true
end, Hook.HookMethodType.Before)

-- Prevent orders from being given client-side
Hook.Patch("Megamod.PreventOrders", "Barotrauma.CrewManager", "CreateCommandUI", function(instance, ptable)
    ptable.PreventExecution = true
    -- Notify the player
    if Character.Controlled then
        Character.Controlled.AddMessage("Orders are disabled on this server.", Color(255, 0, 255, 255), false, "1", 5)
    end
end, Hook.HookMethodType.Before)

-- Remove the alt key labels
Hook.Patch("Megamod.RemoveInteractionLabels", "Barotrauma.InteractionLabelManager", "DrawLabels", function(instance, ptable)
    ptable.PreventExecution = true
    -- Notify the player
    if Character.Controlled then
        Character.Controlled.AddMessage("Interaction labels are disabled on this server.", Color(255, 0, 255, 255), false, "1", 5)
    end
end, Hook.HookMethodType.Before)

-- Hide the top left corner crew list by preventing entries from being added to it
Hook.Patch("Megamod.HideCrewList", "Barotrauma.CrewManager", "AddCharacterToCrewList", function(instance, ptable)
    ptable.PreventExecution = true
end, Hook.HookMethodType.Before)

-- Hide the tab menu crew list if alive
Hook.Patch("Megamod.HideTabMenuCrewList", "Barotrauma.TabMenu", "CreateMultiPlayerList", function(instance, ptable)
    if Game.RoundStarted and Character.Controlled and not Character.Controlled.IsDead then
        ptable.PreventExecution = true
    end
end, Hook.HookMethodType.Before)

-- Remove hover text if non-human or invisible (hover text = text that appears when mouse is near a character)
Hook.Patch("Megamod.NoCharacterHoverText", "Barotrauma.CharacterHUD", "DrawCharacterHoverTexts", function(instance, ptable)
    local char = ptable["character"].FocusedCharacter
    if not char.IsHuman or char.InvisibleTimer > 0 then
        ptable.PreventExecution = true
    end
end, Hook.HookMethodType.Before)

-- Remove name tags / health bars if you are alive
Hook.Patch("Megamod.RemoveNameTags", "Barotrauma.Character", "DrawFront", function(instance, ptable)
    if Game.RoundStarted
    and Character.Controlled
    and not Character.Controlled.IsDead
    and instance ~= Character.Controlled -- We want to draw ourself, particularly our speech bubble
    then
        ptable.PreventExecution = true
    end
end, Hook.HookMethodType.Before)

-- Same as above basically
Hook.Patch("Megamod.RemoveNameTags2", "Barotrauma.AICharacter", "DrawFront", function(instance, ptable)
    if Game.RoundStarted
    and Character.Controlled
    and not Character.Controlled.IsDead
    and instance ~= Character.Controlled -- We want to draw ourself, particularly our speech bubble
    then
        ptable.PreventExecution = true
    end
end, Hook.HookMethodType.Before)

-- Make the message for gaining talents only appear to spectators and the person getting the talent
Hook.Patch("Megamod.TalentNotifs", "Barotrauma.Character", "OnTalentGiven", function(instance, ptable)
    if Character.Controlled and not Character.Controlled.IsDead then
        if instance.ID ~= Character.Controlled.ID then
            ptable.PreventExecution = true
        end
    end
end, Hook.HookMethodType.Before)

-- Make the message for skill gains only appear to spectators and the person whose skill increased
Hook.Patch("Megamod.SkillNotifs", "Barotrauma.Character", "AddMessage", function(instance, ptable)
    if Character.Controlled and not Character.Controlled.IsDead then
        if instance.ID ~= Character.Controlled.ID then
            local text = ptable["rawText"]
            if text and text:sub(1, 8) == "+[value]" then
                ptable.PreventExecution = true
            end
        end
    end
end, Hook.HookMethodType.Before)

-- Remove most markers on the sonar
Hook.Patch("Megamod.HideSonarMarkers", "Barotrauma.Items.Components.Sonar", "DrawMarker", function(instance, ptable)
    local t = tostring(ptable["targetIdentifier"])
    -- Ignore every marker that isn't set by an item/character
    if t ~= "Barotrauma.AITarget" then
        ptable.PreventExecution = true
    end
end, Hook.HookMethodType.Before)
