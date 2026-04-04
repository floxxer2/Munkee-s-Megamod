Megamod_Client.KeyBinds = {}

local firstItem
local funcTable = {
    [1] = function()
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
        local msg = Networking.Start("mm_chem")
        msg.WriteByte(1)
        msg.WriteUInt64(firstItem.ID)
        msg.WriteByte(1) -- Subcontainer 1 ID
        msg.WriteUInt64(slotReference.Item.ID)
        msg.WriteByte(1) -- Subcontainer 2 ID
        msg.WriteUInt64(5) -- Amount to transfer
        Networking.Send(msg)
        Megamod_Client.SelfMsg(true, "Transferred", Color(255, 0, 255, 255))
    end,
}
-- #DEBUG#
table.insert(Megamod_Client.KeyBinds, {
        Key = "V",
        ModifierKeys = {},
        Func = funcTable[1],
        HitType = 1
    })

-- We need to request our keybinds as they're stored server side
Timer.Wait(function()
    local msg = Networking.Start("mm_getkeybinds")
    Networking.Send(msg)
end, 100)
Networking.Receive("mm_getkeybinds", function(message)
    local amount = message.ReadByte()
    for i = 1, amount do
        local keyName = message.ReadString()
        local modifierKeysString = message.ReadString()
        local keyFuncID = message.ReadByte()
        local hitType = message.ReadByte()
        local modifierKeys = {}
        for str in string.gmatch(modifierKeysString, "(%w+),") do
            table.insert(modifierKeys, str)
        end
        table.insert(Megamod_Client.KeyBinds, {
            Key = keyName,
            ModifierKeys = modifierKeys,
            Func = funcTable[keyFuncID],
            HitType = hitType
        })
    end
    funcTable = nil -- Save a little memory
end)

-- HitType
-- (1) Hit: One time when you press down the key
-- (2) Up: Constantly, while the key is not being pressed
-- (3) Down: Constantly, while the key is being pressed

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
    if Game.ChatBox.InputBox.Selected then return end
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
