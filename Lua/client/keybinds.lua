    --[[[1] = function()
        local slotReference = Megamod_Client.GetHoveredItem()
        if slotReference and not firstItem then
            firstItem = slotReference.Item
            Megamod_Client.SelfMsg(true, "Set item #1 to " .. tostring(firstItem.Name), Color(255, 0, 255, 255))
            return
        elseif not slotReference and firstItem ~= nil then
            firstItem = nil
            Megamod_Client.SelfMsg(true, "Reset selected item", Color(255, 0, 255, 255))
            return
        elseif not slotReference then
            Megamod_Client.SelfMsg(true, "Hover over item #1 in your inventory", Color(255, 0, 255, 255))
            return
        end
        if slotReference.Item == firstItem then
            Megamod_Client.SelfMsg(true, "Items are the same", Color(255, 0, 255, 255))
            return
        end
        local msg = Networking.Start("mm_chem")
        msg.WriteByte(2) -- Header
        msg.WriteUInt64(firstItem.ID)
        msg.WriteByte(1) -- Subcontainer 1 ID
        msg.WriteUInt64(slotReference.Item.ID)
        msg.WriteByte(1) -- Subcontainer 2 ID
        msg.WriteSingle(5) -- Amount to transfer
        Networking.Send(msg)
        Megamod_Client.SelfMsg(true, "Transferred", Color(255, 0, 255, 255))
    end,
    [2] = function()
        local slotReference = Megamod_Client.GetHoveredItem()
        if not slotReference then
            print("Hover over an item")
            return
        end
        local container = slotReference.Item
        if not container then
            print("Hover over an item")
            return
        end
        local containerTbl = Megamod_Client.Chemistry.ContainersItems[container]
        if containerTbl then
            print(tostring(container) .. ":")
            print("Subcontainers:")
            for k, subContainerTbl in pairs(containerTbl.SubContainers) do
                print("SC " .. tostring(k))
                print("Capacity: " .. tostring(subContainerTbl.Capacity))
                print("TemperatureK: " .. tostring(subContainerTbl.TemperatureK))
                print("Site: " .. tostring(subContainerTbl.Site))
                print("Reagents:")
                local hasReagents = false
                for reagentID, reagentTbl in pairs(subContainerTbl.Reagents) do
                    hasReagents = true
                    print("ID: " .. tostring(reagentTbl.ID))
                    print("Amount: " .. tostring(reagentTbl.Amount))
                end
                if not hasReagents then
                    print("(no reagents)")
                end
            end
            print("-----")
        else
            print("Not a container")
        end
    end,
    [3] = function()
        local mousePos = Megamod.ScreenToWorld(PlayerInput.MousePosition)
        local container
        local closestDist = math.huge
        for char in Character.CharacterList do
            local dist = Vector2.Distance(char.WorldPosition, mousePos)
            if dist < closestDist then
                container = char
                closestDist = dist
            end
        end
        if not container then return end
        local containerTbl = Megamod_Client.Chemistry.ContainersCharacters[container]
        if containerTbl then
            print(tostring(container.SpeciesName) .. " (" .. tostring(container.DisplayName) .. "):")
            print("Subcontainers:")
            for k, subContainerTbl in pairs(containerTbl.SubContainers) do
                print("SC " .. tostring(k))
                print("Capacity: " .. tostring(subContainerTbl.Capacity))
                print("TemperatureK: " .. tostring(subContainerTbl.TemperatureK))
                print("Site: " .. tostring(subContainerTbl.Site))
                print("Reagents:")
                local hasReagents = false
                for reagentID, reagentTbl in pairs(subContainerTbl.Reagents) do
                    hasReagents = true
                    print("ID: " .. tostring(reagentTbl.ID))
                    print("Amount: " .. tostring(reagentTbl.Amount))
                end
                if not hasReagents then
                    print("(no reagents)")
                end
            end
            print("-----")
        else
            print("Not a container")
        end
    end,]]

Megamod_Client.KeyBinds = {}

