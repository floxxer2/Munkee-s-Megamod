
local data = {}

data.shouldNotify = false
data.shouldPlaySounds = false

data.defaults = {}
data.defaults.gain = 1
data.defaults.range = 400

data.sounds = {}

data.sounds.Groups = {}
data.sounds.byImpactSoundTag = {}
data.sounds.byIdentifier = {}
data.sounds.byTag = {}
data.sounds.special = {}

data.sounds.byImpactSoundTag["impact_soft"] = {
   gain = 0.6,
   index = 4,
}
data.sounds.byImpactSoundTag["impact_metal_light"] = {
   gain = 0.6,
   range = 600,
   index = 4,
}
data.sounds.byImpactSoundTag["impact_metal_heavy"] = {
   gain = 0.7,
   range = 800,
   index = 4,
}
data.sounds.byIdentifier["bikehorn"] = {
   gain = 0.6,
   index = 2,
}
-- TODO better way to do groups 
-- glass bottle sounds (manual list, going by what their sprites look like)
data.sounds.Groups['glass'] = {
   gain = 0.5,
   group = 'glass',
   index = 3,
}
data.sounds.byIdentifier['calcium'] = data.sounds.Groups['glass']
data.sounds.byIdentifier['chlorine'] = data.sounds.Groups['glass']
data.sounds.byIdentifier['ethanol'] = data.sounds.Groups['glass']
data.sounds.byIdentifier['flashpowder'] = data.sounds.Groups['glass']
data.sounds.byIdentifier['lithium'] = data.sounds.Groups['glass']
data.sounds.byIdentifier['magnesium'] = data.sounds.Groups['glass']
data.sounds.byIdentifier['nitroglycerin'] = data.sounds.Groups['glass']
data.sounds.byIdentifier['phosphorus'] = data.sounds.Groups['glass']
data.sounds.byIdentifier['potassium'] = data.sounds.Groups['glass']
data.sounds.byIdentifier['sodium'] = data.sounds.Groups['glass']
data.sounds.byIdentifier['volatilenitroglycerin'] = data.sounds.Groups['glass']
data.sounds.byIdentifier['rum'] = data.sounds.Groups['glass']
data.sounds.byIdentifier['sulphuricacid'] = data.sounds.Groups['glass']
data.sounds.byTag['geneticmaterial'] = data.sounds.Groups['glass']
data.sounds.byTag['unidentifiedgeneticmaterial'] = data.sounds.Groups['glass']

data.sounds.byTag['syringe'] = {
   gain = 0.25,
   index = 3,
}
data.sounds.special["item_shuffle"] = {
   gain = 0.12,
   index = 2,
}

-- overrides, e.g., allow byTag['crate'] to behave like the previously defined byImpactSoundTag['impact_metal_heavy']
data.sounds.overrides = {}
data.sounds.overrides.byImpactSoundTag = {}
data.sounds.overrides.byIdentifier = {}
data.sounds.overrides.byTag = {}

data.sounds.overrides.byIdentifier['opium'] = data.sounds.Groups['glass']
data.sounds.overrides.byTag['wire'] = data.sounds.byImpactSoundTag['impact_soft']

-- blacklist of item identifiers
data.sounds.blacklist = {}
data.sounds.blacklist['smground'] = true
data.sounds.blacklist['smgrounddepletedfuel'] = true
data.sounds.blacklist['hmground'] = true
data.sounds.blacklist['nucleargunbolt'] = true

-- for custom sounds, see Lua/modding_example.lua

return data
