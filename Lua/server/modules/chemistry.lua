local chm = {}

-- Allowed variance of the temperature of reactions,
-- in percents (0.1 = 10% more or less of req temp)
local REACTION_TEMP_VARIANCE = 0.1

-- This number gets multiplied to determine how fast
-- reagents deplete when on characters
local BASE_DEPLETION_RATE = 1

local chmUtil = require 'utils.chem shared'
for k, v in pairs(chmUtil) do
    chm[k] = v
end

---@param stats table table in chm.Reagents
---@param amount number
---@return table reagent
function chm.CreateReagent(stats, amount)
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

-- Every item that can hold reagents
chm.ContainersItems = {}
-- Every character that can hold reagents (currently only humans)
chm.ContainersCharacters = {}

---@param container Barotrauma.Character|Barotrauma.Item
---@param id string the id of the reagent
---@param amount number the amount to add
---@param subContainer integer defaults to 1
---@return number actualInput returns what SetReagent returns
function chm.AddReagent(container, id, amount, subContainer)
    subContainer = subContainer or 1
    if subContainer <= 0 or not (math.ceil(subContainer) == subContainer) then
        print("CHEMISTRY - WARNING: AddReagent called with invalid subContainer.")
        return
    end
    local reagent = chm.GetReagentInSubContainer(container, id, 0, subContainer)
    if reagent ~= false and reagent.Amount > 0 then
        amount = reagent.Amount + amount
    end
    return chm.SetReagent(container, id, amount, subContainer)
end

---@param container Barotrauma.Character|Barotrauma.Item
---@param id string the id of the reagent
---@param amount number the number to set the reagent's amount to
---@param subContainer integer defaults to 1
---@return number actualInput desired amount can be set lower if container is filled
---@return boolean reagentDeleted will delete reagent table if amount goes <= 0
function chm.SetReagent(container, id, amount, subContainer)
    local reagentStats = chm.Reagents[id]
    if not reagentStats then
        Megamod.Error("CHEMISTRY: SetReagent called with invalid id.")
        return
    end
    if type(amount) ~= "number" then
        Megamod.Error("CHEMISTRY: SetReagent called with invalid amount.")
    end
    local containerTbl = chm.GetContainerTable(container)
    subContainer = subContainer or 1
    if subContainer <= 0 or not (math.ceil(subContainer) == subContainer) then
        local errorStr = "CHEMISTRY - WARNING: SetReagent called with invalid subContainer."
        if #containerTbl.SubContainers == 1 then
            print(errorStr .. " Using default subcontainer 1.")
            subContainer = 1
        else -- Don't use subcontainer 1 if there are multiple subcontainers
            print(errorStr .. " Cancelling.")
            return
        end
    end
    local reagentTbl = containerTbl.SubContainers[subContainer].Reagents[id]
    local cap = containerTbl.SubContainers[subContainer].Capacity
    local totalAmount = amount
    for reagent in chm.GetAllReagents(container) do
        if reagent.ID == id then
            -- This is the reagent we are changing, we use the amount we will set it to
            -- (already applied by totalAmount being initialized as amount)
        else
            totalAmount = totalAmount + reagent.Amount
        end
    end
    -- If the total would go over the cap,
    -- try to set the amount we will change the reagent to
    -- to add up to be equal to the cap
    if totalAmount > cap then
        if totalAmount - amount <= cap then
            amount = cap - (totalAmount - amount)
        else -- Container was already over the cap?
            return
        end
    end
    -- Reagent has 0 amount, remove it
    if amount <= 0 then
        containerTbl.SubContainers[subContainer].Reagents[id] = nil
        return amount, true
    end
    -- Reagent was already there
    if reagentTbl then
        reagentTbl.Amount = amount
    else -- Reagent needs to be created
        local stats = chm.Reagents[id]
        containerTbl.SubContainers[subContainer].Reagents[id] = chm.CreateReagent(stats, amount)
    end
    -- We might have changed the desired amount to be lower, so return the new amount
    return amount, false
end

