local rs = {}

rs.Name = "Traitor"

rs.Chance = 75

rs.Enabled = true

rs.SelectedPlayers = {}

rs.Strength = 0

rs.AntagName = "Traitor"

rs.FailReason = ""



local weightedRandom = require 'utils.weightedrandom'
local shared = require 'shared.traitorshared'
local SHOP_BASE = shared.shop

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
">> There are 'dimes' in your uplink. You use them to buy stuff. There are two ways to get more dimes - complete objectives, or siphon leaks in the Deep Vents.\n" ..
">> Your goal is to fulfill the Lender's requests, in the form of objectives.\n" ..
">> Objectives are given to you through your uplink; use the command 'obj' in it to receive your next or advance the current one.\n" ..
">> Type \"!role obj\" (in chat, not your uplink) to view your current objective, if you have accepted one.\n" ..
">> DO NOT IGNORE OBJECTIVES. You took an offer, and it can be taken back."

-- Uplinks
do
    local BASE_DIME_AMOUNT = 10

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
                [5] = 0, -- 'DV' command cooldown, 20 seconds
                [6] = 0, -- Internal dime count, used for siphoning
                [7] = {}, -- Upgrades that this uplink has
            }

            rs.IDMessageCommands[id] = { item, rs.Items.Uplinks[item] }

            -- Wait for the item to be properly initialized
            -- Then send a net message telling the traitor that this is their uplink
            Timer.Wait(function()
                local message = Networking.Start("mm_uplink")
                message.WriteUInt64(tonumber(item.ID))
                Networking.Send(message, traitor.Connection)
            end, 1000)
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

                ownTbl[5] = 20
                local function cooldownLoop()
                    Timer.Wait(function()
                        -- Uplink could be deleted (returned) when on cooldown
                        if not Game.RoundStarted or not uplinkItem then return end
                        ownTbl[5] = ownTbl[5] - 1
                        if ownTbl[5] <= 0 then
                            -- Notify the uplink user
                            if Megamod.CheckIsDead(client) == false then
                                Megamod.SendChatMessage(client, "UPLINK: DV READY", Color(255, 100, 100, 255))
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
            if Megamod.CheckIsDead(tbl[2]) == false then
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
    -- #TODO# Re-add
    --[[NT.ItemMethods["multiscalpel_blood"] = NT.ItemMethods["multiscalpel"]
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
    end)]]
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
        Megamod.AddAffliction(targetCharacter, "huskinfection", 1)
    end)
    --
    -- Dart Gun
    --
    --[[actionTypes = LuaUserData.CreateEnumTable("Barotrauma.ActionType")
    Hook.Add("MM.traitoritems.dartsynth", "Megamod.traitoritems.dartsynth", function(effect, deltaTime, item, targets, worldPosition, element)
        local containedSyringe = item.OwnInventory.GetItemAt(0)
        if not containedSyringe then return end
        
        Entity.Spawner.AddEntityToRemoveQueue(containedSyringe)
        Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab("mm_dart"), item.OwnInventory, nil, nil, function(dart)
            print(tostring(dart))
        end)
    end)
    Hook.Add("MM.traitoritems.darthit", "Megamod.traitoritems.darthit", function(effect, deltaTime, item, targets, worldPosition, element)
       print(tostring(item))
    end)]]
end

-- Dimensional leaks
--[[do
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
        Megamod.Log("Dimensional Leak (containing " .. Megamod.Round(dimeAmount, 2) .. " dimes) spawned.", true)

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
end]]

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

    rs.Objectives = shared.obj

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
        -- Second value returns more than one value, so put it at the end
        return chosenObjective, chosenObjective:Assign(traitor)
    end
end

