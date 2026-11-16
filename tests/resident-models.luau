local rb=require('@lune/roblox')
local fs=require('@lune/fs')
local serde=require('@lune/serde')
local imported=rb.deserializeModel(fs.readFile('art/resident-profiles.rbxm'))[1]
local geometry={}
for _,name in {'Oval','Round','Square','Diamond','Oblong','Heart'} do
 local head=assert(imported:FindFirstChild(name,true),name)
 assert(head:IsA('MeshPart') and head.Size.Y>.99 and head.Size.Z>1,name..' lacks a sculpted face')
 assert(head.MeshContent.Uri~='' and not geometry[head.MeshContent.Uri],name..' shares another head mesh')
 geometry[head.MeshContent.Uri]=true
end
local grooms=rb.deserializeModel(fs.readFile('art/resident-grooms.rbxm'))[1]
local bounds=serde.decode('json',fs.readFile('art/groom-bounds.json'))
for name,box in bounds do
 local hair=assert(grooms:FindFirstChild(name,true),name)
 assert(not geometry[hair.MeshContent.Uri] and hair.MeshContent.Uri~='',name..' missing independent geometry')
 assert(hair.TextureContent.Uri and hair.TextureContent.Uri:match('^rbxassetid://%d+$'),name..' missing fiber texture')
 assert((hair.Size-rb.Vector3.new(table.unpack(box.size))).Magnitude<.002,name..' import changed bounds')
 geometry[hair.MeshContent.Uri]=true
end
assert(bounds['High puff'].center[2]>bounds['Low puff'].center[2]+.12,'Puff attachments overlap')
assert(bounds['Low puff'].center[3]>bounds['High puff'].center[3]+.12,'Low puff should sit at the nape')
print('PASS six sculpted faces and nine individually fitted grooms')
