
local hooks = {}
local data = require '_713.pickupnotifier.data'
local utils = require '_713.pickupnotifier.utils'

local notifications = {}
local sounds = {}

local function recordNotification(item, amount)
   local i = notifications[item.Prefab.Identifier.Value] or {
      amount = 0,
      instances = {}
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
   -- check if item has sound defined by its identifier
   local identifier = item.Prefab.Identifier.Value
   -- if an override exists for this identifier, return that instead
   if data.sounds.overrides.byIdentifier[identifier] then
      return data.sounds.overrides.byIdentifier[identifier]
   end
   local byIdentifier = data.sounds.byIdentifier[identifier]
   if byIdentifier ~= nil then
      return byIdentifier
   end

   -- check if item has sound defined by one of its tags
   local byTag = nil
   for tag in string.gmatch(item.tags, '([^,]+)') do
      if data.sounds.overrides.byTag[tag] then
         return data.sounds.overrides.byTag[tag]
      end
      byTag = data.sounds.byTag[tag]
      if byTag ~= nil then
         return byTag
      end
   end

   -- check if item has sound defined by its impactSoundTag
   -- if there is none, use impact_soft for small items and impact_metal_light otherwise
   local impactSoundTag = item.Prefab.ConfigElement.GetAttributeString('ImpactSoundTag', (item.tags:find('smallitem') and 'impact_soft' or 'impact_metal_light'))
   if data.sounds.overrides.byImpactSoundTag[impactSoundTag] then
      return data.sounds.overrides.byImpactSoundTag[impactSoundTag]
   end
   local byImpactSoundTag = data.sounds.byImpactSoundTag[impactSoundTag]
   if byImpactSoundTag ~= nil then
      return byImpactSoundTag
   end

   -- use sound defined by impact_metal_light as a fallback
   return data.sounds.byImpactSoundTag['impact_metal_light']
end

-- 'enqueue' an item sound to play at the specified inventory's position
local function recordSound(item, inventory, override)
   if not item or not inventory then return end

   -- local i = sounds[item.ID] or {
   local i = {
      item = item,
      inventory = inventory,
      sound = override or getSound(item)
   }

   sounds[inventory.Owner] = i
   return i
end

function hooks.trackItemSounds(item, character)
   if not Game.RoundStarted or not data.shouldPlaySounds then return end
   if data.sounds.blacklist[item.Prefab.Identifier.Value] then return end

   -- local previousInventory = utils.getOutermostInventory(item)
   local previousInventory = item.ParentInventory

   Timer.NextFrame(function()
      -- local currentInventory = utils.getOutermostInventory(item)
      local currentInventory = item.ParentInventory
      if previousInventory == nil and currentInventory == nil then return end

      -- always queue shuffling at previous inventory
      recordSound(item, previousInventory, data.sounds.special['item_shuffle'])

      -- queue item specific sound at current inventory
      if currentInventory ~= nil then
         -- ignore if inventories are the same
         if previousInventory ~= currentInventory then
            recordSound(item, currentInventory)
         end
      -- if there is no current inventory (e.g., when dropping an item), try queueing sound if previous inventory exists
      elseif previousInventory ~= nil then
         recordSound(item, previousInventory)
      end
   end)
end

function hooks.playItemSounds()
   if not #sounds or not Game.RoundStarted then return end

   for k,v in pairs(sounds) do
      if sounds[k] ~= nil then
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

-- track items received from or given to other players, or when dropping or picking items from the floor
function hooks.trackItemNotifications(item, character)
   if not Game.RoundStarted or not data.shouldNotify then return end
   if Character.Controlled then
      local previousInventory = utils.getOutermostInventory(item)

      Timer.NextFrame(function()
         local currentInventory = utils.getOutermostInventory(item)
         -- ignore items if moved in the same inventory, or to/from an ItemInventory (e.g., cabinets)
         if currentInventory == previousInventory then return end
         if currentInventory and LuaUserData.IsTargetType(currentInventory, 'Barotrauma.ItemInventory') then return end
         if previousInventory and LuaUserData.IsTargetType(previousInventory, 'Barotrauma.ItemInventory') then return end
         -- also ignore items not being put directly into the character's inventory
         if currentInventory ~= item.ParentInventory then return end
         -- also ignore items being dropped onto the ground
         if currentInventory == nil then return end

         if character == Character.Controlled and currentInventory ~= Character.Controlled.Inventory then
            recordNotification(item, -1)
         elseif currentInventory == Character.Controlled.Inventory then
            recordNotification(item, 1)
         end
      end)
   end
end

-- display if an item (and how many) was picked up/dropped
LuaUserData.RegisterType('Microsoft.Xna.Framework.Color')
function hooks.pickupNotifier()
   if Character.Controlled == nil or not #notifications then return end

   for k,v in pairs(notifications) do
      if notifications[k] ~= nil then
         local str = ItemPrefab.Prefabs[k].Name.Value

         if math.abs(v.amount) > 1 then
            str = str .. ' x' .. math.abs(v.amount)
         end

         if v.amount > 0 then
            str = '+ ' .. str
         else
            str = '- ' .. str
         end

         Character.Controlled.AddMessage(
            str,
            0 < v.amount and Color.RosyBrown or Color.Sienna,
            true,
            nil,
            nil,
            0 < v.amount and 8 or 4
         )
         notifications[k] = nil
      end
   end
end

return hooks
