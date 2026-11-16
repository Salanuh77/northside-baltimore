local rb=require('@lune/roblox')
local fs=require('@lune/fs')
local serde=require('@lune/serde')
local catalog=require('./retail-brands')
local atlas='rbxassetid://'..assert(serde.decode('json',fs.readFile('art/assets.json'))['retail-aisles'])
local packages=serde.decode('json',fs.readFile('art/retail-packages.json'))
local E,CF,V,C,U=rb.Enum,rb.CFrame,rb.Vector3.new,rb.Color3,rb.UDim2
local cream,iron,oak=C.fromRGB(243,229,197),C.fromRGB(54,58,57),C.fromRGB(156,119,83)
local function model(parent,name)
 local m=rb.Instance.new('Model');m.Name=name;m.Parent=parent;return m
end
local function piece(parent,name,frame,x,y,z,w,h,d,color,material)
 local p=rb.Instance.new('Part');p.Name=name;p.Size=V(w,h,d);p.CFrame=frame*CF.new(x,y,z)
 p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false
 p.Color=color;p.Material=material or E.Material.Metal;p.TopSurface=E.SurfaceType.Smooth;p.BottomSurface=E.SurfaceType.Smooth
 p.Parent=parent;return p
end
local function surface(p,w,h,distance,face)
 local g=rb.Instance.new('SurfaceGui');g.Name='Printed face';g.Face=face or E.NormalId.Front
 g.SizingMode=E.SurfaceGuiSizingMode.FixedSize;g.CanvasSize=rb.Vector2.new(w,h)
 g.LightInfluence=.8;g.MaxDistance=distance;g.Parent=p;return g
end
local function block(g,x,y,w,h,color)
 local f=rb.Instance.new('Frame');f.Position=U.fromScale(x,y);f.Size=U.fromScale(w,h)
 f.BackgroundColor3=color;f.BorderSizePixel=0;f.Parent=g;return f