---@param container Barotrauma.Character|Barotrauma.Item
---@param id string the id of the reagent
---@param defaultAmount number default return value if reagent not found
---@param subContainerID integer  defaults to 1
---@return table|boolean reagent false if reagent not found
function chm.GetReagentInSubContainer(container, id, defaultAmount, subContainerID)
    subContainerID = subContainerID or 1
    if subContainerID <= 0 or not (math.ceil(subContainerID) == subContainerID) then
        print("CHEMISTRY - WARNING: GetReagent called with invalid subContainer.")
        return
    end
    local containerTbl = chm.GetContainerTable(container)
    local subContainerTbl = containerTbl.SubContainers[subContainerID]
    for reagent in subContainerTbl do
        if reagent.ID == id then
            return reagent
        end
    end
    return false
end

---@param container Barotrauma.Character|Barotrauma.Item
---@return table reagents array type with the reagent tables in all subcontainers
function chm.GetAllReagents(container)
    local reagents = {}
    local containerTbl = chm.GetContainerTable(container)
    for subContainer in containerTbl.SubContainers do
        for _, tbl in pairs(subContainer.Reagents) do
            if tbl.Amount > 0 then
                table.insert(reagents, tbl)
            end
        end
    end
    return reagents
end

---@param container Barotrauma.Character|Barotrauma.Item
---@param subContainerID integer
---@return table reagents array type with the reagent tables
function chm.GetAllReagentsInSubContainer(container, subContainerID)
    local reagents = {}
    subContainerID = subContainerID or 1
    if subContainerID <= 0 or not (math.ceil(subContainerID) == subContainerID) then
        print("CHEMISTRY - WARNING: GetAllReagentsInSubContainer called with invalid subContainerID.")
        return
    end
    local containerTbl = chm.GetContainerTable(container)
    local subContainerTbl = containerTbl.SubContainers[subContainerID]
    if not subContainerTbl then
        Megamod.Error("No subcontainer table of ID " .. tostring(subContainerID) .. " for container " .. tostring(container))
        return
    end
    for _, tbl in pairs(subContainerTbl.Reagents) do
        if tbl.Amount > 0 then
            table.insert(reagents, tbl)
        end
    end
    return reagents
end

-- Send an amount of reagents from one (sub)container to another
---@param container1 Barotrauma.Character|Barotrauma.Item
---@param subContainer1ID integer
---@param container2 Barotrauma.Character|Barotrauma.Item
---@param subContainer2ID integer
---@param amountToTransfer number
function chm.TransferReagents(container1, subContainer1ID, container2, subContainer2ID, amountToTransfer)
    local container1Tbl = chm.GetContainerTable(container1)
    subContainer1ID = subContainer1ID or 1
    if subContainer1ID <= 0 or not (math.ceil(subContainer1ID) == subContainer1ID) then
        print("CHEMISTRY - WARNING: TransferReagents called with invalid subContainer1ID.")
        return
    end
    local subContainer1Tbl = container1Tbl.SubContainers[subContainer1ID]
    local container2Tbl = chm.GetContainerTable(container2)
    subContainer2ID = subContainer2ID or 1
    if subContainer2ID <= 0 or not (math.ceil(subContainer2ID) == subContainer2ID) then
        print("CHEMISTRY - WARNING: TransferReagents called with invalid subContainer2ID.")
        return
    end
    local subContainer2Tbl = container2Tbl.SubContainers[subContainer2ID]

    local reagents1 = chm.GetAllReagentsInSubContainer(container1, subContainer1ID)
    local totalAmount1 = 0
    for reagent in reagents1 do
        totalAmount1 = totalAmount1 + reagent.Amount
    end
    local reagents2 = chm.GetAllReagentsInSubContainer(container2, subContainer2ID)
    local totalAmount2 = 0
    for reagent in reagents2 do
        totalAmount2 = totalAmount2 + reagent.Amount
    end

    -- Percent of each reagent in container1 that we want to transfer
    local percentToTransfer = amountToTransfer / totalAmount1
    percentToTransfer = Megamod.Clamp(percentToTransfer, 0, 1)

    -- Available capacity in container2
    local availableCapacity = subContainer2Tbl.Capacity - totalAmount2
    local maxTransferAmount = math.min(amountToTransfer, availableCapacity)

    -- Adjust percentToTransfer based on available capacity
    if maxTransferAmount < amountToTransfer then
        percentToTransfer = maxTransferAmount / totalAmount1
        percentToTransfer = Megamod.Clamp(percentToTransfer, 0, 1)
    end

    -- Can't transfer any reagents, don't try
    if percentToTransfer <= 0 then return end

    local reagentAmounts = {}
    for reagent in reagents1 do
        reagentAmounts[reagent.ID] = reagent.Amount * percentToTransfer
    end

    for reagentID, reagentAmount in pairs(reagentAmounts) do
        -- Remove the reagent from the first container
        chm.AddReagent(container1, reagentID, reagentAmount * -1, subContainer1ID)
        -- Add the reagent to the second container
        chm.AddReagent(container2, reagentID, reagentAmount, subContainer2ID)
    end
