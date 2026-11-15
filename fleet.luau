local rb=require('@lune/roblox')
local rgb,cf=rb.Color3.fromRGB,rb.CFrame
return function(part,group,city)
 local fleet=group('Motor pool',city)
 local parking={{295,199,90},{9,43,0},{-229,111,0},{-439,-32,0},{461,90,0},{-649,320,0},{649,518,180},{-105,-449,90},{150,419,-90},{-461,505,180},{344,-221,-90},{552,199,-90},{-439,695,0},{229,895,180},{461,747,0},{-103,819,-90},{10,694,0},{-10,768,180},{10,896,0},{-739,-105,180}}
 local V=rb.Vector3.new
 local fs=require('@lune/fs')
 local bounds=require('@lune/serde').decode('json',fs.readFile('art/fleet-bounds.json'))
 local library={}
 for _,root in rb.deserializeModel(fs.readFile('art/motorworks.rbxm')) do
  for _,mesh in root:GetDescendants() do if mesh:IsA('MeshPart') then library[mesh.Name]=mesh end end
 end
 local roadLibrary={}
 local materials=require('@lune/serde').decode('json',fs.readFile('art/road-cars.json'))
 for _,root in rb.deserializeModel(fs.readFile('art/road-cars.rbxm')) do
  for _,mesh in root:GetDescendants() do
   if mesh:IsA('MeshPart') then
    local spec=assert(materials[mesh.Name],'Unknown imported car part '..mesh.Name)
    roadLibrary[spec.car]=roadLibrary[spec.car] or {}; table.insert(roadLibrary[spec.car],{mesh=mesh,spec=spec})
   end
  end
 end
 local specs={
  Sport={-8.1,7.85,6.17,3.35,3.91},Saloon={-7.9,7.7,6.65,3.65,3.76},Estate={-7.85,7.49,6.96,3.8,3.8},
  Utility={-8,7.65,7.65,4.12,3.91},Muscle={-8.4,7.78,6.37,3.62,3.86},Van={-7.95,7.69,8.05,4,3.85}}
 local lineup={'Sport','Cab','Muscle','Patrol','Estate','Van','Bus','Sport','Utility','Cab','Muscle','Medic','Saloon','Estate','Patrol','Van','Sport','Cab','Bus','Utility'}
 local paints={rgb(160,35,48),rgb(59,93,135),rgb(68,110,86),rgb(196,202,199),rgb(91,146,172),rgb(40,74,87)}
 local trim=rgb(33,39,43); local alloy=rgb(186,195,199)
 for i,spot in parking do
  local role=lineup[i]
  local style=({Bus='Van',Medic='Van',Cab='Saloon',Patrol='Utility'})[role] or role
  local nose,tail,roof,belt,width=table.unpack(specs[style])
  local scale=role=='Bus' and V(1.18,1.34,1.66) or V(1,1,1)
  local paint=({Bus=rgb(227,157,37),Cab=rgb(225,165,51),Patrol=rgb(48,57,68),Medic=rgb(229,233,228)})[role] or paints[(i-1)%#paints+1]
  local model=group(({Bus='School Bus',Cab='Harbor Cab',Patrol='Patrol Interceptor',Medic='EMS Transport',Sport='Harbor GT',Muscle='Foundry V8',Estate='Touring Wagon',Van='Panel Van',Utility='Crossover',Saloon='City Sedan'})[role],fleet)
  model:SetAttribute('FleetNumber',i); model:SetAttribute('BodyStyle',role); model.ModelStreamingMode=rb.Enum.ModelStreamingMode.Atomic
  local origin=cf.new(spot[1],0,spot[2])*cf.Angles(0,math.rad(spot[3]),0)
  local function scaled(x,y,z) return V(x*scale.X,.45+(y-.45)*scale.Y,z*scale.Z) end
  local function box(n,w,h,d,x,y,z,c,mat)
   local p=part(n,{w*scale.X,h*scale.Y,d*scale.Z},{0,0,0},c,mat or 'Metal',model)
   p.CFrame=origin*cf.new(scaled(x,y,z)); return p
  end
  local function rod(n,a,b,width,depth,c)
   a=scaled(a.X,a.Y,a.Z); b=scaled(b.X,b.Y,b.Z)
   local p=part(n,{width,depth,(a-b).Magnitude},{0,0,0},c,'Metal',model)
   p.CFrame=origin*cf.lookAt((a+b)/2,b); return p
  end
  local function fitCabin(seat)
   local glassTop=-math.huge
   for _,panel in model:GetChildren() do
    if panel.Name=='Glass' then
     local center=origin:PointToObjectSpace(panel.CFrame.Position)
     glassTop=math.max(glassTop,center.Y+panel.Size.Y/2)
    end
   end
   assert(glassTop>-math.huge,'Cabin glass missing on '..model.Name)
   local here=origin:PointToObjectSpace(seat.CFrame.Position)
   seat:SetAttribute('CabinCeiling',glassTop-here.Y-.13)
   seat:SetAttribute('DoorDistance',(width+.95)*scale.X)
  end
  local template=({Sport='GT',Saloon='Sedan',Utility='SUV'})[style]
  if template then
   for _,entry in roadLibrary[template] do
    local spec=entry.spec; local p=entry.mesh:Clone(); p:ClearAllChildren()
    local finish=spec.finish
    p.Name=finish=='Trim' and 'Pillars' or finish
    p.CFrame=origin*cf.new(V(table.unpack(spec.center)))*cf.Angles(0,math.pi,0)
    p.Anchored=true; p.CanCollide=false; p.DoubleSided=true
    p.Color=finish=='Paint' and paint or rgb(table.unpack(spec.color))
    p.Material=finish=='Glass' and rb.Enum.Material.Glass or finish=='Rubber' and rb.Enum.Material.Rubber or finish=='Lamp' and rb.Enum.Material.Neon or finish=='Red' and rb.Enum.Material.Glass or rb.Enum.Material.SmoothPlastic
    p.Transparency=finish=='Glass' and .39 or 0
    p.Reflectance=finish=='Paint' and .12 or finish=='Alloy' and .24 or finish=='Glass' and .12 or 0; p.Parent=model
   end
   local chassis=box('Chassis',6.1,1,13.1,0,2.02,0,trim); chassis.Transparency=1; model.PrimaryPart=chassis
   local track=template=='GT' and 4.19 or 3.36
   for _,side in {-1,1} do for _,z in {-4.95,4.95} do
    local tire=box('Tire',.85,2.8,2.8,side*track,1.85,z,trim,'Rubber'); tire.Transparency=1; tire.Shape=rb.Enum.PartType.Cylinder
   end end
   local seat=rb.Instance.new('VehicleSeat'); seat.Name='Driver'; seat.Size=V(2.1,.34,1.9)
   seat.CFrame=origin*cf.new(-1.35,template=='GT' and 1.88 or 2.59,-.07); seat.Transparency=1; seat.Anchored=true; seat.HeadsUpDisplay=false; seat.Parent=model
   fitCabin(seat)
   if role=='Patrol' then
    box('Lightbar base',4,.13,.72,0,7.05,-.3,trim)
    for _,side in {-1,1} do box('Emergency lens',1.8,.29,.69,side*.95,7.23,-.3,side==-1 and rgb(57,106,239) or rgb(214,50,43),'Glass') end
   elseif role=='Cab' then box('Taxi beacon',2.1,.40,.85,0,6.12,-.1,rgb(249,210,123),'Neon') end
   continue
  end
  for _,finish in {'Paint','Glass','Pillars'} do
   local name=style..'_'..finish; local p=assert(library[name]):Clone(); p:ClearAllChildren()
   local center=bounds[name].center
   p.CFrame=origin*cf.new(scaled(table.unpack(center)))*cf.Angles(0,math.pi,0)
   p.Size=p.Size*scale; p.Name=finish; p.Anchored=true; p.CanCollide=false; p.DoubleSided=true
   p.Material=finish=='Glass' and rb.Enum.Material.Glass or rb.Enum.Material.Metal
   p.Color=finish=='Paint' and paint or finish=='Glass' and rgb(68,95,108) or trim
   p.Transparency=finish=='Glass' and .31 or 0; p.Reflectance=finish=='Glass' and .15 or .055; p.Parent=model
  end
  local base=box('Chassis',6,1,13,0,2.25,0,trim); model.PrimaryPart=base
  for _,side in {-1,1} do
   local function v(x,y,z) return V(side*x,y,z) end
   box('Door pull',.16,.16,.8,side*(width-.08),belt-.33,.18,alloy)
   rod('Mirror mount',v(width-.21,belt+.15,-2.95),v(width+.30,belt+.47,-2.75),.2,.21,trim)
   local mirror=box('Painted mirror',.79,.42,1,side*(width+.4),belt+.51,-2.78,paint); mirror.Shape=rb.Enum.PartType.Ball
   for _,z in {-4.67,4.67} do
    local tire=box('Tire',.93,2.93,2.93,side*(width-.23),1.92,z,rgb(30,32,34),'Rubber')
    -- Keep the bus tires circular while lengthening the wheelbase.
    tire.Size=V(.93*scale.X,2.93*scale.Y,2.93*scale.Y); tire.Shape=rb.Enum.PartType.Cylinder
    for _,spec in {{'Rim',2.12,.10,alloy},{'Brake rotor',1.86,.16,trim},{'Hub',.50,.27,alloy}} do
     local disc=box(spec[1],spec[3],spec[2],spec[2],side*(width+.24),1.92,z,spec[4])
     disc.Size=V(spec[3]*scale.X,spec[2]*scale.Y,spec[2]*scale.Y); disc.Shape=rb.Enum.PartType.Cylinder
    end
    for n=0,6 do
     local a=n*math.pi*2/7
     rod('Swept alloy spoke',v(width+.36,1.92+.14*math.cos(a),z+.14*math.sin(a)*scale.Y/scale.Z),v(width+.36,1.92+.93*math.cos(a+.15),z+.93*math.sin(a+.15)*scale.Y/scale.Z),.14,.15,alloy)
    end
   end
   local lampY=belt-.89
   if style=='Sport' then
    local lo=v(1.92,lampY-.08,nose-.08); local hi=v(3.12,lampY+.15,nose+.07)
    rod('Swept lamp recess',lo,hi,.54,.39,trim)
    rod('Daytime signature',lo+V(0,.11,-.08),hi+V(0,.14,-.08),.14,.115,rgb(230,244,250))
    rod('Fender light return',hi,v(3.61,lampY+.28,nose+.69),.15,.12,alloy)
    box('Corner brake duct',.71,.29,.19,side*2.58,1.94,nose-.11,trim)
   elseif style=='Muscle' then
    box('Split grille bezel',2.86,.68,.19,side*1.50,lampY,nose-.13,alloy)
    box('Split grille insert',2.71,.5,.22,side*1.50,lampY,nose-.22,trim)
    for k=0,1 do
     local ring=box('Round headlight bezel',.57,.57,.2,side*(2.09+.63*k),lampY,nose-.30,alloy); ring.Shape=rb.Enum.PartType.Ball
     local lamp=box('Round headlight',.43,.43,.21,side*(2.09+.63*k),lampY,nose-.38,rgb(251,232,189),'Neon'); lamp.Shape=rb.Enum.PartType.Ball
    end
    box('Chrome bumper',2.95,.17,.39,side*1.54,1.96,nose-.10,alloy)
    rod('Hood brightwork',v(1.19,belt-.08,nose+1.35),v(1.23,belt+.28,-3.5),.075,.08,alloy)
   elseif style=='Van' or style=='Utility' then
    box('Truck headlight bezel',1.39,.75,.18,side*2.43,lampY,nose-.11,trim)
    box('Twin beam',1.13,.29,.19,side*2.43,lampY+.12,nose-.20,rgb(240,238,205),'Neon')
    box('Turn lens',.51,.18,.19,side*2.77,lampY-.18,nose-.20,rgb(216,141,46),'Glass')
    box('Fog lamp',.47,.25,.22,side*2.60,1.92,nose-.12,alloy)
   else
    box('Headlamp housing',1.56,.49,.15,side*2.42,lampY,nose-.055,trim)
    box('Headlamp lens',1.38,.28,.16,side*2.42,lampY,nose-.14,rgb(226,238,235),'Neon')
    rod('Marker return',v(3.0,lampY,nose-.11),v(3.43,lampY+.12,nose+.4),.20,.22,alloy)
   end
   box('Tail lamp',1.52,.36,.14,side*2.32,belt-.72,tail+.04,rgb(189,35,42),'Neon')
   if role=='Bus' or role=='Medic' or role=='Patrol' then
    box('Fleet side stripe',.15,.33,6.3,side*(width-.06),belt-.38,0,role=='Medic' and rgb(193,55,44) or trim)
   end
   if role=='Bus' then
    for col=-3,4 do box('Passenger window divider',.16,2.8,.13,side*(width-.53),belt+1.7,col*1.29,trim) end
   end
  end
  if style=='Sport' then
   box('Wide oval intake',4.27,.43,.21,0,1.99,nose-.13,trim).Shape=rb.Enum.PartType.Ball
   box('Front splitter',6.03,.10,.41,0,1.58,nose-.12,trim)
  elseif style~='Muscle' then
   local h=(style=='Utility' or style=='Van') and 1.03 or .49
   box('Grille frame',3.48,h,.19,0,2.35,nose-.1,alloy)
   box('Inset grille',3.29,h-.12,.2,0,2.35,nose-.18,trim)
   for bar=1,3 do box('Horizontal grille bar',3.22,.055,.2,0,2.35+(bar-2)*h*.24,nose-.25,alloy) end
  end
  box('Plate',1.56,.52,.13,0,2.64,tail+.09,rgb(225,218,195))
  for _,x in {-1.47,1.47} do
   if x>0 then box('Passenger cushion',2.3,.42,2,x,2.92,-.8,trim,'Fabric') end
   box('Bucket seatback',2.2,1.57,.48,x,3.77,.4,trim,'Fabric'); box('Head restraint',1.2,.65,.45,x,4.85,.48,trim,'Fabric')
  end
  box('Rear bench',5.7,.58,2,0,3,2.64,trim,'Fabric'); box('Dashboard',6,.62,1.15,0,belt-.24,-2.94,trim)
  local seat=rb.Instance.new('VehicleSeat'); seat.Name='Driver'; seat.Size=V(2.36,.48,2.2)
  seat.CFrame=origin*cf.new(scaled(-1.47,2.97,-.8)); seat.Color=trim; seat.Anchored=true; seat.HeadsUpDisplay=false; seat.Parent=model
  fitCabin(seat)
  if role=='Cab' then box('Taxi beacon',2.08,.43,.85,0,roof+.38,.25,rgb(249,209,126),'Neon')
  elseif role=='Patrol' or role=='Medic' then
   box('Lightbar base',4.02,.16,.87,0,roof+.24,.2,trim)
   for _,side in {-1,1} do box('Emergency lens',1.85,.33,.75,side*.98,roof+.44,.2,side==-1 and rgb(59,103,240) or rgb(227,60,58),'Glass') end
  elseif role=='Bus' then
   local board=box('School destination',3.75,.68,.18,0,roof-.14,-3.91,rgb(231,165,50))
   local sign=rb.Instance.new('SurfaceGui'); sign.CanvasSize=rb.Vector2.new(320,65); sign.Parent=board
   local text=rb.Instance.new('TextLabel'); text.Size=rb.UDim2.fromScale(1,1); text.BackgroundTransparency=1
   text.Text='SCHOOL BUS'; text.FontFace=rb.Font.new('rbxasset://fonts/families/HighwayGothic.json'); text.TextScaled=true; text.TextColor3=trim; text.Parent=sign
   for _,side in {-1,1} do box('School flasher',.5,.38,.23,side*2.16,roof-.2,-3.85,rgb(218,141,35),'Neon') end
  end
 end
end
