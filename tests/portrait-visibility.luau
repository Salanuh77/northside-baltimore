local rb=require('@lune/roblox')
local fs=require('@lune/fs')
local luau=require('@lune/luau')
local profiles=rb.deserializeModel(fs.readFile('art/resident-profiles.rbxm'))[1]
local features=rb.deserializeModel(fs.readFile('art/resident-features.rbxm'))[1]
local bounds=require('@lune/serde').decode('json',fs.readFile('art/feature-bounds.json'))
for name,box in bounds do features:FindFirstChild(name,true):SetAttribute('FeatureCenter',rb.Vector3.new(table.unpack(box.center))) end
local env={game={ReplicatedStorage={ResidentProfiles=profiles,ResidentFeatures=features}}}
for _,key in {'Vector3','Instance','CFrame','Color3','Enum'} do env[key]=rb[key] end
local Portrait=luau.load(fs.readFile('src/ResidentPortrait.luau'),{environment=env,injectGlobals=true})()
local art=rb.Instance.new('ModuleScript')
local assets=require('@lune/serde').decode('json',fs.readFile('art/assets.json'))
env.game.ReplicatedStorage.ResidentFaceMaterials=require('../face-materials')(rb,nil,assets)
for key,id in assets do art:SetAttribute(key,id) end
local head=rb.Instance.new('Part');head.Size=rb.Vector3.new(1.48,1.08,1.10)
local count=0
for _,shape in Portrait.Shapes do
 for _,spacing in Portrait.Spacings do
  for _,lip in Portrait.Lips do
   Portrait.draw(head,{FaceShape=shape,EyeSpacing=spacing,LipFullness=lip},art,rb.Color3.fromRGB(165,115,86),rb.Color3.new(0,0,0),rb.Color3.new(0,0,0))
   for _,name in {'Resident face','Resident mouth'} do
    local feature=head:FindFirstChild(name,true)
    local material=feature:FindFirstChildOfClass('SurfaceAppearance')
    assert(material and material.AlphaMode==rb.Enum.AlphaMode.Transparency,name..' renders an opaque black panel instead of cutout facial artwork')
    assert(material.ColorMap:match('^rbxassetid://%d+$'),name..' has no artwork')
    assert(feature.Transparency==0 and feature.MeshContent.Uri~='',name..' has no visible conforming surface')
   end
   count+=1
  end
 end
end
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
   local plate=head:FindFirstChild(name,true)
   assert(plate:IsA('MeshPart') and plate.Size.Z>.03,name..' is a flat card')
   assert(plate.CFrame.ZVector:Dot(noseDirection)>.999,name..' points away from the nose')
   assert(not plate.CanCollide and not plate.CanQuery and not plate.CastShadow,name..' interferes with play')
  end
 end
end
print('PASS',count,'face/eye/lip combinations and six sculpted faces at three headings')
