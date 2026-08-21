-- Traitor UI elements

local shared = require 'shared.traitorshared'
local objectives = shared.obj
local STARTING_DIMES = 10
local ownUplink

local function grayOutShopEntry(shopEntry, bool)
    shopEntry.grayedOut = bool
    local imageColor = bool and Color.Gray or Color.White
    local textColor = bool and Color.Gray or Color(228, 217, 167, 255)
    local buyButtonTextColor = bool and Color.Gray or Color(171, 192, 161, 255)
    shopEntry.image.Color = imageColor
    shopEntry.itemName.TextColor = textColor
    shopEntry.price.TextColor = textColor
    shopEntry.stock.TextColor = textColor
    shopEntry.buyButton.Color = imageColor
    shopEntry.buyButton.TextColor = buyButtonTextColor
    -- Make the buy button unusable if it's grayed out
    shopEntry.buyButton.CanBeSelected = not bool
end

local uplinks = {}
local function recalcGrayedEntries(uplinkItem)
    -- Uplink not specified -> recalc all
    if not uplinkItem then
        for uplinkItem, _ in pairs(uplinks) do
            recalcGrayedEntries(uplinkItem)
        end
        return
    end
    local uplinkTbl = uplinks[uplinkItem]
    local amountDimes = 0
    for item in uplinkItem.OwnInventory.FindAllItems() do
        if tostring(item.Prefab.Identifier) == "mm_dime" then
            amountDimes = amountDimes + 1
        end
    end
    if tonumber(amountDimes) ~= tonumber(uplinkTbl.lastDimeAmount) then
        uplinkTbl.dimeText.Text = tostring(amountDimes)
        uplinkTbl.lastDimeAmount = amountDimes
        for _, shopEntry in pairs(uplinkTbl.shopEntries) do
            local price = shopEntry.priceNum
            local stock = shopEntry.stockNum
            if shopEntry.grayedOut == false and (price > amountDimes or stock <= 0) then
                -- Gray out shop items that...
                --  we cannot afford
                --  or are out of stock
                grayOutShopEntry(shopEntry, true)
            elseif shopEntry.grayedOut == true and price <= amountDimes and stock > 0 then
                -- Recolor shop items that are buyable
                grayOutShopEntry(shopEntry, false)
            end
        end
    end
end

-- Add a message to the message box
local function addUplinkMessage(str, id, fromSelf)
    local messagesBoard = uplinks[ownUplink].messagesBoard
    if fromSelf then id = "YOU" end
    if messagesBoard.messageList.Content.CountChildren > 60 then
        local children = {}
        -- Convert moonsharp garbage into an actual Lua table
        for child in messagesBoard.messageList.Content.GetAllChildren() do
            table.insert(children, child)
        end
        while messagesBoard.messageList.Content.CountChildren > 60 do
            messagesBoard.messageList.RemoveChild(children[1])
            table.remove(children, 1)
        end
    end
    local newBlock = GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), messagesBoard.messageList.Content.RectTransform),
        id .. ": " .. str, nil, GUI.Style.MonospacedFont, GUI.Alignment.Left)
    newBlock.TextColor = Color(50, 205, 50, 255)
    newBlock.CanBeFocused = false
end

-- Tells us what uplink is ours
Networking.Receive("mm_uplink", function(message)
    if not Character.Controlled or not Character.Controlled.IsHuman then return end
    local uplinkID = tonumber(message.ReadUInt64())
    for item in Item.ItemList do
        if tonumber(item.ID) == uplinkID then
            ownUplink = item
            break
        end
    end
    if not ownUplink then
        error("Could not find own uplink.")
        return
    end
end)

-- Syncs the stock of an item in the uplink shop
Networking.Receive("mm_traitorstock", function(message)
    local itemName = tostring(message.ReadString())
    local newStock = tonumber(message.ReadUInt16())
    local shopEntryTbl = uplinks[ownUplink].shopEntries[itemName]
    shopEntryTbl.stockNum = newStock
    shopEntryTbl.stock.Text = tostring(newStock)
    if shopEntryTbl.grayedOut == false and newStock <= 0 then
        grayOutShopEntry(shopEntryTbl, true)
    end
end)

