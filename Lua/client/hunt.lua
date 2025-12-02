-- Stuff that has to do with The Beast

local mm = require 'utils.misc math'

LuaUserData.RegisterType("CompleteDarkness.CompleteDarknessMod")
---@type CompleteDarkness.CompleteDarknessMod
Megamod_Client.LightMapOverride = LuaUserData.CreateStatic("CompleteDarkness.CompleteDarknessMod", false)

Megamod_Client.HorrorSFXLoaded = Megamod_Client.GetSound(Megamod_Client.Path .. "/Megamod/Sounds/horrorambience.ogg", true)
Megamod_Client.HorrorSFX = nil

-- The Beast character
Megamod_Client.TheBeast = nil

local function stop()
    Megamod_Client.LightMapOverride.HuntActive = false
    Megamod_Client.TheBeast = nil
    if Megamod_Client.HorrorSFX then
        Megamod_Client.HorrorSFX.Dispose()
        Megamod_Client.HorrorSFX = nil
    end
    Hook.RemovePatch("Megamod.NoRadioHuntsCLIENT", "Barotrauma.Networking.ChatMessage", "CanUseRadio",
    { "Barotrauma.Character", "out Barotrauma.Items.Components.WifiComponent", "System.Boolean" }, Hook.HookMethodType.Before)
    Hook.Remove("think", "Megamod.ScaryBeast")
    Hook.Remove("chatMessage", "Megamod.BeastRedText")
    Hook.Remove("think", "Megamod.UpdateBeastMessages")
    Hook.RemovePatch("Megamod.DrawBeastMessages", "Barotrauma.GUI", "Draw", Hook.HookMethodType.Before)
end
Hook.Add("roundEnd", "Megamod.RoundEnd", stop)

-- Delete all old horror sfx if we reload CL Lua
for i = 1, 31 do
    local soundChannel = Megamod_Client.GameMain.SoundManager.GetSoundChannelFromIndex(0, i)
    if soundChannel then
        local filePath = soundChannel.Sound.Filename
        local _, start = filePath:reverse():find("[/\\]")
        start = #filePath - start
        if filePath:sub(start + 2, -1) == "horrorambience.ogg" then
            soundChannel.Dispose()
        end
    end
end

