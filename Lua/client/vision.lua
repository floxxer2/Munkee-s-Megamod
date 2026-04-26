local function exteriorLight(c)
	if Level.Loaded then
    	Level.Loaded.LevelData.GenerationParams.AmbientLightColor = c
	end
end
local function interiorLight(c)
    for _, hull in pairs(Hull.HullList) do
		hull.AmbientLight = c
	end
end

-- NT Eyes client update, optimized for TBG
Hook.Add("think", "Megamod_Client.Vision.Think", function()
    if not Game.RoundStarted then return end

	local ControlledCharacter = Character.Controlled

	if (ControlledCharacter and not ControlledCharacter.IsHuman)
	or Megamod_Client.LightMapOverride.IsMonsterAntagonist then
		-- If we are a monster, always give purple night vision
		exteriorLight(Color(25, 0, 75, 40))
		interiorLight(Color(50, 0, 200, 75))
	elseif (not ControlledCharacter or ControlledCharacter.IsDead == true) then
		-- When not controlling any character, significant night vision
		exteriorLight(Color(50, 50, 50, 20))
		interiorLight(Color(50, 50, 50, 20))
	else
		-- When controlling a human outside of Hunts, no night vision
		-- The vanilla light halo is modified to be a bit larger but dimmer
		exteriorLight(Color(0, 0, 0, 0))
		interiorLight(Color(0, 0, 0, 0))
    end
end)
