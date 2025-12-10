local event = {}

event.Name = "Graverise"

event.Severity = "special"

event.Enabled = false

event.Started = false

event.CanEnd = false

event.OneOff = false


function event.Check()
    return true
end

-- Admin-triggered; gives all dead players the ability to endlessly respawn as monsters
function event.Start()
    event.Started = true
    event.CanEnd = true
end

---@param fast boolean
function event.End(fast)
    event.Started = false
    event.CanEnd = false
end

return event
