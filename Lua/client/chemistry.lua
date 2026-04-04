Megamod_Client.Chemistry = {
    ContainersItems = {},
    ContainersCharacters = {},
}
local chm = Megamod_Client.Chemistry

local chmUtil = require 'shared.chem shared'
for k, v in pairs(chmUtil) do
    chm[k] = v
end

chm.ItemContainerStats = {
    mm_syringe = true,
}
chm.CharacterContainerStats = {
    Human = true,
}

local tempItems = {}
local tempCharacters = {}

local function updateCharacterContainerTable(char)
    if char
    and not char.Removed
    and not char.IsDead
    and not chm.ContainersCharacters[char] then
        local stats = chm.CharacterContainerStats[tostring(char.SpeciesName)]
        if not stats then return end
        print("CHEM: Added " .. tostring(char.DisplayName) .. " to temp character list.") -- #DEBUG#
        table.insert(tempCharacters, char)
    end
end
Hook.Add("character.created", "Megamod.Chemistry.CharacterCreated", updateCharacterContainerTable)

local function updateItemContainerTable(item)
    local stats = chm.ItemContainerStats[tostring(item.Prefab.Identifier)]
    if not stats then return end
    print("CHEM: Added " .. tostring(item.Prefab.Identifier) .. " to temp item list.") -- #DEBUG#
    table.insert(tempItems, item)
end
Hook.Add("item.created", "Megamod.Chemistry.ItemCreated", updateItemContainerTable)

-- Update item/char list if Lua is reloaded midround
if Game.RoundStarted then
    for item in Item.ItemList do
        updateItemContainerTable(item)
    end
    for char in Character.CharacterList do
        updateCharacterContainerTable(char)
    end
end

local funcs = {
    -- Initial update that tells us all item/character containers
    [1] = function(message)
        
    end,
}
Networking.Receive("mm_chem", function(message)
    local id = message.ReadByte()
    funcs[id](message)
end)

-- We need to know stuff if we reload CL Lua midround
if Game.RoundStarted then
    local msg = Networking.Start("mm_chem")
    msg.WriteByte(1)
    Networking.Send(msg)
end
