-- The traitor's dime locator, allowing you to find dimes / dimensional leaks
-- Lots of how to do this was learned from Item Finder

local LINE_ANGLES = 30 -- Divide by 360 evenly, please
local UPDATE_TIMER = 300 -- Updating new and deleted dime sources
local RANGE = 3000 -- Hard cap on the range
local ANGLE_LIMIT = 15 -- Lines whose angles are within this range of the direction to the source will get longer
local WAVE = 50 -- Amount that the lines move in and out
local LERP_AMOUNT = 0.05 -- Makes the lines jitter around
local HIT_STRENGTH = 2 -- Multiplier on how long the lines get when they "see" something
local INNER = 50 -- Base distance the lines can move towards you
local OUTER = 75 -- Base distance the lines can move away from you

--- @param from System.Numerics.Vector2 The origin point, the player
--- @param to System.Numerics.Vector2 The target
--- @param angle number The angle (in degrees) of the line
--- @return number Multiplier value (float), higher when the line points toward the source
local function calcMult(from, to, angle)
    local sourceAngle = math.deg(Megamod.AngleBetweenVector2(from, to))
    local normalizedSourceAngle = (sourceAngle + 360) % 360
    local diff = ((normalizedSourceAngle - angle + 180) % 360) - 180
    local absDiff = math.abs(diff)
    local exponent = -(absDiff^2) / (2 * ANGLE_LIMIT^2)
    return math.exp(exponent)
end

-- All sources of dimes on the map that are in range
local dimeSources = {}
-- All dimensional leaks on the map that are in range
local leakSources = {}
-- Defines the lines around you
local lines = {}
for i = LINE_ANGLES, 360, LINE_ANGLES do
    table.insert(lines, {
        i, -- 1
        0, -- 2
        0, -- 3
        0, -- 4
        0, -- 5
        0, -- 6
    })
end

Networking.Receive("mm_leak", function(message)
    if not Character.Controlled then return end
    local amount = message.ReadUInt32()
    local newLeakSources = {}
    for i = 1, amount do
        local id = message.ReadUInt32()
        for hull in Hull.HullList do
            if hull.ID == id then
                local dist = Vector2.Distance(Character.Controlled.WorldPosition, hull.WorldPosition)
                if dist <= RANGE then
                    table.insert(newLeakSources, hull)
                end
                break
            end
        end
    end
    leakSources = newLeakSources
end)

-- Message from the server indicating that we should toggle the dime locator
Networking.Receive("mm_dimelocator", function(message)
    local toggle = message.ReadBoolean() -- True = toggle, false = disable
    if toggle then
        Megamod_Client.ToggleDimeLocator(not Megamod_Client.DimeLocatorActive)
    else
        Megamod_Client.ToggleDimeLocator(false)
    end
end)

-- Fairly expensive, as we traverse all of Item.ItemList
local function updateDimeSources()
    if not Character.Controlled then return end
    local newDimeSources = {}
    for item in Item.ItemList do
        if item and tostring(item.Prefab.Identifier) == "mm_dime" then
            local distance = Vector2.Distance(Character.Controlled.WorldPosition, item.WorldPosition)
            if distance <= RANGE then
                table.insert(newDimeSources, item)
            end
        end
    end
    dimeSources = newDimeSources
end

