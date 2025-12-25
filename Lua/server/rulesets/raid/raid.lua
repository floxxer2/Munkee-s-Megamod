local rs = {}

rs.Name = "Raid"

rs.Chance = 30

rs.Enabled = true

rs.SelectedPlayers = {}

rs.Strength = 0

rs.AntagName = "Raider"

rs.FailReason = ""



rs.Started = false

local loopActive = false
local messaged = {}
function rs.Loop()
    if not Game.RoundStarted
    or rs.FailReason ~= ""
    or rs.Strength == 0
    or rs.Started then
        loopActive = false
        return
    end
    -- Notify spectators
    for client in Client.ClientList do
        if Megamod.CheckIsSpectating(client)
        and not messaged[client] then
            messaged[client] = true
            local str1 = "A Separatist raid is building up to attack the station. "
            local str2 = "You may be a part of it.\nIf you do not want to participate, untick your Raider setting in the preferences menu (ESC -> TBG Preferences)."
            if #Megamod.RuleSetManager.AntagStatus(client) > 0 then
                str2 = "You will not be a part of it, as you are already an antagonist."
            elseif not Megamod.GetData(client, "Raider") then
                str2 = "You will not be a part of it, as you have disabled Raider in your preferences (ESC -> TBG Preferences)."
            end
            Megamod.SendChatMessage(client, str1 .. str2, Color(255, 0, 255, 255))
        end
    end
    if rs.TryStartRaid() then
        loopActive = false
        return
    end
    Timer.Wait(function()
        rs.Loop()
    end, 5000)
end

