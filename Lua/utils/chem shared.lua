local chm = {}

-- Also used to determine if an item is a container in the first place
chm.ItemContainerStats = {
    mm_syringe = {
        SubContainers = {
            [1] = {
                Capacity = 15,
                Site = "item",
            },
        },
    },
    mm_beaker = {
        SubContainers = {
            [1] = {
                Capacity = 50,
                Site = "item",
            },
        },
    },
    mm_largebeaker = {
        SubContainers = {
            [1] = {
                Capacity = 100,
                Site = "item",
            },
        },
    },
    mm_chemicaldispenser = {
        SubContainers = {
            [1] = {
                Capacity = 100,
                Site = "item",
            },
        },
    },
}

-- Only humans for now
chm.CharacterContainerStats = {
    Human = {
        BloodType = "blood_human", -- Humans have human blood
        BloodCapacity = 100, -- Humans want to have ~100 units of blood
        InternalTemperatureK = 310.15,
        DepletionRate = 1, -- Mulitplier on how much of each (non "blood" type) chemical is removed per tick
        SubContainers = {
            [1] = { -- Stuff in the blood
                StartingReagents = {
                    blood_human = 100
                },
                Capacity = 1000,
                Site = "blood",
            },
            [2] = { -- Stuff on the skin
                StartingReagents = {},
                Capacity = 1000,
                Site = "skin",
            },
            [3] = { -- Stuff being breathed in
                StartingReagents = {},
                Capacity = 1000,
                Site = "inhale",
            },
            [4] = { -- Stuff being eaten
                StartingReagents = {},
                Capacity = 1000,
                Site = "ingest",
            },
            -- Characters can have extra subcontainers, they will have Site = "extra"
        }
    },
}

local defaultResourceDesc = "A natural or manmade resource."
local function defaultResourceEffect(self, container, site)
    -- Add 1 organ damage per second if blood or inhale, nothing if skin
    if LuaUserData.IsTargetType(container, "Barotrauma.Character") then
        if site == "blood" or site == "inhale" then
            local current = Megamod.GetAfflictionStrength(container, "organdamage", 0)
            Megamod.SetAffliction(container, "organdamage", current + (1 * Megamod.Chemistry.DeltaTime), nil, current)
        end
    end
end
-- Everything with type "material" can be dispensed by the chem dispenser
local function createResource(name, resourceType)
    return {
        Name = name,
        ID = name,
        Desc = defaultResourceDesc,
        Type = resourceType,
        DepletionRate = 1,
        Effect = defaultResourceEffect,
    }
end

-- Effect() function params
-- self = reference to own table that will store this function
-- container = reference to container object
-- site = if container is a character, this is where the chemical was applied, as a string
--  blood
--  skin
--  inhaled

