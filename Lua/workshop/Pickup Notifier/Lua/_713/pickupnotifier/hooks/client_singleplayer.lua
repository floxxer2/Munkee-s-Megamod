
local hooks = {}
local data = require '_713.pickupnotifier.data'
local utils = require '_713.pickupnotifier.utils'

-- local because there's no reason for people to mess with them
local itemSounds = {}
local notifications = {}
local sounds = {}

local function queueNotification(item, amount)
   local i = notifications[item.Prefab.Identifier.Value] or {
      amount = 0,
      instances = {},
      allowedInAnySlot = utils.isAllowedInAnySlot(item),
   }
   if i.instances[item.ID] == nil then
      i.instances[item.ID] = item
      i.amount = i.amount + amount
      notifications[item.Prefab.Identifier.Value] = i
   end
end

-- get the sound to play for item based on what's defined in data.sounds
-- identifier-specific sounds have priority, followed by tags
-- impact tags are basically used as a fallback
local function getSound(item)
   -- do not look up sound when already known
   if itemSounds[item.Prefab.Identifier.Value] then return itemSounds[item.Prefab.Identifier.Value] end

   -- check if item has sound defined by its identifier
   local identifier = item.Prefab.Identifier.Value
   -- if an override exists for this identifier, return that instead
   if data.sounds.overrides.byIdentifier[identifier] then
      itemSounds[identifier] = data.sounds.overrides.byIdentifier[identifier]
      return itemSounds[identifier]
   end

   local byIdentifier = data.sounds.byIdentifier[identifier]
   if byIdentifier then
      itemSounds[identifier] = byIdentifier
      return byIdentifier
   end

   -- check if item has sound defined by one of its tags
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

   -- check if item has sound defined by its impactSoundTag
   -- if there is none, use impact_soft for small items and impact_metal_light otherwise
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

   -- use sound defined by impact_metal_light as a fallback
   itemSounds[identifier] = data.sounds.byImpactSoundTag['impact_metal_light']
   return itemSounds[identifier]
end

-- queue an item sound to play at the specified item/character's position
local function queueSound(item, owner, override)
   if not item or sounds[owner] then return end
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
         -- local offset = sounds[k].item.Submarine ~= nil and sounds[k].item.Submarine.Position or Vector2(0,0)
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
      local character = ptable['dropper']

      -- ignore if item is spawned in (i.e., no dropper is passed)
      if not character then return end
      queueSound(instance.item, fromInventory and fromInventory.Owner or character, data.sounds.special['item_shuffle'])

      local fromOutermostInventory = fromInventory and utils.getOutermostInventory(fromInventory)
      local intoOutermostInventory = intoInventory and utils.getOutermostInventory(intoInventory)
      local toDifferentInventory = intoOutermostInventory and fromOutermostInventory ~= intoOutermostInventory

      -- this is now unlikely to ever trigger because of the check for dropper, but it's kept just in case
      if not utils.isSelectableContainer(intoInventory or fromInventory) then return end

      -- ignore if item is moved between slots in the same inventory
      if not toDifferentInventory then return end
      ---@diagnostic disable-next-line: need-check-nil
      queueSound(instance.item, intoOutermostInventory.Owner)

      local intoCharacterInventory = intoInventory and LuaUserData.IsTargetType(intoInventory, 'Barotrauma.CharacterInventory')

      -- ignore if item is spawned in an item inventory
      if not intoCharacterInventory then return end

      local fromCharacterInventory = fromInventory and LuaUserData.IsTargetType(fromOutermostInventory, 'Barotrauma.CharacterInventory')
      local intoControlledInventory = intoOutermostInventory == Character.Controlled.Inventory

      local fromOtherCharacterInventory = intoControlledInventory and fromCharacterInventory and toDifferentInventory
      local pickedUpFromFloor = not fromInventory and intoControlledInventory and character
      if fromOtherCharacterInventory or pickedUpFromFloor then
         queueNotification(instance.item, 1)
         return
      end

      local fromControlledInventory = fromOutermostInventory == Character.Controlled.Inventory
      local intoOtherCharacterInventory = fromControlledInventory and intoCharacterInventory and not intoControlledInventory
      if intoOtherCharacterInventory then
         queueNotification(instance.item, -1)
      end
   end)
end

-- used when picking up items from the floor, as Holdable::Drop() is not called in this scenario
function hooks.onPicked(instance, ptable)
   if data.blacklist[instance.item.Prefab.Identifier.Value] then return end
   queueSound(instance.item, ptable['picker'], data.sounds.special['item_shuffle'])
end

-- used when equipping an item, or picking up non-Any slot items
function hooks.onEquip(instance, ptable)
   if data.blacklist[instance.item.Prefab.Identifier.Value] then return end
   -- <Holdable/>s without slots="Any" are equipped when picked up
   if not utils.isAllowedInAnySlot(instance.item) then return end
   queueSound(instance.item, ptable['character'], data.sounds.special['item_shuffle'])
end

-- display if an item (and how many) was picked up/dropped
LuaUserData.RegisterType('Microsoft.Xna.Framework.Color')
function hooks.pickupNotifier()
   if Character.Controlled == nil or not next(notifications) then return end

   for k,v in pairs(notifications) do
      if notifications[k] ~= nil then
         local str = ItemPrefab.Prefabs[k].Name.Value
         str = str .. ' ' .. (v.amount > 0 and '+' or '') .. v.amount
         Character.Controlled.AddMessage(
            str,
            0 < v.amount and Color.RosyBrown or Color.Sienna,
            true,
            nil,
            nil,
            0 < v.amount and 8 or 4
         )
         notifications[k] = nil

         -- if item does not have slots="Any" we can probably ignore the second item
         -- #notifications is normally only ever 2 when picking up an item that can only be carried in Right/LeftHand
         -- while already having an item equipped in any hand (e.g., picking up a crate while holding a screwdriver)
         if not v.allowedInAnySlot and next(notifications) then
            notifications = {}
            return
         end
      end
   end
end

return hooks