-- The Lender gets angry if you don't do your objectives, and will
-- send other traitors after you
function rs.PatienceLoop()
    if not Game.RoundStarted or rs.EOTR then return end
    local time = 6
    for traitor, tbl in pairs(rs.SelectedPlayers) do
        -- Traitor must be alive and not on their objective cooldown
        if Megamod.CheckIsDead(traitor) == false and tbl[2][7] <= 0 then
            tbl[2][4] = tbl[2][4] + time
            -- Notify the traitor that they can get another objective
            if not tbl[2][8] and tbl[2][2] then
                Megamod.SendChatMessage(traitor, "UPLINK: OBJECTIVE READY", Color(255, 100, 100, 255))
                tbl[2][8] = true
            elseif not tbl[2][8] and not tbl[2][2] and not tbl[2][1] then
                -- If the traitor hasn't spawned their uplink before the initial objective cooldown, force it to spawn
                rs.SelectedPlayers[traitor][2][1] = true
                tbl[2][8] = true
                Megamod.SendChatMessage(traitor, "Your uplink was force-spawned. Don't wait too long to spawn it!", Color(255, 0, 255, 255))
                rs.SpawnUplink(traitor)
            end
        elseif tbl[2][7] > 0 then
            tbl[2][7] = tbl[2][7] - time
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
        and Megamod.CheckIsDead(client) == false then
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

-- Clients who reload Lua send a sync message to see if they're a traitor
Networking.Receive("mm_traitor", function(message, client)
    -- Don't use rs.SetTraitor, as that would reset everything
    if rs.SelectedPlayers[client] then
        local msg = Networking.Start("mm_traitor")
        msg.WriteBoolean(true)
        Networking.Send(msg, client.Connection)
    end
end)

-- Clients who reload Lua send a sync message to get info about their uplink
Networking.Receive("mm_uplinksync", function(message, client)
    if rs.SelectedPlayers[client] then
        local correctUplink
        for uplinkItem, uplinkTbl in pairs(rs.Items.Uplinks) do
            if uplinkTbl[2] == client then
                correctUplink = uplinkItem
                break
            end
        end
        -- Might happen if it gets returned right as this is called?
        if not correctUplink then
            Megamod.Error("Could not find a traitor's uplink.")
            return
        end
        local msg = Networking.Start("mm_uplink")
        msg.WriteUInt64(tonumber(correctUplink.ID))
        Networking.Send(msg, client.Connection)

        -- Sync the stock of items in their uplink
        for itemName, itemTbl in pairs(rs.Items.Uplinks[correctUplink][3]) do
            local msg = Networking.Start("mm_traitorstock")
            msg.WriteString(tostring(itemName))
            msg.WriteUInt16(tonumber(itemTbl.stock))
            Networking.Send(msg, client.Connection)
        end
    end
end)

-- Traitor bought something in their uplink
Networking.Receive("mm_traitorbuy", function(message, client)
    if not rs.SelectedPlayers[client] then return end -- Completely ignore non-traitors
    local uplink
    for potentialUplink, uplinkTbl in pairs(rs.Items.Uplinks) do
        if uplinkTbl[2] == client and uplinkTbl[4] == true then
            uplink = potentialUplink
            break
        end
    end
    if not uplink then
        Megamod.Error("Could not find uplink item for client '" .. tostring(client.Name) .. "'")
        return
    end
    local boughtItemName = message.ReadString()
    if not boughtItemName then return end
    local uplinkShop = rs.Items.Uplinks[uplink][3]
    local boughtItemTbl = uplinkShop[boughtItemName]
    if boughtItemTbl.stock <= 0 then
        Megamod.Log("Client '" .. tostring(client.Name) .. "' tried to buy an out-of-stock item in their uplink.")
        return
    end
    local dimes = {}
    for item in uplink.OwnInventory.FindAllItems() do
        if tostring(item.Prefab.Identifier) == "mm_dime" then
            table.insert(dimes, item)
        end
    end
    if boughtItemTbl.cost <= #dimes then
        -- Success, buy the item
        boughtItemTbl.stock = boughtItemTbl.stock - 1
        local msg = Networking.Start("mm_traitorstock")
        msg.WriteString(tostring(boughtItemName))
        msg.WriteUInt16(tonumber(boughtItemTbl.stock))
        Networking.Send(msg, client.Connection)
        boughtItemTbl.buy(client, rs, uplink, boughtItemTbl)
        for i = 1, boughtItemTbl.cost do
            Entity.Spawner.AddItemToRemoveQueue(dimes[1])
            table.remove(dimes, 1)
        end
    else
        Megamod.Log("Client '" .. tostring(client.Name) .. "' tried to buy an item in their uplink, but did not have enough dimes.")
        return
    end
end)

