
local utils = {}
local data = require 'workshop.Pickup Notifier.Lua._713.pickupnotifier.data'

local function fileExists(filename)
   if File.Exists(filename) then return true end
   error('Sound file does not exist: ' .. filename, 2)
end

function utils.getOutermostInventory(inventory)
   if not inventory then return end

   local owner = inventory.Owner
   while owner do
      if (inventory and LuaUserData.IsTargetType(inventory, 'Barotrauma.CharacterInventory'))
      or (owner and not owner.ParentInventory) then
         return inventory
      end
      owner = inventory.Owner
      inventory = owner.ParentInventory
   end
   return inventory
end

-- TODO check if we need to worry about reloading the same file multiple times
function utils.loadSounds(id, info, path)
   if info._loaded and info.group then
      return data.sounds.Groups[info.group].sounds
   end

   local subdirectory = "/Workshop/Pickup Notifier/PickupNotifier/Sounds/"
   local sounds = {}

   -- load predictable files from index
   if info.index and 0 < info.index then
      for i = 1, info.index do
         local filename = (info.path or path) .. subdirectory .. id .. "_" .. i .. ".ogg"
         if fileExists(filename) then
            table.insert(sounds, Game.SoundManager.LoadSound(filename))
         end
      end
   end

   -- load from files
   if info.files and #info.files then
      for file in info.files do
         local filename = (info.path or path) .. subdirectory .. file .. ".ogg"
         if fileExists(filename) then
            table.insert(sounds, Game.SoundManager.LoadSound(filename))
         end
      end
   end

   info._loaded = true

   return sounds
end

function utils.isSelectableContainer(inventory)
   if not inventory then return false end
   if LuaUserData.IsTargetType(inventory, 'Barotrauma.ItemInventory') then
      local container = inventory.Owner.GetComponentString('ItemContainer')
      return container and container.IsAccessible() and container.DrawInventory
   end
   return true
end

function utils.isAllowedInAnySlot(item)
   local holdable = item.GetComponentString('Holdable') or item.GetComponentString('Pickable')
   if holdable == nil then return false end
   local allowedSlots = holdable.AllowedSlots
   local hasAny = false

   for _,slot in pairs(allowedSlots) do
      if slot == InvSlotType.Any then
         hasAny = true
         break
      end
   end

   return hasAny
end

 return utils

