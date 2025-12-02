local event = {}

event.Name = "Hunt"

event.Severity = "special"

event.Enabled = true

event.Started = false

event.CanEnd = false

event.OneOff = false


event.SecondPhase = false

-- Clients who reload CL Lua midround need to know if a Hunt is active
Networking.Receive("mm_huntactive", function(message, client)
    if event.SecondPhase then
        local msg = Networking.Start("mm_huntactive")
        msg.WriteBoolean(false) -- Don't apply camera shake
        Networking.Send(msg, client.Connection)
    end
end)

-- #TODO#: This should be setup properly after the Beast ruleset is done
function event.Check()
    return true
end

function event.ToggleAlarmLights(toggle)
    if toggle then
        -- Add a random offset to each light's rotation
        for mem2 in Megamod.Map.BeastMems2 do
            local c = mem2.GetComponentString('MemoryComponent')
            Megamod.CreateEntityEvent(c, mem2, "Value", math.random(0, 360))
        end

        for light in Megamod.Map.BeastAlarmLights do
            -- Slightly randomize the red intensity
            local c = light.GetComponentString('LightComponent')
            Megamod.CreateEntityEvent(c, light, "LightColor", Color(255, 0, 0, math.random(175, 255)))
        end

        -- Toggle the light and enable rotation
        for mem1 in Megamod.Map.BeastMems1 do
            local c = mem1.GetComponentString('MemoryComponent')
            Megamod.CreateEntityEvent(c, mem1, "Value", 1)
        end
    else
        -- Toggle the light and disable rotation
        for mem in Megamod.Map.BeastMems1 do
            local c = mem.GetComponentString('MemoryComponent')
            Megamod.CreateEntityEvent(c, mem, "Value", 0)
        end
    end
end

function event.ToggleFlicker(light, toggle)
    local c = light.GetComponentString('LightComponent')

    if toggle then
        -- Must be a multiple of 0.1
        Megamod.CreateEntityEvent(c, light, "Flicker", math.random(5, 10) / 10)
        -- Must be a multiple of 0.1
        Megamod.CreateEntityEvent(c, light, "FlickerSpeed", math.random(2) / 10)
    else
        Megamod.CreateEntityEvent(c, light, "Flicker", 0)
        Megamod.CreateEntityEvent(c, light, "FlickerSpeed", 0)
    end
end

function event.Start()
    event.Started = true

    -- Make lights flicker for a bit
    for v in Megamod.Map.StationaryLights do
        Timer.Wait(function()
            event.ToggleFlicker(v, true)
        end, math.random(4000, 7000))
    end

    local wait = math.random(15000, 17500)
    Timer.Wait(function()
        local prefab = ItemPrefab.GetItemPrefab("mm_notifalarm")
        Entity.Spawner.AddItemToSpawnQueue(prefab, Submarine.MainSub.WorldPosition)
    end, wait - 4000)

    Timer.Wait(function()
        local str = "BEAST ALARM TRIPPED. PREPARE."
        for client in Client.ClientList do
            Megamod.SendChatMessage(client, str, Color(200, 0, 75, 255))
        end
        -- Blackout stationary lights
        -- We don't worry about turning them back on, as this event should always end off the round
        for v in Megamod.Map.StationaryLights do
            Timer.Wait(function()
                event.ToggleFlicker(v, false)
                local c = v.GetComponentString('LightComponent')
                Megamod.CreateEntityEvent(c, v, "LightColor", Color(0, 0, 0, 0))
            end, math.random(250, 500))
        end
        -- Enable alarm lights, spawn beast alarm
        Timer.Wait(function()
            if not Game.RoundStarted then return end
            event.ToggleAlarmLights(true)
            local prefab = ItemPrefab.GetItemPrefab("mm_beastalarm")
            local rand = math.random(4)
            local pos = nil
            -- 1 - North | 2 - East | 3 - South | 4 - West
            if rand == 1 then
                pos = Vector2.Add(Submarine.MainSub.WorldPosition, Vector2(0, 20000))
                pos = Vector2.Add(pos, Vector2(math.random(-20000, 20000), 0))
            elseif rand == 2 then
                pos = Vector2.Add(Submarine.MainSub.WorldPosition, Vector2(20000, 0))
                pos = Vector2.Add(pos, Vector2(0, math.random(-20000, 20000)))
            elseif rand == 3 then
                pos = Vector2.Subtract(Submarine.MainSub.WorldPosition, Vector2(0, 20000))
                pos = Vector2.Add(pos, Vector2(math.random(-20000, 20000), 0))
            elseif rand == 4 then
                pos = Vector2.Subtract(Submarine.MainSub.WorldPosition, Vector2(20000, 0))
                pos = Vector2.Add(pos, Vector2(0, math.random(-20000, 20000)))
            end
            Entity.Spawner.AddItemToSpawnQueue(prefab, pos)
        end, 1500)
    end, wait)

    Timer.Wait(function()
        if not Game.RoundStarted then return end
        event.SecondPhase = true
        Megamod.Log("A Hunt has entered its second phase.", true)

        -- Prevent headsets from working
        Hook.Patch("Megamod.NoRadioHuntsSERVER", "Barotrauma.Networking.ChatMessage", "CanUseRadio",
        { "Barotrauma.Character", "out Barotrauma.Items.Components.WifiComponent", "System.Boolean" }, function(instance, ptable)
            if event.SecondPhase then
                ptable.PreventExecution = true
                return false
            end
        end, Hook.HookMethodType.Before)

        local message = Networking.Start("mm_huntactive")
        message.WriteBoolean(true) -- Apply camera shake
        -- Send to all clients
        for client in Client.ClientList do
            Networking.Send(message, client.Connection)
        end

        -- Make sure joining clients get the message
        Hook.Add("client.connected", "Megamod.Events.HuntEvent.ClientConnected", function(client)
            local message = Networking.Start("mm_huntactive")
            Networking.Send(message, client.Connection)
        end)

        Hook.Patch("Megamod.Events.Hunt.NoFire", "Barotrauma.FireSource", "Update", function(instance, ptable)
            instance["Remove"]()
            ptable.PreventExecution = true
        end, Hook.HookMethodType.Before)

        -- Disable the reactor(s)
        for reactor in Megamod.Map.Reactors do
            local reactorComponent = reactor.GetComponentString('Reactor')
            Megamod.CreateEntityEvent(reactorComponent, reactor, "MaxPowerOutput", 0)
            local prefab2 = ItemPrefab.GetItemPrefab("mm_out")
            Entity.Spawner.AddItemToSpawnQueue(prefab2, reactor.WorldPosition)
        end

        -- Disable alarm lights
        event.ToggleAlarmLights(false)

        event.CanEnd = true
    end, 72500)
end

function event.End()
    event.CanEnd = false
    Hook.Remove("client.connected", "Megamod.Events.HuntEvent.ClientConnected")
    Hook.RemovePatch("Megamod.Events.Hunt.NoFire", "Barotrauma.FireSource", "Update", Hook.HookMethodType.Before)
    event.Started = false
    event.SecondPhase = false
    Hook.RemovePatch("Megamod.NoRadioHuntsSERVER", "Barotrauma.Networking.ChatMessage", "CanUseRadio",
    { "Barotrauma.Character", "out Barotrauma.Items.Components.WifiComponent", "System.Boolean" }, Hook.HookMethodType.Before)
end

return event
