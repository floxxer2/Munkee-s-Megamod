local event = {}

event.Name = "Bombardment"

event.Severity = "major"

event.Enabled = true

event.Started = false

event.CanEnd = false

event.OneOff = false

local function get8WayCardinalDirection(from, to)
    local dx = to.X - from.X
    local dy = to.Y - from.Y
    local angle = math.atan2(dy, dx)
    local degrees = math.deg(angle)

    if degrees >= -22.5 and degrees < 22.5 then
        return "EAST"
    elseif degrees >= 22.5 and degrees < 67.5 then
        return "NORTHEAST"
    elseif degrees >= 67.5 and degrees < 112.5 then
        return "NORTH"
    elseif degrees >= 112.5 and degrees < 157.5 then
        return "NORTHWEST"
    elseif degrees >= 157.5 or degrees < -157.5 then
        return "WEST"
    elseif degrees >= -157.5 and degrees < -112.5 then
        return "SOUTHWEST"
    elseif degrees >= -112.5 and degrees < -67.5 then
        return "SOUTH"
    else
        return "SOUTHEAST"
    end
end

function event.Check()
    return true
end

function event.Start()
    event.Started = true

    -- ["shell id"] = points value
    --[[local shellTable = {
        ["railgunshell"] = 1,
        ["scp_railgunpiercingshell"] = 1,
        ["scp_railgundushell"] = 1,
        ["scp_railgunduflechetteshell"] = 1,
        ["scp_railgunphyspiercingshell"] = 1,
        ["scp_railgunthermoshell"] = 1,
        ["scp_railgunnukemirvshell"] = 1,
        ["scp_railgunerdshell"] = 1,
        ["scp_railgunbunkerbuster"] = 1,
        ["scp_tsarshell"] = 1,
    }]]

    local timeBetweenVolleys = math.random(8000, 15000)
    local timeBetweenShells = math.random(500, 1000)
    local amountShellsInVolley = math.random(2, 3)
    local amountVolleys = math.random(1, 2)

    local total = amountShellsInVolley * amountVolleys
    Megamod.Log("Firing " .. total .. " railgun shells at the station.", true)

    -- All shells will come from one direction
    local r = 12000
    local randTheta = math.rad(math.random(0, 360))
    local spawnPoint = Vector2(Submarine.MainSub.WorldPosition.X + (r * math.cos(randTheta)),
        Submarine.MainSub.WorldPosition.Y + (r * math.sin(randTheta)))
    spawnPoint = Vector2.Add(spawnPoint, Vector2(math.random(-1000, 1000), math.random(-1000, 1000)))
    local rotation = Megamod.AngleBetweenVector2(spawnPoint, Vector2.Add(Submarine.MainSub.WorldPosition, Vector2(0, 2000)))
    local cardinalDirection = get8WayCardinalDirection(Submarine.MainSub.WorldPosition, spawnPoint)

    local str = "RAILGUN BOMBARDMENT INCOMING. BRACE FOR IMPACT."
    str = str .. "\nDETECTED " .. tostring(total) .. " SHELLS FROM [" .. cardinalDirection .. "]"

    Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab("mm_notifalarm"), spawnPoint)
    for client in Client.ClientList do
        Megamod.SendChatMessage(client, str, Color(255, 50, 50, 255))
    end

    local shellPrefab = ItemPrefab.GetItemPrefab("railgunshell")
    --local c4Prefab = ItemPrefab.GetItemPrefab("c4block")

    local function fireVolley()
        if not Game.RoundStarted or not event.Started then return end

        -- Fire a volley of shells
        for i = 1, amountShellsInVolley do
            Timer.Wait(function()
                Entity.Spawner.AddItemToSpawnQueue(shellPrefab, spawnPoint, nil, nil, function(shell)
                    -- Give the shell a c4 payload (DISABLED)
                    --Entity.Spawner.AddItemToSpawnQueue(c4Prefab, shell.OwnInventory, nil, nil, function() end)
                    local c = shell.GetComponentString("Projectile")
                    c.Shoot(nil, shell.SimPosition, shell.SimPosition, rotation + math.rad(math.random(-5, 5)), {}, true, 1, 10000)
                end)
            end, i * timeBetweenShells)
        end

        amountVolleys = amountVolleys - 1
        if amountVolleys <= 0 then
            event.CanEnd = true
            Megamod.EventManager.EndEvent(event.Name)
            return
        end
        Timer.Wait(function()
            fireVolley()
        end, timeBetweenVolleys)
    end
    Timer.Wait(function()
        fireVolley()
    end, 25000)
end

---@param fast boolean
function event.End(fast)
    event.CanEnd = false
    event.Started = false
    Timer.Wait(function()
        if not Game.RoundStarted then return end
        local str = "The bombardment has ended."
        for client in Client.ClientList do
            Megamod.SendChatMessage(client, str, Color(255, 50, 50, 255))
        end
    end, 8000)
end

return event
