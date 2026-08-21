local tbl = {}

-- A reference to the traitor ruleset, this is used in objectives
local rs
-- Wait for the rulesetmanager to initialize
Timer.Wait(function()
    if CLIENT then return end
    for ruleSet in Megamod.RuleSetManager.RuleSets do
        if ruleSet.Name == "Traitor" then
            rs = ruleSet
            break
        end
    end
    if not rs then
        error("Could not find traitor ruleset.")
        return
    end
end, 1)

-- Traitor's uplink store
tbl.shop = {
    [{ "medicaldoctor", "surgeon" }] = {
        --[[["blood scalpel"] = {
            spriteID = "multiscalpel_blood",
            type = "item",
            cost = 3,
            stock = 2,
            desc = "\"Surgically inspect\" the captain.",
            buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                local prefab = ItemPrefab.GetItemPrefab("multiscalpel_blood")
                Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                return true, "" -- success
            end
        },]]
        --[[["flashlight syringe"] = {
            spriteID = "flashlightsyringe",
            type = "item",
            cost = 3,
            stock = 1,
            desc = "A syringe gun that looks like a flashlight.",
            buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                local prefab = ItemPrefab.GetItemPrefab("flashlightsyringe")
                Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                return true, "" -- success
            end
        },]]
        ["husk egg injector"] = {
            spriteID = "mm_huskegginjector",
            type = "item",
            cost = 2,
            stock = 4,
            desc = "Adds friends to your morphine.\n(Note: Any method other than the health interface will not cause husk infection.)",
            buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                local prefab = ItemPrefab.GetItemPrefab("mm_huskegginjector")
                Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                return true, "" -- success
            end
        }
    },
    [{ "engineer", "mechanic" }] = {
        ["stun prod"] = {
            spriteID = "mm_stunprod",
            type = "item",
            cost = 4,
            stock = 2,
            desc = "Old stun batons supercharged when fueled with dimes.",
            buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                local prefab = ItemPrefab.GetItemPrefab("mm_stunprod")
                Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                return true, "" -- success
            end
        },
        ["contraband welder"] = {
            spriteID = "scp_contrawelder",
            type = "item",
            cost = 4,
            stock = 2,
            desc = "It won't give *you* eye damage.",
            buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                local prefab = ItemPrefab.GetItemPrefab("scp_contrawelder")
                Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                return true, "" -- success
            end
        },
    },
    ["assistant"] = {
    },
    ["all"] = {
        -- Vanilla traitor item
        ["radio jammer"] = {
            spriteID = "radiojammer",
            type = "item",
            cost = 3,
            stock = 2,
            desc = "It's on the tin.",
            buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                local prefab = ItemPrefab.GetItemPrefab("radiojammer")
                Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                return true, "" -- success
            end
        },
        ["zip ties"] = {
            spriteID = "stasky",
            type = "item",
            cost = 1,
            stock = 3,
            desc = "A traitor's handcuffs.",
            buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                local prefab = ItemPrefab.GetItemPrefab("stasky")
                Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                return true, "" -- success
            end
        },
        ["plastic bag"] = {
            spriteID = "plasticbag",
            type = "item",
            cost = 1,
            stock = 3,
            desc = "The most effective weapon.",
            buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                local prefab = ItemPrefab.GetItemPrefab("plasticbag")
                Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                return true, "" -- success
            end
        },
        ["suicide belt"] = {
            spriteID = "shahidka",
            type = "item",
            cost = 4,
            stock = 2,
            desc = "Quite the lethal prank. Explosive not included.",
            buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                local prefab = ItemPrefab.GetItemPrefab("shahidka")
                Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                return true, "" -- success
            end
        },
        ["suicide vest"] = {
            spriteID = "shahidkatimer",
            type = "item",
            cost = 4,
            stock = 2,
            desc = "Strap it on someone, preferably not yourself. Explosive not included.",
            buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                local prefab = ItemPrefab.GetItemPrefab("shahidkatimer")
                Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                return true, "" -- success
            end
        },
        ["blindfold"] = {
            spriteID = "blindfold",
            type = "item",
            cost = 1,
            stock = 3,
            desc = "It blinds. And folds.",
            buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                local prefab = ItemPrefab.GetItemPrefab("blindfold")
                Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                return true, "" -- success
            end
        },
        ["muzzle"] = {
            spriteID = "muzzle",
            type = "item",
            cost = 1,
            stock = 3,
            desc = "It has use.",
            buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                local prefab = ItemPrefab.GetItemPrefab("muzzle")
                Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                return true, "" -- success
            end
        },
        ["alcd"] = {
            spriteID = "emag",
            type = "item",
            cost = 2,
            stock = 1,
            desc = "ID card access level copy device.",
            buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                local prefab = ItemPrefab.GetItemPrefab("emag")
                Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                return true, "" -- success
            end
        },
        ["reverse bear trap"] = {
            spriteID = "reversebeartrap",
            type = "item",
            cost = 2,
            stock = 3,
            desc = "I want to play a game.",
            buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                local prefab = ItemPrefab.GetItemPrefab("reversebeartrap")
                Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                return true, "" -- success
            end
        },
        ["revolver"] = {
            -- Just uses the revolver
            spriteID = "scp_r8",
            type = "item",
            cost = 7,
            stock = 1,
            desc = "A .357 revolver, comes with 16 shots.",
            buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                local prefab = ItemPrefab.GetItemPrefab("scp_r8")
                Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                local prefab = ItemPrefab.GetItemPrefab("scp_357round")
                for i = 1, 16 do
                    Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                end
                return true, "" -- success
            end
        },
        ["contraband shiv"] = {
            spriteID = "scp_shiv",
            type = "item",
            cost = 2,
            stock = 4,
            desc = "Very destructive to kneecaps.",
            buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                local prefab = ItemPrefab.GetItemPrefab("scp_shiv")
                Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                return true, "" -- success
            end
        },
        ["contraband crowbar"] = {
            spriteID = "scp_crowbar",
            type = "item",
            cost = 3,
            stock = 3,
            desc = "Effectiveness may vary.",
            buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                local prefab = ItemPrefab.GetItemPrefab("scp_crowbar")
                Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                return true, "" -- success
            end
        },
        ["contraband baton"] = {
            spriteID = "scp_batoncontra",
            type = "item",
            cost = 4,
            stock = 2,
            desc = "A persuasive argument.",
            buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                local prefab = ItemPrefab.GetItemPrefab("scp_batoncontra")
                Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                return true, "" -- success
            end
        },
        ["contraband container"] = {
            spriteID = "scp_contrabandcontainer",
            type = "item",
            cost = 2,
            stock = 2,
            desc = "Hide your tools.",
            buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                local prefab = ItemPrefab.GetItemPrefab("scp_contrabandcontainer")
                Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                return true, "" -- success
            end
        },
        ["molotov"] = {
            spriteID = "molotovcoctail",
            type = "item",
            cost = 2,
            stock = 3,
            desc = "A spicy cocktail.",
            buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                local prefab = ItemPrefab.GetItemPrefab("molotovcoctail")
                Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                return true, "" -- success
            end
        },
        ["frag grenade bouquet"] = {
            spriteID = "sgt_fraggrenadebouquet",
            type = "item",
            cost = 4,
            stock = 3,
            desc = "Three frag grenades taped together. Rather loud.",
            buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                local prefab = ItemPrefab.GetItemPrefab("sgt_fraggrenadebouquet")
                Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                return true, "" -- success
            end
        },
        --[[["dart gun"] = {
            spriteID = "mm_dartgun",
            type = "item",
            cost = 4,
            stock = 3,
            desc = "Uses mostly any syringe to synthesize and fire nearly undetectable darts. The gun itself is not as stealthy as the darts.",
            buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                local prefab = ItemPrefab.GetItemPrefab("mm_dartgun")
                Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                return true, "" -- success
            end
        },]]
        ["cyanide"] = {
            spriteID = "cyanide",
            type = "item",
            cost = 4,
            stock = 3,
            desc = "Kills fast, but it's very obvious.",
            buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                local prefab = ItemPrefab.GetItemPrefab("cyanide")
                Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                return true, "" -- success
            end
        },
        ["morbusine"] = {
            spriteID = "morbusine",
            type = "item",
            cost = 3,
            stock = 3,
            desc = "A rather lame poison.",
            buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                local prefab = ItemPrefab.GetItemPrefab("morbusine")
                Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                return true, "" -- success
            end
        },
        ["sufforin"] = {
            spriteID = "sufforin",
            type = "item",
            cost = 4,
            stock = 3,
            desc = "Sneakier than the others.",
            buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                local prefab = ItemPrefab.GetItemPrefab("sufforin")
                Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                return true, "" -- success
            end
        },
        ["radiotoxin"] = {
            spriteID = "radiotoxin",
            type = "item",
            cost = 4,
            stock = 3,
            desc = "Very deadly.",
            buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                local prefab = ItemPrefab.GetItemPrefab("radiotoxin")
                Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                return true, "" -- success
            end
        },
        ["paralyzant"] = {
            spriteID = "paralyzant",
            type = "item",
            cost = 4,
            stock = 3,
            desc = "What are you plotting?",
            buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                local prefab = ItemPrefab.GetItemPrefab("paralyzant")
                Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                return true, "" -- success
            end
        },
        ["calyx extract"] = {
            spriteID = "huskeggs",
            type = "item",
            cost = 4,
            stock = 3,
            desc = "I enjoy these little guys. Maybe not so much for you.",
            buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                local prefab = ItemPrefab.GetItemPrefab("huskeggs")
                Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                return true, "" -- success
            end
        },
        --[[["pale horse"] = {
            spriteID = "sgt_berserk",
            type = "item",
            cost = 6,
            stock = 1,
            desc = "Makes you comparable.",
            buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                local prefab = ItemPrefab.GetItemPrefab("sgt_berserk")
                Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                return true, "" -- success
            end
        },]]
        --[[["dime locator"] = {
            spriteID = "mm_dime",
            type = "upgrade",
            cost = 1,
            stock = 1,
            desc = "Should help you find dimensional essence, though it's not as effective in your hands.",
            buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                rs.Items.Uplinks[uplinkItem][7]["dime locator"] = function(uplinkItem, terminal, client, argument)
                    local msg = Networking.Start("mm_dimelocator")
                    msg.WriteBoolean(true) -- True = toggle, false = disable
                    Networking.Send(msg, client.Connection)
                    return "Dime locator toggled."
                end
                return true, ""
            end
        },]]
    }
}

