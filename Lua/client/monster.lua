-- Being an antagonist in the Monster ruleset


local frame = GUI.Frame(GUI.RectTransform(Vector2(1, 1)), nil)
frame.CanBeFocused = false
Hook.Patch("Barotrauma.GameScreen", "AddToGUIUpdateList", function()
    frame.AddToGUIUpdateList()
end)

--[[local dropDown = GUI.DropDown(GUI.RectTransform(Vector2(0.15, 0.15), frame.RectTransform, GUI.Anchor.TopCenter), "Monster List", 3, nil, false)
dropDown.OnSelected = function(guiComponent, object)
    print(object)
end]]

local exitButton = GUI.Button(GUI.RectTransform(Vector2(0.15, 0.15), frame.RectTransform, GUI.Anchor.TopCenter), "Stop Controlling Monster", GUI.Alignment.Center, "GUIButton")
exitButton.Visible = false
exitButton.OnClicked = function()
    if Character.Controlled and not Character.Controlled.IsDead then
        local msg = Networking.Start("mm_monster")
        msg.WriteBoolean(false)
        Networking.Send(msg)
    end
end

Networking.Receive("mm_monster", function(message)
    local bool = message.ReadBoolean()
    Megamod_Client.LightMapOverride.IsMonsterAntagonist = bool
    if bool then
        if Character.Controlled and not Character.Controlled.IsDead then
            exitButton.Visible = true
            --dropDown.Visible = false
        else
            exitButton.Visible = false
            --dropDown.Visible = true
        end
    end
end)

local cooldown = 0
local function cooldownLoop()
    cooldown = cooldown - 1
    if cooldown <= 0 then return end
    Timer.Wait(function()
        cooldownLoop()
    end, 1000)
end

local function setSuicideButtonVisible(bool)
    if not Character.Controlled
    or not Character.Controlled.CharacterHealth
    or not Character.Controlled.CharacterHealth.SuicideButton then return end
    local button = Character.Controlled.CharacterHealth.SuicideButton
    if bool then
        button.Visible = true
    else
        button.Visible = false
    end
end

--DROPDOWNUPDATE_BASE = 15
--local dropDownUpdateTimer = DROPDOWNUPDATE_BASE
local closestChar
local wasMonsterAntag = false
LuaUserData.MakeFieldAccessible(Descriptors["Barotrauma.GameMain"], "spriteBatch")
Hook.Add("think", "Megamod.MonsterGUIThink", function()
    if not Megamod_Client.LightMapOverride.IsMonsterAntagonist then
        if wasMonsterAntag then
            wasMonsterAntag = false
            --dropDown.Visible = false
            exitButton.Visible = false
            closestChar = nil
            setSuicideButtonVisible(true)
        end
        return
    end
    wasMonsterAntag = true
    --dropDownUpdateTimer = dropDownUpdateTimer - 1
    if Character.Controlled and not Character.Controlled.IsDead then
        setSuicideButtonVisible(false)
        --dropDown.Visible = false
        exitButton.Visible = true
        closestChar = nil
        return
    else
        setSuicideButtonVisible(true)
        --dropDown.Visible = true
        exitButton.Visible = false
    end
    local function findValidMonsters()
        local monsters = {}
        for char in Character.CharacterList do
            if char
            and not char.IsDead
            and not char.IsHuman
            and not Megamod.BlacklistedPlayerMonsters[tostring(char.SpeciesName)] then
                table.insert(monsters, char)
            end
        end
        return monsters
    end
    --[[if dropDownUpdateTimer <= 0 then
        dropDownUpdateTimer = DROPDOWNUPDATE_BASE
        dropDown.ClearChildren()
        local monsters = {}
        for monster in findValidMonsters() do
            monsters[tostring(monster.DisplayName)] = monster
        end
        for str, monster in pairs(monsters) do
            dropDown.AddItem(str, monster)
        end
    end]]
    local closestDist = 100
    local foundChar
    local monsters = findValidMonsters()
    for monster in monsters do
        local dist = Vector2.Distance(Megamod.ScreenToWorld(PlayerInput.MousePosition), monster.WorldPosition)
        if dist < closestDist then
            closestChar = monster
            closestDist = dist
            foundChar = true
        end
    end
    if not foundChar then closestChar = nil return end
    if PlayerInput.PrimaryMouseButtonClicked() then
        if cooldown > 0 then
            GUI.AddMessage("Please don't spam control monsters.", Color(255, 0, 255, 255), 5)
            return
        end
        cooldown = 5
        cooldownLoop()
        local msg = Networking.Start("mm_monster")
        msg.WriteBoolean(true)
        msg.WriteUInt64(closestChar.ID)
        Networking.Send(msg)
    end
end)

Hook.Patch("Megamod.ControlMonsterCursorText", "Barotrauma.GUI", "Draw", function(instance, ptable)
    if closestChar then
        GUI.DrawString(ptable["spriteBatch"], PlayerInput.MousePosition - Vector2(0, -30),
            string.format("[%s] Control '%s'", tostring(PlayerInput.PrimaryMouseLabel), tostring(closestChar.DisplayName)),
            Color(255, 0, 255, 255), Color.Black * 0.5, 0, GUI.Style.SmallFont)
    end
end, Hook.HookMethodType.Before)
