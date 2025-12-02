local event = {}

event.Name = "Infiltrator"

event.Severity = "medium"

event.Enabled = false

event.Started = false

event.CanEnd = false

event.OneOff = true


function event.Check()
    return true
end

function event.Start()
    event.Started = true
    event.CanEnd = true
end

---@param fast boolean
function event.End(fast)
    if not fast then fast = false end
    event.Started = false
    event.CanEnd = false
end

return event
