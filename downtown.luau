local rb=require('@lune/roblox')
local rgb,cf=rb.Color3.fromRGB,rb.CFrame
return function(t,i,district,group,builder,landmark,lettering,glass,action,tableSet,lounge,glow)
 local name,x,z,style,floors=table.unpack(t)
 local half=math.abs(x)==120 and 120 or 105
 local depth=z<830 and 110 or 105
 local p=builder(group(name..' commercial block',district),x,z)
 local stone=rgb(197,183,163); local teal=rgb(43,82,88); local brass=rgb(161,115,68)
 local base=({rgb(147,75,56),stone,rgb(110,119,125),rgb(91,106,103)})[(i-1)%4+1]
 local front=-depth+30
 p('Continuous city paving',half*2-34,.6,depth*2-34,0,.4,2,stone,'Concrete')
 local towerZ=front+83
 landmark(name,x,z+towerZ,0,style,floors,district)
 local names={{'Exchange Books','Park Avenue Clothiers'},{'Pratt Arcade','Charles Center Deli'},{'Lexington Produce','Chesapeake Coffee'},{'Baltimore Press','Calvert Pharmacy'},{'Meridian Social Club','Lexington Box Office'},{'Commerce Provisions','The Newsstand'},{'Municipal Records','Civic Coffee'}}
 local function wing(side)
  local width=half-42
  local u=side*(9+width/2)
  local shopName=names[i][side==-1 and 1 or 2]
  local m=group(shopName,district)
  local f=builder(m,x+u,z+front+24)
  local club=i==5 and side==-1
  f('Terrazzo floor',width,.8,48,0,.95,0,'cream','Marble')
  f('Shop rear',width,15,.8,0,8.9,24,base,'Brick')
  for _,s in {-1,1} do
   f('Display base',.8,2.2,48,s*width/2,2.4,0,base,'Brick')
   f('Display header',.8,3.9,48,s*width/2,14.45,0,base,'Brick')
   for _,endSign in {-1,1} do f('Shop return pier',.8,10.2,6.5,s*width/2,7.5,endSign*20.75,base,'Brick') end
   glass(f,'Street display bay',.45,10.2,35,s*(width/2+.45),7.4,0)
   for _,v in {-15,-5,5,15} do f('Shopfront pilaster',1.1,12,1.1,s*(width/2+.6),7.6,v,stone,'Concrete') end
   f('Sidewalk shade',4.2,.55,35,s*(width/2+1.4),13.3,0,brass,'Metal')
   glass(f,'Display window',width/2-6,12,.4,s*(width/4+3),7.55,-24)
   f('Stone sill',width/2-6,1,1,s*(width/4+3),1.7,-24.2,stone,'Concrete')
  end
  f('Terracotta lintel',width,2,.75,0,15,-24.5,base,'Concrete')
  if not club then
   local offset=(side==-1 and -1 or 1)*(width/2-6)
   f('Blade bracket',.3,.3,5.6,offset,12.3,-26,brass,'Metal')
   local blade=f('Hanging shop blade',5.2,3.2,.45,offset,10.4,-28.4,side==-1 and teal or base,'Metal')
   lettering(blade,shopName)
  end
  f('Sidewalk canopy',width+1,.7,5.5,0,12.8,-26,brass,'Metal')
  local levels=2+(i+(side==1 and 2 or 0))%4
  for k=1,levels do
   local y=16.5+(k-1)*9
   f('Office floor slab',width,.5,48,0,y+.25,0,stone,'Concrete')
   f('Office rear wall',width,8.5,.7,0,y+4.25,23.65,base,'Brick')
   f('Street spandrel',width,2,.8,0,y+1,-23.65,base,'Brick')
   f('Street header',width,1.1,.8,0,y+8.05,-23.65,base,'Brick')
   local bay=width/5
   for j=-2,2 do
    local bx=j*bay
    glass(f,'Recessed street window',bay-2.4,5.5,.28,bx,y+4.75,-23.55)
    f('Masonry sill',bay-2,.43,1,bx,y+2,-24,stone,'Concrete')
    f('Window mullion',.23,5.5,.42,bx,y+4.75,-23.8,brass,'Metal')
    for _,edge in {-1,1} do f('Brick jamb',1.2,5.5,.8,bx+edge*(bay/2-.6),y+4.75,-23.65,base,'Brick') end
   end
   for _,sideWall in {-1,1} do
    local sx=sideWall*width/2
    f('Office sill course',.8,2,48,sx,y+1,0,base,'Brick')
    f('Office side header',.8,1.1,48,sx,y+8.05,0,base,'Brick')
    for j=-2,2 do
     glass(f,'Return sash',.28,5.5,7.2,sx,y+4.75,j*9.6)
     for _,edge in {-1,1} do f('Return jamb',.8,5.5,1.2,sx,y+4.75,j*9.6+edge*4.2,base,'Brick') end
    end
   end
   f('Limestone course',width+.6,.6,48.6,0,y+8.7,0,stone,'Concrete')
  end
  f('Flat parapet',width+1.8,1.4,50,0,16.6+levels*9,0,stone,'Concrete')
  f('Rooftop plant',width*.38,2.5,8,4,18+levels*9,4,'dark','Metal')
  if club then
   for a=-1,1 do for b=-1,1 do local tile=f('Dance tile',7,.2,6,a*7.2,1.52,b*6.2,teal,'Neon'); tile:SetAttribute('BeatTile',(a+b+2)%3) end end
   local dj=f('DJ console',13,3.4,4,0,3.2,15,'dark','Metal'); action(dj,'Club','DJ booth')
   local dance=f('Dance floor controls',2,3,2,-14,2.9,-7,brass,'Metal'); action(dance,'Dance','Dance / stop')
   lettering(f('Stage sign',23,3,.4,0,9,23.4,teal,'Metal'),'MERIDIAN  /  AFTERHOURS')
   for _,s in {-1,1} do f('Sound cabinet',4,8,4,s*13,5.4,17,'dark','Metal'); lounge(f,s*19,1.4,-7,teal) end
   local track=rb.Instance.new('Sound'); track.Name='Afterhours'; track.SoundId='rbxassetid://95309271954971'; track.Looped=true; track.Volume=.34; track.RollOffMaxDistance=66; track.RollOffMinDistance=8; track.Parent=dj
   local blade=f('Illuminated blade',2.5,18,6,-width/2+3,22,-28,teal,'Neon')
   lettering(f('Blade lettering',6.5,18,.4,-width/2+3,22,-31.25,teal,'Metal'),'M\nE\nR\nI\nD\nI\nA\nN')
  else
   tableSet(f,-width*.26,-7,1.4); lounge(f,width*.26,1.4,7,teal)
   local counter=f('Sales counter',12,3.2,4,-9,3,16,brass,'Wood')
   if side==-1 and (i==3 or i==6) then action(f('City register',2,1.4,1.6,-9,5.25,16,'dark','Metal'),'Store','Rob register',225,12) end
  end
  glow(f,0,13,-3)
 end
 wing(-1); wing(1)
 -- A covered passage connects both retail wings to the tower lobby.
 p('Arcade canopy',19,.65,49,0,17,front+24,teal,'Glass')
 for v=3,47,11 do p('Arcade roof ribs',20,.6,.65,0,17.4,front+v,brass,'Metal') end
 -- Buildings at the corners frame both intersections and the rear street.
 for _,side in {-1,1} do
  local u=side*(half-39); local h=27+(i%3)*9
  p('Corner office block',19,h,57,u,h/2+1,towerZ+9,base,'Brick')
  for k=1,math.floor(h/9) do for j=-2,2 do
   glass(p,'Side street office window',.5,5,6,u+side*9.8,k*9-3,towerZ+9+j*10)
  end end
  p('Corner coping',20,.8,58,u,h+1.3,towerZ+9,stone,'Concrete')
 end
 for _,u in {-half+35,half-35} do
  p('Parking meter',.6,4.4,.6,u,2.8,front-6,'dark','Metal')
  p('Meter head',1.1,1.6,.9,u,5.5,front-6,teal,'Metal')
 end
 if i==2 or i==6 then
  local side=i==2 and 1 or -1; local bx=side*(half-24)
  p('Transit shelter roof',5.5,.55,16,bx,9.5,towerZ+30,teal,'Metal')
  for _,v in {-6.5,6.5} do p('Shelter upright',.4,8.8,.4,bx-side*2,5.1,towerZ+30+v,brass,'Metal') end
  glass(p,'Shelter windscreen',.25,7.3,14,bx-side*2,5.6,towerZ+30)
  p('Shelter bench',2.6,.5,9,bx,3,towerZ+30,'stone','Metal')
 end
 if i==2 then
  local y=17+floors*10
  p('Illuminated tower crown',33,12,20,0,y+6,towerZ,teal,'Glass')
  p('Broadcast mast',.8,24,.8,0,y+23,towerZ,'cream','Metal')
 end
 if i==2 or i==3 or i==6 then
  local y=17+floors*10
  local brand=({[2]='Charles Center',[3]='PRATT',[6]='Commerce'})[i]
  local color=i==3 and rgb(230,190,115) or rgb(239,239,219)
  local setback=style=='deco' and math.min(20,math.floor((floors-2)/3)*4)/2 or 2
  local glassZ=towerZ-24+setback
  local function letters(tag,yOffset,zOffset,tint)
   local mount=p(tag,i==3 and 38 or 63,7.8,.09,0,y-14+yOffset,glassZ+zOffset,tint,'Metal')
   mount.Transparency=1; mount.CanCollide=false; mount.CanTouch=false; mount.CanQuery=false
   lettering(mount,brand)
   local sg=mount:FindFirstChildOfClass('SurfaceGui'); local face=sg:FindFirstChildOfClass('TextLabel')
   sg.CanvasSize=rb.Vector2.new(760,96); sg.LightInfluence=.25; face.TextColor3=tint; face.TextScaled=true; face.TextSize=66
   face.FontFace=rb.Font.new('rbxasset://fonts/families/RomanAntique.json',rb.Enum.FontWeight.Bold)
  end
  letters('Channel letter returns',-.23,-1.3,rgb(29,42,48)); letters('Raised crown lettering',0,-1.6,color)
  if i==2 then
   local wedge=rb.Instance.new('WedgePart'); wedge.Name='Sloping glass crown'; wedge.Size=rb.Vector3.new(41,22,93); wedge.CFrame=cf.new(x,y+11,z+towerZ)*cf.Angles(0,math.pi/2,0); wedge.Color=rgb(92,130,149); wedge.Material=rb.Enum.Material.Glass; wedge.Anchored=true; wedge.Parent=district
   for j=0,13 do local h=2+j*1.5; p('Silver crown fin',.52,h,.9,-45+j*6.9,y+h/2,towerZ-20.8,stone,'Metal') end
  end
 end
end