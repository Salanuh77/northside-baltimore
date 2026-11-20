local furnish=require('./home-furniture')
local facade=require('./residential-facades')
local fixtures=require('./shop-fixtures')
local rb = require('@lune/roblox')
local cf, rgb, Enum = rb.CFrame, rb.Color3.fromRGB, rb.Enum
return function(part,group,label,action,city)
 local garden=rgb(72,113,87)
 local blue=rgb(66,122,141)
 local bone=rgb(229,211,179)
 local bronze=rgb(155,111,61)
 local harbor=group('Inner Harbor • Quay District',city)
 local west=group('Lanvale Courts',city)
 local east=group('Eastgate Terrace',city)
 local south=group('Madison Gardens',city)
 local market=group('Broadway Market District',city)
 local mill=group('Foundry Quarter',city)
 local function builder(model,x,z,angle)
  local base=cf.new(x,0,z)*cf.Angles(0,math.rad(angle or 0),0)
  return function(name,w,h,d,u,y,v,color,mat)
   local p=part(name,{w,h,d},{0,0,0},color,mat,model); p.CFrame=base*cf.new(u,y,v); return p
  end
 end
 local function lettering(p,text)
  label(p,text,bone)
 end
 local function glass(p,name,w,h,d,x,y,z)
  local pane=p(name,w,h,d,x,y,z,blue,'Glass'); pane.Transparency=.40
  return pane
 end
 local function tree(p,x,z,i)
  p('Tree pit',7,.35,7,x,.72,z,'dark','Slate')
  p('Trunk',1.25,10,1.25,x,5.6,z,bronze,'Wood')
  local canopy=p('Crown',10,12,9,x,13,z,i%2==0 and rgb(68,115,84) or rgb(92,135,90),'Grass'); canopy.Shape=Enum.PartType.Ball
  local crown=p('Crown',8,8,8,x+2.2,10,z+1,garden,'Grass'); crown.Shape=Enum.PartType.Ball
 end
 local function bench(p,x,z)
  for _,dx in {-3.5,3.5} do p('Cast iron foot',.55,2.3,2.4,x+dx,1.7,z,'dark','Metal') end
  p('Slatted seat',9,.55,2.5,x,2.7,z,bronze,'WoodPlanks')
  p('Bench back',9,2,.45,x,3.8,z+1.15,bronze,'WoodPlanks')
 end
 local function tableSet(p,x,z,y)
  p('Cafe pedestal',1.1,2.7,1.1,x,y+1.35,z,'dark','Metal')
  local top=p('Oak tabletop',5,.45,4,x,y+2.8,z,bone,'Wood')
  for _,dx in {-4,4} do
   p('Chair frame',1.2,2.2,1.3,x+dx,y+1.1,z,'dark','Metal')
   p('Chair seat',2.8,.5,2.8,x+dx,y+2.2,z,bronze,'Wood')
   p('Chair back',.4,2.2,2.8,x+dx+math.sign(dx)*1.2,y+3.4,z,bronze,'Wood')
  end
 end
 local function glow(p,x,y,z)
  local lamp=p('Pendant diffuser',3,.5,3,x,y,z,bone,'Neon')
  local light=rb.Instance.new('PointLight'); light.Range=30; light.Brightness=.8; light.Color=rgb(255,231,192); light.Parent=lamp
 end
 local function lounge(p,x,y,z,col)
  p('Woven rug',14,.12,10,x,y+.07,z,'cream','Fabric')
  p('Couch',10,2.2,3.1,x,y+1.5,z+2.5,col,'Fabric')
  p('Upholstered back',10,3.1,.65,x,y+2.35,z+4,col,'Fabric')
  p('Coffee table base',1.5,1.5,1.5,x,y+.8,z-2,'dark','Metal')
  p('Coffee table top',6,.38,3,x,y+1.7,z-2,bronze,'Wood')
 end
 -- Each floor has two flats opening onto a shared gallery. The stair and
 -- return passage occupy separate lanes, so each landing reaches the next flight.
 local function apartments(district,name,x,z,angle,levels,tint)
  local m=group(name,district); local p=builder(m,x,z,angle)
  p('Entrance walk',76,.6,4,0,.56,-28.5,'stone','Concrete')
  for level=0,levels-1 do
   local y=level*13+1
   p('Apartment floor',66,.7,48,-9,y,0,'cream','WoodPlanks')
   p('Gallery deck',88,.72,9,0,y,-22,'stone','Concrete')
   if levels>=8 then
    local pad=p('Lift landing',9,.72,9,-46,y,-22,'stone','Concrete')
    p('Lift surround',8,12,.7,-47,y+6.4,-17.5,'dark','Metal')
    p('Brushed lift doors',6.2,9,.4,-47,y+5,-18.2,'stone','Metal')
    local call=p('Lift controls',1.8,2.4,.45,-42.9,y+4.1,-18.6,bronze,'Metal')
    action(call,'Lift','Choose floor'); call:SetAttribute('Floor',level+1)
    pad:SetAttribute('Landing',level+1); m:SetAttribute('Floors',levels)
   end
   p('Stair return passage',9,.72,48,42,y,0,'stone','Concrete')
   p('Landing',23.5,.72,9,34.75,y,20,'stone','Concrete')
   for _,pos in {-10,10} do
    p('Gable base',.85,3,19.9,-42,y+1.9,pos+3,tint,'Brick')
    p('Gable sill',1.3,.5,9,-42,y+3.55,pos+3,bone,'Concrete')
    for _,q in {-1,1} do p('Gable jamb',.85,7,5.2,-42,y+7.15,pos+3+q*7.4,tint,'Brick') end
    glass(p,'Side sash',.42,7.2,9.5,-42,y+7.15,pos+3)
    p('Sash division',.7,7.1,.42,-42,y+7.15,pos+3,bone,'Metal')
    p('Lintel',.9,2.3,19.9,-42,y+11.75,pos+3,tint,'Brick')
   end
   for _,edge in {-9,24} do p('Party wall',.7,12.6,40.4,edge,y+6.6,3.5,tint,'Brick') end
   for n=1,2 do
    local u=-25.5+(n-1)*33
    local base,ceiling=y+.35,y+12.65
    facade.bay(p,u-16.5,u-5.15,base,ceiling,-17,tint,'Brick',u-8.7,y+5.55,7.1,10.4)
    facade.bay(p,u-5.15,u+16.5,base,ceiling,-17,tint,'Brick',u+6,y+7,11.5,6.8)
    local trim=rgb(69,76,73)
    facade.sash(p,'Gallery window',u+6,y+7,-17,11.5,6.8,-1,trim,true)
    local coats={rgb(64,83,75),rgb(65,76,85),rgb(104,70,55)}
    local paint=coats[(n+level)%#coats+1]
    local door=p('Apartment door',6.75,10.3,.42,u-8.7,y+5.55,-17,paint,'SmoothPlastic')
    action(door,'Door','Open / close')
    facade.frame(door,7.1,10.4,0,-1)
    facade.entry(door,Enum.NormalId.Front)
    for _,side in {-1,1} do
     p('Entry casing',.24,10.4,.8,u-8.7+side*3.50,y+5.55,-17.1,bone,'Metal')
    end
    p('Entry casing head',7.25,.32,.82,u-8.7,y+10.82,-17.1,bone,'Metal')
    lettering(p('Flat number',2.4,1.1,.15,u-14.2,y+6,-17.55,bronze,'Metal'),tostring((level+1)*100+n))
    for _,side in {-1,1} do
     local pos=u+side*8.25
     facade.bay(p,pos-8.25,pos+8.25,base,ceiling,23.5,tint,'Brick',pos,y+7.4,13.5,7.4)
     facade.sash(p,'Bedroom sash',pos,y+7.4,23.5,13.5,7.4,1,trim,true)
    end
    if (level+n)%3==0 then
     -- Short interior shades leave a view across the living room at eye height.
     p('Linen shade',5.35,1.25,.12,u+8.82,y+9.45,-16.36,rgb(199,184,155),'Fabric')
    end
    local flatFrame=cf.new(x,0,z)*cf.Angles(0,math.rad(angle),0)*cf.new(u,y+.35,0)
    furnish(m,flatFrame,'Flat',(level+1)*100+n)
    p('Refrigerator',3.5,7,3.5,u-13,y+3.9,-10,'cream','Metal')
    p('Freezer handle',.3,1.7,.3,u-11.1,y+5,-10,'dark','Metal')
    p('Washroom partition',.55,11,10,u+9.2,y+6,18.2,bone,'Plaster')
    p('Washroom entry return',2.4,11,.55,u+15,y+6,13.4,bone,'Plaster')
    p('Vanity',4.2,3.2,2.5,u+12,y+2,21,'cream','Marble')
    p('Wash basin',2.7,.3,1.7,u+12,y+3.8,21,'stone','Metal')
    p('Bathroom mirror',3.6,3.8,.18,u+12,y+6.4,23.1,blue,'Glass')
    p('Bedroom partition',23,12,.65,u+4,y+6.5,5,bone,'Plaster')
    local buzzer=p('Residence intercom',1.2,1.8,.48,u-14.2,y+4,-17.65,bronze,'Metal')
    action(buzzer,'Residence','Apartment & parties')
    buzzer:SetAttribute('Address',name..' / '..tostring((level+1)*100+n))
    buzzer:SetAttribute('LeasePrice',0)
    facade.link(door,buzzer)
    local box=p('Apartment lockbox',2.8,2,2,u-11,y+1.5,18,'dark','Metal')
    action(box,'Home','Search apartment lockbox',110,9)
    glow(p,u,y+11.7,-3)
   end
   if level>0 then
    for _,h in {1.4,3.4} do p('Gallery handrail',85,.22,.3,0,y+h,-26,rgb(107,116,108),'Metal') end
    for xpost=-42,42,7 do p('Gallery picket',.22,3.25,.24,xpost,y+1.9,-26,rgb(107,116,108),'Metal') end
   end
   if level<levels-1 then
    local incline=-math.atan(13/32)
    local slab=p('Stair stringer',12,.55,35.15,31,y+6.3,-.9,'stone','Concrete')
    slab.CFrame*=cf.Angles(incline,0,0)
    for k=1,20 do
     local tread=p('Stair tread',12,.55,1.65,31,y+k*.65-.26,-17+k*1.6,'stone','Concrete')
     tread.CanCollide=false
    end
   end
  end
  for level=0,levels-2 do
   local y=1+level*13
   for _,side in {-1,1} do
    for k=0,4 do
     p('Stair rail post',.24,3.6,.24,31+side*5.5,y+2.1+k*3.25,-17+k*8,'dark','Metal')
    end
    local rail=p('Stair guard',.28,.3,34.55,31+side*5.5,y+10.4,-1,'dark','Metal')
    rail.CFrame*=cf.Angles(-math.atan(13/32),0,0)
   end
  end
  p('Oversailing roof',90,1.2,55,0,levels*13+1,0,bone,'Concrete')
  for _,u in {-42,-9,24,43} do p('Gallery column',1,levels*13,1,u,1+levels*6.5,-25,tint,'Brick') end
  -- Building names appear at the neighborhood gate.
  return m
 end
 -- Each window is laid out in its own facade plane, looking out along local +Z.
 local function millWindow(building,face,radius,tint)
  local bay=group('Foundry sash',building)
  local function fit(name,w,h,d,x,y,z,color,material)
   local v=part(name,{w,h,d},{0,0,0},color,material,bay)
   v.CFrame=face*cf.new(x,y,z)
   return v
  end
  local spring,rise=5.75,2.35
  local pane=rgb(64,93,98)
  local iron=rgb(48,54,51)
  fit('Limestone sill',2*radius+1.7,.62,1.5,0,.64,.28,bone,'Concrete')
  fit('Lower sash',2*radius,spring-.8,.38,0,(spring+.8)/2,.09,pane,'SmoothPlastic')
  local fan=fit('Arched fanlight',.38,2*rise,2*radius,0,spring,.08,pane,'SmoothPlastic')
  fan.Shape=Enum.PartType.Cylinder
  fan.CFrame*=cf.Angles(0,math.pi/2,0)
  for _,side in {-1,1} do
   fit(side<0 and 'Left jamb' or 'Right jamb',1,spring-.75,1,side*radius,(spring+.75)/2,.24,tint,'Brick')
  end
  fit('Meeting rail',2*radius,.23,.52,0,spring,.12,iron,'Metal')
  fit('Sash bar',.19,spring+rise-.85,.5,0,(spring+rise+.85)/2,.12,iron,'Metal')
  -- The first and last chords land on the jamb centerlines. Adjacent
  -- chords share their endpoints, including on the return elevations.
  local lastX,lastY=-radius,spring
  for i=1,8 do
   local angle=math.pi*(1-i/8)
   local x,y=radius*math.cos(angle),spring+rise*math.sin(angle)
   local dx,dy=x-lastX,y-lastY
   local arch=fit('Voussoir '..i,math.sqrt(dx*dx+dy*dy)+.16,.95,1,(x+lastX)/2,(y+lastY)/2,.24,tint,'Brick')
   arch.CFrame*=cf.Angles(0,0,math.atan2(dy,dx))
   lastX,lastY=x,y
  end
 end
 -- Distinct commercial silhouettes share an open, furnished ground floor.
 local function landmark(name,x,z,angle,style,levels,parent)
  local m=group(name,parent); local p=builder(m,x,z,angle)
  local widths={['Charles Center']=102,['Pratt Financial']=93,['Municipal Offices']=96,['Commerce Plaza']=87}; local w=widths[name] or (style=='mill' and 88 or 78); local d=48
  local facadeTints={['Charles Center']=rgb(104,135,153),['Baltimore Mutual']=rgb(137,146,150),['Commerce Plaza']=rgb(88,112,120),['Metropolitan Exchange']=rgb(128,126,110),['Municipal Offices']=rgb(142,143,132)}
  local tint=style=='mill' and rgb(155,81,58) or style=='deco' and rgb(202,179,145) or rgb(42,82,94)
  p('Terrazzo lobby',w,1,d,0,.6,0,bone,'Marble')
  for _,s in {-1,1} do
   glass(p,'Lobby glazing',w/2-7,13,.6,s*(w/4+3.5),7.8,-24)
   glass(p,'Side glazing',.65,13,d,s*w/2,7.8,0)
   for _,v in {-23,0,23} do p('Pilaster',2,15,2,s*w/2,8,v,tint,'Concrete') end
  end
  p('Lobby back',w,14,1,0,8,24,tint,'Brick')
  for _,u in {-24,0,24} do
   glass(p,'Rear lobby display',15,8,.35,u,8,24.7)
   p('Rear sill',16,.55,1.35,u,3.7,24.9,bone,'Concrete')
  end
  p('Lobby desk',18,3.5,4,-17,2.8,13,tint,'Wood')
  local directory=p('Brass lobby directory',10,2.5,.35,-16,7.5,23.3,bronze,'Metal'); lettering(directory,name)
  lounge(p,19,1.1,9,garden); tableSet(p,-22,-11,1.1); glow(p,0,13,2)
  p('Entry canopy',34,.8,9,0,12.2,-27,bronze,'Metal')
  p('Canopy edge',34,.45,.45,0,12,-31,bronze,'Metal')
  p('Podium cornice',w+3,2.8,d+3,0,15.7,0,bone,'Concrete')
  local base=cf.new(x,0,z)*cf.Angles(0,math.rad(angle),0)
  for k=1,levels do
   local y=17+(k-1)*10
   if style=='mill' then
    p('Foundry masonry',w,10,d,0,y+5,0,tint,'Brick')
    p('Floor band',w+1.1,.8,d+1.1,0,y+9.65,0,tint,'Brick')
    for _,s in {-1,1} do
     local front=base*cf.new(0,y,s*d/2)*cf.Angles(0,s==1 and 0 or math.pi,0)
     local flank=base*cf.new(s*w/2,y,0)*cf.Angles(0,s*math.pi/2,0)
     for bay=-3,3 do millWindow(m,front*cf.new(bay*w/7,0,0),4.6,tint) end
     for bay=-1,1 do millWindow(m,flank*cf.new(bay*d/3,0,0),5.1,tint) end
    end
    continue
   end
   local setback=style=='deco' and math.min(20,math.floor((k-1)/3)*4) or style=='glass' and (k>4 and 4 or 0) or 0
   local a,b=w-2*setback,d-setback
   local skin=p('Glazed floor',a,9.4,b,0,y+4.8,0,facadeTints[name] or blue,'SmoothPlastic'); skin.Reflectance=.13
   p('Floor band',a+1.4,style=='glass' and .8 or 1.55,b+1.4,0,y+9.6,0,tint,'Metal')
   for _,s in {-1,1} do
    for j=-3,3 do p('Facade mullion',.65,9.8,.9,j*(a-6)/6,y+4.8,s*b/2,tint,'Metal') end
    -- Occasional occupied bays give the dark waterfront glass a scale at dusk.
    if (k+s)%3==0 and style=='glass' then
     local j=(k+#name)%6-3
     local spacing=(a-6)/6
     local color=skin.Color:Lerp(rgb(162,171,170),.32)
     local glassBay=p('Occupied tower bay',spacing-.9,7.65,.18,(j+.5)*spacing,y+5.07,s*(b/2+.16),color,'SmoothPlastic')
     glassBay.CanCollide=false;glassBay.CanQuery=false;glassBay.CastShadow=false
     glassBay:SetAttribute('DayGlass',color)
     glassBay:SetAttribute('EveningGlass',(k%2==0 and rgb(179,154,108) or rgb(183,175,147)))
     p('Window transom',spacing-.65,.26,.35,(j+.5)*spacing,y+7.15,s*(b/2+.28),tint,'Metal')
    end
    for j=-1,1 do p('Return mullion',.9,10,1,s*a/2,y+4.8,j*(b-4)/2,tint,'Metal') end
   end
  end
  if style=='deco' then
   for _,u in {-12,-7,7,12} do
    p('Fluted tower pier',1.1,28,2,u,30,-24.8,bone,'Concrete')
    p('Brass pier cap',1.5,2.8,2.4,u,45,-24.8,bronze,'Metal')
   end
  elseif style=='glass' then
   for k=1,levels,2 do
    local inset=k>4 and 4 or 0
    p('Cantilevered sunshade',w-2*inset+4,.55,5,0,17+k*10,-24+inset*.5,'cream','Metal')
   end
  end
  local top=17+levels*10
  if style=='mill' then
   for _,u in {-27,-7,13} do
    local stack=p('Kiln chimney',24,5.4,5.4,u,top+11,10,tint,'Brick'); stack.Shape=Enum.PartType.Cylinder; stack.CFrame*=cf.Angles(0,0,math.pi/2)
    local rim=p('Chimney lip',1.4,6.4,6.4,u,top+23,10,bone,'Concrete'); rim.Shape=Enum.PartType.Cylinder; rim.CFrame*=cf.Angles(0,0,math.pi/2)
   end
  elseif style=='deco' then
   p('Crown',w*.46,8,d*.54,0,top+3,0,tint,'Concrete')
   for j=-2,2 do p('Crown fin',1.4,12-math.abs(j)*2,12,j*5,top+7,0,bronze,'Metal') end
  else p('Roof lantern',w*.55,5,d*.55,0,top+2,0,blue,'Glass') end
 end
 local function pavilion(name,x,z,angle,tint,parent,kind)
  local m=group(name,parent); local p=builder(m,x,z,angle)
  -- Each hall has a walk-in retail floor beneath a continuous commercial cornice.
  local clay={rgb(141,77,57),rgb(145,96,75),rgb(123,75,61)}
  local face=kind=='cafe' and clay[(#name%3)+1] or kind=='market' and rgb(170,126,79) or rgb(179,164,144)
  local metal=rgb(47,64,65)
  local levels=kind=='gallery' and 2 or 1
  p('Hall floor',69,.8,42,0,.65,0,'cream','WoodPlanks')
  p('Back wall',69,14,1,0,7.8,21,face,'Brick')
  for _,s in {-1,1} do
   glass(p,'Display glazing',27,9.5,.4,s*20,6.8,-20.6)
   p('Stone stall riser',27,1.4,1,s*20,1.6,-21,bone,'Limestone')
   glass(p,'Clerestory return',.55,13,42,s*34,7.5,0)
   for _,u in {7,20,33.7} do p('Bronze mullion',.5,12.7,.8,s*u,7.5,-21,metal,'Metal') end
   for _,v in {-20,0,20} do p('Cast iron columns',1.1,14,1.1,s*34,8,v,metal,'Metal') end
   p('Upper masonry pier',2.2,levels*9,42,s*33.5,15+levels*4.5,0,face,'Brick')
  end
  p('Continuous ceiling',69,.85,42,0,14.78,0,bone,'Concrete')
  p('Glazed transom rail',69,.28,.9,0,11.65,-21,metal,'Metal')
  glass(p,'Upper transom glazing',69,2.6,.5,0,13,-21)
  for _,side in {-1,1} do p('Side cornice',1,1.6,42,side*34,14.1,0,face,'Brick') end
  p('Recessed entrance surround',13,2.65,.7,0,10.45,-21,metal,'Metal')
  p('Canopy over entry',17,.4,5,0,11.5,-23,metal,'Metal')
  p('Shop sign arm',.25,.3,5.5,8.4,11.2,-23.5,bronze,'Metal')
  if kind=='cafe' then
   local medallion=p('Round enamel coffee sign',.38,4.4,4.4,8.4,8.96,-25.1,garden,'Metal')
   medallion.Shape=Enum.PartType.Cylinder
   p('Sign pendant',.22,.65,.22,8.4,11.1,-25.1,bronze,'Metal')
   for _,side in {-1,1} do
    local u=8.4+side*.23
    p('Porcelain cup',.13,1,1.55,u,8.8,-25.22,bone,'Metal')
    p('Saucer',.14,.15,2.15,u,8.14,-25.15,bone,'Metal')
    p('Cup handle',.14,.58,.48,u,8.93,-24.35,bone,'Metal')
    p('Handle cutout',.16,.25,.22,u+side*.02,8.95,-24.34,garden,'Metal')
    for _,v in {-.30,.27} do local steam=p('Steam',.12,.55,.12,u,9.82,-25.2+v,bone,'Metal'); steam.CFrame*=cf.Angles(.26,0,0) end
   end
  else
   local blade=p('Enamel shop blade',4.8,2.7,.22,8.4,9.65,-25,tint,'Metal'); blade.CFrame*=cf.Angles(0,math.pi/2,0)
   lettering(blade,kind=='gallery' and 'GALLERY' or 'MARKET')
   local reverse=blade:FindFirstChildOfClass('SurfaceGui'):Clone(); reverse.Face=Enum.NormalId.Back; reverse.Parent=blade
  end
  p('Upper rear masonry',69,levels*9,.8,0,15+levels*4.5,20.6,face,'Brick')
  for level=1,levels do
   local base=15+(level-1)*9
   for bay=-2,2 do
    local u=bay*13.3
    local l=bay==-2 and -34.5 or u-6.65
    local r=bay==2 and 34.5 or u+6.65
    facade.bay(p,l,r,base,base+9,-20.7,face,'Brick',u,base+4.4,10.8,6.1)
    facade.sash(p,'Office glazing',u,base+4.4,-20.7,10.8,6.1,-1,metal,true)
    if (bay+level)%3==0 then p('Office roller shade',10.1,1.1,.15,u,base+6.55,-19.7,bone,'Fabric') end
   end
   p('Office slab',68.2,.32,40.4,0,base+.02,0,bone,'Concrete')
  end
  local top=15+levels*9
  p('Flat roof',69.5,.65,42.5,0,top+.33,0,'dark','Slate')
  p('Parapet crown',70.5,1.1,1.5,0,top+1,-21.2,bone,'Limestone')
  p('Rear coping',69,.8,1,0,top+1,21,bone,'Limestone')
  p('Ventilation plant',8,2.6,5,15,top+1.9,10,metal,'Metal')
  if kind=='cafe' then
   for _,u in {-20,16} do for _,v in {-10,4} do tableSet(p,u,v,1.05) end end
   local bar=p('Serving bar',23,3.5,5,0,2.9,14,bronze,'Wood')
   fixtures.staff(bar,'Barista',0,4.4,1.05);fixtures.coffee(p)
   action(bar,'Coffee','Buy coffee · $6')
  elseif kind=='gallery' and name~='Exchange Streetwear' and name~='Eastern Outfitters' and name~='Union Athletics' then
   local desk=p('Gallery desk',7.2,3.2,3,0,2.65,15,bronze,'Wood')
   fixtures.staff(desk,'Gallery attendant',0,3.6,1.05)
   for i=-1,1 do
    p('Gallery plinth',6,3.2,6,i*20,2.7,4,bone,'Marble')
    local art=p('Sculpture',3+i,5,3,i*20,7,4,tint,'Metal'); art.CFrame*=cf.Angles(.3,.35,.5)
   end
  elseif kind=='market' then
   for _,u in {-19,18} do for _,v in {-5,9} do
    p('Vendor counter',14,3.5,5,u,2.8,v,bronze,'WoodPlanks')
    for n=-1,1 do p('Produce crate',3,1.3,3,u+n*4,5.25,v,n==0 and garden or 'gold','Wood') end
   end end
  end
  if kind=='market' then
   p('Cash desk',9,3.5,4,0,2.8,15,bronze,'Wood')
   local till=p('Market till',2,1.3,1.8,0,5.2,14.7,'dark','Metal')
   fixtures.register(till);fixtures.staff(till,'Grocer',0,3.65,1.05)
   action(till,'Store','Rob register',225,12)
  end
  if name=='Eastern Outfitters' or name=='Exchange Streetwear' or name=='Union Athletics' then
   local clothing=name=='Exchange Streetwear'
   local sporting=name=='Union Athletics'
   local counter=p('Sales counter',13,3.8,4,-15,2.9,-10,bronze,'WoodPlanks')
   action(counter,clothing and 'Clothing' or sporting and 'Sporting' or 'GunStore',clothing and 'Shop streetwear' or sporting and 'Shop sports equipment' or 'Browse sidearms')
   if name=='Eastern Outfitters' then city:SetAttribute('OutfittersDesk',counter.CFrame.Position) end
   local plaque=p('Shop window lettering',24,2.7,.22,-19,8,-21.3,bone,'Metal')
   plaque.Transparency=1; plaque.CanCollide=false; lettering(plaque,name:upper())
   fixtures.staff(counter,clothing and 'Stylist' or sporting and 'Sports clerk' or 'Outfitters clerk',0,3.65,1.05)
   if clothing then fixtures.clothing(p,lettering,0,3) end
   if sporting or name=='Eastern Outfitters' then
    for j=-1,1 do
     p('Stockroom shelf',8,.32,3,j*10,5.6,18,metal,'Metal')
     for k=-1,1 do p('Boxed stock',2.3,1.6,2.4,j*10+k*2.5,6.55,18,k==0 and bronze or bone,'Wood') end
    end
   end
  end
  glow(p,-16,13,0); glow(p,16,13,0)
 end
 local chairAsset=rb.deserializeModel(require('@lune/fs').readFile('art/baltimore-barber-chair.rbxm'))[1]
 local chairMesh=assert(chairAsset:FindFirstChildWhichIsA('MeshPart',true),'Barber chair import missing')
 local function communityRoom(district,name,x,z,kind)
  local room=group(name,district); local p=builder(room,x,z)
  p('Tile floor',42,.8,30,0,.7,0,bone,'Marble')
  p('Painted back wall',42,13,.7,0,7.4,15,'cream','Plaster')
  for _,s in {-1,1} do
   p('Blockwork return',.7,13,30,s*21,7.4,0,'brick','Brick')
   glass(p,'Plate glass',15.5,10,.5,s*13,6.5,-15)
  end
  p('Fascia',43,3.3,1,0,12.4,-15,garden,'Metal')
  local glyph=p('Community door lettering',13,2.2,.2,9,10,-15.7,bone,'Metal'); glyph.Transparency=1; glyph.CanCollide=false; lettering(glyph,kind:upper())
  p('Roof',43,1.1,32,0,14.1,0,'cream','Concrete')
  p('Striped valance',43,.7,5,0,10.7,-17,garden,'Fabric')
  if kind=='Laundry' then
   for i=-2,2 do
    p('Washer',6.3,5.5,5,i*7,3.9,10,bone,'Metal')
    local drum=p('Washer door',.45,3.8,3.8,i*7,3.7,7.25,blue,'Glass')
    drum.Shape=Enum.PartType.Cylinder; drum.CFrame*=cf.Angles(0,math.pi/2,0)
    p('Controls',4,.6,.25,i*7,6,7.4,'dark','Metal')
   end
   fixtures.staff(p('Folding island',12,3.5,4,7,2.85,-3,'stone','Concrete'),'Laundry attendant',0,3.8,1.1)
   bench(p,-10,-3)
  elseif kind=='Barber' then
   for _,u in {-12,0,12} do
    p('Mirror surround',8,7,.55,u,7.3,14.4,bronze,'Wood')
    local mirror=p('Mirror',7.2,6.3,.22,u,7.3,14,blue,'Glass'); mirror.Reflectance=.3
    p('Tool cabinet',8.4,3.4,2,u,2.8,12.6,'dark','Wood')
    p('Porcelain worktop',8.7,.36,2.3,u,4.65,12.45,bone,'Marble')
    for _,side in {-1,1} do
     p('Mirror tube',.28,5.7,.3,u+side*4.18,7.5,13.9,bone,'Neon')
    end
    for j=1,3 do p('Pomade tin',.72,.43,.7,u-3+j*.84,5.05,12.2,j%2==0 and bronze or garden,'Metal') end
    local chair=chairMesh:Clone()
    chair.Name='Barber chair'; chair.Size=chairMesh.Size*(7.2/chairMesh.Size.Y)
    chair.Anchored=true; chair.CanCollide=false; chair.CanTouch=false
    chair.CFrame=cf.new(x+u,1.1+chair.Size.Y/2,z+6)*cf.Angles(0,math.pi,0)
    chair.Parent=room
    local seat=rb.Instance.new('Seat')
    seat.Name='Swivel seat';seat.Size=rb.Vector3.new(2.75,.25,2.2);seat.Anchored=true;seat.Transparency=1
    seat.CFrame=cf.new(x+u,4.7,z+5.8)*cf.Angles(0,math.pi,0);seat.Parent=room
    local tray=p('Clipper tray',1.35,.35,1.8,u+2.05,5.5,5.7,bronze,'Metal')
    action(tray,'Barber','Choose a haircut')
    if name=='Juniper Barber' and u==0 then tray:SetAttribute('Station','BarberChair') end
   end
   for _,u in {11,16} do
    p('Waiting chair base',2.6,1.5,2.7,u,1.85,-8,bronze,'Wood')
    p('Waiting chair cushion',3.8,.65,3.5,u,2.84,-8,blue,'Fabric')
    p('Waiting chair back',3.8,2.8,.55,u,3.95,-9.6,blue,'Fabric')
   end
   p('Reception cabinet',7,3.3,3.6,-12,2.75,-8,bronze,'Wood')
   fixtures.staff(p('Reception counter',7.4,.32,3.9,-12,4.55,-8,bone,'Marble'),'Barber',0,3.6,1.1)
   for j=0,6 do p('Enamel barber pole',1.25,.49,1.25,-7,6+j*.49,-16.15,({bone,blue,bone,rgb(168,62,54)})[j%4+1],'Metal') end
   if name=='Juniper Barber' then local clock=p('Shift book',2,.3,1.6,-11,4.88,-8,bone,'Wood'); action(clock,'WorkStop','Sign in'); clock:SetAttribute('Station','BarberDesk') end
  else
   for _,u in {-13,13} do
    p('Library case',10,8,2.6,u,5,13,bronze,'Wood')
    for level=1,2 do for j=-3,3 do p('Book spine',.8,2,.65,u+j*1.3,level*3,11.4,j%2==0 and garden or blue,'Fabric') end end
    tableSet(p,u,-3,1.1)
   end
  end
  glow(p,0,12.5,0)
  local box=p('Parcel shelf',4,3,2,17,2.7,-17,bone,'Metal')
  action(box,'Delivery',name)
 end
 local function court(district,name,x,z,n,angle,tint)
  local p=builder(group(name..' green',district),x,z)
  p('Garden square',175,.48,145,0,.03,0,garden,'Grass')
  p('Courtyard walk',174,.4,16,0,.42,0,'cream','Concrete')
  p('Access walk',12,.48,144,0,.42,0,'stone','Concrete')
  apartments(district,name..' A',x-41,z-41,180,n,tint)
  apartments(district,name..' B',x+41,z+41,0,n-1,tint)
  for _,s in {-1,1} do bench(p,s*35,7); tree(p,s*70,4,n); tree(p,s*13,3,n+1) end
 end
 local function square(district,name,x,z,tint)
  local p=builder(group(name,district),x,z)
  p('Paved square',164,.55,147,0,.08,0,tint,'Cobblestone')
  for _,u in {-64,64} do for _,v in {-53,-16,22,54} do if name=='Franklin Square' and u==64 then continue end; tree(p,u,v,math.floor(v)); bench(p,u-math.sign(u)*6,v) end end
  for _,v in {-49,49} do p('Planting bed',58,1,8,0,1,v,garden,'Grass') end
 end
 -- Six harbor blocks between the boulevard and the old neighborhoods.
 local monuments={
  {'Quay Arts Exchange',-555,'mill',3},{'Tidewater Hotel',-345,'deco',8},
  {'Pier Three Works',-120,'mill',4},{'Harborlight Offices',120,'glass',8},
  {'Chesapeake Trust',345,'deco',10},{'Eastern Wharf Studios',555,'glass',4},
 }
 for i,v in monuments do
  square(harbor,v[1]..' plaza',v[2],-334,bone)
  landmark(v[1],v[2],-357,0,v[3],v[4],harbor)
  pavilion(({'Quay Coffee','Tidewater Books & Art','Boiler House Market','Harbor Roasters','Chesapeake Gallery','Wharf Produce'})[i],v[2],-260,180,i%2==0 and garden or bronze,harbor,({'cafe','gallery','market'})[(i-1)%3+1])
 end
 local walk=builder(group('Waterfront promenade',harbor),0,-510)
 walk('Brick esplanade',1430,1,48,0,.4,-20,rgb(171,116,92),'Brick')
 walk('Granite seawall',1440,8,3,0,-2,-46,bone,'Concrete')
 local water=walk('Harbor water',1940,2,350,0,-4,-222,rgb(57,128,147),'Glass'); water.Reflectance=.16
 for i=-6,6 do
  tree(walk,i*104,-12,i); bench(walk,i*104+13,-29)
  if i%2==0 then
   walk('Timber pier',13,1.3,62,i*104,0,-73,bronze,'WoodPlanks')
   for _,s in {-1,1} do for _,v in {-62,-88,-103} do walk('Mooring pile',1.8,7,1.8,i*104+s*7,0,v,'dark','Wood') end end
   local u=i*104+19
   walk('Launch hull',8,2.8,23,u,-1.2,-86,'cream','Metal')
   walk('Teak deck',7,1,19,u,.35,-86,bronze,'Wood')
   walk('Cabin',5,3,9,u,2,-85,blue,'Glass')
   walk('Canopy',6,.5,10,u,3.7,-85,'cream','Metal')
  else
   walk('Quayside railing',86,.35,.35,i*104,4,-45,'dark','Metal')
   for dx=-42,42,14 do walk('Rail post',.38,4,.38,i*104+dx,2,-45,'dark','Metal') end
  end
 end
 -- The harbor beacon sits off the promenade on a pile-supported octagonal deck.
 local beacon=builder(group('Seven Foot Knoll Lighthouse',harbor),-152,-585)
 local red=rgb(167,64,50)
 local function drum(p,name,diameter,height,x,y,z,color)
  local ring=p(name,height,diameter,diameter,x,y,z,color,'Metal')
  ring.Shape=Enum.PartType.Cylinder; ring.CFrame*=cf.Angles(0,0,math.pi/2)
  return ring
 end
 beacon('Boardwalk bridge',8,1.1,32,0,.5,16,bronze,'WoodPlanks')
 drum(beacon,'Round lookout deck',34,1.3,0,1,0,bone)
 for i=0,7 do
  local a=i*math.pi/4; local u,v=math.sin(a),math.cos(a)
  beacon('Beacon piles',1.5,11,1.5,u*14,-2,v*14,'dark','Metal')
  local wall=beacon('Octagonal lantern house',10.4,10,.8,u*12,6.7,v*12,red,'WoodPlanks'); wall.CFrame*=cf.Angles(0,a,0)
  local sash=glass(beacon,'Lookout sash',5,5,.3,u*12.7,7,v*12.7); sash.CFrame*=cf.Angles(0,a,0)
  local post=beacon('Beacon gallery post',.4,3.5,.4,u*16,3,v*16,'cream','Metal')
 end
 for i=0,7 do
  local angle=(i+.5)*math.pi/4
  for _,h in {2.8,4.4} do
   local rail=beacon('Gallery rail',12.55,.24,.24,math.sin(angle)*14.8,h,math.cos(angle)*14.8,'dark','Metal')
   rail.CFrame*=cf.Angles(0,angle,0)
  end
 end
 for i=0,4 do drum(beacon,'Conical red roof',29-i*3.7,.7,0,12.9+i*.6,0,red) end
 drum(beacon,'Gallery cornice',28,1.1,0,12.2,0,bone)
 drum(beacon,'Lamp pedestal',13,3,0,14,0,red)
 local lantern=drum(beacon,'Lantern glazing',10,6,0,18.5,0,blue)
 lantern.Material=Enum.Material.Glass;lantern.Transparency=.35
 drum(beacon,'Fresnel lamp',3,4,0,18.5,0,bone).Material=Enum.Material.Neon
 drum(beacon,'Lantern cap',13,1,0,22,0,'dark')
 beacon('Finial',.55,5,.55,0,24,0,'gold','Metal')
 require('./constellation')(harbor,group)
 -- A folded canopy marks the landing. The wedge sides leave the hall open to the quay.
 local landing=group('Pier Four Ferry Hall',harbor)
 local fp=builder(landing,101,-534)
 fp('Waiting terrace',83,1,34,0,1.1,0,'cream','Concrete')
 for _,u in {-35,-11,13,35} do
  for _,v in {-12,12} do fp('Steel frame',.85,15,.85,u,8,v,'dark','Metal') end
 end
 for i=-1,1 do
  local u=i*24
  for _,side in {-1,1} do
   local wing=fp('Butterfly canopy',12.9,.6,33,u+side*6,16,0,bone,'Metal')
   wing.CFrame*=cf.Angles(0,0,side*math.rad(27))
  end
  bench(fp,u,6)
 end
 lettering(fp('Ferry sign',39,3,.45,0,12,14,garden,'Metal'),'PIER FOUR  •  HARBOR FERRY')
 -- Two sloops have distinct profiles from the small motor launches.
 for i,x in {-103,309} do
  local m=group('Moored sloop',harbor); local bp=builder(m,x,-595)
  bp('Hull',6.5,2.5,24,0,-1.15,0,i==1 and blue or red,'Metal')
  bp('Deck',6.2,.6,22,0,.3,0,bone,'Wood')
  bp('Mast',.4,24,.4,0,12.5,0,'cream','Metal')
  for _,side in {-1,1} do
   local sail=rb.Instance.new('WedgePart'); sail.Name='Canvas sail'; sail.Size=rb.Vector3.new(.18,side==1 and 20 or 15,side==1 and 12 or 8)
   sail.CFrame=cf.new(x,side==1 and 12 or 9.8,-595+side*(side==1 and 6.2 or 4.2))*cf.Angles(0,side==1 and math.pi or 0,0)
   sail.Color=side==1 and bone or rgb(219,146,87); sail.Material=Enum.Material.Fabric; sail.Anchored=true; sail.Parent=m
  end
 end
 local names={'Lanvale','Juniper','Eastgate','Madison','Waverly','Orchard'}
 local courts={{west,-555,-105,4},{west,-345,105,3},{east,555,-105,5},{south,-120,520,4},{south,345,520,3},{east,555,320,4}}
 for i,c in courts do
  court(c[1],names[i]..' Court',c[2],c[3],c[4],0,({rgb(163,96,70),rgb(169,133,94),rgb(136,81,65)})[(i-1)%3+1])
  local kind=({'Laundry','Barber','Library'})[(i-1)%3+1]
  communityRoom(c[1],names[i]..' '..kind,c[2]-46,c[3]+42,kind)
 end
 local blocks={
  {west,'Lanvale',-345,-105},{west,'Carey',-555,105},{west,'Union',-555,320},
  {west,'Linden',-345,320},{east,'Broadway',345,-105},{market,'Cross Street',345,105},
  {market,'Eastern',555,105},{market,'Orleans',345,320},{south,'Madison',-555,520},
  {south,'Garden',-345,520},{south,'Willow',120,520},{south,'Chestnut',555,520},
 }
 for i,b in blocks do
  local parent,name,x,z=b[1],b[2],b[3],b[4]
  local north=z==-105 and -210 or z==105 and 0 or z==320 and 210 or 430
  local frontage=north+48
  local block=builder(group(name..' retail walk',parent),x,frontage)
  block('Sidewalk extension',155,.55,8,0,.46,-20,bone,'Concrete')
  block('Rear service court',150,.45,30,0,.1,37,'stone','Cobblestone')
  pavilion(name..' Coffee',x-35,frontage,0,garden,parent,'cafe')
  local neighbor=({'Print Exchange','Music Hall','Photo Lab','Book Arcade','Studio Exchange','Design Hall'})[(i-1)%6+1]
  local specialty=({Linden='Exchange Streetwear',Eastern='Eastern Outfitters',Union='Union Athletics'})[name]
  pavilion(specialty or name..' '..neighbor,x+34,frontage,0,i%2==0 and blue or bronze,parent,'gallery')
  if i%3==0 then landmark(name..' Foundry',x+34,z+37,0,'mill',2,parent)
  elseif i%3==1 then apartments(parent,name..' Flats',x+34,z+38,0,2,rgb(150,99,79))
  else pavilion(name..' Market',x+38,z+36,0,bronze,parent,'market') end
 end
 -- Give the freight yards a second frontage along Orleans Street.
 pavilion('Foundry Canteen',-107,378,180,garden,mill,'cafe')
 pavilion('Seafarers Hall',112,378,180,blue,mill,'gallery')
 local downtown=group('Downtown • Charles Center',city)
 local westside=group('Westside • Franklin Homes',city)
 local eastside=group('Eastside • Harbor View Homes',city)
 local function workStop(parent,name,key,x,z)
  local p=builder(group(name,parent),x,z)
  p('Station landing',13,.55,10,0,.3,0,'stone','Concrete')
  p('Station post',.58,6,.58,-3.5,3.2,0,'dark','Metal')
  p('Station post',.58,6,.58,3.5,3.2,0,'dark','Metal')
  local kiosk=p('Work station',8,3,.7,0,4.8,0,garden,'Metal')
  lettering(kiosk,name:upper()); action(kiosk,'WorkStop',name); kiosk:SetAttribute('Station',key)
 end
 local function estate(parent,name,x,z,floors,tint)
  local grounds=builder(group(name..' grounds',parent),x,z)
  grounds('Residents courtyard',175,.5,144,0,.1,0,garden,'Grass')
  grounds('Public walk',16,.5,161,0,.45,0,'stone','Concrete')
  grounds('Tower entrances',165,.52,12,0,.48,0,bone,'Concrete')
  apartments(parent,name..' Tower',x-44,z-40,180,floors,tint)
  apartments(parent,name..' Walkups',x+41,z+39,0,3,tint)
  for _,side in {-1,1} do
   tree(grounds,side*68,3,floors); bench(grounds,side*33,6)
  end
  
 end
 estate(westside,'Franklin Homes',-555,718,10,rgb(136,79,62))
 estate(westside,'Edmondson Courts',-345,934,8,rgb(154,115,84))
 estate(eastside,'Harbor View',555,718,12,rgb(151,94,69))
 estate(eastside,'Ashland Courts',555,934,9,rgb(131,97,77))
 local towers={
  {'Metropolitan Exchange',-345,718,'deco',15},{'Charles Center',-120,718,'glass',22},
  {'Pratt Financial',120,718,'deco',18},{'Baltimore Mutual',345,718,'glass',13},
  {'The Lexington',-120,934,'deco',14},{'Commerce Plaza',120,934,'glass',17},
  {'Municipal Offices',345,934,'deco',11},
 }
 local downtownBlock=require('./downtown')
 for i,t in towers do downtownBlock(t,i,downtown,group,builder,landmark,lettering,glass,action,tableSet,lounge,glow) end
 square(westside,'Franklin Square',-555,934,'stone')
 communityRoom(westside,'Franklin Branch Library',-580,954,'Library')
 pavilion('Penn Avenue Market',-530,896,180,bronze,westside,'market')
 local entry=builder(group('Downtown gateway',downtown),0,655)
 for _,side in {-1,1} do
  entry('Granite marker',3,13,3,side*32,6.7,0,'cream','Concrete')
  local stone=entry('Carved gateway',19,4,1.2,side*36,6.5,-1.85,bone,'Limestone'); label(stone,'Charles Center',rgb(59,76,73))
 end
 workStop(downtown,'Charles Center lobby service','Lobby',-120,674)
 workStop(downtown,'Commerce recycling desk','Recycling',120,883)
 workStop(mill,'Freight dispatch','Freight',76,327)
 workStop(harbor,'Pier Four receiving','Pier',101,-512)
 workStop(westside,'Franklin parcel room','Parcel',-548,732)
 workStop(eastside,'Harbor View parcel room','ParcelEast',558,730)
 workStop(mill,'Backroom dispatch','NightDesk',149,324)
 local exchange=builder(group('Eastside night exchange',eastside),585.5,955)
 local locker=exchange('Parcel cabinet',3.5,4.4,.88,0,4.6,0,rgb(67,78,75),'Metal')
 for _,y in {3.5,5.4} do
  local slot=exchange('Parcel hatch',2.85,.34,.14,0,y,-.49,'dark','Metal');slot.CanQuery=false;slot.CanCollide=false
 end
 lettering(locker,'PARCELS')
 action(locker,'WorkStop','Complete exchange');locker:SetAttribute('Station','NightDrop')
 require('./citylife')(city,group,builder,lettering,glass,action,lounge,glow)
 for i,c in {{-555,-105,'Lanvale Courts'},{-555,718,'Franklin Homes'},{555,718,'Harbor View Homes'},{-345,934,'Edmondson Courts'},{-120,520,'Madison Gardens'},{555,-105,'Eastgate Terrace'},{345,520,'Waverly Court'}} do
  local q=builder(group(c[3]..' entrance',city),c[1],c[2])
  q('Brick monument base',29,3,3,28,1.7,-68,rgb(128,77,60),'Brick')
  for _,u in {13,43} do q('Stone gate pier',3.2,6.2,3.8,u,3.2,-68,bone,'Limestone'); q('Gate pier cap',4,.65,4.7,u,6.45,-68,bone,'Concrete') end
  local stone=q('Engraved limestone',27,3.6,1.4,28,4.2,-68.3,bone,'Limestone')
  label(stone,c[3],rgb(62,73,68))
  local engraving=stone:FindFirstChildOfClass('SurfaceGui'):FindFirstChildOfClass('TextLabel')
  engraving.FontFace=rb.Font.new('rbxasset://fonts/families/Guru.json',Enum.FontWeight.SemiBold)
  q('Bronze edge',27,.22,.45,28,2.65,-69.1,bronze,'Metal')
  for _,u in {9,47} do local bush=q('Clipped shrub',6,3.5,4.5,u,1.9,-68,garden,'Grass'); bush.Shape=Enum.PartType.Ball end
 end
 workStop(westside,'Poster pickup','Posters',-516,940)
 workStop(market,'Broadway poster board','Board',325,146)

end
