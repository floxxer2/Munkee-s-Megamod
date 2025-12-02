
NTBT = {} -- Neurotrauma BrainTrans
NTBT.Name="BrainTrans"
NTBT.Version = "1.0"
NTBT.VersionNum = 01000301
NTBT.MinNTVersion = "A1.8.4h2"
NTBT.MinNTVersionNum = 01080402
NTBT.Path = table.pack(...)[1]
Timer.Wait(function() if NTC ~= nil and NTC.RegisterExpansion ~= nil then NTC.RegisterExpansion(NTBT) end end,1)


dofile(NTBT.Path.."/Lua/Scripts/helperfunctions.lua")

-- server-side code (also run in singleplayer)
if (Game.IsMultiplayer and SERVER) or not Game.IsMultiplayer then

	Timer.Wait(function()
        if NTC == nil then
            print("Error loading NT BrainTrans: It appears Neurotrauma isn't loaded!")
            return
        end
        print("Loading NT BrainTrans")
        dofile(NTBT.Path.."/Lua/Scripts/hooks.lua")
		dofile(NTBT.Path.."/Lua/Scripts/items.lua")
    end,1)
	
end

