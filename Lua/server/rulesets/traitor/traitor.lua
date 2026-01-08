local rs = {}

rs.Name = "Traitor"

rs.Chance = 75

rs.Enabled = true

rs.SelectedPlayers = {}

rs.Strength = 0

rs.AntagName = "Traitor"

rs.FailReason = ""



local weightedRandom = require 'utils.weightedrandom'

rs.Items = {}
rs.Items.Uplinks = {}
rs.Items.HuskInfected = {}

rs.DLeaks = {}

rs.TraitorAmount = 0

-- "End of the Road"
-- If true, the traitors should be killing everyone
rs.EOTR = false

local BASE_UPLINK_ID_CHARS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$&"
rs.UplinkIDChars = BASE_UPLINK_ID_CHARS

rs.RoleMessage =
">> You are a traitor, given power by the Lender in the form of an uplink.\n" ..
">> Type \"!uplink\" to spawn your uplink when you're ready, and don't lose it; you can only use \"!uplink\" once.\n" ..
">> Use your uplink to get special gear and communicate with other traitors.\n" ..
">> Dimensional Leaks will appear in the Deep Vents. Siphon them with your uplink to get more 'dimes,' which are used to buy things in your uplink.\n" ..
">> Your goal is to fulfill the Lender's requests, in the form of objectives.\n" ..
">> Objectives are given to you through your uplink; use the command 'obj' in it to receive your next or advance the current one.\n" ..
">> Type \"!role obj\" (in chat, not your uplink) to view your current objective, if you have accepted one.\n" ..
">> DO NOT IGNORE OBJECTIVES. You took an offer, and it can be taken back."