-- Yes, this is heavily inspired by the chemical system in SS13
chm.Reagents = {
    -- ******************************
    -- Materials // Legal, but should not be injected
    -- ******************************
    -- Elements (can be dispensed directly)
    aluminum = createResource("aluminum", "material"),
    barium = createResource("barium", "material"),
    bromine = createResource("bromine", "material"),
    carbon = createResource("carbon", "material"),
    calcium = createResource("calcium", "material"),
    chlorine = createResource("chlorine", "material"),
    chromium = createResource("chromium", "material"),
    copper = createResource("copper", "material"),
    ethanol = createResource("ethanol", "material"),
    fluorine = createResource("fluorine", "material"),
    helium = createResource("helium", "material"),
    hydrogen = createResource("hydrogen", "material"),
    iodine = createResource("iodine", "material"),
    iron = createResource("iron", "material"),
    lithium = createResource("lithium", "material"),
    magnesium = createResource("magnesium", "material"),
    mercury = createResource("mercury", "material"),
    nickel = createResource("nickel", "material"),
    nitrogen = createResource("nitrogen", "material"),
    oxygen = createResource("oxygen", "material"),
    phosphorus = createResource("phosphorus", "material"),
    plasma = createResource("plasma", "material"),
    platinum = createResource("platinum", "material"),
    potassium = createResource("potassium", "material"),
    radium = createResource("radium", "material"),
    silicon = createResource("silicon", "material"),
    silver = createResource("silver", "material"),
    sodium = createResource("sodium", "material"),
    sugar = createResource("sugar", "material"),
    sulfur = createResource("sulfur", "material"),
    water = createResource("water", "material"),
    -- Compounds (must be crafted by reactions)
    acetone = createResource("acetone", "compound"),
    ammonia = createResource("ammonia", "compound"),
    diethylamine = createResource("diethylamine", "compound"),
    oil = createResource("oil", "compound"),
    phenol = createResource("phenol", "compound"),
    stabilizine = {
        Name = "stabilizine",
        ID = "stabilizine",
        Desc = "A general precursor drug. On it's own, it will slow down the progression of toxins.",
        Type = "stabilizine",
        DepletionRate = 1,
        Effect = function(self, container, site)
            -- #TODO#
        end,
    },

    -- Blood types
    blood_human = {
        Name = "blood (human)",
        ID = "blood_human",
        Desc = "Can be used for transfusions or certain chemical reactions.",
        Type = "blood",
        DepletionRate = 1,
        Effect = function(self, container, site)
            -- No effect
        end,
    },
    blood_nonhuman = {
        Name = "blood (nonhuman)",
        ID = "blood_nonhuman",
        Desc = "Can be used for certain chemical reactions. Do not inject into the bloodstream.",
        Type = "blood",
        DepletionRate = 1,
        Effect = function(self, container, site)
            -- #TODO#
        end,
    },

    -- ******************************
    -- GENERAL HEALERS // Legal unless not used to heal
    -- ******************************
    -- Type: Anti-burn
    -- Downside: Expensive to make
    -- Overdose: Causes burns, suffocation if too much
    antiburn = {
        Name = "antiburn", -- #TODO#
        ID = "antiburn",
        Desc = "A chemical that heals burns. It is expensive to make.",
        Type = "chemical",
        DepletionRate = 1,
        Effect = function(self, container, site)
            -- #TODO#
        end,
    },

    -- Type: Anti-bleeding
    -- Downside: Causes lacerations proportional to the amount of bleeding fixed
    -- Overdose: Causes bloodloss, suffocation if too much
    --[[antibleeding = {
        desc = "A chemical that quickly cauterizes bleeding. It causes lacerations as a result of closing wounds.",
    },]]

    -- Type: Anti-blunt force
    -- Downside: Heals slowly
    -- Overdose: Speed debuff, suffocation if too much
    --[[antiblunt = {
        desc = "A chemical that helps heal blunt force trauma. The effect is rather slow.",
    },]]

    -- Type: Anti-lacerations/gunshot/bite wound etc
    -- Downside: Causes burns
    -- Overdose: Vitality damage + suffocation
    --[[antilaceration = {
        desc = "A chemical that helps heal lacerations, bite wounds, etc. It causes minor burns.",
    },]]

    -- Type: Anti-suffocation/oxyloss
    -- Downside: Causes disorientation even when not overdosing
    -- Overdose: Extreme disorientation, suffocation if too much
    --[[antioxyloss = {
        desc = "A chemical that prevents oxygen loss from becoming lethal. It causes disorientation.",
    },]]

    -- Type: Anti-toxin
    -- Downside: Requies high dosage
    -- Overdose: Vitality damage + suffocation
    --[[antitoxin = {
        desc = "A chemical that neutralizes toxins. It requires a high dosage to be effective.",
    },]]

    -- Protective, prevents getting radiation but doesn't cure it
    --[[antiradP = {
        desc = "A chemical that helps prevent radiation from accumulating, but does not remove it if it's already affecting you.",
    },]]

    -- Cure, removes rad poisoning (slowly) but does not prevent gaining it
    --[[antiradC = {
        desc = "A chemical that slowly removes radiation.",
    },]]

    -- ******************************
    -- POISONS // Illegal unless exclusively used to make antidotes
    -- ******************************
}

-- Keep all numbers at 2 decimal places
chm.Reactions = {
    { -- Antiburn
        ID = "basic_antiburn",
        ReqTempK = 712.8,
        AffectedByStabilizine = true,
        AllowedSites = {
            "item",
            "extra",
        },
        Reactants = {
            carbon = 1.00,
            barium = 1.25,
        },
        Products = {
            antiburn = 1.50,
        },
    },
}


-- Every item that can hold reagents
chm.ContainersItems = {}
-- Every character that can hold reagents (currently only humans)
chm.ContainersCharacters = {}

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

---@param container Barotrauma.Character|Barotrauma.Item
---@param id string the id of the reagent
---@param amount number the amount to add
---@param subContainerID integer defaults to 1
---@return number actualInput returns what SetReagent returns
function chm.AddReagent(container, id, amount, subContainerID)
    subContainerID = subContainerID or 1
    if subContainerID <= 0 or not (math.ceil(subContainerID) == subContainerID) then
        error("Invalid subContainer.")
        return
    end
    local reagentTbl = chm.GetReagentInSubContainer(container, id, subContainerID)
    if reagentTbl and reagentTbl.Amount > 0 then
        amount = reagentTbl.Amount + amount
    end
    return chm.SetReagent(container, id, amount, subContainerID)
