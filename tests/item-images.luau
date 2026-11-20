local rb=require('@lune/roblox')
local fs=require('@lune/fs')
local luau=require('@lune/luau')
local catalog=require('../src/ItemCatalog')
local total=0
for _,file in fs.readDir('src/ItemModels') do
 if not file:match('%.luau$') then continue end
 local model=rb.Instance.new('Model');local parts={};local points={}
 local builder={model=model,options={color={51,83,124}}}
 function builder.part(name,size,pos,color,shape,rotation)
  assert(#size==3 and #pos==3 and #color==3,file..' malformed geometry')
  for _,n in size do assert(n>0 and n<12,file..' invalid product bounds') end
  for _,n in color do assert(n>=0 and n<=255,file..' invalid color') end
  local p=rb.Instance.new(shape=='Wedge' and 'WedgePart' or 'Part')
  p.Name=name;p.Size=rb.Vector3.new(table.unpack(size));p.Color=rb.Color3.fromRGB(table.unpack(color))
  p.CFrame=rb.CFrame.new(table.unpack(pos))*(rotation and rb.CFrame.Angles(table.unpack(rotation)) or rb.CFrame.identity)
  p.Parent=model;table.insert(parts,p);table.insert(points,name..tostring(p.Size));return p
 end
 luau.load(fs.readFile('src/ItemModels/'..file))()(builder)
 assert(#parts>=3,file..' has no recognizable product silhouette')
 if file=='Clothing.luau' then assert(model['Jacket body'].Color==rb.Color3.fromRGB(51,83,124),'Clothing preview ignores garment color') end
 total+=1
end
assert(total==17,'Missing a shop product image')
for key,item in catalog do
 assert(fs.isFile('src/ItemModels/'..item.Icon..'.luau'),key..' has no image')
 assert(#item.Name>0 and #item.Description>0,key..' lacks useful product text')
 if item.Price then assert(item.Price>0 and item.Price%1==0,key..' price is invalid') end
end
print('PASS 17 product image geometries, clothing colors and catalog coverage')
