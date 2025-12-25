local esc = {}

-- Escaping via the escape portal saves everything you
-- have in your inventory, so you can use it in the next round
esc.SavedLoot = {}

local TIMER_START = 15
local timers = {}
local antagMessages = {}
-- Reset timers between rounds
Hook.Add("roundEnd", "Megamod.EscapePortal.RoundEnd", function()
    timers = {}
    antagMessages = {}
end)

Hook.Add("megamod.escapeportal", "Megamod.EscapePortal.Portal", function(effect, deltaTime, item, targets, worldPosition)
    for target in targets do
        if target and target.IsHuman and not target.IsDead then
            local client = Util.FindClientCharacter(target)
            if not client then return end
            -- Antags can't use the escape portal
            if #Megamod.RuleSetManager.AntagStatus(client) > 0 then
                if not antagMessages[client] then
                    antagMessages[client] = true
                    Megamod.SendChatMessage(client, "Antagonists (you) cannot use the escape portal.", Color(255, 0, 255, 255))
                end
                return
            end

            if not timers[target] then
                timers[target] = TIMER_START
                return
            else
                -- Ragdolls tend to bounce around, so the max speed for them is higher
                local speedLimit = 0.1
                if target.Vitality < 5 or target.IsRagdolled then
                    speedLimit = 1
                end
                -- Don't tick the timer if the target is still moving
                if timers[target] >= 0 and target.CurrentSpeed < speedLimit then
                    timers[target] = timers[target] - 1
                    return
                elseif timers[target] <= 0 then
                    timers[target] = nil
                    -- Don't return
                else
                    timers[target] = TIMER_START
                    return
                end
            end

            -- // "Escaping" // 

            target.GodMode = true

            if Megamod.RuleSetManager.RoundType == 1 then
                local tbl, tbl2 = {}, {}
                tbl.ClientID = client.SteamID
                tbl.Role = tostring(client.Character.JobIdentifier)
                tbl.Items = {}
                local function addItem(lootItem, isInHiddenInventory, parentItem)
                    -- Don't include hidden items in hidden inventories (i.e. bullets in a magazine)
                    if isInHiddenInventory and lootItem.Prefab.HideInMenus then return end

                    local itemTbl = {}
                    -- Still search the inventory if its an invalid item, but don't save the item itself
                    if esc.DetermineValidLootItem(lootItem) then
                        itemTbl.Condition = lootItem.Condition
                        itemTbl.ID = lootItem.Prefab.Identifier
                        if lootItem.OwnInventory then
                            itemTbl.Inventory = {}
                        end
                        tbl2[lootItem] = itemTbl -- Used for inventory saving
                        if parentItem then
                            local parentTbl = tbl2[parentItem]
                            if parentTbl then
                                table.insert(parentTbl.Inventory, itemTbl)
                            else -- No parent table = parent item was blacklisted, so spawn it by itself
                                table.insert(tbl.Items, itemTbl)
                            end
                        else
                            table.insert(tbl.Items, itemTbl)
                        end
                    end

                    if lootItem.OwnInventory then
                        local containerComponent = lootItem.GetComponentString('ItemContainer')
                        for childLootItem in lootItem.OwnInventory.FindAllItems() do
                            addItem(childLootItem, containerComponent.hideItems, lootItem)
                        end
                    end
                end
                for lootItem in client.Character.Inventory.FindAllItems() do
                    addItem(lootItem, false)
                end
                table.insert(esc.SavedLoot, tbl)
            end

            table.insert(Megamod.RuleSetManager.ExtraSummary, tostring(client.Name) .. " - Escaped")
            Megamod.SendChatMessage(client, "You escaped! Use the chat command '!loot' to view what items you can bring with you into the next round.", Color(255, 0, 255, 255))
            client.SetClientCharacter(nil)

            -- "Escape"
            target.TeleportTo(Vector2(0, -1000000))
        end
    end
end)

