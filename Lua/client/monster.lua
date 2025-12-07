-- Being an antagonist in the Monster ruleset


local frame = GUI.Frame(GUI.RectTransform(Vector2(1, 1)), nil)
frame.CanBeFocused = false

local exitButton = GUI.Button(GUI.RectTransform(Vector2(0.15, 0.15), frame.RectTransform, GUI.Anchor.TopCenter), "Stop Controlling Monster", GUI.Alignment.Center, "GUIButton")
exitButton.Visible = false
exitButton.OnClicked = function()
    local msg = Networking.Start("mm_monster")
    msg.WriteBoolean(false)
    Networking.Send(msg)
end

Hook.Patch("Barotrauma.GameScreen", "AddToGUIUpdateList", function()
    frame.AddToGUIUpdateList()
end)

Networking.Receive("mm_monster", function(message)
    Megamod_Client.LightMapOverride.IsMonsterAntagonist = message.ReadBoolean()
end)

local function onClicked()
    local closestChar
    local closestDist = 500
    for char in Character.CharacterList do
        if char
        and not char.IsDead
        --and not char.IsHuman
        then
            local dist = Vector2.Distance(Megamod.WorldToScreen(PlayerInput.MousePosition), char.WorldPosition)
            if dist < closestDist then
                closestChar = char
                closestDist = dist
            end
        end
    end
    if not closestChar then return end
    local msg = Networking.Start("mm_monster")
    msg.WriteBoolean(true)
    msg.WriteUInt64(closestChar.ID)
    Networking.Send(msg)
end

Hook.Add("think", "Megamod.", function()
    if not Megamod_Client.LightMapOverride.IsMonsterAntagonist then return end
    if PlayerInput.PrimaryMouseButtonClicked() then
        onClicked()
    end
end)