function rs.TryStartRaid()
    if #Client.ClientList == 0 or rs.Strength < 3 then return false end
    local raiderAmount = math.ceil(#Client.ClientList / 3)
    local availablePlayers = {}
    for client in Client.ClientList do
        if Megamod.CheckIsSpectating(client)
        and Megamod.GetData(client, "Raider")
        and #Megamod.RuleSetManager.AntagStatus(client) == 0
        and not (Megamod.Cloning.ActiveProcess
        and Megamod.Cloning.ActiveProcess[1] == client) -- Don't include people being cloned
        then
            table.insert(availablePlayers, client)
        end
    end

    -- // Chance to start the raid //

    local chance = (rs.Strength / 5) * (#raiderAmount / #availablePlayers)
    if math.random() >= chance then
        return false
    end

    -- Reset messaged in case an admin re-drafts this ruleset midround
    messaged = {}

    -- // Starting the raid //

    if #availablePlayers < raiderAmount then
        Megamod.Log("Not enough players were eligible to be raiders, total number of raiders reduced from " ..
        tostring(raiderAmount) .. " to " .. tostring(#availablePlayers) .. ".")
        raiderAmount = #availablePlayers
    end

    Megamod.Log("A Raid has started with " .. tostring(raiderAmount) .. " raiders.", true)

    -- Ear destroyer 9000
    local prefab = ItemPrefab.GetItemPrefab("mm_notifalarm")
    Entity.Spawner.AddItemToSpawnQueue(prefab, Megamod.Map.CurrentMap.WorldPosition)

    local str = ""
    if raiderAmount > 1 then
        str = "A Separatist raiding party with " ..
        tostring(raiderAmount) .. " members has been detected teleporting to the station. They are going to attack shortly."
    elseif raiderAmount == 1 then
        str = "A Separatist raider has been detected teleporting to the station. The raider is going to attack shortly."
    end
    -- Bright red message
    for client in Client.ClientList do
        Megamod.SendChatMessage(client, str, Color(255, 0, 0, 255))
    end

    local str = "Gave %s gear to " .. raiderAmount .. " raiders."
    local str2 = ""
    local gearSets
    -- 2 loadouts
    local bestGear = {
        -- Vanguard
        [1] = {
            job = "securityofficer",
            talentLevel = 0,
            skills = {
                weapons = { 80, 100 },
                surgery = { 15, 25 },
                medical = { 45, 60 },
                helm = { 10, 20 },
                mechanical = { 30, 45 },
                electrical = { 30, 45 },
            },
            loadout = {
                -- Headset
                headset = { 1, 1 },
                -- Vanguard Helmet
                scp_livhelmet = { 1, 2, true },
                -- Vanguard Ballistic Undersuit
                scp_livuniform = { 1, 3, true },
                -- Vanguard Rig
                scp_livrig = { 1, 4, true },
                -- Assault Backpack
                scp_assaultpack = { 1, 7, false, { scp_akmag = 12 } },
                -- Durasteel Crowbar
                sgt_crowbar = { 1 },
                -- Vanguard Oppressor AR, with a mag and flashlight
                scp_akliv = { 1, nil, false, { scp_akmag = 1, flashlight = 1 } },
                -- AR mags
                scp_akmag = { 3 },
                -- Plastiseal
                antibleeding2 = { 8 },
                -- Tourniquet
                tourniquet = { 2 },
                -- Fulgurium Battery cells
                fulguriumbatterycell = { 2 },
            },
        },
        -- Infiltrator
        [2] = {
            job = "securityofficer",
            talentLevel = 0,
            skills = {
                weapons = { 80, 100 },
                surgery = { 15, 25 },
                medical = { 45, 60 },
                helm = { 10, 20 },
                mechanical = { 30, 45 },
                electrical = { 30, 45 },
            },
            loadout = {
                -- Headset
                headset = { 1, 1 },
                -- Infiltrator Helmet
                scp_yuihelmet = { 1, 2, true },
                -- Infiltrator Fragmentation Suit
                scp_specopsuniform = { 1, 3, true },
                -- Infiltrator Vest
                scp_yuirig = { 1, 4, true },
                -- Assault Backpack
                scp_assaultpack = { 1, 7, false, { scp_ak74mag = 12 } },
                -- Durasteel Crowbar
                sgt_crowbar = { 1 },
                -- Infiltrator Covert AR, with a mag
                scp_sr3 = { 1, nil, false, { scp_ak74mag = 1 } },
                -- Renegade Assault Rifle mags
                scp_ak74mag = { 3 },
                -- Plastiseal
                antibleeding2 = { 8 },
                -- Tourniquet
                tourniquet = { 2 },
                -- Fulgurium Battery cells
                fulguriumbatterycell = { 2 },
                -- Flashlight
                flashlight = { 1 },
            },
        },
    }
    -- 5 loadouts
    local averageGear = {
        -- Heavy Soldier
        [1] = {
            job = "securityofficer",
            talentLevel = 0,
            skills = {
                weapons = { 70, 85 },
                surgery = { 0, 5 },
                medical = { 10, 25 },
                helm = { 0, 10 },
                mechanical = { 15, 30 },
                electrical = { 15, 30 },
            },
            loadout = {
                -- Headset
                headset = { 1, 1 },
                -- Renegade Heavy Combat Helmet
                scp_renegadeheavyhelmet = { 1, 2, true },
                -- Renegade Frag Suit
                scp_heavyrenuniform = { 1, 3, true },
                -- Renegade Special Carrier Rig
                scp_renegadespecialrig = { 1, 4, true },
                -- Assault Backpack
                scp_assaultpack = { 1, 7, false },
                -- Crowbar
                crowbar = { 1 },
                -- Renegade Assault Rifle, with a mag and flashlight
                scp_ak74m = { 1, nil, false, { scp_ak74mag = 1, flashlight = 1 } },
                -- AR mags
                scp_ak74mag = { 4 },
                -- Bandage
                antibleeding1 = { 6 },
                -- Battery cells
                batterycell = { 2 },
            },
        },
        -- Soldier 1
        [2] = {
            job = "securityofficer",
            talentLevel = 0,
            skills = {
                weapons = { 50, 65 },
                surgery = { 0, 5 },
                medical = { 5, 15 },
                helm = { 0, 10 },
                mechanical = { 5, 15 },
                electrical = { 5, 15 },
            },
            loadout = {
                -- Headset
                headset = { 1, 1 },
                -- Renegade Ballistic Helmet
                scp_renegadehelmet = { 1, 2, true },
                -- Renegade Combat Fatigues (style 1)
                scp_renegadeuniform = { 1, 3, true },
                -- Renegade Plate Carrier
                scp_renegadeplatecarrier = { 1, 4, true },
                -- Crowbar
                crowbar = { 1 },
                -- Renegade Heavy SMG, with a mag and flashlight
                scp_sr2 = { 1, nil, false, { scp_umpmag = 1, flashlight = 1 } },
                -- Heavy SMG mags
                scp_umpmag = { 4 },
                -- Bandage
                antibleeding1 = { 8 },
                -- Battery cells
                batterycell = { 2 },
            },
        },
        -- Soldier 2
        [3] = {
            job = "securityofficer",
            talentLevel = 0,
            skills = {
                weapons = { 70, 75 },
                surgery = { 0, 5 },
                medical = { 5, 15 },
                helm = { 0, 10 },
                mechanical = { 5, 15 },
                electrical = { 5, 15 },
            },
            loadout = {
                -- Headset
                headset = { 1, 1 },
                -- Renegade Ballistic Helmet
                scp_renegadehelmet = { 1, 2, true },
                -- Renegade Combat Fatigues (style 2)
                sgt_renegadeuniform = { 1, 3, true },
                -- Renegade Plate Carrier
                scp_renegadeplatecarrier = { 1, 4, true },
                -- Crowbar
                crowbar = { 1 },
                -- Renegade Combat Shotgun, with a drum mag and flashlight
                scp_saiga12 = { 1, nil, false, { scp_saigadrummag = 1, flashlight = 1 } },
                -- Renegade Combat Shotgun Mags
                scp_saigaextmag = { 4 },
                -- Bandage
                antibleeding1 = { 8 },
                -- Battery cells
                batterycell = { 2 },
            },
        },
        -- Rocketeer
        [4] = {
            job = "securityofficer",
            talentLevel = 0,
            skills = {
                weapons = { 50, 65 },
                surgery = { 0, 5 },
                medical = { 5, 15 },
                helm = { 0, 10 },
                mechanical = { 5, 15 },
                electrical = { 5, 15 },
            },
            loadout = {
                -- Headset
                headset = { 1, 1 },
                -- Renegade Ballistic Helmet
                scp_renegadehelmet = { 1, 2, true },
                -- Renegade Combat Fatigues (style 2)
                scp_heavyrenuniform = { 1, 3, true },
                -- Renegade Soft Armor Vest
                scp_renegadevest = { 1, 4, true },
                -- Renegdae Anti-Sub Grenade Launcher, wiwth a frag rocket
                scp_rpg7 = { 1, 7, false, { scp_rpg7he = 1 } },
                -- Crowbar
                crowbar = { 1 },
                -- Renegade Pistol, with a mag and flashlight
                scp_mp443 = { 1, nil, false, { scp_9mmmag = 1, flashlight = 1 } },
                -- Pistol mags
                scp_9mmmag = { 5 },
                -- Frag rockets
                scp_rpg7he = { 2 },
                -- Bandage
                antibleeding1 = { 8 },
                -- Battery cells
                batterycell = { 2 },
            },
        },
        -- Medic
        [5] = {
            job = "medicaldoctor",
            talentLevel = 0,
            skills = {
                weapons = { 10, 25 },
                surgery = { 25, 35 },
                medical = { 60, 75 },
                helm = { 0, 4 },
                mechanical = { 0, 8 },
                electrical = { 0, 7 },
            },
            loadout = {
                -- Headset
                headset = { 1, 1 },
                -- Renegade Ballistic Helmet
                scp_renegadehelmet = { 1, 2, true },
                -- Renegade Combat Medic Uniform (style 1)
                scp_renegadecombatmedicuniform = { 1, 3, true },
                -- Renegade Soft Armor Vest
                scp_renegadevest = { 1, 4, true },
                -- Crowbar
                crowbar = { 1 },
                -- Renegade Pistol, with a mag and flashlight
                scp_mp443 = { 1, nil, false, { scp_9mmmag = 1 } },
                -- Pistol mags
                scp_9mmmag = { 10 },
                -- Wrench (for dislocations)
                wrench = { 1 },
                -- Medical Container, with medical supplies
                medtoolbox = { 1, nil, false, {
                    antibleeding1 = 6,
                    antibleeding2 = 4,
                    antidama1 = 4,
                    deusizine = 3,
                    ointment = 1,
                    tourniquet = 2,
                    gypsum = 2,
                    needle = 1,
                    suture = 16
                    }
                },
                -- Battery cell
                batterycell = { 1 },
                -- Flashlight
                flashlight = { 1 },
                -- Hypomaxim
                mm_hypomaxim = { 1 },
            },
        },
    }
    -- 8 loadouts
    local worstGear = {
        -- Soldier 1
        [1] = {
            job = "securityofficer",
            talentLevel = 0,
            skills = {
                weapons = { 30, 45 },
                surgery = { 0, 5 },
                medical = { 5, 15 },
                helm = { 0, 10 },
                mechanical = { 10, 25 },
                electrical = { 10, 25 },
            },
            loadout = {
                -- Headset
                headset = { 1, 1 },
                -- Improvised Combat Helmet
                scp_simplehelmet = { 1, 2, true },
                -- Renegade Combat Fatigues (style 1)
                scp_renegadeuniform = { 1, 3, true },
                -- Renegade Soft Armor Vest
                scp_renegadevest = { 1, 4, true },
                -- Crowbar
                crowbar = { 1 },
                -- Renegade SMG, with a mag and flashlight
                scp_uzi = { 1, nil, false, { scp_9mmsmgmag = 1, flashlight = 1 } },
                -- SMG mags
                scp_9mmsmgmag = { 4 },
                -- Bandage
                antibleeding1 = { 4 },
                -- Battery cells
                batterycell = { 2 },
            },
        },
        -- Soldier 2
        [2] = {
            job = "securityofficer",
            talentLevel = 0,
            skills = {
                weapons = { 30, 45 },
                surgery = { 0, 5 },
                medical = { 5, 15 },
                helm = { 0, 10 },
                mechanical = { 10, 25 },
                electrical = { 10, 25 },
            },
            loadout = {
                -- Headset
                headset = { 1, 1 },
                -- Improvised Combat Helmet
                scp_simplehelmet = { 1, 2, true },
                -- Renegade Combat Fatigues (style 2)
                sgt_renegadeuniform = { 1, 3, true },
                -- Renegade Soft Armor Vest
                scp_renegadevest = { 1, 4, true },
                -- Crowbar
                crowbar = { 1 },
                -- Renegade SMG, with a mag and flashlight
                scp_uzi = { 1, nil, false, { scp_9mmsmgmag = 1, flashlight = 1 } },
                -- SMG mags
                scp_9mmsmgmag = { 4 },
                -- Bandage
                antibleeding1 = { 4 },
                -- Battery cells
                batterycell = { 2 },
            },
        },
        -- Soldier 3
        [3] = {
            job = "securityofficer",
            talentLevel = 0,
            skills = {
                weapons = { 30, 45 },
                surgery = { 0, 5 },
                medical = { 5, 15 },
                helm = { 0, 10 },
                mechanical = { 10, 25 },
                electrical = { 10, 25 },
            },
            loadout = {
                -- Headset
                headset = { 1, 1 },
                -- Improvised Combat Helmet
                scp_simplehelmet = { 1, 2, true },
                -- Renegade Combat Fatigues (style 1)
                scp_renegadeuniform = { 1, 3, true },
                -- Renegade Soft Armor Vest
                scp_renegadevest = { 1, 4, true },
                -- Crowbar
                crowbar = { 1 },
                -- Renegade SMG, with a mag and flashlight
                scp_uzi = { 1, nil, false, { scp_9mmsmgmag = 1, flashlight = 1 } },
                -- SMG mags
                scp_9mmsmgmag = { 4 },
                -- Bandage
                antibleeding1 = { 2 },
                -- Battery cells
                batterycell = { 2 },
            },
        },
        -- Soldier 4
        [4] = {
            job = "securityofficer",
            talentLevel = 0,
            skills = {
                weapons = { 30, 45 },
                surgery = { 0, 5 },
                medical = { 5, 15 },
                helm = { 0, 10 },
                mechanical = { 10, 25 },
                electrical = { 10, 25 },
            },
            loadout = {
                -- Headset
                headset = { 1, 1 },
                -- Improvised Combat Helmet
                scp_simplehelmet = { 1, 2, true },
                -- Renegade Combat Fatigues (style 1)
                scp_renegadeuniform = { 1, 3, true },
                -- Renegade Soft Armor Vest
                scp_renegadevest = { 1, 4, true },
                -- Crowbar
                crowbar = { 1 },
                -- Renegade SMG, with a mag and flashlight
                scp_uzi = { 1, nil, false, { scp_9mmsmgmag = 1, flashlight = 1 } },
                -- SMG mags
                scp_9mmsmgmag = { 4 },
                -- Bandage
                antibleeding1 = { 2 },
                -- Battery cells
                batterycell = { 2 },
            },
        },
        -- Grenadier
        [5] = {
            job = "securityofficer",
            talentLevel = 0,
            skills = {
                weapons = { 45, 55 },
                surgery = { 0, 5 },
                medical = { 5, 15 },
                helm = { 0, 10 },
                mechanical = { 7, 15 },
                electrical = { 8, 15 },
            },
            loadout = {
                -- Headset
                headset = { 1, 1 },
                -- Improvised Combat Helmet
                scp_simplehelmet = { 1, 2, true },
                -- Renegade Frag Suit
                scp_heavyrenuniform = { 1, 3, true },
                -- Renegade Soft Armor Vest
                scp_renegadevest = { 1, 4, true },
                -- Crowbar
                crowbar = { 1 },
                -- Renegade Pistol, with a mag and flashlight
                scp_mp443 = { 1, nil, false, { scp_9mmmag = 1 } },
                -- Pistol mags
                scp_9mmmag = { 3 },
                -- Surplus Grenade Launcher
                grenadelauncher = { 1 },
                -- 40mm grenade
                ["40mmgrenade"] = { 3 },
                -- 40mm stun grenade
                ["40mmstungrenade"] = { 4 },
                -- Bandage
                antibleeding1 = { 2 },
                -- Battery cells
                batterycell = { 2 },
                -- Flashlight
                flashlight = { 1 },
            },
        },
        -- Bomber
        [6] = {
            job = "assistant",
            talentLevel = 0,
            skills = {
                weapons = { 10, 20 },
                surgery = { 0, 5 },
                medical = { 0, 3 },
                helm = { 0, 0 },
                mechanical = { 0, 4 },
                electrical = { 0, 7 },
            },
            loadout = {
                -- Headset
                headset = { 1, 1 },
                -- Improvised Combat Helmet
                scp_simplehelmet = { 1, 2, true },
                -- Renegade Combat Fatigues (style 1)
                scp_renegadeuniform = { 1, 3, true },
                -- Renegade Soft Armor Vest
                scp_renegadevest = { 1, 4, true },
                -- Crowbar
                crowbar = { 1 },
                -- Breaching charges
                ek_breachingcharge = { 2 },
                -- Molotovs
                molotovcoctail = { 4 },
                -- Pipe bombs
                scp_pipebomb = { 4 },
                -- Battery cells
                batterycell = { 2 },
                -- Flashlight with battery
                flashlight = { 1, nil, false, { batterycell = 1 } },
            },
        },
        -- Trapper
        [7] = {
            job = "mechanic",
            talentLevel = 0,
            skills = {
                weapons = { 10, 20 },
                surgery = { 0, 5 },
                medical = { 0, 3 },
                helm = { 0, 3 },
                mechanical = { 30, 50 },
                electrical = { 35, 55 },
            },
            loadout = {
                -- Headset
                headset = { 1, 1 },
                -- Renegade Combat Fatigues (style 1)
                scp_renegadeuniform = { 1, 3, true },
                -- Assault Backpack
                scp_assaultpack = { 1, 7, false, { blackwire = 8, motiondetector = 3, detonator = 3 } },
                -- Crowbar
                crowbar = { 1 },
                -- Renegade Pistol, with a mag and flashlight
                scp_mp443 = { 1, nil, false, { scp_9mmmag = 1, flashlight = 1 } },
                -- Pistol mags
                scp_9mmmag = { 5 },
                -- Screwdriver
                screwdriver = { 1 },
                -- Wrench
                wrench = { 1 },
                -- UEX
                uex = { 3 },
                -- Battery cells
                batterycell = { 2 },
            },
        },
        -- Medic
        [8] = {
            job = "medicaldoctor",
            talentLevel = 0,
            skills = {
                weapons = { 10, 25 },
                surgery = { 25, 35 },
                medical = { 60, 75 },
                helm = { 0, 4 },
                mechanical = { 0, 8 },
                electrical = { 0, 7 },
            },
            loadout = {
                -- Headset
                headset = { 1, 1 },
                -- Renegade Combat Medic Uniform (style 1)
                scp_renegadecombatmedicuniform = { 1, 3, true },
                -- Crowbar
                crowbar = { 1 },
                -- Renegade Pistol, with a mag and flashlight
                scp_mp443 = { 1, nil, false, { scp_9mmmag = 1 } },
                -- Pistol mags
                scp_9mmmag = { 5 },
                -- Wrench (for dislocations)
                wrench = { 1 },
                -- Medical Container, with medical supplies
                medtoolbox = { 1, nil, false, {
                    antibleeding1 = 6,
                    antibleeding2 = 4,
                    antidama1 = 4,
                    deusizine = 3,
                    ointment = 1,
                    tourniquet = 2,
                    gypsum = 2,
                    needle = 1,
                    suture = 16
                    }
                },
                -- Battery cell
                batterycell = { 1 },
                -- Flashlight
                flashlight = { 1 },
            },
        },
    }
    -- Give best gear if there's a lot of people to kill and few raiders, etc etc
    -- Also affected by ruleset strength
    local gearStrength = math.max(1, rs.Strength / 3) * (#Client.ClientList / math.max(1, raiderAmount / 2))
    if gearStrength >= 10 then
        gearSets = bestGear
        str2 = "best"
    elseif gearStrength >= 5 then
        gearSets = averageGear
        str2 = "average"
    else
        gearSets = worstGear
        str2 = "worst"
    end
    Megamod.Log(string.format(str, str2), true)

    local dvos = Megamod.Map.DVOutside
    local dvo = dvos[math.random(#dvos)]
    local spawnPoint = dvo.WorldPosition

    local prefab = ItemPrefab.GetItemPrefab("mm_rift")
    Entity.Spawner.AddItemToSpawnQueue(prefab, spawnPoint)

    local amountGearSets = #gearSets

    Timer.Wait(function()
        -- Update the spawnpoint, in case the station somehow moved
        spawnPoint = dvo.WorldPosition
        -- Spawn a flare and light it
        local prefab = ItemPrefab.GetItemPrefab("flare")
        Entity.Spawner.AddItemToSpawnQueue(prefab, spawnPoint, nil, nil, function(item)
            -- Yes, this "throws" the flare, but it works
            item.Use(0, nil, nil, nil, nil)
        end)
        for i = 1, raiderAmount do
            local newRaider = table.remove(availablePlayers, math.random(#availablePlayers))

            rs.SelectedPlayers[newRaider] = { "Raider", {} }

            local key = math.random(#gearSets)
            local gearSet = gearSets[key]
            -- Don't spawn medics with small raids
            if raiderAmount < 3 and gearSet.job == "medicaldoctor" then
                table.remove(gearSets, key)
                key = math.random(#gearSets)
                gearSet = gearSets[key]
            end
            -- There should only be one medic loadout per gearset

            local info = CharacterInfo("Human", newRaider.Name, newRaider.Name, JobPrefab.Get(gearSet.job), 0, nil, nil)
            if newRaider.CharacterInfo and newRaider.CharacterInfo.Head then -- Sometimes these aren't set?? If not set, info.Head will be randomized
                info.Head = newRaider.CharacterInfo.Head -- This copies over all of the client's cosmetic choices (hair, skin color, etc.)
            end
            info.TeamID = 2

            -- Talents are currently unused
            --info.GiveExperience(info.GetExperienceRequiredForLevel(gearSet.talentLevel))

            for skillID, skillRange in pairs(gearSet.skills) do
                local skillLevel = math.random(skillRange[1], skillRange[2])
                info.SetSkillLevel(skillID, skillLevel, false)
            end

            local raiderCharacter = Character.Create(info, spawnPoint, info.Name, 0, false, false)
            raiderCharacter.TeamID = 2
            -- Make sure everyone knows what team the raider is on
            local msg = Networking.Start("mm_setteam")
            msg.WriteUInt64(raiderCharacter.ID)
            for client in Client.ClientList do
                Networking.Send(msg, client.Connection)
            end

            HF.AddAffliction(raiderCharacter, "pressurestabilized", 180)

            for gearItemID, tbl in pairs(gearSet.loadout) do
                local prefab = ItemPrefab.GetItemPrefab(gearItemID)
                -- tbl[1] is the amount to spawn
                for p = 1, tbl[1] do
                    Entity.Spawner.AddItemToSpawnQueue(prefab, raiderCharacter.Inventory, nil, nil, function(item)
                        -- Items to spawn in the item
                        if tbl[4] then
                            for gearItemID2, amountToSpawn in pairs(tbl[4]) do
                                local prefab2 = ItemPrefab.GetItemPrefab(gearItemID2)
                                for l = 1, amountToSpawn do
                                    Entity.Spawner.AddItemToSpawnQueue(prefab2, item.OwnInventory)
                                end
                            end
                        end
                        -- tbl[2] is the inventory index to move the item to, for clothing/armor
                        if tbl[2] then
                            raiderCharacter.Inventory.TryPutItem(item, tbl[2], false, false, raiderCharacter, true, true)
                        end
                        -- Set to noninteractable
                        if tbl[3] then
                            Megamod.CreateEntityEvent(item, item, "NonInteractable", true)
                        end
                    end)
                end
            end

            newRaider.SetClientCharacter(raiderCharacter)

            Megamod.GiveAntagOverlay(raiderCharacter)

            for admin in Client.ClientList do
                if Megamod.Admins[admin.SteamID] then
                    local msg = Networking.Start("mm_ruleset")
                    msg.WriteByte(3)
                    msg.WriteString(rs.Name)
                    msg.WriteByte(newRaider.SessionId)
                    msg.WriteString(rs.SelectedPlayers[newRaider][1])
                    Networking.Send(msg, admin.Connection)
                end
            end

            -- Don't use this loadout again, if possible
            if raiderAmount <= amountGearSets then
                table.remove(gearSets, key)
            end
        end
        -- Wait to "start" the raid so that the end round check doesn't think all raiders are dead because they haven't spawned yet
        rs.Started = true
    end, 5000)
    return true
end



function rs.Reset()
    rs.SelectedPlayers = {}
    rs.Strength = 0
    rs.Strength = 0
    rs.Started = false
    messaged = {}
end

function rs.RoleHelp(client)
    if rs.SelectedPlayers[client] then
        return true, ">> You are a Separatist raider!\n>> You are attacking the station to kill everybody.\n>> Cooperate with fellow raiders (if any) to succeed."
    end
    return false, ""
end

function rs.Check()
    return true
end

local healthTimer = {}
function rs.CheckShouldFail()
    -- Don't end before the raid starts
    if not rs.Started then return false, "" end

    local healthyRaiders = 0
    for client, _ in pairs(rs.SelectedPlayers) do
        if not Megamod.CheckIsDead(client) then
            local vitality = client.Character.Vitality
            if vitality > 0 then
                healthTimer[client] = 12
                healthyRaiders = healthyRaiders + 1
            else
                -- If raider is downed, wait ~2 minutes before considering them dead
                if not healthTimer[client] then
                    healthTimer[client] = 12

                    healthyRaiders = healthyRaiders + 1
                elseif healthTimer[client] > 0 then
                    healthTimer[client] = healthTimer[client] - 1

                    healthyRaiders = healthyRaiders + 1
                end
            end
        end
    end
    if healthyRaiders > 0 then return false, "" end
    return true, "All raiders are dead or dying."
end

function rs.Draft()
    if not loopActive and not rs.Started then
        loopActive = true
        rs.Loop()
    end
end

return rs
