local event = {}

event.Name = "Radiation Storm"

event.Severity = "major"

event.Enabled = true

event.Started = false

event.CanEnd = false

event.OneOff = false


function event.Check()
    return true
end

-- 5-7 minutes
local timer = -1
function event.Loop()
    if not Game.RoundStarted or timer <= 0 then
        if event.Started then
            Megamod.EventManager.EndEvent(event.Name)
        end
        return
    end
    timer = timer - 1
    for character in Character.CharacterList do
        if character and not character.IsDead then
            local hull = character.CurrentHull
            if not hull
            or (hull.Submarine ~= Submarine.MainSub -- Don't irradiate on the station
            and hull.Submarine ~= Megamod.Map.DeepVents) -- Don't irradiate in the Deep Vents
            then
                HF.AddAffliction(character, "radiationsickness", 7)
            end
        end
    end
    Timer.Wait(function()
        return event.Loop()
    end, 5000)
end

function event.Start()
    event.Started = true
    event.CanEnd = true
    Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab("mm_notifalarm"), Submarine.MainSub.WorldPosition)
    local str = "A radiation storm will be passing over this area shortly. Stay within the station to avoid irradiation."
    for client in Client.ClientList do
        Megamod.SendChatMessage(client, str, Color(255, 50, 50, 255))
    end
    timer = math.random(60, 84)
    Timer.Wait(function()
        event.Loop()
    end, 30000)
end

---@param fast boolean
function event.End(fast)
    event.Started = false
    event.CanEnd = false
    timer = -1 -- Stops the loop
    if not Game.RoundStarted then return end
    local str = "The radiation storm has passed."
    for client in Client.ClientList do
        Megamod.SendChatMessage(client, str, Color(255, 50, 50, 255))
    end
end

return event
