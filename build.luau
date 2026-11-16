local furnish=require('./home-furniture')
local facade=require('./residential-facades')
local fixtures=require('./shop-fixtures')
local fs = require('@lune/fs')
local rb = require('@lune/roblox')
local Instance, Vector3, CFrame, Color3, Enum = rb.Instance, rb.Vector3, rb.CFrame, rb.Color3, rb.Enum
local game = rb.deserializePlace(fs.readFile('Squishy-original.rbxlx.rbxl'))
local world = game:GetService('Workspace')
local archive = Instance.new('Folder'); archive.Name='OriginalMap_Archive'; archive.Parent=game:GetService('ServerStorage')
for _,v in world:GetChildren() do
 if v.ClassName~='Terrain' and v.ClassName~='Camera' then v.Parent=archive end
end
for _,v in archive:GetDescendants() do if v:IsA('BaseScript') then v.Disabled=true end end
local city=Instance.new('Model'); city.Name='Baltimore'; city.Parent=world
local function group(name,parent)
 local m=Instance.new('Model'); m.Name=name; m.Parent=parent or city; return m
end
local colors={brick=Color3.fromRGB(126,65,48),cream=Color3.fromRGB(202,185,151),dark=Color3.fromRGB(31,39,43),stone=Color3.fromRGB(142,143,135),glass=Color3.fromRGB(96,133,145),road=Color3.fromRGB(48,51,53),gold=Color3.fromRGB(240,185,73),green=Color3.fromRGB(59,89,67)}
local function part(name,size,pos,color,mat,parent)
 local p=Instance.new('Part'); p.Name=name; p.Size=Vector3.new(table.unpack(size)); p.CFrame=CFrame.new(table.unpack(pos)); p.Anchored=true
 p.Color=colors[color] or color or colors.stone; p.Material=Enum.Material[mat or 'Concrete']; p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth; p.Parent=parent or city; return p