local funcTable = {
    -- Change force swim mode
    [1] = function()
        if not Megamod.CertifiedBeasters[Megamod_Client.GetSelfClient().SteamID]
        or not Character.Controlled
        or Character.Controlled.IsDead == true
        or tostring(Character.Controlled.SpeciesName) ~= "Truebeast" then return end
        Megamod.CS_Shared.ForceInWater = not Megamod.CS_Shared.ForceInWater
        local msg = Networking.Start("mm_beastwater")
        msg.WriteBoolean(Megamod.CS_Shared.ForceInWater)
        Networking.Send(msg)
        local str = "Enabled"
        if not Megamod.CS_Shared.ForceInWater then
            str = "Disabled"
        end
        Game.ChatBox.AddMessage(ChatMessage.Create("", str .. " gravitational ignorance",
        ChatMessageType.Default, Megamod_Client.GetSelfClient().Character, Megamod_Client.GetSelfClient(), 1, Color(200, 0, 75, 255)))
    end,
    -- Swim upward while in force swim mode
    [2] = function()
        if not Megamod.CertifiedBeasters[Megamod_Client.GetSelfClient().SteamID]
        or not Character.Controlled
        or Character.Controlled.IsDead == true
        or not tostring(Character.Controlled.SpeciesName) == "Truebeast"
        or not Megamod.CS_Shared.ForceInWater then return end

        local shiftDown = PlayerInput.KeyDown(Keys["LeftShift"])

        local vector = Vector2(0, 4)
        if shiftDown then
            vector = Vector2(0, 12)
        end
        Character.Controlled.AnimController.Collider.ApplyLinearImpulse(vector, 10)

        local msg = Networking.Start("mm_beastmove")
        msg.WriteBoolean(shiftDown)
        Networking.Send(msg)
    end,
    -- Rotate collider towards cursor while in force swim mode
    [3] = function()
        if not Megamod.CertifiedBeasters[Megamod_Client.GetSelfClient().SteamID]
        or not Character.Controlled
        or Character.Controlled.IsDead == true
        or not tostring(Character.Controlled.SpeciesName) == "Truebeast"
        or not Megamod.CS_Shared.ForceInWater then return end

        local collider = Character.Controlled.AnimController.Collider
        local dirTowardsCursor = Megamod.AngleBetweenVector2(Character.Controlled.WorldPosition, Megamod.ScreenToWorld(PlayerInput.MousePosition))
        dirTowardsCursor = math.deg(dirTowardsCursor)
        dirTowardsCursor = dirTowardsCursor - 90
        dirTowardsCursor = math.rad(dirTowardsCursor)
        collider.SmoothRotate(dirTowardsCursor, 10, true)

        local msg = Networking.Start("mm_beastrotate")
        msg.WriteSingle(dirTowardsCursor)
        Networking.Send(msg)
    end,
}

-- We need to request our keybinds as they're stored server side
--[[Timer.Wait(function()
    local msg = Networking.Start("mm_getkeybinds")
    Networking.Send(msg)
end, 100)
Networking.Receive("mm_getkeybinds", function(message)
    local amount = message.ReadByte()
    for i = 1, amount do
        local keyName = message.ReadString()
        local keyFuncID = message.ReadByte()
        local hitType = message.ReadByte()
        local modifierKeys = {}
        local modifierKeysAmount = message.ReadByte()
        for a = 1, modifierKeysAmount do
            local modifierKeyName = message.ReadString()
            table.insert(modifierKeys, modifierKeyName)
        end
        table.insert(Megamod_Client.KeyBinds, {
            Key = keyName,
            ModifierKeys = modifierKeys,
            Func = funcTable[keyFuncID],
            HitType = hitType
        })
    end
    funcTable = nil -- Save a little memory
end)]]

-- HitType
-- (1) Hit: One time when you press down the key
-- (2) Up: Constantly, while the key is not being pressed
-- (3) Down: Constantly, while the key is being pressed


table.insert(Megamod_Client.KeyBinds, {
    Key = "F",
    ModifierKeys = {},
    Func = funcTable[1],
    HitType = 1
})
table.insert(Megamod_Client.KeyBinds, {
    Key = "W",
    ModifierKeys = {},
    Func = funcTable[2],
    HitType = 3
})
table.insert(Megamod_Client.KeyBinds, {
    Key = "LeftAlt",
    ModifierKeys = {},
    Func = funcTable[3],
    HitType = 3
})

local function process(keyBind)
    if #keyBind.ModifierKeys > 0 then
        local modifiersDown = true
        for modifierKey in keyBind.ModifierKeys do
            if not PlayerInput.KeyDown(Keys[modifierKey]) then
                -- One of the modifiers isn't down, we know it isn't going through
                modifiersDown = false
                break
            end
        end
        if modifiersDown then
            keyBind.Func()
        end
    else
        keyBind.Func()
    end
end
Hook.Add("think", "Megamod_Client.KeyBinds.Think", function()
    -- Don't process keybinds if we're typing
    if GUI.KeyboardDispatcher.Subscriber ~= nil then return end
    for keyBind in Megamod_Client.KeyBinds do
        if keyBind.HitType == 1 and PlayerInput.KeyHit(Keys[keyBind.Key]) then
            process(keyBind)
        elseif keyBind.HitType == 2 and PlayerInput.KeyUp(Keys[keyBind.Key]) then
            process(keyBind)
        elseif keyBind.HitType == 3 and PlayerInput.KeyDown(Keys[keyBind.Key]) then
            process(keyBind)
        end
    end
end)
