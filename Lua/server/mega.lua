Megamod.ClientData = {}

local json = require 'utils.json'

Megamod.ClientDataMap = {
    Messaging = {
        desc = "How do you want certain messages from TBG to be displayed? This affects messages that you can send to yourself constantly, like those of hypomaxims.",
        defaultValue = 1,
        valueMap = {
            ["Hover above my character (like skill gain messages)"] = 1,
            ["Float at the top of the screen (like the messages when you have husk)"] = 2,
            ["Appear in the chatbox"] = 3,
        },
    },
}
Timer.Wait(function()
    for antagType in Megamod.RuleSetManager.AntagTypes do
        local default = antagType ~= "Beast"
        Megamod.ClientDataMap[antagType] = {
            desc = "Do you want to be (potentially) selected as this antagonist?",
            defaultValue = default,
            valueMap = {
                Yes = true,
                No = false,
            },
        }
    end
end, 1)

function Megamod.NewClientData(client)
    Megamod.ClientData[client.SteamID] = {}
    Megamod.ClientData[client.SteamID]["Name"] = client.Name
    Megamod.ClientData[client.SteamID]["Prefs"] = {}
    for valueName, valueTbl in pairs(Megamod.ClientDataMap) do
        Megamod.ClientData[client.SteamID]["Prefs"][valueName] = valueTbl
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