-- Tells us what objective we got
Networking.Receive("mm_traitornewobj", function(message)
    if not Character.Controlled or not Character.Controlled.IsHuman then return end
    local successful = tonumber(message.ReadByte())
    local objectivesMenu = uplinks[ownUplink].objectivesMenu
    if successful == 1 then -- We successfully got an objective
        local key = tonumber(message.ReadByte())
        local target = tostring(message.ReadString())
        local chatID = tonumber(message.ReadByte())

        local objTbl = objectives[key]
        if not objTbl then
            error("Could not find the objective with key " .. tostring(key))
            return
        end
        local desc = string.format(objTbl.Name .. "\n" .. objTbl.DescriptionChat[chatID] .. "\n" .. objTbl.DescriptionReal, target, target)
        objectivesMenu.text.Text = desc
        objectivesMenu.currentObj = objTbl
    elseif successful == 2 then -- We didn't get an objective
        uplinks[ownUplink].objectivesMenu.text.Text = "I NEED NOT OF YOU RIGHT NOW"
    end
end)

-- Abandon our current objective
Networking.Receive("mm_traitorabandonobj", function(message)
    if not Character.Controlled or not Character.Controlled.IsHuman then return end
    local id = tonumber(message.ReadByte())
    local objectivesMenu = uplinks[ownUplink].objectivesMenu
    if id == 1 then
        objectivesMenu.text.Text = "Canceled objective. Complete your next objective in a timely manner."
    elseif id == 2 then
        objectivesMenu.text.Text = "Canceled objective. No penalty incurred."
    end
    objectivesMenu.currentObj = nil
end)

local timesClicked = 0
-- Complete our current objective
Networking.Receive("mm_traitorcompleteobj", function(message)
    if not Character.Controlled or not Character.Controlled.IsHuman then return end
    local objectivesMenu = uplinks[ownUplink].objectivesMenu
    local str = tostring(message.ReadString())
    local bool = message.ReadBoolean()
    if bool then
        objectivesMenu.currentObj = nil
        objectivesMenu.text.Text = "No objective at the moment."
    end
    -- Change a second text box to avoid overriding the objective instructions
    objectivesMenu.text2.Text = str
    objectivesMenu.text2.Visible = true
    timesClicked = timesClicked + 1
    Timer.Wait(function()
        timesClicked = timesClicked - 1
        if timesClicked <= 0 then
            objectivesMenu.text2.Visible = false
        end
    end, 10000)
end)

-- Receive messages from other traitors
Networking.Receive("mm_traitormsg", function(message)
    local str = tostring(message.ReadString())
    local id = tostring(message.ReadString())
    addUplinkMessage(str, id, false)
end)

local timesClicked = 0
-- Receive messages about using the DV command
Networking.Receive("mm_traitordv", function(message)
    local str = tostring(message.ReadString())
    local functions = uplinks[ownUplink].functions
    functions.text.Text = str
    functions.text.Text = str
    functions.text.Visible = true
    timesClicked = timesClicked + 1
    Timer.Wait(function()
        timesClicked = timesClicked - 1
        if timesClicked <= 0 then
            functions.text.Visible = false
        end
    end, 10000)
end)

-- We need to know some info when we reload CL Lua midround
if Game.RoundStarted then
    -- Wait for other things to be initialized
    Timer.Wait(function()
        local msg = Networking.Start("mm_uplinksync")
        Networking.Send(msg)
    end, 50)
end


local TIMER_BASE = 20
local timer = TIMER_BASE
-- Update our own uplink constantly, ignore others
Hook.Add("think", "Megamod_Client.UplinkUpdate", function()
    if not Game.RoundStarted
    or not Character.Controlled
    or Character.Controlled.IsDead == true then
        return
    end
    timer = timer - 1
    if timer <= 0 then
        timer = TIMER_BASE
        if ownUplink then
            recalcGrayedEntries(ownUplink)
        end
    end
end)