-- Uplinks
do
    local BASE_DIME_AMOUNT = 2

    local SHOP_BASE = {
        [{ "medicaldoctor", "surgeon" }] = {
            ["blood scalpel"] = {
                type = "item",
                cost = 3,
                stock = 2,
                desc = "\"Surgically inspect\" the captain.",
                buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                    local prefab = ItemPrefab.GetItemPrefab("multiscalpel_blood")
                    Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                    return true, "" -- success
                end
            },
            --[[["flashlight syringe"] = {
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
                type = "item",
                cost = 4,
                stock = 3,
                desc = "Old stun batons supercharged when fueled with dimes.",
                buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                    local prefab = ItemPrefab.GetItemPrefab("mm_stunprod")
                    Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                    return true, "" -- success
                end
            },
            ["contraband welder"] = {
                type = "item",
                cost = 4,
                stock = 4,
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
                type = "item",
                cost = 3,
                stock = 10,
                desc = "It's on the tin.",
                buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                    local prefab = ItemPrefab.GetItemPrefab("radiojammer")
                    Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                    return true, "" -- success
                end
            },
            ["zip ties"] = {
                type = "item",
                cost = 1,
                stock = 10,
                desc = "A traitor's handcuffs.",
                buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                    local prefab = ItemPrefab.GetItemPrefab("stasky")
                    Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                    return true, "" -- success
                end
            },
            ["plastic bag"] = {
                type = "item",
                cost = 1,
                stock = 10,
                desc = "The most effective weapon.",
                buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                    local prefab = ItemPrefab.GetItemPrefab("plasticbag")
                    Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                    return true, "" -- success
                end
            },
            ["suicide belt"] = {
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
            ["molotov"] = {
                type = "item",
                cost = 2,
                stock = 5,
                desc = "A spicy cocktail.",
                buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                    local prefab = ItemPrefab.GetItemPrefab("molotovcoctail")
                    Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                    return true, "" -- success
                end
            },
            ["blindfold"] = {
                type = "item",
                cost = 1,
                stock = 10,
                desc = "It blinds. And folds.",
                buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                    local prefab = ItemPrefab.GetItemPrefab("blindfold")
                    Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                    return true, "" -- success
                end
            },
            ["muzzle"] = {
                type = "item",
                cost = 1,
                stock = 10,
                desc = "It has use.",
                buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                    local prefab = ItemPrefab.GetItemPrefab("muzzle")
                    Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                    return true, "" -- success
                end
            },
            ["alcd"] = {
                type = "item",
                cost = 2,
                stock = 10,
                desc = "ID card access level copy device.",
                buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                    local prefab = ItemPrefab.GetItemPrefab("emag")
                    Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                    return true, "" -- success
                end
            },
            ["reverse bear trap"] = {
                type = "item",
                cost = 2,
                stock = 5,
                desc = "I want to play a game.",
                buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                    local prefab = ItemPrefab.GetItemPrefab("reversebeartrap")
                    Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                    return true, "" -- success
                end
            },
            ["contraband shiv"] = {
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
                type = "item",
                cost = 2,
                stock = 10,
                desc = "Hide your tools.",
                buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                    local prefab = ItemPrefab.GetItemPrefab("scp_contrabandcontainer")
                    Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                    return true, "" -- success
                end
            },
            ["frag grenade bouquet"] = {
                type = "item",
                cost = 4,
                stock = 3,
                desc = "Three frag grenades taped together.",
                buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                    local prefab = ItemPrefab.GetItemPrefab("sgt_fraggrenadebouquet")
                    Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                    return true, "" -- success
                end
            },
            --[[["poison box"] = { -- #TODO#
                type = "item",
                cost = 5,
                stock = 1,
                desc = "Some random poisons in a crate.",
                buy = function(buyer, ruleSet, uplinkItem, shopItemTable)
                    local prefab = ItemPrefab.GetItemPrefab("metalcrate")
                    Entity.Spawner.AddItemToSpawnQueue(prefab, buyer.Character.Inventory)
                    return true, "" -- success
                end
            },]]
            ["dime locator"] = {
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
            },
        }
    }

    function rs.SpawnUplink(traitor)
        local prefab = ItemPrefab.GetItemPrefab("mm_uplink")
        -- Will spawn on ground if inventory is full
        Entity.Spawner.AddItemToSpawnQueue(prefab, traitor.Character.Inventory, nil, nil, function(item)
            rs.SelectedPlayers[traitor][2][2] = item

            item.Tags = "smallitem,uplink"

            -- Failsafe
            if #rs.UplinkIDChars < 3 then
                Megamod.Error("Not enough characters to choose from for traitor lender IDs. Resetting potential characters.")
                rs.UplinkIDChars = BASE_UPLINK_ID_CHARS
            end

            local id = Megamod.RandomWord(rs.UplinkIDChars)
            -- Remove used characters from possible selection; prevents potentially selecting the same id for 2 uplinks
            for str in string.gmatch(id, ".") do
                rs.UplinkIDChars = string.gsub(rs.UplinkIDChars, str, "")
            end

            item.Description = "‖color:gui.red‖\"Lender: " .. id .. " | Borrower: " .. tostring(traitor.Name) .. "\"‖end‖"

            local prefab = ItemPrefab.GetItemPrefab("mm_dime")
            for i = 1, BASE_DIME_AMOUNT do
                Entity.Spawner.AddItemToSpawnQueue(prefab, item.OwnInventory)
            end

            local uplinkShop = {}

            for job, jobShop in pairs(SHOP_BASE) do
                if type(job) == "table" then
                    for subJob in job do
                        if tostring(traitor.Character.JobIdentifier) == subJob then
                            for shopItem, shopItemTable in pairs(jobShop) do
                                local shopItemName = tostring(shopItem)
                                local newShopItemTable = {}
                                for k, v in pairs(shopItemTable) do
                                    newShopItemTable[k] = v
                                end
                                uplinkShop[shopItemName] = newShopItemTable
                            end
                            break
                        end
                    end
                elseif type(job) == "string" then
                    if job == "all" or tostring(traitor.Character.JobIdentifier) == job then
                        for shopItem, shopItemTable in pairs(jobShop) do
                            local shopItemName = tostring(shopItem)
                            local newShopItemTable = {}
                            for k, v in pairs(shopItemTable) do
                                newShopItemTable[k] = v
                            end
                            uplinkShop[shopItemName] = newShopItemTable
                        end
                    end
                end
            end

            rs.Items.Uplinks[item] = {
                [1] = id, -- Unique "Lender ID" of the uplink
                [2] = traitor, -- Original owner
                [3] = uplinkShop, -- Shop for this uplink
                [4] = true, -- If the uplink can be used (i.e. is not being returned)
                [5] = 0, -- 'DV' command cooldown, 2 minutes
                [6] = 0, -- Internal dime count, used for siphoning
                [7] = {}, -- Upgrades that this uplink has
            }

            rs.IDMessageCommands[id] = { item, rs.Items.Uplinks[item] }

            local terminal = item.GetComponentString("Terminal")
            -- Happens sometimes apparently??
            if not terminal then
                Megamod.Error("Terminal component not found on an uplink.")
                return
            end
            terminal.ShowMessage = "Type 'help' for commands."
            terminal.SyncHistory()
        end, true)
    end

    rs.UplinkCommands = {
        ["help"] = function(uplinkItem, terminal, client, argument)
            local ownTbl = rs.Items.Uplinks[uplinkItem]
            if client ~= ownTbl[2] then return "Access denied." end
            local str =
                "Commands:\n" ..
                "help - This message.\n" ..
                "obj - Get your next objective, or advance the current one.\n" ..
                "obj cancel - Cancel your current objective. Only do this if you absolutely can't do it.\n" ..
                "shop/store [item name] - Displays what you can buy. Use the name of an item as an argument to read more. Example: \"shop\" or \"shop zip ties\"\n" ..
                "buy [item name] - \"Spend\" dimes in the shop to do something, usually materializing an item. Example: \"buy zip ties\"\n" ..
                "message/msg [message] - Send an anonymous message to all other uplinks. Example: \"msg I'm a traitor\"\n" ..
                "[other uplink id] [message] - Send an anonymous message to the uplink with the specified Lender ID. Example: \"Y@# Kill that guy\"\n" ..
                "dv - Activate a nearby Deep Vents Access Point. These are found in maintenance areas and are inaccessible to the crew. Has a cooldown of 2 minutes.\n" ..
                "siphon - Used near a Dimensional Leak, siphon it for dimes. Recommended to use a Dime Locator to find leaks.\n" ..
                "func - Typically used for uplink upgrades, such as the dime locator. Example: \"func dime locator\"\n" ..
                "return - Return this uplink. You will become a part of the crew once more.\n\n" ..
                "All commands and arguments are case insensitive. Typing \"help\" is the same as typing \"Help.\"\n" ..
                "The 'Lender ID' of this uplink is written on the back."
            return str
        end,

        ["obj"] = function(uplinkItem, terminal, client, argument)
            local ownTbl = rs.Items.Uplinks[uplinkItem]
            if client ~= ownTbl[2] then return "Access denied." end
            local objective = rs.SelectedPlayers[client][2][3]
            if argument == "cancel" and objective and not rs.EOTR then
                local str = "Canceled objective. Complete your next objective in a timely manner."
                if objective["NoPenalty"] then
                    str = "Canceled objective. No penalty incurred."
                else
                    rs.SelectedPlayers[client][2][4] = rs.SelectedPlayers[client][2][4] + 180
                end
                rs.SelectedPlayers[client][2][3] = nil
                return str
            elseif objective then
                return objective["Obj"](client)
            end
            return rs.CreateObjective(client)
        end,

        ["store"] = function(uplinkItem, terminal, client, argument)
            local ownTbl = rs.Items.Uplinks[uplinkItem]
            if client ~= ownTbl[2] then return "Access denied." end
            local str = ""
            if argument and argument ~= "" then
                local shopItemTable = ownTbl[3][argument]
                if not shopItemTable then
                    str = "That is not in the shop."
                else
                    local desc = shopItemTable["desc"]
                    local cost = shopItemTable["cost"]
                    local stock = shopItemTable["stock"]
                    str = Megamod.Capitalize(argument) ..
                        "\n" .. desc .. "\nCost: " .. cost .. "\nStock: " .. stock .. "\n"
                end
            else
                for shopItemName, shopItemTbl in pairs(ownTbl[3]) do
                    str = str .. "(" .. string.upper(shopItemTbl.type) .. ") " .. Megamod.Capitalize(shopItemName) .. "\n"
                end
            end
            if str == "" then
                str = "The shop for this uplink is empty."
            else
                -- Remove the last newline
                str = str:sub(1, -2)
            end
            return str
        end,

        ["buy"] = function(uplinkItem, terminal, client, argument)
            local ownTbl = rs.Items.Uplinks[uplinkItem]
            if client ~= ownTbl[2] then return "Access denied." end
            local str = ""
            local shopItemTable = ownTbl[3][argument]
            if not shopItemTable then
                str = "That is not in the shop."
            else
                local cost = shopItemTable["cost"]
                local stock = shopItemTable["stock"] -- stock = false means infinite stock
                local dimes = uplinkItem.OwnInventory.FindAllItems()
                if stock and stock <= 0 then
                    str = "That is out of stock."
                elseif #dimes < cost then
                    str = "Not enough dimes for that."
                else
                    local success, errorMsg = shopItemTable["buy"](client, rs, uplinkItem, shopItemTable)
                    if success then
                        -- Remove dimes
                        for i = 1, cost do
                            Entity.Spawner.AddItemToRemoveQueue(dimes[i])
                        end
                        if stock then
                            shopItemTable["stock"] = shopItemTable["stock"] - 1
                            stock = stock - 1
                        else
                            stock = "Infinite"
                        end
                        str = "Bought " .. Megamod.Capitalize(argument) .. "\nRemaining stock: " .. tostring(stock)
                    else
                        str = errorMsg
                    end
                end
            end
            return str
        end,

        ["message"] = function(uplinkItem, terminal, client, argument)
            local ownTbl = rs.Items.Uplinks[uplinkItem]
            if client ~= ownTbl[2] then return "Access denied." end
            local str = ""
            if not argument or argument == "" then
                str = "Please specify a message to send."
            else
                for otherUplink, tbl in pairs(rs.Items.Uplinks) do
                    if otherUplink ~= uplinkItem then
                        Megamod.SendClientSideMsg(tbl[2], "Uplink: RECEIVED MESSAGE (from " .. ownTbl[1] ..")", Color(255, 100, 100))

                        local otherTerminal = otherUplink.GetComponentString("Terminal")
                        otherTerminal.ShowMessage = "RECEIVED MESSAGE (from " .. ownTbl[1] .. "): " .. argument
                        otherTerminal.SyncHistory()
                    end
                end
                str = "Message sent."
            end
            return str
        end,

        ["dv"] = function(uplinkItem, terminal, client, argument)
            local ownTbl = rs.Items.Uplinks[uplinkItem]
            if client ~= ownTbl[2] then return "Access denied." end
            if not client.Character then return end
            local str = ""
            if not client.Character.CurrentHull then
                return "You must be near a DV Access Point."
            end
            local closest
            local minDist = 115
            for dvo in Megamod.Map.DVOutside do
                -- Hidden = disabled
                if not dvo.HiddenInGame then
                    local distance = Vector2.Distance(client.Character.WorldPosition, dvo.WorldPosition)
                    if distance < minDist then
                        minDist = distance
                        closest = dvo
                    end
                end
            end
            for dvi in Megamod.Map.DVInside do
                -- Hidden = disabled
                if not dvi.HiddenInGame then
                    local distance = Vector2.Distance(client.Character.WorldPosition, dvi.WorldPosition)
                    if distance < minDist then
                        minDist = distance
                        closest = dvi
                    end
                end
            end
            if closest then
                local c = closest.GetComponentString('LightComponent')
                if c.IsOn then
                    return "This DV Access Point is already active."
                end
                -- This is after the IsOn check, so that being near an access point
                -- will prioritize "this is active" over "on cooldown"
                if ownTbl[5] > 0 then
                    return "DV is on cooldown for " .. tostring(ownTbl[5]) .. " seconds."
                end
                local exit
                for tbl in Megamod.Map.DVConnections do
                    if tbl.Inside == closest then
                        exit = tbl.Outside
                        break
                    elseif tbl.Outside == closest then
                        exit = tbl.Inside
                        break
                    end
                end
                if not exit then
                    Megamod.Error("No DV connection found.")
                    return "Error: This DV Access Point is not connected."
                end
                local c2 = exit.GetComponentString('LightComponent')
                -- Apparently this can happen
                if c.IsOn == nil or c2.IsOn == nil then
                    Megamod.Error("Traitor DV command did not find IsOn in a LightComponent.")
                    return "Error: Try again. (This is a Baro bug. Just \"dv\" again.)"
                end

                -- Turning on the light component activates the DV point, as a
                -- statuseffect makes it noninteractable based on IsOn

                Megamod.CreateEntityEvent(c, closest, "IsOn", not c.IsOn)
                Megamod.CreateEntityEvent(c2, exit, "IsOn", not c2.IsOn)

                ownTbl[5] = 120
                local function cooldownLoop()
                    Timer.Wait(function()
                        -- Uplink could be deleted (returned) when on cooldown
                        if not Game.RoundStarted or not uplinkItem then return end
                        ownTbl[5] = ownTbl[5] - 1
                        if ownTbl[5] <= 0 then
                            -- Notify the uplink user
                            if not Megamod.CheckIsDead(client) then
                                Megamod.SendChatMessage(client, "Uplink " .. tostring(ownTbl[1]) .. ": DV READY", Color(255, 100, 100, 255))
                            end
                            return
                        end
                        cooldownLoop()
                    end, 1000)
                end
                cooldownLoop()

                str = "DV Access Point activated. It will stay open for ~30 seconds."

                -- Deactivate after 25-35 seconds
                Timer.Wait(function()
                    if not Game.RoundStarted or not closest or not exit then return end
                    local c = closest.GetComponentString('LightComponent')
                    Megamod.CreateEntityEvent(c, closest, "IsOn", not c.IsOn)

                    local c2 = exit.GetComponentString('LightComponent')
                    Megamod.CreateEntityEvent(c2, exit, "IsOn", not c2.IsOn)
                end, math.random(25000, 35000))
            else
                str = "You must be near a DV Access Point."
            end
            return str
        end,

        ["siphon"] = function(uplinkItem, terminal, client, argument)
            local ownTbl = rs.Items.Uplinks[uplinkItem]
            if client ~= ownTbl[2] then return "Access denied." end
            for leak, dimeAmount in pairs(rs.DLeaks) do
                local distance = Vector2.Distance(client.Character.WorldPosition, leak.WorldPosition)
                -- Check both distance and current hull, for big and small hulls respectively
                if distance < 150 or client.Character.CurrentHull == leak then
                    ownTbl[6] = ownTbl[6] + dimeAmount
                    local prefab = ItemPrefab.GetItemPrefab("mm_dime")
                    for i = 1, math.floor(ownTbl[6]) do
                        ownTbl[6] = ownTbl[6] - 1
                        -- Excess will spawn on the ground
                        Entity.Spawner.AddItemToSpawnQueue(prefab, uplinkItem.OwnInventory)
                    end
                    rs.DLeaks[leak] = nil
                    rs.SendDLeakNetMessage()
                    Megamod.Log("'" .. tostring(client.Name) .. "' siphoned a dimensional leak for " .. dimeAmount .. " dimes.", true)
                    return "Dimensional leak siphoned for " .. math.floor(dimeAmount) .. " dimes."
                end
            end
            return "No dimensional leak found nearby."
        end,

        ["func"] = function(uplinkItem, terminal, client, argument)
            local ownTbl = rs.Items.Uplinks[uplinkItem]
            if client ~= ownTbl[2] then return "Access denied." end
            if argument == "" then -- Find all available funcs and list them
                local str = ""
                for k, v in pairs(ownTbl[7]) do
                    str = str .. k .. "\n"
                end
                -- Remove the last newline
                str = str:sub(1, -2)
                return str
            else -- Use a func
                if ownTbl[7][argument] then
                    return ownTbl[7][argument](uplinkItem, terminal, client, argument)
                else
                    return "No function found."
                end
            end
        end,

        ["return"] = function(uplinkItem, terminal, client, argument)
            local ownTbl = rs.Items.Uplinks[uplinkItem]
            -- Anybody can return the uplink
            --if client ~= rs.Items.Uplinks[uplinkItem][2] then return "Access denied." end
            -- Disables using any commands
            ownTbl[4] = false
            local timer = 6
            local function countDown()
                if not Game.RoundStarted then return end
                Timer.Wait(function()
                    timer = timer - 1
                    if timer <= 0 then
                        rs.IDMessageCommands[ownTbl[1]] = nil

                        -- Don't send to 'client,' as 'client' is just the one using the uplink; we want the uplink's assigned traitor
                        local traitor = ownTbl[2]
                        Megamod.SendChatMessage(traitor, "Your uplink was returned, and as such you are no longer a traitor.", Color(255, 0, 255, 255))
                        rs.SelectedPlayers[traitor] = nil -- Revoke traitor status
                        rs.TraitorAmount = rs.TraitorAmount - 1

                        -- Make sure their dime locator is turned off, if it's on
                        local msg = Networking.Start("mm_dimelocator")
                        msg.WriteBoolean(false) -- True = toggle, false = disable
                        Networking.Send(msg, traitor.Connection)

                        -- Let the traitor know they are no longer a traitor, so they can't use vanilla traitor things
                        local message = Networking.Start("mm_traitor")
                        message.WriteBoolean(false)
                        Networking.Send(message, traitor.Connection)

                        -- Complete Loan Shark (->return this traitor's uplink) objectives
                        for otherTraitor, tbl in pairs(rs.SelectedPlayers) do
                            if tbl[2][3] and tbl[2][3]["Uplink"] == uplinkItem then
                                tbl[2][3]:Complete(otherTraitor)
                            end
                        end

                        rs.Items.Uplinks[uplinkItem] = nil
                        Entity.Spawner.AddItemToRemoveQueue(uplinkItem)
                        Megamod.Log("'" .. tostring(traitor.Name) .. "' had their uplink returned.", true)
                        return
                    end
                    terminal.ShowMessage = timer
                    terminal.SyncHistory()
                    countDown()
                end, 1000)
            end
            countDown()
            return ""
        end,
    }
    -- Alternate spellings
    rs.UplinkCommands["shop"] = rs.UplinkCommands["store"]
    rs.UplinkCommands["msg"] = rs.UplinkCommands["message"]

    rs.IdMessagesFunc = function(uplinkItem, terminal, client, argument, otherUplink, tbl)
        local ownTbl = rs.Items.Uplinks[uplinkItem]
        if client ~= ownTbl[2] then return "Access denied." end
        local str = ""
        if tbl[1] == ownTbl[1] then
            str = "Cannot send message to self."
        else
            if not Megamod.CheckIsDead(tbl[2]) then
                Megamod.SendClientSideMsg(tbl[2], "Uplink: RECEIVED MESSAGE (from " .. ownTbl[1] ..")", Color(255, 100, 100))
            end
            local otherTerminal = otherUplink.GetComponentString("Terminal")
            otherTerminal.ShowMessage = "RECEIVED MESSAGE (from " .. ownTbl[1] .. "): " .. argument
            otherTerminal.SyncHistory()
            str = "Sent message."
        end
        return str
    end

    -- Each index is the Lender ID of an uplink
    rs.IDMessageCommands = {}

    -- Do not remove this hook in runtime (learned the hard way)
    Hook.Add("megamod.terminalWrite", "Megamod.RuleSets.Traitor.Uplink", function(uplinkItem, client, output)
        if not uplinkItem.HasTag("uplink") then return end
        if not client.Character then return end

        if not rs.Items.Uplinks[uplinkItem] or not rs.Items.Uplinks[uplinkItem][4] then return end

        Megamod.Log("Uplink usage by " .. client.Name .. ": " .. output, true)

        local command, argument = output:match("(%S+)%s*(.*)")
        local idCommand = command
        if command then
            command = command:lower()
        end
        if argument then
            argument = argument:lower():match("^%s*(.-)%s*$")
        end

        local terminal = uplinkItem.GetComponentString("Terminal")

        local str = ""

        if rs.UplinkCommands[command] then
            str = rs.UplinkCommands[command](uplinkItem, terminal, client, argument)
        elseif rs.IDMessageCommands[idCommand]
        and rs.IDMessageCommands[idCommand][1] -- Make sure the uplink hasn't been returned (deleted)
        then
            -- If no other command went through, try to do an ID message command
            str = rs.IdMessagesFunc(uplinkItem, terminal, client, argument, rs.IDMessageCommands[idCommand][1], rs.IDMessageCommands[idCommand][2])
        end

        if str ~= "" then
            terminal.ShowMessage = "**********"
            -- Print every line individually to avoid weird behavior when printing big strings
            for line in str:gmatch("([^\n]*)\n?") do
                terminal.ShowMessage = line
            end
            terminal.ShowMessage = "**********"
            terminal.SyncHistory()
        end
    end)
end

-- Lua functionality for traitor items
do
    --
    -- Deep Vents Access Point
    --
    Hook.Add("MM.dvpoint", "Megamod.DVPoint", function(effect, deltaTime, item, targets, worldPosition, element)
        local target = targets[1]
        if not target then return end
        local exit
        for tbl in Megamod.Map.DVConnections do
            if tbl.Inside == item then
                exit = tbl.Outside
                break
            elseif tbl.Outside == item then
                exit = tbl.Inside
                break
            end
        end
        if not exit then
            Megamod.Error("No DV connection found.")
            return
        end
        if target.SelectedCharacter then
            target.SelectedCharacter.TeleportTo(exit.WorldPosition)
        end
        target.TeleportTo(exit.WorldPosition)
    end)
    --
    --  Blood Scalpel
    --
    NT.ItemMethods["multiscalpel_blood"] = NT.ItemMethods["multiscalpel"]
    Hook.Add("MM.traitoritems.bloodscalpel", "Megamod.traitoritems.bloodscalpel", function(effect, deltaTime, item, targets, worldPosition, element)
        local itemPrefab = item.Prefab
        if itemPrefab.Identifier == "mm_bloodscalpel" then -- Revert to a multiscalpel
            local targetinventory = item.ParentInventory
            local targetslot = 0
            if targetinventory ~= nil then targetslot = targetinventory.FindIndex(item) end

            local function SpawnFunc(newscalpelitem, targetinventory)
                if targetinventory ~= nil then
                    targetinventory.TryPutItem(newscalpelitem, targetslot, true, true, nil)
                end
            end
            Entity.Spawner.AddEntityToRemoveQueue(item)
            Timer.Wait(function()
                local prefab = ItemPrefab.GetItemPrefab("multiscalpel_blood")
                Entity.Spawner.AddItemToSpawnQueue(prefab, item.WorldPosition, nil, nil, function(newscalpelitem)
                    SpawnFunc(newscalpelitem, targetinventory)
                end)
            end, 35)
        elseif itemPrefab.Identifier == "multiscalpel_blood" then -- Spawn the stabby thing
            local targetinventory = item.ParentInventory
            local targetslot = 0
            if targetinventory ~= nil then targetslot = targetinventory.FindIndex(item) end

            local function SpawnFunc(newscalpelitem, targetinventory)
                if targetinventory ~= nil then
                    targetinventory.TryPutItem(newscalpelitem, targetslot, true, true, nil)
                end
            end

            Entity.Spawner.AddEntityToRemoveQueue(item)

            Timer.Wait(function()
                local prefab = ItemPrefab.GetItemPrefab("mm_bloodscalpel")
                Entity.Spawner.AddItemToSpawnQueue(prefab, item.WorldPosition, nil, nil, function(newscalpelitem)
                    SpawnFunc(newscalpelitem, targetinventory)
                end)
            end, 35)
        end
    end)
    --
    --  Husk Egg Injector
    --
    Hook.Add("MM.traitoritems.huskegginjector", "Megamod.traitoritems.huskegginjector", function(effect, deltaTime, item, targets, worldPosition, element)
        -- Injector only has 1 slot
        local containedItem = item.OwnInventory.GetItemAt(0)
        if not containedItem then return end
        if not containedItem.UseInHealthInterface then return end
        -- Cannot be used on surgery tools
        for tag in containedItem.GetTags() do
            if tag == "surgery" then return end
        end
        rs.Items.HuskInfected[containedItem] = true
        local characterInventory = item.ParentInventory
        local prefab = ItemPrefab.GetItemPrefab("mm_huskegginjector2")
        -- Drop the item so it doesn't get deleted with the injector
        containedItem.Drop()
        Entity.Spawner.AddEntityToRemoveQueue(item)
        Timer.Wait(function()
            Entity.Spawner.AddItemToSpawnQueue(prefab, characterInventory, nil, nil, function(newItem)
                characterInventory.TryPutItem(newItem)
                newItem.OwnInventory.TryPutItem(containedItem)
            end)
        end, 35)
    end)
    Hook.Add("item.applyTreatment", "Megamod.traitoritems.huskeditems", function(item, usingCharacter, targetCharacter, limb)
        if not rs.Items.HuskInfected[item] then return end
        rs.Items.HuskInfected[item] = nil
        local prefab = AfflictionPrefab.Prefabs["huskinfection"]
        local limbType = LimbType.Torso
        local affliction = prefab.Instantiate(1)
        targetCharacter.CharacterHealth.ApplyAffliction(targetCharacter.AnimController.GetLimb(limbType), affliction,
            false, false, false)
    end)
end

-- Dimensional leaks
do
    function rs.SendDLeakNetMessage()
        local msg = Networking.Start("mm_leak")
        local amount = 0
        local leaks = {}
        for leak, _ in pairs(rs.DLeaks) do
            amount = amount + 1
            table.insert(leaks, leak)
        end
        msg.WriteUInt32(amount)
        for leak in leaks do
            msg.WriteUInt32(leak.ID)
        end
        for client in Client.ClientList do
            Networking.Send(msg, client.Connection)
        end
    end

    local MIN_HULL_SIZE = 100000
    function rs.SpawnDLeak(dimeAmount)
        Megamod.Log("Dimensional Leak (containing " .. dimeAmount .. " dimes) spawned.", true)

        local hulls = Megamod.Map.DeepVents.GetHulls(false)
        local removeHulls = {}
        -- Avoid hulls that are too small
        for k, v in pairs(hulls) do
            if v.RectWidth * v.RectHeight <= MIN_HULL_SIZE then
                table.insert(removeHulls, v)
            end
        end
        -- Don't make a leak in the same hull as another
        for leak, _ in pairs(rs.DLeaks) do
            table.insert(removeHulls, leak)
        end
        for k in removeHulls do
            for k1, v in pairs(hulls) do
                if v == k then
                    table.remove(hulls, k1)
                    break
                end
            end
        end
        local chosenHull = hulls[math.random(#hulls)]
        if not chosenHull then
            Megamod.Log("No hull for a dimensional leak to spawn in. Canceling spawn...", true)
            return
        end
        rs.DLeaks[chosenHull] = dimeAmount
        rs.SendDLeakNetMessage()
    end

    function rs.GetNewDLeakTarget()
        local base = (rs.Strength / 8 + 1) * (rs.TraitorAmount + 1)
        return math.random(math.floor(base * 3), math.ceil(base * 5))
    end

    local DIME_ACCUMULATION = 0.01
    rs.DLeakTbl = {
        0, -- Current dime count
        0 -- Target dime count, more likely to spawn when current is close to this
    }
    local netTimer = 0
    local TIMER = 15
    function rs.DLeakLoop()
        if not Game.RoundStarted or rs.TraitorAmount <= 0 then return end

        local time = 7.5

        -- We update on a timer in case clients somehow don't get the messages right when one spawns/despawns
        netTimer = netTimer + time
        if netTimer >= TIMER then
            netTimer = 0
            rs.SendDLeakNetMessage()
        end

        rs.DLeakTbl[1] = rs.DLeakTbl[1] + (DIME_ACCUMULATION * time)
        if rs.DLeakTbl[1] > rs.DLeakTbl[2] then rs.DLeakTbl[1] = rs.DLeakTbl[2] end

        local chance = math.abs((rs.DLeakTbl[1] - rs.DLeakTbl[2]) / 6.8)
        if math.random() >= chance then
            rs.SpawnDLeak(rs.DLeakTbl[1])
            rs.DLeakTbl[1] = 0
            rs.DLeakTbl[2] = rs.GetNewDLeakTarget()
        end

        Timer.Wait(function()
            rs.DLeakLoop()
        end, time * 1000)
    end
end

-- Objectives
do
    rs.SuccessMessages = {
    "GOOD JOB  NOW DO IT AGAIN WHEN I TELL YOU TO",
    "YOUR ABILITIES AMUSE ME",
    "YOUR ABILITIES SURPRISE ME",
    "GREAT  GET BACK TO WORK THAT WASN'T THE LAST ONE",
    "AWESOME  NO YOU DON'T GET A BREAK",
    "KEEP ON IT LEST ONE OF YOUR FRIENDS GETS AN IDEA",
    "THAT WAS GOOD BUT NOT ENOUGH  STAY FOCUSED",
    "SATISFACTORY  AWAIT YOUR NEXT ASSIGNMENT",
    "ALRIGHT NOW MOVE ON",
    "I WILL STILL REQUIRE MORE FROM YOU",
    }

    -- Get the timer reduction from the credit value of the objective
    local function creditTimer(creditValue)
        return (creditValue + 1) * 50
    end

    local function completeObj(self, traitor)
        Megamod.Log("Traitor " .. tostring(traitor.Name) .. " completed their '" .. self.Name .. "' objective.", true)
        rs.SelectedPlayers[traitor][2][6] = rs.SelectedPlayers[traitor][2][6] + self.Credit
        rs.SelectedPlayers[traitor][2][4] = rs.SelectedPlayers[traitor][2][4] - creditTimer(self.Credit)
        rs.SelectedPlayers[traitor][2][7] = math.random(30, 60) -- Cooldown of 30-60 seconds till you can get another objective
        rs.SelectedPlayers[traitor][2][8] = false
        rs.SelectedPlayers[traitor][2][3] = nil
        local prefab = ItemPrefab.GetItemPrefab("mm_dime")
        if not Megamod.CheckIsDead(traitor) then
            for i = 1, self.Credit do
                Entity.Spawner.AddItemToSpawnQueue(prefab, traitor.Character.Inventory, nil, nil, nil, true)
            end
        end
        return rs.SuccessMessages[math.random(#rs.SuccessMessages)] .. "\n(Objective completed. Await your next.)"
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

    -- #TODO#: Thief, Meeting
    rs.Objectives = {
        { -- Murder: Kill a crewmate who is not security or captain - must kill confirm
            Name = "Murder",
            Jobs = "all",
            Chance = 50,
            Credit = 4,
            MinStrength = 4,
            DescriptionChat = {
                "KILL \"%s\" FOR ME WOULD YOU",
                "I NEED \"%s\" OUT OF THE PICTURE",
                "DISPOSE OF \"%s\" PLEASE",
                "LET \"%s\" SLEEP WITH THE FISHES",
                "I NEED \"%s\" TO BE DONE AWAY WITH",
            },
            DescriptionReal = "(Kill %s, then use the 'obj' command in your uplink when near their corpse.)",
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
                        if not Megamod.CheckIsDead(client)
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
                    if not Megamod.CheckIsDead(client)
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
                local desc = string.format(self.DescriptionChat[math.random(#self.DescriptionChat)] .. "\n" .. self.DescriptionReal, target[2].Name, target[2].Name)
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
                return self.Name .. "\n" .. desc
            end,
            Complete = completeObj
        },
        { -- Kidnapping: Kidnap a crewmate who is not security or captain and take them to the Deep Vents
            Name = "Kidnapping",
            Jobs = "all",
            Chance = 40,
            Credit = 5,
            MinStrength = 5,
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
                        if not Megamod.CheckIsDead(client)
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
                    if not Megamod.CheckIsDead(client)
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
                local desc = string.format(self.DescriptionChat[math.random(#self.DescriptionChat)] .. "\n" .. self.DescriptionReal, target[2].Name, target[2].Name)
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
                return self.Name .. "\n" .. desc
            end,
            Complete = completeObj
        },
        { -- Regicide: Kill a captain or security - must kill confirm
            Name = "Regicide",
            Jobs = "all",
            Chance = 10,
            Credit = 7,
            MinStrength = 8,
            DescriptionChat = {
                "\"%s\" HAS BEEN IN POWER FOR TOO LONG FIX THAT",
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
                        if not Megamod.CheckIsDead(client)
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
                    if not Megamod.CheckIsDead(client)
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
                local desc = string.format(self.DescriptionChat[math.random(#self.DescriptionChat)] .. "\n" .. self.DescriptionReal, target[2].Name, target[2].Name)
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
                return self.Name .. "\n" .. desc
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
                "THE TEAM IS FALTERING \"%s\" COULD FIX THAT",
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
                        if not Megamod.CheckIsDead(client)
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
                    if not Megamod.CheckIsDead(client)
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
                local desc = string.format(self.DescriptionChat[math.random(#self.DescriptionChat)] .. "\n" .. self.DescriptionReal, target[2].Name, target[2].Name)
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
                return self.Name .. "\n" .. desc
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
                    and not Megamod.CheckIsDead(client)
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
                    and not Megamod.CheckIsDead(client)
                    and client.Character
                    and client.Character.IsHuman
                    and rs.SelectedPlayers[client][2][4] > 480
                    then
                        table.insert(potentialTargets, { client, client.Character })
                    end
                end
                local target = potentialTargets[math.random(#potentialTargets)]
                Megamod.Log("Gave objective '" .. self.Name .. "' (target: '" .. tostring(target[1].Name) .. "' as '" .. tostring(target[2].Name) .. "') to '" .. tostring(traitor.Name) .. "'")
                local desc = string.format(self.DescriptionChat[math.random(#self.DescriptionChat)] .. "\n" .. self.DescriptionReal, target[2].Name, target[2].Name)
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
                return self.Name .. "\n" .. desc
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
                    and not Megamod.CheckIsDead(client)
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
                    and not Megamod.CheckIsDead(client)
                    and client.Character
                    and client.Character.IsHuman
                    and rs.SelectedPlayers[client][2][4] > 480
                    then
                        table.insert(potentialTargets, { client, client.Character })
                    end
                end
                local target = potentialTargets[math.random(#potentialTargets)]
                Megamod.Log("Gave objective '" .. self.Name .. "' (target: '" .. tostring(target[1].Name) .. "' as '" .. tostring(target[2].Name) .. "') to '" .. tostring(traitor.Name) .. "'")
                local desc = string.format(self.DescriptionChat[math.random(#self.DescriptionChat)] .. "\n" .. self.DescriptionReal, target[2].Name, target[2].Name)
                assign(self, traitor, target, desc, function(client)
                    if not client.Character then return "" end
                    if not target[2] then
                        rs.SelectedPlayers[traitor][2][3]["NoPenalty"] = true
                        return "Target no longer exists. Canceling this will not incur a penalty."
                    end
                    return "Use the 'return' command on the target's uplink."
                end)
                return self.Name .. "\n" .. desc
            end,
            Complete = completeObj
        },
        { -- Payment: Send the Lender some amount of dimes
            Name = "Payment",
            Jobs = "all",
            Chance = 15,
            Credit = 0,
            MinStrength = 0,
            DescriptionChat = {
                "I NEED %d ESSENCE",
                "%d ESSENCE THAT'S IT",
                "I REQUIRE %d ESSENCE FROM YOU",
                "%d ESSENCE",
                "ESSENCE %d UNITS",
            },
            DescriptionReal = "(Have %d dime(s) in your hotbar, then use the 'obj' command in your uplink.)",
            Check = function(traitor) -- Always available
                return true
            end,
            Assign = function(self, traitor)
                local target = math.random(rs.Strength, math.floor(rs.Strength * 1.5))
                Megamod.Log("Gave objective '" .. self.Name .. "' (target: " .. tostring(target) .. ") to '" .. tostring(traitor.Name) .. "'")
                local desc = string.format(self.DescriptionChat[math.random(#self.DescriptionChat)] .. "\n" .. self.DescriptionReal, target, target)
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
                return self.Name .. "\n" .. desc
            end,
            Complete = completeObj
        },
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

    local function compareJobs(job, requiredJobs)
        local t = type(requiredJobs)
        if t == "string" then
            return job == requiredJobs or requiredJobs == "all"
        elseif t == "table" then
            for requiredJob in requiredJobs do
                if job == requiredJob then
                    return true
                end
            end
        end
        return false
    end

    function rs.CreateObjective(traitor)
        if rs.SelectedPlayers[traitor][2][3] then return end -- If they already have an objective
        if rs.SelectedPlayers[traitor][2][7] > 0 then
            return "I NEED NOT OF YOU RIGHT NOW"
        end
        local potentialObjectives = {}
        for objective in rs.Objectives do
            if rs.Strength >= objective.MinStrength
            and objective.Chance > 0 -- 0 chance = disabled by dev
            and compareJobs(tostring(traitor.Character.JobIdentifier), objective.Jobs)
            and objective.Check(traitor)
            then
                potentialObjectives[objective] = objective.Chance
            end
        end
        local chosenObjective = weightedRandom.Choose(potentialObjectives)
        if not chosenObjective then
            Megamod.Log("No valid traitor objectives to give to '" .. tostring(traitor.Name) .. ".'", true)
            return "(No objectives were valid to give you. If this persists, tell an admin!)"
        end
        return chosenObjective:Assign(traitor)
    end
end

-- The Lender gets angry if you don't do your objectives, and will
-- send other traitors after you
function rs.PatienceLoop()
    if not Game.RoundStarted or rs.EOTR then return end
    local time = 6
    for traitor, tbl in pairs(rs.SelectedPlayers) do
        -- Traitor must be alive and not on their objective cooldown
        if not Megamod.CheckIsDead(traitor) and tbl[2][7] <= 0 then
            tbl[2][4] = tbl[2][4] + time
            -- Notify the traitor that they can get another objective
            if not tbl[2][8] and tbl[2][2] then
                Megamod.SendChatMessage(traitor, "UPLINK " .. rs.Items.Uplinks[tbl[2][2]][1] .. ": OBJECTIVE READY", Color(255, 100, 100, 255))
                tbl[2][8] = true
            elseif not tbl[2][8] and not tbl[2][2] and not tbl[2][1] then
                -- If the traitor hasn't spawned their uplink before the initial objective cooldown, force it to spawn
                rs.SelectedPlayers[traitor][2][1] = true
                tbl[2][8] = true
                Megamod.SendChatMessage(traitor, "Your uplink was force-spawned. Don't wait too long to spawn it!", Color(255, 0, 255, 255))
                rs.SpawnUplink(traitor)
            end
        elseif tbl[2][7] > 0 then
            tbl[2][7] = tbl[2][7] - 1
            if tbl[2][7] < 0 then tbl[2][7] = 0 end
        end
    end
    Timer.Wait(function()
        rs.PatienceLoop()
    end, time * 1000)
end

-- You probably want to give them the antag overlay
function rs.SetTraitor(client, brainwashed)
    rs.TraitorAmount = rs.TraitorAmount + 1
    if brainwashed then
        table.insert(Megamod.RuleSetManager.ExtraSummary, "'" .. tostring(client.Name) .. "' was brainwashed into becoming a traitor.")
    end
    rs.SelectedPlayers[client] = {
        "Traitor",
        {
            [1] = false, -- If the traitor has spawned their uplink
            [2] = nil, -- The traitor's assigned uplink, may be nil even if [1] is true, because uplinks can be "returned" (deleted)
            [3] = nil, -- Current objective
            [4] = 0, -- Can be negative; timer (counting up) representing the Lender's dwindling patience, if too high, this traitor may be the target of another traitor
            [5] = false, -- If the traitor is in a "Meeting" objective
            [6] = 0, -- The traitor's accumulated "Credit," used for bragging rights in the end-of-round summary
            [7] = 60, -- Cooldown for objectives, [4] doesn't go up while this is >0 and you can't get another objective either; starts at 1 minute
            [8] = false, -- If the traitor has received the "you can get another objective" message
        }
    }
    for admin in Client.ClientList do
        if Megamod.Admins[admin.SteamID] then
            local msg = Networking.Start("mm_ruleset")
            msg.WriteByte(3)
            msg.WriteString(rs.Name)
            msg.WriteByte(client.SessionId)
            msg.WriteString(rs.SelectedPlayers[client][1])
            Networking.Send(msg, admin.Connection)
        end
    end
    client.Character.IsTraitor = true
    -- Let the client know they are a traitor
    local message = Networking.Start("mm_traitor")
    message.WriteBoolean(true)
    Networking.Send(message, client.Connection)
    -- Let them know they're an antag
    local msg = Networking.Start("mm_antag")
    msg.WriteBoolean(true)
    Networking.Send(msg, client.Connection)
end

function rs.EOTRLoop()
    local endRound = true
    for client in Client.ClientList do
        if #Megamod.RuleSetManager.AntagStatus(client, "Traitor") == 0
        and not Megamod.CheckIsDead(client) then
            endRound = false
            break
        end
    end
    if endRound then
        Megamod.RuleSetManager.EndRoundTimer(30, "All crewmates are dead: traitor victory.")
    else
        Timer.Wait(function()
            rs.EOTRLoop()
        end, 1000)
    end
end

-- Clients who reload lua send a sync message to see if they're a traitor
Networking.Receive("mm_traitor", function(message, client)
    -- Don't use rs.SetTraitor, as that would reset everything
    if rs.SelectedPlayers[client] then
        local msg = Networking.Start("mm_traitor")
        msg.WriteBoolean(true)
        Networking.Send(msg, client.Connection)
    end
end)



function rs.Reset()
    for traitor, _ in pairs(rs.SelectedPlayers) do
        -- If this was called on round end, wait so that we see the round ended
        Timer.Wait(function()
            if Game.RoundStarted then
                Megamod.SendMessage(traitor, "The traitors have failed. You are no longer a traitor.")
            end
        end, 1000)
        -- Make sure their dime locator is turned off, if it's on
        local msg = Networking.Start("mm_dimelocator")
        msg.WriteBoolean(false) -- True = toggle, false = disable
        Networking.Send(msg, traitor.Connection)
        if traitor.Character then
            -- Let the client know they are no longer a traitor, so they can't use vanilla traitor things
            local message = Networking.Start("mm_traitor")
            message.WriteBoolean(false)
            Networking.Send(message, traitor.Connection)
        end
    end
    rs.SelectedPlayers = {}
    rs.Strength = 0
    rs.Items = {}
    rs.Items.Uplinks = {}
    rs.Items.HuskInfected = {}
    rs.DLeaks = {}
    rs.TraitorAmount = 0
    rs.UplinkIDChars = BASE_UPLINK_ID_CHARS
    rs.IDMessageCommands = {}
    rs.DLeakTbl = { 0, 0 }
    rs.EOTR = false
end

function rs.RoleHelp(client, obj)
    if rs.SelectedPlayers[client] then
        if obj then
            local str = ""
            local s = rs.SelectedPlayers[client][2][3]
            if not s then
                str = "You have no objective. Use the 'obj' command in your uplink to get one."
            else
                str = "Objective: '" .. s["Name"] .. "'\n" .. s["Desc"]
            end
            return true, str
        else
            return true, rs.RoleMessage
        end
    end
    return false, ""
end

-- At least one player must be eligible to be a traitor, or strength >0
function rs.Check()
    if rs.Strength > 0 then return true end -- There are already traitors, so yes
    for _, client in pairs(Client.ClientList) do
        if Megamod.GetData(client, "Traitor") -- Wants to play as traitor
        and not Megamod.CheckIsDead(client) -- Not dead
        and client.Character
        and client.Character.IsHuman
        and #Megamod.RuleSetManager.AntagStatus(client) == 0 then -- Not already an antagonist
            local job = client.Character.JobIdentifier
            if job == "captain" or job == "securityofficer" then
                -- Cannot be traitors
            else
                return true
            end
        end
    end
    return false
end

-- All traitors are completely dead or had their uplinks returned
-- NOTE: Traitors who freecam are considered dead, beware admins
function rs.CheckShouldFail()
    -- If there are no traitors it will return true by default
    for traitor, _ in pairs(rs.SelectedPlayers) do
        if not Megamod.CheckIsDead(traitor) then
            return false, ""
        end
    end
    return true, "All traitors died or had their uplinks returned"
end

function rs.Draft()
    if rs.Strength == 10 then -- End of the Road, the traitors are let loose on the crewmates
        rs.EOTR = true
        rs.EOTRLoop()
        local str = "THE FINAL ACT IS UPON US. CHECK YOUR OBJECTIVE.\nTHEY WILL KNOW. ACT NOW."
        for traitor, tbl in pairs(rs.SelectedPlayers) do
            tbl[3] = nil
            for objective in rs.Objectives do
                if objective.EOTR then -- End of the Road
                    objective:Assign(traitor)
                    break
                end
            end
            Megamod.SendChatMessage(traitor, str, Color(255, 100, 100, 255))
        end
        Timer.Wait(function()
            if not Game.RoundStarted then return end
            local str = "Increasing dimensional activity detected..."
            for client in Client.ClientList do
                Megamod.SendChatMessage(client, str, Color(255, 0, 255, 255))
            end
            Timer.Wait(function()
                local prefab = ItemPrefab.GetItemPrefab("mm_notifalarm")
                Entity.Spawner.AddItemToSpawnQueue(prefab, Submarine.MainSub.WorldPosition)
                local str = "RED ALERT! TRAITORS ARE ON BOARD AND PLOTTING TO OVERTHROW THE STATION. STAND YOUR GROUND!"
                for client in Client.ClientList do
                    Megamod.SendChatMessage(client, str, Color(255, 0, 0, 255))
                end
            end, 3500)
        end, 25000)
        return true, ""
    elseif rs.Strength > 1 then
        return true, ""
    end
    -- The rest of this is initialization

    local traitorAmount = 1
    if #Client.ClientList > 18 and math.random() <= 0.25 then
        traitorAmount = 4
    elseif #Client.ClientList > 12 then
        traitorAmount = 3
    elseif #Client.ClientList > 6 then
        traitorAmount = 2
    end

    local availablePlayers = {}
    local availablePlayerTotal = 0

    for _, client in pairs(Client.ClientList) do
        if Megamod.GetData(client, "Traitor") -- Wants to play as traitor
        and not Megamod.CheckIsDead(client) -- Not dead
        and client.Character
        and client.Character.IsHuman
        and #Megamod.RuleSetManager.AntagStatus(client) == 0 then -- Not already an antagonist
            local job = client.Character.JobIdentifier
            if job == "captain" or job == "securityofficer" then
                -- Cannot be traitors
            elseif job == "medicaldoctor" or job == "surgeon" then
                -- 50% relative chance
                availablePlayers[client] = 0.5
                availablePlayerTotal = availablePlayerTotal + 1
            elseif job == "mechanic" or job == "engineer" then
                -- 100% relative chance
                availablePlayers[client] = 1
                availablePlayerTotal = availablePlayerTotal + 1
            elseif job == "assistant" then
                -- 125% relative chance
                availablePlayers[client] = 1.25
                availablePlayerTotal = availablePlayerTotal + 1
            end
        end
    end

    if availablePlayerTotal == 0 then
        return false, "Not enough players are eligible to be traitors."
    end

    if availablePlayerTotal < traitorAmount then
        Megamod.Log("Not enough players are eligible to be traitors, total number of traitors reduced from "
        .. traitorAmount .. " to " .. availablePlayerTotal .. ".", true)
        traitorAmount = availablePlayerTotal
    end

    rs.TraitorAmount = traitorAmount

    for i = 1, traitorAmount do
        local newTraitor = weightedRandom.Choose(availablePlayers)
        Megamod.GiveAntagOverlay(newTraitor.Character)
        rs.SetTraitor(newTraitor)
        availablePlayers[newTraitor] = nil
    end

    local str = ""
    for traitor, _ in pairs(rs.SelectedPlayers) do
        str = str .. tostring(traitor.Name) .. ", "
    end
    -- Remove the last two characters (", ")
    str = str:sub(1, -3)
    Megamod.Log("Traitors selected: " .. str, true)

    rs.DLeakTbl[2] = rs.GetNewDLeakTarget()
    rs.PatienceLoop()
    rs.DLeakLoop()

    -- Spawn a leak as we're drafted, so traitors have some initial dimes
    rs.SpawnDLeak(rs.DLeakTbl[2] / 2)

    -- Success
    return true, ""
end

return rs
