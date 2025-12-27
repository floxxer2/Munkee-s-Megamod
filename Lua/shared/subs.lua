local s = {}

---@param sub Barotrauma.Submarine
---@param bodyType "dynamic"|"static"|"kinematic"
function s.SetSubBodyType(sub, bodyType)
    if bodyType == "dynamic" then
        sub.PhysicsBody.BodyType = Megamod.PhysicsBodyTypes.Dynamic
    elseif bodyType == "static" then
        sub.PhysicsBody.BodyType = Megamod.PhysicsBodyTypes.Static
    elseif bodyType == "kinematic" then
        sub.PhysicsBody.BodyType = Megamod.PhysicsBodyTypes.Kinematic
    else
        Megamod.Error("Invalid body type.")
    end
end

-- Don't use this, it isn't networked and will desync anybody trying to join
--@param filePath string
--@param spawnPoint Microsoft.Xna.Framework.Vector2
--[[function s.SpawnSub(filePath, spawnPoint)
    -- SubmarineInfo() will just error if the path is invalid
    local ok, subInfo = pcall(function() return SubmarineInfo(filePath) end)
    if not ok or not subInfo then return end

    local sub = Submarine.Load(subInfo, false)
    sub.SetPosition(spawnPoint, {}, false)
    return sub
end]]

return s