local function patchUplink(instance)
    -- Need to wait for other stuff to be initialized
    Timer.Wait(function()
        local uplinkTbl = {
            lastDimeAmount = STARTING_DIMES
        }
        local uplink = instance.Item

        uplinks[uplink] = uplinkTbl

        local frame = instance.GuiFrame

        -- Clears the previous UI, which would otherwise remain if we reload CL Lua
        frame.ClearChildren()

        --local menuContent = GUI.Frame(GUI.RectTransform(Vector2(0.3, 0.6), frame.RectTransform, GUI.Anchor.Center))
        --local menuList = GUI.ListBox(GUI.RectTransform(Vector2(0.7, 0.7), frame.RectTransform, GUI.Anchor.Center))

        local title = GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), frame.RectTransform), "Uplink", nil, GUI.Style.SubHeadingFont, GUI.Alignment.TopLeft)
        title.RectTransform.RelativeOffset = Vector2(0.01, 0.01)

        local objectivesMenu = {}
        uplinkTbl.objectivesMenu = objectivesMenu
        do
            objectivesMenu.currentObj = {}
            -- Button changes from "Get new objective" to "Abandon objective"
            -- based on if we currently have an objective
            objectivesMenu.buttonRow = GUI.LayoutGroup(GUI.RectTransform(Vector2(0.5, 0.05), frame.RectTransform, GUI.Anchor.BottomCenter), true)
            objectivesMenu.buttonRow.Visible = false
            objectivesMenu.buttonRow.RectTransform.RelativeOffset = Vector2(0, 0.05)
            objectivesMenu.newObjButton = GUI.Button(
                GUI.RectTransform(Vector2(0.33, 1), objectivesMenu.buttonRow.RectTransform, GUI.Anchor.Center),
                "Get new objective",
                GUI.Alignment.Center,
                "GUIButtonSmallFreeScale")
            objectivesMenu.newObjButton.OnClicked = function()
                local msg = Networking.Start("mm_traitornewobj")
                Networking.Send(msg)
            end
            objectivesMenu.abandonButton = GUI.Button(
                GUI.RectTransform(Vector2(0.33, 1), objectivesMenu.buttonRow.RectTransform, GUI.Anchor.Center),
                "Abandon objective",
                GUI.Alignment.Center,
                "GUIButtonSmallFreeScale")
            objectivesMenu.abandonButton.OnClicked = function()
                local msg = Networking.Start("mm_traitorabandonobj")
                Networking.Send(msg)
            end
            objectivesMenu.completeButton = GUI.Button(
                GUI.RectTransform(Vector2(0.33, 1), objectivesMenu.buttonRow.RectTransform, GUI.Anchor.Center),
                "Complete objective",
                GUI.Alignment.Center,
                "GUIButtonSmallFreeScale")
            objectivesMenu.completeButton.OnClicked = function()
                local msg = Networking.Start("mm_traitorcompleteobj")
                Networking.Send(msg)
            end

            objectivesMenu.innerFrame = GUI.Frame(GUI.RectTransform(Vector2(0.9, 0.6), frame.RectTransform, GUI.Anchor.Center), "InnerFrame")
            objectivesMenu.innerFrame.Visible = false
            objectivesMenu.text = GUI.TextBlock(GUI.RectTransform(Vector2(0.95, 0.95), objectivesMenu.innerFrame.RectTransform, GUI.Anchor.Center), "No objective at the moment.", nil, nil, GUI.Alignment.Center)
            objectivesMenu.text2 = GUI.TextBlock(GUI.RectTransform(Vector2(0.95, 0.3), objectivesMenu.innerFrame.RectTransform, GUI.Anchor.BottomCenter), "", nil, nil, GUI.Alignment.Center)
        end

        local messagesBoard = {}
        uplinkTbl.messagesBoard = messagesBoard
        do
            messagesBoard.messageList = GUI.ListBox(GUI.RectTransform(Vector2(0.9, 0.75), frame.RectTransform, GUI.Anchor.Center), false, Color.Transparent, nil, true)
            messagesBoard.messageList.Visible = false
            messagesBoard.messageList.ResizeContentToMakeSpaceForScrollBar = true
            messagesBoard.messageList.ScrollBarVisible = true
            messagesBoard.messageList.ScrollBarEnabled = true
            messagesBoard.messageList.RectTransform.RelativeOffset = Vector2(0, 0.00)
            messagesBoard.messageList.CanBeFocused = false

            messagesBoard.spacingLine = GUI.Frame(GUI.RectTransform(Vector2(0.9, 0.6), frame.RectTransform, GUI.Anchor.BottomCenter), "HorizontalLine")
            messagesBoard.spacingLine.Visible = false
            messagesBoard.spacingLine.RectTransform.RelativeOffset = Vector2(0, 0.11)

            messagesBoard.inputBox = GUI.TextBox(GUI.RectTransform(Vector2(0.8, 0.1), frame.RectTransform, GUI.Anchor.BottomCenter), "")
            messagesBoard.inputBox.Visible = false
            messagesBoard.inputBox.RectTransform.RelativeOffset = Vector2(0, 0.05)
            messagesBoard.inputBox.MaxTextLength = 94
            messagesBoard.inputBox.OverflowClip = true
            messagesBoard.inputBox.OnEnterPressed = function(inputBox)
                local str = tostring(inputBox.Text)
                addUplinkMessage(str, nil, true) -- Add a message to the box from "YOU"
                local msg = Networking.Start("mm_traitormsg")
                msg.WriteString(str)
                Networking.Send(msg)
                inputBox.Text = ""
            end
        end

        local shopList
        do
            local SHOP_BASE = shared.shop
            local availableShopItems = {}
            for job, jobShop in pairs(SHOP_BASE) do
                if type(job) == "table" then
                    for subJob in job do
                        if tostring(Character.Controlled.JobIdentifier) == subJob then
                            for shopItem, shopItemTable in pairs(jobShop) do
                                local shopItemName = tostring(shopItem)
                                local newShopItemTable = {}
                                for k, v in pairs(shopItemTable) do
                                    newShopItemTable[k] = v
                                end
                                availableShopItems[shopItemName] = newShopItemTable
                            end
                            break
                        end
                    end
                elseif type(job) == "string" then
                    if job == "all" or tostring(Character.Controlled.JobIdentifier) == job then
                        for shopItem, shopItemTable in pairs(jobShop) do
                            local shopItemName = tostring(shopItem)
                            local newShopItemTable = {}
                            for k, v in pairs(shopItemTable) do
                                newShopItemTable[k] = v
                            end
                            availableShopItems[shopItemName] = newShopItemTable
                        end
                    end
                end
            end

            shopList = GUI.ListBox(GUI.RectTransform(Vector2(0.95, 0.83), frame.RectTransform, GUI.Anchor.Center), false, Color.Transparent, "GUIListBoxNoBorder", true)
            shopList.Visible = false
            shopList.ResizeContentToMakeSpaceForScrollBar = true
            shopList.ScrollBarVisible = true
            shopList.ScrollBarEnabled = true
            shopList.RectTransform.RelativeOffset = Vector2(0, 0.05)
            shopList.Spacing = 15

            local shopEntries = {}
            uplinkTbl.shopEntries = shopEntries
            for itemName, itemTbl in pairs(availableShopItems) do
                local tbl = {}
                shopEntries[itemName] = tbl
                tbl.lastDimeAmount = STARTING_DIMES
                tbl.grayedOut = false
                tbl.priceNum = itemTbl.cost
                tbl.stockNum = itemTbl.stock
                tbl.rowFrame = GUI.Frame(GUI.RectTransform(Vector2(1, 0.1), shopList.Content.RectTransform, GUI.Anchor.TopCenter), "InnerFrame")
                tbl.row = GUI.LayoutGroup(GUI.RectTransform(Vector2(1, 1), tbl.rowFrame.RectTransform, GUI.Anchor.Center), true)
                tbl.item = ItemPrefab.GetItemPrefab(itemTbl.spriteID)
                -- Items that do not define an InventoryIcon will use their
                -- sprite as an InventoryIcon instead
                -- It's okay if this is nil (neither were defined), it'll just be blank in the menu
                local sprite = tbl.item.InventoryIcon or tbl.item.Sprite
                tbl.image = GUI.Image(GUI.RectTransform(Vector2(0.05, 1), tbl.row.RectTransform, GUI.Anchor.Center), sprite)
                tbl.image.ToolTip = tostring(itemTbl.desc)
                tbl.itemName = GUI.TextBlock(GUI.RectTransform(Vector2(0.4, 1), tbl.row.RectTransform), Megamod.Capitalize(tostring(itemName)), nil, nil, GUI.Alignment.Center)
                tbl.price = GUI.TextBlock(GUI.RectTransform(Vector2(0.2, 1), tbl.row.RectTransform), tostring(tbl.priceNum), nil, nil, GUI.Alignment.Center)
                tbl.price.ToolTip = "Cost"
                tbl.stock = GUI.TextBlock(GUI.RectTransform(Vector2(0.2, 1), tbl.row.RectTransform), tostring(tbl.stockNum), nil, nil, GUI.Alignment.Center)
                tbl.stock.ToolTip = "Stock"
                tbl.buyButton = GUI.Button(
                    GUI.RectTransform(Vector2(0.15, 1), tbl.row.RectTransform, GUI.Anchor.Center),
                    "Buy",
                    GUI.Alignment.Center,
                    "GUIButtonSmallFreeScale")
                -- Can't just use itemTbl.buy() here because that's server-sided
                tbl.buyButton.OnClicked = function()
                    if tbl.priceNum <= tbl.lastDimeAmount and tbl.stockNum > 0 then
                        tbl.stockNum = tbl.stockNum - 1
                        tbl.stock.Text = tostring(tbl.stockNum)
                        -- Manually gray this out if stock runs out
                        if tbl.grayedOut == false and tbl.stockNum <= 0 then
                            grayOutShopEntry(tbl, true)
                        end
                        -- Send a net message to the server telling it that we bought this
                        local msg = Networking.Start("mm_traitorbuy")
                        msg.WriteString(itemName)
                        Networking.Send(msg)
                    end
                end
            end
        end

        local functions = {}
        uplinkTbl.functions = functions
        do
            functions.dvButton = GUI.Button(
                GUI.RectTransform(Vector2(0.15, 0.15), frame.RectTransform, GUI.Anchor.Center),
                "DV",
                GUI.Alignment.Center,
                "GUIButtonSmallFreeScale")
            functions.dvButton.ToolTip = "Activate a Deep Vents Access Point. These are the holes in the walls you see in maintenance areas."
            functions.dvButton.Visible = false
            functions.dvButton.OnClicked = function()
                local msg = Networking.Start("mm_traitordv")
                Networking.Send(msg)
            end
        
            functions.text = GUI.TextBlock(GUI.RectTransform(Vector2(0.4, 0.1), frame.RectTransform, GUI.Anchor.Center), "", nil, nil, GUI.Alignment.Center)
            functions.text.Visible = false
            functions.text.RectTransform.RelativeOffset = Vector2(0, 0.1)
        end

        -- 0 = none (default)
        -- 1 = objectives
        -- 2 = messages
        -- 3 = store
        -- 4 = functions
        local selectedMode = 0

        local modeButtonRow = GUI.LayoutGroup(GUI.RectTransform(Vector2(0.7, 0.2), frame.RectTransform, GUI.Anchor.TopCenter), true)
        modeButtonRow.RectTransform.RelativeOffset = Vector2(0, 0.05)

        local modeButtons = {
            {
                Label = "Objectives",
                Button = nil,
                -- Any GUI components in this table get their Visible toggled when the
                -- mode buttons are pressed
                GUI = { objectivesMenu.buttonRow, objectivesMenu.innerFrame },
            },
            {
                Label = "Messages",
                Button = nil,
                GUI = { messagesBoard.messageList, messagesBoard.spacingLine, messagesBoard.inputBox },
            },
            {
                Label = "Store",
                Button = nil,
                GUI = { shopList },
            },
            {
                Label = "Functions",
                Button = nil,
                GUI = { functions.dvButton, functions.text },
            },
        }

        for buttonNum, tbl in ipairs(modeButtons) do
            local newButton = GUI.Button(
                GUI.RectTransform(Vector2(1 / #modeButtons, 1), modeButtonRow.RectTransform, GUI.Anchor.Center),
                tbl.Label,
                GUI.Alignment.Center,
                "GUIButton")
            tbl.Button = newButton
            newButton.OnClicked = function()
                if selectedMode == buttonNum then return end
                selectedMode = buttonNum
                for otherTbl in modeButtons do
                    otherTbl.Button.ExternalHighlight = false
                    for guiComponent in otherTbl.GUI do
                        guiComponent.Visible = false
                    end
                end
                newButton.ExternalHighlight = true
                for guiComponent in tbl.GUI do
                    guiComponent.Visible = true
                end
            end
        end

        local dimeSprite = ItemPrefab.GetItemPrefab("mm_dime")
        dimeSprite = dimeSprite.InventoryIcon or dimeSprite.Sprite
        local dimesIcon = GUI.Image(GUI.RectTransform(Vector2(0.05, 0.05), frame.RectTransform, GUI.Anchor.TopLeft), dimeSprite)
        dimesIcon.ToolTip = tostring("Dimensional Essence, or dimes for short. It's used as currency in your uplink.")
        dimesIcon.RectTransform.RelativeOffset = Vector2(0.02, 0.06)
        local dimeText = GUI.TextBlock(GUI.RectTransform(Vector2(0.02, 0.05), frame.RectTransform, GUI.Anchor.TopLeft), tostring(STARTING_DIMES), nil, GUI.Style.MonospacedFont, GUI.Alignment.Center)
        dimeText.RectTransform.RelativeOffset = Vector2(0.06, 0.06)
        uplinkTbl.dimeText = dimeText
    end, 1)
end
Hook.Patch("Barotrauma.Items.Components.CustomInterface", "CreateGUI", function(instance, ptable)
    if instance.originalElement.GetAttributeString("type", "") ~= "uplink" then
        return
    end
    patchUplink(instance)
end)
-- Find uplinks if we reload CL Lua midround
if Game.RoundStarted then
    for item in Item.ItemList do
        if tostring(item.Prefab.Identifier) == "mm_uplink" then
            patchUplink(item.GetComponentString("CustomInterface"))
        end
    end
end
