-- Stuff that has to do with (being hunted by) The Beast

Megamod_Client.HorrorSFXLoaded = Megamod_Client.GetSound(Megamod_Client.Path .. "/Megamod/Sounds/horrorambience.ogg", true)
Megamod_Client.HorrorSFX = nil

-- The Beast character
Megamod_Client.TheBeast = nil

local function stop()
    Megamod_Client.LightMapOverride.HuntActive = false
    Megamod.CS_Shared.ForceInWater = false
    Megamod_Client.TheBeast = nil
    if Megamod_Client.HorrorSFX then
        Megamod_Client.HorrorSFX.Dispose()
        Megamod_Client.HorrorSFX = nil
    end
    -- This doesn't work for some reason
    --[[Hook.RemovePatch("Megamod.NoRadioHuntsCLIENT", "Barotrauma.Networking.ChatMessage", "CanUseRadio",
    { "Barotrauma.Character", "out Barotrauma.Items.Components.WifiComponent", "System.Boolean" }, Hook.HookMethodType.Before)]]
    Hook.Remove("think", "Megamod.ScaryBeast")
    Hook.Remove("chatMessage", "Megamod.BeastRedText")
    Hook.Remove("think", "Megamod.UpdateBeastMessages")
    Hook.RemovePatch("Megamod.DrawBeastMessages", "Barotrauma.GUI", "Draw", Hook.HookMethodType.Before)
end
Hook.Add("roundEnd", "Megamod.RoundEnd", stop)

-- Delete all old horror sfx if we reload CL Lua
for i = 1, 31 do
    local soundChannel = Megamod.GameMain.SoundManager.GetSoundChannelFromIndex(0, i)
    if soundChannel then
        local filePath = soundChannel.Sound.Filename
        local _, start = filePath:reverse():find("[/\\]")
        start = #filePath - start
        if filePath:sub(start + 2, -1) == "horrorambience.ogg" then
            soundChannel.Dispose()
        end
    end
end

-- Headsets don't work during Hunts server-side, so we need to reflect that on the client
Hook.Patch("Megamod.NoRadioHuntsCLIENT", "Barotrauma.Networking.ChatMessage", "CanUseRadio",
{ "Barotrauma.Character", "out Barotrauma.Items.Components.WifiComponent", "System.Boolean" }, function(instance, ptable)
    if Megamod_Client.LightMapOverride.HuntActive then
        ptable.PreventExecution = true
        return false
    end
end, Hook.HookMethodType.Before)

Networking.Receive("mm_beastwater", function(message)
    local bool = message.ReadBoolean()
    Megamod.CS_Shared.ForceInWater = bool
end)

Networking.Receive("mm_beastinvis", function(message)
    local bool = message.ReadBoolean()
    if Megamod_Client.TheBeast then
        Megamod_Client.ToggleInvis(Megamod_Client.TheBeast, bool)
    end
end)

Hook.Add("character.created", "Megamod.FindBeastClient", function(character)
    if not Megamod_Client.TheBeast and tostring(character.SpeciesName) == "Truebeast" then
        Megamod_Client.TheBeast = character
    end
end)
-- Search for The Beast endlessly; this fixes any edge cases
-- while not being overly performance intensive
local function searchForBeast()
    if Megamod_Client.GetSelfClient() -- This is nil on runtime
    and Megamod_Client.GetSelfClient().InGame -- Don't try to search if we are in the lobby
    and not Megamod_Client.TheBeast then
        for char in Character.CharacterList do
            if tostring(char.SpeciesName) == "Truebeast" then
                Megamod_Client.TheBeast = char
                break
            end
        end
    end
    -- Also clean up if The Beast dies
    if Megamod_Client.TheBeast
    and (Megamod_Client.TheBeast.IsDead or Megamod_Client.TheBeast.Removed) then
        Megamod_Client.TheBeast = nil
    end
    Timer.Wait(function()
        return searchForBeast()
    end, 5000)
end
searchForBeast()

