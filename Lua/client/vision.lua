local function exteriorLight(c)
    Level.Loaded.LevelData.GenerationParams.AmbientLightColor = c
end
local function interiorLight(c)
    for _, HullLight in pairs(Hull.HullList) do
		HullLight.AmbientLight = c
	end
end

-- NT Eyes client update, optimized for TBG
Hook.Add("think", "Megamod_Client.Vision.Think", function()
    if not Game.RoundStarted then return end

	local ControlledCharacter = Character.Controlled

	-- If we are a monster, always give purple night vision
	if (ControlledCharacter and not ControlledCharacter.IsHuman)
	or Megamod_Client.LightMapOverride.IsMonsterAntagonist then
		exteriorLight(Color(25, 0, 75, 40))
		interiorLight(Color(50, 0, 200, 75))
    elseif Megamod_Client.LightMapOverride.HuntActive
    and (ControlledCharacter and not ControlledCharacter.IsDead) then -- No light at all during Hunts if we are controlling a character
        exteriorLight(Color(0, 0, 0, 0))
		interiorLight(Color(0, 0, 0, 0))
	else -- Normal colors for everything else: VERY slightly visible inside the sub
		exteriorLight(Color(0, 0, 0, 0))
		interiorLight(Color(29, 29, 29, 9))
    end
end)
