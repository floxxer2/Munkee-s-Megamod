local cloning = {}

local BASE_COST_MULTIPLIER = 1

local BASE_CLONING_DURATION = 60 -- 1 minute
local BASE_RM_COST = 10
local COST_INCREASE_PER_CLONE = 0
local BASE_RM_RATE = BASE_RM_COST / BASE_CLONING_DURATION

cloning.CloningCostMultiplier = BASE_COST_MULTIPLIER
cloning.CloningDuration = BASE_CLONING_DURATION -- Always same as base atm but it's set up to be able to be changed
-- cloning.BaseRMCost = BASE_RM_COST -- Unused
cloning.CostIncreasePerClone = COST_INCREASE_PER_CLONE
cloning.RMRate = BASE_RM_RATE

-- The current cloning process
cloning.ActiveProcess = nil

-- If set, a dead player using !clone can start their own cloning process
-- References the cloning machine in question
cloning.SelfClone = nil

-- Hypomaxim devices
cloning.Hypomaxims = {}

function cloning.Reset()
    cloning.CloningCostMultiplier = BASE_COST_MULTIPLIER
    cloning.CloningDuration = BASE_CLONING_DURATION
    cloning.RMRate = BASE_RM_RATE
    cloning.ActiveProcess = nil
    cloning.Hypomaxims = {}
    cloning.SelfClone = nil
end

function cloning.ToggleMachineActive(bool, machine, reset)
    local c = machine.GetComponentString('LightComponent')
    Megamod.CreateEntityEvent(c, machine, "IsOn", bool)
    local consumption
    if bool then
        consumption = 1000
    else
        consumption = 10
        if reset then
            machine.SendSignal("Idle", "status_out")
            machine.SendSignal("n/a", "clonee_out")
            machine.SendSignal("n/a", "time_out")
            machine.SendSignal("RM: " .. tostring(BASE_RM_COST * cloning.CloningCostMultiplier), "riftcost_out")
        end
    end
    Megamod.CreateEntityEvent(c, machine, "PowerConsumption", consumption)
end

function cloning.SpawnBuzzer(buzzerType, worldPosition)
    if buzzerType == "success" then
        local prefab = ItemPrefab.GetItemPrefab("mm_cloning_buzzer_success")
        Entity.Spawner.AddItemToSpawnQueue(prefab, worldPosition)
    elseif buzzerType == "failure" then
        local prefab = ItemPrefab.GetItemPrefab("mm_cloning_buzzer_failure")
        Entity.Spawner.AddItemToSpawnQueue(prefab, worldPosition)
    end
end

---@param sendMessage boolean
-- true = successful, false = unsuccessful
function cloning.StopClone(sendMessage, buzzerType, refund)
    if cloning.SelfClone then cloning.SelfClone = nil end
    if not buzzerType then buzzerType = false end
    if not sendMessage then sendMessage = false end
    if refund then
        local prefab = ItemPrefab.GetItemPrefab("riftmat")
        for i = 1, cloning.ActiveProcess[7] do
            Entity.Spawner.AddItemToSpawnQueue(prefab, cloning.ActiveProcess[4].OwnInventory, nil, nil, nil, true)
        end
    end
    if buzzerType then
        cloning.SpawnBuzzer(buzzerType, cloning.ActiveProcess[4].WorldPosition)
    end
    if sendMessage and cloning.ActiveProcess[1] then Megamod.SendChatMessage(cloning.ActiveProcess[1], "Your cloning has been canceled.", Color(255, 0, 255, 255)) end
    cloning.ActiveProcess = nil
end