-- Give traitors new objectives
Networking.Receive("mm_traitornewobj", function(message, client)
    if not rs.SelectedPlayers[client] or rs.EOTR then return end
    local uplink
    for potentialUplink, uplinkTbl in pairs(rs.Items.Uplinks) do
        if uplinkTbl[2] == client and uplinkTbl[4] == true then
            uplink = potentialUplink
            break
        end
    end
    if not uplink then
        Megamod.Error("Could not find uplink item for client '" .. tostring(client.Name) .. "'")
        return
    end
    local chosenObj, str, target, chosenChat = rs.CreateObjective(client)
    if chosenObj == "I NEED NOT OF YOU RIGHT NOW" then
        -- Tell the traitor that they cannot get an objective right now
        local msg = Networking.Start("mm_traitornewobj")
        msg.WriteByte(2)
        Networking.Send(msg, client.Connection)
        return
    end
    local id
    for key, obj in pairs(rs.Objectives) do
        if obj.Name == chosenObj.Name then
            id = key
            break
        end
    end
    if not id then
        Megamod.Error("Could not find an objective to give to '" .. tostring(client.Name) .. "'")
        return
    end
    local msg = Networking.Start("mm_traitornewobj")
    msg.WriteByte(1) -- Tells the client that this is a real objective and not a "I NEED NOT OF YOU"
    msg.WriteByte(id) -- Key position of the objective in the objectives table
    msg.WriteString(target[1].Name) -- Name of the target client
    msg.WriteByte(chosenChat) -- The Lender smalltalk that was chosen
    Networking.Send(msg, client.Connection)
end)

-- Let traitors abandon their current objective
Networking.Receive("mm_traitorabandonobj", function(message, client)
    if not rs.SelectedPlayers[client] or rs.EOTR then return end
    local objective = rs.SelectedPlayers[client][2][3]
    if not objective then return end
    local id = 1
    if objective["NoPenalty"] then
        id = 2
    else
        rs.SelectedPlayers[client][2][4] = rs.SelectedPlayers[client][2][4] + 180
    end
    rs.SelectedPlayers[client][2][3] = nil
    local msg = Networking.Start("mm_traitorabandonobj")
    msg.WriteByte(id) -- 1 means there was a penalty, 2 means no penalty
    Networking.Send(msg, client.Connection)
end)

-- Let traitors complete their objectives
Networking.Receive("mm_traitorcompleteobj", function(message, client)
    if not rs.SelectedPlayers[client] or rs.EOTR then return end
    local objective = rs.SelectedPlayers[client][2][3]
    if not objective then return end
    local str, bool = objective["Obj"](client)
    local msg = Networking.Start("mm_traitorcompleteobj")
    msg.WriteString(str)
    msg.WriteBoolean(bool)
    Networking.Send(msg, client.Connection)
end)

