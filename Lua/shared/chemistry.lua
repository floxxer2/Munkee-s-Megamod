local chm = {}
chm.ML_TIMER_BASE = 120
chm.MasterLoopTimer = chm.ML_TIMER_BASE
-- Client doesn't use this
chm.TicksSinceRoundStart = 0
if Game.RoundStarted then
    chm.TicksSinceRoundStart = 3
end
chm.DeltaTime = chm.ML_TIMER_BASE / 60

-- Also used to determine if an item is a container in the first place
chm.ReagentContainerStats = {
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
            -- 1 organdamage per second
            Megamod.AddAffliction(container, "organdamage", Megamod.Chemistry.DeltaTime)
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
    -- Alien blood
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
    -- DRUGS // Only legal if used to heal
    -- ******************************
    -- Values are not perfectly vanilla due to tick variance but it's close enough
    meth = {
        Name = "meth",
        ID = "meth",
        Desc = "WIP",
        Type = "drug",
        DepletionRate = 1,
        Effect = function(self, container, site)
            if LuaUserData.IsTargetType(container, "Barotrauma.Character") then
                Megamod.AddAffliction(container, "haste", 28 * chm.DeltaTime, nil)
            end
        end,
    },
    steroids = {
        Name = "steroids",
        ID = "steroids",
        Desc = "WIP",
        Type = "drug",
        DepletionRate = 1,
        Effect = function(self, container, site)
            if LuaUserData.IsTargetType(container, "Barotrauma.Character") then
                Megamod.AddAffliction(container, "strengthen", 28 * chm.DeltaTime, nil)
            end
        end,
    },
    hyperzine = {
        Name = "hyperzine",
        ID = "hyperzine",
        Desc = "WIP",
        Type = "drug",
        DepletionRate = 1,
        Effect = function(self, container, site)
            if LuaUserData.IsTargetType(container, "Barotrauma.Character") then
                Megamod.AddAffliction(container, "haste", 26.67 * chm.DeltaTime, nil)
                Megamod.AddAffliction(container, "strengthen", 26.67 * chm.DeltaTime, nil)
            end
        end,
    },
    ethanol = {
        Name = "ethanol",
        ID = "ethanol",
        Desc = "WIP",
        Type = "drug",
        DepletionRate = 1,
        Effect = function(self, container, site)
            if LuaUserData.IsTargetType(container, "Barotrauma.Character") then
                Megamod.AddAffliction(container, "haste", 26.67 * chm.DeltaTime, nil)
                Megamod.AddAffliction(container, "strengthen", 26.67 * chm.DeltaTime, nil)
            end
        end,
    },
    antidama1 = {
        Name = "morphine",
        ID = "antidama1",
        Desc = "WIP",
        Type = "drug",
        DepletionRate = 1,
        Effect = function(self, container, site)
            if LuaUserData.IsTargetType(container, "Barotrauma.Character") then
                -- ReduceAfflictionOnAllLimbs appears to work the exact same way as vanilla healing, so we're good there
                container.CharacterHealth.ReduceAfflictionOnAllLimbs("damage", 2.67 * chm.DeltaTime, nil, nil)
                container.CharacterHealth.ReduceAfflictionOnAllLimbs("burn", 0.13 * chm.DeltaTime, nil, nil)
                Megamod.AddAffliction(container, "oxygenlow", 2 * chm.DeltaTime, nil)
                Megamod.AddAffliction(container, "opiateaddiction", 2.67 * chm.DeltaTime, nil)
                Megamod.AddAffliction(container, "opiateoverdose", 2 * chm.DeltaTime, nil)
                container.CharacterHealth.ReduceAfflictionOnAllLimbs("opiatewithdrawal", 5 * chm.DeltaTime, nil, nil)
            end
        end,
    },
    antidama2 = {
        Name = "fentanyl",
        ID = "antidama2",
        Desc = "WIP",
        Type = "drug",
        DepletionRate = 1,
        Effect = function(self, container, site)
            if LuaUserData.IsTargetType(container, "Barotrauma.Character") then
                container.CharacterHealth.ReduceAfflictionOnAllLimbs("damage", 5 * chm.DeltaTime, nil, nil)
                container.CharacterHealth.ReduceAfflictionOnAllLimbs("burn", 0.33 * chm.DeltaTime, nil, nil)
                Megamod.AddAffliction(container, "oxygenlow", 1.67 * chm.DeltaTime, nil)
                Megamod.AddAffliction(container, "opiateaddiction", 1.67 * chm.DeltaTime, nil)
                Megamod.AddAffliction(container, "opiateoverdose", 1.67 * chm.DeltaTime, nil)
                container.CharacterHealth.ReduceAfflictionOnAllLimbs("opiatewithdrawal", 6.67 * chm.DeltaTime, nil, nil)
            end
        end,
    },
    pomegrenadeextract = {
        Name = "pomegrenade extract",
        ID = "Pomegrenadeextract",
        Desc = "WIP",
        Type = "drug",
        DepletionRate = 1,
        Effect = function(self, container, site)
            if LuaUserData.IsTargetType(container, "Barotrauma.Character") then
                Megamod.AddAffliction(container, "oxygenlow", 1.33 * chm.DeltaTime, nil)
                container.CharacterHealth.ReduceAfflictionOnAllLimbs("damage", 0.53 * chm.DeltaTime, nil, nil)
                container.CharacterHealth.ReduceAfflictionOnAllLimbs("burn", 0.53 * chm.DeltaTime, nil, nil)
            end
        end,
    },
    antibloodloss1 = {
        Name = "saline",
        ID = "antibloodloss1",
        Desc = "WIP",
        Type = "drug",
        DepletionRate = 1,
        Effect = function(self, container, site)
            -- #TODO#: Blood loss not implemented yet
        end,
    },
    -- Just use the human blood?
    --[[antibloodloss2 = {
        Name = "blood",
        ID = "antibloodloss2",
        Desc = "WIP",
        Type = "drug",
        DepletionRate = 1,
        Effect = function(self, container, site)

        end,
    },]]
    deusizine = {
        Name = "deusizine",
        ID = "deusizine",
        Desc = "WIP",
        Type = "drug",
        DepletionRate = 1,
        Effect = function(self, container, site)
            if LuaUserData.IsTargetType(container, "Barotrauma.Character") then
                Megamod.AddAffliction(container, "burn", 0.27 * chm.DeltaTime, nil)
                container.CharacterHealth.ReduceAfflictionOnAllLimbs("damage", 4 * chm.DeltaTime, nil, nil)
                container.CharacterHealth.ReduceAfflictionOnAllLimbs("bloodloss", 3.33 * chm.DeltaTime, nil, nil)
                container.CharacterHealth.ReduceAfflictionOnAllLimbs("bleeding", 1.33 * chm.DeltaTime, nil, nil)
                container.CharacterHealth.ReduceAfflictionOnAllLimbs("internaldamage", 1.33 * chm.DeltaTime, nil, nil)
                container.CharacterHealth.ReduceAfflictionOnAllLimbs("infection", 1.67 * chm.DeltaTime, nil, nil)
                container.CharacterHealth.ReduceAfflictionOnAllLimbs("stun", 0.4 * chm.DeltaTime, nil, nil)
                Megamod.AddAffliction(container, "strengthen", 13.33 * chm.DeltaTime, nil)
                container.CharacterHealth.ReduceAfflictionOnAllLimbs("oxygenlow", 10 * chm.DeltaTime, nil, nil)
            end
        end,
    },
    liquidoxygenite = {
        Name = "liquid oxygenite",
        ID = "liquidoxygenite",
        Desc = "WIP",
        Type = "drug",
        DepletionRate = 1,
        Effect = function(self, container, site)
            if LuaUserData.IsTargetType(container, "Barotrauma.Character") then
                container.CharacterHealth.ReduceAfflictionOnAllLimbs("oxygenlow", 10 * chm.DeltaTime, nil, nil)
            end
        end,
    },
    calyxanide = {
        Name = "calyxanide",
        ID = "calyxanide",
        Desc = "WIP",
        Type = "drug",
        DepletionRate = 1,
        Effect = function(self, container, site)
            if LuaUserData.IsTargetType(container, "Barotrauma.Character") then
                local huskProgress = Megamod.GetAfflictionStrength(container, "huskinfection", 0)
                if huskProgress < 100 then
                    -- Intentionally higher than vanilla because it's over 15 seconds, not 1, and the husk will
                    -- regenerate a bit in that time
                    container.CharacterHealth.ReduceAfflictionOnAllLimbs("huskinfection", 7.33 * chm.DeltaTime, nil, nil)
                else
                    Megamod.AddAffliction(container, "organdamage", 2 * chm.DeltaTime, nil)
                end
            end
        end,
    },
    antipsychosis = {
        Name = "haloperidol",
        ID = "antipsychosis",
        Desc = "WIP",
        Type = "drug",
        DepletionRate = 1,
        Effect = function(self, container, site)
            if LuaUserData.IsTargetType(container, "Barotrauma.Character") then
                container.CharacterHealth.ReduceAfflictionOnAllLimbs("psychosis", 6.7 * chm.DeltaTime, nil, nil)
                container.CharacterHealth.ReduceAfflictionOnAllLimbs("hallucinating", 6.7 * chm.DeltaTime, nil, nil)
            end
        end,
    },
    antinarc = {
        Name = "naloxone",
        ID = "antinarc",
        Desc = "WIP",
        Type = "drug",
        DepletionRate = 1,
        Effect = function(self, container, site)
            if LuaUserData.IsTargetType(container, "Barotrauma.Character") then
                container.CharacterHealth.ReduceAfflictionOnAllLimbs("opiatewithdrawal", 4 * chm.DeltaTime, nil, nil)
                container.CharacterHealth.ReduceAfflictionOnAllLimbs("opiateaddiction", 4 * chm.DeltaTime, nil, nil)
                container.CharacterHealth.ReduceAfflictionOnAllLimbs("opiateoverdose", 4 * chm.DeltaTime, nil, nil)
            end
        end,
    },
    morbusineantidote = {
        Name = "morbusine antidote",
        ID = "morbusineantidote",
        Desc = "WIP",
        Type = "drug",
        DepletionRate = 1,
        Effect = function(self, container, site)
            if LuaUserData.IsTargetType(container, "Barotrauma.Character") then
                -- Intentionally higher than vanilla because it takes a little longer
                container.CharacterHealth.ReduceAfflictionOnAllLimbs("morbusinepoisoning", 10.0 * chm.DeltaTime, nil, nil)
            end
        end,
    },
    cyanideantidote = {
        Name = "cyanide antidote",
        ID = "cyanideantidote",
        Desc = "WIP",
        Type = "drug",
        DepletionRate = 1,
        Effect = function(self, container, site)
            if LuaUserData.IsTargetType(container, "Barotrauma.Character") then
                -- Intentionally higher than vanilla because it takes a little longer
                container.CharacterHealth.ReduceAfflictionOnAllLimbs("cyanidepoisoning", 10.0 * chm.DeltaTime, nil, nil)
            end
        end,
    },
    sufforinantidote = {
        Name = "sufforin antidote",
        ID = "sufforinantidote",
        Desc = "WIP",
        Type = "drug",
        DepletionRate = 1,
        Effect = function(self, container, site)
            if LuaUserData.IsTargetType(container, "Barotrauma.Character") then
                -- Intentionally higher than vanilla because it takes a little longer
                container.CharacterHealth.ReduceAfflictionOnAllLimbs("sufforinpoisoning", 15.0 * chm.DeltaTime, nil, nil)
            end
        end,
    },
    deliriumineantidote = {
        Name = "deliriumine antidote",
        ID = "deliriumineantidote",
        Desc = "WIP",
        Type = "drug",
        DepletionRate = 1,
        Effect = function(self, container, site)
            if LuaUserData.IsTargetType(container, "Barotrauma.Character") then
                -- Intentionally higher than vanilla because it takes a little longer
                container.CharacterHealth.ReduceAfflictionOnAllLimbs("deliriuminepoisoning", 15.0 * chm.DeltaTime, nil, nil)
            end
        end,
    },
    antirad = {
        Name = "antirad",
        ID = "antirad",
        Desc = "WIP",
        Type = "drug",
        DepletionRate = 1,
        Effect = function(self, container, site)
            if LuaUserData.IsTargetType(container, "Barotrauma.Character") then
                -- Intentionally higher than vanilla because it takes a little longer
                container.CharacterHealth.ReduceAfflictionOnAllLimbs("radiationsickness", 7.0 * chm.DeltaTime, nil, nil)
            end
        end,
    },
    antiparalysis = {
        Name = "anaparalyzant",
        ID = "antiparalysis",
        Desc = "WIP",
        Type = "drug",
        DepletionRate = 1,
        Effect = function(self, container, site)
            if LuaUserData.IsTargetType(container, "Barotrauma.Character") then
                Megamod.AddAffliction(container, "antiparalysis", 53.33 * chm.DeltaTime, nil)
            end
        end,
    },
    opium = {
        Name = "opium",
        ID = "opium",
        Desc = "WIP",
        Type = "drug",
        DepletionRate = 1,
        Effect = function(self, container, site)
            if LuaUserData.IsTargetType(container, "Barotrauma.Character") then
                container.CharacterHealth.ReduceAfflictionOnAllLimbs("damage", 1.33 * chm.DeltaTime, nil, nil)
                container.CharacterHealth.ReduceAfflictionOnAllLimbs("burn", 0.33 * chm.DeltaTime, nil, nil)
                Megamod.AddAffliction(container, "opiateaddiction", 1.67 * chm.DeltaTime, nil)
                Megamod.AddAffliction(container, "opiateoverdose", 1.67 * chm.DeltaTime, nil)
                Megamod.AddAffliction(container, "oxygenlow", 1.17 * chm.DeltaTime, nil)
                container.CharacterHealth.ReduceAfflictionOnAllLimbs("opiatewithdrawal", 2.33 * chm.DeltaTime, nil, nil)
            end
        end,
    },
    antibiotics = {
        Name = "antibiotics",
        ID = "antibiotics",
        Desc = "WIP",
        Type = "drug",
        DepletionRate = 1,
        Effect = function(self, container, site)
            if LuaUserData.IsTargetType(container, "Barotrauma.Character") then
                local huskProgress = Megamod.GetAfflictionStrength(container, "huskinfection", 0)
                if huskProgress < 75 then
                    container.CharacterHealth.ReduceAfflictionOnAllLimbs("huskinfection", 2 * chm.DeltaTime, nil, nil)
                end
                Megamod.AddAffliction(container, "organdamage", 2.2 * chm.DeltaTime, nil)
                Megamod.AddAffliction(container, "huskinfectionresistance", 40 * chm.DeltaTime, nil)
                container.CharacterHealth.ReduceAfflictionOnAllLimbs("infection", 5 * chm.DeltaTime, nil, nil)
                Megamod.AddAffliction(container, "drunkweakness", 6.67 * chm.DeltaTime, nil)
            end
        end,
    },
    stabilozine = {
        Name = "stabilozine",
        ID = "stabilozine",
        Desc = "WIP",
        Type = "drug",
        DepletionRate = 1,
        Effect = function(self, container, site)
            if LuaUserData.IsTargetType(container, "Barotrauma.Character") then
                Megamod.AddAffliction(container, "stabilozineeffect", 8 * chm.DeltaTime, nil)
            end
        end,
    },
    adrenaline = {
        Name = "adrenaline",
        ID = "adrenaline",
        Desc = "WIP",
        Type = "drug",
        DepletionRate = 1,
        Effect = function(self, container, site)
            if LuaUserData.IsTargetType(container, "Barotrauma.Character") then
                Megamod.AddAffliction(container, "adrenalinerush", 2 * chm.DeltaTime, nil)
                Megamod.AddAffliction(container, "nausea", 2.67 * chm.DeltaTime, nil)
                Megamod.AddAffliction(container, "organdamage", 1.33 * chm.DeltaTime, nil)
            end
        end,
    },
    tonicliquid = {
        Name = "tonic liquid",
        ID = "tonicliquid",
        Desc = "WIP",
        Type = "drug",
        DepletionRate = 1,
        Effect = function(self, container, site)
            if LuaUserData.IsTargetType(container, "Barotrauma.Character") then
                Megamod.AddAffliction(container, "durationincrease", 20 * chm.DeltaTime, nil)
                container.CharacterHealth.ReduceAfflictionOnAllLimbs("damage", 0.8 * chm.DeltaTime, nil, nil)
            end
        end,
    },
    morbusine = {
        Name = "morbusine",
        ID = "morbusine",
        Desc = "WIP",
        Type = "drug",
        DepletionRate = 1,
        Effect = function(self, container, site)

        end,
    },
    chloralhydrate = {
        Name = "chloral hydrate",
        ID = "chloralhydrate",
        Desc = "WIP",
        Type = "drug",
        DepletionRate = 1,
        Effect = function(self, container, site)

        end,
    },
    cyanide = {
        Name = "cyanide",
        ID = "cyanide",
        Desc = "WIP",
        Type = "drug",
        DepletionRate = 1,
        Effect = function(self, container, site)

        end,
    },
    radiotoxin = {
        Name = "radiotoxin",
        ID = "radiotoxin",
        Desc = "WIP",
        Type = "drug",
        DepletionRate = 1,
        Effect = function(self, container, site)

        end,
    },
    sufforin = {
        Name = "sufforin",
        ID = "sufforin",
        Desc = "WIP",
        Type = "drug",
        DepletionRate = 1,
        Effect = function(self, container, site)

        end,
    },
    deliriumine = {
        Name = "deliriumine",
        ID = "deliriumine",
        Desc = "WIP",
        Type = "drug",
        DepletionRate = 1,
        Effect = function(self, container, site)

        end,
    },
    paralyzant = {
        Name = "paralyzant",
        ID = "paralyzant",
        Desc = "WIP",
        Type = "drug",
        DepletionRate = 1,
        Effect = function(self, container, site)

        end,
    },
    raptorbaneextract = {
        Name = "raptor bane extract",
        ID = "raptorbaneextract",
        Desc = "WIP",
        Type = "drug",
        DepletionRate = 1,
        Effect = function(self, container, site)

        end,
    },
}

-- Keep all numbers at 2 decimal places
chm.Reactions = {
    {
        ID = "reaction_meth",
        ReqTempK = 712.8,
        AffectedByStabilizine = true,
        AllowedSites = {
            "item",
            "extra",
        },
        Reactants = {
            phosphorus = 1.00,
            chlorine = 2.00,
            carbon = 2.00,
        },
        Products = {
            meth = 1.00,
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
        if not containerTbl and chm.ReagentContainerStats[tostring(container.Prefab.Identifier)] then
            print("CHEMISTRY: GetContainerTable - Container table not initalized for " .. tostring(container) .. ", correcting...") -- #DEBUG#
            chm.UpdateReagentContainerTable(container)
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

function chm.UpdateReagentContainerTable(item)
    local stats = chm.ReagentContainerStats[tostring(item.Prefab.Identifier)]
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
Hook.Add("item.created", "Megamod.Chemistry.ItemCreated", chm.UpdateReagentContainerTable)

-- Update item/char list if Lua is reloaded midround
if Game.RoundStarted then
    for item in Item.ItemList do
        chm.UpdateReagentContainerTable(item)
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
