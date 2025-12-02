local m = {}

--m.MaxExpeditionMonsters = 10

--[[m.ExpeditionMonsterIDs = {
    -- [monster id] = spawn chance
    ["husk"] = 100,
    ["husksprintercombat"] = 25,
    ["husksprinterhumanold"] = 25,
    ["husk_chimera"] = 1
}

m.ExpeditionMonstersMaxSpawnAtOnce = {
    -- [monster id] = max number that can be spawned in one rift
    ["husk"] = 5,
    ["husksprintercombat"] = 3,
    ["husksprinterhumanold"] = 3,
    ["husk_chimera"] = 1
}

m.ExpeditionMonstersRiftMats = {
    -- [monster id] = {min rift mats, max rift mats}
    ["husk"] = {12, 20},
    ["husksprintercombat"] = {20, 32},
    ["husksprinterhumanold"] = {20, 32},
    ["husk_chimera"] = {64, 86}
}]]

m.MapSpecificFunctions = {}
m.CurrentMap = nil -- Could be substituted for Submarine.MainSub
m.Reactors = {} -- Primary reactor(s) on the map
m.StationaryLights = {}
m.RoundStartTime = 0

m.BeastAlarmLights = {}
m.BeastMems1 = {}
m.BeastMems2 = {}

m.DeepVents = nil -- A sub
m.DVOutside = {} -- DV Access Points on the station
m.DVInside = {} -- DV Access Points in the Deep Vents
m.DVConnections = {}

local lightIDs = {
    "lamp",
    "lightfluorescentm01",
    "lightfluorescentm02",
    "lightfluorescentm03",
    "lightfluorescentm04",
    "lightfluorescentl01",
    "lightfluorescentl02",
    "lighthalogenmm01",
    "lighthalogenmm02",
    "lighthalogenmm03",
    "lighthalogenm04",
    "lightleds01",
    "lightfluorescentm01wrecked",
    "lightfluorescentm02wrecked",
    "lightfluorescentm03wrecked",
    "lightfluorescentm04wrecked",
    "lightfluorescentl01wrecked",
    "lightfluorescentl02wrecked",
    "lighthalogenmm01wrecked",
    "lighthalogenmm02wrecked",
    "lighthalogenmm03wrecked",
    "lighthalogenm04wrecked",
    "lightleds01wrecked",
}

