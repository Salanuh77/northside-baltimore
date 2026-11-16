local rb=require('@lune/roblox')
local fs=require('@lune/fs')
local luau=require('@lune/luau')
local profiles=rb.deserializeModel(fs.readFile('art/resident-profiles.rbxm'))[1]
local env={game={ReplicatedStorage={ResidentProfiles=profiles}}}
for _,key in {'Vector3','Instance','CFrame','Color3','Enum'} do env[key]=rb[key] end
local Portrait=luau.load(fs.readFile('src/ResidentPortrait.luau'),{environment=env,injectGlobals=true})()
local art=rb.Instance.new('ModuleScript')
local assets=require('@lune/serde').decode('json',fs.readFile('art/assets.json'))
for key,id in assets do art:SetAttribute(key,id) end
local head=rb.Instance.new('Part');head.Size=rb.Vector3.new(1.48,1.08,1.10)
for _,shape in Portrait.Shapes do
 local source=profiles:FindFirstChild(shape,true)
 -- The imported nose moves the bounding center toward +Z in Roblox's mesh coordinates.
 assert(source.CFrame.Position.Z>.07 and source.CFrame.Position.Z<.09,shape..' import convention changed')
 for _,yaw in {0,.63,math.pi} do
  head.CFrame=rb.CFrame.Angles(0,yaw,0)
  Portrait.draw(head,{FaceShape=shape},art,rb.Color3.fromRGB(165,115,86),rb.Color3.new(0,0,0),rb.Color3.new(0,0,0))
  local skin=head:FindFirstChild('Head sculpt',true)
  local noseDirection=skin.CFrame.ZVector
  assert(noseDirection:Dot(head.CFrame.LookVector)>.999,shape..' points its nose away from its eyes and lips')
  for _,name in {'Resident face','Resident mouth'} do
   local plate=head:FindFirstChild(name,true).Parent
   assert(plate.CFrame.LookVector:Dot(noseDirection)>.80,name..' points away from the nose')
  end
 end
end
print('PASS all six imported noses face their eye and lip artwork at three headings')
