local mm = {}

function mm.WorldToScreen(worldPosition)
    return Game.GameScreen.Cam.WorldToScreen(worldPosition)
end

function mm.FunnyMaths(point, angle, distance)
    angle = math.rad(angle)
    return Vector2(point.X + distance * math.cos(angle), point.Y + distance * math.sin(angle))
end

function mm.AngleBetweenVector2(from, to)
    local dx = to.x - from.x
    local dy = to.y - from.y
    local angle = math.atan2(dy, dx)
    return angle
end

return mm