local function draw(ptable)
    if not Character.Controlled then return end
    local from = Character.Controlled.AnimController.MainLimb.WorldPosition
    for line in lines do
        -- angle (degrees) = line[1]
        -- currentWave = line[2]
        -- nextWave = line[3]
        -- lerp = line[4]
        -- update timer = line[5]
        -- mult = line[6]

        --[[local direction = math.random() <= 0.5
        if direction then
            line[1] = line[1] + math.random()
        else
            line[1] = line[1] - math.random()
        end]]

        line[5] = line[5] - 1
        if line[5] <= 0 then
            line[5] = 10
            local mults = {}
            local roots = {}
            for dimeSource in dimeSources do
                if dimeSource.ParentInventory then
                    local root = dimeSource.GetRootInventoryOwner()
                    -- Ignore dimes that we are carrying
                    if root == Character.Controlled then
                        goto continue
                    end
                    -- Ignore multiple dimes in a single root inventory
                    for inventory in roots do
                        if root == inventory then
                            goto continue
                        end
                    end
                    table.insert(roots, root)
                end
                do
                    local v2 = dimeSource.WorldPosition
                    local distMult = Megamod.Normalize(Vector2.Distance(from, v2), RANGE, 0)
                    if distMult < 0 then distMult = 0 end
                    local angleMult = calcMult(from, v2, line[1])
                    table.insert(mults, (angleMult * distMult) * HIT_STRENGTH + 1)
                end
                ::continue::
            end
            for leakSource in leakSources do
                local v2 = leakSource.WorldPosition
                local distMult = Megamod.Normalize(Vector2.Distance(from, v2), RANGE, 0)
                if distMult < 0 then distMult = 0 end
                local angleMult = calcMult(from, v2, line[1])
                table.insert(mults, (angleMult * distMult) * HIT_STRENGTH + 1)
            end
            local sourceMult = 1
            for mult in mults do
                if mult > sourceMult then sourceMult = mult end
            end
            line[6] = sourceMult
        end

        line[4] = line[4] + LERP_AMOUNT
        if line[4] >= 1 then line[4] = 0 end
        if line[2] == line[3] then line[3] = math.random(WAVE) + math.random() end
        line[2] = Megamod.Lerp(line[2], line[3], line[4])

        local INNER2 = INNER + line[2]
        local OUTER2 = OUTER + line[2] * line[6]
        if OUTER2 < INNER2 then OUTER2 = INNER2 end
        local inner = Megamod.FunnyMaths(from, line[1], INNER2)
        local outer = Megamod.FunnyMaths(from, line[1], OUTER2)
        local alpha = math.min(255, math.random(50, 65) * line[6])
        GUI.DrawLine(
                ptable["spriteBatch"],
                Megamod.WorldToScreen(inner), Megamod.WorldToScreen(outer),
                Color(255, 0, 255, alpha),
                0, 1
            )
    end
end

Megamod_Client.DimeLocatorActive = false

function Megamod_Client.ToggleDimeLocator(toggle)
    if toggle and not Megamod_Client.DimeLocatorActive then
        Megamod_Client.DimeLocatorActive = true
        updateDimeSources() -- Update once immediately
        local timer = 0
        Hook.Patch("Megamod.DimeLocator", "Barotrauma.GUI", "Draw", function(instance, ptable)
            draw(ptable)
            if timer >= UPDATE_TIMER then
                timer = 0
                updateDimeSources()
            else
                timer = timer + 1
            end
        end)
    elseif not toggle and Megamod_Client.DimeLocatorActive then
        Megamod_Client.DimeLocatorActive = false
        Hook.RemovePatch("Megamod.DimeLocator", "Barotrauma.GUI", "Draw", Hook.HookMethodType.Before)
    end
end

local function disableLoop()
    if not Game.RoundStarted then return end
    if Megamod_Client -- ???
    and Megamod_Client.DimeLocatorActive
    and (not Character.Controlled
    or Character.Controlled.IsDead
    or Character.Controlled.Vitality < 0) then
        Megamod_Client.ToggleDimeLocator(false)
    end
    Timer.Wait(function()
        disableLoop()
    end, 1000)
end
if Game.RoundStarted then disableLoop() end -- Restart the loop if we reload CL Lua midround
Hook.Add("roundStart", "Megamod.Client.RoundStartDimeLocator", function()
    disableLoop()
end)
Hook.Add("roundEnd", "Megamod.Client.RoundEnd", function()
    Megamod_Client.ToggleDimeLocator(false)
end)
