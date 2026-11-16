local rb = require('@lune/roblox')
local fs = require('@lune/fs')
local path = require('@lune/process').args[1] or 'Northside Baltimore - Heritage Harbor.rbxl'
local game=rb.deserializePlace(fs.readFile(path))
local city=game:GetService('Workspace').Baltimore
local starter=game:GetService('StarterPlayer')
local hall=assert(city:FindFirstChild('Civic clock tower',true))
for _,piece in {'Council entrance','Copper dome','Lantern finial','Council gallery bench','Portico capital'} do
 assert(hall:FindFirstChild(piece,true),'Missing civic architecture: '..piece)
end
local styles=game:GetService('ReplicatedStorage').StreetStyle
for _,key in {'mouth-level','mouth-smile','mouth-set','washed-denim','canvas-trousers'} do
 assert(styles:GetAttribute(key),'Missing separate appearance layer: '..key)
end
assert(not game:GetService('Players').CharacterAutoLoads and not starter.LoadCharacterAppearance)
assert(starter.StarterCharacter:GetAttribute('GameOwnedRig') and game:GetService('ReplicatedStorage').ResidentRig.Humanoid)

for _,model in {starter.StarterCharacter,game:GetService('ReplicatedStorage').ResidentRig} do
 local connected={[model.HumanoidRootPart]=true}
 local motors={}
 for _,v in model:GetDescendants() do if v:IsA('Motor6D') then table.insert(motors,v) end end
 for _=1,#motors do
  for _,m in motors do
   assert(m.Part0 and m.Part1 and m.Part0.Parent==model and m.Part1.Parent==model,'Dangling motor')
   if connected[m.Part0] then connected[m.Part1]=true end
  end
 end
 assert(#motors==15 and model.Humanoid.RigType==rb.Enum.HumanoidRigType.R15)
 for _,v in model:GetChildren() do if v:IsA('BasePart') then assert(connected[v],'Detached R15 limb '..v.Name) end end
end

local function find(name)
 return assert(city:FindFirstChild(name,true),name..' missing from built city')
end
assert(city:GetAttribute('ReleaseChannel')=='Alpha','Release channel missing')
local ship = find('USS Constellation')
local masts = 0
for _,part in ship:GetChildren() do
 if part:IsA('BasePart') then
  for _,value in {part.CFrame:GetComponents()} do assert(math.abs(value)<math.huge,'Invalid transform on '..part.Name) end
 end
 if part.Name=='Lower mast' then masts+=1 end
end
assert(masts==3 and ship:FindFirstChild('Boarding ramp'))
assert(find('Seven Foot Knoll Lighthouse'):FindFirstChild('Lantern glazing'))
local art = {}
for _,gui in city:GetDescendants() do
 if gui.Name=='Alley paint' then
  local collection=assert(gui:GetAttribute('ArtCollection'),'missing mural collection')
  art[collection]=art[collection] or {}
  art[collection][gui:GetAttribute('Cell')]=true
 end
end
for collection,count in {['block-marks']=4,['alley-walls']=4,['athlete-paint']=2,['baltimore-history']=1} do
 for cell=1,count do assert(art[collection] and art[collection][cell],collection..' cell '..cell..' missing') end
end
print('PASS: both harbor landmarks and every mural design in the built place')