end
local function words(g,txt,x,y,w,h,color,font)
 local t=rb.Instance.new('TextLabel');t.Position=U.fromScale(x,y);t.Size=U.fromScale(w,h)
 t.BackgroundTransparency=1;t.Text=txt;t.TextColor3=color;t.FontFace=rb.Font.new(font=='serif' and 'rbxasset://fonts/families/Garamond.json' or 'rbxasset://fonts/families/GothamSSm.json',font=='medium' and E.FontWeight.Medium or E.FontWeight.Bold)
 local canvas=g:IsA('SurfaceGui') and g.CanvasSize or rb.Vector2.new(115,110)
 t.TextScaled=false;t.TextSize=math.clamp(math.floor(math.min(canvas.X*w/(math.max(1,#txt)*.60),canvas.Y*h*.88)),9,96)
 t.TextWrapped=false;t.Parent=g;return t
end
local function branding(p,b)
 local bg,accent=C.fromHex(b[4]),C.fromHex(b[5])
 local g=surface(p,750,150,185)
 local badge=block(g,.027,.13,.155,.73,accent)
 if b[1]=='Goose & Griddle' then
  for feather=0,2 do
   local wing=block(badge,.15+feather*.15,.61-feather*.17,.41,.12,bg)
   wing.Rotation=-24
  end
 elseif b[1]=='Crown Roost' then
  for point=0,2 do
   local tip=block(badge,.20+point*.22,.31+math.abs(point-1)*.06,.19,.35,bg)
   tip.Rotation=(point-1)*18
  end
  block(badge,.20,.63,.62,.10,bg)
 elseif b[1]=='Eight Till Late' then
  words(badge,'8',0,-.01,1,.96,bg)
 else
  words(badge,b[1]:sub(1,1),0,0,1,.96,bg,'serif')
 end
 words(g,string.upper(b[1]),.208,.13,.765,.45,cream)
 block(g,.21,.65,.73,.025,accent)
 words(g,b[6],.21,.70,.73,.18,accent,'medium')
end
local function printed(p,txt,accent,face)
 local g=surface(p,460,62,72,face)
 words(g,txt,.025,.12,.95,.76,accent,'bold')
end
local function printRow(g,slot,line)
 local i=line-1
 local img=rb.Instance.new('ImageLabel');img.Name=catalog.names[line];img:SetAttribute('StockLine',line)
 img.Position=U.fromScale(.025,.018+slot*.326);img.Size=U.fromScale(.95,.303)
 img.BackgroundTransparency=1;img.Image=atlas;img.ImageRectOffset=rb.Vector2.new(i%4*256,math.floor(i/4)*128)
 img.ImageRectSize=rb.Vector2.new(256,128);img.Parent=g
end
local widePack={shoe=true,ball=true,record=true,poster=true,fold=true,bread=true,fruit=true}
local shortPack={shoe=true,fold=true,bread=true,wrap=true,fruit=true}
local roundPack={can=true,bottle=true,jar=true}
local function stockTier(rack,frame,width,tier,line)
 local pack=packages[line]
 local count=widePack[pack.shape] and 4 or 5
 local spacing=(width-.3)*.91/count
 local floor=.27+(2-tier)*1.84
 for n=0,count-1 do
  local w=spacing*.85
  local h=shortPack[pack.shape] and .53 or 1.04
  local depth=math.min(1.05,w)
  local x=((count-1)*.5-n)*spacing
  local tint=C.fromHex(pack.colors[(math.floor(n/2)+line-1)%3+1])
  local item=piece(rack,'Shelf merchandise',frame,x,floor+h/2,-1.42+depth/2,w,h,depth,tint,E.Material.SmoothPlastic)
  if roundPack[pack.shape] then
   item.Size=V(h,depth,w);item.Shape=E.PartType.Cylinder;item.CFrame*=CF.Angles(0,0,math.pi/2)
  elseif pack.shape=='ball' then
   item.Shape=E.PartType.Ball
  end
 end
end
local function bay(stock,frame,width,profile,offset)
 local rack=model(stock,'Shelf bay')
 local enamel=C.fromHex(profile[4]);local accent=C.fromHex(profile[5])
 local lines=catalog.lines[profile[3]];local height=6.1
 piece(rack,'Enamel back',frame,0,height/2,0,width,height,.23,enamel)
 -- The case is solid from the floor up; shelf lips and printed stock share one collision volume.
 local carcass=piece(rack,'Shelf footprint',frame,0,height/2,-.78,width,height,1.80,iron)
 carcass.Transparency=1;carcass.CanCollide=true;carcass.CanQuery=true
 for j=0,3 do
  local y=.20+j*1.84
  piece(rack,'Shelf deck',frame,0,y,-.81,width,.14,1.82,oak)
  piece(rack,'Price rail',frame,0,y+.04,-1.71,width,.19,.12,cream)
  for n=1,3 do piece(rack,'Shelf ticket',frame,(n-2)*width*.3,y+.04,-1.785,.45,.13,.015,accent) end
 end
 for _,s in {-1,1} do piece(rack,'Folded upright',frame,s*(width/2-.12),height/2,-.65,.19,height,1.54,iron) end
 local stockFront=piece(rack,'Product faces',frame,0,2.97,-1.46,width-.3,5.68,.045,iron)
 stockFront.Transparency=1
 local artwork=surface(stockFront,340,300,77)
 for tier=0,2 do
  local line=lines[(offset+tier)%#lines+1]
  stockTier(rack,frame,width,tier,line)
  printRow(artwork,tier,line)
 end
 local cap=piece(rack,'Department rail',frame,0,6.38,-.8,width,.75,1.82,enamel)
 printed(cap,string.upper(catalog.names[lines[(offset+1)%#lines+1]]),cream)
end
local function board(stock,frame,x,y,z,w,title,items,b)
 local face=piece(stock,'Service menu',frame,x,y,z,w,3.55,.2,C.fromHex(b[4]))
 local g=surface(face,490,160,65)
 block(g,.025,.10,.022,.80,C.fromHex(b[5]))
 words(g,title,.08,.10,.85,.39,cream)
 words(g,items,.07,.59,.88,.22,C.fromHex(b[5]),'medium')
end
local function solid(p)
 p.CanCollide=true;p.CanQuery=true;return p
end
local function gasService(stock,frame,b)
 local base=C.fromHex(b[4])
 solid(piece(stock,'Hot food counter',frame,10,1.55,13.4,8.2,3.1,3.6,base))
 piece(stock,'Deli counter slab',frame,10,3.19,13.4,8.5,.18,3.8,cream)
 piece(stock,'Warming tray',frame,10,3.45,13.6,7,.34,2.35,iron)
 local glass=piece(stock,'Hot case glass',frame,10,4.25,12.42,7.3,1.7,.1,cream,E.Material.Glass);glass.Transparency=.72
 for _,s in {-1,1} do piece(stock,'Case post',frame,10+s*3.55,4.4,13.5,.16,1.8,2.3,iron) end
 piece(stock,'Case canopy',frame,10,5.35,13.5,7.45,.21,2.5,base)
 local choices=b[1]=='Crown Roost' and {'HOT CHICKEN','BREAST  /  WINGS  /  WEDGES'} or b[1]=='Eight Till Late' and {'ROLLER GRILL','DOGS  /  BITES  /  MELTS'} or {'HOAGIE COUNTER','CLASSIC  /  TURKEY  /  VEGGIE'}
 for j=-2,2 do for k=0,1 do
  local meal=piece(stock,'Deli portion',frame,10+j*1.18,3.82,13.16+k*.85,.9,.46,.67,k==0 and oak or C.fromRGB(181,110,51),E.Material.SmoothPlastic)
  meal.Shape=E.PartType.Ball
 end end
 board(stock,frame,10,8.8,16.25,8.7,choices[1],choices[2],b)
 local fascia=piece(stock,'Pump canopy emblem',frame,0,13.15,-41.65,15.4,3.05,.4,base)
 branding(fascia,b)
end
local function fuelShelves(site,stock,frame,b)
 -- These print panels fit the existing gondolas and cooler bottles precisely.
 for _,part in site:GetChildren() do
  if part.Name=='Package band' or part.Name=='Pantry label' then
   part:Destroy()
  elseif part.Name=='Chilled drink' then
   local rot=part.CFrame
   part.Size=V(1.0,.72,.72);part.Shape=E.PartType.Cylinder;part.CFrame=rot*CF.Angles(0,0,math.pi/2)
   local sleeve=piece(stock,'Printed drink sleeve',part.CFrame,0,0,0,.47,.735,.735,cream)
   sleeve.Shape=E.PartType.Cylinder
  end
 end
 local lines=catalog.lines.fuel
 for _,side in {-1,1} do
  for _,face in {-1,1} do
   for tier=1,3 do
    local y=1.96+(tier-1)*1.65
    local localFrame=frame*CF.new(side*11+face*1.4,y-.54,0)*CF.Angles(0,-face*math.pi/2,0)
    local p=piece(stock,'Branded snack facing',localFrame,0,0,0,7.13,1.51,.035,iron)
    p.Transparency=1
    local g=surface(p,340,122,68)
    local row=lines[((side+1)*3+(face+1)*2+tier-1)%#lines+1]
    printRow(g,0,row)
    local image=g:FindFirstChildOfClass('ImageLabel');image.Size=U.fromScale(1,1);image.Position=U.fromScale(0,0)
   end
  end
 end
 for tier=1,2 do
  for column=0,1 do
   local front=piece(stock,'Pantry shelf facing',frame,(column-.5)*7,6.9+(tier-1)*2-.43,16.17,6.9,1.7,.05,iron)
   front.Transparency=1;local g=surface(front,280,110,67)
   printRow(g,0,({32,10,11,6})[(tier-1)*2+column+1])
   local img=g:FindFirstChildOfClass('ImageLabel');img.Size=U.fromScale(1,1);img.Position=U.fromScale(0,0)
  end
 end
 -- Keep the center of the till clear. The candy tray sits at the far end of the actual checkout slab.
 local till=site['Counter edge']
 local tray=piece(stock,'Impulse candy tray',till.CFrame,-2.9,.48,-.55,2.4,.78,1.2,C.fromHex(b[4]))
 local g=surface(tray,250,82,38);printRow(g,0,2)
 local img=g:FindFirstChildOfClass('ImageLabel');img.Size=U.fromScale(1,1);img.Position=U.fromScale(0,0)
 for slot=-2,2 do piece(stock,'Wrapped counter candy',till.CFrame,-2.9+slot*.4,.91,-.55,.32,.20,.85,slot%2==0 and C.fromHex(b[5]) or cream) end
 board(stock,frame,-10.5,7.6,17.15,8.2,'COFFEE BAR','DRIP  /  DARK  /  DECAF',b)
end

local function extraCounter(stock,frame,b,width,depth)
 local kind=b[3]
 if kind=='arcade' then
  for i=0,2 do
   local x=width/2-7-i*5
   solid(piece(stock,'Coin cabinet',frame,x,2.8,15,3.9,5.6,4,iron))
   local bezel=piece(stock,'Arcade screen',frame,x,4,12.95,3.3,2.5,.16,C.fromHex(b[4]))
   printed(bezel,({'ORBIT','DRIFT','RUSH'})[i+1],C.fromHex(b[5]))
   piece(stock,'Control panel',frame,x,2.2,12.65,3.8,.3,1.2,C.fromHex(b[4]))
   piece(stock,'Joystick',frame,x-.7,2.65,12.63,.3,.62,.3,C.fromHex(b[5]))
  end
 elseif kind=='deli' or kind=='bakery' or kind=='coffee' or kind=='cinema' or kind=='club' then
  local title=({deli='DELI BOARD',bakery='FROM THE OVEN',coffee='ON THE BAR',cinema='AT THE COUNTER',club='ON THE HOUSE'})[kind]
  local menu=({deli='HOT STACK  /  BREAD & SPREAD',bakery='CRULLER  /  GLAZE  /  TWIST',coffee='ESPRESSO  /  FILTER  /  COLD BREW',cinema='POPCORN  /  SODA  /  CANDY',club='LIME FIZZ  /  CHERRY COLA'})[kind]
  board(stock,frame,0,8.95,depth/2-.65,10,title,menu,b)
 end
end
local function vinylBin(stock,frame,x,section,title,tint)
 piece(stock,'Bin floor',frame,x,3.27,.05,2.75,.26,3.25,oak,E.Material.Wood)
 for _,s in {-1,1} do
  piece(stock,'Bin side',frame,x+s*1.34,3.78,.05,.13,1.0,3.25,oak,E.Material.Wood)
 end
 for i=0,5 do
  local jacket=piece(stock,'LP sleeve',frame,x,4.55+i*.044,-.96+i*.42,2.38,2.38,.11,
   i==0 and tint or i%2==0 and iron or cream,E.Material.SmoothPlastic)
  jacket.CFrame*=CF.Angles(-.16,0,0)
  if i==0 then
   local art=surface(jacket,180,180,65);art.Name='Album cover'
   local circle=block(art,.23,.1,.58,.58,iron)
   local round=rb.Instance.new('UICorner');round.CornerRadius=rb.UDim.new(.5,0);round.Parent=circle
   local dot=block(art,.46,.33,.12,.12,cream)
   local roundDot=round:Clone();roundDot.Parent=dot
   words(art,title,.06,.74,.88,.17,cream)
  end
 end
 local lip=piece(stock,'Bin index',frame,x,3.64,-1.63,2.76,.58,.14,iron)
 printed(lip,section,cream)
end
local function retailFeature(site,stock,frame,width,depth,b)
 local kind=b[3];local color=C.fromHex(b[4]);local accent=C.fromHex(b[5])
 -- Replace the original three generic sculptures in converted art halls with the business's wares.
 if site:FindFirstChild('Gallery plinth') and kind~='art' then
  for _,child in site:GetChildren() do
   if child.Name=='Sculpture' or child.Name=='Gallery plinth' then child:Destroy() end
  end
  for _,side in {-1,1} do
   local fx=frame*CF.new(side*18,0,4)
   solid(piece(stock,'Browse table',fx,0,1.55,0,10,3.1,4.2,oak,E.Material.Wood))
   if kind=='records' then
    vinylBin(stock,fx,-3.1,'SOUL','NIGHT BUS',C.fromRGB(161,69,56))
    if side<0 then
     vinylBin(stock,fx,0,'JAZZ','SECOND LINE',C.fromRGB(64,113,123))
     vinylBin(stock,fx,3.1,'GO-GO','BACKBEAT',C.fromRGB(142,107,44))
    end
    if side==1 then
     local deck=piece(stock,'Listening deck',fx,1.3,3.44,-.2,4.3,.55,3.3,iron)
     local disc=piece(stock,'Turntable platter',deck.CFrame,-.5,.4,0,.13,2.5,2.5,iron)
     disc.Color=C.fromRGB(25,28,29);disc.Shape=E.PartType.Cylinder;disc.CFrame*=CF.Angles(0,0,math.pi/2)
     local label=piece(stock,'Center label',deck.CFrame,-.5,.48,0,.06,.81,.81,accent)
     label.Shape=E.PartType.Cylinder;label.CFrame*=CF.Angles(0,0,math.pi/2)
     piece(stock,'Tonearm',deck.CFrame,1.2,.55,0,.12,.12,1.65,cream)
    end
   elseif kind=='books' then
    for stack=0,3 do for level=0,2 do
     local book=piece(stock,'Hardcover stack',fx,(stack-1.5)*2.11,3.21+level*.28,0,1.72,.23,2.4,(stack+level)%2==0 and color or accent)
     book.CFrame*=CF.Angles(0,(level-1)*.055,0)
    end end
   else
    local monitor=piece(stock,'Customer kiosk',fx,0,4.72,.55,4.2,2.9,.44,iron)
    printed(monitor,kind=='camera' and 'PHOTO PICKUP' or 'PRINT DESK',cream)
    piece(stock,'Control pad',fx,0,3.27,-1,3,.17,1,accent)
    for j=1,3 do piece(stock,'Paper cassette',fx,3.3,3.22+j*.33,0,2.3,.22,2.8,cream) end
   end
  end
 end
 if kind=='produce' or kind=='grocery' then
  for _,crate in site:GetChildren() do
   if crate.Name=='Produce crate' then
    for j=-1,1 do for k=0,1 do
     local fruit=piece(stock,'Fresh produce',crate.CFrame,j*.84,crate.Size.Y/2+.31,k*.90-.45,.82,.78,.82,
      (j+k)%2==0 and C.fromRGB(174,77,45) or C.fromRGB(148,155,58),E.Material.SmoothPlastic)
     fruit.Shape=E.PartType.Ball
    end end
   end
  end
 end
 if kind=='deli' or kind=='coffee' or kind=='bakery' then
  local bar=site:FindFirstChild('Serving bar') or site:FindFirstChild('Sales counter')
  if bar then
   local trayFrame=bar.CFrame*CF.new(-bar.Size.X*.38,bar.Size.Y/2,0)
   piece(stock,'Bakery tray',trayFrame,0,.10,0,3.6,.2,2.25,cream)
   for j=-1,1 do for k=0,1 do
    local roll=piece(stock,'Fresh pastry',trayFrame,j*.96,.40,(k-.5)*.92,.88,.43,.73,k==0 and oak or accent,E.Material.SmoothPlastic)
    roll.Shape=E.PartType.Ball
   end end
  end
 end
 if kind=='barber' or kind=='laundry' then
  local corner=frame*CF.new(-width/2+5.8,0,kind=='barber' and .3 or -8.8)
  solid(piece(stock,'Service hamper',corner,0,1.7,0,2.8,3.4,2.8,oak,E.Material.Wood))
  for j=0,3 do piece(stock,'Folded cotton towels',corner,0,3.56+j*.27,0,2.7,.24,2.28,j%2==0 and cream or accent,E.Material.Fabric) end
 elseif kind=='bank' or kind=='clinic' then
  local wall=frame*CF.new(width*.27,0,depth/2-1.4)
  board(stock,wall,0,7.4,0,12,kind=='clinic' and 'PATIENT CHECK-IN' or 'MEMBER SERVICES',kind=='clinic' and 'APPOINTMENTS  /  WALK-INS' or 'CASH DESK  /  DEPOSITS',b)
 end
end

local function findFloor(site)
 for _,n in {'Shop floor','Hall floor','Terrazzo floor','Tile floor','Floor'} do
  local p=site:FindFirstChild(n);if p and p:IsA('BasePart') then return p end
 end
end
local function apparelWall(stock,frame,b)
 local display=model(stock,'Apparel wall')
 local ink=C.fromHex(b[4])
 piece(display,'Walnut slat panel',frame,0,7.25,0,22,9,.38,oak,E.Material.WoodPlanks)
 for i=0,8 do
  piece(display,'Slat channel',frame,0,3.42+i*.89,-.23,21.9,.065,.11,iron)
 end
 local header=piece(display,'Collection header',frame,0,10.8,-.32,21.9,1.6,.18,ink)
 printed(header,b[3]=='sneakers' and 'WARMUPS  /  COURT COLLECTION' or 'LAST SEASON  /  WORKWEAR',cream)
 local fabrics={C.fromRGB(87,111,126),C.fromRGB(167,112,84),C.fromRGB(74,85,71),C.fromRGB(151,144,117)}
 for i=1,4 do
  local x=(i-2.5)*5.05
  local tone=fabrics[i]
  piece(display,'Wall peg',frame,x,9.3,-.65,.22,.22,1.1,iron)
  piece(display,'Hanger hook',frame,x,8.94,-1.10,.12,.55,.12,iron)
  piece(display,'Work jacket',frame,x,6.67,-1.09,2.45,3.45,.42,tone,E.Material.Fabric)
  for _,side in {-1,1} do
   local sleeve=piece(display,'Jacket sleeve',frame,x+side*1.37,6.86,-1.09,.73,2.93,.42,tone,E.Material.Fabric)
   sleeve.CFrame*=CF.Angles(0,0,side*.25)
   local collar=piece(display,'Folded collar',frame,x+side*.31,8.12,-1.35,.39,.64,.08,cream,E.Material.Fabric)
   collar.CFrame*=CF.Angles(0,0,-side*.45)
  end
  piece(display,'Jacket seam',frame,x,6.53,-1.33,.06,2.92,.06,iron)
  piece(display,'Patch pocket',frame,x+.62,7.13,-1.34,.57,.53,.08,tone:Lerp(cream,.23),E.Material.Fabric)
 end
end
local function fitLargeSalesFloor(site,stock,frame,width,depth,b)
 -- Finish the rear corners and side runs; customers can still cross the whole center aisle.
 for _,side in {-1,1} do
  local rear=frame*CF.new(side*width*.345,0,depth/2-.87)
  bay(stock,rear,math.min(13,width*.19),b,side<0 and 4 or 7)
  local middle=frame*CF.new(side*(width/2-1),0,0)*CF.Angles(0,side*math.pi/2,0)
  bay(stock,middle,math.min(9.6,depth*.19),b,side<0 and 1 or 5)
  local lamp=piece(stock,'Merchandise downlight',frame,side*width*.28,11.65,depth*.29,1.55,.22,.88,cream,E.Material.Neon)
  local light=rb.Instance.new('PointLight');light.Color=C.fromRGB(255,232,196)
  light.Range=23;light.Brightness=.76;light.Shadows=false;light.Parent=lamp
 end
 if site:FindFirstChild('Window dress form') then
  apparelWall(stock,frame*CF.new(0,0,depth/2-.70),b)
 end
end
local function fit(site,b)
 local floor=assert(findFloor(site),site.Name..' has no sales floor')
 local width,depth=floor.Size.X,floor.Size.Z
 local frame=floor.CFrame*CF.new(0,floor.Size.Y/2,0)
 local stock=model(site,'Retail merchandising')
 site:SetAttribute('RetailBrand',b[1]);site:SetAttribute('RetailReference',b[2]);site:SetAttribute('RetailDepartment',b[3])
 local fuel=b[3]=='fuel'
 local old=site:FindFirstChild('Enamel station wordmark') or site:FindFirstChild('Painted lettering')
 local plate
 if old then
  -- Reuse the original mount, including the offset at rotated fuel stations.
  plate=old:Clone();plate:ClearAllChildren();plate.Name='Brand face';plate.Transparency=0;plate.Color=C.fromHex(b[4])
  plate.Size=V(math.min(plate.Size.X,24),plate.Size.Y,plate.Size.Z);plate.Parent=stock
  old:Destroy()
 else
  local y=floor.Name=='Tile floor' and 11.4 or floor.Name=='Hall floor' and 12.4 or 12.8
  plate=piece(stock,'Brand face',frame,-width*.255,y,-depth/2-.72,math.min(18,width*.45),3.05,.42,C.fromHex(b[4]))
 end
 branding(plate,b)
 for _,n in {'Hanging shop blade','Enamel shop blade','Shop window lettering','Community door lettering'} do
  local blade=site:FindFirstChild(n)
  if blade then for _,t in blade:GetDescendants() do if t:IsA('TextLabel') then t.Text=b[1] end end end
 end
 if fuel then
  -- Local shelf coordinates use the shop floor center, three studs behind the station origin.
  local origin=frame*CF.new(0,0,-3)
  for _,s in {-1,1} do
   bay(stock,origin*CF.new(s*19,0,-5.1)*CF.Angles(0,s*math.pi/2,0),9.6,b,s<0 and 0 or 3)
  end
  -- End displays face the customer with their footprint attached to each existing gondola.
  for _,s in {-1,1} do bay(stock,origin*CF.new(s*11,0,-3.82),3.5,b,s<0 and 6 or 9) end
  gasService(stock,origin,b)
  fuelShelves(site,stock,origin,b)
 else
  local hall=floor.Name=='Tile floor'
  local rackWidth=hall and 6 or math.min(9.6,depth*.23)
  local distance=hall and 5.6 or depth*.25
  for _,s in {-1,1} do
   for j=0,1 do
    local z=(j==0 and -1 or 1)*distance
    bay(stock,frame*CF.new(s*(width/2-1),0,z)*CF.Angles(0,s*math.pi/2,0),rackWidth,b,(s<0 and 0 or 2)+j*3)
   end
  end
  extraCounter(stock,frame,b,width,depth)
  retailFeature(site,stock,frame,width,depth,b)
  if floor.Name=='Terrazzo floor' or floor.Name=='Hall floor' then
   fitLargeSalesFloor(site,stock,frame,width,depth,b)
  end
 end
end
return function(city)
 for _,site in city:GetDescendants() do
  if site:IsA('Model') and findFloor(site) then
   local brand=catalog.forSite(site.Name)
   if brand then fit(site,brand) end
  end
 end
end