Networking.Receive("mm_huntactive", function(message)
    Megamod_Client.HorrorSFX = Megamod_Client.HorrorSFXLoaded
    -- Replace the loaded sound with a playing Sound
    Megamod_Client.HorrorSFX = Megamod_Client.HorrorSFX.Play(0.45) -- 45% gain
    Megamod_Client.HorrorSFX.Looping = true
    Megamod_Client.LightMapOverride.HuntActive = true

    local shouldShake = message.ReadBoolean()
    -- Cause some screenshake the moment the hunt starts
    if shouldShake then
        Megamod_Client.GameMain.GameScreen.Cam.Shake = 100
        -- Not a great way to do it, but it works
        Timer.Wait(function()
            Megamod_Client.GameMain.GameScreen.Cam.Shake = 100
        end, 150)
        Timer.Wait(function()
            Megamod_Client.GameMain.GameScreen.Cam.Shake = 100
        end, 300)
        Timer.Wait(function()
            Megamod_Client.GameMain.GameScreen.Cam.Shake = 100
        end, 450)
    end

    -- Headsets don't work during Hunts server-side, so we need to reflect that on the client
    Hook.Patch("Megamod.NoRadioHuntsCLIENT", "Barotrauma.Networking.ChatMessage", "CanUseRadio",
    { "Barotrauma.Character", "out Barotrauma.Items.Components.WifiComponent", "System.Boolean" }, function(instance, ptable)
        ptable.PreventExecution = true
        return false
    end, Hook.HookMethodType.Before)

    local beastHead
    -- Search for The Beast endlessly until it spawns
    local function searchForBeast()
        if Megamod_Client.GetSelfClient().InGame then -- Don't try to search if we are in the lobby
            for char in Character.CharacterList do
                if tostring(char.SpeciesName) == "Truebeast" then
                    Megamod_Client.TheBeast = char
                    beastHead = char.AnimController.GetLimb(LimbType.Head)
                    return
                end
            end
        end
        Timer.Wait(function()
            if Game.RoundStarted then
                return searchForBeast()
            end
        end, 100)
    end
    searchForBeast()
    local MAX_BEAST_DIST = 500
    local MULT = 2
    local TIMER_BASE = 10
    local timer = 10
    -- Cause a bit of screenshake when The Beast is near
    Hook.Add("think", "Megamod.ScaryBeast", function()
        timer = timer - 1 -- Slightly throttled
        if timer <= 0 then
            timer = TIMER_BASE
            if not Megamod_Client.TheBeast or not Megamod_Client.GetSelfClient().InGame then return end
            -- Don't shake if we can't see The Beast
            -- or we are also a monster
            if Character.Controlled and
            (not Character.Controlled.IsHuman
            or not Character.Controlled.CanSeeTarget(Megamod_Client.TheBeast, Character.Controlled, true, false)) then
                return
            end
            local dist = Vector2.Distance(
                (Character.Controlled and Character.Controlled.WorldPosition)
                or Megamod_Client.GameMain.GameScreen.Cam.GetPosition(),
                Megamod_Client.TheBeast.WorldPosition)
                local shake = Megamod.Normalize(dist, MAX_BEAST_DIST, 0) * MULT
            -- Acts like a minimum value for screenshake, it won't go below but can go above
            if Megamod_Client.GameMain.GameScreen.Cam.Shake <= shake then
                Megamod_Client.GameMain.GameScreen.Cam.Shake = shake
            end
        end
    end)

    -- Changing chat messages from The Beast
    do
        local MESSAGE_LIFETIME = 330

        local beastMessage
        local beastMessageTimer = 0
        local beastMessageColor = Color.Transparent
        local lower = MESSAGE_LIFETIME * 0.1
        local upper = MESSAGE_LIFETIME * 0.9
        -- Change vanilla chat messages into The Beast's special text
        Hook.Add("chatMessage", "Megamod.BeastRedText", function(message, sender)
            if not Megamod_Client.GetSelfClient().InGame
            or not message
            or not sender
            or type(message) ~= "string"
            or not sender.Character
            or sender.Character.IsDead
            or sender.Character ~= Megamod_Client.TheBeast
            then return end
            if #message > 35 then
                if sender == Megamod_Client.GetSelfClient() then
                    -- Fake a message to ourself, as we can't use Megamod.SendChatMessage() on the client
                    Game.ChatBox.AddMessage(ChatMessage.Create(sender.Character.DisplayName, "Be more concise. (That message was too long, >35 chars).", ChatMessageType.Default, sender.Character, sender, 1, Color(255, 0, 255, 255)))
                end
                return true
            end
            -- Don't send our message to ourself twice (we can see it next to The Beast)
            --[[if Character.Controlled ~= sender.Character then
                -- Fake a new chat message with forced red text
                Game.ChatBox.AddMessage(ChatMessage.Create("The Beast", message, ChatMessageType.Default, sender.Character, sender, 1, Color(200, 0, 75, 255)))
            end]]
            -- Restart the timer if we already had a message
            if beastMessage then
                beastMessageTimer = 0
            end
            beastMessage = message
            return true
        end)
        -- This is hooked on 'think' instead of 'Draw' to be more consistent (update or draw, not both)
        Hook.Add("think", "Megamod.UpdateBeastMessages", function()
            if not beastMessage then return end
            beastMessageTimer = beastMessageTimer + 1
            -- The color starts transparent, transitions to opaque from 0%-10% of its lifetime,
            -- then transitions to transparent again at 90%-100% of its lifetime
            local a = 0
            if beastMessageTimer < lower then
                -- 0%-10%
                a = 255 * Megamod.Normalize(beastMessageTimer, 0, lower)
            elseif beastMessageTimer > upper then
                -- 90%-100%
                a = 255 * Megamod.Normalize(beastMessageTimer, MESSAGE_LIFETIME, upper)
            else
                -- 10%-90%
                a = 255
            end
            a = math.floor(a)
            if a < 0 then a = 0
            elseif a > 255 then a = 255 end
            beastMessageColor = Color(200, 0, 75, a)
            if beastMessageTimer >= MESSAGE_LIFETIME then
                beastMessage = nil
                beastMessageTimer = 0
            end
        end)
        Hook.Patch("Megamod.DrawBeastMessages", "Barotrauma.GUI", "Draw", function(instance, ptable)
            if not beastMessage or not Megamod_Client.TheBeast then return end
            if Character.Controlled
            and not Character.Controlled.IsDead
            and not Character.Controlled.CanSeeTarget(Megamod_Client.TheBeast, Character.Controlled, true, false) then
                return
            end
            local pos = beastHead.WorldPosition
            if Megamod_Client.TheBeast.IsFlipped then -- Facing left
                pos.X = pos.X - (25 + 3.95 * #beastMessage)
            else -- Facing right
                pos.X = pos.X + 25
            end
            GUI.DrawString(ptable["spriteBatch"], mm.WorldToScreen(pos),
                beastMessage, beastMessageColor, Color(0, 0, 0, beastMessageColor.A * 0.5), 0, GUI.Style.SmallFont)
        end, Hook.HookMethodType.Before)
    end
end)

-- We need to know if a Hunt is active if we reload CL Lua midround
local msg = Networking.Start("mm_huntactive")
msg.WriteByte(0)
Networking.Send(msg)
