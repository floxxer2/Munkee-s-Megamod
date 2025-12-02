if CLIENT and Game.IsMultiplayer then return end

Hook.Patch('AllCharactersGetAi','Barotrauma.Character', 'Create', {
    "Barotrauma.CharacterPrefab",
    "Microsoft.Xna.Framework.Vector2",
    "System.String",
    "Barotrauma.CharacterInfo",
    "System.UInt16",
    "System.Boolean",
    "System.Boolean",
    "System.Boolean",
    "Barotrauma.RagdollParams",
    "System.Boolean"
}, 
function(instance, ptable)
ptable['hasAi'] = true 
end)

Hook.Patch('AddLeftoverCharacterToCrewManager','Barotrauma.Character', 'SetOwnerClient',
function(instance, ptable)
    if ptable['client'] == nil then
        Game.GameSession.CrewManager.AddCharacter(instance)
        -- print("Added to crewmanager: ", instance.Name)
    end
end, Hook.HookMethodType.After)

Hook.Add('roundStart', 'roundStart', function()
    for character in Character.CharacterList do
        character.Info.StartItemsGiven = false
    end

    for item in Item.ItemList do
        if item.Prefab.Identifier == "braintransplant" then
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
    end
end)

Hook.Add('roundEnd', 'roundEnd', function()
    for character in Character.CharacterList do
        character.Info.StartItemsGiven = false
    end
end)