-- Admin control panel

-- This is useless for non-admins
if not Megamod_Client.IsAdmin then return end

Megamod_Client.RuleSetTable = {}
Megamod_Client.RuleSetTable.RoundType = 0
Megamod_Client.RuleSetTable.RuleSets = {}
Megamod_Client.RuleSetTable.Enabled = true
Megamod_Client.DropDownTbl = {}

--[[Hook.Add("roundStart", "Megamod.RoundStartClient", function()
    if Megamod_Client.RuleSetTable.Enabled and #Client.ClientList >= 5 then
        Megamod_Client.RuleSetTable.RoundType = 1
    else
        Megamod_Client.RuleSetTable.RoundType = 2
    end
end)]]

Hook.Add("roundEnd", "Megamod.RoundEndClient", function()
    Megamod_Client.RuleSetTable.RoundType = 0
    for _, tbl in pairs(Megamod_Client.RuleSetTable.RuleSets) do
        tbl.SelectedPlayers = {}
        tbl.Strength = 0
        tbl.FailReason = ""
    end
end)

-- Updates on the state of the ruleset manager, only admins receive the net messages
local funcs = {
    -- Load sync
    [0] = function(message)
        Megamod_Client.RuleSetTable.RoundType = message.ReadByte()
        local amountRuleSets = message.ReadByte()
        for i = 1, amountRuleSets do
            local ruleSetName = message.ReadString()
            table.insert(Megamod_Client.DropDownTbl, { ruleSetName, i - 1 })
            Megamod_Client.RuleSetTable.RuleSets[ruleSetName] = {
                Strength = message.ReadByte(),
                SelectedPlayers = {},
                FailReason = message.ReadString(),
            }
            local amountSelectedPlayers = message.ReadByte()
            for e = 1, amountSelectedPlayers do
                local id = message.ReadByte()
                local antagName = message.ReadString()
                local client
                for potentialClient in Client.ClientList do
                    if potentialClient.SessionId == id then
                        client = potentialClient
                        break
                    end
                end
                if not client then return end
                Megamod_Client.RuleSetTable.RuleSets[ruleSetName].SelectedPlayers[client] = antagName
            end
        end
    end,
    -- Roundstart roundtype
    [1] = function(message)
        local roundType = message.ReadByte()
        Megamod_Client.RuleSetTable.RoundType = roundType
    end,
    -- Ruleset drafted
    [2] = function(message)
        local ruleSetName = message.ReadString()
        local strength = message.ReadByte()
        Megamod_Client.RuleSetTable.RuleSets[ruleSetName].Strength = strength
    end,
    -- Ruleset selected a player
    [3] = function(message)
        local ruleSetName = message.ReadString()
        local id = message.ReadByte() -- Session ID of the selected player
        local antagName = message.ReadString()
        local client
        for potentialClient in Client.ClientList do
            if potentialClient.SessionId == id then
                client = potentialClient
                break
            end
        end
        if not client then return end
        Megamod_Client.RuleSetTable.RuleSets[ruleSetName].SelectedPlayers[client] = antagName
    end,
    -- Ruleset failed
    [4] = function(message)
        local ruleSetName = message.ReadString()
        local reason = message.ReadString()
        Megamod_Client.RuleSetTable.RuleSets[ruleSetName].FailReason = reason
    end,
    -- Ruleset manager toggled
    [5] = function(message)
        Megamod_Client.RuleSetTable.Manager = message.ReadBoolean()
    end,
}
Networking.Receive("mm_ruleset", function(message)
    local id = message.ReadByte()
    funcs[id](message)
end)

-- We need to sync every time CL Lua (re)loads
local msg = Networking.Start("mm_ruleset")
msg.WriteByte(0)
Networking.Send(msg)

-- Highly based on easySettings by Evil Factory >>

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
			"Control Panel",
			GUI.Alignment.Center,
			"GUIButtonSmall"
		)
		button.OnClicked = function() Megamod_Client.RuleSetMenu(frame) end
	end
end, Hook.HookMethodType.After)

local roundTypeEnum = {
    [0] = "In Lobby",
    [1] = "Serious",
    [2] = "Silly",
}