function esc.GiveLootMessage(client, delete)
    for k, lootTbl in pairs(esc.SavedLoot) do
        do
            if client.SteamID ~= lootTbl.ClientID then goto continue end

            if delete then
                table.remove(esc.SavedLoot, k)
                Megamod.SendChatMessage(client, "Deleted saved gear.", Color(255, 0, 255, 255))
                return
            end

            local str = "You have saved gear! If you don't spawn as a valid role next round, it will be lost. You may also use '!loot delete' to manually delete it.\n\n" ..
            "Valid roles:\n"
            local roles = {
                "captain",
                "securityofficer",
                "surgeon",
                "medicaldoctor",
                "engineer",
                "mechanic",
                "assistant",
            }
            local lines = {}
            local validRoles = esc.DetermineValidRoles(lootTbl.Role)
            for role in roles do
                local isValid = false
                for validRole in validRoles do
                    if role == validRole then
                        isValid = true
                        break
                    end
                end
                if isValid then
                    local roleName = tostring(JobPrefab.Get(role).Name)
                    table.insert(lines, ">" .. roleName)
                end
            end
            for line in lines do
                str = str .. line .. "\n"
            end

            str = str .. "\nItems (some may be in nested inventories):\n"
            local dupes = {}
            local function inventorySearch(itemTbl)
                for childItemTbl in itemTbl.Inventory do
                    local prefab = ItemPrefab.GetItemPrefab(childItemTbl.ID)
                    local key = tostring(prefab.Name) .. " (" .. tostring(childItemTbl.Condition) .. "%)"
                    dupes[key] = (dupes[key] or 0) + 1
                    if childItemTbl.Inventory and #childItemTbl.Inventory > 0 then
                        inventorySearch(childItemTbl)
                    end
                end
            end
            for itemTbl in lootTbl.Items do
                local prefab = ItemPrefab.GetItemPrefab(itemTbl.ID)
                local key = tostring(prefab.Name) .. " (" .. tostring(itemTbl.Condition) .. "%)"
                dupes[key] = (dupes[key] or 0) + 1
                if itemTbl.Inventory and #itemTbl.Inventory > 0 then
                    inventorySearch(itemTbl)
                end
            end
            for key, count in pairs(dupes) do
                if key:sub(-6) == "(100%)" then
                    key = key:sub(1, -8)
                end
                str = str .. "x" .. count .. " " .. key .. "\n"
            end
            Megamod.SendMessage(client, str)
            return
        end

        ::continue::
    end
    Megamod.SendChatMessage(client, "No saved gear.", Color(255, 0, 255, 255))
end

-- Give players their hard-earned loot
Hook.Add("roundStart", "Megamod.EscapePortal.RoundStart", function()
    Timer.Wait(function()
        -- Don't do anything if it's a silly round, keep loot until a serious round
        if Megamod.RuleSetManager.RoundType ~= 1 then return end
        for k, lootTbl in pairs(esc.SavedLoot) do
            do
                local lootClient
                for client in Client.ClientList do
                    if client.SteamID == lootTbl.ClientID then
                        lootClient = client
                        break
                    end
                end
                if not lootClient or Megamod.CheckIsDead(lootClient) then
                    if lootClient then
                        Megamod.SendChatMessage(lootClient, "You did not spawn in this round. Your items from escaping have been deleted.", Color(255, 0, 255, 255))
                    end
                    goto continue
                end

                local lootClientRole = tostring(lootClient.Character.JobIdentifier)
                local validRoles = esc.DetermineValidRoles(lootTbl.Role)
                local isValidRole = false
                for validRole in validRoles do
                    if lootClientRole == validRole then
                        isValidRole = true
                    end
                end
                if not isValidRole then
                    Megamod.SendChatMessage(lootClient, "You did not spawn as a valid role. Your items from escaping have been deleted.", Color(255, 0, 255, 255))
                    goto continue
                end

                local prefab = ItemPrefab.GetItemPrefab("duffelbag")
                -- Give the loot in a duffel bag (will still spawn if inventory is full)
                Entity.Spawner.AddItemToSpawnQueue(prefab, lootClient.Character.Inventory, nil, nil, function(duffel)
                    local function spawn(itemTbl, parent)
                        local prefab = ItemPrefab.GetItemPrefab(itemTbl.ID)
                        Entity.Spawner.AddItemToSpawnQueue(prefab, parent.OwnInventory, nil, nil, function(spawnedItem)
                            if itemTbl.Inventory then
                                for childItemTbl in itemTbl.Inventory do
                                    spawn(childItemTbl, spawnedItem)
                                end
                            end
                        end)
                    end
                    for itemTbl in lootTbl.Items do spawn(itemTbl, duffel) end
                end, true)
                Megamod.SendChatMessage(lootClient, "You have been given your items from escaping.", Color(255, 0, 255, 255))
            end

            ::continue::
        end
        esc.SavedLoot = {}
    end, 10000)
end)

