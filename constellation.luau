-- A walkable interpretation of the 1854 museum ship, alongside the existing timber pier.
local rb=require('@lune/roblox')
local V,C,E=rb.Vector3,rb.CFrame,rb.Enum
return function(parent,group)
 local model=group('USS Constellation',parent)
 local origin=V.new(383,0,-621)
 local tar=rb.Color3.fromRGB(42,43,41)
 local copper=rb.Color3.fromRGB(127,86,60)
 local pine=rb.Color3.fromRGB(189,158,111)
 local ivory=rb.Color3.fromRGB(229,216,185)
 local function piece(name,size,frame,color,material,class)
  local part=rb.Instance.new(class or 'Part')
  part.Name=name;part.Size=size;part.CFrame=frame+origin;part.Anchored=true
  part.Color=color;part.Material=material or E.Material.Wood;part.Parent=model
  return part
 end
 local function spar(name,a,b,r,color,solid)
  local part=piece(name,V.new((b-a).Magnitude,r,r),C.lookAt((a+b)/2,b)*C.Angles(0,math.pi/2,0),color)
  part.Shape=E.PartType.Cylinder;part.CanCollide=solid==true
  return part
 end
 -- Split each triangular plank along the altitude. The deck and topsides share vertices.
 local function triangle(name,a,b,c,color)
  local ab,ac,bc=b-a,c-a,c-b
  if ab.Magnitude>ac.Magnitude and ab.Magnitude>bc.Magnitude then a,c=c,a
  elseif ac.Magnitude>bc.Magnitude then a,b=b,a end
  ab,ac,bc=b-a,c-a,c-b
  local right=ac:Cross(ab).Unit
  local back=bc.Unit
  local up=back:Cross(right).Unit
  local height=math.abs(ab:Dot(up))
  for _,t in {{a,b,right,back,ab},{a,c,-right,-back,ac}} do
   local length=math.abs(t[5]:Dot(back))
   if length>.02 then
    piece(name,V.new(.12,height,length),C.fromMatrix((t[1]+t[2])/2,t[3],up,t[4]),color,E.Material.WoodPlanks,'WedgePart')
   end
  end
 end
 local sections={{-51,.35},{-43,6.3},{-30,10.5},{-12,12.5},{17,12.5},{35,10.6},{45,8.8}}
 local levels={{-.6,.59,copper},{2.8,.90,tar},{4.6,.97,ivory},{6,1,tar},{7.1,1,pine}}
 for index=2,#sections do
  local first,last=sections[index-1],sections[index]
  for _,side in {-1,1} do
   for i=2,#levels do
    local lo,hi=levels[i-1],levels[i]
    local a=V.new(side*first[2]*lo[2],lo[1],first[1]);local b=V.new(side*last[2]*lo[2],lo[1],last[1])
    local c=V.new(side*last[2]*hi[2],hi[1],last[1]);local d=V.new(side*first[2]*hi[2],hi[1],first[1])
    triangle('Planked hull',a,b,c,lo[3]);triangle('Planked hull',a,c,d,lo[3])
   end
  end
  local a=V.new(-first[2],7.1,first[1]);local b=V.new(first[2],7.1,first[1])
  local c=V.new(last[2],7.1,last[1]);local e=V.new(-last[2],7.1,last[1])
  triangle('Spar deck',a,b,c,pine);triangle('Spar deck',a,c,e,pine)
 end
 piece('Stern transom',V.new(17.6,6,.5),C.new(0,4.1,45),tar)
 for _,mast in {{-25,45},{2,52},{29,38}} do
  local z,h=mast[1],mast[2]
  spar('Lower mast',V.new(0,7,z),V.new(0,h*.64,z),1.5,ivory,true)
  spar('Topmast',V.new(0,h*.64,z),V.new(0,h,z),.83,pine)
  for i=1,3 do
   local y=h*(.43+.16*i); local half=16-i*2
   spar('Square yard',V.new(-half,y,z),V.new(half,y,z),.82,tar)
   spar('Furled canvas',V.new(-half+1,y+.3,z),V.new(half-1,y+.3,z),1.12,ivory)
  end
  for _,side in {-1,1} do for n=-1,1 do
   spar('Shroud',V.new(side*9.6,7.3,z+n*2.3),V.new(0,h*.69,z),.14,tar)
  end end
 end
 spar('Bowsprit',V.new(0,8,-42),V.new(0,18,-64),1.3,pine)
 spar('Forestay',V.new(0,18,-64),V.new(0,43,-25),.19,tar)
 spar('Main stay',V.new(0,44,-25),V.new(0,51,2),.17,tar)
 spar('Mizzen stay',V.new(0,51,2),V.new(0,38,29),.17,tar)
 for _,side in {-1,1} do for z=-27,30,7 do
  local width=math.min(12.5,12.5-math.max(0,math.abs(z)-17)*.115)
  piece('Port shutter',V.new(.21,1.6,2.3),C.new(side*width*.95,3.85,z),tar)
 end end
 local shore,deck=V.new(30,.72,11),V.new(11,7.18,11)
 local ramp=piece('Boarding ramp',V.new(5,.45,(deck-shore).Magnitude),C.lookAt((deck+shore)/2,deck),pine)
 for _,side in {-1,1} do
  local offset=V.new(0,3,side*2.5)
  spar('Gangway handrail',shore+offset,deck+offset,.22,ivory)
  for _,t in {0,.5,1} do
   local foot=shore:Lerp(deck,t)+V.new(0,0,side*2.5)
   spar('Handrail stanchion',foot,foot+V.new(0,3,0),.23,ivory)
  end
 end
end
