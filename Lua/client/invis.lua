-- Invisibility stuff

local INVIS_RATE = 0.008
local OFFSET_INCREASE = 0.75

local invis = {}

function Megamod_Client.ToggleInvis(char, bool)
    if not char then return end
    if bool then
        if not invis[char] then
            invis[char] = {
                isInvis = true,
                limbs = {},
            }
            local offset = 1
            for limb in char.AnimController.Limbs do
                offset = offset + OFFSET_INCREASE
                invis[char].limbs[limb] = { offset = offset, current = 1 }
            end
        elseif invis[char] and invis[char].isInvis == false then
            invis[char].isInvis = true
        end
        -- Do nothing if we want to set it invis and it's already invis
    else
        if invis[char] then
            invis[char].isInvis = false
        end
    end
end

Hook.Add("think", "Megamod.Invis1", function()
    local removeKeys = {}
    for char, tbl in pairs(invis) do
        if tbl.isInvis then
            for _, limbTbl in pairs(tbl.limbs) do
                if limbTbl.current > 0 then
                    limbTbl.current = limbTbl.current - (INVIS_RATE * limbTbl.offset)
                else
                    limbTbl.current = 0
                end
            end
        else
            for _, limbTbl in pairs(tbl.limbs) do
                if limbTbl.current < 1 then
                    limbTbl.current = limbTbl.current + (INVIS_RATE * limbTbl.offset)
                else
                    limbTbl.current = 1
                end
            end
            local allOpaque = true
            for _, limbTbl in pairs(tbl.limbs) do
                if limbTbl.current < 1 then
                    allOpaque = false
                    break
                end
            end
            if allOpaque then
                table.insert(removeKeys, char)
            end
        end
    end
    for removeKey in removeKeys do
        invis[removeKey] = nil
    end
end)

local function multiplyColorByScale(color, scale)
    return Color(color.R * scale, color.G * scale, color.B * scale, color.A * scale)
end
LuaUserData.MakeFieldAccessible(Descriptors["Barotrauma.Limb"], "burnOverLayStrength")
Hook.Patch("Megamod.Invis2", "Barotrauma.Limb", "Draw", function(instance, ptable)
    if not invis[instance.character] then return end
    local limbTbl = invis[instance.character].limbs[instance]
    local scaler = limbTbl.current

    scaler = Megamod.Clamp(scaler, 0, 1)

    local spriteParams = instance.Params.GetSprite()
    if not spriteParams then return end

    local c = multiplyColorByScale(Color.White, scaler * 0.4)

    ptable["overrideColor"] = Color(c.R, c.G, c.B, 255 * scaler)
end, Hook.HookMethodType.Before)

Hook.Add("roundEnd", "Megamod.Invis.RoundEnd", function()
    invis = {}
end)
