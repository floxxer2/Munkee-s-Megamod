local rs = {}

rs.Name = "Ruleset"

-- Base chance to be drafted (relative to other rulesets' chances)
rs.Chance = 0

-- If false on runtime = this ruleset will be ignored, good for unfinished rulesets
rs.Enabled = false

-- key = client, value = {[1] = "role name", [2] = {special table for role functionality}}
-- Keep this for consistency, even if the ruleset doesn't select players
rs.SelectedPlayers = {}

rs.Strength = 0

-- The name of the antagonist this ruleset adds
rs.AntagName = "Antagonist"

rs.FailReason = ""



-- Put extra stuff here, and keep the 3 newlines above and below for clarity



-- Called when the ruleset should clean up, at the end of a round or due to antags failing
-- Note that rulesets are a static table, they reset, not dispose!
function rs.Reset()
    rs.SelectedPlayers = {}
    rs.Strength = 0
end

-- Called when someone uses '!role'
---@param client Barotrauma.Networking.Client
---@param obj boolean
---@return boolean IsRole
---@return string RoleMessage
function rs.RoleHelp(client, obj)
    if rs.SelectedPlayers[client] then
        local str = ">> You are an antagonist!"
        if obj then
            -- Replace str with the antag's objectives
        end
        return true, str
    end
    return false, ""
end

-- Check to determine if the ruleset can be drafted
---@return boolean
function rs.Check()
    return true -- Can always be drafted
end

-- Check for determining if the ruleset's antagonists have failed
---@return boolean
---@return string
function rs.CheckShouldFail()
    return false, ""
end

-- Called every time the ruleset is drafted
---@return boolean Success
---@return string Failmessage string to log when failed to draft
function rs.Draft()
    rs.Strength = rs.Strength + 1

    -- Do other stuff here

    return true, "" -- Success
end

return rs