-- Get the timer reduction from the credit value of the objective
local function creditTimer(creditValue)
    return (creditValue + 1) * 50
end

local function completeObj(self, traitor, extraReturns)
    Megamod.Log("Traitor " .. tostring(traitor.Name) .. " completed their '" .. self.Name .. "' objective.", true)
    rs.SelectedPlayers[traitor][2][6] = rs.SelectedPlayers[traitor][2][6] + self.Credit
    rs.SelectedPlayers[traitor][2][4] = rs.SelectedPlayers[traitor][2][4] - creditTimer(self.Credit)
    rs.SelectedPlayers[traitor][2][7] = math.random(30, 60) -- Cooldown of 30-60 seconds till you can get another objective
    rs.SelectedPlayers[traitor][2][8] = false
    rs.SelectedPlayers[traitor][2][3] = nil
    local prefab = ItemPrefab.GetItemPrefab("mm_dime")
    if Megamod.CheckIsDead(traitor) == false then
        for i = 1, self.Credit do
            Entity.Spawner.AddItemToSpawnQueue(prefab, traitor.Character.Inventory, nil, nil, nil, true)
        end
    end
    return rs.SuccessMessages[math.random(#rs.SuccessMessages)] .. "\n(Objective completed. Await your next.)", true
end

local function assign(self, traitor, target, desc, objFunc)
    rs.SelectedPlayers[traitor][2][3] = {
        Name = self.Name,
        Desc = desc,
        Credit = self.Credit,
        Target = target,
        NoPenalty = false,
        Obj = objFunc
    }
end

-- Objectives
tbl.obj = {
    -- #TODO#: Thief, Meeting
    { -- Murder: Kill a crewmate who is not security or captain - must kill confirm
        Name = "Murder",
        Jobs = "all",
        Chance = 50,
        Credit = 4,
        MinStrength = 1,
        DescriptionChat = {
            "KILL \"%s\" FOR ME WOULD YOU",
            "I NEED \"%s\" OUT OF THE PICTURE",
            "DISPOSE OF \"%s\" PLEASE",
            "LET \"%s\" SLEEP WITH THE FISHES",
            "I NEED \"%s\" TO BE DONE AWAY WITH",
        },
        DescriptionReal = "(Kill %s, then click 'complete objective' when near their corpse.)",
        -- >=50% of crew must be alive and healthy
        -- There must be at least one healthy crewmate who is not security or captain
        Check = function(traitor)
            local healthyTargets = 0
            local totalTargets = 0
            local target = false
            for client in Client.ClientList do
                if #Megamod.RuleSetManager.AntagStatus(client, "Traitor") == 0 then -- Must not be a traitor, other antags are valid
                    totalTargets = totalTargets + 1
                    local jobID = (client.Character and tostring(client.Character.JobIdentifier)) or ""
                    if Megamod.CheckIsDead(client) == false
                    and client.Character
                    and client.Character.IsHuman
                    and client.Character.Vitality > 40
                    then
                        healthyTargets = healthyTargets + 1
                        if not target
                        and jobID ~= "captain"
                        and jobID ~= "securityofficer" then
                            target = true
                        end
                    end
                end
            end
            return target and (healthyTargets / math.max(totalTargets, 1) >= 0.5)
        end,
        Assign = function(self, traitor)
            local potentialTargets = {}
            for client in Client.ClientList do
                local jobID = (client.Character and tostring(client.Character.JobIdentifier)) or ""
                if Megamod.CheckIsDead(client) == false
                and client.Character
                and client.Character.IsHuman
                and client.Character.Vitality > 5
                and #Megamod.RuleSetManager.AntagStatus(client, "Traitor") == 0
                and jobID ~= "captain"
                and jobID ~= "securityofficer"
                then
                    table.insert(potentialTargets, { client, client.Character })
                end
            end
            local target = potentialTargets[math.random(#potentialTargets)]
            Megamod.Log("Gave objective '" .. self.Name .. "' (target: '" .. tostring(target[1].Name) .. "' as '" .. tostring(target[2].Name) .. "') to '" .. tostring(traitor.Name) .. "'")
            local chosenChat = math.random(#self.DescriptionChat)
            local desc = string.format(self.DescriptionChat[chosenChat] .. "\n" .. self.DescriptionReal, target[2].Name, target[2].Name)
            assign(self, traitor, target, desc, function(client)
                if not client.Character then return "" end
                if not target[2] then
                    rs.SelectedPlayers[traitor][2][3]["NoPenalty"] = true
                    return "Target no longer exists. Canceling this will not incur a penalty.", false
                end
                local distance = Vector2.Distance(client.Character.WorldPosition, target[2].WorldPosition)
                if distance < 115 then
                    if target[2].IsDead then
                        return self:Complete(traitor)
                    else
                        return "Target is not dead.", false
                    end
                else
                    return "Target not in range.", false
                end
            end)
            return self.Name .. "\n" .. desc, target, chosenChat
        end,
        Complete = completeObj
    },
    { -- Kidnapping: Kidnap a crewmate who is not security or captain and take them to the Deep Vents
        Name = "Kidnapping",
        Jobs = "all",
        Chance = 40,
        Credit = 5,
        MinStrength = 3,
        DescriptionChat = {
            "I NEED TO HAVE A WORD WITH \"%s\"",
            "GIVE ME \"%s\"",
            "COME TO ME AND TAKE \"%s\" WITH YOU",
            "GET \"%s\"",
            "RIP \"%s\" FROM THE STATION",
        },
        DescriptionReal = "(Take %s to the Deep Vents and use the 'obj' command in your uplink near them.)",
        -- >=50% of crew must be alive and healthy
        -- There must be at least one healthy crewmate who is not security or captain
        Check = function(traitor)
            local healthyTargets = 0
            local totalTargets = 0
            local target = false
            for client in Client.ClientList do
                if #Megamod.RuleSetManager.AntagStatus(client, "Traitor") == 0 then -- Must not be a traitor, other antags are valid
                    totalTargets = totalTargets + 1
                    local jobID = (client.Character and tostring(client.Character.JobIdentifier)) or ""
                    if Megamod.CheckIsDead(client) == false
                    and client.Character
                    and client.Character.IsHuman
                    and client.Character.Vitality > 40
                    then
                        healthyTargets = healthyTargets + 1
                        if not target
                        and jobID ~= "captain"
                        and jobID ~= "securityofficer" then
                            target = true
                        end
                    end
                end
            end
            return target and (healthyTargets / math.max(totalTargets, 1) >= 0.5)
        end,
        Assign = function(self, traitor)
            local potentialTargets = {}
            for client in Client.ClientList do
                local jobID = (client.Character and tostring(client.Character.JobIdentifier)) or ""
                if Megamod.CheckIsDead(client) == false
                and client.Character
                and client.Character.IsHuman
                and client.Character.Vitality > 5
                and #Megamod.RuleSetManager.AntagStatus(client, "Traitor") == 0
                and jobID ~= "captain"
                and jobID ~= "securityofficer"
                then
                    table.insert(potentialTargets, { client, client.Character })
                end
            end
            local target = potentialTargets[math.random(#potentialTargets)]
            Megamod.Log("Gave objective '" .. self.Name .. "' (target: '" .. tostring(target[1].Name) .. "' as '" .. tostring(target[2].Name) .. "') to '" .. tostring(traitor.Name) .. "'")
            local chosenChat = math.random(#self.DescriptionChat)
            local desc = string.format(self.DescriptionChat[chosenChat] .. "\n" .. self.DescriptionReal, target[2].Name, target[2].Name)
            assign(self, traitor, target, desc, function(client)
                if not client.Character then return "" end
                if not target[2] then
                    rs.SelectedPlayers[traitor][2][3]["NoPenalty"] = true
                    return "Target no longer exists. Canceling this will not incur a penalty."
                elseif target[2].IsDead then
                    rs.SelectedPlayers[traitor][2][3]["NoPenalty"] = true
                    return "Target is dead. Canceling this will not incur a penalty."
                end
                local hull = client.Character.CurrentHull
                if hull.RoomName ~= "???" then
                    return "You must be in the Deep Vents."
                end
                local distance = Vector2.Distance(client.Character.WorldPosition, target[2].WorldPosition)
                if distance < 115 then
                    Megamod.SendChatMessage(target[1], "You have been kidnapped by a traitor. Your only hope is to be cloned...", Color(255, 100, 100, 255))
                    Entity.Spawner.AddEntityToRemoveQueue(target[2])
                    return self:Complete(traitor)
                else
                    return "Target not in range."
                end
            end)
            return self.Name .. "\n" .. desc, target, chosenChat
        end,
        Complete = completeObj
    },
    { -- Regicide: Kill a captain or security - must kill confirm
        Name = "Regicide",
        Jobs = "all",
        Chance = 10,
        Credit = 7,
        MinStrength = 6,
        DescriptionChat = {
            "\"%s\" HAS BEEN IN POWER FOR TOO LONG  FIX THAT",
            "REMOVE \"%s\" FROM OFFICE",
            "TAKE \"%s\" OFF THEIR THRONE",
            "IMPEACH \"%s\"",
            "THE PRESIDENCY OF \"%s\" MUST COME TO AN END",
        },
        DescriptionReal = "(Kill %s, then use the 'obj' command in your uplink when near their corpse.)",
        -- >=50% of crew must be alive and healthy
        -- There must be at least one healthy security or captain
        Check = function(traitor)
            local healthyTargets = 0
            local totalTargets = 0
            local target = false
            for client in Client.ClientList do
                if #Megamod.RuleSetManager.AntagStatus(client, "Traitor") == 0 then -- Must not be a traitor, other antags are valid
                    totalTargets = totalTargets + 1
                    local jobID = (client.Character and tostring(client.Character.JobIdentifier)) or ""
                    if Megamod.CheckIsDead(client) == false
                    and client.Character
                    and client.Character.IsHuman
                    and client.Character.Vitality > 40
                    then
                        healthyTargets = healthyTargets + 1
                        if not target
                        and (jobID == "captain"
                        or jobID == "securityofficer") then
                            target = true
                        end
                    end
                end
            end
            return target and (healthyTargets / math.max(totalTargets, 1) >= 0.5)
        end,
        Assign = function(self, traitor)
            local potentialTargets = {}
            for client in Client.ClientList do
                local jobID = (client.Character and tostring(client.Character.JobIdentifier)) or ""
                if Megamod.CheckIsDead(client) == false
                and client.Character
                and client.Character.IsHuman
                and client.Character.Vitality > 5
                and (jobID == "captain" or jobID == "securityofficer") -- No need for an antag check, security / captain are never antags
                then
                    table.insert(potentialTargets, { client, client.Character })
                end
            end
            local target = potentialTargets[math.random(#potentialTargets)]
            Megamod.Log("Gave objective '" .. self.Name .. "' (target: '" .. tostring(target[1].Name) .. "' as '" .. tostring(target[2].Name) .. "') to '" .. tostring(traitor.Name) .. "'")
            local chosenChat = math.random(#self.DescriptionChat)
            local desc = string.format(self.DescriptionChat[chosenChat] .. "\n" .. self.DescriptionReal, target[2].Name, target[2].Name)
            assign(self, traitor, target, desc, function(client)
                if not client.Character then return "" end
                if not target[2] then
                    rs.SelectedPlayers[traitor][2][3]["NoPenalty"] = true
                    return "Target no longer exists. Canceling this will not incur a penalty."
                end
                local distance = Vector2.Distance(client.Character.WorldPosition, target[2].WorldPosition)
                if distance < 115 then
                    if target[2].IsDead then
                        return self:Complete(traitor)
                    else
                        return "Target is not dead."
                    end
                else
                    return "Target not in range."
                end
            end)
            return self.Name .. "\n" .. desc, target, chosenChat
        end,
        Complete = completeObj
    },
    { -- Brainwashing: Same as Kidnap, but instead of deleting the victim, they turn into another traitor
        Name = "Brainwashing",
        Jobs = "all",
        Chance = 30,
        Credit = 5,
        MinStrength = 3,
        DescriptionChat = {
            "TAKE \"%s\" TO ME AND I'LL GIVE THEM A HELPING HAND",
            "\"%s\" LOOKS LIKE A FINE CANDIDATE",
            "THE TEAM IS FALTERING  \"%s\" COULD FIX THAT",
            "\"%s\" SEEMS LIKE THEY ARE RESPONSIBLE ENOUGH",
            "TAKE \"%s\" TO ME AND I'LL DO THE REST",
        },
        DescriptionReal = "(Take %s to the Deep Vents and use the 'obj' command in your uplink near them. They will turn into another traitor.)",
        -- >=50% of crew must be alive and healthy
        -- There must be at least one crewmate who is not security or captain
        -- At most 4 people can be turned into traitors in one round
        Check = function(traitor)
            if rs.TraitorAmount >= 4 then return false end
            local healthyTargets = 0
            local totalTargets = 0
            local target = false
            for client in Client.ClientList do
                if #Megamod.RuleSetManager.AntagStatus(client, "Traitor") == 0 then -- Must not be a traitor, other antags are valid
                    totalTargets = totalTargets + 1
                    local jobID = (client.Character and tostring(client.Character.JobIdentifier)) or ""
                    if Megamod.CheckIsDead(client) == false
                    and client.Character
                    and client.Character.IsHuman
                    and client.Character.Vitality > 40
                    then
                        healthyTargets = healthyTargets + 1
                        if not target
                        and jobID ~= "captain"
                        and jobID ~= "securityofficer" then
                            target = true
                        end
                    end
                end
            end
            return target and (healthyTargets / math.max(totalTargets, 1) >= 0.5)
        end,
        Assign = function(self, traitor)
            local potentialTargets = {}
            for client in Client.ClientList do
                local jobID = (client.Character and tostring(client.Character.JobIdentifier)) or ""
                if Megamod.CheckIsDead(client) == false
                and client.Character
                and client.Character.IsHuman
                and client.Character.Vitality > 5
                and jobID ~= "captain"
                and jobID ~= "securityofficer"
                and #Megamod.RuleSetManager.AntagStatus(client, "Traitor") == 0 -- Must not be a traitor, other antags are valid
                then
                    table.insert(potentialTargets, { client, client.Character })
                end
            end
            local target = potentialTargets[math.random(#potentialTargets)]
            Megamod.Log("Gave objective '" .. self.Name .. "' (target: '" .. tostring(target[1].Name) .. "' as '" .. tostring(target[2].Name) .. "') to '" .. tostring(traitor.Name) .. "'")
            local chosenChat = math.random(#self.DescriptionChat)
            local desc = string.format(self.DescriptionChat[chosenChat] .. "\n" .. self.DescriptionReal, target[2].Name, target[2].Name)
            assign(self, traitor, target, desc, function(client)
                if not client.Character then return "" end
                if not target[2] then
                    rs.SelectedPlayers[traitor][2][3]["NoPenalty"] = true
                    return "Target no longer exists. Canceling this will not incur a penalty."
                elseif target[2].IsDead then
                    rs.SelectedPlayers[traitor][2][3]["NoPenalty"] = true
                    return "Target is dead. Canceling this will not incur a penalty."
                end
                local hull = client.Character.CurrentHull
                if hull.RoomName ~= "???" then
                    return "You must be in the Deep Vents."
                end
                local distance = Vector2.Distance(client.Character.WorldPosition, target[2].WorldPosition)
                if distance < 115 then
                    if target[1] then
                        Megamod.SendChatMessage(target[1], "You have been converted into a traitor.", Color(255, 0, 255, 255))
                        Megamod.GiveAntagOverlay(target[2])
                        rs.SetTraitor(target[1], true)
                    end
                    return self:Complete(traitor)
                else
                    return "Target not in range."
                end
            end)
            return self.Name .. "\n" .. desc, target, chosenChat
        end,
        Complete = completeObj
    },
    { -- Double Agent: Kill a traitor who hasn't been following their objectives - must kill confirm
        Name = "Double Agent",
        Jobs = "all",
        Chance = 200, -- Very high chance if check() succeeds
        Credit = 7,
        MinStrength = 0,
        DescriptionChat = {
            "\"%s\" HASN'T BEEN UP TO SNUFF",
            "\"%s\" IS A LIABILITY TO THE TEAM",
            "\"%s\" HASN'T BEEN FOLLOWING ORDERS",
            "\"%s\" HASN'T BEEN DOING THEIR JOB",
            "\"%s\" ISN'T AS EVIL AS THE REST OF YOU",
        },
        DescriptionReal = "(Kill %s, then use the 'obj' command in your uplink when near their corpse.)",
        Check = function(traitor) -- There must be at least one traitor whose timer is >480
            for client in Client.ClientList do
                if client ~= traitor
                and #Megamod.RuleSetManager.AntagStatus(client, "Traitor") ~= 0 -- Must be a traitor
                and Megamod.CheckIsDead(client) == false
                and client.Character
                and client.Character.IsHuman
                and rs.SelectedPlayers[client][2][4] > 480
                then
                    return true
                end
            end
            return false
        end,
        Assign = function(self, traitor)
            local potentialTargets = {}
            for client in Client.ClientList do
                if client ~= traitor
                and #Megamod.RuleSetManager.AntagStatus(client, "Traitor") ~= 0 -- Must be a traitor
                and Megamod.CheckIsDead(client) == false
                and client.Character
                and client.Character.IsHuman
                and rs.SelectedPlayers[client][2][4] > 480
                then
                    table.insert(potentialTargets, { client, client.Character })
                end
            end
            local target = potentialTargets[math.random(#potentialTargets)]
            Megamod.Log("Gave objective '" .. self.Name .. "' (target: '" .. tostring(target[1].Name) .. "' as '" .. tostring(target[2].Name) .. "') to '" .. tostring(traitor.Name) .. "'")
            local chosenChat = math.random(#self.DescriptionChat)
            local desc = string.format(self.DescriptionChat[chosenChat] .. "\n" .. self.DescriptionReal, target[2].Name, target[2].Name)
            assign(self, traitor, target, desc, function(client)
                if not client.Character then return "" end
                if not target[2] then
                    rs.SelectedPlayers[traitor][2][3]["NoPenalty"] = true
                    return "Target no longer exists. Canceling this will not incur a penalty."
                end
                local distance = Vector2.Distance(client.Character.WorldPosition, target[2].WorldPosition)
                if distance < 115 then
                    if target[2].IsDead then
                        return self:Complete(traitor)
                    else
                        return "Target is not dead."
                    end
                else
                    return "Target not in range."
                end
            end)
            return self.Name .. "\n" .. desc, target, chosenChat
        end,
        Complete = completeObj
    },
    { -- Loan Shark: Same as Double Agent, but use the 'return' command on their uplink instead of killing them
        Name = "Loan Shark",
        Jobs = "all",
        Chance = 200, -- Very high chance if check() succeeds
        Credit = 7,
        MinStrength = 0,
        DescriptionChat = {
            "\"%s\" HASN'T BEEN UP TO SNUFF",
            "\"%s\" IS A LIABILITY TO THE TEAM",
            "\"%s\" HASN'T BEEN FOLLOWING ORDERS",
            "\"%s\" HASN'T BEEN DOING THEIR JOB",
            "\"%s\" ISN'T AS EVIL AS THE REST OF YOU",
        },
        DescriptionReal = "(Use the 'return' command on the uplink assigned to %s.)",
        Check = function(traitor) -- There must be at least one traitor whose timer is >480
            for client in Client.ClientList do
                if client ~= traitor
                and #Megamod.RuleSetManager.AntagStatus(client, "Traitor") ~= 0 -- Must be a traitor
                and Megamod.CheckIsDead(client) == false
                and client.Character
                and client.Character.IsHuman
                and rs.SelectedPlayers[client][2][4] > 480
                then
                    return true
                end
            end
            return false
        end,
        Assign = function(self, traitor)
            local potentialTargets = {}
            for client in Client.ClientList do
                if client ~= traitor
                and #Megamod.RuleSetManager.AntagStatus(client, "Traitor") ~= 0 -- Must be a traitor
                and Megamod.CheckIsDead(client) == false
                and client.Character
                and client.Character.IsHuman
                and rs.SelectedPlayers[client][2][4] > 480
                then
                    table.insert(potentialTargets, { client, client.Character })
                end
            end
            local target = potentialTargets[math.random(#potentialTargets)]
            Megamod.Log("Gave objective '" .. self.Name .. "' (target: '" .. tostring(target[1].Name) .. "' as '" .. tostring(target[2].Name) .. "') to '" .. tostring(traitor.Name) .. "'")
            local chosenChat = math.random(#self.DescriptionChat)
            local desc = string.format(self.DescriptionChat[chosenChat] .. "\n" .. self.DescriptionReal, target[2].Name, target[2].Name)
            assign(self, traitor, target, desc, function(client)
                if not client.Character then return "" end
                if not target[2] then
                    rs.SelectedPlayers[traitor][2][3]["NoPenalty"] = true
                    return "Target no longer exists. Canceling this will not incur a penalty."
                end
                return "Use the 'return' command on the target's uplink."
            end)
            return self.Name .. "\n" .. desc, target, chosenChat
        end,
        Complete = completeObj
    },
    --[[{ -- Payment: Send the Lender some amount of dimes
        Name = "Payment",
        Jobs = "all",
        Chance = 15,
        Credit = 0,
        MinStrength = 0,
        DescriptionChat = {
            "I NEED %d ESSENCE",
            "%d ESSENCE  THAT'S IT",
            "I REQUIRE %d ESSENCE FROM YOU",
            "%d ESSENCE",
            "ESSENCE  %d UNITS",
        },
        DescriptionReal = "(Have %d dime(s) in your hotbar, then use the 'obj' command in your uplink.)",
        Check = function(traitor) -- Always available
            return true
        end,
        Assign = function(self, traitor)
            local target = math.random(rs.Strength, math.floor(rs.Strength * 1.5))
            Megamod.Log("Gave objective '" .. self.Name .. "' (target: " .. tostring(target) .. ") to '" .. tostring(traitor.Name) .. "'")
            local chosenChat = math.random(#self.DescriptionChat)
            local desc = string.format(self.DescriptionChat[chosenChat] .. "\n" .. self.DescriptionReal, target, target)
            assign(self, traitor, target, desc, function(client)
                if not client.Character then return "" end
                local items = client.Character.Inventory.GetAllItems(false)
                local dimes = {}
                for item in items do
                    if tostring(item.Prefab.Identifier) == "mm_dime" then
                        table.insert(dimes, item)
                    end
                end
                if #dimes >= target then
                    for i = 1, target do
                        Entity.Spawner.AddItemToRemoveQueue(dimes[i])
                    end
                    return self:Complete(traitor)
                else
                    return "Not enough dimes."
                end
            end)
            return self.Name .. "\n" .. desc, target, chosenChat
        end,
        Complete = completeObj
    },]]
    { -- End of the Road: Kill all non-traitors; handled separately but shown as an objective in uplinks
        Name = "End of the Road",
        Jobs = "all",
        Chance = 1, -- n/a, but must be >0
        EOTR = true, -- This obj is special
        Credit = 15,
        MinStrength = 0, -- n/a - kept for consistency
        DescriptionChat = {
            "IT IS TIME",
            "THE CLOCK STRIKES TWELVE",
            "FETCH ME THEIR SOULS",
            "TIME TO PAY THE REAPER",
            "I'VE BECOME IMPATIENT",
        },
        DescriptionReal = "(Kill everybody who isn't a traitor. This objective ends the round when completed.)",
        Check = function(traitor) -- n/a
        end,
        Assign = function(self, traitor)
            local target = "n/a"
            Megamod.Log("Gave objective '" .. self.Name .. "' (target: " .. tostring(target) .. ") to '" .. tostring(traitor.Name) .. "'")
            local desc = self.DescriptionChat[math.random(#self.DescriptionChat)] .. "\n" .. self.DescriptionReal
            assign(self, traitor, target, desc, function(client)
                return "Kill them all. This objective will complete automatically."
            end)
            return self.Name .. "\n" .. desc
        end,
        Complete = completeObj
    },
}

return tbl
