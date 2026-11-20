local rb=require('@lune/roblox');local fs=require('@lune/fs');local luau=require('@lune/luau')
local serde=require('@lune/serde')
local grooms=rb.deserializeModel(fs.readFile('art/resident-grooms.rbxm'))[1]
for name,box in serde.decode('json',fs.readFile('art/groom-bounds.json')) do
 grooms:FindFirstChild(name,true):SetAttribute('GroomCenter',rb.Vector3.new(table.unpack(box.center)))
end
local library=rb.deserializeModel(fs.readFile('art/resident-hair.rbxm'))[1]
local code=fs.readFile('src/StreetStyle.luau'):match('(local function hair%b().-)\nfunction Style.apply')
local dyes={Black=rb.Color3.fromRGB(44,37,34),Copper=rb.Color3.fromRGB(167,88,53)}
local env={game={ReplicatedStorage={ResidentGrooms=grooms,ResidentHair=library}},dyes=dyes}
for _,key in {'Instance','Vector3','CFrame','Color3','Enum'} do env[key]=rb[key] end
local draw=luau.load(code..'\nreturn hair',{environment=env,injectGlobals=true})()
local head=rb.Instance.new('Part')
for _,name in {'High puff','Twists','Low puff','Close crop'} do
 for color,dye in dyes do
  draw(head,name,dye,'Natural',rb.Vector3.one)
  local mesh=head:FindFirstChild('Hair mesh',true)
  local material=mesh:FindFirstChildOfClass('SurfaceAppearance')
  if material then assert(material.Color==dye,name..' '..color..' is overridden by the imported material')
  else assert(mesh.Color==dye or color=='Black',name..' loses its selected dye') end
 end
end
print('PASS imported hair material dye and fallback mesh color')