end

---@param container Barotrauma.Character|Barotrauma.Item
---@param id string the id of the reagent
---@param amount number the number to set the reagent's amount to
---@param subContainerID integer defaults to 1
---@return number actualInput desired amount can be set lower if container is filled
---@return boolean reagentDeleted will delete reagent table if amount goes <= 0
function chm.SetReagent(container, id, amount, subContainerID)
    local reagentStats = chm.Reagents[id]
    if not reagentStats then
        error("Invalid id.")
        return
    end
    if type(amount) ~= "number" then
        error("Invalid amount.")
    end
    local containerTbl = chm.GetContainerTable(container)
    subContainerID = subContainerID or 1
    if subContainerID <= 0 or not (math.ceil(subContainerID) == subContainerID) then
        local errorStr = "CHEMISTRY - WARNING: SetReagent called with invalid subContainerID."
        if #containerTbl.SubContainers == 1 then
            error(errorStr .. " Using default subcontainer 1.")
            subContainerID = 1
        else -- Don't use subcontainer 1 if there are multiple subcontainers
            error(errorStr .. " Cancelling.")
            return
        end
    end
    local reagentTbl = containerTbl.SubContainers[subContainerID].Reagents[id]
    local cap = containerTbl.SubContainers[subContainerID].Capacity
    local totalAmount = amount
    for reagent in chm.GetAllReagentsInSubContainer(container, subContainerID) do
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
        containerTbl.SubContainers[subContainerID].Reagents[id] = nil
        return amount, true
    end
    -- Reagent was already there
    if reagentTbl then
        reagentTbl.Amount = amount
    else -- Reagent needs to be created
        local stats = chm.Reagents[id]
        containerTbl.SubContainers[subContainerID].Reagents[id] = chm.CreateReagent(stats, amount)
    end
    -- We might have changed the desired amount to be lower, so return the new amount
    return amount, false
end

---@param container Barotrauma.Character|Barotrauma.Item
---@param id string the id of the reagent
---@param subContainerID integer  defaults to 1
---@return table|boolean reagent false if reagent not found
function chm.GetReagentInSubContainer(container, id, subContainerID)
    subContainerID = subContainerID or 1
    if subContainerID <= 0 or not (math.ceil(subContainerID) == subContainerID) then
        error("Invalid subContainerID.")
        return false
    end
    local containerTbl = chm.GetContainerTable(container)
    local subContainerTbl = containerTbl.SubContainers[subContainerID]
    for _, reagentTbl in pairs(subContainerTbl.Reagents) do
        if reagentTbl.ID == id then
            return reagentTbl
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
        error("Invalid subContainerID.")
        return
    end
    local containerTbl = chm.GetContainerTable(container)
    local subContainerTbl = containerTbl.SubContainers[subContainerID]
    if not subContainerTbl then
        error("No subcontainer table of ID " .. tostring(subContainerID) .. " for container " .. tostring(container))
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
    --local container1Tbl = chm.GetContainerTable(container1)
    subContainer1ID = subContainer1ID or 1
    if subContainer1ID <= 0 or not (math.ceil(subContainer1ID) == subContainer1ID) then
        error("Invalid subContainer1ID.")
        return 0
    end
    --local subContainer1Tbl = container1Tbl.SubContainers[subContainer1ID]
    local container2Tbl = chm.GetContainerTable(container2)
    subContainer2ID = subContainer2ID or 1
    if subContainer2ID <= 0 or not (math.ceil(subContainer2ID) == subContainer2ID) then
        error("Invalid subContainer2ID.")
        return 0
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
    if percentToTransfer <= 0 then return 0 end

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

    return percentToTransfer * amountToTransfer
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
        error("GetContainerTable called with invalid container type.")
        return
    end
    return containerTbl
end


function chm.UpdateCharacterContainerTable(char)
    if char
    and not char.Removed
    and not char.IsDead
    and not chm.ContainersCharacters[char] then
        local stats = chm.CharacterContainerStats[tostring(char.SpeciesName)]
        if not stats then return end
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
    chm.ContainersItems[item] = {
        SubContainers = {},
    }
    for subContainer in stats.SubContainers do
        table.insert(chm.ContainersItems[item].SubContainers, {
            Capacity = subContainer.Capacity,
            Reagents = {},
            Reactions = {},
            TemperatureK = 295.372, -- Room temperature
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
end
Hook.Add("roundEnd", "Megamod.Chemistry_Shared.End", chm.Reset)

return chm
