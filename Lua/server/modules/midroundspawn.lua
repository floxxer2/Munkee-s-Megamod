local mrs = {}

mrs.SpawnedPlayers = {}

-- Only one captain can spawn per round
mrs.AllowCaptain = true

function mrs.SpawnPlayer(client)
    if not client then return end
    if not client.InGame then
        Megamod.SendChatMessage(client, "You can't be in the lobby. Join the round first.", Color(255, 0, 255, 255))
        return
    end
    if Megamod.CheckIsSpectating(client) then
        if not mrs.SpawnedPlayers[client.SteamID] then
            local jobPrefab, jobVariant
            if client.JobPreferences and #client.JobPreferences > 0 then
                local onlyHasCaptain = true
                for pref in client.JobPreferences do
                    if tostring(pref.Prefab.Identifier) ~= "captain" then
                        onlyHasCaptain = false
                        break
                    end
                end
                if not mrs.AllowCaptain and onlyHasCaptain then
                    Megamod.SendChatMessage(client, "There was already a captain this round. Return to the lobby and choose another job!", Color(255, 0, 255, 255))
                    return
                else
                    for pref in client.JobPreferences do
                        if not mrs.AllowCaptain and tostring(pref.Prefab.Identifier) ~= "captain" then
                            -- Choose the first job pref that isn't captain
                            jobPrefab = pref.Prefab
                            jobVariant = pref.Variant
                            break
                        elseif mrs.AllowCaptain then
                            -- Choose the first job pref (captain allowed)
                            jobPrefab = pref.Prefab
                            jobVariant = pref.Variant
                            break
                        end
                    end
                end
            else
                Megamod.SendChatMessage(client, "You must choose a job in the lobby before midround spawning.", Color(255, 0, 255, 255))
                return
            end
            local info = CharacterInfo("Human", client.Name, client.Name, jobPrefab, jobVariant, nil, nil)
            if client.CharacterInfo and client.CharacterInfo.Head then -- Sometimes these aren't set?? If not set, info.Head will be randomized
                info.Head = client.CharacterInfo.Head -- This copies over all of the client's cosmetic choices (hair, skin color, etc.)
            end
            local spawnPoints = WayPoint.SelectCrewSpawnPoints({info}, Submarine.MainSub)
            if #spawnPoints == 0 then
                Megamod.SendChatMessage(client, "No spawnpoints available!", Color(255, 0, 255, 255))
                Megamod.Error("No MRS spawnpoints available for client '" .. tostring(client.Name) .. "'")
                return
            end
            local spawnPoint = spawnPoints[math.random(#spawnPoints)]
            local char = Character.Create("Human", spawnPoint.WorldPosition, "e", info, 0, true, false, true, info.Ragdoll, true, false)
            char.TeamID = CharacterTeamType.Team1
            char.GiveJobItems(false, spawnPoint)
            -- Give pressure resistance
            local prefab = AfflictionPrefab.Prefabs["pressurestabilized"]
            local limb = char.AnimController.GetLimb(LimbType.Torso)
            char.CharacterHealth.ApplyAffliction(limb, prefab.Instantiate(180))
            -- Make their idcard noninteractable if it's a silly round
            if Megamod.RuleSetManager.RoundType == 2 then
                for item in char.Inventory.GetAllItems(false) do
                    if item.HasTag("identitycard") then
                        Megamod.CreateEntityEvent(item, item, "NonInteractable", true)
                        break
                    end
                end
            end
            client.SetClientCharacter(char)
            -- Allow infinite spawns and captains if it's a silly round
            if Megamod.RuleSetManager.RoundType ~= 2 then
                mrs.SpawnedPlayers[client.SteamID] = client
                if tostring(jobPrefab.Identifier) == "captain" then
                    mrs.AllowCaptain = false
                end
            end
            Megamod.Log("Client '" .. tostring(client.Name) .. "' midround spawned as '" .. tostring(jobPrefab.Identifier) .. ".'", true)
        else
            Megamod.SendChatMessage(client, "You have already spawned this round.", Color(255, 0, 255, 255))
        end
    else
        Megamod.SendChatMessage(client, "You cannot midround spawn while alive!", Color(255, 0, 255, 255))
    end
end

-- Notify people that they can use !mrs
Hook.Add("client.connected", "Megamod.MidRoundSpawn.ClientConnected", function(client)
    Timer.Wait(function()
        if client and Game.RoundStarted and Megamod.CheckIsDead(client) and not mrs.SpawnedPlayers[client.SteamID] then
            local str = "You are eligible to use the chat command \"!mrs\" to spawn midround.\nNote that you must choose a job.\n"
            if mrs.AllowCaptain then
                str = str .. "You may spawn as captain."
            else
                str = str .. "There was already a captain, so you can't spawn as captain."
            end
            Megamod.SendChatMessage(client, str, Color(255, 0, 255, 255))
        end
    end, 10000)
end)

-- Add the players who were there on roundstart to mrs.SpawnedPlayers,
-- regardless of whether they are dead or alive (spectators can't decide to hop in)
function mrs.Start()
    Timer.Wait(function() -- Wait for the rulesetmanager to declare round type
        if Megamod.RuleSetManager.RoundType ~= 2 then -- Not in silly rounds
            for client in Client.ClientList do
                mrs.SpawnedPlayers[client.SteamID] = client
                if mrs.AllowCaptain
                and client.Character
                and tostring(client.Character.JobIdentifier) == "captain" then
                    mrs.AllowCaptain = false
                end
            end
        end
    end, 1000)
end
Hook.Add("roundStart", "Megamod.MidRoundSpawn.RoundStart", mrs.Start)

function mrs.Reset()
    mrs.SpawnedPlayers = {}
    mrs.AllowCaptain = true
end
Hook.Add("roundEnd", "Megamod.MidRoundSpawn.RoundEnd", mrs.Reset)

return mrs
