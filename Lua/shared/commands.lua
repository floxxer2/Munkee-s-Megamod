local cmds = {}

cmds.GenericCommands = {}
cmds.AdminCommands = {}

cmds.Cooldown = {}

if CLIENT then
    Networking.Receive("mm_command", function(msg)
        local command = msg.ReadString()
        local argument = msg.ReadString() or ""

        local client = Megamod_Client.GetSelfClient()

        if Megamod.Admins[client.SteamID] then
            for k, v in pairs(cmds.AdminCommands) do
                if command == k then
                    v[1](client, argument)
                    return true
                end
            end
        end

        for k, v in pairs(cmds.GenericCommands) do
            if command == k then
                v[1](client, argument)
                return true
            end
        end
    end)
end

-- Argument may be nil if sender does not provide an argument
---@param type1 "generic"|"admin"
---@param name string|table
---@param callback function
function cmds.AddCommand(type1, name, callback, clientSide)
    clientSide = clientSide or false
    if type1:lower() == "generic" then
        if type(name) == "string" then
            cmds.GenericCommands[name] = { callback, clientSide }
        elseif type(name) == "table" then
            for v in name do
                cmds.GenericCommands[v] = { callback, clientSide }
            end
        end
    elseif type1:lower() == "admin" then
        if type(name) == "string" then
            cmds.AdminCommands[name] = { callback, clientSide }
        elseif type(name) == "table" then
            for v in name do
                cmds.AdminCommands[v] = { callback, clientSide }
            end
        end
    end
end

if SERVER then
    Hook.Add("chatMessage", "Megamod.Commands.DoCommand", function(msg, sender)
        if not msg:match("^!") then return end

        -- Admins ignore command cooldown
        if Timer.GetTime() < (cmds.Cooldown[sender] or 0) and not Megamod.Admins[sender.SteamID] then
            Megamod.SendChatMessage(sender, "Command denied (on cooldown).",
                Color(255, 0, 255, 255))
            return true
        end

        local command, argument = msg:match("^!(%S+)%s*(.*)")
        command = string.lower(command or "") or ""

        if Megamod.Admins[sender.SteamID] then
            for k, v in pairs(cmds.AdminCommands) do
                if command == k then
                    -- Prevents error propagation, so we can still do return true
                    Timer.Wait(function()
                        v[1](sender, argument)
                    end, 1)

                    -- Command is also meant to execute on the client
                    if v[2] then
                        local message = Networking.Start("mm_command")
                        message.WriteString(command)
                        message.WriteString(argument or "")
                        Networking.Send(message, sender.Connection)
                    end

                    cmds.Cooldown[sender] = Timer.GetTime() + 1
                    Megamod.Log(
                        "A; '" .. sender.Name .. "' (Steam: " .. sender.SteamID .. ") used command '!" .. k .. "'", false)
                    return true
                end
            end
        end

        for k, v in pairs(cmds.GenericCommands) do
            if command == k then
                -- Prevents error propagation, so we can still do return true
                Timer.Wait(function()
                    v[1](sender, argument)
                end, 1)

                -- Command is also meant to execute on the client
                if v[2] then
                    local message = Networking.Start("mm_command")
                    message.WriteString(command)
                    message.WriteString(argument or "")
                    Networking.Send(message, sender.Connection)
                end

                cmds.Cooldown[sender] = Timer.GetTime() + 1
                Megamod.Log("'" .. sender.Name .. "' (Steam: " .. sender.SteamID .. ") used command '!" .. k .. "'",
                    false)
                return true
            end
        end

        Megamod.SendChatMessage(sender, "Invalid command/lack of permission\n'!" .. command .. "'",
            Color(255, 0, 255, 255))
        return true
    end)
end

