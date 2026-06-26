
-- see client_multiplayer.lua for function descriptions
-- comments here will mostly point out differences between singleplayer and multiplayer
-- one of these days I'll merge the two client_*player files,
-- but I'm not sure I want a bunch of `if Game.IsMultiplayer then ... end` statements

local hooks = {}
local data = require 'workshop.Pickup Notifier.Lua._713.pickupnotifier.data'
local utils = require 'workshop.Pickup Notifier.Lua._713.pickupnotifier.utils'

local itemSounds = {}
local itemsPickedUp = {}
local sounds = {}

local function queueNotification(item, dropped)
   local allowedInAnySlot = utils.isAllowedInAnySlot(item)
   local i = {
      item = item,
      dropped = dropped,
      allowedInAnySlot = allowedInAnySlot
   }

   if not allowedInAnySlot then
      table.insert(itemsPickedUp, 1, i)
   else table.insert(itemsPickedUp, i) end
end

local function getSound(item)
   if itemSounds[item.Prefab.Identifier.Value] then return itemSounds[item.Prefab.Identifier.Value] end
   local identifier = item.Prefab.Identifier.Value
   if data.sounds.overrides.byIdentifier[identifier] then
      itemSounds[identifier] = data.sounds.overrides.byIdentifier[identifier]
      return itemSounds[identifier]
   end
   local byIdentifier = data.sounds.byIdentifier[identifier]
   if byIdentifier then
      itemSounds[identifier] = byIdentifier
      return byIdentifier
   end
   local byTag = nil
   for tag in string.gmatch(item.tags, '([^,]+)') do
      if data.sounds.overrides.byTag[tag] then
         itemSounds[identifier] = data.sounds.overrides.byTag[tag]
         return itemSounds[identifier]
      end
      byTag = data.sounds.byTag[tag]
      if byTag then
         itemSounds[identifier] = byTag
         return byTag
      end
   end
   local impactSoundTag = item.Prefab.ConfigElement.GetAttributeString('ImpactSoundTag', (item.tags:find('smallitem') and 'impact_soft' or 'impact_metal_light'))
   if data.sounds.overrides.byImpactSoundTag[impactSoundTag] then
      itemSounds[identifier] = data.sounds.overrides.byImpactSoundTag[impactSoundTag]
      return itemSounds[identifier]
   end
   local byImpactSoundTag = data.sounds.byImpactSoundTag[impactSoundTag]
   if byImpactSoundTag then
      itemSounds[identifier] = byImpactSoundTag
      return byImpactSoundTag
   end
   itemSounds[identifier] = data.sounds.byImpactSoundTag['impact_metal_light']
   return itemSounds[identifier]
end

local function queueSound(item, owner, override, fallbackOwner)
   if not data.shouldNotify or not item or not owner then return end
   if sounds[owner] then
      if fallbackOwner then
         if sounds[fallbackOwner] then
            return
         else
            owner = fallbackOwner
         end
      else return end
   end
   local i = {
      item = item,
      sound = override or getSound(item)
   }
   sounds[owner] = i
   return i
end

