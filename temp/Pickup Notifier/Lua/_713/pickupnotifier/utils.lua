
local utils = {}
local data = require '_713.pickupnotifier.data'

local function fileExists(filename)
   if File.Exists(filename) then return true end
   error('Sound file does not exist: ' .. filename, 2)
end

function utils.getOutermostInventory(item)
   local o = item
   local inventory = item.ParentInventory
   if inventory ~= nil then
      while o ~= nil and not LuaUserData.IsTargetType(inventory, 'Barotrauma.CharacterInventory') and o.ParentInventory ~= nil do
         o = o.ParentInventory.Owner
         if LuaUserData.IsTargetType(o, 'Barotrauma.Character') then
            inventory = o.Inventory
         else
            inventory = o.OwnInventory
         end
      end
   end
   return inventory
end

-- TODO check if we need to worry about reloading the same file multiple times
function utils.loadSounds(id, info, path)
   if info._loaded and info.group then
      return data.sounds.Groups[info.group].sounds
   end

   local subdirectory = info.subdirectory or "/PickupNotifier/Sounds/"
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

 return utils