cmds.AddCommand("generic", "help", function(sender, argument)
    local str =
        "!help\n" ..
        "Show this message.\n\n" ..
        "!spawn !midroundspawn !mrs\n" ..
        "Spawns you in if you joined late, using your job preferences. You can't spawn as captain, and you get 3 minutes of pressure protection.\n\n" ..
        "!loot\n" ..
        "Gives you information about the loot you have from escaping, if you have any.\n\n" ..
        "!role\n" ..
        "Information regarding your antagonist role. Use the 'obj' argument (\"!role obj\") to view antagonist objectives.\n\n" ..
        "!clone !cloning\n" ..
        "If you are being cloned, tells you the time left until you revive.\n\n" ..
        "!round\n" ..
        "Tells you what round type it currently is (silly or serious).\n\n" ..
        "!summary\n" ..
        "Gives you the summary of last round, if available."
    Megamod.SendMessage(sender, str)
end)

cmds.AddCommand("generic", { "spawn", "midroundspawn", "mrs" }, function(sender, argument)
    -- Logic is all handled in this function
    Megamod.MidRoundSpawn.SpawnPlayer(sender)
end)

cmds.AddCommand("generic", "loot", function(sender, argument)
    for k, lootTbl in pairs(Megamod.EscapePortal.SavedLoot) do
        do
            if sender.SteamID ~= lootTbl.ClientID then goto continue end

            if argument == "delete" then
                table.remove(Megamod.EscapePortal.SavedLoot, k)
                Megamod.SendChatMessage(sender, "Deleted saved gear.", Color(255, 0, 255, 255))
                return
            end

            local str = "You have saved gear! If you don't spawn as a valid role next round, it will be lost. You may also use '!loot delete' to manually delete it.\n\n" ..
            "Valid roles:\n"
            local roles = {
                "captain",
                "securityofficer",
                "surgeon",
                "medicaldoctor",
                "engineer",
                "mechanic",
                "assistant",
            }
            local lines = {}
            local validRoles = Megamod.EscapePortal.DetermineValidRoles(lootTbl.Role)
            for role in roles do
                local isValid = false
                for validRole in validRoles do
                    if role == validRole then
                        isValid = true
                        break
                    end
                end
                if isValid then
                    local roleName = tostring(JobPrefab.Get(role).Name)
                    table.insert(lines, ">" .. roleName)
                end
            end
            for line in lines do
                str = str .. line .. "\n"
            end

            str = str .. "\nItems (some may be in nested inventories):\n"
            local dupes = {}
            local function inventorySearch(itemTbl)
                for childItemTbl in itemTbl.Inventory do
                    local prefab = ItemPrefab.GetItemPrefab(childItemTbl.ID)
                    local key = tostring(prefab.Name) .. " (" .. tostring(childItemTbl.Condition) .. "%)"
                    dupes[key] = (dupes[key] or 0) + 1
                    if childItemTbl.Inventory and #childItemTbl.Inventory > 0 then
                        inventorySearch(childItemTbl)
                    end
                end
            end
            for itemTbl in lootTbl.Items do
                local prefab = ItemPrefab.GetItemPrefab(itemTbl.ID)
                local key = tostring(prefab.Name) .. " (" .. tostring(itemTbl.Condition) .. "%)"
                dupes[key] = (dupes[key] or 0) + 1
                if itemTbl.Inventory and #itemTbl.Inventory > 0 then
                    inventorySearch(itemTbl)
                end
            end
            for key, count in pairs(dupes) do
                if key:sub(-6) == "(100%)" then
                    key = key:sub(1, -8)
                end
                str = str .. "x" .. count .. " " .. key .. "\n"
            end
            Megamod.SendMessage(sender, str)
            return
        end

        ::continue::
    end
    Megamod.SendChatMessage(sender, "No saved gear.", Color(255, 0, 255, 255))
end)

cmds.AddCommand("generic", "role", function(sender, argument)
    argument = string.lower(argument or "")
    local obj = argument == "obj"
    for ruleset in Megamod.RuleSetManager.RuleSets do
        -- Returns true/false + a string for the message, which can also contain objectives
        local isSelected, str = ruleset.RoleHelp(sender, obj)
        if isSelected then
            -- Remove the antag overlay, if they have it
            if not Megamod.CheckIsDead(sender) then
                -- Non-humans need to have it forcefully removed
                if sender.Character.IsHuman then
                    HF.AddAffliction(sender.Character, "mm_antagoverlay2", 10)
                else
                    HF.SetAffliction(sender.Character, "mm_antagoverlay", 0)
                end
            end
            Megamod.SendMessage(sender, str)
            return
        end
    end
    Megamod.SendMessage(sender, ">> You are a crewmate.\n(No specific objectives, just do your job!)")
end)

