local rb,fs,serde=require('@lune/roblox'),require('@lune/fs'),require('@lune/serde')
return function(storage)
 local folder=rb.Instance.new('Folder');folder.Name='CombatAnimations';folder.Parent=storage
 local ids=serde.decode('json',fs.readFile('art/assets.json'))
 for name,spec in require('./art/combat-motion') do
  local clip=rb.Instance.new('Animation');clip.Name=name
  clip.AnimationId='rbxassetid://'..assert(ids['combat-'..name],'Unpublished combat animation '..name)
  clip:SetAttribute('Priority',spec.priority);clip:SetAttribute('Loop',spec.loop==true)
  clip:SetAttribute('Duration',spec.frames[#spec.frames][1]);clip.Parent=folder
 end
end