end

---@param container Barotrauma.Character|Barotrauma.Item
---@return table
function chm.GetContainerTable(container)
    local containerTbl
    if LuaUserData.IsTargetType(container, "Barotrauma.Item") then
        containerTbl = chm.ContainersItems[container]
        if not containerTbl and chm.ItemContainerStats[tostring(container.Prefab.Identifier)] then
            print("CHEMISTRY: GetContainerTable - Container table not initalized for " .. tostring(container) .. ", correcting...") -- #DEBUG#
            chm.UpdateItemContainerTable(container)
            containerTbl = chm.ContainersItems[container]
        end
    elseif LuaUserData.IsTargetType(container, "Barotrauma.Character") then
        containerTbl = chm.ContainersCharacters[container]
        if not containerTbl and chm.CharacterContainerStats[tostring(container.SpeciesName)] then
            print("CHEMISTRY: GetContainerTable - Container table not initalized for " .. tostring(container) .. ", correcting...") -- #DEBUG#
            chm.UpdateCharacterContainerTable(container)
            containerTbl = chm.ContainersCharacters[container]
        end
    else
        Megamod.Error("GetContainerTable called with invalid container type.")
        return
    end
    return containerTbl
end


---@param container Barotrauma.Character|Barotrauma.Item
---@param subContainerID number
function chm.TickReactions(container, subContainerID)
    local containerTbl = chm.GetContainerTable(container)
    local subContainerTbl = containerTbl.SubContainers[subContainerID]
    local reagents = chm.GetAllReagentsInSubContainer(container, subContainerID)
    for reaction in chm.Reactions do
        -- Don't check to add a reaction that is already occuring
        local reactionActive = false
        for activeReaction in containerTbl.SubContainers[subContainerID].Reactions do
            if activeReaction.ID == reaction.ID then
                reactionActive = true
            end
        end
        if not reactionActive then
            local subContainerTemp = subContainerTbl.TemperatureK
            -- Check if temperature is in valid range
            if subContainerTemp >= reaction.ReqTempK * (1 - REACTION_TEMP_VARIANCE)
            and subContainerTemp <= reaction.ReqTempK * (1 + REACTION_TEMP_VARIANCE) then
                -- Check if we are in a valid site (item, skin, etc)
                local isValidSite = false
                local subContainerSite = containerTbl.SubContainers[subContainerID].Site
                for validSite in reaction.AllowedSites do
                    if subContainerSite == validSite then
                        isValidSite = true
                        break
                    end
                end
                if isValidSite then
                    -- Check if we have the reactants
                    local missingReactants = 0
                    for reactantID, _ in pairs(reaction.Reactants) do
                        missingReactants = missingReactants + 1
                        for reagent in reagents do
                            if reagent.ID == reactantID then
                                missingReactants = missingReactants - 1
                                break
                            end
                        end
                    end
                    if missingReactants == 0 then
                        table.insert(subContainerTbl.Reactions, {
                            ID = reaction.ID,
                            ReqTempK = reaction.ReqTempK,
                            AffectedByStabilizine = reaction.AffectedByStabilizine,
                            AllowedSites = reaction.AllowedSites,
                            Reactants = reaction.Reactants,
                            Products = reaction.Products,
                        })
                    end
                end
            end
        end
    end
end

---@param container Barotrauma.Character|Barotrauma.Item
---@param subContainerID number
-- Tick Effect() of reagents
function chm.TickEffects(container, subContainerID)
    local containerTbl = chm.GetContainerTable(container)
    local subContainer = containerTbl.SubContainers[subContainerID]
    local site = subContainer.Site
    if site and site ~= "extra" then
        for _, reagentTbl in pairs(subContainer.Reagents) do
            reagentTbl:Effect(container, site)
        end
    end
