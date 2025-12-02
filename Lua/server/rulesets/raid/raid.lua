local rs = {}

rs.Name = "Raid"

rs.Chance = 30

rs.Enabled = false

rs.SelectedPlayers = {}

rs.Strength = 0

rs.AntagName = "Raider"

rs.FailReason = ""



local weightedRandom = require 'utils.weightedrandom'

-- Incremented by 1 when the raid COULD start but doesn't, must be >=2 for the raid to start
rs.Stacks = 0

rs.Started = false



function rs.Reset()
    rs.SelectedPlayers = {}
    rs.Strength = 0
    rs.Stacks = 0
    rs.Started = false
end

function rs.RoleHelp(client)
    if rs.SelectedPlayers[client] then
        return true, ">> You are a Separatist raider!\n>> You are attacking the station to kill everybody.\n>> Cooperate with fellow raiders (if any) to succeed."
    end
    return false, ""
end

function rs.Check()
    if rs.Strength >= 10 or not Game.RoundStarted then return false end
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
        if not Game.RoundStarted then return end

        local raiderAmount = 0
        if #Client.ClientList > 14 then
            raiderAmount = 8
        elseif #Client.ClientList > 11 then
            raiderAmount = 6
        elseif #Client.ClientList > 7 then
            raiderAmount = 4
        elseif #Client.ClientList > 3 then
            raiderAmount = 2
        end

        local availablePlayers = {}
        local availablePlayerTotal = 0

        for client in Client.ClientList do
            local text = ""
            if Megamod.CheckIsDead(client) and Megamod.GetData(client, "Raider") then
                availablePlayers[client] = 1
                availablePlayerTotal = availablePlayerTotal + 1
                text =
                "A Separatist raid is building up to attack the station. You may be a part of it.\nIf you do not want to potentially participate, type \"!pp raider\" in chat (that will also stop these messages)."
            end
            Megamod.SendChatMessage(client, text, Color(255, 0, 255, 255))
        end

        if availablePlayerTotal == 0 then
            -- Wait for more players
            Timer.Wait(function()
                rs.Stacks = 0
                rs.Raid()
            end, math.random(50000, 60000))
            return true, ""
        elseif #Client.ClientList >= 7 and availablePlayerTotal > 0 and availablePlayerTotal <= 2 then
            -- 80% chance to wait for more players
            if rs.Stacks <= 2 or math.random() <= 0.8 then
                Timer.Wait(function()
                    rs.Stacks = rs.Stacks + 1
                    rs.Raid()
                end, math.random(50000, 60000))
                return true, ""
            end
        elseif #Client.ClientList >= 11 and availablePlayerTotal > 2 and availablePlayerTotal <= 4 then
            -- 60% chance to wait for more players
            if rs.Stacks <= 2 or math.random() <= 0.6 then
                Timer.Wait(function()
                    rs.Stacks = rs.Stacks + 1
                    rs.Raid()
                end, math.random(50000, 60000))
                return true, ""
            end
        elseif #Client.ClientList >= 14 and availablePlayerTotal > 4 and availablePlayerTotal <= 6 then
            -- 40% chance to wait for more players
            if rs.Stacks <= 2 or math.random() <= 0.4 then
                Timer.Wait(function()
                    rs.Stacks = rs.Stacks + 1
                    rs.Raid()
                end, math.random(50000, 60000))
                return true, ""
            end
        end

        -- /// STARTING THE RAID ///

        Megamod.Log("A Raid has started.", true)

        if availablePlayerTotal < raiderAmount then
            Megamod.Log(
                "Not enough players are eligible to be raiders, total number of raiders reduced from " ..
                raiderAmount .. " to " .. availablePlayerTotal .. ".", true)
            raiderAmount = availablePlayerTotal
        end

        -- Ear destroyer 9000
        local prefab = ItemPrefab.GetItemPrefab("mm_notifalarm")
        Entity.Spawner.AddItemToSpawnQueue(prefab, Megamod.Map.CurrentMap.WorldPosition)

        local text = ""
        if raiderAmount > 1 then
            text = "A Separatist raiding party with " ..
            tostring(raiderAmount) .. " members has been detected. They are going to attack shortly."
        elseif raiderAmount == 1 then
            text = "A Separatist raider has been detected. The raider is going to attack shortly."
        end

        -- Bright red message
        for client in Client.ClientList do
            Megamod.SendChatMessage(client, text, Color(255, 0, 0, 255))
        end

        local gearSets
        if raiderAmount <= 2 then
            -- Best gear for 1-2 raiders
            gearSets = {
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
                        -- Headset (spawns with disposable battery)
                        headset = { 1, 1 },
                        -- Vanguard Helmet
                        scp_livhelmet = { 1, 2, true },
                        -- Vanguard Ballistic Undersuit
                        scp_livuniform = { 1, 3, true },
                        -- Vanguard Rig
                        scp_livrig = { 1, 4, true },
                        -- Assault Backpack
                        scp_assaultpack = { 1, 7, false, { scp_akmag = 10 } },
                        -- Durasteel Crowbar
                        sgt_crowbar = { 1 },
                        -- Vanguard Oppressor AR, with a mag and flashlight
                        scp_akliv = { 1, nil, false, { scp_akmag = 1, flashlight = 1 } },
                        -- AR mags
                        scp_akmag = { 2 },
                        -- Plastiseal
                        antibleeding2 = { 8 },
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
                        -- Headset (spawns with disposable battery)
                        headset = { 1, 1 },
                        -- Infiltrator Helmet
                        scp_yuihelmet = { 1, 2, true },
                        -- Infiltrator Fragmentation Suit
                        scp_specopsuniform = { 1, 3, true },
                        -- Infiltrator Vest
                        scp_yuirig = { 1, 4, true },
                        -- Assault Backpack
                        scp_assaultpack = { 1, 7, false, { scp_valextmag = 10 } },
                        -- Durasteel Crowbar
                        sgt_crowbar = { 1 },
                        -- Infiltrator Covert AR, with a mag
                        scp_sr3 = { 1, nil, false, { scp_valextmag = 1 } },
                        -- Covert AR mags
                        scp_valextmag = { 2 },
                        -- Plastiseal
                        antibleeding2 = { 8 },
                        -- Fulgurium Battery cells
                        fulguriumbatterycell = { 2 },
                        -- Flashlight
                        flashlight = { 1 },
                    },
                },
            }
        elseif raiderAmount > 2 and raiderAmount <= 5 then
            -- Average gear for 3-5 raiders
            gearSets = {
                -- Heavy Soldier
                [1] = {
                    job = "securityofficer",
                    talentLevel = 0,
                    skills = {
                        weapons = { 55, 70 },
                        surgery = { 0, 5 },
                        medical = { 10, 25 },
                        helm = { 0, 10 },
                        mechanical = { 15, 30 },
                        electrical = { 15, 30 },
                    },
                    loadout = {
                        -- Headset (spawns with disposable battery)
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
                        -- Headset (spawns with disposable battery)
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
                        weapons = { 50, 65 },
                        surgery = { 0, 5 },
                        medical = { 5, 15 },
                        helm = { 0, 10 },
                        mechanical = { 5, 15 },
                        electrical = { 5, 15 },
                    },
                    loadout = {
                        -- Headset (spawns with disposable battery)
                        headset = { 1, 1 },
                        -- Renegade Ballistic Helmet
                        scp_renegadehelmet = { 1, 2, true },
                        -- Renegade Combat Fatigues (style 2)
                        sgt_renegadeuniform = { 1, 3, true },
                        -- Renegade Plate Carrier
                        scp_renegadeplatecarrier = { 1, 4, true },
                        -- Crowbar
                        crowbar = { 1 },
                        -- Renegade Pump Action Shotgun, with shells and a flashlight
                        scp_rm93 = { 1, nil, false, { shotgunshell = 6, flashlight = 1 } },
                        -- Shotgun shells
                        shotgunshell = { 24 },
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
                        -- Headset (spawns with disposable battery)
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
                        -- Frag rockets, 3 stacks
                        scp_rpg7he = { 6 },
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
                        medical = { 50, 65 },
                        helm = { 0, 4 },
                        mechanical = { 0, 8 },
                        electrical = { 0, 7 },
                    },
                    loadout = {
                        -- Headset (spawns with disposable battery)
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
                        scp_mp443 = { 1, nil, false, { scp_9mmmag = 1, flashlight = 1 } },
                        -- Pistol mags
                        scp_9mmmag = { 10 },
                        -- Wrench (for dislocations)
                        wrench = { 1 },
                        -- Plastiseal
                        antibleeding2 = { 8 },
                        -- Morphine
                        antidama1 = { 8 },
                        -- Antibiotic ointment
                        ointment = { 1 },
                        -- Tourniquets
                        tourniquet = { 4 },
                        -- Gypsum
                        gypsum = { 4 },
                        -- Battery cell
                        batterycell = { 1 },
                    },
                },
            }
        elseif raiderAmount > 5 then
            -- Worst gear for 6-8 raiders, or when drafted as secondary
            gearSets = {
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
                        -- Headset (spawns with disposable battery)
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
                        scp_9mmsmgmag = { 2 },
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
                        -- Headset (spawns with disposable battery)
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
                        scp_9mmsmgmag = { 2 },
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
                        -- Headset (spawns with disposable battery)
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
                        scp_9mmsmgmag = { 2 },
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
                        -- Headset (spawns with disposable battery)
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
                        scp_9mmsmgmag = { 2 },
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
                        -- Headset (spawns with disposable battery)
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
                        scp_mp443 = { 1, nil, false, { scp_9mmmag = 1, flashlight = 1 } },
                        -- Pistol mags
                        scp_9mmmag = { 3 },
                        -- Renegade Compact Grenade Launcher
                        sgt_m79 = { 1 },
                        -- 40mm grenade
                        ["40mmgrenade"] = { 3 },
                        -- 40mm stun grenade
                        ["40mmstungrenade"] = { 4 },
                        -- Bandage
                        antibleeding1 = { 2 },
                        -- Battery cells
                        batterycell = { 2 },
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
                        -- Headset (spawns with disposable battery)
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
                        -- Headset (spawns with disposable battery)
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
                        surgery = { 10, 25 },
                        medical = { 30, 45 },
                        helm = { 0, 4 },
                        mechanical = { 0, 8 },
                        electrical = { 0, 7 },
                    },
                    loadout = {
                        -- Headset (spawns with disposable battery)
                        headset = { 1, 1 },
                        -- Renegade Combat Medic Uniform (style 1)
                        scp_renegadecombatmedicuniform = { 1, 3, true },
                        -- Crowbar
                        crowbar = { 1 },
                        -- Renegade Pistol, with a mag and flashlight
                        scp_mp443 = { 1, nil, false, { scp_9mmmag = 1, flashlight = 1 } },
                        -- Pistol mags
                        scp_9mmmag = { 3 },
                        -- Wrench (for dislocations)
                        wrench = { 1 },
                        -- Plastiseal
                        antibleeding2 = { 8 },
                        -- Morphine
                        antidama1 = { 4 },
                        -- Antibiotic ointment
                        ointment = { 1 },
                        -- Tourniquets
                        tourniquet = { 2 },
                        -- Gypsum
                        gypsum = { 2 },
                        -- Battery cells
                        batterycell = { 2 },
                    },
                },
            }
        end

        -- #TODO#
        local spawnPoint = nil

        local prefab = ItemPrefab.GetItemPrefab("mm_rift")
        Entity.Spawner.AddItemToSpawnQueue(prefab, spawnPoint)

        Timer.Wait(function()
            for i = 1, raiderAmount do
                local newRaider = weightedRandom.Choose(availablePlayers)

                rs.SelectedPlayers[newRaider] = { "Raider", {} }

                local key = math.random(#gearSets)
                local gearSet = gearSets[key]

                local info = CharacterInfo("human", tostring(newRaider.Name))

                info.Job = Job(JobPrefab.Get(gearSet.job), false)

                info.TeamID = 2

                info.GiveExperience(info.GetExperienceRequiredForLevel(gearSet.talentLevel))

                for skillID, skillRange in pairs(gearSet.skills) do
                    local skillLevel = math.random(skillRange[1], skillRange[2])
                    info.SetSkillLevel(skillID, skillLevel, false)
                end

                local raiderCharacter = Character.Create(info, spawnPoint, info.Name, 0, false, false)
                raiderCharacter.TeamID = 2

                for gearItemID, tbl in pairs(gearSet.loadout) do
                    local prefab = ItemPrefab.Prefabs[gearItemID]
                    -- tbl[1] is the amount to spawn
                    for p = 1, tbl[1] do
                        Entity.Spawner.AddItemToSpawnQueue(prefab, raiderCharacter.Inventory, nil, nil, function(item)
                            -- Items to spawn in the item
                            if tbl[4] then
                                for gearItemID2, amountToSpawn in pairs(tbl[4]) do
                                    local prefab2 = ItemPrefab.Prefabs[gearItemID2]
                                    for l = 1, amountToSpawn do
                                        Entity.Spawner.AddItemToSpawnQueue(prefab2, item.OwnInventory)
                                    end
                                end
                            end
                            -- tbl[2] is the inventory index to move the item to, for clothing/armor
                            if tbl[2] then
                                raiderCharacter.Inventory.TryPutItem(item, tbl[2], false, false, raiderCharacter, true,
                                    true)
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

                -- Don't use this loadout again, if possible
                if raiderAmount >= #gearSets then
                    table.remove(gearSets, key)
                end
            end

            -- Wait to "start" the raid so that the end round check doesn't think all raiders are dead because they haven't spawned yet
            rs.Started = true
        end, 5000)

        -- Success
        return true, ""
end

return rs
