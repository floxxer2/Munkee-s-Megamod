local rsm = {}

-- Disabled = no auto-drafting
-- Only flipped by admin commands
rsm.Enabled = true

-- 0 = lobby, 1 = serious, 2 = silly
rsm.RoundType = 0

rsm.DraftLoopTime = math.random(420, 600)

rsm.ForceDraft = nil

-- Set to 1 or 2 to force round type, nil for auto
rsm.ForceRoundType = nil

rsm.ExtraSummary = {} -- Printed above the ruleset stuff in the summary message

rsm.Summary = {} -- Each index is a line

rsm.AntagTypes = {} -- Populated by enabled rulesets

rsm.MinSeriousPlayers = 5 -- Min server pop for serious rounds, inclusive

-- Set by admins, no auto-fail if true
rsm.NoFail = false

-- Do not remove rulesets from this table, they are static
rsm.RuleSets = {}
-- Populate rsm.RuleSets with all active rulesets
-- We store the original require() because rulesets can have hooks
for dirPath in File.GetDirectories(Megamod.Path .. "/Lua/server/rulesets") do
    dirPath = dirPath:gsub("\\", "/")
    local lastSlash = dirPath:reverse():find("/") * -1
    lastSlash = lastSlash + 1
    local potentialRuleSetName = dirPath:sub(lastSlash, -1)
    local req = require(Megamod.PathToReq(dirPath) .. "." .. potentialRuleSetName)
    if req.Enabled then
        if req.AntagName then table.insert(rsm.AntagTypes, req.AntagName) end
        table.insert(rsm.RuleSets, req)
    end
end

local weightedRandom = require 'utils.weightedrandom'

