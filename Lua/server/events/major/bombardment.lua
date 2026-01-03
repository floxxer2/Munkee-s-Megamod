local event = {}

event.Name = "Bombardment"

event.Severity = "major"

event.Enabled = true

event.Started = false

event.CanEnd = false

event.OneOff = false


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
    local amountShellsInVolley = math.random(3, 5)
    local amountVolleys = math.random(2, 4)

    local total = amountShellsInVolley * amountVolleys
    Megamod.Log("Firing " .. total .. " railgun shells at the station.", true)

    local str = "RAILGUN BOMBARDMENT INCOMING. BRACE FOR IMPACT."
    if total >= 10 and total <= 15 then
        str = "HEAVY " .. str
    elseif total > 15 then
        str = "EXTREMELY HEAVY " .. str
    end

    -- All shells will come from one direction
    local r = 12000
    local randTheta = math.rad(math.random(0, 360))
    local spawnPoint = Vector2(Submarine.MainSub.WorldPosition.X + (r * math.cos(randTheta)),
        Submarine.MainSub.WorldPosition.Y + (r * math.sin(randTheta)))
    spawnPoint = Vector2.Add(spawnPoint, Vector2(math.random(1000), math.random(1000)))
    local rotation = Megamod.AngleBetweenVector2(spawnPoint, Vector2.Add(Submarine.MainSub.WorldPosition, Vector2(0, 2000)))

    Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab("mm_notifalarm"), spawnPoint)
    for client in Client.ClientList do
        Megamod.SendChatMessage(client, str, Color(255, 50, 50, 255))
    end

    local shellPrefab = ItemPrefab.GetItemPrefab("railgunshell")
    --local c4Prefab = ItemPrefab.GetItemPrefab("c4block")

    local volleyTimer = coroutine.create(function(self)
        ::restart::
        if not Game.RoundStarted then return end

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
            coroutine.resume(self)
        end, timeBetweenVolleys)
        coroutine.yield()
        goto restart
    end)
    Timer.Wait(function()
        coroutine.resume(volleyTimer, volleyTimer)
    end, 15000)
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
