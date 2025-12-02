
local mod = {}

mod.path = ...
mod.data = require 'workshop.Pickup Notifier.Lua._713.pickupnotifier.data'
mod.utils = require 'workshop.Pickup Notifier.Lua._713.pickupnotifier.utils'

mod.hooks = {
   client = CLIENT and require 'workshop.Pickup Notifier.Lua._713.pickupnotifier.hooks.client' or nil
}

if CLIENT then
   
   -- disable pickup notifier on round end, and re-enable it after a delay on round start (for sub editor (and single player?)),
   -- and when the player's character is created (for multiplayer)
   function enableAfterDelay()
      Timer.Wait(function()
         mod.data.shouldPlaySounds = true
         mod.data.shouldNotify = true
      end, 500)
   end
   Hook.Add('roundEnd', 'roundEnd', function()
      mod.data.shouldPlaySounds = false
      mod.data.shouldNotify = false
   end)
   Hook.Add('roundStart', 'roundStart', function() enableAfterDelay() end)
   Hook.Add('character.created', 'character.created', function(character)
      if character == Character.Controlled then
         enableAfterDelay()
      end
   end)

   Hook.Add('loaded', 'loaded', function()
      enableAfterDelay()

      -- load sounds
      -- TODO dry 
      for k,v in pairs(mod.data.sounds.Groups) do
         mod.data.sounds.Groups[k].sounds = mod.utils.loadSounds(k, v, mod.path)
      end
      for k,v in pairs(mod.data.sounds.byIdentifier) do
         mod.data.sounds.byIdentifier[k].sounds = mod.utils.loadSounds(k, v, mod.path)
      end
      for k,v in pairs(mod.data.sounds.byTag) do
         mod.data.sounds.byTag[k].sounds = mod.utils.loadSounds(k, v, mod.path)
      end
      for k,v in pairs(mod.data.sounds.byImpactSoundTag) do
         mod.data.sounds.byImpactSoundTag[k].sounds = mod.utils.loadSounds(k, v, mod.path)
      end
      for k,v in pairs(mod.data.sounds.special) do
         mod.data.sounds.special[k].sounds = mod.utils.loadSounds(k, v, mod.path)
      end

      -- for k,v in pairs(mod.data.sounds) do
      --    mod.data.sounds[k].sounds = mod.utils.loadSounds(k, v, mod.path)
      -- end
   end)

   Hook.Add('think', 'playItemSounds', mod.hooks.client.playItemSounds)
   Hook.Add('think', 'pickupNotifier', mod.hooks.client.pickupNotifier)

   Hook.Add('item.drop', 'trackItemSounds', mod.hooks.client.trackItemSounds)
   Hook.Add('item.drop', 'trackItemNotifications', mod.hooks.client.trackItemNotifications)

end

return mod