function rsm.SyncAdmin(client)
    if not Megamod.Admins[client.SteamID] then return end
    local msg = Networking.Start("mm_ruleset")
    msg.WriteByte(0)
    msg.WriteByte(rsm.RoundType)
    msg.WriteByte(#rsm.RuleSets)
    for ruleSet in rsm.RuleSets do
        msg.WriteString(ruleSet.Name)
        msg.WriteByte(ruleSet.Strength)
        msg.WriteString(ruleSet.FailReason)
        local selectedPlayers = {}
        for selectedClient, tbl in pairs(ruleSet.SelectedPlayers) do
            table.insert(selectedPlayers, { selectedClient, tbl[1] })
        end
        msg.WriteByte(#selectedPlayers)
        for tbl in selectedPlayers do
            msg.WriteByte(tbl[1].SessionId)
            msg.WriteString(tbl[2])
        end
    end
    Networking.Send(msg, client.Connection)
end

function rsm.AntagStatus(client, targetAntagName, targetRuleSetName)
    local antagRoles = {}
    for ruleSet in rsm.RuleSets do
        local sel = ruleSet.SelectedPlayers[client]
        if (targetRuleSetName and ruleSet.Name == targetRuleSetName)
        or ((not targetAntagName and sel)
        or (targetAntagName and sel and sel[1] == targetAntagName))
        then
            table.insert(antagRoles, sel)
        end
    end
    return antagRoles
end

function rsm.GiveSummary(client)
    local str = ""
    for line in rsm.ExtraSummary do
        str = str .. line .. "\n"
    end
    for line in rsm.Summary do
        str = str .. line .. "\n"
    end
    -- Remove the last newline
    str = str:sub(1, -2)
    Megamod.SendMessage(client, str)
end

function rsm.CheckFailLoop()
    if not Game.RoundStarted then return end
    if not rsm.NoFail then
        for ruleSet in rsm.RuleSets do
            if ruleSet.Strength > 0 and ruleSet.FailReason == "" then
                local failed, str = ruleSet.CheckShouldFail()
                if failed then
                    ruleSet.FailReason = str
                    -- Add rulesets that failed to the summary
                    table.insert(rsm.Summary, ruleSet.Name .. " - failed (" .. str .. ")")
                    for antag, tbl in pairs(ruleSet.SelectedPlayers) do
                        table.insert(rsm.Summary, tostring(antag.Name) .. " - " .. tbl[1])
                    end
                    for client in Client.ClientList do
                        if Megamod.Admins[client.SteamID] then
                            local msg = Networking.Start("mm_ruleset")
                            msg.WriteByte(4)
                            msg.WriteString(ruleSet.Name)
                            msg.WriteString(str)
                            Networking.Send(msg, client.Connection)
                        end
                    end
                    ruleSet.Reset()
                end
            end
        end
    end
    Timer.Wait(function()
        rsm.CheckFailLoop()
    end, 4500)
end

function rsm.Start()
    -- The summary is reset on roundstart instead of roundend so it can be viewed in the lobby
    rsm.ExtraSummary = {}
    rsm.Summary = {}

    local msgStr, logStr = "", ""
    rsm.RoundType = rsm.ForceRoundType or (#Client.ClientList >= rsm.MinSeriousPlayers and 1 or 2)
    if rsm.RoundType == 1 then
        msgStr = "This is a -serious- round.\nDo your job, follow the Captain's orders, and don't die."
        logStr = "-serious-"
        rsm.DraftLoop()
    elseif rsm.RoundType == 2 then
        msgStr = "This is a -silly- round.\nHave fun, experiment, and let mayhem ensue!"
        logStr = "-silly-"
    end
    for client in Client.ClientList do
        Megamod.SendChatMessage(client, msgStr, Color(255, 0, 255, 255))
    end
    if rsm.ForceRoundType then
        Megamod.Log("The round type was forced to be " .. logStr .. " by an admin.", true)
        rsm.ForceRoundType = nil
    end

    -- Outdated by the above logic but kept incase something goes wrong
    --[[if not rsm.ForceRoundType then
        if #Client.ClientList >= rsm.MinSeriousPlayers then
            rsm.RoundType = 1
            rsm.DraftLoop()
        else
            rsm.RoundType = 2
        end
    else -- An admin has forced the round type
        rsm.RoundType = rsm.ForceRoundType
        local str = ""
        if rsm.RoundType == 1 then
            str = "serious."
            rsm.DraftLoop()
        elseif rsm.RoundType == 2 then
            str = "silly."
        end
        Megamod.Log("The round type was forced to be " .. str, true)
        rsm.ForceRoundType = nil
    end]]

    rsm.CheckFailLoop()
    -- Have to wait here because sending a net message right on roundstart sometimes crashes the client (??)
    Timer.Wait(function()
        for client in Client.ClientList do
            if Megamod.Admins[client.SteamID] then
                local msg = Networking.Start("mm_ruleset")
                msg.WriteByte(1)
                msg.WriteByte(rsm.RoundType)
                Networking.Send(msg, client.Connection)
            end
        end
    end, 10000)
end
Hook.Add("roundStart", "Megamod.RuleSetManager.RoundStart", rsm.Start)
-- Call Start() if we reload Lua midround
if Game.RoundStarted then
    rsm.Start()
end

local endRoundTimerActive = false
function rsm.EndRoundTimer(timer, inputStr)
    if endRoundTimerActive or not Game.RoundStarted then return end
    endRoundTimerActive = true
    local str = " The round is ending in " .. tostring(timer) .. " seconds."
    if inputStr then
        str = inputStr .. str -- Can't have newlines in ServerMessageBoxInGame
    end
    for client in Client.ClientList do
        Megamod.SendChatMessage(client, str, Color(255, 0, 255, 255))
        Game.SendDirectChatMessage("", str, nil, ChatMessageType.ServerMessageBoxInGame, client, nil)
    end
    local function loop()
        if not Game.RoundStarted then endRoundTimerActive = false return end
        timer = timer - 1
        if timer <= 0 then
            endRoundTimerActive = false
            Game.EndGame()
            return
        end
        Timer.Wait(function()
            loop()
        end, 1000)
    end
    loop()
end

function rsm.End()
    for ruleSet in rsm.RuleSets do
        if ruleSet.Strength > 0 -- Was drafted
        and ruleSet.FailReason == "" -- Didn't fail (failing = reset early, don't need to reset again)
        then
            -- Add rulesets that succeeded to the summary
            table.insert(rsm.Summary, ruleSet.Name .. " - successful")
            for antag, tbl in pairs(ruleSet.SelectedPlayers) do
                table.insert(rsm.Summary, tostring(antag.Name) .. " - " .. tbl[1])
            end
            ruleSet.Reset()
        elseif ruleSet.FailReason ~= "" then
            -- Reset unsuccessful rulesets' FailReasons
            ruleSet.FailReason = ""
            -- Failed rulesets are Reset() and added to the summary when they fail in CheckFailLoop()
        end
    end
    -- Don't show the summary message after a silly round
    if rsm.RoundType ~= 2 then
        Timer.Wait(function()
            for client in Client.ClientList do
                Megamod.SendChatMessage(client, "Available summary for last round. Type '!summary' to view it.", Color(255, 0, 255, 255))
            end
        end, 8000)
    end
    rsm.DraftLoopTime = math.random(420, 600) -- 7-10 minutes
    rsm.RoundType = 0
    rsm.ForceDraft = nil
end
Hook.Add("roundEnd", "Megamod.RuleSetManager.RoundEnd", rsm.End)

-- Drafting means adding 1 to the strength of a ruleset
-- Weighted to be far more common for rulesets with low but not 0 strength
-- Max strength is 10, no more drafting at 10 strength
function rsm.Draft(forced)
    local draft
    -- If Beast was drafted, Beast is the only one that can be drafted
    -- We ignore the 10 strength cap for Beast because it's special
    for ruleSet in rsm.RuleSets do
        if ruleSet.Name == "Beast" then
            if ruleSet.Strength > 0 then
                forced = "Beast"
            end
            break
        end
    end
    forced = forced or rsm.ForceDraft
    if not forced then
        local checkedRuleSets = {}
        for ruleSet in rsm.RuleSets do
            if ruleSet.Check() then
                table.insert(checkedRuleSets, ruleSet)
            end
        end
        local potentialDrafts = {}
        for ruleSet in checkedRuleSets do
            if ruleSet.Strength > 0
            and ruleSet.Strength < 10
            and ruleSet.FailReason == "" -- If FailReason is not "", the ruleset failed this round and should not be drafted again
            then
                potentialDrafts[ruleSet] = ruleSet.Chance * (15 - ruleSet.Strength)
            elseif ruleSet.Strength == 0
            and ruleSet.FailReason == "" then
                potentialDrafts[ruleSet] = ruleSet.Chance
            end
        end
        draft = weightedRandom.Choose(potentialDrafts)
    else
        for ruleSet in rsm.RuleSets do
            if ruleSet.Name == forced then
                draft = ruleSet
                break
            end
        end
    end
    if not draft then
        Megamod.Log("No rulesets can be drafted. Canceling draft...", true)
        return
    end
    draft.Strength = draft.Strength + 1
    for client in Client.ClientList do
        if Megamod.Admins[client.SteamID] then
            local msg = Networking.Start("mm_ruleset")
            msg.WriteByte(2)
            msg.WriteString(draft.Name)
            msg.WriteByte(draft.Strength)
            Networking.Send(msg, client.Connection)
        end
    end
    Megamod.Log("Drafted '" .. draft.Name .. "' - Strength: " .. tostring(draft.Strength), true)
    draft.Draft()
end

local draftLoopActive = false
-- First draft is 7-10 minutes in
-- Drafts after the first happen every 120-180 seconds
-- Called less often when the timer for the next draft is >5
function rsm.DraftLoop()
    draftLoopActive = true
    local time = 5
    if rsm.DraftLoopTime < 5 then
        time = 1
    end
    if not Game.RoundStarted or not rsm.Enabled then
        draftLoopActive = false
        return
    end
    rsm.DraftLoopTime = rsm.DraftLoopTime - time
    if rsm.DraftLoopTime <= 0 then
        rsm.DraftLoopTime = math.random(180, 240)
        rsm.Draft()
    end
    Timer.Wait(function()
        rsm.DraftLoop()
    end, time * 1000)
end

local funcs = {
    -- Client needs syncing
    [0] = function(message, sender)
        rsm.SyncAdmin(sender)
    end,
    -- Manager toggled
    [1] = function(message, sender)
        local toggle = message.ReadBoolean()
        rsm.Enabled = toggle
    end,
    -- Draft
    [2] = function(message, sender)
        local ruleSetName = message.ReadString()
        rsm.Draft(ruleSetName)
    end,
    -- Call the draft loop
    [3] = function(message, sender)
        if not draftLoopActive and rsm.Enabled then
            Megamod.SendChatMessage(sender, "Draft loop enabled.", Color(255, 0, 255, 255))
            rsm.DraftLoop()
        end
    end,
    -- End round
    [4] = function(message, sender)
        rsm.End()
    end,
}
Networking.Receive("mm_ruleset", function(message, sender)
    if not Megamod.Admins[sender.SteamID] then
        Megamod.Log("Client '" .. tostring(sender.Name) .. "' tried to send a ruleset message, but was not an admin.", true)
        return
    end
    local id = message.ReadByte()
    funcs[id](message, sender)
end)

return rsm