cmds.AddCommand("generic", { "clone", "cloning" }, function(sender, argument)
    if not Megamod.CheckIsSpectating(sender) then
        Megamod.SendChatMessage(sender, "You must be spectating the round.", Color(255, 0, 255, 255))
        return
    end
    local machine = Megamod.Cloning.SelfClone
    if machine then
        local hypomaxim = machine.OwnInventory.GetItemAt(6)
        if hypomaxim then
            Megamod.Cloning.SetHypomaxim(hypomaxim, sender)
            -- This is the same as someone pressing the "start" button on a cloning machine
            Hook.Call("mm.cloningstart", nil, nil, Megamod.Cloning.SelfClone)
            -- Client gets notified by the cloning code
            return
        else
            Megamod.Error("!clone was used to self-clone, but there was no hypomaxim.")
            -- Don't return
        end
    end
    if Megamod.Cloning.ActiveProcess and Megamod.Cloning.ActiveProcess[1] == sender then
        Megamod.SendChatMessage(sender, tostring(Megamod.Cloning.ActiveProcess[2]) .. " seconds remaining.", Color(255, 0, 255, 255))
    else
        Megamod.SendChatMessage(sender, "You are not being cloned, and self-cloning is currently unavailable.", Color(255, 0, 255, 255))
    end
end)

cmds.AddCommand("generic", "round", function(sender, argument)
    local roundType = Megamod.RuleSetManager.RoundType
    local text = ""
    if roundType == 0 then
        text = "(In Lobby)"
    elseif roundType == 1 then
        text = "Serious"
    elseif roundType == 2 then
        text = "Silly"
    end
    Megamod.SendChatMessage(sender, text, Color(255, 0, 255, 255))
end)

cmds.AddCommand("generic", "summary", function(sender, argument)
    if Game.RoundStarted then
        Megamod.SendChatMessage(sender, "Cannot view summary during a round.", Color(255, 0, 255, 255))
        return
    end
    Megamod.RuleSetManager.GiveSummary(sender)
end)

cmds.AddCommand("generic", "uplink", function(sender, argument)
    local rs
    for ruleset in Megamod.RuleSetManager.RuleSets do
        if ruleset.Name == "Traitor" then
            rs = ruleset
            break
        end
    end

    -- Fake invalid command message
    if not rs or not rs.SelectedPlayers[sender] or rs.SelectedPlayers[sender][2][1] then
        Megamod.SendChatMessage(sender, "Invalid command/lack of permission\n'!uplink'", Color(255, 0, 255, 255))
        return
    end

    rs.SelectedPlayers[sender][2][1] = true
    rs.SpawnUplink(sender)
end)

cmds.AddCommand("admin", "helpadmin", function(sender, argument)
    local str =
        "!helpadmin\n" ..
        "Show this message.\n\n" ..
        "!omni\n" ..
        "Toggle omniscience.\n\n" ..
        "!info\n" ..
        "Argument: <cloning/roles/events/roundtype/time> | See information about one of those.\n\n" ..
        "!luacheck\n" ..
        "Find those pesky non-Lua-ers.\n\n" ..
        "!event-toggle\n" ..
        "Toggles automatic event triggering.\n\n" ..
        "!event-start\n" ..
        "Starts the specified event. Case insensitive.\n\n" ..
        "!event-end\n" ..
        "Ends the specified event. Case insensitive.\n\n" ..
        "!ruleset-forceround\n" ..
        "Argument: <1/2> | Use to force the round to be serious (1) or silly (2). Use with no argument to un-force the round.\n\n"..
        "!ruleset-forcedraft\n" ..
        "Argument: <ruleset name> | Force the rulesetmanager to draft a specific ruleset over and over. Use with no argument to stop forcing the draft."
    Megamod.SendMessage(sender, str)
end)

