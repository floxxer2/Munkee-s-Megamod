-- GUI for being an antagonist in the Monster ruleset


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

local monsters = {}

local function update()
    local removeKeys = {}
    for k, monster in pairs(monsters) do
        if not monster
        or monster.IsDead then
            table.insert(removeKeys, k)
        end
    end
    for removeKey in removeKeys do
        table.remove(monsters, removeKey)
    end
    for char in Character.CharacterList do
        if char
        and not char.IsHuman
        and not char.IsDead
        and not Megamod.BlacklistedPlayerMonsters[tostring(char.SpeciesName)] then
            table.insert(monsters, char)
        end
    end
    for monster in monsters do
        if not monster then
            
        end
    end
end

local function draw(ptable)
    for monster in monsters do
        
    end
end

local UPDATE_TIMER = 5
function Megamod_Client.ToggleDimeLocator(toggle)
    if toggle and not Megamod_Client.DimeLocatorActive then
        Megamod_Client.DimeLocatorActive = true
        update() -- Update once immediately
        local timer = 0
        Hook.Patch("Megamod.DimeLocator", "Barotrauma.GUI", "Draw", function(instance, ptable)
            draw(ptable)
            if timer >= UPDATE_TIMER then
                timer = 0
                update()
            else
                timer = timer + 1
            end
        end)
    elseif not toggle and Megamod_Client.DimeLocatorActive then
        Megamod_Client.DimeLocatorActive = false
        Hook.RemovePatch("Megamod.DimeLocator", "Barotrauma.GUI", "Draw", Hook.HookMethodType.Before)
    end
end
