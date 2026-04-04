Megamod_Client.Chemistry = {
    ContainersItems = {},
    ContainersCharacters = {},
}
local chm = Megamod_Client.Chemistry

chm.ItemContainerStats = {

}
chm.CharacterContainerStats = {
    
}

local tempItems = {}
local tempCharacters = {}

Hook.Add("character.created", "Megamod.Chemistry.CharacterCreated", function(char)
    if char
    and not char.Removed
    and not char.IsDead
    and not chm.ContainersCharacters[char] then
        local stats = chm.CharacterContainerStats[tostring(char.SpeciesName)]
        if not stats then return end
        print("CHEM: Added " .. tostring(char.DisplayName) .. " to temp character list.") -- #DEBUG#
        table.insert(tempCharacters, char)
    end
end)
Hook.Add("item.created", "Megamod.Chemistry.ItemCreated", function(item)
    local stats = chm.ItemContainerStats[tostring(item.Prefab.Identifier)]
    if not stats then return end
    print("CHEM: Added " .. tostring(item.Prefab.Identifier) .. " to temp item list.") -- #DEBUG#
    table.insert(tempItems, item)
end)

local funcs = {
    -- Update on nearby item/character containers
    [1] = function(message)
        
    end,
}
Networking.Receive("mm_chem", function(message)
    local id = message.ReadByte()
    funcs[id](message)
end)

Hook.Add("think", "Megamod_Client.Chemistry.Think", function()

end)