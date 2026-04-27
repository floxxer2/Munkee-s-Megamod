Megamod_Client.Chemistry = {}
local chm = Megamod_Client.Chemistry

local chmUtil = require 'utils.chem shared'
for k, v in pairs(chmUtil) do
    chm[k] = v
end

-- Debug script to remove all spawned chem dispensers
-- lua for item in Item.ItemList do if tostring(item.Prefab.Identifier) == 'mm_chemicaldispenser' then Entity.Spawner.AddEntityToRemoveQueue(item) end end

-- Distance that, if we are closer than, we will update this 
local NEAR_DIST = 300

local function concatReagents(container, stats)
    local str = ""
    local total = 0
    local containerTbl = chm.GetContainerTable(container)
    for _, reagentTbl in pairs(containerTbl.SubContainers[1].Reagents) do
        total = total + reagentTbl.Amount
        str = str .. reagentTbl.Name .. " - " .. tostring(reagentTbl.Amount) .. "\n"
    end
    str = str:sub(1, -2)
    if str == "" then
        str = "(No reagents)"
    end
    return total, str
end

local dispenserPatches = {}
local TIMER_BASE = 120
local timer = TIMER_BASE
Hook.Add("think", "Megamod_Client.Chemistry.ChemDispenserUpdate", function()
    if not Game.RoundStarted
    or not Character.Controlled
    or Character.Controlled.IsDead == true then
        return
    end
    timer = timer - 1
    local isUpdateTick = timer <= 0
    if isUpdateTick then
        timer = TIMER_BASE
    end
    if isUpdateTick then
        for tbl in dispenserPatches do
            tbl.dist = Vector2.Distance(Character.Controlled.WorldPosition, tbl.dispenser.WorldPosition)
        end
    end

    for tbl in dispenserPatches do
        -- Update every 2 seconds, or every tick if we are very close to the dispenser
        if isUpdateTick or tbl.dist < NEAR_DIST then
            
        end
    end
end)

local function patchDispenser(instance)
    -- Need to wait for other stuff to be initialized
    Timer.Wait(function()
        local dispenser = instance.Item

        local frame = instance.GuiFrame
        
    end, 1)
end
Hook.Patch("Barotrauma.Items.Components.CustomInterface", "CreateGUI", function(instance, ptable)
    if instance.originalElement.GetAttributeString("type", "") ~= "chemicaldispenser" then
        return
    end
    patchDispenser(instance)
end)
-- Find special items (i.e. chem dispensers) if we reload CL Lua midround
if Game.RoundStarted then
    for item in Item.ItemList do
        if tostring(item.Prefab.Identifier) == "mm_chemicaldispenser" then
            patchDispenser(item.GetComponentString("CustomInterface"))
        end
    end
end

local function readSubContainers(msg, stats)
    local subContainers = {}
    local amountSubContainers = tonumber(msg.ReadByte())
    for i = 1, amountSubContainers do
        local capacity = stats.SubContainers[i].Capacity
        local temperatureK = tonumber(msg.ReadSingle())
        local site = stats.SubContainers[i].Site
        local amountReagents = tonumber(msg.ReadUInt32())
        local reagents = {}
        for v = 1, amountReagents do
            local reagentID = msg.ReadString()
            local reagentAmount = tonumber(msg.ReadSingle())
            reagents[reagentID] = chm.CreateReagent(chm.Reagents[reagentID], reagentAmount)
        end
        local amountReactions = tonumber(msg.ReadUInt32())
        local reactions = {}
        for j = 1 , amountReactions do
            local reactionID = msg.ReadString()
            local stats
            for reaction in chm.Reactions do
                if reaction.ID == reactionID then
                    stats = reaction
                    break
                end
            end
            if not stats then
                error("Could not find reaction stats for reaction ID: " .. tostring(reactionID))
            end
            table.insert(reactions, {
                ID = reactionID,
                ReqTempK = stats.ReqTempK,
                AffectedByStabilizine = stats.AffectedByStabilizine,
                AllowedSites = stats.AllowedSites,
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
    -- General update, could be 1 item/char, could be all items/chars
    [1] = function(msg)
        local numChars = tonumber(msg.ReadUInt64())
        for i = 1, numChars do
            local charID = tonumber(msg.ReadUInt64())
            local char
            for possibleChar, _ in pairs(chm.ContainersCharacters) do
                if possibleChar.ID == charID then
                    char = possibleChar
                    break
                end
            end
            -- If character wasn't in character containers list, search full character list
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
            local stats = chm.CharacterContainerStats[tostring(char.SpeciesName)]
            chm.ContainersCharacters[char] = {
                SubContainers = readSubContainers(msg, stats)
            }
        end
        local numItems = tonumber(msg.ReadUInt64())
        for i = 1, numItems do
            local itemID = tonumber(msg.ReadUInt64())
            local item
            for possibleItem, _ in pairs(chm.ContainersItems) do
                if possibleItem.ID == itemID then
                    item = possibleItem
                    break
                end
            end
            -- If item wasn't in item containers list, search full item list
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
            local stats = chm.ItemContainerStats[tostring(item.Prefab.Identifier)]
            chm.ContainersItems[item] = {
                SubContainers = readSubContainers(msg, stats)
            }
        end
    end,
}
Networking.Receive("mm_chem", function(msg)
    local id = msg.ReadByte()
    if funcs[id] then
        funcs[id](msg)
    else
        error("No function with ID " .. tostring(id))
    end
end)

Hook.Add("roundEnd", "Megamod_Client.Chemistry.RoundEnd", function()
    chm.ContainersCharacters = {}
    chm.ContainersItems = {}
end)
