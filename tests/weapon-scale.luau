local Catalog=require('../src/WeaponCatalog')
local geometry=require('@lune/serde').decode('json',require('@lune/fs').readFile('art/weapon-geometry.json'))
for id,limit in {Compact=1.05,SMG=1.8,Shotgun=2.5,Carbine=2.6} do
 local spec=Catalog.get(id)
 assert(spec.Length<=limit,id..' exceeds the handheld silhouette budget')
 local mesh=geometry[spec.Mesh]
 local ratio=(mesh.max[2]-mesh.min[2])/(mesh.max[1]-mesh.min[1])
 assert(spec.Length*ratio<(id=='Compact' and .8 or 1),'Body height fits a resident hand/forearm')
 assert(spec.GripZ>0 and spec.GripZ<.5 and spec.GripY<0,'Grip is on the actual rear handle, below the receiver')
 assert(spec.MuzzleY>spec.GripY,'Barrel remains above the grip')
end
local rb=require('@lune/roblox')
local library=require('../weapon-meshes')(rb.Instance.new('Folder'))
local encoded=rb.serializeModel({library})
local restored=rb.deserializeModel(encoded)[1]
for _,model in restored:GetChildren() do
 assert(model.PrimaryPart and model.PrimaryPart.Name=='Weapon axis','Weapon must retain a stable measurement axis after serialization')
 assert((model.PrimaryPart.CFrame.LookVector-rb.Vector3.new(0,0,-1)).Magnitude<.001,'Weapon length is measured along the barrel')
end
print('PASS handheld weapon silhouette and grip bounds')
