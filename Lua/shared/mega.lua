-- Some of these are modified from Traitormod

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

-- Use to check if a client is controlling an alive character
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

-- Specifically check if a client is dead & spectating the round, different than CheckIsDead
---@return boolean "true=spectating, false=not spectating"
function Megamod.CheckIsSpectating(client)
    if not client
    or not client.InGame
    or (client.Character and not client.Character.IsDead) then
        return false
    end
    return true
end

function Megamod.GetClients()
    local clients = {}
    for client in Client.ClientList do
        if client then
            table.insert(clients, client)
        end
    end
    return clients
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