-- Let traitors communicate
Networking.Receive("mm_traitormsg", function(message, client)
    if not rs.SelectedPlayers[client] then return end
    local str = tostring(message.ReadString())
    local uplink
    for potentialUplink, uplinkTbl in pairs(rs.Items.Uplinks) do
        if uplinkTbl[2] == client and uplinkTbl[4] == true then
            uplink = potentialUplink
            break
        end
    end
    if not uplink then
        Megamod.Error("Could not find uplink item for client '" .. tostring(client.Name) .. "'")
        return
    end
    local clientsToMsg = {}
    for potentialClient, _ in pairs(rs.SelectedPlayers) do
        if potentialClient ~= client then
            table.insert(clientsToMsg, potentialClient)
        end
    end
    local id = tostring(rs.Items.Uplinks[uplink][1])
    local msg = Networking.Start("mm_traitormsg")
    msg.WriteString(str) -- The message content
    msg.WriteString(id) -- The sending traitor's uplink ID
    for clientToMsg in clientsToMsg do
        Megamod.SendChatMessage(clientToMsg, "UPLINK: RECEIVED MESSAGE (FROM " .. id .. ")", Color(255, 100, 100, 255))
        Networking.Send(msg, clientToMsg.Connection)
    end
end)

local function activateDV(uplinkItem, client)
    local ownTbl = rs.Items.Uplinks[uplinkItem]
    if not client.Character then return end
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

        ownTbl[5] = 20
        local function cooldownLoop()
            Timer.Wait(function()
                -- Uplink could be deleted (returned) when on cooldown
                if not Game.RoundStarted or not uplinkItem then return end
                ownTbl[5] = ownTbl[5] - 1
                if ownTbl[5] <= 0 then
                    -- Notify the uplink user
                    if Megamod.CheckIsDead(client) == false then
                        Megamod.SendChatMessage(client, "UPLINK: DV READY", Color(255, 100, 100, 255))
                    end
                    return
                end
                cooldownLoop()
            end, 1000)
        end
        cooldownLoop()

        -- Deactivate after 25-35 seconds
        Timer.Wait(function()
            if not Game.RoundStarted or not closest or not exit then return end
            local c = closest.GetComponentString('LightComponent')
            Megamod.CreateEntityEvent(c, closest, "IsOn", not c.IsOn)

            local c2 = exit.GetComponentString('LightComponent')
            Megamod.CreateEntityEvent(c2, exit, "IsOn", not c2.IsOn)
        end, math.random(25000, 35000))
        return "DV Access Point activated. It will stay open for ~30 seconds."
    else
        return "You must be near a DV Access Point."
    end
end

-- Let traitors activate DV points
Networking.Receive("mm_traitordv", function(message, client)
    if not rs.SelectedPlayers[client] then return end
    local uplinkItem
    for potentialUplink, uplinkTbl in pairs(rs.Items.Uplinks) do
        if uplinkTbl[2] == client and uplinkTbl[4] == true then
            uplinkItem = potentialUplink
            break
        end
    end
    if not uplinkItem then
        Megamod.Error("Could not find uplink item for client '" .. tostring(client.Name) .. "'")
        return
    end
    local str = activateDV(uplinkItem, client)
    local msg = Networking.Start("mm_traitordv")
    msg.WriteString(str)
    Networking.Send(msg, client.Connection)
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
        and Megamod.CheckIsDead(client) == false -- Not dead
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
        if Megamod.CheckIsDead(traitor) == false then
            return false, ""
        end
    end
    return true, "All traitors died or had their uplinks returned"
end

function rs.Draft()
    if rs.Strength == 10 then -- End of the Road, the traitors are let loose on the crewmates
        rs.EOTR = true
        rs.EOTRLoop()
        local str = "THE FINAL ACT IS UPON US. CHECK YOUR OBJECTIVE."
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
        and Megamod.CheckIsDead(client) == false -- Not dead
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

    --rs.DLeakTbl[2] = rs.GetNewDLeakTarget()
    rs.PatienceLoop()
    --rs.DLeakLoop()

    -- Spawn a leak as we're drafted, so traitors have some initial dimes
    --rs.SpawnDLeak(rs.DLeakTbl[2] / 2)

    -- Success
    return true, ""
end

return rs
