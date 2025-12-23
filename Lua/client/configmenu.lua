-- Highly based on easySettings by Evil Factory >>

-- Each has a ["value"] and ["defaultValue"] that should be set by mm_getprefs
Megamod_Client.Prefs = {
    -- Make sure that the antag names (e.g. "Traitor") EXACTLY match the ruleset's antag name
    Antagonists = {
        Traitor = {
            guiType = "tickbox",
            defaultValue = true,
        },
        Monster = {
            guiType = "tickbox",
            defaultValue = true,
        },
        Raider = {
            guiType = "tickbox",
            defaultValue = true,
        },
        Beast = {
            guiType = "tickbox",
            defaultValue = false,
        },
    },
}

local GUIComponent = LuaUserData.CreateStatic("Barotrauma.GUIComponent")

local function makeTickBox(parent, text, onSelected, state)
	if state == nil then
		state = true
	end

	local tickBox = GUI.TickBox(GUI.RectTransform(Vector2(0.2, 0.2), parent.RectTransform), text)
	tickBox.Selected = state
	tickBox.OnSelected = function()
		onSelected(tickBox.State == GUIComponent.ComponentState.Selected)
	end

	return tickBox
end

--[[local function makeDropDown(frame)

end]]

local amCB
Timer.Wait(function()
    amCB = Megamod.CertifiedBeasters[Megamod_Client.GetSelfClient().SteamID] == true
    Megamod_Client.Prefs.Antagonists.Beast.defaultValue = amCB
end, 100)

local function sendUpdate()
    local msg = Networking.Start("mm_changeprefs")
    local amountPrefs = 0
    for _, tbl in pairs(Megamod_Client.Prefs) do
        for name, _ in pairs(tbl) do
            if not amCB and name == "Beast" then
                goto continue
            end
            do
                amountPrefs = amountPrefs + 1
            end
            ::continue::
        end
    end
    msg.WriteByte(amountPrefs)
    for groupName, groupTbl in pairs(Megamod_Client.Prefs) do
        for prefName, prefTbl in pairs(groupTbl) do
            if not amCB and prefName == "Beast" then
                goto continue
            end
            do
                msg.WriteString(prefName)
                if prefTbl.value == nil then
                    prefTbl.value = prefTbl.defaultValue
                end
                if type(prefTbl.value) == "boolean" then
                    msg.WriteBoolean(prefTbl.value)
                end
            end
            ::continue::
        end
    end
    Networking.Send(msg)
end

-- Sync client-side prefs with the server
Networking.Receive("mm_getprefs", function(message)
    local amount = message.ReadByte()
    for i = 1, amount do
        local prefName = message.ReadString()
        -- Temporary until more value types are implemented
        local prefValue = message.ReadBoolean()
        for groupName, groupTbl in pairs(Megamod_Client.Prefs) do
            for tblPrefName, prefTbl in pairs(groupTbl) do
                if tostring(tblPrefName) == tostring(prefName) then
                    prefTbl.value = prefValue
                    prefTbl.defaultValue = prefValue
                    break
                end
            end
        end
    end
end)
Timer.Wait(function()
    local msg = Networking.Start("mm_getprefs")
    Networking.Send(msg)
end, 100)

local function saveButton(parent)
	local button = GUI.Button(
		GUI.RectTransform(Vector2(0.32, 0.05), parent.RectTransform, GUI.Anchor.BottomLeft),
		"Save",
		GUI.Alignment.Center,
		"GUIButton"
	)

	button.OnClicked = function()
        sendUpdate()
		GUI.GUI.TogglePauseMenu()
	end

	return button
end

local function closeButton(parent)
	local button = GUI.Button(
		GUI.RectTransform(Vector2(0.32, 0.05), parent.RectTransform, GUI.Anchor.BottomCenter),
		"Cancel",
		GUI.Alignment.Center,
		"GUIButton"
	)

	button.OnClicked = function()
		GUI.GUI.TogglePauseMenu()

	end

	return button
end

local function resetMessage(parent)
	local messageBox = GUI.MessageBox(
		"Reset",
		"Reset TBG settings to default?",
		{ "Yes", "No" }
	)
	messageBox.DrawOnTop = true
	messageBox.Text.TextAlignment = GUI.Alignment.Center
	messageBox.Buttons[1].OnClicked = function()
		for groupName, groupTbl in pairs(Megamod_Client.Prefs) do
            for prefName, prefTbl in pairs(groupTbl) do
                prefTbl["value"] = prefTbl["defaultValue"]
            end
        end
        sendUpdate()
		messageBox.Close()
        GUI.GUI.TogglePauseMenu()
	end
	messageBox.Buttons[2].OnClicked = function()
		messageBox.Close()
	end
	return messageBox
end

local function resetButton(parent)
	local button = GUI.Button(
		GUI.RectTransform(Vector2(0.32, 0.05), parent.RectTransform, GUI.Anchor.BottomRight),
		"Reset",
		GUI.Alignment.Center,
		"GUIButton"
	)

	button.OnClicked = function()
		resetMessage(parent)
	end
	return button
end

local function GetChildren(comp)
	local tbl = {}
	for value in comp.GetAllChildren() do
		table.insert(tbl, value)
	end
	return tbl
end

Hook.Patch("Barotrauma.GUI", "TogglePauseMenu", {}, function()
	if GUI.GUI.PauseMenuOpen then
		local frame = GUI.GUI.PauseMenu

		local list = GetChildren(GetChildren(frame)[2])[1]

		local button = GUI.Button(
			GUI.RectTransform(Vector2(1, 0.1), list.RectTransform),
			"TBG Preferences",
			GUI.Alignment.Center,
			"GUIButtonSmall"
		)
		button.OnClicked = function() Megamod_Client.PreferenceMenu(frame) end
	end
end, Hook.HookMethodType.After)

function Megamod_Client.PreferenceMenu(frame)
    local menuContent = GUI.Frame(GUI.RectTransform(Vector2(0.3, 0.6), frame.RectTransform, GUI.Anchor.Center))
    local menuList = GUI.ListBox(GUI.RectTransform(Vector2(1, 0.95), menuContent.RectTransform, GUI.Anchor.TopCenter))

    GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), menuList.Content.RectTransform), "TBG Preferences", nil, nil, GUI.Alignment.Center)
    local mainLayout = GUI.LayoutGroup(GUI.RectTransform(Vector2(0.95, 0.95), menuList.Content.RectTransform, GUI.Anchor.Center, GUI.Pivot.Center), false)
    for groupName, groupTbl in pairs(Megamod_Client.Prefs) do
        local row = GUI.LayoutGroup(GUI.RectTransform(Vector2(1, 0.12), mainLayout.RectTransform), true)
        GUI.TextBlock(GUI.RectTransform(Vector2(0.2, 0), row.RectTransform), groupName, nil, nil, GUI.Alignment.Center)
        for prefName, prefTbl in pairs(groupTbl) do
            -- Value is a boolean
            if prefTbl.guiType == "tickbox"
            and not (prefName == "Beast" and not amCB) -- Don't show the Beast tickbox if we're not a CB
            then
                makeTickBox(row, prefName, function(state)
                    Megamod_Client.Prefs[groupName][prefName]["value"] = state
                end, prefTbl.value)
            end
        end
    end
    local row = GUI.LayoutGroup(GUI.RectTransform(Vector2(1, 0.12), mainLayout.RectTransform), true)
    saveButton(row)
    closeButton(row)
    resetButton(row)
end
