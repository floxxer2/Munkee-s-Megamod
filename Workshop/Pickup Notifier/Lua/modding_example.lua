
-- for basic compatibility with custom sounds, move this file into Lua/Autorun and edit accordingly
-- this file assumes it will be in Lua/Autorun
-- this file uses DynamicEuropa's rubber ducks as an example
-- feel free to ask questions on the workshop page

local mod = {}
mod.path = ...

local pickupnotifier = require '_713.pickupnotifier.data'

if pickupnotifier then

   -- there are three tables where you can define custom sounds for PickupNotifier to play, in order of priority:
   -- byIdentifier - an item identifier, e.g., 'bikehorn'
   -- byTag - a single tag, e.g., 'crate'
   -- byImpactSoundTag - an impact sound tag, e.g., 'impact_metal_light' or a custom-defined tag

   -- for example, to add a custom sound to DynamicEuropa's rubber ducks, you would do the following:
   pickupnotifier.sounds.byImpactSoundTag['impact_rubberduck'] = {
      gain = 1, -- how loud to play the sound (default is 1 if omitted)
      range = 400, -- how far the sound can be heard (default is 400 or 4 metres if omitted)

      -- path for PickupNotifier to find the files in, this is required (for now)
      path = mod.path,
      -- by default, PickupNotifier will look for /PickupNotifier/Sounds/ in your mod's directory.
      -- use this if your files are kept elsewhere
      -- note the leading and trailing slashes
      -- subdirectory = '/PickupNotifier/Sounds',
      subdirectory = '/Sounds/Impact/',

      -- number of files to load, if your files are predictably named
      -- e.g., impact_rubberduck_1.ogg, impact_rubberduck_2.ogg, etc
      -- index = 2
      index = 0,

      -- if your files are NOT predictably named, you can specify the filenames themselves
      -- note the lack of file extension
      files = {
         'NovevaSqueak',
         'RubberDuck1',
         'RubberDuck2',
         'RubberDuck3',
         'RubberDuck4',
         'RubberDuck5',
      }
   }
end

