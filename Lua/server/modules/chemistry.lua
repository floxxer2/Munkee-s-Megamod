local chm = {}

local chmUtil = require 'utils.chem shared'
for k, v in pairs(chmUtil) do
    chm[k] = v
end

-- Allowed variance of the temperature of reactions,
-- in percents (0.1 = 10% more or less of req temp)
local REACTION_TEMP_VARIANCE = 0.1

-- This number gets multiplied to determine how fast
-- reagents deplete when on characters
local BASE_DEPLETION_RATE = 1


Hook.Add("mm.chemistry.itemContainerUse", "Megamod.Chemistry.ItemContainerUse", function(effect, deltaTime, item, targets, worldPosition)
    if not item or not targets then return end
    local target = targets[1]
    if not target
    or not LuaUserData.IsTargetType(target, "Barotrauma.Character")
    or not chm.CharacterContainerStats[tostring(target.SpeciesName)] then
        return
    end
    local containerTbl = chm.GetContainerTable(item)
    chm.TransferReagents(item, 1, target, 1, containerTbl.SubContainers[1].Capacity)
end)


local function writeSubContainers(msg, containerTbl)
    msg.WriteByte(#containerTbl.SubContainers)
    for subContainer in containerTbl.SubContainers do
        msg.WriteSingle(subContainer.TemperatureK)
        local amountReagents = 0
        for _, _ in pairs(subContainer.Reagents) do
            amountReagents = amountReagents + 1
        end
        msg.WriteUInt32(amountReagents)
        for reagentID, reagentTbl in pairs(subContainer.Reagents) do
            msg.WriteString(reagentID)
            msg.WriteSingle(reagentTbl.Amount)
        end
        msg.WriteUInt32(#subContainer.Reactions)
        for reactionTbl in subContainer.Reactions do
            msg.WriteString(reactionTbl.ID)
        end
    end
end

---@param client Barotrauma.Networking.Client nil = send to all clients
---@param items Barotrauma.Item[]
---@param characters Barotrauma.Character[]
function chm.WriteContainerMessage(client, items, characters)
    local msg = Networking.Start("mm_chem")
    msg.WriteByte(1)

    msg.WriteUInt64(#characters)
    for char in characters do
        msg.WriteUInt64(char.ID)
        local charTbl = chm.GetContainerTable(char)
        writeSubContainers(msg, charTbl)
    end

    msg.WriteUInt64(#items)
    for item in items do
        msg.WriteUInt64(item.ID)
        local itemTbl = chm.GetContainerTable(item)
        writeSubContainers(msg, itemTbl)
    end

    if client then
        Networking.Send(msg, client.Connection)
    else
        for client in Client.ClientList do
            Networking.Send(msg, client.Connection)
        end
    end
end

local function checkIsChemDispenser(message, sender)
    local itemID = tonumber(message.ReadUInt64())
    local item
    for container, _ in pairs(chm.ContainersItems) do
        if container.ID == itemID then
            item = container
            break
        end
    end
    if not item then
        Megamod.Error("Could not find item with ID " .. tostring(itemID))
        return false
    end
    if tostring(item.Prefab.Identifier) ~= "mm_chemicaldispenser" then
        Megamod.Error("Item with ID " .. tostring(itemID) .. " is not a chem dispenser.")
        return false
    end
    local dist = Vector2.Distance(item.WorldPosition, sender.Character.WorldPosition)
    if dist > 300 then
        Megamod.Error("Client " .. tostring(sender.Name) .. " tried to use a chem dispenser from out of range.")
        return false
    end
    return item
end

local funcs = {
    -- Client is requesting info on certain containers
    [1] = function(message, sender)
        local numItems = tonumber(message.ReadUInt64())
        local items = {}
        for i = 1, numItems do
            local itemID = tonumber(message.ReadUInt64())
            local foundItem = false
            for item, _ in pairs(chm.ContainersItems) do
                if item.ID == itemID then
                    foundItem = true
                    table.insert(items, item)
                    break
                end
            end
            if not foundItem then
                Megamod.Error("Could not find item with ID " .. tostring(itemID))
            end
        end
        local numChars = tonumber(message.ReadUInt64())
        local characters = {}
        for i = 1, numChars do
            local charID = tonumber(message.ReadUInt64())
            local foundChar = false
            for character, _ in pairs(chm.ContainersCharacters) do
                if character.ID == charID then
                    foundChar = true
                    table.insert(characters, character)
                    break
                end
            end
            if not foundChar then
                Megamod.Error("Could not find character with ID " .. tostring(charID))
            end
        end
        chm.WriteContainerMessage(sender, items, characters)
    end,
    -- Transfer reagents between two containers in inventory
    [2] = function(message, sender)
        local container1ID = tonumber(message.ReadUInt64())
        local subContainer1ID = tonumber(message.ReadByte())
        local container2ID = tonumber(message.ReadUInt64())
        local subContainer2ID = tonumber(message.ReadByte())
        local amount = tonumber(message.ReadSingle())
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
    -- Eject container from chem dispenser
    [3] = function(message, sender)
        local item = checkIsChemDispenser(message, sender)
        if not item then return end
        local containedItem = item.OwnInventory.GetItemAt(0)
        if not containedItem then return end
        local hasSpace = sender.Character.TryPutItemInAnySlot(containedItem)
        if not hasSpace then
            Megamod.SendClientSideMsg(sender, "Need a free hotbar slot", Color(255, 0 ,255, 255), false)
        end
    end,
    -- Add reagent in chem dispenser
    [4] = function(message, sender)
        local item = checkIsChemDispenser(message, sender)
        if not item then return end
        local reagentID = message.ReadString()
        local reagentAmount = tonumber(message.ReadUInt64())
        chm.AddReagent(item, reagentID, reagentAmount, 1)
    end,
    -- Transfer reagents between a chem dispenser's buffer and its contained item
    [5] = function(message, sender)
        local dispenser = checkIsChemDispenser(message, sender)
        if not dispenser then return end
        local containedItem = dispenser.OwnInventory.GetItemAt(0)
        if not containedItem then return end
        -- True = item -> dispenser
        -- False = dispenser -> item
        local direction = message.ReadBoolean()
        local reagentAmount = tonumber(message.ReadSingle())
        if direction then
            chm.TransferReagents(containedItem, 1, dispenser, 1, reagentAmount)
        else
            chm.TransferReagents(dispenser, 1, containedItem, 1, reagentAmount)
        end
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
    if funcs[id] then
        funcs[id](message, sender)
    else
        Megamod.Error("No function with ID " .. tostring(id))
    end
end)

---@param container Barotrauma.Character|Barotrauma.Item
---@param subContainerID number
function chm.TickReactions(container, subContainerID)
    local containerTbl = chm.GetContainerTable(container)
    local subContainerTbl = containerTbl.SubContainers[subContainerID]
    local reagents = chm.GetAllReagentsInSubContainer(container, subContainerID)

    local reactionsToRemove = {}
    -- Tick active reactions
    for k, reactionTbl in pairs(subContainerTbl.Reactions) do
        -- Check if the reaction should stop
        -- Note: The site does not change, so no need to check that
        local subContainerTemp = subContainerTbl.TemperatureK
        if not (subContainerTemp >= reactionTbl.ReqTempK * (1 - REACTION_TEMP_VARIANCE)
        and subContainerTemp <= reactionTbl.ReqTempK * (1 + REACTION_TEMP_VARIANCE)) then
            -- Temperature is invalid, stop reaction
            table.insert(reactionsToRemove, k)
        else
            -- Temperature is valid, continue
            -- Check if we have reactants
            -- Ignore amount of reactant, just need the reactant to be there
            local missingReactants = 0
            for reactantID, _ in pairs(reactionTbl.Reactants) do
                missingReactants = missingReactants + 1
                for reagent in reagents do
                    if reagent.ID == reactantID then
                        missingReactants = missingReactants - 1
                        break
                    end
                end
            end
            if missingReactants > 0 then
                -- We are missing some reactants, stop reaction
                table.insert(reactionsToRemove, k)
            else
                -- We have all reactants, continue
                -- Calculate rate multiplier based on available reactant amounts
                local rateMultiplier = 1
                for reactantID, reactantAmount in pairs(reactionTbl.Reactants) do
                    local reagent = subContainerTbl.Reagents[reactantID]
                    if reagent then
                        local available = reagent.Amount
                        local requiredPerSecond = reactantAmount
                        if requiredPerSecond > 0 then
                            local maxRateForThis = available / requiredPerSecond
                            rateMultiplier = math.min(rateMultiplier, maxRateForThis)
                        end
                    end
                end
                -- Remove reactants
                for reactantID, reactantAmount in pairs(reactionTbl.Reactants) do
                    chm.AddReagent(container, reactantID, reactantAmount * -1 * rateMultiplier * chm.DeltaTime, subContainerID)
                end
                -- Add products
                for productID, productAmount in pairs(reactionTbl.Products) do
                    chm.AddReagent(container, productID, productAmount * rateMultiplier * chm.DeltaTime, subContainerID)
                end
            end
        end
    end
    for key in reactionsToRemove do
        table.remove(subContainerTbl.Reactions, key)
    end

    -- Checking if a reaction should occur
    for reaction in chm.Reactions do
        -- Don't check to add a reaction that is already active
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
-- Reagent effects are ticked both client- and server- side
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
        -- Don't deplete own blood
        if reagentTbl.ID ~= stats.BloodType then
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
-- Client doesn't use this
local ticksSinceRoundStart = 0
if Game.RoundStarted then
    ticksSinceRoundStart = 3
end
chm.DeltaTime = TIMER_BASE / 60
function chm.TickMaster()
    if not Game.RoundStarted then
        ticksSinceRoundStart = 0
        timer = TIMER_BASE
        return
    end
    timer = timer - 1
    if timer <= 0 then
        timer = TIMER_BASE

        -- Check if containers still exist
        local itemsToRemove = {}
        for item, _ in pairs(chm.ContainersItems) do
            if not item or item.Removed == true then
                table.insert(itemsToRemove, item)
            end
        end
        for itemToRemove in itemsToRemove do
            chm.ContainersItems[itemToRemove] = nil
        end
        local charsToRemove = {}
        for char, _ in pairs(chm.ContainersCharacters) do
            -- Keep dead characters
            if not char or char.Removed == true then
                table.insert(charsToRemove, char)
            end
        end
        for charToRemove in charsToRemove do
            chm.ContainersCharacters[charToRemove] = nil
        end

        tickContainerType(chm.ContainersItems)
        tickContainerType(chm.ContainersCharacters)

        if SERVER then
            -- Don't send net messages too soon in the round
            if ticksSinceRoundStart >= 3 then
                local items = {}
                for item, _ in pairs(chm.ContainersItems) do
                    table.insert(items, item)
                end
                local characters = {}
                for char, _ in pairs(chm.ContainersCharacters) do
                    table.insert(characters, char)
                end
                for client in Client.ClientList do
                    if client and client.InGame then
                        chm.WriteContainerMessage(client, items, characters)
                    end
                end
            else
                ticksSinceRoundStart = ticksSinceRoundStart + 1
            end
        end
    end
end
Hook.Add("think", "Megamod.Chemistry.Think", chm.TickMaster)

return chm
