Megamod_Client.Chemistry = {
    ContainersItems = {},
    ContainersCharacters = {},
}
local chm = Megamod_Client.Chemistry

local chmUtil = require 'utils.chem shared'
for k, v in pairs(chmUtil) do
    chm[k] = v
end

-- Checked first instead of checking all of Item.ItemList
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

---@param stats table table in chm.Reagents
---@param amount number
---@return table reagent
local function createReagent(stats, amount)
    return {
        Name = stats.Name,
        ID = stats.ID,
        Desc = stats.Desc,
        Type = stats.Type,
        DepletionRate = stats.DepletionRate,
        Effect = stats.Effect,
        Amount = amount,
    }
end

local function readSubContainers(msg)
    local subContainers = {}
    local amountSubContainers = msg.ReadByte()
    for i = 1, amountSubContainers do
        local capacity = msg.ReadUInt64()
        local temperatureK = msg.ReadUInt64()
        local site = msg.ReadString()
        local amountReagents = msg.ReadUInt32()
        local reagents = {}
        for v = 1, amountReagents do
            local reagentID = msg.ReadString()
            local reagentAmount = msg.ReadUInt64()
            reagents[reagentID] = createReagent(chm.Stats[reagentID], reagentAmount)
        end
        local amountReactions = msg.ReadUInt32()
        local reactions = {}
        for j = 1 , amountReactions do
            local reactionID = msg.ReadString()
            local stats = chm.Reactions[reactionID]
            table.insert(reactions, {
                ID = reactionID,
                ReqTempK = stats.ReqTempK,
                AffectedByStabilizine = stats.AffectedByStabilizine,
                AllowedSites = stats.AllowedSitesm,
                Reactants = stats.Reactants,
                Products = stats.Products,
            })
        end
        table.insert(subContainers, {
            Capacity = capacity,
            Reagents = reagents,
            Reactions = reactions,
            TemperatureK = temperatureK,
            Site = site,
        })
    end
    return subContainers
end
local funcs = {
    -- Initial update that tells us all item/character containers
    [1] = function(msg)
        local numChars = msg.ReadUInt64()
        for i = 1, numChars do
            local charID = msg.ReadUInt64()
            local char
            local keyToRemove
            for k, possibleChar in pairs(tempCharacters) do
                if possibleChar.ID == charID then
                    char = possibleChar
                    keyToRemove = k
                    break
                end
            end
            if keyToRemove then
                table.remove(tempCharacters, keyToRemove)
            end
            -- If character wasn't in tempCharacters, search full char list
            if not char then
                for possibleChar in Character.CharacterList do
                    if possibleChar.ID == charID then
                        char = possibleChar
                        break
                    end
                end
            end
            if not char then
                error("Could not find character with ID " .. tostring(charID))
                return
            end
            chm.ContainersCharacters[char] = {
                SubContainers = readSubContainers(msg)
            }
        end
        local numItems = msg.ReadUInt64()
        for i = 1, numItems do
            local itemID = msg.ReadUInt64()
            local item
            local keyToRemove
            for k, possibleItem in pairs(tempItems) do
                if possibleItem.ID == itemID then
                    item = possibleItem
                    keyToRemove = k
                    break
                end
            end
            if keyToRemove then
                table.remove(tempItems, keyToRemove)
            end
            -- If item wasn't in tempItems, search full item list
            if not item then
                for possibleItem in Item.ItemList do
                    if possibleItem.ID == itemID then
                        item = possibleItem
                        break
                    end
                end
            end
            if not item then
                error("Could not find item with ID " .. tostring(itemID))
                return
            end
            chm.ContainersItems[item] = {
                SubContainers = readSubContainers(msg)
            }
        end
    end,
}
Networking.Receive("mm_chem", function(msg)
    local id = msg.ReadByte()
    funcs[id](msg)
end)

-- We need to know stuff if we reload CL Lua midround
if Game.RoundStarted then
    local msg = Networking.Start("mm_chem")
    msg.WriteByte(1)
    Networking.Send(msg)
end