end

-- Tick reagents depleting on characters
function chm.TickDepletion(container, subContainerID)
    local stats = chm.CharacterContainerStats[tostring(container.SpeciesName)]
    local containerTbl = chm.GetContainerTable(container)
    local subContainer = containerTbl.SubContainers[subContainerID]
    for reagentID, reagentTbl in pairs(subContainer.Reagents) do
        local depletionMult = 1 * reagentTbl.DepletionRate * stats.DepletionRate
        local newAmount = reagentTbl.Amount - (BASE_DEPLETION_RATE * depletionMult) * chm.DeltaTime
        -- Don't call SetReagent if we don't have to
        if newAmount ~= reagentTbl.Amount then
            chm.SetReagent(container, reagentID, newAmount, subContainerID)
            -- We don't care if SetReagent reduces the
            -- amount depleted for some reason
        end
    end
end

local function tickContainerType(masterTable)
    for container, containertbl in pairs(masterTable) do
        for subContainerID, subContainerTbl in pairs(containertbl.SubContainers) do
            local hasReagents = false
            for _, _ in pairs(subContainerTbl.Reagents) do
                hasReagents = true -- At least one entry
                break
            end
            -- We don't need to tick empty containers
            if hasReagents then
                chm.TickEffects(container, subContainerID)
                chm.TickReactions(container, subContainerID)
                if LuaUserData.IsTargetType(container, "Barotrauma.Character") then
                    chm.TickDepletion(container, subContainerID)
                end
            end
        end
    end
end

local TIMER_BASE = 120
local timer = TIMER_BASE
chm.DeltaTime = TIMER_BASE / 60
function chm.TickMaster()
    if not Game.RoundStarted then return end
    timer = timer - 1
    if timer <= 0 then
        timer = TIMER_BASE
        tickContainerType(chm.ContainersItems)
        tickContainerType(chm.ContainersCharacters)
    end
end
Hook.Add("think", "Megamod.Chemistry.Think", chm.TickMaster)

