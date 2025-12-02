Timer.Wait(function()
    NT.ItemMethods.organscalpel_brain = function(item, usingCharacter, targetCharacter, limb) 
        local limbtype = limb.type
    
        if limbtype == LimbType.Head and (HF.HasAfflictionLimb(targetCharacter, "retractedskin", limbtype, 1) or HF.HasAfflictionLimb(targetCharacter, "disassembled", limbtype, 1)) then
            local damage = HF.GetAfflictionStrength(targetCharacter, "cerebralhypoxia", 0)
            local removed = HF.GetAfflictionStrength(targetCharacter, "brainremoved", 0)
            
            if removed <= 0 and HF.GetSurgerySkillRequirementMet(usingCharacter, 100) then
                HF.SetAffliction(targetCharacter, "brainremoved", 100, usingCharacter)
                if HF.HasAffliction(targetCharacter, "artificialbrain") then
                    HF.SetAffliction(targetCharacter, "artificialbrain", 0, usingCharacter)
                    damage = 100
                end
    
                if damage < 90 then
                    local postSpawnFunction = function(item, donor, client, accid)
                        item.AddTag("dn=" .. donor.Name)
                        item.AddTag("di=" .. tostring(accid))
                        item.AddTag("dj=" .. tostring(donor.JobIdentifier))
                        item.AddTag("de=" .. tostring(donor.Info.Job.GetSkillLevel(Identifier("electrical"))))
                        item.AddTag("dm=" .. tostring(donor.Info.Job.GetSkillLevel(Identifier("mechanical"))))
                        item.AddTag("dw=" .. tostring(donor.Info.Job.GetSkillLevel(Identifier("weapons"))))
                        item.AddTag("dmed=" .. tostring(donor.Info.Job.GetSkillLevel(Identifier("medical"))))
                        item.AddTag("dh=" .. tostring(donor.Info.Job.GetSkillLevel(Identifier("helm"))))
                        item.AddTag("dex=" .. tostring(donor.Info.ExperiencePoints))
    
                        local talentList = ""
                        for talent in donor.Info.UnlockedTalents do
                            talentList = talentList .. tostring(talent.Value) .. "--"
                        end

                        talentList = talentList:sub(1, -3)
    
                        item.AddTag("dt=" .. talentList)

                        local description = ""
                        for tag in item.GetTags() do
                            tag = tostring(tag)
                            if string.find(tag, "dn=") then
                                description = description .. "Client name: " .. tag:sub(4) .. "\n"
                            elseif string.find(tag, "di=") then
                                description = description .. "Account ID: " .. tag:sub(4) .. "\n"
                            elseif string.find(tag, "dj=") then
                                description = description .. "Client job identifier: " .. tag:sub(4) .. "\n"
                            elseif string.find(tag, "de=") then 
                                description = description .. "Electrical skill: " .. tag:sub(4) .. "\n"
                            elseif string.find(tag, "dm=") then
                                description = description .. "Mechanical skill: " .. tag:sub(4) .. "\n"
                            elseif string.find(tag, "dw=") then
                                description = description .. "Weapons skill: " .. tag:sub(4) .. "\n"
                            elseif string.find(tag, "dmed=") then
                                description = description .. "Medical skill: " .. tag:sub(6) .. "\n"
                            elseif string.find(tag, "dh=") then
                                description = description .. "Helm skill: " .. tag:sub(4) .. "\n"
                            elseif string.find(tag, "dex=") then
                                description = description .. "Experience points: " .. tag:sub(5) .. "\n"
                            elseif string.find(tag, "dt=") then
                                description = description .. "Talent list: " .. tag:sub(4) .. "\n"
                            end
                        end
                        item.Description = description
                    end
    
                    if SERVER or (CLIENT and not Game.IsMultiplayer) then
                        local prefab = ItemPrefab.GetItemPrefab("braintransplant")
                        local client = targetCharacter.IsBot and targetCharacter or HF.CharacterToClient(targetCharacter)
    
                        Entity.Spawner.AddItemToSpawnQueue(prefab, usingCharacter.WorldPosition, nil, nil, function(item)
                            usingCharacter.Inventory.TryPutItem(item, nil, {InvSlotType.Any})
                            local accid = NTBT.GetAccountID(targetCharacter)
                            postSpawnFunction(item, targetCharacter, client, accid)
                        
                            if SERVER and client ~= nil then
                                client.SetClientCharacter(nil)
                            end
                        end)
                    end
                else
                    HF.AddAfflictionLimb(targetCharacter, "bleeding", limbtype, 15, usingCharacter)
                    HF.AddAffliction(targetCharacter, "cerebralhypoxia", 50, usingCharacter)
                end
    
                HF.GiveItem(targetCharacter, "ntsfx_slash")
            end
        end
    end
    
    NT.ItemMethods.braintransplant = function(item, usingCharacter, targetCharacter, limb) 
        local limbtype = limb.type
        local conditionmodifier = HF.GetSurgerySkillRequirementMet(usingCharacter, 100) and 0 or -40
        local workcondition = HF.Clamp(item.Condition + conditionmodifier, 0, 100)
        
        if HF.HasAffliction(targetCharacter, "brainremoved", 1) and limbtype == LimbType.Head then
            HF.AddAffliction(targetCharacter, "cerebralhypoxia", -workcondition, usingCharacter)
            HF.SetAffliction(targetCharacter, "brainremoved", 0, usingCharacter)

    
            if SERVER or (CLIENT and not Game.IsMultiplayer) then
                local clientName, clientJobIdentifier, electricalSkill, mechanicalSkill, weaponsSkill, medicalSkill, helmSkill, experiencePoints, rawtalentList, talentList = "", "", 0, 0, 0, 0, 0, 0, "", {}
                local tags = item.GetTags()

                for tag in tags do
                    tag = tostring(tag)
                    if string.find(tag, "dn=") then
                        clientName = tag:sub(4)
                    elseif string.find(tag, "di=") then
                        accountID = tag:sub(4)
                    elseif string.find(tag, "dj=") then
                        clientJobIdentifier = tag:sub(4)
                    elseif string.find(tag, "de=") then
                        electricalSkill = tag:sub(4)
                    elseif string.find(tag, "dm=") then
                        mechanicalSkill = tag:sub(4)
                    elseif string.find(tag, "dw=") then
                        weaponsSkill = tag:sub(4)
                    elseif string.find(tag, "dmed=") then
                        medicalSkill = tag:sub(6)
                    elseif string.find(tag, "dh=") then
                        helmSkill = tag:sub(4)
                    elseif string.find(tag, "dex=") then
                        experiencePoints = tag:sub(5)
                    elseif string.find(tag, "dt=") then
                        rawtalentList = tag:sub(4)
                        for talent in string.gmatch(rawtalentList, "([^%-]+)") do
                            table.insert(talentList, talent)
                        end
                    end
                end

                NTBT.ChangeJob(targetCharacter, clientJobIdentifier, {
                    [Identifier("electrical")] = electricalSkill,
                    [Identifier("mechanical")] = mechanicalSkill,
                    [Identifier("weapons")] = weaponsSkill,
                    [Identifier("medical")] = medicalSkill,
                    [Identifier("helm")] = helmSkill
                }, experiencePoints, talentList, clientName, accountID)
                
            end
    
            HF.RemoveItem(item)
        end
    end
end,1000)