do
    local MAX_BEAST_DIST = 500
    local MULT = 2
    local TIMER_BASE = 10
    local timer = TIMER_BASE
    -- Cause a bit of screenshake when The Beast is near
    Hook.Add("think", "Megamod.ScaryBeast", function()
        if not Megamod_Client.TheBeast
        or Megamod_Client.TheBeast.IsDead then return end
        timer = timer - 1 -- Slightly throttled
        if timer <= 0 then
            timer = TIMER_BASE
            if not Megamod_Client.GetSelfClient().InGame then return end
            -- Don't shake if we can't see The Beast
            -- or we are also a monster
            if Character.Controlled and
            (not Character.Controlled.IsHuman
            or not Character.Controlled.CanSeeTarget(Megamod_Client.TheBeast, Character.Controlled, true, false)) then
                return
            end
            local dist = Vector2.Distance(
                (Character.Controlled and Character.Controlled.WorldPosition)
                or Megamod.GameMain.GameScreen.Cam.GetPosition(),
                Megamod_Client.TheBeast.WorldPosition)
            local shake = Megamod.Normalize(dist, MAX_BEAST_DIST, 0) * MULT
            -- Acts like a minimum value for screenshake, it won't go below but can go above
            if Megamod.GameMain.GameScreen.Cam.Shake <= shake then
                Megamod.GameMain.GameScreen.Cam.Shake = shake
            end
        end
    end)
end

-- Changing chat messages from The Beast
do
    local MESSAGE_LIFETIME = 330
    local MAX_LENGTH = 35

    local beastMessage
    local beastMessageTimer = 0
    local beastMessageColor = Color.Transparent
    local lower = MESSAGE_LIFETIME * 0.1
    local upper = MESSAGE_LIFETIME * 0.9
    -- Change vanilla chat messages into The Beast's special text
    Hook.Add("chatMessage", "Megamod.BeastRedText", function(message, sender)
        if not Megamod_Client.TheBeast
        or not Megamod_Client.GetSelfClient().InGame
        or not message
        or not sender
        or type(message) ~= "string"
        or not sender.Character
        or sender.Character.IsDead
        or sender.Character ~= Megamod_Client.TheBeast
        then return end
        if #message > MAX_LENGTH then
            if sender == Megamod_Client.GetSelfClient() then
                -- Fake a message to ourself, as we can't use Megamod.SendChatMessage() on the client
                Game.ChatBox.AddMessage(ChatMessage.Create(sender.Character.DisplayName, "That message was too long (>" .. tostring(MAX_LENGTH) .. " chars).", ChatMessageType.Default, sender.Character, sender, 1, Color(255, 0, 255, 255)))
            end
            return true
        end
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
        -- Prevents people from modifying Megamod.BeastRedText to allow super long messages,
        -- we block them on other clients
        if #beastMessage > MAX_LENGTH then return end
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
        local pos = Megamod_Client.TheBeast.AnimController.GetLimb(LimbType.Head).WorldPosition
        if Megamod_Client.TheBeast.IsFlipped then -- Facing left
            pos.X = pos.X - (25 + 3.95 * #beastMessage)
        else -- Facing right
            pos.X = pos.X + 25
        end
        GUI.DrawString(ptable["spriteBatch"], Megamod.WorldToScreen(pos),
            beastMessage, beastMessageColor, Color(0, 0, 0, beastMessageColor.A * 0.85), 0, GUI.Style.SmallFont)
    end, Hook.HookMethodType.Before)
end

-- Receiving this message means that a Hunt is started,
-- it does not end midround (only ends if the round ends)
Networking.Receive("mm_huntactive", function(message)
    Megamod_Client.HorrorSFX = Megamod_Client.HorrorSFXLoaded
    -- Replace the loaded sound with a playing sound
    Megamod_Client.HorrorSFX = Megamod_Client.HorrorSFX.Play(0.45) -- 45% gain
    Megamod_Client.HorrorSFX.Looping = true
    Megamod_Client.LightMapOverride.HuntActive = true

    local shouldShake = message.ReadBoolean()
    -- Cause some screenshake the moment the hunt starts
    if shouldShake then
        Megamod.GameMain.GameScreen.Cam.Shake = 100
        -- Not a great way to do it, but it works
        Timer.Wait(function()
            Megamod.GameMain.GameScreen.Cam.Shake = 100
        end, 150)
        Timer.Wait(function()
            Megamod.GameMain.GameScreen.Cam.Shake = 100
        end, 300)
        Timer.Wait(function()
            Megamod.GameMain.GameScreen.Cam.Shake = 100
        end, 450)
    end
end)

-- We need to know if a Hunt is active if we reload CL Lua midround
local msg = Networking.Start("mm_huntactive")
Networking.Send(msg)
