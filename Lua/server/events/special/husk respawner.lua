local event = {}

event.Name = "Husk Respawner"

event.Severity = "special"

event.Enabled = false

event.Started = false

event.CanEnd = false

event.OneOff = false


function event.Check()
    return true
end

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