Networking.Receive("mm_subpos", function(message, client)
    local subs = {}
    for sub in Submarine.Loaded do
        if sub.PhysicsBody.BodyType == Megamod.PhysicsBodyTypes.Static then
            table.insert(subs, sub)
        end
    end
    local msg = Networking.Start("mm_subpos")
    msg.WriteByte(#subs)
    for sub in subs do
        msg.WriteUInt16(tonumber(sub.ID))
        msg.WriteInt64(sub.WorldPosition.X)
        msg.WriteInt64(sub.WorldPosition.Y)
        msg.WriteBoolean(sub ~= Submarine.MainSub) -- Undock if it's not the station
    end
    Networking.Send(msg, client.Connection)
end)

m.MapSpecificFunctions["Sierra Station"] = function()
    for k, item in pairs(m.CurrentMap.GetItems(true)) do
        if item.Prefab.Identifier == "reactor1" then -- Sierra uses a reactor1
            table.insert(m.Reactors, item)
            break
        end
    end

    --[[local function expeditionLoop()
        Timer.Wait(function()
            if math.random() <= 0.1 then
                local indexesToRemove = {}
                for k, v in pairs(m.ExpeditionMonsters) do
                    if not v or v.IsDead then
                        table.insert(indexesToRemove, k)
                    end
                end
                for indexToRemove in indexesToRemove do
                    m.ExpeditionMonsters[indexToRemove] = nil
                end

                if #m.ExpeditionMonsters >= m.MaxExpeditionMonsters then return expeditionLoop() end

                local spawnPoint = m.ExpeditionSpawns[math.random(#m.ExpeditionSpawns)]
                if not spawnPoint then
                    Megamod_Server.Error("No spawnpoint for expedition monster found. Canceling spawn...")
                    return expeditionLoop()
                end

                local monsterID = weightedRandom.Choose(m.ExpeditionMonsterIDs)
                if not monsterID then
                    Megamod_Server.Error("No suitable expedition monster to spawn. Canceling spawn...")
                    return expeditionLoop()
                end

                local prefab = ItemPrefab.GetItemPrefab("mm_rift")
                Entity.Spawner.AddItemToSpawnQueue(prefab, spawnPoint.WorldPosition)

                Timer.Wait(function()
                    local numberToSpawn = math.random(1, m.ExpeditionMonstersMaxSpawnAtOnce[monsterID])
                    -- Make sure we don't spawn more than the limit
                    if #m.ExpeditionMonsters + numberToSpawn > m.MaxExpeditionMonsters then
                        numberToSpawn = 1
                    end
                    for i = 1, numberToSpawn do
                        local monster = Character.Create(monsterID, spawnPoint.WorldPosition, "", nil, 0, false, true, true, nil, true, true)

                        local AfflictionPrefab = AfflictionPrefab.Prefabs["mm_monsterantiparalysis"]
                        local limb = monster.AnimController.MainLimb
                        monster.CharacterHealth.ApplyAffliction(limb, AfflictionPrefab.Instantiate(1))

                        local riftMatsToSpawn = math.random(m.ExpeditionMonstersRiftMats[monsterID][1], m.ExpeditionMonstersRiftMats[monsterID][2])
                        local riftMatPrefab = ItemPrefab.GetItemPrefab("riftmat")
                        for r = 1, riftMatsToSpawn do
                            Entity.Spawner.AddItemToSpawnQueue(riftMatPrefab, monster.Inventory)
                        end

                        table.insert(m.ExpeditionMonsters, monster)
                    end
                end, 5000)
            end
            if Game.RoundStarted then return expeditionLoop() end
        end, 10000)
    end
    expeditionLoop()]]
end

m.MapSpecificFunctions["Tsunya Station"] = function()
    for k, item in pairs(m.CurrentMap.GetItems(true)) do
        if item.Prefab.Identifier == "ekdockyard_reactorfusion_medium" then -- Tsunya uses an ekdockyard_reactorfusion_medium
            table.insert(m.Reactors, item)
            break
        end
    end
end

function m.OnStart()
    m.RoundStartTime = Timer.GetTime()
    m.CurrentMap = Submarine.MainSub

    for sub in Submarine.Loaded do
        if tostring(sub.Info.Name) == "DV 1" then
            m.DeepVents = sub
            break
        end
    end

    Megamod.Subs.SetSubBodyType(m.CurrentMap, "static")

    -- Teleport the Deep Vents very far left
    m.DeepVents.SetPosition(Vector2(-2000000, m.DeepVents.WorldPosition.Y), nil, true)
    Megamod.Subs.SetSubBodyType(m.DeepVents, "static")

    for item in Item.ItemList do
        -- Could conflict with other elseif's, so they're separate
        if item.GetComponentString("LightComponent") then
            for lightID in lightIDs do
                if tostring(item.Prefab.Identifier) == lightID then
                    table.insert(m.StationaryLights, item)
                    break
                end
            end
        end
        if item.HasTag("beast_light") then -- The red rotating alarm lights
            table.insert(m.BeastAlarmLights, item)
        elseif item.HasTag("beast_memc1") then -- Memory component controlling alarm lights
            table.insert(m.BeastMems1, item)
        elseif item.HasTag("beast_memc2") then -- Memory component controlling alarm lights
            table.insert(m.BeastMems2, item)
        elseif item.HasTag("outside") then -- DV Access Points on the station
            table.insert(m.DVOutside, item)
        elseif item.HasTag("inside") then -- DV Access Points in the Deep Vents
            table.insert(m.DVInside, item)
        end
    end

    -- Randomize the Deep Vents Access Point connections
    local used = {}
    for dvo in m.DVOutside do
        local validInside = {}
        for dvi in m.DVInside do
            local isUsed = false
            for usedDVI in used do
                if usedDVI == dvi then
                    isUsed = true
                    break
                end
            end
            if not isUsed then
                table.insert(validInside, dvi)
            end
        end
        local dvi = validInside[math.random(#validInside)]
        table.insert(m.DVConnections, { Outside = dvo, Inside = dvi })
        table.insert(used, dvi)
    end
    -- Hide any inactive inside DV points
    for dvi in m.DVInside do
        local connected = false
        for usedDVI in used do
            if usedDVI == dvi then
                connected = true
                break
            end
        end
        if not connected then
            Megamod.CreateEntityEvent(dvi, dvi, "HiddenInGame", true)
        else -- Can happen if Lua is reloaded midround
            Megamod.CreateEntityEvent(dvi, dvi, "HiddenInGame", false)
        end
    end

    local subName = tostring(Submarine.MainSub.Info.Name)
    for mapID, func in pairs(m.MapSpecificFunctions) do
        if subName == mapID then
            func()
            break
        end
    end

    -- Finalize, we wait on this so that the rulesetmanager can declare round type
    Timer.Wait(function()
        if Megamod.RuleSetManager.RoundType == 2 then
            -- Have to wait even more to do godmode, because commands can't be executed
            -- while the round is loading
            Timer.Wait(function() Game.ExecuteCommand("godmode_mainsub") end, 5000)
            -- For some reason there's a ReadOnly specifically for repairables, let's use it
            for item in Item.RepairableItems do
                if not item.GetComponentString('Door') then
                    Megamod.CreateEntityEvent(item, item, "InvulnerableToDamage", true)
                end
            end
            -- Make everybody's id cards noninteractable
            for client in Client.ClientList do
                if client.Character then
                    for item in client.Character.Inventory.GetAllItems(false) do
                        if item.HasTag("identitycard") then
                            Megamod.CreateEntityEvent(item, item, "NonInteractable", true)
                            break
                        end
                    end
                end
            end
        end
        for reactor in m.Reactors do
            local c = reactor.GetComponentString("Reactor")
            c.PowerUpImmediately() -- Force enable the reactor
            if Megamod.RuleSetManager.RoundType == 2 then
                -- Make the reactor noninteractable to prevent sabotaging it
                Megamod.CreateEntityEvent(reactor, reactor, "NonInteractable", true)
                -- Make the reactor's fuel never run out
                for item in reactor.OwnInventory.GetAllItems(false) do
                    Megamod.CreateEntityEvent(item, item, "InvulnerableToDamage", true)
                end
            end
        end
    end, 750)
end
Hook.Add("roundStart", "Megamod.Maps.RoundStart", m.OnStart)
-- Call OnStart if Lua was reloaded midround
if Game.RoundStarted then
    m.OnStart()
end

function m.Reset()
    m.CurrentMap = nil
    m.Reactors = {}
    m.StationaryLights = {}
    m.RoundStartTime = nil
    m.BeastAlarmLights = {}
    m.BeastMems1 = {}
    m.BeastMems2 = {}
    m.DeepVents = nil
    m.DVOutside = {}
    m.DVInside = {}
    m.DVConnections = {}
end
Hook.Add("roundEnd", "Megamod.Maps.RoundEnd", m.Reset)

return m
