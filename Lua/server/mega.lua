Megamod.ClientData = {}

local json = require 'utils.json'

local prefMap = {
    { name = "Traitor", type = "boolean" },
    { name = "Monster", type = "boolean" },
    { name = "Beast", type = "boolean" },
}

Networking.Receive("mm_changeprefs", function(message, client)
    local amount = message.ReadByte()
    if not amount
    or math.ceil(amount) ~= amount -- Integer
    or 0 >= amount or amount > #prefMap then
        Megamod.Log("Client '" .. tostring(client.Name) .. "' sent malformed mm_changeprefs (invalid amount).", true)
        return
    end
    for i = 1, amount do
        local prefName = message.ReadString()
        if not prefName then
            Megamod.Log("Client '" .. tostring(client.Name) .. "' sent malformed mm_changeprefs (no prefName).", true)
            return
        end
        local prefType
        for tbl in prefMap do
            if tbl.name == prefName then
                prefType = tbl.type
                break
            end
        end
        if not prefType then
            Megamod.Log("Client '" .. tostring(client.Name) .. "' sent malformed mm_changeprefs (invalid prefName).", true)
            return
        end
        local prefValue
        if prefType == "boolean" then
            prefValue = message.ReadBoolean()
        end
        if prefValue == nil then
            Megamod.Log("Client '" .. tostring(client.Name) .. "' sent malformed mm_changeprefs (invalid prefValue).", true)
            return
        end
        if prefName == "Beast" and prefValue == true
        and not Megamod.CertifiedBeasters[client.SteamID] then
            -- This should be blocked client-side, if they sent a message, their client was modified
            Megamod.Log("Client '" .. tostring(client.Name) .. "' tried to enable Beast, but was not a CB.", true)
            return
        end
        Megamod.SetData(client, prefName, prefValue)
        --print(tostring(tostring(client.Name) .. " - " .. tostring(prefName) .. " - " .. tostring(prefValue)))
    end
end)

Networking.Receive("mm_getprefs", function(message, client)
    local msg = Networking.Start("mm_getprefs")
    msg.WriteByte(#prefMap)
    for _, prefTbl in pairs(prefMap) do
        msg.WriteString(prefTbl.name)
        local value = Megamod.GetData(client, prefTbl.name)
        if prefTbl.type == "boolean" then
            msg.WriteBoolean(value)
        end
    end
    Networking.Send(msg, client.Connection)
end)

local defaultPrefMap = {
    Traitor = true,
    Monster = true,
    Beast = false -- Value doesn't matter for Beast
}

function Megamod.NewClientData(client)
    Megamod.ClientData[client.SteamID] = {}
    Megamod.ClientData[client.SteamID]["Name"] = client.Name
    Megamod.ClientData[client.SteamID]["Prefs"] = {}
    for valueName, value in pairs(defaultPrefMap) do
        if valueName == "Beast" then
            value = Megamod.CertifiedBeasters[client.SteamID] == true
        end
        Megamod.ClientData[client.SteamID][valueName] = value
    end
end

function Megamod.LoadData()
    local cfgFile = Game.SaveFolder .. "/ModConfigs/Megamod.json"
    if not File.Exists(cfgFile) then
        File.Write(cfgFile, "{}")
    end
    Megamod.ClientData = json.decode(File.Read(cfgFile)) or {}
end
Megamod.LoadData()

function Megamod.SaveData()
    File.Write(Game.SaveFolder .. "/ModConfigs/Megamod.json", json.encode(Megamod.ClientData))
end
Hook.Add("roundEnd", "Megamod.SaveData", Megamod.SaveData)

function Megamod.SetMasterData(name, value)
    Megamod.ClientData[name] = value
end

function Megamod.GetMasterData(name)
    return Megamod.ClientData[name]
end

function Megamod.SetData(client, name, amount)
    if Megamod.ClientData[client.SteamID] == nil then
        Megamod.NewClientData(client)
    end

    Megamod.ClientData[client.SteamID][name] = amount
end

function Megamod.GetData(client, name)
    if Megamod.ClientData[client.SteamID] == nil then
        Megamod.NewClientData(client)
    end

    return Megamod.ClientData[client.SteamID][name]
end

function Megamod.AddData(client, name, amount)
    Megamod.SetData(client, name, math.max((Megamod.GetData(client, name) or 0) + amount, 0))
end


function Megamod.SendClientSideMsg(client, text, color, msgType)
    local msg = Networking.Start("mm_selfmsg")
    if msgType then
        msg.WriteBoolean(msgType)
    else
        if not Megamod.CheckIsDead(client) and client.Character.Vitality > 5 then
            msg.WriteBoolean(true) -- Shows a message hovering above their character, like skill gain messages
        else
            msg.WriteBoolean(false) -- Shows a message at the top of the screen, like husk warnings
        end
    end
    msg.WriteString(text)
    msg.WriteColorR8G8B8(color)
    Networking.Send(msg, client.Connection)
end

function Megamod.SendMessageEveryone(text, popup)
    if popup then
        Game.SendMessage(text, ChatMessageType.MessageBox)
    else
        Game.SendMessage(text, ChatMessageType.Server)
    end
end

function Megamod.SendMessage(client, text, icon)
    if not client or not text or text == "" then
        return
    end
    text = tostring(text)

    if icon then
        Game.SendDirectChatMessage("", text, nil, ChatMessageType.ServerMessageBoxInGame, client, icon)
    else
        Game.SendDirectChatMessage("", text, nil, ChatMessageType.MessageBox, client)
    end

    Game.SendDirectChatMessage("", text, nil, ChatMessageType.Default, client)
end

function Megamod.SendChatMessage(client, text, color)
    if not client or not text or text == "" then return end

    text = tostring(text)

    local chatMessage = ChatMessage.Create("", text, ChatMessageType.Default)
    if color then
        chatMessage.Color = color
    end

    Game.SendDirectChatMessage(chatMessage, client)
end

function Megamod.CreateEntityEvent(entity, originalEntity, propID, value)
    entity[propID] = value
    local prop = entity.SerializableProperties[Identifier(propID)]
    Networking.CreateEntityEvent(originalEntity, Item.ChangePropertyEventData(prop, entity))
end

---@return boolean "true=success"
function Megamod.GiveAntagOverlay(character)
    if not character or character.IsDead then return false end

    local prefab = AfflictionPrefab.Prefabs["mm_antagoverlay"]
    local limb
    -- Apparently these can be null
    if character.AnimController and character.AnimController.GetLimb then
        limb = character.AnimController.GetLimb(LimbType.Torso)
        character.CharacterHealth.ApplyAffliction(limb, prefab.Instantiate(1))
        return true
    end

    return false
end

-- type: 6 = Server message, 7 = Console usage, 9 = error
---@param message string
---@param important boolean
function Megamod.Log(message, important)
    important = important or false
    if not important then
        Game.Log("[Megamod] " .. message, 6)
        return
    end
    Game.Log("\\[Megamod] " .. message, 6)
    -- Omni clients get the log in chat
    for k, client in pairs(Megamod.Omni) do
        Megamod.SendChatMessage(client, message, Color(0, 255, 255, 255))
    end
end

---@param name string
function Megamod.EventLog(name)
    Megamod.Log("Event started: " .. name, true)
end

---@param message string
function Megamod.Error(message, ...)
    Game.Log("\\[Megamod-Error] " .. message, 9)
    -- Omni clients get the error in chat
    for k, client in pairs(Megamod.Omni) do
        Megamod.SendChatMessage(client, "[ERROR] " .. message, Color(0, 255, 255, 255))
    end
end