end
local function label(p,text,color)
 local s=Instance.new('SurfaceGui'); s.Face=Enum.NormalId.Front; s.SizingMode=Enum.SurfaceGuiSizingMode.FixedSize; s.CanvasSize=rb.Vector2.new(math.round(p.Size.X*32),math.round(p.Size.Y*32)); s.Parent=p
 local t=Instance.new('TextLabel'); t.Size=rb.UDim2.fromScale(1,1); t.BackgroundTransparency=1; t.Text=text; t.FontFace=rb.Font.new('rbxasset://fonts/families/SourceSansPro.json',Enum.FontWeight.Bold); local longest,lines=1,0; for line in string.gmatch(text..'\n','([^\n]*)\n') do longest=math.max(longest,#line); lines+=1 end
 t.TextScaled=false; t.TextSize=math.clamp(math.floor(math.min(s.CanvasSize.X/(longest*.73),s.CanvasSize.Y/(lines*1.3))),9,100); t.TextColor3=color or colors.cream; t.Parent=s
end
local function sign(text,x,y,z,w,parent)
 local p=part('Painted lettering', {w or 22,3,0.20},{x,y,z},'cream','Metal',parent); p.Transparency=1; p.CanCollide=false; p.CanQuery=false; label(p,text,Color3.fromRGB(238,225,197)); return p
end
local function action(p,kind,name,reward,hold)
 p:SetAttribute('Action',kind); p:SetAttribute('Label',name); p:SetAttribute('Reward',reward or 0); p:SetAttribute('Hold',0.5)
end
local streets=group('Streets & alleys')
require('./roads')(part,group,label,streets)
for _,x in {-120,120} do part('Service alley',{12,0.3,155},{x,0.1,-105},'road','Asphalt',streets) end
local function light(x,z)
 local m=group('Streetlight',streets)
 part('Pole',{0.65,23,0.65},{x,12,z},'dark','Metal',m)
 part('Arm',{5,0.5,0.6},{x+2,23,z},'dark','Metal',m)
 local lamp=part('Warm lamp',{3,0.3,1.5},{x+4,22.7,z},'cream','Neon',m)
 local l=Instance.new('PointLight'); l.Color=Color3.fromRGB(255,214,158); l.Brightness=1.4; l.Range=36; l.Shadows=true; l.Parent=lamp
end
for _,x in {-217,23,217} do for _,z in {-270,-155,-55,55,155,270} do light(x,(x==23 and z==155) and 118 or z) end end

local buildings=group('Rowhomes')
local brickPalette={Color3.fromRGB(130,67,48),Color3.fromRGB(151,83,59),Color3.fromRGB(109,61,52),Color3.fromRGB(163,112,79),Color3.fromRGB(103,91,80)}
local function home(x,z,index,flip)
 local m=group('Rowhome '..index,buildings); local front=z-19
 local col=brickPalette[(index-1)%#brickPalette+1]
 local function p(n,s,pos,c,mat) return part(n,s,pos,c,mat,m) end
 p('Foundation',{27,1.2,38},{x,1.2,z},'stone')
 p('Left party wall',{0.8,29,38},{x-13.2,16,z},col,'Brick'); p('Right party wall',{0.8,29,38},{x+13.2,16,z},col,'Brick')
 local function facing(n,w,h,d,dx,y,dz,c,mat)
  return p(n,{w,h,d},{x+dx,y,z+dz},c,mat)
 end
 local ground,landing,roof=1.8,15.2,30.5
 facade.bay(facing,-13.5,0,ground,landing,-19,col,'Brick',-6.5,6.65,6.8,9.7)
 facade.bay(facing,0,13.5,ground,landing,-19,col,'Brick',6.4,9,8,7)
 facade.sash(facing,'Ground window',6.4,9,-19,8,7,-1,colors.cream,false)
 for _,side in {-1,1} do
  local left,right=math.min(side*13.5,0),math.max(side*13.5,0)
  local center=side*6.5
  facade.bay(facing,left,right,landing,roof,-19,col,'Brick',center,23,6.6,8.2)
  facade.sash(facing,'Upper window',center,23,-19,6.6,8.2,-1,colors.cream,false)
  for _,level in {{ground,landing,8},{landing,roof,23}} do
   facade.bay(facing,left,right,level[1],level[2],18.6,col,'Brick',center,level[3],6.5,7.2)
   facade.sash(facing,'Rear sash',center,level[3],18.6,6.5,7.2,1,colors.cream,false)
  end
 end
 p('Cornice',{28,1.2,1.9},{x,30.4,front-0.5},'cream')
 p('Roof',{27,1,38},{x,31,z},'dark','Slate')
 p('Upper floor',{18,.65,37},{x+4,15,z},'cream')
 p('Upper landing',{8,.65,9},{x-9,15,z+14},'cream')
 for step=1,20 do p('Stair tread',{7,step*.66,1.2},{x-9,1.8+step*.33,z-14+step*1.15},'stone') end
 p('Chimney',{3,5,3},{x+9,33,z+12},col,'Brick')
 for i=1,3 do p('Marble stoop',{8,i*0.5,1.7},{x-6.5,0.85+i*0.25,front-6+i*1.7},'cream') end
 local door=p('Door',{6.5,9.5,0.6},{x-6.5,6.5,front},Color3.fromRGB(42+index%3*18,58,59),'Wood')
 action(door,'Door','Open / close');facade.entry(door,Enum.NormalId.Front)
 sign(tostring(1800+index),x-6.5,12,front-0.6,5,m)
 furnish(m,CFrame.new(x,1.8,z),'Rowhome',index)
 local safe=p('House lockbox',{3,2,2},{x+1,3,z+14},'dark','Metal'); action(safe,'Home','Search lockbox',110,9)
 if index%4==0 then
  local box=p('Delivery mailbox',{2,2,1.8},{x+11,4,front-3},'dark','Metal')
  p('Mailbox post',{0.35,3,0.35},{x+11,2,front-3},'dark','Metal')
  action(box,'Delivery','Rowhome '..tostring(1800+index))
 end
 local lamp=p('Ceiling light',{3,0.2,3},{x,14,z},'cream','Neon'); local l=Instance.new('PointLight'); l.Range=25; l.Brightness=0.65; l.Color=Color3.fromRGB(255,221,179); l.Parent=lamp
 local yard=p('Backyard',{25,0.2,14},{x,0.7,z+27},'green','Grass')
 for _,dx in {-13,13} do p('Yard wall',{0.4,4,14},{x+dx,2.5,z+27},'stone') end
 if flip then
  for _,v in m:GetDescendants() do if v:IsA('BasePart') then v.CFrame=CFrame.new(x,0,z)*CFrame.Angles(0,math.pi,0)*CFrame.new(-x,0,-z)*v.CFrame end end
 end
end
local idx=0
for _,z in {-157,-53} do for _,x in {-190,-162,-78,-50,50,78,162,190} do idx+=1; home(x,z,idx,z==-53) end end
local shops=group('Neighborhood businesses')
local function shop(name,x,z,w,d,col)
 local m=group(name,shops)
 part('Floor',{w,1,d},{x,1,z},'stone',nil,m)
 part('Back',{w,18,1},{x,9,z+d/2},col,'Brick',m)
 for _,s in {-1,1} do part('Side',{1,18,d},{x+s*w/2,9,z},col,'Brick',m) end
 part('Front fascia',{w,5,1},{x,16,z-d/2},col,'Brick',m)
 for _,s in {-1,1} do
  local p=part('Shop window',{w/2-5,10,0.3},{x+s*(w/4+2),7,z-d/2},'glass','Glass',m); p.Transparency=0.45
  part('Window base',{w/2-5,1.5,0.7},{x+s*(w/4+2),1.9,z-d/2},'dark',nil,m)
 end
 part('Masonry header',{w,1.6,1},{x,12.75,z-d/2},col,'Brick',m)
 part('Roof',{w+1,1,d+1},{x,18.5,z},'dark','Slate',m)
 part('Awning',{w+1,0.5,6},{x,12.8,z-d/2-2},col,'Fabric',m)
 sign(name,x,16,z-d/2-0.7,w-3,m)
 local lamp=part('Shop light',{w-4,0.2,1},{x,15,z},'cream','Neon',m); local l=Instance.new('PointLight'); l.Range=40; l.Brightness=1.2; l.Parent=lamp
 return m
end
local store=shop('MONUMENT MARKET',-165,64,70,46,colors.brick)
for _,x in {-187,-165,-143} do for _,z in {63,76} do
 part('Shelving',{12,5,3},{x,4,z},'cream',nil,store)
 for i=-4,4,2 do part('Goods',{1.3,1.4,1.5},{x+i,7,z},i%3==0 and 'gold' or 'green','SmoothPlastic',store) end
end end
part('Checkout',{15,3,4},{-143,3,49},'dark',nil,store)
local register=part('Register',{2,1.5,2},{-143,5.1,49},'dark','Metal',store); action(register,'Store','Rob register',225,12);fixtures.register(register);fixtures.staff(register,'Grocer',0,3.8,1.5)
local bank=shop('CHARM CITY CREDIT',-66,64,65,46,colors.cream)
local teller=part('Teller counter',{39,3,4},{-66,3,73},'dark',nil,bank); fixtures.staff(teller,'Bank teller',0,4.4,1.5)
local atm=part('ATM',{5,7,3},{-88,4.5,48},'dark','Metal',bank); sign('ATM',-88,7.5,46.3,4,bank); action(atm,'Bank','Bank / withdraw')
local clinic=shop('NORTHSIDE CLINIC',63,64,65,46,Color3.fromRGB(99,128,128))
local medic=part('First aid station',{5,4,3},{63,3,65},'cream',nil,clinic); action(medic,'Heal','Treatment $50'); fixtures.staff(medic,'Clinic registrar',0,3.7,1.5)
sign('+',63,9,63,4,clinic)
local precinct=shop('COMMUNITY CENTER',164,64,70,46,Color3.fromRGB(84,101,112))
local work=part('Courier desk',{12,3,4},{164,3,67},'dark',nil,precinct); action(work,'Job','Pick up parcel ($90 on delivery)')
city:SetAttribute('CourierDesk',work.CFrame.Position)
fixtures.staff(work,'Parcel dispatcher',0,5.1,1.5)
sign('LEGAL WORK  /  COURIER',164,9,66,30,precinct)
local spawn=Instance.new('SpawnLocation'); spawn.Name='CommunitySpawn'; spawn.Size=Vector3.new(8,0.3,8); spawn.CFrame=CFrame.new(162,1,37); spawn.Anchored=true; spawn.Neutral=true; spawn.Duration=12; spawn.Transparency=1; spawn.Parent=city
local zones=group('SafeZones'); local safe=part('Community safe zone',{88,30,82},{164,10,57},'green',nil,zones); safe.Transparency=1; safe.CanCollide=false; safe.CanQuery=false; safe.CanTouch=false
local bzone=part('Bank safe zone',{65,25,46},{-66,10,64},'green',nil,zones); bzone.Transparency=1; bzone.CanCollide=false; bzone.CanQuery=false; bzone.CanTouch=false
-- Basketball courtyard and small pocket park.
local park=group('Northside court & park')
part('Court pavement',{85,0.4,76},{-165,0.7,145},'dark','Asphalt',park)
part('Playing surface',{72,0.08,58},{-165,0.95,145},Color3.fromRGB(121,78,59),'SmoothPlastic',park)
for _,x in {-201,-129} do part('Court boundary',{0.3,0.05,58},{x,1.02,145},'cream','SmoothPlastic',park) end
for _,z in {116,174} do part('Court boundary',{72,0.05,0.3},{-165,1.02,z},'cream','SmoothPlastic',park) end
part('Half court line',{0.3,0.05,58},{-165,1.02,145},'cream','SmoothPlastic',park)
for _,x in {-198,-132} do
 part('Hoop post',{0.6,13,0.6},{x,7,145},'dark','Metal',park)
 part('Backboard',{0.4,5,9},{x,12,145},'cream',nil,park)
 local toward=x<-165 and 1 or -1
 for _,dz in {-1.5,1.5} do part('Rim',{3,0.2,0.2},{x+toward*1.5,10.5,145+dz},'gold','Metal',park) end
 for _,dx in {0,3} do part('Rim',{0.2,0.2,3},{x+toward*dx,10.5,145},'gold','Metal',park) end
end
local function tree(x,z)
 part('Tree trunk',{2,12,2},{x,6,z},Color3.fromRGB(88,69,49),'Wood',park)
 local leaf=part('Tree canopy',{13,14,13},{x,17,z},'green','Grass',park); leaf.Shape=Enum.PartType.Ball
end
for _,x in {-95,-40,36,91,144,196} do tree(x,175) end
for _,x in {-182,-149} do
 part('Park bench seat',{10,0.6,3},{x,2.2,185},'cream','Wood',park)
 part('Bench back',{10,3,0.5},{x,3.3,186.5},'dark','Wood',park)
 for _,dx in {-4,4} do part('Bench legs',{0.6,2,3},{x+dx,1.2,185},'dark','Metal',park) end
end
sign('NORTHSIDE  /  BALTIMORE',32,5,124,46,park)
part('Park path',{80,0.25,8},{-165,0.6,182},'stone',nil,park)
-- Industrial district / backroom black market with multiple entrances.
local industrial=group('Harbor industrial district')
local warehouse=shop('HARBOR FREIGHT',112,273,154,64,Color3.fromRGB(92,78,68))
warehouse.Parent=industrial
for _,x in {60,80,150,170} do for _,z in {263,286} do
 part('Freight crate',{9,8,8},{x,5,z},'cream','WoodPlanks',warehouse)
 part('Crate strap',{9.1,0.5,8.1},{x,6,z},'dark','Metal',warehouse)
end end
local market=part('Black market counter',{18,3,5},{112,3,292},'dark','Metal',warehouse); fixtures.staff(market,'Warehouse trader',0,4.6,1.5);action(market,'Market','Browse black market')
sign('BACKROOM EXCHANGE',112,8,290,32,warehouse)
local fence=part('Fence buyer',{10,3,4},{112,3,268},'green',nil,warehouse); action(fence,'Fence','Sell stolen goods')
sign('SALVAGE / CASH',112,8,266,20,warehouse)
for i=1,4 do
 local x=-200+(i-1)*43
 local c=part('Shipping container',{36,16,38},{x,8.5,270},i%2==0 and 'green' or 'brick','Metal',industrial)
 for off=-15,15,5 do part('Container ribs',{0.4,16,0.4},{x+off,8.5,250.8},'dark','Metal',industrial) end
 label(c,'HARBOR  '..i)
end
-- Street dressing stays out of doorways and travel lanes.
for _,x in {-213,-27,27,213} do for _,z in {-183,-28,32,183} do
 local bin=part('Trash bin',{3,4,3},{x,2.6,z},'green','Metal',streets)
 part('Bin lid',{3.4,0.4,3.4},{x,4.8,z},'dark','Metal',streets)
end end
city:SetAttribute('ReleaseChannel','Alpha')
require('./districts')(part,group,label,action,city)
require('./fleet')(part,group,city)
require('./prison')(part,group,label,action,city)
require('./retail-interiors')(city)
local radar={}
for _,part in city:GetDescendants() do
 if part:IsA('BasePart') and table.find({'Carriageway','Worn asphalt','Side street connection','Service alley'},part.Name) then
  local pos,sz=part.CFrame.Position,part.Size
  table.insert(radar,{pos.X,pos.Z,sz.X,sz.Z})
 end
end
city:SetAttribute('RadarRoads',require('@lune/serde').encode('json',radar))
local mapBoard=group('Neighborhood directory',city)
for _,x in {143,155} do part('Directory upright',{.6,10,.6},{x,5,31},'dark','Metal',mapBoard) end
local panel=part('Street directory',{15,8,.7},{149,6,31},'green','Metal',mapBoard)
label(panel,'NORTHSIDE\nQUAY DISTRICT  ↑ N\nLANVALE  ← W     E →  EASTGATE\nMADISON GARDENS  ↓ S')
local reverse=panel:FindFirstChildOfClass('SurfaceGui'):Clone(); reverse.Face=Enum.NormalId.Back; reverse.Parent=panel
local lighting=game:GetService('Lighting'); lighting.TimeOfDay='14:24:00'; lighting.Brightness=2.5; lighting.Ambient=Color3.fromRGB(88,90,103); lighting.OutdoorAmbient=Color3.fromRGB(128,125,119); lighting.GlobalShadows=true; lighting.GeographicLatitude=39.29; lighting.ShadowSoftness=.30
local at=Instance.new('Atmosphere'); at.Density=0.19; at.Offset=0.2; at.Color=Color3.fromRGB(222,213,194); at.Decay=Color3.fromRGB(124,133,145); at.Haze=1.3; at.Parent=lighting
local grade=Instance.new('ColorCorrectionEffect'); grade.Contrast=0.065; grade.Saturation=0.03; grade.TintColor=Color3.fromRGB(255,251,242); grade.Parent=lighting
local cam=world:FindFirstChildOfClass('Camera'); if cam then cam.CFrame=CFrame.lookAt(Vector3.new(-601,9,302),Vector3.new(-607,7.8,279.5)); cam.Focus=CFrame.new(-607,7.8,279.5) end
local rs=game:GetService('ReplicatedStorage'); local rem=Instance.new('RemoteEvent'); rem.Name='CityAction'; rem.Parent=rs
local servers=Instance.new('RemoteEvent');servers.Name='CityServers';servers.Parent=rs
local browser=Instance.new('ModuleScript');browser.Name='ServerBrowser';browser.Source=fs.readFile('src/ServerBrowser.luau');browser.Parent=rs
local directory=Instance.new('ModuleScript');directory.Name='ServerDirectory';directory.Source=fs.readFile('src/ServerDirectory.luau');directory.Parent=game:GetService('ServerScriptService')
local starter=game:GetService('StarterPlayer')
game:GetService('Players').CharacterAutoLoads=false
starter.LoadCharacterAppearance=false
local rig=rb.deserializeModel(fs.readFile('art/resident-rig.rbxm'))[1]
rig.Name='ResidentRig';rig:SetAttribute('GameOwnedRig',true);rig.PrimaryPart=rig.HumanoidRootPart
for _,v in rig:GetDescendants() do
 if v:IsA('LuaSourceContainer') or v:IsA('Accessory') or v:IsA('Clothing') then v:Destroy() end
end
-- Bake the city-owned selection of Robloxian 2.0 body parts once for preview and spawn.
rig.Humanoid.AutomaticScalingEnabled=false
rig.Humanoid.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
rig.Parent=rs
local hairLibrary=rb.deserializeModel(fs.readFile('art/resident-hair.rbxm'))[1];hairLibrary.Name='ResidentHair';hairLibrary.Parent=rs
local profiles=rb.deserializeModel(fs.readFile('art/resident-profiles.rbxm'))[1]
profiles.Name='ResidentProfiles';profiles.Parent=rs
local grooms=rb.deserializeModel(fs.readFile('art/resident-grooms.rbxm'))[1]
grooms.Name='ResidentGrooms';grooms.Parent=rs
local bounds=require('@lune/serde').decode('json',fs.readFile('art/groom-bounds.json'))
for name,box in bounds do
 local mesh=assert(grooms:FindFirstChild(name,true),name)
 mesh:SetAttribute('GroomCenter',Vector3.new(table.unpack(box.center)))
end
local function singleMesh(file,name,parent)
 local imported=rb.deserializeModel(fs.readFile('art/'..file..'.rbxm'))[1]
 local mesh=assert(imported:FindFirstChildWhichIsA('MeshPart',true))
 mesh.Name=name;mesh.Parent=parent
 return mesh
end
local fringe=singleMesh('short-fringe','Cropped fringe',grooms)
fringe.Size=Vector3.new(1.07,.56,1.04);fringe:SetAttribute('GroomCenter',Vector3.new(0,.325,.016))
singleMesh('service-cap','ServiceCap',rs)
local starterRig=rig:Clone();starterRig.Name='StarterCharacter';starterRig.Parent=starter
local menu=Instance.new('LocalScript');menu.Name='ResidentMenu';menu.Source=fs.readFile('src/ResidentMenu.client.luau');menu.Parent=starter:FindFirstChildOfClass('StarterPlayerScripts')
local portrait=Instance.new('ModuleScript'); portrait.Name='ResidentPortrait'; portrait.Source=fs.readFile('src/ResidentPortrait.luau'); portrait.Parent=rs
local names=Instance.new('ModuleScript'); names.Name='ResidentNames'; names.Source=fs.readFile('src/ResidentNames.luau'); names.Parent=rs
local style=Instance.new('ModuleScript'); style.Name='StreetStyle'; style.Source=fs.readFile('src/StreetStyle.luau'); style.Parent=rs
local art=require('@lune/serde').decode('json',fs.readFile('art/assets.json'))
for _,key in {'fleet-track','foundry-work','pier-varsity','indigo-denim','harbor-warmup','clay-workshirt','olive-overshirt','street-denim','washed-denim','canvas-trousers','street-denim-black','washed-denim-black','canvas-trousers-black','resident-calm','resident-smile','resident-focused','mouth-level','mouth-smile','mouth-set','ash-pullover','dock-denim','field-liner','haste-markdown','forever-tuesday','last-season','portrait-calm','portrait-smile','portrait-focused','lips-level','lips-smile','lips-set'} do style:SetAttribute(key,assert(art[key],key)) end
local catalog=Instance.new('ModuleScript');catalog.Name='ShopProducts';catalog.Source=fs.readFile('src/ShopProducts.luau');catalog.Parent=rs
local clock=Instance.new('Script'); clock.Name='CityClock'; clock.Source=fs.readFile('src/CityClock.server.luau'); clock.Parent=game:GetService('ServerScriptService')
local styleUI=Instance.new('ModuleScript');styleUI.Name='RetailUI';styleUI.Source=fs.readFile('src/RetailUI.luau');styleUI.Parent=rs
local server=Instance.new('Script'); server.Name='CityServer'; server.Source=fs.readFile('src/CityServer.server.luau'); server.Parent=game:GetService('ServerScriptService')
local client=Instance.new('LocalScript'); client.Name='CityClient'; client.Source=fs.readFile('src/CityClient.client.luau'); client.Parent=game:GetService('StarterPlayer'):FindFirstChildOfClass('StarterPlayerScripts')
local drive=Instance.new('RemoteEvent'); drive.Name='DriveCar'; drive.Parent=rs
local traffic=Instance.new('Script'); traffic.Name='TrafficServer'; traffic.Source=fs.readFile('src/Traffic.server.luau'); traffic.Parent=server.Parent
local input=Instance.new('LocalScript'); input.Name='TrafficClient'; input.Source=fs.readFile('src/Traffic.client.luau'); input.Parent=client.Parent
local route=Instance.new('RemoteFunction'); route.Name='WalkingRoute'; route.Parent=rs
local trail=Instance.new('ModuleScript'); trail.Name='StreetTrail'; trail.Source=fs.readFile('src/StreetTrail.luau'); trail.Parent=rs
local staff=Instance.new('ModuleScript');staff.Name='ShopStaff';staff.Source=fs.readFile('src/ShopStaff.luau');staff.Parent=server.Parent
local routes=Instance.new('ModuleScript'); routes.Name='WalkingRoutes'; routes.Source=fs.readFile('src/WalkingRoutes.luau'); routes.Parent=server.Parent
local bearing=Instance.new('ModuleScript'); bearing.Name='JobBearing'; bearing.Source=fs.readFile('src/JobBearing.luau'); bearing.Parent=rs
local catalog=Instance.new('ModuleScript'); catalog.Name='WorkCatalog'; catalog.Source=fs.readFile('src/WorkCatalog.luau'); catalog.Parent=rs
local jobs=Instance.new('ModuleScript'); jobs.Name='WorkService'; jobs.Source=fs.readFile('src/WorkService.luau'); jobs.Parent=server.Parent
for _,name in {'Handset','StreetHUD','MapCompass'} do
 local module=Instance.new('ModuleScript'); module.Name=name; module.Source=fs.readFile('src/'..name..'.luau'); module.Parent=rs
end
local lifeUi=Instance.new('ModuleScript'); lifeUi.Name='LifeUI'; lifeUi.Source=fs.readFile('src/LifeUI.luau'); lifeUi.Parent=rs
for _,entry in {{'StreetLighting','src/StreetLighting.luau'},{'TrafficPhases','src/TrafficPhases.luau'},{'VehicleHandling','src/VehicleHandling.luau'},{'ResidentFiles','src/ResidentFiles.luau'},{'CityRetail','src/CityRetail.luau'},{'NeighborhoodLife','src/NeighborhoodLife.luau'},{'Responders','src/Responders.luau'},{'Custody','src/Custody.luau'}} do
 local mod=Instance.new('ModuleScript'); mod.Name=entry[1]; mod.Source=fs.readFile(entry[2]); mod.Parent=server.Parent
end
fs.writeFile('Northside Baltimore - Heritage Harbor.rbxl',rb.serializePlace(game))
fs.writeFile('Northside Baltimore - Heritage Harbor.rbxlx',rb.serializePlace(game,true))
print('Built Baltimore district:',#city:GetDescendants(),'instances; original map archived:',#archive:GetDescendants())
