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
}
-- Only humans for now
chm.CharacterContainerStats = {
    Human = {
        BloodType = "human", -- Humans have human blood
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
    -- Add 1 organ damage per tick if blood or inhale, nothing if skin
    if LuaUserData.IsTargetType(container, "Barotrauma.Character") then
        if site == "blood" or site == "inhale" then
            local current = Megamod.GetAfflictionStrength(container, "organdamage", 0)
            Megamod.SetAffliction(container, "organdamage", current + 1, nil, current)
        end
    end
end
local function createResource(name)
    return {
        Name = name,
        ID = name,
        Desc = defaultResourceDesc,
        Type = "material",
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

-- Yes, this is heavily inspired by the chemical system in SS13.
chm.Reagents = {
    -- ******************************
    -- Materials // Legal, but should not be injected
    -- ******************************
    -- Elements (can be dispensed directly)
    aluminum = createResource("aluminum"),
    barium = createResource("barium"),
    bromine = createResource("bromine"),
    carbon = createResource("carbon"),
    calcium = createResource("calcium"),
    chlorine = createResource("chlorine"),
    chromium = createResource("chromium"),
    copper = createResource("copper"),
    ethanol = createResource("ethanol"),
    fluorine = createResource("fluorine"),
    helium = createResource("helium"),
    hydrogen = createResource("hydrogen"),
    iodine = createResource("iodine"),
    iron = createResource("iron"),
    lithium = createResource("lithium"),
    magnesium = createResource("magnesium"),
    mercury = createResource("mercury"),
    nickel = createResource("nickel"),
    nitrogen = createResource("nitrogen"),
    oxygen = createResource("oxygen"),
    phosphorus = createResource("phosphorus"),
    plasma = createResource("plasma"),
    platinum = createResource("platinum"),
    potassium = createResource("potassium"),
    radium = createResource("radium"),
    silicon = createResource("silicon"),
    silver = createResource("silver"),
    sodium = createResource("sodium"),
    sugar = createResource("sugar"),
    sulfur = createResource("sulfur"),
    water = createResource("water"),
    -- Compounds (must be crafted by reactions)
    acetone = createResource("acetone"),
    ammonia = createResource("ammonia"),
    diethylamine = createResource("diethylamine"),
    oil = createResource("oil"),
    phenol = createResource("phenol"),
    stabilizine = {
        Name = "stabilizine",
        ID = "stabilizine",
        Desc = "A general precursor drug. On it's own, it will slow down the progression of toxins.",
        Type = "material",
        DepletionRate = 1,
        Effect = function(self, container, site)
            -- #TODO#
        end,
    },

    -- Special reagents
    bloodHuman = {
        Name = "blood (human)",
        ID = "blood_human",
        Desc = "Can be used for transfusions or certain chemical reactions.",
        Type = "blood",
        DepletionRate = 1,
        Effect = function(self, container, site)
            -- No effect
        end,
    },
    bloodNonHuman = {
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

-- Keep reactant/product amounts at 2 decimal places
chm.Reactions = {
    { -- Antiburn
        ID = 1,
        ReqTempK = 712.8,
        AffectedByStabilizine = true,
        AllowedSites = {
            ["item"] = true,
            ["extra"] = true,
        },
        Reactants = {
            ["carbon"] = 1.00,
        },
        Products = {
            ["antiburn"] = 1.00,
        },
    },
}

return chm