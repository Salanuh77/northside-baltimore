local furnish=require('./home-furniture')
local facade=require('./residential-facades')
local fixtures=require('./shop-fixtures')
local rb=require('@lune/roblox')
local E,cf,rgb=rb.Enum,rb.CFrame,rb.Color3.fromRGB
return function(city,group,builder,lettering,glass,action,lounge,glow)
 local housing=group('Westside • Hollins Row',city)
 local uptown=group('Harbor East • Waterfront Residences',city)
 local service=group('Gas stations',city)
 local civic=group('City Hall & emergency services',city)
 local cream=rgb(212,203,181); local blue=rgb(54,92,108)
 local art=require('@lune/serde').decode('json',require('@lune/fs').readFile('art/assets.json'))
 local function mural(wall,face,index,offset,height,width,fade,collection)
  local columns=collection=='baltimore-history' and 1 or 2
  local rows=(collection=='baltimore-history' or collection=='athlete-paint') and 1 or 2
  local aspect=collection=='alley-walls' and 2 or collection=='baltimore-history' and 3 or 1
  local gui=rb.Instance.new('SurfaceGui')
  gui:SetAttribute('ArtCollection',collection); gui:SetAttribute('Cell',index)
  gui.Name='Alley paint'; gui.Face=face; gui.LightInfluence=1
  gui.SizingMode=E.SurfaceGuiSizingMode.PixelsPerStud; gui.PixelsPerStud=36; gui.Parent=wall
  -- Sizes are in studs. Only the painted portion of the atlas draws on the masonry.
  local clip=rb.Instance.new('Frame'); clip.BackgroundTransparency=1; clip.BorderSizePixel=0
  clip.AnchorPoint=rb.Vector2.new(.5,.5)
  clip.Position=rb.UDim2.fromScale(.5+offset/wall.Size.X,1-height/wall.Size.Y)
  clip.Size=rb.UDim2.fromScale(width/wall.Size.X,width/aspect/wall.Size.Y)
  clip.ClipsDescendants=true; clip.Parent=gui
  local image=rb.Instance.new('ImageLabel'); image.BackgroundTransparency=1; image.BorderSizePixel=0
  image.Image='rbxassetid://'..art[collection or 'Image']; image.ImageTransparency=fade
  image.Size=rb.UDim2.fromScale(columns,rows)
  image.Position=rb.UDim2.fromScale(-((index-1)%columns),-math.floor((index-1)/columns))
  image.Parent=clip
 end
 local function lease(p,where,u,y,v,cost)
  local key=p('Residence intercom',1.5,2.2,.55,u,y,v,'dark','Metal')
  action(key,'Residence','Apartment & parties'); key:SetAttribute('Address',where); key:SetAttribute('LeasePrice',cost or 0)
 end
 for i=1,18 do
  local stretch=math.floor((i-1)/6)
  local z=-159+((i-1)%6)*22+stretch*216
  local m=group('Hollins Row '..(1500+i),housing); local p=builder(m,-700,z,-90)
  -- Fronts look east across the west-side street.
  local function face(name,w,h,d,x,y,v,c,mat) return p(name,w,h,d,-x,y,-v,c,mat) end
  local tint=({rgb(130,72,60),rgb(136,133,118),rgb(155,109,76),rgb(125,115,94)})[(i-1)%4+1]
  local vacant=i%5==1 or i%7==0
  p('Party wall',.7,25,29,-10.7,13.5,0,tint,'Brick'); p('Party wall',.7,25,29,10.7,13.5,0,tint,'Brick')
  p('Ground floor',21.6,.8,29,0,1.3,0,cream,'WoodPlanks'); p('Rear',21.7,25,.8,0,13.5,-14.3,tint,'Brick')
  local faceMaterial=i%3==0 and 'Concrete' or 'Brick'
  facade.bay(p,-10.85,0,1.0,14.0,14.3,tint,faceMaterial,-4.4,6.3,6.6,10.6)
  facade.bay(p,0,10.85,1.0,14.0,14.3,tint,faceMaterial,5,8,6.4,7.2)
  facade.bay(p,-10.85,0,14.0,26,14.3,tint,faceMaterial,-5,20,6.4,7.2)
  facade.bay(p,0,10.85,14.0,26,14.3,tint,faceMaterial,5,20,6.4,7.2)
  p('Roof',22.1,.8,30,0,26.3,0,'dark','Slate'); p('Cornice',22.4,1.2,1.4,0,25.6,14.6,cream,'Concrete')
  for _,v in {{-5,20},{5,20},{5,8}} do
   if vacant then
    p('Plywood infill',6.45,7.25,.42,v[1],v[2],14.45,rgb(125,103,76),'WoodPlanks')
    local board=p('Cross batten',6.8,.6,.4,v[1],v[2],14.81,'dark','Wood'); board.CFrame*=cf.Angles(0,0,.27)
   else
    facade.sash(p,'Double hung sash',v[1],v[2],14.3,6.4,7.2,1,cream,false)
   end
  end
  for k=1,3 do p('Marble stoop',7,k*.45,1.2,-4.4,k*.225,19.5-k*1.18,cream,'Concrete') end
  p('Stoop rail',.32,3.6,.32,-8,2.3,18,'dark','Metal'); p('Stoop rail',.32,3.6,.32,-8,2.8,15.6,'dark','Metal')
  local rail=p('Handrail',.32,.3,3.4,-8,4.4,17,'dark','Metal'); rail.CFrame*=cf.Angles(.17,0,0)
  if vacant then
   p('Boarded door',6.2,9,.6,-4.4,6,14.3,rgb(110,91,70),'WoodPlanks')
   p('Chipped stoop fragment',2,.6,1.5,3,.4,18,cream,'Concrete')
  else
   local door=p('Rowhouse door',6.4,9.6,.45,-4.4,6.5,14.3,blue,'Wood')
   action(door,'Door','Open / close'); facade.entry(door,rb.Enum.NormalId.Back)
   furnish(m,cf.new(-700,1.7,z)*cf.Angles(0,-math.pi/2,0),'Hollins',i)
   lease(p,m.Name,1,5,13.5,0); glow(p,0,12,0) end
  if i%3==0 then
   p('Utility pole',.85,32,.85,8,16,22,rgb(101,84,69),'Wood')
   p('Crossarm',5,.55,.55,8,30,22,'dark','Wood')
   for _,v in {-1,1} do p('Overhead service line',64,.16,.16,-23,30,22+v*1.4,'dark','Metal') end
  end
 end
 local lane=builder(group('Hollins residential lane',housing),-734,0)
 lane('West residential land',65,5,660,-24,-2.75,110,'green','Grass')
 lane('Worn asphalt',20,.58,648,0,0,105,'road','Asphalt')
 for _,side in {-1,1} do lane('Narrow footway',6,.72,648,side*13,.2,105,'stone','Concrete') end
 for _,v in {-210,0,210,430} do lane('Side street connection',74,.65,16,37,.15,v,'road','Asphalt') end
 for i=1,26 do
  local patch=lane('Asphalt patch',4.4,.04,4+i%7,(i%3-1)*4,.33,-194+i*23,'dark','Asphalt')
  patch.CFrame*=cf.Angles(0,.14*(i%4),0)
 end
 for i=1,18 do
  if i%6~=2 then
   local source=housing:FindFirstChild('Hollins Row '..(1500+i)); local other=source:Clone()
   other.Name='Hollins Row '..(1600+i); local z=-159+((i-1)%6)*22+math.floor((i-1)/6)*216
   local from=cf.new(-700,0,z)*cf.Angles(0,-math.pi/2,0); local to=cf.new(-768,0,z)*cf.Angles(0,math.pi/2,0)
   for _,v in other:GetDescendants() do
    if v:IsA('BasePart') then v.CFrame=to*from:Inverse()*v.CFrame; if v:GetAttribute('Address') then v:SetAttribute('Address',other.Name) end end
   end
   other.Parent=housing
  end
 end
 for i=1,7 do
  local x=255+i*39; local m=group('Harbor East Residence '..i,uptown); local p=builder(m,x,-493,180)
  p('Stone floor',32,1,25,0,1,0,cream,'Marble')
  for _,s in {-1,1} do p('Townhouse return',.7,27,25,s*16,14.5,0,cream,'Limestone'); glass(p,'Bay window',9,10,.6,s*10.2,7,-12.5) end
  p('Rear elevation',32,27,.8,0,14.5,12,cream,'Limestone'); p('Balcony deck',33,.9,29,0,14.5,0,cream,'Marble')
  glass(p,'Upper bay',31,11,.7,0,20.8,-12.4); p('Penthouse cornice',34,1,27,0,28.5,0,cream,'Concrete')
  for _,u in {-14,0,14} do p('Bronze mullion',.6,12,.8,u,21,-12.8,'gold','Metal') end
  local door=p('Townhouse door',11.3,10,.45,0,6.5,-12.5,blue,'Wood')
  action(door,'Door','Open / close')
  p('Townhouse transom',11.4,2.4,.4,0,12.7,-12.5,cream,'Limestone')
  furnish(m,cf.new(x,1.5,-493)*cf.Angles(0,math.pi,0),'Waterfront',i)
  p('Entry bell post',1.1,4.8,1.1,7,2.5,-14,cream,'Limestone'); lease(p,m.Name,7,4.2,-14.85,200); glow(p,0,13,0)
 end
 local martModels={}
 for _,id in {'dispenser','ice-locker','coffee-brewer'} do
  local imported=rb.deserializeModel(require('@lune/fs').readFile('art/mart-'..id..'.rbxm'))[1]
  martModels[id]=assert(imported:FindFirstChildWhichIsA('MeshPart',true),'Missing mart mesh: '..id)
 end
 for _,v in {{'North Avenue Fuel',60,148,90,60},{'Franklin Fuel',-510,994,-90,60},{'Eastside Fuel',719,111,90,59}} do
  local m=group(v[1],service); local p=builder(m,v[2],v[3],v[4])
  local frame=cf.new(v[2],0,v[3])*cf.Angles(0,math.rad(v[4]),0)
  local function fixture(id,name,x,bottom,z,width,height,depth,yaw)
   local mesh=martModels[id]:Clone()
   local size=mesh.Size
   mesh.Size=size*math.min(width/size.X,height/size.Y,depth/size.Z)
   mesh.Name=name; mesh.Anchored=true; mesh.CanCollide=false; mesh.CanTouch=false; mesh.CanQuery=false
   mesh.CFrame=frame*cf.new(x,bottom+mesh.Size.Y/2,z)*cf.Angles(0,math.rad(yaw or 0),0)
   mesh.Parent=m
   return mesh
  end
  p('Driveway throat',37,.35,v[5]-17,0,.43,-(v[5]-17)/2,'stone','Concrete')
  p('Station apron',45,.6,60,0,.38,-11.5,'stone','Concrete')
  m:SetAttribute('SidewalkOffset',-(v[5]-21+3))
  p('Shop floor',40,.7,30,0,.9,3,cream,'Marble'); p('Rear wall',40,12,.8,0,7.2,18,cream,'Brick')
  for _,s in {-1,1} do p('Return wall',.8,12,30,s*20,7.2,3,cream,'Brick'); glass(p,'Storefront',13,9,.45,s*13.5,5.9,-12) end
  p('Store roof',41,1,31,0,13.4,3,'dark','Metal')
  local brand=({
   ['North Avenue Fuel']={'NORTH AVE',rgb(162,58,45)},
   ['Franklin Fuel']={'FRANKLIN',rgb(34,105,89)},
   ['Eastside Fuel']={'EASTSIDE',rgb(48,88,151)}
  })[v[1]]
  local enamel=brand[2]
  lettering(p('Enamel station wordmark',20,3.4,.52,-6,12,-12.6,enamel,'Metal'),brand[1])
  for band=0,2 do p('Speed stripe',9-band*1.65,.25,.18,8+band*.8,11.1+band*.63,-12.85,cream,'Neon') end
  p('Blade bracket',.24,.3,3.4,16,10.6,-13.7,'dark','Metal')
  local blade=p('Mart projecting blade',5.2,3.2,.4,16,8.9,-15.1,enamel,'Metal')
  blade.CFrame*=cf.Angles(0,math.pi/2,0)
  lettering(blade,'MART')
  local front=blade:FindFirstChildOfClass('SurfaceGui'); local back=front:Clone();back.Face=E.NormalId.Back;back.Parent=blade
  p('Entry mat',11,.1,4,0,1.3,-9,blue,'Fabric')
  for _,side in {-1,1} do
   p('Chiller cabinet',3,7.4,9,side*17.8,5.05,9,'dark','Metal')
   for j=-1,1 do
    p('Cooler glass',.18,5.5,2.65,side*16.2,5.2,9+j*2.9,blue,'Glass')
    p('Cooler pull',.28,1.6,.19,side*16,5.1,10+j*2.9,cream,'Metal')
   end
   glow(p,side*11,12,7)
  end
  -- Stock both faces of the two gondolas. Their narrow ends face the entrance.
  for _,side in {-1,1} do
   local x=side*11
   p('Gondola plinth',3.3,.52,7.6,x,1.51,0,blue,'Metal')
   p('Retail pegboard',.24,5.4,7.3,x,4.05,0,cream,'Metal')
   for tier=1,3 do
    local y=1.96+(tier-1)*1.65
    p('Gondola shelf',3.4,.15,7.5,x,y,0,cream,'Metal')
    for _,face in {-1,1} do
     for slot=1,4 do
      local z=(slot-2.5)*1.65
      local tint=({enamel,cream,blue,rgb(192,138,62)})[(slot+tier)%4+1]
      p('Boxed groceries',.83,1.08,1.13,x+face*.95,y+.62,z,tint,'SmoothPlastic')
      p('Package band',.035,.22,.91,x+face*1.38,y+.8,z,cream,'SmoothPlastic')
     end
    end
   end
  end
  local ice=fixture('ice-locker','Bagged ice locker',-15,.68,-15.1,8,5.7,3.7)
  p('Ice locker footing',ice.Size.X,.16,ice.Size.Z,-15,.69,-15.1,cream,'Concrete')
  local iceSolid=p('Ice locker collision',ice.Size.X,ice.Size.Y,ice.Size.Z,-15,.68+ice.Size.Y/2,-15.1,cream)
  iceSolid.Transparency=1
  lettering(p('Ice locker blade',4.7,1.35,.22,-15,7.9,-12.5,blue,'Metal'),'BAGGED ICE')
  p('Coffee bar base',8.6,2.8,3.4,-11,2.65,12.4,enamel,'Wood')
  p('Coffee bar top',9,.26,3.7,-11,4.18,12.4,cream,'Marble')
  fixture('coffee-brewer','Twin coffee brewer',-12.2,4.31,12.6,4.9,4.5,3.55)
  for i=1,3 do
   local cup=p('Takeaway cup stack',.65,1.25-i*.05,1.25-i*.05,-8.6,4.65+(i-1)*.18,12.35,cream,'SmoothPlastic')
   cup.Shape=E.PartType.Cylinder;cup.CFrame*=cf.Angles(0,0,math.pi/2)
  end
  local menu=p('Coffee counter',6,1.15,.18,-11,3.05,10.62,enamel,'Metal')
  lettering(menu,'FRESH COFFEE   $6')
  action(menu,'Coffee','Buy coffee · $6')
  p('Checkout desk',9,3.2,3,0,3,13,'dark','Wood')
  local till=p('Mart till',2,1.5,1.7,0,5.4,12.8,'dark','Metal')
  fixtures.staff(till,'Mart cashier',0,3.1,1.4);action(till,'Mart','Buy supplies')
  for _,s in {-1,1} do
   p('Pump island',4.6,.45,9,s*8,.83,-30,'cream','Concrete')
   p('Canopy column',.9,14,.9,s*8,7.4,-27.2,'stone','Metal')
   local machine=fixture('dispenser','Fuel dispenser',s*8,1.055,-31,4.1,7.4,3)
   local guard=p('Dispenser collision',machine.Size.X,machine.Size.Y,machine.Size.Z,s*8,1.055+machine.Size.Y/2,-31,'dark','Metal')
   guard.Transparency=1
   local pump=p('Pump face',3.4,1.4,.2,s*8,4.2,-31-machine.Size.Z/2-.15,'dark','Metal')
   pump.Transparency=1; pump.CanCollide=false
   action(pump,'Fuel','Fill tank · $1 per 5%')
   local number=p('Island number',2.6,1.8,.36,s*8,9.3,-27.85,enamel,'Metal')
   lettering(number,s==-1 and '01' or '02')
   for _,edge in {-1,1} do
    p('Island guard post',.54,2.9,.54,s*8+edge*1.7,2.35,-33.95,'gold','Metal')
   end
  end
  p('Fuel canopy',36,1,18,0,15,-32,blue,'Metal'); p('Canopy trim',36,1,1,0,14.4,-41,enamel,'Metal')
  for _,side in {-1,1} do
   local light=p('Forecourt downlight',6.5,.2,1.4,side*10,14.36,-34,cream,'Neon')
   local lamp=rb.Instance.new('SurfaceLight');lamp.Face=E.NormalId.Bottom;lamp.Range=23;lamp.Brightness=1.25
   lamp.Angle=105;lamp.Color=rgb(255,239,207);lamp.Parent=light
  end
  glow(p,2,12,0)
 end
 local gallery=group('Pier 8 Maritime Gallery',city); local g=builder(gallery,-316,-575)
 g('Pier',78,1.2,56,0,.6,0,'stone','Concrete')
 g('Gangway',10,1,25,0,.8,32,'cream','WoodPlanks')
 local historyWall=g('Gallery back wall',48,14,1,0,8,-14,cream,'Brick')
 mural(historyWall,E.NormalId.Back,1,0,7,38,.035,'baltimore-history')
 for _,side in {-1,1} do glass(g,'Harbor glazing',.6,13,30,side*24,8,0); glass(g,'Quay windows',17,11,.6,side*15,7,14) end
 for _,side in {-1,1} do
  local wing=rb.Instance.new('WedgePart'); wing.Name='Folded zinc roof'; wing.Size=rb.Vector3.new(35,23,25); wing.Color=side==-1 and rgb(116,160,174) or rgb(173,196,202); wing.Material=E.Material.Metal
  wing.CFrame=cf.new(-316+side*12.3,26,-575)*cf.Angles(0,side==-1 and math.pi/2 or -math.pi/2,0); wing.Anchored=true; wing.Parent=gallery
 end
 lettering(g('Pier sign',21,4,.7,0,12,15,blue,'Metal'),'PIER 8  /  MARITIME')
 lounge(g,9,1.3,0,blue); glow(g,-10,12,-4)
 local p=builder(group('Civic clock tower',civic),0,1079)
 local bronze=rgb(78,72,58);local copper=rgb(77,116,103)
 p('Council entrance',128,1.1,32,0,1.1,0,cream,'Marble')
 p('Council chamber ceiling',129,1,32,0,23.5,0,cream,'Limestone')
 p('Rear chamber wall',128,22,1,0,12,15.5,cream,'Limestone')
 for _,side in {-1,1} do
  p('Gallery end wall',1,22,31,side*63.5,12,0,cream,'Limestone')
  p('Council gallery bench',15,1.1,3,side*33,3,4,'dark','Wood')
  p('Bench back',15,3,.5,side*33,4.2,5.4,'dark','Wood')
  p('Bench pedestal',9,1.3,2,side*33,2,4,cream,'Marble')
  for i=0,3 do
   local x=side*(20+12*i)
   p('Window stall riser',12,4,1.1,x,3.3,-15.2,cream,'Limestone')
   glass(p,'Chamber sash',10.2,13,.55,x,11.8,-15)
   p('Sash meeting rail',10.3,.45,.9,x,11.6,-15.45,bronze,'Metal')
   p('Bronze glazing bar',.32,13,.8,x,11.8,-15.4,bronze,'Metal')
   p('Window hood',11.7,1.1,2,x,18.6,-15.6,cream,'Marble')
   p('Facade pier',1.8,21.8,1.6,x+side*5.8,12.2,-15.2,cream,'Limestone')
  end
  p('Wing entablature',50,4.7,1.4,side*39,21.3,-15.3,cream,'Limestone')
  p('Covered wing roof',49,2.4,29,side*39,25.4,0,copper,'Metal')
  for level=1,6 do
   p('Mansard course',49-level*.55,1.15,29-level*1.15,side*39,26.1+level*.9,0,copper,'Metal')
  end
  for i=0,3 do
   local x=side*(20+12*i)
   p('Dormer cheek',5,4.4,3.1,x,28.5,-12.8,cream,'Limestone')
   glass(p,'Dormer sash',3.25,3,.26,x,28.5,-14.45)
   p('Dormer crown',5.65,.65,3.7,x,30.9,-12.9,bronze,'Metal')
  end
  p('Wing ridge',47,1.15,22,side*39,32.3,0,bronze,'Metal')
  for k=0,6 do p('Cornice bracket',1,1.2,2,side*(16+7*k),22.4,-16.2,cream,'Marble') end
 end
 for i=1,4 do p('Portico step',31,.4*i,1.4,0,.6+.2*i,-26.3+i*1.35,cream,'Marble') end
 p('Portico landing',32,1.6,7.5,0,1.45,-18,cream,'Marble')
 for _,x in {-13,-8,8,13} do
  p('Column plinth',2.6,1.3,2.6,x,2.9,-20,cream,'Marble')
  local shaft=p('Portico shaft',16.8,1.65,1.65,x,11.6,-20,cream,'Marble')
  shaft.Shape=E.PartType.Cylinder;shaft.CFrame*=cf.Angles(0,0,math.pi/2)
  p('Portico capital',2.8,1.5,2.8,x,20.4,-20,cream,'Marble')
 end
 p('Portico fascia',32,2.8,8,0,22.3,-18,cream,'Limestone')
 for _,s in {-1,1} do
  local rake=p('Pediment rake',16.8,.85,8.4,s*7.95,25.7,-18,copper,'Metal')
  rake.CFrame*=cf.Angles(0,0,-s*.265)
 end
 p('Council reception desk',12,3.8,3,0,3.6,8,bronze,'Wood')
 for k,v in {{30,48},{24,24},{20,20}} do local y=({46,82,104})[k]; p('Tower stage',v[1],v[2],v[1],0,y,0,cream,'Limestone'); p('Tower entablature',v[1]+3,1.4,v[1]+3,0,y+v[2]/2,0,cream,'Marble') end
 for _,u in {-11,11} do
  p('Fluted civic column',2.2,45,2.2,u,45,-15.6,cream,'Marble')
  p('Column capital',3.5,2.5,3.2,u,68,-15.5,cream,'Marble')
 end
 local origin=cf.new(0,0,1079)
 for face=0,3 do
  local side=origin*cf.Angles(0,face*math.pi/2,0)
  local function relief(name,w,h,d,u,y,r,color,material,roll)
   local part=p(name,w,h,d,0,0,0,color,material)
   part.CFrame=side*cf.new(u,y,-r)*cf.Angles(0,0,roll or 0)
   return part
  end
  for _,band in {{34,15.4},{49,15.4},{66,15.4},{71,12.5},{92.5,12.5},{110.5,10.6}} do
   relief('Carved belt course',band[2]*2+1,.9,1.25,0,band[1],band[2],cream,'Marble')
  end
  for _,story in {{39,15,8.1},{54,15,8.1},{98,10,6.1}} do
   local y,r,spacing=story[1],story[2],story[3]
   for _,direction in {-1,1} do
    local x=direction*spacing*.57
    relief('Arched bay shadow',5.4,7,.5,x,y,r+.51,bronze,'Metal')
    relief('Upper sash',4.6,6.1,.42,x,y,r+.83,blue,'Glass')
    relief('Sash bar',.32,6.1,.5,x,y,r+1.05,cream,'Limestone')
    for _,edge in {-1,1} do relief('Arch jamb',.75,7,.92,x+edge*2.95,y,r+.82,cream,'Marble') end
    for voussoir=0,8 do
     local a=(voussoir+.5)*math.pi/9
     relief('Arch voussoir',1.18,1,.98,x+3*math.cos(a),y+3.45+3*math.sin(a),r+.82,cream,'Marble',a-math.pi/2)
    end
    relief('Window apron',7.1,.85,1.35,x,y-3.7,r+.8,cream,'Marble')
   end
  end
  for _,x in {-8.4,8.4} do relief('Clock corner pier',1.6,18,1.4,x,82,12.35,cream,'Marble') end
  for i=-3,3 do relief('Gallery baluster',.85,2.8,1.2,i*3.2,114.4,11.9,cream,'Marble') end
  relief('Gallery handrail',24,1,1.5,0,116,11.9,cream,'Marble')
 end
 for i=0,3 do
  local pivot=cf.new(0,0,1079)*cf.Angles(0,i*math.pi/2,0)
  local rim=p('Bronze clock rim',.56,13.2,13.2,0,0,0,'dark','Metal'); rim.Shape=E.PartType.Cylinder; rim.CFrame=pivot*cf.new(0,82,-12.4)*cf.Angles(0,math.pi/2,0)
  local dial=p('Clock face',.3,12.1,12.1,0,80,0,'cream','SmoothPlastic'); dial.Shape=E.PartType.Cylinder; dial.CFrame=pivot*cf.new(0,82,-12.79)*cf.Angles(0,math.pi/2,0)
  local hand=p('Clock minute hand',.5,4.5,.45,0,80,0,'dark','Metal'); hand.CFrame=pivot*cf.new(0,84,-12.9); hand:SetAttribute('ClockPivot',pivot*cf.new(0,82,-13.1))
  local hour=p('Clock hour hand', .5,3.8,.45,0,80,0,'dark','Metal'); hour.CFrame=pivot*cf.new(0,83.8,-13.5); hour:SetAttribute('ClockPivot',pivot*cf.new(0,82,-13.5))
  for n=0,11 do local a=n*math.pi/6; local tick=p('Clock index',.36,.8,.26,0,0,0,'dark','Metal'); tick.CFrame=pivot*cf.new(5*math.sin(a),82+5*math.cos(a),-12.9)*cf.Angles(0,0,-a) end
 end
 for _,ring in {{111.5,3.1,22.3},{115,4.0,24.3},{117.8,2.2,26.2}} do
  local belt=p('Dome drum',ring[2],ring[3],ring[3],0,ring[1],0,cream,'Limestone')
  belt.Shape=E.PartType.Cylinder;belt.CFrame*=cf.Angles(0,0,math.pi/2)
 end
 local skirt=p('Copper dome skirt',3,27,27,0,118.2,0,copper,'Metal');skirt.Shape=E.PartType.Cylinder;skirt.CFrame*=cf.Angles(0,0,math.pi/2)
 local dome=p('Copper dome',26,35,26,0,119,0,copper,'Metal'); dome.Shape=E.PartType.Ball
 for rib=0,11 do
  local azimuth=rib*math.pi/6
  local function profile(a)
   return rb.Vector3.new(13.15*math.cos(a)*math.sin(azimuth),119+17.65*math.sin(a),13.15*math.cos(a)*math.cos(azimuth))
  end
  for step=1,6 do
   local a,b=profile((step-1)*math.pi/12),profile(step*math.pi/12)
   local ridge=p('Raised copper seam',.33,.33,(b-a).Magnitude+.1,0,0,0,rgb(111,142,123),'Metal')
   ridge.CFrame=origin*cf.lookAt((a+b)/2,b)
  end
 end
 p('Lantern sill',5.1,.9,5.1,0,136,0,bronze,'Metal')
 for _,x in {-1.7,1.7} do for _,z in {-1.7,1.7} do p('Lantern post',.5,4.7,.5,x,138.7,z,cream,'Marble') end end
 local crown=p('Lantern roof',5.6,4.8,5.6,0,141.6,0,copper,'Metal');crown.Shape=E.PartType.Ball
 p('Spire',.48,5.5,.48,0,146,0,'gold','Metal')
 local tip=p('Lantern finial',1.3,1.6,1.3,0,148.8,0,'gold','Metal');tip.Shape=E.PartType.Ball
 -- Assign the alley faces after both rows exist, so opposite homes have individual marks.
 local function rowPaint(address,collection,cell,offset,height,width,fade)
  mural(housing['Hollins Row '..address].Rear,E.NormalId.Front,cell,offset,height,width,fade,collection)
 end
 for _,v in {
  {1501,1,-2,6.3,11,.22},{1504,1,3,5.3,8,.32},{1506,1,-2,7.8,14,.16},
  {1509,2,1,7,13,.21},{1511,2,-4,5.4,8,.31},{1514,2,1,6.1,11,.25},
  {1603,3,-2,6.1,11,.17},{1606,3,4,5,8,.3},{1610,4,1,7.3,13,.24},{1616,4,-3,6.5,10,.25}
 } do rowPaint(v[1],'block-marks',v[2],v[3],v[4],v[5],v[6]) end
 for _,v in {{1502,1,1,4.8,18,.25},{1512,2,0,6.8,19,.18},{1604,1,-1,5,18,.28},{1615,4,0,6.7,19,.25}} do
  rowPaint(v[1],'alley-walls',v[2],v[3],v[4],v[5],v[6])
 end
 for _,v in {
  {'Foundry Canteen','alley-walls',4,10,7,25,.18},{'Broadway Coffee','alley-walls',1,-12,5.7,20,.23},
  {'Carey Market','alley-walls',3,0,7,26,.09},{'Eastern Coffee','alley-walls',2,13,7,24,.17},
  {'Garden Coffee','alley-walls',1,-10,5.8,21,.28},{'Orleans Coffee','athlete-paint',1,13,7.2,13,.07},
  {'Union Coffee','athlete-paint',2,-17,7.2,13,.08}
 } do
  local wall=city:FindFirstChild(v[1],true)['Back wall']
  mural(wall,E.NormalId.Back,v[3],v[4],v[5],v[6],v[7],v[2])
 end
 local function annex(name,x,z,id,angle,sidewalk)
  local m=group(name,civic); local f=builder(m,x,z,angle)
  m:SetAttribute('SidewalkOffset',sidewalk)
  f('Public entrance walk',14,.45,-sidewalk-15,0,.62,(sidewalk-15)/2,cream,'Concrete')
  f('Station house floor',36,.8,30,0,1,0,cream,'Concrete'); f('Rear',36,11,1,0,6.8,15,blue,'Brick')
  for _,side in {-1,1} do f('Side',1,11,30,side*18,6.8,0,blue,'Brick'); glass(f,'Street window',11,9,.6,side*12.5,6,-15) end
  f('Station roof',37,1,31,0,13,0,'dark','Metal'); lettering(f('Station sign',36,2.8,.55,0,11.7,-15.5,blue,'Metal'),name:upper())
  for _,side in {-1,1} do
   f('Waiting seat base',6.8,1.5,2.6,side*12,2.2,-4,'dark','Metal')
   f('Waiting seat cushion',7.2,.65,3,side*12,3.2,-4,blue,'Fabric')
   f('Waiting backrest',7.2,2.4,.48,side*12,4.25,-5.4,blue,'Fabric')
   glow(f,side*10,11.8,3)
  end
  f('Dispatch cabinet',6,4,2,-12,3.45,12,cream,'Metal')
  lettering(f('Service board',7,3.2,.35,-12,7.2,14.3,blue,'Metal'),id=='PoliceDesk' and 'REPORTS' or 'TRIAGE')
  local desk=f('Duty desk',12,3.3,3,0,3,10,'dark','Metal'); action(desk,'WorkStop',name); desk:SetAttribute('Station',id)
 end
 annex('District police desk',-54,124,'PoliceDesk',-90,-33); annex('Medic dispatch',164,153,'MedicDesk',180,-36)
end