local function combineRuleSetInfo()
    local str = ""
    local roundType = Megamod_Client.RuleSetTable.RoundType
    str = str .. roundType .. " - (" .. roundTypeEnum[roundType] .. ")\n"
    for ruleSetName, ruleSet in pairs(Megamod_Client.RuleSetTable.RuleSets) do
        str = str .. ruleSetName .. " - (" .. ruleSet.Strength .. ")\n"
        if ruleSet.FailReason ~= "" then
            str = str .. ruleSet.FailReason .. "\n"
        end
        for selectedPlayer, antagName in pairs(ruleSet.SelectedPlayers) do
            str = str .. selectedPlayer.Name .. " - '" .. antagName .. "'\n"
        end
    end
    -- Remove the last newline
    str = str:sub(1, -2)
    return str
end

-- Count every newline in combineRuleSetInfo()
local function getTextSize()
    local str = combineRuleSetInfo()
    local newLines = 0
    string.gsub(str, "\n", function()
        newLines = newLines + 1
    end)
    return 0.05 * newLines
end

function Megamod_Client.RuleSetMenu(frame)
    local menuContent = GUI.Frame(GUI.RectTransform(Vector2(0.3, 0.6), frame.RectTransform, GUI.Anchor.Center))
    local menuList = GUI.ListBox(GUI.RectTransform(Vector2(1, 0.95), menuContent.RectTransform, GUI.Anchor.TopCenter))

    GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), menuList.Content.RectTransform), "Control Panel", nil, nil, GUI.Alignment.Center)

    GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), menuList.Content.RectTransform), "- Rulesets -", nil, nil, GUI.Alignment.Center)

    local tickBox = GUI.TickBox(GUI.RectTransform(Vector2(1, 0.2), menuList.Content.RectTransform), "Manager")
    tickBox.Selected = Megamod_Client.RuleSetTable.Enabled
    tickBox.OnSelected = function()
        local msg = Networking.Start("mm_ruleset")
        msg.WriteByte(1)
        msg.WriteBoolean(tickBox.Selected)
        Networking.Send(msg)
        Megamod_Client.RuleSetTable.Enabled = tickBox.Selected
    end

    --[[local clicked = false
    -- End button requires double clicking
    local endButton = GUI.Button(GUI.RectTransform(Vector2(1, 0.1), menuList.Content.RectTransform), "End Round", GUI.Alignment.Center, "GUIButtonSmall")
    endButton.OnClicked = function()
        if not clicked then clicked = true return end
        local msg = Networking.Start("mm_ruleset")
        msg.WriteByte(4)
        Networking.Send(msg)
    end]]

    local draftLoopButton = GUI.Button(GUI.RectTransform(Vector2(1, 0.1), menuList.Content.RectTransform), "Draft Loop", GUI.Alignment.Center, "GUIButtonSmall")
    draftLoopButton.OnClicked = function()
        local msg = Networking.Start("mm_ruleset")
        msg.WriteByte(3)
        Networking.Send(msg)
    end

    local dropDown = GUI.DropDown(GUI.RectTransform(Vector2(1, 0.05), menuList.Content.RectTransform), "Draft a ruleset", 4, nil, false, false, GUI.Alignment.Center)
    for tbl in Megamod_Client.DropDownTbl do
        dropDown.AddItem(tbl[1], tbl[2])
    end
    dropDown.OnSelected = function(guiComponent, object)
        local msg = Networking.Start("mm_ruleset")
        msg.WriteByte(2)
        msg.WriteString(guiComponent.Text)
        Networking.Send(msg)
        -- Hacky solution - works, but probably isn't foolproof
        Timer.Wait(function()
            Megamod_Client.Text1.Text = combineRuleSetInfo()
        end, 100)
    end

    -- Text block with all info, changes size based on amount of info
    Megamod_Client.Text1 = GUI.TextBlock(GUI.RectTransform(Vector2(1, getTextSize()), menuList.Content.RectTransform), combineRuleSetInfo(), nil, nil, GUI.Alignment.Center)
end
