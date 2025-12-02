local evm = {}

-- Max 1 major event per round
evm.MajorEventTriggered = false

evm.ActiveEvents = {}

evm.TriggerLoopActive = true


---@param eventName string Case sensitive
---@param expectedSeverity "major"|"medium"|"minor"|"special"
---@return table|nil event
function evm.GetNewEvent(eventName, expectedSeverity)
    for eventPath in File.GetFiles(Megamod.Path .. "/Lua/server/events/" .. expectedSeverity) do
        if eventPath:sub(-4) == ".lua" then
            local req = require(Megamod.PathToReq(eventPath))
            if req.Name == eventName then return req end
        end
    end
    return nil
end

---@param eventName string Case sensitive
---@return boolean active
function evm.GetEventActive(eventName)
    if not eventName or eventName == "" or type(eventName) ~= "string" then return false end
    for _, event in pairs(evm.ActiveEvents) do
        if event.Name == eventName then
            return true
        end
    end
    return false
end

-- Only one event per type can be active at once
---@param eventName string Case sensitive
---@param expectedSeverity "major"|"medium"|"minor"|"special"
---@return boolean success
function evm.StartEvent(eventName, expectedSeverity)
    if not eventName or eventName == "" or type(eventName) ~= "string" or evm.GetEventActive(eventName) then return false end
    local event = evm.GetNewEvent(eventName, expectedSeverity)
    if event then
        -- One-offs don't get added to the active events list,
        -- as they are not meant to be tracked
        if not event.OneOff then table.insert(evm.ActiveEvents, event) end
        if event.Severity == "major" then
            evm.MajorEventTriggered = true
        end

        Megamod.Log("Event '" .. event.Name .. "' triggered.", true)
        event.Start()
        return true
    end
    return false
end

---@param eventName string Case sensitive
---@return boolean eventEnded
function evm.EndEvent(eventName)
    if not eventName or eventName == "" or type(eventName) ~= "string" then return false end
    for k, event in pairs(evm.ActiveEvents) do
        if event.Name == eventName and event.CanEnd then
            Megamod.Log("Event '" .. event.Name .. "' ended.", true)
            event.End()
            evm.ActiveEvents[k] = nil
            return true
        end
    end
    return false
end

function evm.TriggerRandomEvent()
    if not Game.RoundStarted then return end
    local path = Megamod.Path .. "/Lua/server/events/"
    ---@type string
    local severity = ""
    local severityNumber = math.random()
    -- Can't trigger more than one major event per round
    if severityNumber <= 0.15 and evm.MajorEventTriggered then
        severityNumber = 0.16
    end
    if severityNumber <= 0.15 then
        -- Major event, 15% chance
        severity = "major"
        path = path .. severity
    elseif severityNumber > 0.15 and severityNumber <= 0.5 then
        -- Medium event, 35% chance
        severity = "medium"
        path = path .. severity
    elseif severityNumber > 0.5 then
        -- Minor event, 50% chance
        severity = "minor"
        path = path .. severity
    end

    local function doEvent()
        -- The loop function is still active, but it won't actually trigger events
        if not evm.TriggerLoopActive
        or Megamod.RuleSetManager.RoundType ~= 1 -- Don't do events during silly rounds
        or evm.GetEventActive("Hunt") -- Don't do events during Hunts
        then return end

        local potentialEvents = {}
        local potentialEventsAmount = 0

        for eventPath in File.GetFiles(path) do
            if eventPath:sub(-3) == "lua" then
                local req = require(Megamod.PathToReq(eventPath))
                if req.Enabled and not evm.GetEventActive(req.Name) and req.Check() then
                    table.insert(potentialEvents, req)
                    potentialEventsAmount = potentialEventsAmount + 1
                end
            end
        end

        if potentialEventsAmount == 0 then
            Megamod.Log("No eligible events of severity '" .. severity .. "' found. Lowering severity or canceling.", true)
            if severity == "major" then
                severity = "medium"
                path = Megamod.Path .. "/Lua/server/events/" .. severity
            elseif severity == "medium" then
                severity = "minor"
                path = Megamod.Path .. "/Lua/server/events/" .. severity
            elseif severity == "minor" then
                -- No more severity to lower to, cancel
                return
            end
            doEvent()
            return
        end

        local eventToTrigger = potentialEvents[math.random(potentialEventsAmount)]
        evm.StartEvent(eventToTrigger.Name, eventToTrigger.Severity)
    end
    doEvent()
end

local time = 10
local chance = 0
function evm.EventTriggerLoop()
    if not Game.RoundStarted then
        time = 10
        chance = 0
        return
    end
    time = time - 1
    if time <= 0 then
        time = 10
        chance = chance + 0.1
        if math.random() <= chance then
            chance = 0
            evm.TriggerRandomEvent()
        end
    end
    Timer.Wait(function()
        return evm.EventTriggerLoop()
    end, math.random(9950, 10050)) -- 100 ms of random time difference
end

Hook.Add("roundStart", "Megamod.EventManager.RoundStart", evm.EventTriggerLoop)
-- Start the loop if Lua is reloaded midround
if Game.RoundStarted then
    evm.EventTriggerLoop()
end

-- Manually end all events on roundend, doesn't use EndEvent()
Hook.Add("roundEnd", "Megamod.EventManager.RoundEnd", function()
    for k, event in pairs(evm.ActiveEvents) do
        -- True as first arg means end faster
        event.End(true)
        evm.ActiveEvents[k] = nil
    end
    evm.MajorEventTriggered = false
    evm.TriggerChance = 10
    evm.LoopTimer = 30
end)

return evm