local function writeSubContainers(msg, containerTbl)
    msg.WriteByte(#containerTbl.SubContainers)
    for subContainer in containerTbl.SubContainers do
        msg.WriteUInt64(subContainer.Capacity)
        local amountReagents = 0
        for _, _ in pairs(subContainer.Reagents) do
            amountReagents = amountReagents + 1
        end
        msg.WriteUInt32(amountReagents)
        for reagentID, reagentTbl in pairs(subContainer.Reagents) do
            msg.WriteString(reagentID)
            msg.WriteString(reagentTbl.Name)
            msg.WriteString(reagentTbl.Desc)
            msg.WriteString(reagentTbl.Type)
            msg.WriteUInt32(reagentTbl.DepletionRate)
            -- Ignore Effect field
            msg.WriteUInt64(reagentTbl.Amount)
        end
        msg.WriteUInt32(#subContainer.Reactions)
        for reactionTbl in subContainer.Reactions do
            msg.WriteString(reactionTbl.ID)
            msg.WriteUInt64(reactionTbl.ReqTempK)
            msg.WriteBoolean(reactionTbl.AffectedByStabilizine)
            local amountAllowedSites = 0
            for _, _ in pairs(reactionTbl.AllowedSites) do
                amountAllowedSites = amountAllowedSites + 1
            end
            msg.WriteByte(amountAllowedSites)
            for site, _ in pairs(reactionTbl.AllowedSites) do
                msg.WriteString(site)
            end
            local amountReactants = 


            ID = reaction.ID,
            ReqTempK = reaction.ReqTempK,
            AffectedByStabilizine = reaction.AffectedByStabilizine,
            AllowedSites = reaction.AllowedSites,
            Reactants = reaction.Reactants,
            Products = reaction.Products,
        end
    end
end
local funcs = {
    -- We need to tell a client about all item/character containers
    [1] = function(_, sender)
        local msg = Networking.Start("mm_chem")
        msg.WriteByte(1)

        local numChars = 0
        for _, _ in pairs(chm.ContainersCharacters) do
            numChars = numChars + 1
        end
        msg.WriteUInt64(numChars)
        for char, charTbl in pairs(chm.ContainersCharacters) do
            msg.WriteUInt64(char.ID)
            writeSubContainers(msg, charTbl)
        end

        local numItems = 0
        for _, _ in pairs(chm.ContainersItems) do
            numItems = numItems + 1
        end
        msg.WriteUInt64(numItems)
        for item, itemTbl in pairs(chm.ContainersItems) do
            msg.WriteUInt64(item.ID)
            writeSubContainers(itemTbl)
        end

        Networking.Send(msg, sender)
    end,
    -- Transfer reagents between two containers in inventory
    [2] = function(message, sender)
        local container1ID = message.ReadUInt64()
        local subContainer1ID = message.ReadByte()
        local container2ID = message.ReadUInt64()
        local subContainer2ID = message.ReadByte()
        local amount = message.ReadUInt64()
        local container1, container2
        for container, _ in pairs(chm.ContainersItems) do
            if container1 ~= nil
            and container2 ~= nil then
                break
            end
            if not container1 and container.ID == container1ID then
                container1 = container
            end
            -- Don't use if-else because container 1/2 could be the same item
            if not container2 and container.ID == container2ID then
                container2 = container
            end
        end
        if not container1 or not container2 then
            Megamod.Error("Invalid container 1/2 IDs.")
            return
        end
        if container1.ParentInventory ~= container2.ParentInventory then
            Megamod.Error("Containers were not in the same inventory.")
            return
        end
        chm.TransferReagents(container1, subContainer1ID, container2, subContainer2ID, Megamod.Round(amount, 2))
    end,
}
Networking.Receive("mm_chem", function(message, sender)
    if not sender.Character
    or sender.Character.IsDead == true
    or sender.Character.Vitality <= -5 then
        Megamod.Log("Client '" .. tostring(sender.Name) .. "' sent an invalid chemistry message.", true)
        return
    end
    local id = message.ReadByte()
    funcs[id](message, sender)
end)

function chm.UpdateCharacterContainerTable(char)
    if char
    and not char.Removed
    and not char.IsDead
    and not chm.ContainersCharacters[char] then
        local stats = chm.CharacterContainerStats[tostring(char.SpeciesName)]
        if not stats then return end
        print("CHEM: Added " .. tostring(char.DisplayName) .. " to character containers list.") -- #DEBUG#
        chm.ContainersCharacters[char] = {
            SubContainers = {},
        }
        for k, subContainer in pairs(stats.SubContainers) do
            local subContainerTable = {
                Capacity = subContainer.Capacity,
                Reagents = {},
                Reactions = {},
                TemperatureK = stats.InternalTemperatureK,
                Site = subContainer.Site,
            }
            -- Add the subContainer here so that SetReagent() will see it
            table.insert(chm.ContainersCharacters[char].SubContainers, subContainerTable)
            for reagentID, amount in pairs(subContainer.StartingReagents) do
                chm.SetReagent(char, reagentID, amount, k)
            end
        end
    end
end
Hook.Add("character.created", "Megamod.Chemistry.CharacterCreated", chm.UpdateCharacterContainerTable)

function chm.UpdateItemContainerTable(item)
    local stats = chm.ItemContainerStats[tostring(item.Prefab.Identifier)]
    if not stats then return end
    print("CHEM: Added " .. tostring(item.Prefab.Identifier) .. " to item containers list.") -- #DEBUG#
    chm.ContainersItems[item] = {
        SubContainers = {},
    }
    for subContainer in stats.SubContainers do
        table.insert(chm.ContainersItems[item].SubContainers, {
            Capacity = subContainer.Capacity,
            Reagents = {},
            Reactions = {},
            TemperatureK = 295.372,
            Site = subContainer.Site,
        })
    end
end
Hook.Add("item.created", "Megamod.Chemistry.ItemCreated", chm.UpdateItemContainerTable)

-- Update item/char list if Lua is reloaded midround
if Game.RoundStarted then
    for item in Item.ItemList do
        chm.UpdateItemContainerTable(item)
    end
    for char in Character.CharacterList do
        chm.UpdateCharacterContainerTable(char)
    end
end

function chm.Reset()
    chm.ContainersItems = {}
    chm.ContainersCharacters = {}
    timer = 0
end
Hook.Add("roundEnd", "Megamod.Chemistry.End", chm.Reset)

return chm
