local rb = require('@lune/roblox')
local CFrame, Color3, Enum = rb.CFrame, rb.Color3, rb.Enum
local xs = {-660,-450,-240,0,240,450,660}
local zs = {-460,-210,0,210,430,610,830,1040}
local avenues = {'FULTON AVE','CAREY ST','HOWARD ST','CHARLES ST','CALVERT ST','BROADWAY','CHESTER ST'}
local streets = {'QUAY WALK','MONUMENT ST','NORTH AVE','HARBOR WAY','ORLEANS ST','MADISON ST','PRATT ST','LEXINGTON ST'}
return function(part,group,label,parent)
 local function slab(name,axis,along,across,length,width,y,height,color,material)
  return part(name,axis and {width,height,length} or {length,height,width},axis and {across,y,along} or {along,y,across},color,material,parent)
 end
 part('City land',{1460,6,1660},{0,-3.2,270},Color3.fromRGB(105,127,99),'Grass',parent)
 local function road(axis,fixed,intersections)
  local first,last=intersections[1],intersections[#intersections]
  slab('Carriageway',axis,(first+last)/2,fixed,last-first+34,34,axis and 0 or .025,.7,'road','Asphalt')
  local drives=axis and ({[0]={1,148},[-450]={-1,994},[660]={1,111}})[fixed]
  local function sidewalk(name,side,start,finish,offset,width,y,height,color)
   local function strip(a,b)
    if b>a then slab(name,axis,(a+b)/2,fixed+side*offset,b-a,width,y,height,color,'Concrete') end
   end
   if drives and side==drives[1] and drives[2]>start and drives[2]<finish then
    strip(start,drives[2]-20); strip(drives[2]+20,finish)
   else strip(start,finish) end
  end
  for i=1,#intersections-1 do
   local a,b=intersections[i],intersections[i+1]
   for _,side in {-1,1} do
    local inset=axis and 17 or 26
    sidewalk('Pavement',side,a+inset,b-inset,21.5,9,.25,1,'stone')
    sidewalk('Kerbstone',side,a+17,b-17,17.3,.6,.35,.9,'cream')
   end
   for k=a+39,b-34,20 do slab('Center line',axis,k,fixed,8,.35,.42,.04,(not axis and fixed==zs[#zs]) and 'cream' or 'gold','SmoothPlastic') end
   for _,k in {a+21,b-21} do
    for offset=-14,14,4 do slab('Zebra crossing',axis,k,fixed+offset,5.5,1.6,.42,.05,'cream','Concrete') end
   end
  end
 end
 for _,x in xs do road(true,x,zs) end
 for _,z in zs do road(false,z,xs) end
 local signals=group('Traffic signals',parent)
 local rgbHousing=Color3.fromRGB(201,151,47)
 local white=Color3.fromRGB(245,246,232)
 local green=Color3.fromRGB(18,112,82)
 local silver=Color3.fromRGB(153,162,162)
 local font=rb.Font.new('rbxasset://fonts/families/HighwayGothic.json')
 local function surface(p,face,w,h)
  local gui=rb.Instance.new('SurfaceGui'); gui.Face=face; gui.SizingMode=Enum.SurfaceGuiSizingMode.FixedSize
  gui.CanvasSize=rb.Vector2.new(w,h); gui.LightInfluence=.55; gui.Parent=p; return gui
 end
 local function field(gui,name,x,y,w,h,color)
  local f=rb.Instance.new('Frame'); f.Name=name; f.Position=rb.UDim2.fromScale(x,y); f.Size=rb.UDim2.fromScale(w,h)
  f.BorderSizePixel=0; f.BackgroundColor3=color; f.Parent=gui; return f
 end
 local function text(gui,name,word,x,y,w,h,size,color)
  local t=rb.Instance.new('TextLabel'); t.Name=name; t.BackgroundTransparency=1; t.Text=word
  t.FontFace=font; t.TextSize=size; t.TextColor3=color
  t.Size=rb.UDim2.fromScale(w,h); t.Position=rb.UDim2.fromScale(x,y); t.Parent=gui; return t
 end
 local function blade(name,post,y,angle)
  local street,suffix=name:match('^(.*) (%S+)$'); street=street or name
  local width=math.max(7.6,#street*.86+(suffix and 3.1 or 1.7))
  local blade=part('Street blade',{width,2.04,.15},{0,0,0},white,'Metal',parent)
  blade:SetAttribute('StreetName',name)
  blade.CFrame=post*CFrame.Angles(0,angle,0)*CFrame.new(width/2+.18,y,0)
  for _,face in {Enum.NormalId.Front,Enum.NormalId.Back} do
   local gui=surface(blade,face,math.floor(width*50),102)
   field(gui,'Enamel',.014,.055,.972,.89,green)
   text(gui,'TextLabel',street,.03,.035,suffix and .73 or .94,.92,75,white)
   if suffix then text(gui,'Suffix',suffix,.76,.09,.20,.58,#suffix>3 and 29 or 42,white) end
  end
 end
 local function band(post,y)
  local ring=part('Mounting band',{.32,.83,.83},{0,0,0},silver,'Metal',parent)
  ring.Shape=Enum.PartType.Cylinder; ring.CFrame=post*CFrame.new(0,y,0)*CFrame.Angles(0,0,math.pi/2)
 end
 for ix,x in xs do for iz,z in zs do
  local post=CFrame.new(x+21,0,z+21)
  local mast=part('Galvanized signpost',{13.6,.64,.64},{0,0,0},silver,'Metal',parent)
  mast.Shape=Enum.PartType.Cylinder; mast.CFrame=post*CFrame.new(0,6.8,0)*CFrame.Angles(0,0,math.pi/2)
  band(post,12.35); band(post,10.16)
  blade(avenues[ix],post,12.35,math.pi/2); blade(streets[iz],post,10.16,0)
  if iz==#zs then
   local plate=part('One way',{6.1,2,.17},{x+21,7.75,z+20.52},white,'Metal',parent)
   for _,face in {Enum.NormalId.Front,Enum.NormalId.Back} do
    local gui=surface(plate,face,320,102); field(gui,'Black enamel',.015,.045,.97,.91,Color3.fromRGB(29,31,32))
    local right=face==Enum.NormalId.Back
    field(gui,'Arrow shaft',right and .075 or .20,.28,.72,.44,white)
    local arrow=field(gui,'Arrow point',right and .73 or .105,.267,.14,.465,white); arrow.Rotation=45
    text(gui,'Legend','ONE WAY',.22,.23,.56,.52,43,Color3.fromRGB(21,25,25))
   end
  end
  if ix>1 and ix<#xs and iz>1 and iz<#zs then
   for i=0,3 do
    local m=group('Signal head',signals); m:SetAttribute('Axis',i%2); m:SetAttribute('Junction',ix..'-'..iz)
    local pivot=CFrame.new(x,0,z)*CFrame.Angles(0,i*math.pi/2,0)
    local function pole(name,size,dx,y,dz,color)
     local p=part(name,size,{0,0,0},color,'Metal',m); p.CFrame=pivot*CFrame.new(dx,y,dz); return p
    end
    pole('Mast',{.63,20,.63},-20,10,20,silver)
    pole('Cantilever',{13.6,.45,.45},-13.4,19.3,20,silver)
    pole('Signal hanger',{.32,1.5,.35},-8,18.9,20,'dark')
    pole('Housing',{2.4,5.8,.88},-8,16,20,rgbHousing)
    pole('Visor backing',{2.03,5.48,.3},-8,16,19.43,'dark')
    local phase=i%2==0 and 'Green' or 'Red'; m:SetAttribute('Phase',phase)
    for n,name in {'Red','Amber','Green'} do
     local y=17.65-(n-1)*1.65
     local lens=pole(name,{1.28,1.28,.3},-8,y,19.17,'dark'); lens.Shape=Enum.PartType.Ball
     if phase==name then lens.Material=Enum.Material.Neon; lens.Color=name=='Red' and Color3.fromRGB(251,65,52) or Color3.fromRGB(66,224,138) end
     pole('Rain hood',{1.48,.16,.79},-8,y+.69,19.11,'dark')
    end
    local ped=pole('Crossing signal',{2.6,3,.78},-20,8.35,19.5,rgbHousing)
    local gui=surface(ped,Enum.NormalId.Front,100,115)
    field(gui,'Lens',.06,.07,.88,.86,Color3.fromRGB(27,31,33))
    local hand=field(gui,'Stop',0,0,1,1,white); hand.BackgroundTransparency=1
    local walk=field(gui,'Walk',0,0,1,1,white); walk.BackgroundTransparency=1
    local amber=Color3.fromRGB(255,161,65)
    field(hand,'Palm',.32,.45,.39,.30,amber)
    for k,h in {.21,.29,.25,.17} do field(hand,'Finger',.32+(k-1)*.10,.46-h,.078,h,amber) end
    field(hand,'Thumb',.249,.466,.09,.22,amber).Rotation=-32
    field(walk,'Head',.46,.18,.15,.14,white); field(walk,'Torso',.44,.34,.14,.27,white).Rotation=14
    field(walk,'Arm',.315,.36,.10,.22,white).Rotation=49; field(walk,'Arm',.57,.36,.095,.21,white).Rotation=-44
    field(walk,'Leg',.35,.55,.11,.25,white).Rotation=34; field(walk,'Leg',.54,.53,.11,.25,white).Rotation=-30
    walk.Visible=phase=='Green'; hand.Visible=not walk.Visible
   end
  end
 end end
end
