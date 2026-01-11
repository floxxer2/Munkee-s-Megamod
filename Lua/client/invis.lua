-- Invisibility stuff

--[=[local INVIS_RATE = 0.07 -- IK it's not deltatime'd but who cares
local invisChars = {}
local charTbl = {}

-- This prevents reloading CL Lua to see invisible characters
for char in Character.CharacterList do
    if char.InvisibleTimer > 0 then
        charTbl[char] = {}
        for limb in char.AnimController.Limbs do
            charTbl[char][limb] = 1
        end
    end
end

do
    local TIMER_BASE = 10
    local timer = 10
    -- Check all characters every 0.1 seconds to see if they're going invisible
    Hook.Add("think", "Megamod.Invis1", function()
        timer = timer - 1
        if timer <= 0 then
            timer = TIMER_BASE
            for char in Character.CharacterList do
                if char and not char.IsDead and char.InvisibleTimer > 0 and not charTbl[char] then
                    table.insert(invisChars, char)
                end
            end
        end
    end)
end
-- Update invisible characters (Smoothly transition opaque / transparent when meant to be invisible)
Hook.Add("think", "Megamod.Invis2", function()
    local removeKeys = {}
    for k, char in pairs(invisChars) do
        if char and not char.IsDead then
            local isInvis = char.InvisibleTimer > 0
            if isInvis then
                if not charTbl[char] then
                    charTbl[char] = {}
                    for limb in char.AnimController.Limbs do
                        charTbl[char][limb] = 0
                    end
                else
                    for limb, val in pairs(charTbl[char]) do
                        if val < 1 then
                            charTbl[char][limb] = charTbl[char][limb] + INVIS_RATE
                        else
                            charTbl[char][limb] = 1
                        end
                    end
                end
            elseif not isInvis and charTbl[char] then
                -- Become opaque again
                for limb, val in pairs(charTbl[char]) do
                    if val > 0 then
                        charTbl[char][limb] = charTbl[char][limb] - INVIS_RATE
                    else
                        charTbl[char] = nil
                        table.insert(removeKeys, k)
                        break
                    end
                end
            end
        else
            table.insert(removeKeys, k)
        end
    end
    for removeKey in removeKeys do
        table.remove(invisChars, removeKey)
    end
end)
-- Remove charTbl if the character is disabled
-- Also, keep drawing even if meant to be invisible, as we fade in/out
Hook.Patch("Megamod.Invis3", "Barotrauma.Character", "Draw", function(instance, ptable)
    ptable.PreventExecution = true -- Character.Draw() is simple enough to just override completely
    if not instance.Enabled then
        charTbl[instance] = nil
        return
    end
    instance.AnimController.Draw(ptable["spriteBatch"], ptable["cam"])
end, Hook.HookMethodType.Before)

--[[local function multiplyColorByScale(color, scale)
    return Color(color.R * scale, color.G * scale, color.B * scale, color.A * scale)
end
local function multiplyColorByColor(color1, color2)
    return Color(
        math.floor(color1.R * color2.R / 255),
        math.floor(color1.G * color2.G / 255),
        math.floor(color1.B * color2.B / 255),
        math.floor(color1.A * color2.A / 255)
    )
end
LuaUserData.MakeFieldAccessible(Descriptors["Barotrauma.Limb"], "burnOverLayStrength")]]
Hook.Patch("Megamod.Invis4", "Barotrauma.Limb", "Draw", function(instance, ptable)
    if not charTbl[instance.character] then return end
    local scaler = charTbl[instance.character][instance]
    if scaler < 0 then return end -- <0 = just got damaged, don't draw as invis

    --[[local ogColor
    local spriteParams = instance.Params.GetSprite()
    if not spriteParams then return end
    local burn
    if spriteParams.IgnoreTint then
        burn = 0
    else
        burn = instance.burnOverLayStrength
    end
    local brightness = math.max(1 - burn, 0.2)
    local tintedColor = spriteParams.Color
    if not spriteParams.IgnoreTint then
        tintedColor = multiplyColorByColor(tintedColor, instance.ragdoll.RagdollParams.Color)
        if instance.character and instance.character.Info then
            tintedColor = multiplyColorByColor(tintedColor, instance.character.Info.Head.SkinColor)
        end
        if instance.character.CharacterHealth.FaceTint.A > 0 and instance.type == LimbType.Head then
            tintedColor = Color.Lerp(tintedColor, instance.character.CharacterHealth.FaceTint.Opaque(), instance.character.CharacterHealth.FaceTint.A / 255.0)
        end
        if instance.character.CharacterHealth.BodyTint.A > 0 then
            tintedColor = Color.Lerp(tintedColor, instance.character.CharacterHealth.BodyTint.Opaque(), instance.character.CharacterHealth.BodyTint.A / 255.0)
        end
    end
    ogColor = Color(multiplyColorByScale(tintedColor, brightness), tintedColor.A)]]

    local num = (1 - scaler)
    local c = 60 * num
    ptable["overrideColor"] = Color(c, c, c, 255 * num)
end, Hook.HookMethodType.Before)

-- Make things spawning in use the fade animation
Hook.Add("character.created", "Megamod.CharacterCreated", function(char)
    charTbl[char] = {}
    for limb in char.AnimController.Limbs do
        charTbl[char][limb] = 1
    end
end)]=]

-- Make invisibility go away on taking damage
Hook.Add("character.applyDamage", "Megamod.CharacterDamage", function(characterHealth, attackResult, hitLimb, allowStacking)
    local char = characterHealth.Character
    char.InvisibleTimer = 0
    --[[if charTbl[char] then
        for k, _ in pairs(charTbl[char]) do
            charTbl[char][k] = -5
        end
    end]]
end)