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
  p('Front pier',3,25,.8,-9.2,13.5,14.3,tint,'Brick'); p('Front bay',12,25,.8,4.8,13.5,14.3,tint,i%3==0 and 'Concrete' or 'Brick')
  p('Door lintel',6.5,15,.8,-4.3,18.5,14.3,tint,'Brick')
  p('Roof',22.1,.8,30,0,26.3,0,'dark','Slate'); p('Cornice',22.4,1.2,1.4,0,25.6,14.6,cream,'Concrete')
  for _,v in {{-5,20},{5,20},{5,8}} do
   p('Window casing',6.6,7.8,.5,v[1],v[2],15,cream,'Concrete')
   if vacant then
    p('Plywood infill',5.8,7,.42,v[1],v[2],15.4,rgb(125,103,76),'WoodPlanks')
    local board=p('Cross batten',6.8,.6,.4,v[1],v[2],15.75,'dark','Wood'); board.CFrame*=cf.Angles(0,0,.27)
   else glass(p,'Double hung sash',5.6,6.6,.4,v[1],v[2],15.4); p('Meeting rail',5.6,.3,.55,v[1],v[2],15.65,cream,'Wood') end
  end
  for k=1,3 do p('Marble stoop',7,k*.45,1.2,-4.4,k*.225,19.5-k*1.18,cream,'Concrete') end
  p('Stoop rail',.32,3.6,.32,-8,2.3,18,'dark','Metal'); p('Stoop rail',.32,3.6,.32,-8,2.8,15.6,'dark','Metal')
  local rail=p('Handrail',.32,.3,3.4,-8,4.4,17,'dark','Metal'); rail.CFrame*=cf.Angles(.17,0,0)
  if vacant then
   p('Boarded door',6.2,9,.6,-4.4,6,14.3,rgb(110,91,70),'WoodPlanks')
   p('Chipped stoop fragment',2,.6,1.5,3,.4,18,cream,'Concrete')
  else lounge(p,2,1.8,-3,blue); lease(p,m.Name,1,5,13.5,0); glow(p,0,12,0) end
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
  lounge(p,3,1.55,1,blue); p('Entry bell post',1.1,4.8,1.1,2,2.5,-14,cream,'Limestone'); lease(p,m.Name,2,4.2,-14.85,200); glow(p,0,13,0)
 end
 for _,v in {{'North Avenue Fuel',60,148,90,60},{'Franklin Fuel',-510,994,-90,60},{'Eastside Fuel',719,111,90,59}} do
  local m=group(v[1],service); local p=builder(m,v[2],v[3],v[4])
  p('Driveway throat',37,.35,v[5]-17,0,.43,-(v[5]-17)/2,'stone','Concrete')
  p('Station apron',45,.6,69,0,.38,-15,'stone','Concrete')
  p('Shop floor',34,.7,24,0,.9,2,cream,'Marble'); p('Rear wall',34,12,.8,0,7.2,14,cream,'Brick')
  for _,s in {-1,1} do p('Return wall',.8,12,24,s*17,7.2,2,cream,'Brick'); glass(p,'Storefront',11.4,9,.45,s*11,5.9,-10) end
  p('Store roof',36,1,26,0,13.4,2,'dark','Metal')
  lettering(p('Store fascia',35,3,.55,0,11.7,-10.5,blue,'Metal'),v[1]:upper()..'  •  MART')
  for _,s in {-1,1} do p('Shelf',7,3,3,s*11,2.85,4,cream,'Metal'); for k=-2,2 do p('Grocery stock',.8,1.2,1.6,s*11+k,5,4,k%2==0 and 'gold' or 'green','SmoothPlastic') end end
  p('Checkout desk',9,3.2,3,0,3,9,'dark','Wood')
  action(p('Mart till',2,1.5,1.7,0,5.4,8.8,'dark','Metal'),'Mart','Buy supplies')
  for _,s in {-1,1} do
   p('Pump island',4.6,.45,9,s*8,.83,-30,'cream','Concrete')
   p('Canopy column',.9,14,.9,s*8,7.4,-27.2,'stone','Metal')
   p('Fuel dispenser',3.6,5,2.4,s*8,3.1,-31,blue,'Metal')
   local pump=p('Pump face',3.4,1.4,.25,s*8,4.2,-32.4,'dark','Metal'); lettering(pump,'REGULAR'); action(pump,'Fuel','Fill tank · $1 per 5%')
   p('Nozzle cradle',.42,1.2,.38,s*9.65,3.1,-32.25,'dark','Metal')
   p('Rubber hose',.22,2.4,.24,s*9.93,2.45,-32.13,'dark','Rubber')
   p('Hose return',.56,.22,.24,s*9.77,1.35,-32.13,'dark','Rubber')
  end
  p('Fuel canopy',36,1,18,0,15,-32,blue,'Metal'); p('Canopy trim',36,1,1,0,14.4,-41,'gold','Metal')
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
 p('Civic hall',127,23,29,0,12,0,cream,'Limestone')
 for _,u in {-53,-38,-23,23,38,53} do glass(p,'Civic arch window',7,13,.4,u,12,-14.8); p('Classical pier',2,22,2,u+5.2,12,-15,cream,'Marble') end
 for k,v in {{30,48},{24,24},{20,20}} do local y=({46,82,104})[k]; p('Tower stage',v[1],v[2],v[1],0,y,0,cream,'Limestone'); p('Tower entablature',v[1]+3,1.4,v[1]+3,0,y+v[2]/2,0,cream,'Marble') end
 for _,u in {-11,11} do
  p('Fluted civic column',2.2,45,2.2,u,45,-15.6,cream,'Marble')
  p('Column capital',3.5,2.5,3.2,u,68,-15.5,cream,'Marble')
 end
 for _,y in {33,52,102} do
  glass(p,'Belfry recess',8,12,.45,0,y,y==102 and -10.4 or -15.45)
  p('Window mullion',.65,12,.65,0,y,y==102 and -10.8 or -15.85,cream,'Limestone')
 end
 for i=0,3 do
  local pivot=cf.new(0,0,1079)*cf.Angles(0,i*math.pi/2,0)
  local rim=p('Bronze clock rim',.56,13.2,13.2,0,0,0,'dark','Metal'); rim.Shape=E.PartType.Cylinder; rim.CFrame=pivot*cf.new(0,82,-12.4)*cf.Angles(0,math.pi/2,0)
  local dial=p('Clock face',.3,12.1,12.1,0,80,0,'cream','SmoothPlastic'); dial.Shape=E.PartType.Cylinder; dial.CFrame=pivot*cf.new(0,82,-12.79)*cf.Angles(0,math.pi/2,0)
  local hand=p('Clock minute hand',.5,4.5,.45,0,80,0,'dark','Metal'); hand.CFrame=pivot*cf.new(0,84,-12.9); hand:SetAttribute('ClockPivot',pivot*cf.new(0,82,-13.1))
  local hour=p('Clock hour hand', .5,3.8,.45,0,80,0,'dark','Metal'); hour.CFrame=pivot*cf.new(0,83.8,-13.5); hour:SetAttribute('ClockPivot',pivot*cf.new(0,82,-13.5))
  for n=0,11 do local a=n*math.pi/6; local tick=p('Clock index',.36,.8,.26,0,0,0,'dark','Metal'); tick.CFrame=pivot*cf.new(5*math.sin(a),82+5*math.cos(a),-12.9)*cf.Angles(0,0,-a) end
 end
 local dome=p('Copper dome',18,13,18,0,119,0,blue,'Metal'); dome.Shape=E.PartType.Ball
 p('Lantern',4,7,4,0,127,0,cream,'Metal'); p('Spire',.65,12,.65,0,136,0,'gold','Metal')
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
 local function annex(name,x,z,id)
  local m=group(name,civic); local f=builder(m,x,z)
  f('Station house floor',28,.8,22,0,1,0,cream,'Concrete'); f('Rear',28,11,1,0,6.8,11,blue,'Brick')
  for _,side in {-1,1} do f('Side',1,11,22,side*14,6.8,0,blue,'Brick'); glass(f,'Street window',8,9,.6,side*9.5,6,-11) end
  f('Station roof',29,1,23,0,13,0,'dark','Metal'); lettering(f('Station sign',28,2.8,.55,0,11.7,-11.5,blue,'Metal'),name:upper())
  local desk=f('Duty desk',9,3.3,3,0,3,5,'dark','Metal'); action(desk,'WorkStop',name); desk:SetAttribute('Station',id)
 end
 annex('District police desk',-69,102,'PoliceDesk'); annex('Medic dispatch',66,152,'MedicDesk')
end
