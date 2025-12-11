-- "client.lua" is all misc stuff that doesn't deserve its own file

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


-- When someone is revived via cloning, set their team to 1 client-side
-- This makes their name normal-colored, instead of red like they're a pirate
Networking.Receive("mm_clone", function(message)
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

-- Sent to you when you become a traitor / need to sync being a traitor
-- IsTraitor allows vanilla traitor features, such as sabotage and hidden fabricator recipes
Networking.Receive("mm_traitor", function(message)
    if not Character.Controlled or not Character.Controlled.IsHuman then return end
    Character.Controlled.IsTraitor = message.ReadBoolean()
end)

-- We need to know if we're a traitor if we reload CL Lua midround
if Megamod_Client.GetSelfClient() and Megamod_Client.GetSelfClient().InGame then
    local msg = Networking.Start("mm_traitor")
    Networking.Send(msg)
end

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

-- Prevent ID card monitoring on status monitors (op for finding traitors)
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

--[=[local INVIS_RATE = 0.07 -- IK it's not deltatime'd but who cares
local invisChars = {}
local charTbl = {}

-- This prevents reloading CL Lua to see invisible characters
for char in Character.CharacterList do
    if char.InvisibleTimer > 0 then
        charTbl[char] = {}
        for limb in char.AnimController.Limbs do
            charTbl[char][limb] = 1
        end
    end
end

do
    local TIMER_BASE = 10
    local timer = 10
    -- Check all characters every 0.1 seconds to see if they're going invisible
    Hook.Add("think", "Megamod.Invis1", function()
        timer = timer - 1
        if timer <= 0 then
            timer = TIMER_BASE
            for char in Character.CharacterList do
                if char and not char.IsDead and char.InvisibleTimer > 0 and not charTbl[char] then
                    table.insert(invisChars, char)
                end
            end
        end
    end)
end
-- Update invisible characters (Smoothly transition opaque / transparent when meant to be invisible)
Hook.Add("think", "Megamod.Invis2", function()
    local removeKeys = {}
    for k, char in pairs(invisChars) do
        if char and not char.IsDead then
            local isInvis = char.InvisibleTimer > 0
            if isInvis then
                if not charTbl[char] then
                    charTbl[char] = {}
                    for limb in char.AnimController.Limbs do
                        charTbl[char][limb] = 0
                    end
                else
                    for limb, val in pairs(charTbl[char]) do
                        if val < 1 then
                            charTbl[char][limb] = charTbl[char][limb] + INVIS_RATE
                        else
                            charTbl[char][limb] = 1
                        end
                    end
                end
            elseif not isInvis and charTbl[char] then
                -- Become opaque again
                for limb, val in pairs(charTbl[char]) do
                    if val > 0 then
                        charTbl[char][limb] = charTbl[char][limb] - INVIS_RATE
                    else
                        charTbl[char] = nil
                        table.insert(removeKeys, k)
                        break
                    end
                end
            end
        else
            table.insert(removeKeys, k)
        end
    end
    for removeKey in removeKeys do
        table.remove(invisChars, removeKey)
    end
end)
-- Remove charTbl if the character is disabled
-- Also, keep drawing even if meant to be invisible, as we fade in/out
Hook.Patch("Megamod.Invis3", "Barotrauma.Character", "Draw", function(instance, ptable)
    ptable.PreventExecution = true -- Character.Draw() is simple enough to just override completely
    if not instance.Enabled then
        charTbl[instance] = nil
        return
    end
    instance.AnimController.Draw(ptable["spriteBatch"], ptable["cam"])
end, Hook.HookMethodType.Before)

--[[local function multiplyColorByScale(color, scale)
    return Color(color.R * scale, color.G * scale, color.B * scale, color.A * scale)
end
local function multiplyColorByColor(color1, color2)
    return Color(
        math.floor(color1.R * color2.R / 255),
        math.floor(color1.G * color2.G / 255),
        math.floor(color1.B * color2.B / 255),
        math.floor(color1.A * color2.A / 255)
    )
end
LuaUserData.MakeFieldAccessible(Descriptors["Barotrauma.Limb"], "burnOverLayStrength")]]
Hook.Patch("Megamod.Invis4", "Barotrauma.Limb", "Draw", function(instance, ptable)
    if not charTbl[instance.character] then return end
    local scaler = charTbl[instance.character][instance]
    if scaler < 0 then return end -- <0 = just got damaged, don't draw as invis

    --[[local ogColor
    local spriteParams = instance.Params.GetSprite()
    if not spriteParams then return end
    local burn
    if spriteParams.IgnoreTint then
        burn = 0
    else
        burn = instance.burnOverLayStrength
    end
    local brightness = math.max(1 - burn, 0.2)
    local tintedColor = spriteParams.Color
    if not spriteParams.IgnoreTint then
        tintedColor = multiplyColorByColor(tintedColor, instance.ragdoll.RagdollParams.Color)
        if instance.character and instance.character.Info then
            tintedColor = multiplyColorByColor(tintedColor, instance.character.Info.Head.SkinColor)
        end
        if instance.character.CharacterHealth.FaceTint.A > 0 and instance.type == LimbType.Head then
            tintedColor = Color.Lerp(tintedColor, instance.character.CharacterHealth.FaceTint.Opaque(), instance.character.CharacterHealth.FaceTint.A / 255.0)
        end
        if instance.character.CharacterHealth.BodyTint.A > 0 then
            tintedColor = Color.Lerp(tintedColor, instance.character.CharacterHealth.BodyTint.Opaque(), instance.character.CharacterHealth.BodyTint.A / 255.0)
        end
    end
    ogColor = Color(multiplyColorByScale(tintedColor, brightness), tintedColor.A)]]

    local num = (1 - scaler)
    local c = 60 * num
    ptable["overrideColor"] = Color(c, c, c, 255 * num)
end, Hook.HookMethodType.Before)

-- Make things spawning in use the fade animation
Hook.Add("character.created", "Megamod.CharacterCreated", function(char)
    charTbl[char] = {}
    for limb in char.AnimController.Limbs do
        charTbl[char][limb] = 1
    end
end)]=]

-- Make invisibility go away on taking damage
Hook.Add("character.applyDamage", "Megamod.CharacterDamage", function(characterHealth, attackResult, hitLimb, allowStacking)
    local char = characterHealth.Character
    char.InvisibleTimer = 0
    --[[if charTbl[char] then
        for k, _ in pairs(charTbl[char]) do
            charTbl[char][k] = -5
        end
    end]]
end)