function hooks.playItemSounds()
   if not next(sounds) or not Game.RoundStarted then return end
   for k,v in pairs(sounds) do
      if sounds[k] then
         local soundInfo = v.sound
         if soundInfo.sounds == nil then
            local item = tostring(sounds[k].item)
            sounds[k] = nil
            assert(soundInfo.sounds ~= nil, 'no soundInfo found for item '.. item)
         end
         local sound = soundInfo.sounds[math.random(#soundInfo.sounds)]
         if sound then
            sound.Play(soundInfo.gain or data.defaults.gain, soundInfo.range or data.defaults.range, sounds[k].item.WorldPosition)
         end
         sounds[k] = nil
      end
   end
end

function hooks.onDropped(instance, ptable)
   if not Game.RoundStarted then return end
   if data.blacklist[instance.item.Prefab.Identifier.Value] then return end
   local fromInventory = instance.item.ParentInventory or instance.item.FindParentInventory()
   Timer.NextFrame(function()
      local intoInventory = instance.item.ParentInventory or instance.item.FindParentInventory()
      local character = ptable['dropper'] -- may be nil if not Character.Controlled
      -- just give up
      if not fromInventory and not intoInventory then return end
      -- use either inventory if dropper is nil
      if fromInventory or intoInventory then
         character = (fromInventory or intoInventory).Owner
         -- ignore creatures
         if LuaUserData.IsTargetType(character, 'Barotrauma.Character') and not character.IsHuman then return end
      end
      -- ignore if item is in an unselectable container
      if not utils.isSelectableContainer(intoInventory or fromInventory) then return end
      queueSound(instance.item, fromInventory and fromInventory.Owner or character, data.sounds.special['item_shuffle'])
      local fromOutermostInventory = fromInventory and utils.getOutermostInventory(fromInventory)
      local intoOutermostInventory = intoInventory and utils.getOutermostInventory(intoInventory)
      local toDifferentInventory = fromInventory ~= nil and intoOutermostInventory ~= nil and fromOutermostInventory ~= intoOutermostInventory

      if toDifferentInventory and intoOutermostInventory then
         queueSound(instance.item, intoOutermostInventory.Owner, nil, fromOutermostInventory)
      end
      local intoCharacterInventory = intoInventory and LuaUserData.IsTargetType(intoInventory, 'Barotrauma.CharacterInventory')

      -- return if item is not being placed into a character inventory
      -- or in some occasions during loading where the client doesn't have control of a character yet
      if not intoCharacterInventory or not Character.Controlled then return end

      local fromCharacterInventory = fromInventory and LuaUserData.IsTargetType(fromOutermostInventory, 'Barotrauma.CharacterInventory')
      local intoControlledInventory = intoOutermostInventory == Character.Controlled.Inventory

      local fromOtherCharacterInventory = intoControlledInventory and fromCharacterInventory and toDifferentInventory
      local pickedUpFromFloor = not fromInventory and intoControlledInventory and character
      if fromOtherCharacterInventory or pickedUpFromFloor then
         queueNotification(instance.item)
         return
      end
      local fromControlledInventory = toDifferentInventory and fromOutermostInventory == Character.Controlled.Inventory
      local intoOtherCharacterInventory = fromControlledInventory and intoCharacterInventory and not intoControlledInventory
      if intoOtherCharacterInventory then
         queueNotification(instance.item, true)
      end
   end)
end

function hooks.onPicked(instance, ptable)
   if data.blacklist[instance.item.Prefab.Identifier.Value] or not ptable['picker'] then return end
   queueSound(instance.item, ptable['picker'], data.sounds.special['item_shuffle'])
end

function hooks.onEquip(instance, ptable)
   if data.blacklist[instance.item.Prefab.Identifier.Value] then return end
   if not utils.isAllowedInAnySlot(instance.item) or not ptable['character'] then return end
   queueSound(instance.item, ptable['character'], data.sounds.special['item_shuffle'])
end

LuaUserData.RegisterType('Microsoft.Xna.Framework.Color')
function hooks.pickupNotifier()
   if Character.Controlled == nil or #itemsPickedUp == 0 then return end
   -- if we somehow end up here while shouldNotify is still false,
   -- the round probably just started and the queue contains your current items.
   -- if so, ignore the queue and toggle shouldNotify
   if not data.shouldNotify then
      itemsPickedUp = {}
      data.shouldNotify = true
      return
   end

   -- loop through items picked up, decrementing value if item was dropped and incrementing otherwise
   local notifications = {}
   for i in itemsPickedUp do
      local identifier = i.item.Prefab.Identifier.Value
      local amount = i.dropped and -1 or 1

      notifications[identifier] = (notifications[identifier] or 0) + amount
      -- break out of building notifications if item is two-handed or hand-only item
      if not i.allowedInAnySlot then
         break
      end
   end
   itemsPickedUp = {}

   for k,v in pairs(notifications) do
      local str = ItemPrefab.Prefabs[k].Name.Value
      str = str .. ' ' .. (0 < v and '+' or '') .. v
      Character.Controlled.AddMessage(
         str,
         0 < v and Color.RosyBrown or Color.Sienna,
         true,
         nil,
         nil,
         0 < v and 8 or 6
      )
   end
   notifications = {}
end

return hooks

