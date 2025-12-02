LuaUserData.RegisterType("TalentManagerMod.TalentManager")
local CSModS = ModStore.GetCsStore("TalentManagerMod.TalentManager")
local NTBTCS = CSModS.Get("Instance")

function NTBT.ChangeJob(character, newJobIdentifier, skills, experience, talents, clientName, accountID)
    if not character or newJobIdentifier == "" then return end

    local newJobPrefab = JobPrefab.Get(newJobIdentifier)
    if not newJobPrefab then return end

    local newJob = Job(newJobPrefab,false)

    NTBTCS.ClearTalents(character)

    character.Info.Job = newJob
    
    character.Info.SetExperience(tonumber(experience))

    for _, talent in ipairs(talents) do        
        character.GiveTalent(Identifier(talent), true)
    end
    
    for skill, level in pairs(skills) do
        character.Info.SetSkillLevel(tostring(skill), tonumber(level), false)
    end

    if SERVER then
        local client = NTBT.ClientFromAccountID(accountID)

        if client then
            client.SetClientCharacter(character)
        end

        local updateMessage = Networking.Start("UpdateJob")
        updateMessage.WriteUInt16(character.ID)
        updateMessage.WriteString(newJobIdentifier)

        updateMessage.WriteUInt16(#talents)
        for _, talent in ipairs(talents) do
            updateMessage.WriteString(talent)
        end
    
        updateMessage.WriteUInt16(#skills)
        for skill, level in pairs(skills) do
            updateMessage.WriteString(skill)
            updateMessage.WriteString(level)
        end
        -- Timer.Wait(function()
            for client in Client.ClientList do
                Networking.Send(updateMessage, client.Connection)
            end
        -- end,1000)
    end
end

function NTBT.ClientFromAccountID(accountID)
    if not SERVER then return nil end

    for client in Client.ClientList do
        if tostring(client.AccountId) == accountID then
            return client
        end
    end

    return nil
end

function NTBT.GetAccountID(character)
    if not SERVER then return nil end

    if not character.IsPlayer then return "bot" end
    
    for client in Client.ClientList do
        if client.Character and client.Character.Name == character.Name then
            return client.AccountId
        end
    end

    return nil
end

if CLIENT then
    Networking.Receive("UpdateJob", function(message)
        print("UpdateJob")
        local characterID = message.ReadUInt16()
        local newJobIdentifier = message.ReadString()

        local talents = {}
        local talentsCount = message.ReadUInt16()
        for i = 1, talentsCount do
            table.insert(talents, message.ReadString())
        end

        local skills = {}
        local skillsCount = message.ReadUInt16()
        for i = 1, 5 do
            local skill = message.ReadString()
            local level = message.ReadString()
            skills[skill] = level
        end

        local CharacterList = Character.CharacterList
        for _, character in pairs(CharacterList) do
            if characterID == character.ID then
                local newJobPrefab = JobPrefab.Get(newJobIdentifier)
                if newJobPrefab then
                    character.Info.Job = Job(newJobPrefab, false)
                end
                NTBTCS.ClearTalents(character)
                for _, talent in ipairs(talents) do
                    character.GiveTalent(Identifier(talent), true)
                end
                for skill, level in pairs(skills) do
                    character.Info.SetSkillLevel(tostring(skill), tonumber(level), false)
                end
            end
        end
    end)
end