function esc.DetermineValidRoles(roleID)
    local validRoles = {
        ["assistant"] = {
            "assistant",
            "engineer",
            "mechanic",
            "medicaldoctor",
            "surgeon",
            "securityofficer",
            "captain",
        },

        ["engineer"] = {
            "engineer",
            "mechanic",
        },
        ["mechanic"] = {
            "engineer",
            "mechanic",
        },

        ["medicaldoctor"] = {
            "medicaldoctor",
            "surgeon",
        },
        ["surgeon"] = {
            "medicaldoctor",
            "surgeon",
        },

        ["securityofficer"] = {
            "securityofficer",
            "captain",
        },
        ["captain"] = {
            "securityofficer",
            "captain",
        },
    }
    return validRoles[roleID]
end

-- Spawn an escape portal in a random hull
function esc.SpawnPortal()
    local portalHull
    local hulls = Submarine.MainSub.GetHulls(true)
    local removeHulls = {}
    -- Avoid hulls that are too small
    for k, v in pairs(hulls) do
        if v.RectWidth * v.RectHeight < 100000 then
            table.insert(removeHulls, v)
        end
    end
    for k in removeHulls do
        for k1, v in pairs(hulls) do
            if v == k then
                table.remove(hulls, k1)
                break
            end
        end
    end
    portalHull = hulls[math.random(#hulls)]
    -- Get a random X value in the middle-ish of the room
    local max = portalHull.RectWidth / 3
    local rand = math.random(-max, max)
    local x = portalHull.WorldPosition.X + rand
    -- Get a Y value slightly above the bottom of the hull,
    -- to ensure we always spawn the portal in reach of players
    local y = portalHull.WorldPosition.Y - (portalHull.RectHeight / 2) + 115
    local prefab = ItemPrefab.GetItemPrefab("mm_escapeportal")
    Entity.Spawner.AddItemToSpawnQueue(prefab, Vector2(x, y))
end

local blackListedItems = {
    -- Beast items
    "mm_container",
    "mm_grabberammo",
    "mm_grabber",

    -- Traitor items
    "mm_uplink",
    "mm_dime",
    "multiscalpel_blood",
    "mm_bloodscalpel",
    "flashlightsyringe",
    "mm_huskegginjector",
    "mm_huskegginjector2",
    "mm_stunprod",
    "radiojammer",
    "stasky",
    "plasticbag",
    "shahidka",
    "shahidkatimer",
    "molotovcoctail",
    "blindfold",
    "muzzle",
    "emag",
    "reversebeartrap",
    "alcd",
    "scp_shiv",
    "scp_crowbar",
    "scp_batoncontra",
    "scp_contrawelder",
    "sgt_fraggrenadebouquet",

    -- Misc. items
    "idcard",
    "headset",
    "braintransplant",
}

-- True = item can be saved, false = item should not be saved
function esc.DetermineValidLootItem(item)
    local id = tostring(item.Prefab.Identifier)
    for badID in blackListedItems do
        if id == badID then
            return false
        end
    end
    return true
end

return esc