cmds.AddCommand("admin", "omni", function(sender, argument)
    local str = "Enabled"
    local key
    for k, omniClient in pairs(Megamod.Omni) do
        if omniClient == sender then
            str = "Disabled"
            key = k
            break
        end
    end
    Megamod.SendChatMessage(sender, str, Color(255, 0, 255, 255))
    if key then table.remove(Megamod.Omni, key)
    else table.insert(Megamod.Omni, sender) end
end)

cmds.AddCommand("admin", "info", function(sender, argument)
    argument = string.lower(argument)
    if argument == "cloning" then
        if not Game.RoundStarted then
            Megamod.SendChatMessage(sender, "Cannot be used in the lobby", Color(255, 0, 255, 255))
            return
        end
        local str = ""

        local process = Megamod.Cloning.ActiveProcess
        if process then
            str =
            "Client: " .. tostring(process[1].Name) .. "\n" ..
            "Remaining time: " .. tostring(process[2]) .. "\n" ..
            "Rift material ticker: " .. tostring(process[3]) .. "\n" ..
            "Cloning machine: " .. tostring(process[4]) .. "\n" ..
            "Active: " .. tostring(process[5]) .. "\n" ..
            "Paused: " .. tostring(process[6]) .. "\n" ..
            "Rift material used: " .. tostring(process[7])
        else
            str = "No cloning process"
        end

        Megamod.SendChatMessage(sender, str, Color(255, 0, 255, 255))
    elseif argument == "roles" then -- #TODO#
        do return end
        if not Game.RoundStarted then
            Megamod.SendChatMessage(sender, "Cannot be used in the lobby", Color(255, 0, 255, 255))
            return
        end
        local str = ""
        for client in Client.ClientList do
            local antags = Megamod.RuleSetManager.AntagStatus(client)
            if #antags > 0 then
                str = str .. "\n" .. tostring(client.Name) .. " - "
                for antag in antags do
                    str = str .. antag[1] .. ", "
                end
                -- Remove the last ", "
                str = str:sub(1, -3)
            end
        end
        if str == "" then
            str = "No antagonists\n"
        end
        -- Remove the last newline
        str = str:sub(1, -2)
        Megamod.SendChatMessage(sender, str, Color(255, 0, 255, 255))
    elseif argument == "events" then
        if not Game.RoundStarted then
            Megamod.SendChatMessage(sender, "Cannot be used in the lobby", Color(255, 0, 255, 255))
            return
        end
        local str = "Active events:"
        for event in Megamod.EventManager.ActiveEvents do
            str = str .. "\n" .. event.Name
        end
        if str == "Active events:" then
            str = "Active events:\n(None)"
        end
        Megamod.SendChatMessage(sender, str, Color(255, 0, 255, 255))
    elseif argument == "roundtype" then
        local rt = Megamod.RuleSetManager.RoundType
        local text = ""
        if rt == 0 then
            text = "In Lobby"
        elseif rt == 1 then
            text = "Serious"
        elseif rt == 2 then
            text = "Silly"
        end
        Megamod.SendChatMessage(sender, text, Color(255, 0, 255, 255))
    elseif argument == "time" then
        local num = (Timer.GetTime() - Megamod.Map.RoundStartTime) / 60
        Megamod.SendChatMessage(sender, "Minutes since the round started:\n" .. tostring(num), Color(255, 0, 255, 255))
    end
end)

cmds.AddCommand("admin", "luacheck", function(sender, argument)
    if not Megamod.LuaCheck.Active then
        Megamod.LuaCheck.Check(sender)
        Megamod.SendChatMessage(sender, "Started Lua check", Color(255, 0, 255, 255))
    else
        Megamod.SendChatMessage(sender, "Lua check is already active", Color(255, 0, 255, 255))
    end
end)

-- Admins could just use the control panel to do ruleset stuff, but these are good as backups

