local event = {}

event.Name = "Random Husk"

event.Severity = "medium"

event.Enabled = true

event.Started = false

event.CanEnd = false

event.OneOff = true

-- >90% of crew is alive, >90% of alive crew are healthy (>75 vitality and no infections)
function event.Check()
    if #Client.ClientList == 0 then return false end
    local alive = 0
    local healthy = 0
    for client in Client.ClientList do
        if not Megamod.CheckIsDead(client) then
            alive = alive + 1
            if client.Character.Vitality > 75 then
                healthy = healthy + 1
            end
        end
    end
    return (alive / #Client.ClientList) >= 0.90 and (healthy / alive) >= 0.90
end

function event.Start()
    if #Client.ClientList == 0 then
        Megamod.Log("No clients to infect. Canceling...", true)
        return
    end
    -- Targets must be alive and healthy
    local targets = {}
    for client in Client.ClientList do
        if not Megamod.CheckIsDead(client)
        and client.Character.IsHuman == true
        and client.Character.Vitality > 75
        and Megamod.GetAfflictionStrength(client.Character, "huskinfection", 0) == 0 then
            table.insert(targets, client)
        end
    end
    if #targets == 0 then
        Megamod.Log("No valid targets found for infection. Canceling...", true)
        return
    end
    local target = targets[math.random(#targets)]
    Megamod.AddAffliction(target.Character, "huskinfection", 1)
    Megamod.Log("Infected '" .. tostring(target.Name) .. "' with husk.", true)
end

---@param fast boolean
function event.End(fast)
end

return event
