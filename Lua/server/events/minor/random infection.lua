local event = {}

event.Name = "Random Infection"

event.Severity = "minor"

event.Enabled = true

event.Started = false

event.CanEnd = false

event.OneOff = true


local limbTypes = {
    {"Torso", LimbType.Torso},
    {"Head", LimbType.Head},
    {"LeftArm", LimbType.LeftArm},
    {"RightArm", LimbType.RightArm},
    {"LeftLeg", LimbType.LeftLeg},
    {"RightLeg", LimbType.RightLeg},
}

-- >75% of crew is alive, >75% of alive crew are healthy (>75 vitality and no infections)
function event.Check()
    if #Client.ClientList == 0 then return false end
    local alive = 0
    local healthy = 0
    for client in Client.ClientList do
        if not Megamod.CheckIsDead(client) then
            alive = alive + 1
            local function isInfected()
                -- Check for husk infection
                if HF.GetAfflictionStrength(client.Character, "huskinfection", 0) > 0 then
                    return true
                end
                -- Check for NT Infections
                for i = 1, #NTI.InfInfo do
                    local inf = NTI.InfInfo[i]
                    for tbl in limbTypes do
                        if HF.GetAfflictionStrengthLimb(client.Character, tbl[2], inf[1], nil) > 0 then
                            return true
                        end
                    end
                end
                return false
            end
            if not isInfected() and client.Character.Vitality > 75 then
                healthy = healthy + 1
            end
        end
    end
    return (alive / #Client.ClientList) >= 0.75 and (healthy / alive) >= 0.75
end

-- Can give any NT Infections infection, or rarely husk infection
function event.Start()
    if #Client.ClientList == 0 then
        Megamod.Log("No clients to infect. Canceling...", true)
        return
    end
    -- Targets must be alive, healthy, and not infected
    local targets = {}
    for client in Client.ClientList do
        if not Megamod.CheckIsDead(client)
        and client.Character.IsHuman == true
        and client.Character.Vitality > 75 then
            -- Check for husk infection
            if HF.GetAfflictionStrength(client.Character, "huskinfection", 0) <= 0 then
                local isInfected = false
                -- Check for NT Infections
                for i = 1, #NTI.InfInfo do
                    local inf = NTI.InfInfo[i]
                    for tbl in limbTypes do
                        if HF.GetAfflictionStrengthLimb(client.Character, tbl[2], inf[1], nil) > 0 then
                            isInfected = true
                            break
                        end
                    end
                end
                if not isInfected then
                    table.insert(targets, client)
                end
            end
        end
    end
    if #targets == 0 then
        Megamod.Log("No valid targets found for infection. Canceling...", true)
        return
    end
    local target = targets[math.random(#targets)]
    local char = target.Character
    local limbName
    local infectionChance = math.random()
    local infectionName
    -- Husk
    if infectionChance <= 0.25 then
        infectionName = "husk infection"
        limbName = char.AnimController.MainLimb.Name
        HF.SetAffliction(char, infectionName, 1)
    else -- Every regular infection that NT Infections can throw at you
        infectionName = "an NTI infection"
        local potentialLimbs = {}
        -- Make sure we don't pick a limb that is already infected
        for tbl in limbTypes do
            if not NTI.LimbIsInfected(char, tbl[2]) then
                table.insert(potentialLimbs, tbl)
            end
        end
        if #potentialLimbs == 0 then return end
        local i = math.random(#potentialLimbs)
        NTI.InfectCharacterRandom(char, potentialLimbs[i][2])
        -- Find the name of the limb for logging
        for tbl in limbTypes do
            if tbl[2] == potentialLimbs[i][2] then
                limbName = tbl[1]
                break
            end
        end
    end
    if not infectionName or not limbName then
        Megamod.Log("Failed to infect target.", true)
        return
    end
    Megamod.Log("Infected '" .. tostring(target.Name) .. "' with " .. infectionName .. " in their " .. limbName, true)
end

---@param fast boolean
function event.End(fast)
end

return event