cmds.AddCommand("admin", "ruleset-forceround", function(sender, argument)
    if Megamod.RuleSetManager.ForceRoundType and (not argument or argument == "") then
        Megamod.RuleSetManager.ForceRoundType = nil
        Megamod.SendChatMessage(sender, "No longer forcing round type", Color(255, 0, 255, 255))
        return
    end
    argument = tonumber(argument)
    if argument ~= 1 and argument ~= 2 then
        Megamod.SendChatMessage(sender, "Invalid argument. Usage: !ruleset-forceround <1/2>", Color(255, 0, 255, 255))
        return
    end
    Megamod.RuleSetManager.ForceRoundType = argument
    Megamod.SendChatMessage(sender, "Forced round type to " .. tostring(argument), Color(255, 0, 255, 255))
end)

cmds.AddCommand("admin", "ruleset-forcedraft", function(sender, argument)
    if Megamod.RuleSetManager.ForceDraft and (not argument or argument == "") then
        Megamod.RuleSetManager.ForceDraft = nil
        Megamod.SendChatMessage(sender, "No longer forcing the draft", Color(255, 0, 255, 255))
        return
    end
    argument = Megamod.Capitalize(argument)
    local valid = false
    for ruleSet in Megamod.RuleSetManager.RuleSets do
        if argument == ruleSet.Name then
            valid = true
            break
        end
    end
    if not valid then
        Megamod.SendChatMessage(sender, "Invalid argument. Usage: !ruleset-forcedraft <ruleset name>", Color(255, 0, 255, 255))
        return
    end
    Megamod.RuleSetManager.ForceDraft = argument
    Megamod.SendChatMessage(sender, "Forced the draft to " .. argument, Color(255, 0, 255, 255))
end)

cmds.AddCommand("admin", "ruleset-toggle", function(sender, argument)
    Megamod.RuleSetManager.Enabled = not Megamod.RuleSetManager.Enabled
    local str = "disabled"
    if Megamod.RuleSetManager.Enabled then
        str = "enabled"
    end
    Megamod.SendChatMessage(sender, str, Color(255, 0, 255, 255))
end)

--[[cmds.AddCommand("admin", "debug", function(sender, argument)
    
end)]]

-- Event commands
do
    cmds.AddCommand("admin", "event-toggle", function(sender, argument)
        local enabled = not Megamod.EventManager.TriggerLoopActive
        Megamod.EventManager.TriggerLoopActive = enabled
        local text = "Natural events: enabled"
        if not enabled then text = "Natural events: disabled" end
        Megamod.SendChatMessage(sender, text, Color(255, 0, 255, 255))
    end)

    local severities = {
        "major",
        "medium",
        "minor",
        "special",
    }

    cmds.AddCommand("admin", "event-start", function(sender, argument)
        if not argument or argument == "" then return end
        argument = Megamod.Capitalize(argument)
        local isStarted = Megamod.EventManager.GetEventActive(argument)
        if isStarted then
            Megamod.SendChatMessage(sender, "Event is already active", Color(255, 0, 255, 255))
            return
        end
        for severity in severities do
            if Megamod.EventManager.StartEvent(argument, severity) then
                Megamod.SendChatMessage(sender, "Started event", Color(255, 0, 255, 255))
                return
            end
        end
        Megamod.SendChatMessage(sender, "Failed to start event", Color(255, 0, 255, 255))
    end)

    cmds.AddCommand("admin", "event-end", function(sender, argument)
        if not argument or argument == "" then return end
        argument = Megamod.Capitalize(argument)
        local isStarted = Megamod.EventManager.GetEventActive(argument)
        if not isStarted then
            Megamod.SendChatMessage(sender, "Event is not active", Color(255, 0, 255, 255))
            return
        end
        if Megamod.EventManager.EndEvent(argument) then
            Megamod.SendChatMessage(sender, "Ended event", Color(255, 0, 255, 255))
            return
        end
        Megamod.SendChatMessage(sender, "Failed to end event", Color(255, 0, 255, 255))
    end)
end

return cmds
