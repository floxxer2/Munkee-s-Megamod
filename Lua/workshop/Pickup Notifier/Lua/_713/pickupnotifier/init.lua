
local mod = {}

mod.path = ...
mod.data = require 'workshop.Pickup Notifier.Lua._713.pickupnotifier.data'
mod.utils = require 'workshop.Pickup Notifier.Lua._713.pickupnotifier.utils'

mod.hooks = {}

if CLIENT then
   if Game.IsSingleplayer then
      mod.hooks.client = require 'workshop.Pickup Notifier.Lua._713.pickupnotifier.hooks.client_singleplayer'
   elseif Game.IsMultiplayer then
      mod.hooks.client = require 'workshop.Pickup Notifier.Lua._713.pickupnotifier.hooks.client_multiplayer'
   end

   -- in multiplayer, you get notified of the items you currently have on you
   -- we want to ignore this first 'queue' of items
   Hook.Add('roundStart', 'roundStart', function()
      if Game.IsMultiplayer then
         mod.data.shouldNotify = false
      end
   end)

   Hook.Add('loaded', 'loadSounds', function()
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
      mod.data.shouldNotify = true
   end)

   Hook.Add('think', 'playItemSounds', mod.hooks.client.playItemSounds)
   Hook.Add('think', 'pickupNotifier', mod.hooks.client.pickupNotifier)

   Hook.Patch('dropHoldable', 'Barotrauma.Items.Components.Holdable', 'Drop', {'Barotrauma.Character', 'System.Boolean'},
      mod.hooks.client.onDropped, Hook.HookMethodType.Before)
   Hook.Patch('dropPickable', 'Barotrauma.Items.Components.Pickable', 'Drop', {'Barotrauma.Character', 'System.Boolean'},
      mod.hooks.client.onDropped, Hook.HookMethodType.Before)

   Hook.Patch('onPickedHoldable', 'Barotrauma.Items.Components.Holdable', 'OnPicked', {'Barotrauma.Character'},
      mod.hooks.client.onPicked, Hook.HookMethodType.After)
   Hook.Patch('onPickedPickable', 'Barotrauma.Items.Components.Pickable', 'OnPicked', {'Barotrauma.Character'},
      mod.hooks.client.onPicked, Hook.HookMethodType.After)

   Hook.Patch('onEquippedHoldable', 'Barotrauma.Items.Components.Holdable', 'Equip', {'Barotrauma.Character'},
      mod.hooks.client.onEquip, Hook.HookMethodType.Before)
   Hook.Patch('onEquippedPickable', 'Barotrauma.Items.Components.ItemComponent', 'Equip', {'Barotrauma.Character'},
      mod.hooks.client.onEquip, Hook.HookMethodType.Before)
end

return mod