function cloning.Tick()
    Timer.Wait(function()
        if not Game.RoundStarted or not cloning.ActiveProcess then return cloning.Tick() end

        -- Stop cloning if the client somehow stops spectating (returns to lobby, starts controlling something alive, etc)
        -- We have to check if there is a client because of sleeves (cloning w/o a client makes an empty body)
        if (cloning.ActiveProcess[1] and not Megamod.CheckIsSpectating(cloning.ActiveProcess[1]))
        or Megamod.EventManager.GetEventActive("Hunt") -- Don't clone during Hunts
        then
            cloning.ToggleMachineActive(false, cloning.ActiveProcess[4])
            cloning.StopClone(true, "failure", true)
            return cloning.Tick()
        end

        if cloning.ActiveProcess[2] > 0 then
            if cloning.ActiveProcess[5] then
                cloning.ActiveProcess[3] = cloning.ActiveProcess[3] + cloning.RMRate
            end

            local mats = {}
            for item in cloning.ActiveProcess[4].OwnInventory.FindAllItems() do
                if item.Prefab.Identifier == "riftmat" then
                    table.insert(mats, item)
                end
            end

            local max = math.floor(cloning.ActiveProcess[3])
            for i = 1, max do
                if #mats == 0 then break end
                cloning.ActiveProcess[3] = cloning.ActiveProcess[3] - 1
                cloning.ActiveProcess[7] = cloning.ActiveProcess[7] + 1
                -- Remove a rift material from the cloning machine
                Entity.Spawner.AddItemToRemoveQueue(mats[#mats])
                table.remove(mats, #mats)
            end
        end

        local c = cloning.ActiveProcess[4].GetComponentString('LightComponent')
        local powered = c.Voltage >= c.MinVoltage
        -- If we lack both material and power, display both
        if cloning.ActiveProcess[3] >= 1 and not powered then
            cloning.ActiveProcess[4].SendSignal("ERROR: NO_POWER / NEED_RIFT_MATERIAL", "status_out")
        end
        cloning.ActiveProcess[5] = cloning.ActiveProcess[3] < 1 and powered
        if cloning.ActiveProcess[5] then
            if cloning.ActiveProcess[6] then
                cloning.ActiveProcess[6] = false
                cloning.ToggleMachineActive(true, cloning.ActiveProcess[4])
                cloning.SpawnBuzzer("success", cloning.ActiveProcess[4].WorldPosition)
                if cloning.ActiveProcess[1] then
                    Megamod.SendChatMessage(cloning.ActiveProcess[1], "Cloning has resumed.", Color(255, 0, 255, 255))
                end
                cloning.ActiveProcess[4].SendSignal("Active", "status_out")
            end
            -- Initial beep on process start
            if cloning.ActiveProcess[2] == cloning.CloningDuration then
                local prefab = ItemPrefab.GetItemPrefab("mm_cloning_buzzer_success")
                Entity.Spawner.AddItemToSpawnQueue(prefab, cloning.ActiveProcess[4].WorldPosition)
            end
            cloning.ToggleMachineActive(true, cloning.ActiveProcess[4])
            if cloning.ActiveProcess[2] > 0 then
                cloning.ActiveProcess[2] = cloning.ActiveProcess[2] - 1
            end
        elseif cloning.ActiveProcess[3] >= 1 and not cloning.ActiveProcess[6] then
            cloning.ActiveProcess[6] = true
            cloning.ToggleMachineActive(false, cloning.ActiveProcess[4])
            cloning.SpawnBuzzer("failure", cloning.ActiveProcess[4].WorldPosition)
            if cloning.ActiveProcess[1] then
                Megamod.SendChatMessage(cloning.ActiveProcess[1],
                    "Cloning has paused because the cloning machine lacks rift material.",
                    Color(255, 0, 255, 255))
            end
            cloning.ActiveProcess[4].SendSignal("ERROR: NEED_RIFT_MATERIAL", "status_out")
            return cloning.Tick()
        elseif not powered and not cloning.ActiveProcess[6] then
            cloning.ActiveProcess[6] = true
            cloning.ToggleMachineActive(false, cloning.ActiveProcess[4])
            cloning.SpawnBuzzer("failure", cloning.ActiveProcess[4].WorldPosition)
            if cloning.ActiveProcess[1] then
                Megamod.SendChatMessage(cloning.ActiveProcess[1],
                    "Cloning has paused because the cloning machine is not powered.",
                    Color(255, 0, 255, 255))
            end
            cloning.ActiveProcess[4].SendSignal("ERROR: NO_POWER", "status_out")
            return cloning.Tick()
        end

        cloning.ActiveProcess[4].SendSignal(tostring(cloning.ActiveProcess[2]) .. " s", "time_out")
        cloning.ActiveProcess[4].SendSignal(tostring(BASE_RM_COST * cloning.CloningCostMultiplier - cloning.ActiveProcess[7]) .. " RM", "riftcost_out")

        -- Success
        if cloning.ActiveProcess[2] <= 0 then
            local intended = BASE_RM_COST * cloning.CloningCostMultiplier
            -- This can happen due to precision errors
            if cloning.ActiveProcess[7] ~= intended then
                Megamod.Log("CLONING: Rift Material used was not the same as the intended requirement. Correcting...", true)
                if cloning.ActiveProcess[7] > intended then
                    local amountToRefund = cloning.ActiveProcess[7] - intended
                    local prefab = ItemPrefab.GetItemPrefab("riftmat")
                    for i = 1, amountToRefund do
                        Entity.Spawner.AddItemToSpawnQueue(prefab, cloning.ActiveProcess[4].OwnInventory, nil, nil, nil, true)
                    end
                else
                    local amountToTake = intended - cloning.ActiveProcess[7]
                    local mats = {}
                    for item in cloning.ActiveProcess[4].OwnInventory.FindAllItems() do
                        if item.Prefab.Identifier == "riftmat" then
                            table.insert(mats, item)
                        end
                    end
                    for i = 1, amountToTake do
                        -- Not enough material to take, set back the process and force it to eat more material
                        if #mats == 0 then
                            cloning.ActiveProcess[2] = 1
                            cloning.ActiveProcess[3] = i
                            return cloning.Tick()
                        end
                        Entity.Spawner.AddItemToRemoveQueue(mats[1])
                        table.remove(mats, 1)
                    end
                end
                cloning.ActiveProcess[7] = intended
            end

            -- This increases the amount of rift material used for the next cloning process
            cloning.CloningCostMultiplier = cloning.CloningCostMultiplier + cloning.CostIncreasePerClone
            cloning.RMRate = BASE_RM_RATE * cloning.CloningCostMultiplier

            if cloning.ActiveProcess[1] then -- Players
                local pos = cloning.ActiveProcess[4].WorldPosition
                local info = CharacterInfo("Human", cloning.ActiveProcess[8][1], cloning.ActiveProcess[8][1], cloning.ActiveProcess[8][2], cloning.ActiveProcess[8][2].Variant, RandSync.ServerAndClient, nil)
                -- Copies over cosmetic choices
                info.Head = cloning.ActiveProcess[8][3]
                local char = Character.Create(info, pos, info.Name, 0, false, false)

                char.TeamID = 1
                -- Make sure all clients have the clonee's team set to 1
                local msg = Networking.Start("mm_setteam")
                msg.WriteUInt64(char.ID)
                for client in Client.ClientList do
                    Networking.Send(msg, client.Connection)
                end

                cloning.ActiveProcess[1].SetClientCharacter(char)

                local str = "You have been revived by a cloning machine."
                -- Make sure traitors know that they are still a traitor after being cloned
                if #Megamod.RuleSetManager.AntagStatus(cloning.ActiveProcess[1], "Traitor") > 0 then
                    str = "You have been revived by a cloning machine.\nYOU ARE STILL A TRAITOR!"
                end
                Megamod.SendChatMessage(cloning.ActiveProcess[1], str, Color(255, 0, 255, 255))
                Megamod.Log("Client '" .. tostring(cloning.ActiveProcess[1].Name) .. "' (Steam: " .. cloning.ActiveProcess[1].SteamID .. ") was revived via cloning.", true)
            else -- Sleeves, 'empty' humans
                local pos = cloning.ActiveProcess[4].WorldPosition
                local info = CharacterInfo("Human", "Sleeve", "Sleeve", JobPrefab.Get("assistant"), nil, RandSync.ServerAndClient, nil)
                local sleeve = Character.Create(info, pos, info.Name, 0, false, false)

                sleeve.TeamID = 1
                -- Make sure all clients have the sleeve's team set to 1
                local msg = Networking.Start("mm_setteam")
                msg.WriteUInt64(sleeve.ID)
                for client in Client.ClientList do
                    Networking.Send(msg, client.Connection)
                end

                -- Give artifical brain to imitate being consciousness-less
                local prefab = AfflictionPrefab.Prefabs["artificialbrain"]
                local limb = sleeve.AnimController.GetLimb(LimbType.Head)
                sleeve.CharacterHealth.ApplyAffliction(limb, prefab.Instantiate(2))

                sleeve.TeamID = CharacterTeamType.Team1

                Megamod.Log("A sleeve was created via cloning.", true)
            end

            cloning.ToggleMachineActive(false, cloning.ActiveProcess[4], true)
            cloning.StopClone(false, "success", false)
        end

        return cloning.Tick()
    end, 1000)
end
cloning.Tick()

function cloning.StartProcess(client, machine, infoTbl)
    local c = machine.GetComponentString('LightComponent')
    local powered = c.Voltage >= c.MinVoltage
    if not powered then return end
    local tbl = {
        [1] = client, -- The client, if nil then we're making an "empty" human - a sleeve
        [2] = cloning.CloningDuration, -- How long till the clonee is revived, as an integer in seconds
        [3] = 0, -- Used for rift material requirement
        [4] = machine, -- The cloning machine
        [5] = true, -- False if the cloning machine should stop ticking down the timer
        [6] = false,  -- True if the cloning process is currently paused (prevents repeated pause notifications)
        [7] = 0, -- Amount of rift material used
        [8] = infoTbl, -- Table for data about how we should respawn the person
    }
    cloning.ActiveProcess = tbl
    if client then
        Megamod.SendChatMessage(client, "A cloning machine is reviving you.\nUse the command !clone to check your progress.", Color(255, 0, 255, 255))
        cloning.ActiveProcess[4].SendSignal(tostring(client.Name), "clonee_out")
    else
        cloning.ActiveProcess[4].SendSignal("_SLEEVE_", "clonee_out")
    end
    cloning.ActiveProcess[4].SendSignal("Active", "status_out")
end

local lastSelfCloningMsgTime = 0
local SELF_CLONING_CDN = 15
local cdn = {}
local CDN_BASE = 5
Hook.Add("mm.cloningstart", "Megamod.Cloning.CloningStart", function(effect, deltaTime, item, targets, worldPosition)
    -- Doesn't work if there's already a process, or during Hunts
    if cloning.ActiveProcess
    or Megamod.EventManager.GetEventActive("Hunt")
    then return end
    local cloners = {}
    for client in Client.ClientList do
        if not Megamod.CheckIsDead(client) then
            local dist = Vector2.Distance(client.Character.WorldPosition, item.WorldPosition)
            if dist < 190 then
                table.insert(cloners, client)
            end
        end
    end
    for cloner in cloners do
        if cdn[cloner] and Timer.GetTime() - cdn[cloner] < CDN_BASE then
            for cloner in cloners do
                Megamod.SendChatMessage(cloner, "Please don't spam the cloning machine.\n(Wait ~5 seconds before you hit 'start' again.)", Color(255, 0, 255, 255))
            end
            return
        end
        cdn[cloner] = Timer.GetTime() + CDN_BASE
    end
    local hypomaxim = item.OwnInventory.GetItemAt(6)
    -- No hypomaxim -> make a "sleeve," a human with no consciousness
    if not hypomaxim then
        cloning.StartProcess(nil, item)
        return
    end
    local targetClient = cloning.Hypomaxims[hypomaxim] and cloning.Hypomaxims[hypomaxim][1]
    -- Hypomaxim inserted but no stored client = self clone (ask dead players to clone)
    if not targetClient and not cloning.SelfClone then
        Megamod.CreateEntityEvent(hypomaxim, hypomaxim, "NonInteractable", true)
        cloning.SelfClone = item
        if Timer.GetTime() - lastSelfCloningMsgTime < SELF_CLONING_CDN then
            local str = "Self-cloning enabled, but dead players were not notified because you're spamming the machine.\n(Wait ~15 seconds to activate self-cloning again.)"
            for cloner in cloners do
                Megamod.SendChatMessage(cloner, str, Color(255, 0, 255, 255))
            end
            return
        end
        lastSelfCloningMsgTime = Timer.GetTime()
        local str = "Self-cloning activated. Use the chat command \"!clone\" to respawn yourself at a cloning machine.\nYOU SPAWN WITH NOTHING! Only do this if you are sure you will survive!"
        for client in Client.ClientList do
            if #Megamod.RuleSetManager.AntagStatus(client) == 0
            and Megamod.CheckIsSpectating(client) then
                Megamod.SendChatMessage(client, str, Color(255, 0, 255, 255))
            end
        end
        return
    end
    if Megamod.CheckIsSpectating(targetClient) then
        cloning.StartProcess(targetClient, item, cloning.Hypomaxims[hypomaxim][4])
        cloning.Hypomaxims[hypomaxim] = nil
        Entity.Spawner.AddItemToRemoveQueue(hypomaxim)
    end
end)

Hook.Add("mm.cloningstop", "Megamod.Cloning.CloningStop", function(effect, deltaTime, item, targets, worldPosition)
    if cloning.ActiveProcess then
        cloning.ToggleMachineActive(false, cloning.ActiveProcess[4], true)
        cloning.StopClone(true, "failure", true)
    end
    if cloning.SelfClone then
        cloning.SelfClone = nil
        local hypomaxim = item.OwnInventory.GetItemAt(6)
        if hypomaxim then
            Megamod.CreateEntityEvent(hypomaxim, hypomaxim, "NonInteractable", false)
        else
            Megamod.Error("Self clone was enabled, but hypomaxim not found in cloning machine.")
        end
    end
end)

function cloning.InitHypomaxim(hypomaxim)
    if not cloning.Hypomaxims[hypomaxim] then
        cloning.Hypomaxims[hypomaxim] = { [3] = 2 }
        return true
    end
    return false
end

function cloning.SetHypomaxim(hypomaxim, client)
    if not client then return end
    if not hypomaxim then return end
    local char = client.Character
    if not char then return end
    cloning.InitHypomaxim(hypomaxim)
    cloning.Hypomaxims[hypomaxim][1] = client
    cloning.Hypomaxims[hypomaxim][2] = char.DisplayName
    cloning.Hypomaxims[hypomaxim][4] = { tostring(client.Name), char.Info.Job, char.Info.Head }
    return true
end

Hook.Add("mm.hypomaximUse", "Megamod.Cloning.HypomaximUse", function(effect, deltaTime, item, targets, worldPosition)
    local usingChar = item.GetRootInventoryOwner()
    if not usingChar then return end
    local client = Util.FindClientCharacter(usingChar)
    if not client then return end
    cloning.InitHypomaxim(item)
    local t = targets[1]
    local targetClient = Util.FindClientCharacter(t)
    if not t.IsHuman or not targetClient then
        Megamod.SendClientSideMsg(client, "Invalid target.", Color(255, 0, 255))
        return
    end
    if usingChar.TeamID ~= t.TeamID then
        Megamod.SendClientSideMsg(client, "That is an enemy.", Color(255, 0, 255))
        return
    end
    -- Revive them if this hypomaxim is in revive mode (don't care if they're dead or not)
    if cloning.Hypomaxims[item][3] == 1 then
        -- Give the hypomaxim affliction so they won't die again right after being revived
        local prefab = AfflictionPrefab.Prefabs["mm_hypomaxim"]
        local limb = t.AnimController.GetLimb(LimbType.Torso)
        t.CharacterHealth.ApplyAffliction(limb, prefab.Instantiate(180))

        -- Keeps afflictions, so whatever killed them is still there
        t.Revive(false, true)
        targetClient.SetClientCharacter(t)

        Megamod.SendChatMessage(targetClient, "You have been revived by a hypomaxim device.", Color(255, 0, 255, 255))
        Megamod.Log("Client '" .. tostring(targetClient.Name) .. "' (Steam: " .. targetClient.SteamID .. ") was revived via hypomaxim.", true)

        Megamod.SendClientSideMsg(client, "Revived " .. tostring(t.DisplayName) .. ".", Color(255, 0, 255))

        cloning.Hypomaxims[item] = nil
        Entity.Spawner.AddItemToRemoveQueue(item)
        return
    end
    -- Hypomaxim is in store mode...

    cloning.SetHypomaxim(item, targetClient)

    Megamod.SendClientSideMsg(client, tostring(t.DisplayName) .. " stored.", Color(255, 0, 255))
end)

Hook.Add("mm.hypomaximReset", "Megamod.Cloning.HypomaximReset", function(effect, deltaTime, item, targets, worldPosition)
    local usingChar = item.GetRootInventoryOwner()
    if not usingChar then return end
    local client = Util.FindClientCharacter(usingChar)
    if not client then return end
    cloning.InitHypomaxim(item)
    if cloning.Hypomaxims[item] and cloning.Hypomaxims[item][1] or cloning.Hypomaxims[item][2] then
        cloning.Hypomaxims[item][1] = nil
        cloning.Hypomaxims[item][2] = nil
        Megamod.SendClientSideMsg(client, "Successful - reset current data.", Color(255, 0, 255))
    else
        Megamod.SendClientSideMsg(client, "No data to reset.", Color(255, 0, 255))
    end
end)

Hook.Add("mm.hypomaximInfo", "Megamod.Cloning.HypomaximInfo", function(effect, deltaTime, item, targets, worldPosition)
    local usingChar = item.GetRootInventoryOwner()
    if not usingChar or not LuaUserData.IsTargetType(usingChar, "Barotrauma.Character") then return end
    local client = Util.FindClientCharacter(usingChar)
    if not client then return end
    cloning.InitHypomaxim(item)
    local targetName = cloning.Hypomaxims[item] and cloning.Hypomaxims[item][2]
    if targetName then
        Megamod.SendClientSideMsg(client, "Stored: " .. targetName, Color(255, 0, 255))
    else
        Megamod.SendClientSideMsg(client, "No data.", Color(255, 0, 255))
    end
end)

Hook.Add("mm.hypomaximMode", "Megamod.Cloning.HypomaximMode", function(effect, deltaTime, item, targets, worldPosition)
    local usingChar = item.GetRootInventoryOwner()
    if not usingChar then return end
    local client = Util.FindClientCharacter(usingChar)
    if not client then return end
    cloning.InitHypomaxim(item)
    local currentMode = cloning.Hypomaxims[item][3]
    if currentMode == 1 then
        cloning.Hypomaxims[item][3] = 2
        Megamod.SendClientSideMsg(client, "Set mode to Store.", Color(255, 0, 255))
    elseif currentMode == 2 then
        cloning.Hypomaxims[item][3] = 1
        Megamod.SendClientSideMsg(client, "Set mode to Revive.", Color(255, 0, 255))
    end
end)

Hook.Add("roundEnd", "Megamod.Cloning.End", cloning.Reset)

return cloning
