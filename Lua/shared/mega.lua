-- Some of these are modified from Traitormod

Megamod.ClientData = {}

local json = require 'utils.json'

function Megamod.Capitalize(str)
    return (str:gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest:lower()
    end))
end

function Megamod.PathToReq(path)
    local _, str = path:find("/Lua/")
    str = str + 1
    path = path:sub(str, -1):gsub("\\", "."):gsub("/", ".")
    local ending = path:sub(-3, -1)
    if ending == "xml" or ending == "lua" then
        path = path:sub(1, -5)
    end
    return path
end

function Megamod.RandomWord(chars)
    local word = ""
    for i = 1, 3 do
        local randomIndex = math.random(1, #chars)
        local randomChar = string.sub(chars, randomIndex, randomIndex)
        word = word .. randomChar
    end
    return word
end

---@return boolean "true=dead, false=alive"
function Megamod.CheckIsDead(client)
    if not client
    or not client.InGame
    or client.Character == nil
    or client.Character.IsDead then
        return true
    end
    return false
end

-- Specifically check if a client is spectating while ingame
---@return boolean "true=spectating, false=not spectating"
function Megamod.CheckIsSpectating(client)
    if not client
    or not client.InGame
    or (client.Character and not client.Character.IsDead) then
        return false
    end
    return true
end

-- Math stuff

function Megamod.Lerp(a, b, t)
	return a + (b - a) * t
end

function Megamod.Normalize(x, min, max)
  return (x - min) / (max - min)
end

function Megamod.WorldToScreen(worldPosition)
    return Game.GameScreen.Cam.WorldToScreen(worldPosition)
end

function Megamod.ScreenToWorld(screenPos)
    return Game.GameScreen.Cam.ScreenToWorld(screenPos)
end

function Megamod.FunnyMaths(point, angle, distance)
    angle = math.rad(angle)
    return Vector2(point.X + distance * math.cos(angle), point.Y + distance * math.sin(angle))
end

function Megamod.AngleBetweenVector2(from, to)
    local dx = to.x - from.x
    local dy = to.y - from.y
    local angle = math.atan2(dy, dx)
    return angle
end



-- **********************
if CLIENT then return end
-- **********************



function Megamod.NewClientData(client)
    Megamod.ClientData[client.SteamID] = {}
    Megamod.ClientData[client.SteamID]["Name"] = client.Name
    for antagType in Megamod.RuleSetManager.AntagTypes do
        if antagType ~= "Beast" then
            Megamod.ClientData[client.SteamID][antagType] = true
        else
            Megamod.ClientData[client.SteamID][antagType] = false
        end
    end
end

function Megamod.LoadData()
    local cfgFile = Game.SaveFolder .. "/ModConfigs/Megamod.json"
    if not File.Exists(cfgFile) then
        File.Write(cfgFile, "{}")
    end
    Megamod.ClientData = json.decode(File.Read(cfgFile)) or {}
end
Hook.Add("loaded", "Megamod.LoadDataServer", Megamod.LoadData)

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


function Megamod.SendHoverMessage(client, text, color)
    local msg = Networking.Start("mm_selfcharmsg")
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