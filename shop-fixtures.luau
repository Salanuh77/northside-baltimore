local rb=require('@lune/roblox')
local rgb=rb.Color3.fromRGB
local Fixtures={}
local imported={}
for _,key in {'pastry-case','dress-form'} do
 local model=rb.deserializeModel(require('@lune/fs').readFile('art/'..key..'.rbxm'))[1]
 imported[key]=assert(model:FindFirstChildWhichIsA('MeshPart',true),key)
end

local function display(p,key,title,x,floor,z,width,height,depth,yaw,color)
 local placement=p('Fixture placement',1,1,1,x,floor,z,'dark','Metal')
 local mesh=imported[key]:Clone()
 local s=mesh.Size
 mesh.Size=s*math.min(width/s.X,height/s.Y,depth/s.Z)
 mesh.CFrame=placement.CFrame*rb.CFrame.new(0,mesh.Size.Y/2,0)*rb.CFrame.Angles(0,math.rad(yaw),0)
 mesh.Name=title;mesh.Anchored=true;mesh.CanCollide=false;mesh.CanTouch=false;mesh.CanQuery=false
 mesh.Color=color;mesh.Parent=placement.Parent
 placement:Destroy()
 return mesh
end
local steel=rgb(65,70,68)
local oak=rgb(157,124,88)
local stock={rgb(125,49,55),rgb(48,71,87),rgb(143,139,103)}

-- The station stores a floor point behind the fixture and inherits its local heading.
function Fixtures.staff(desk,role,x,z,floor)
 local at=desk.CFrame*rb.CFrame.new(x,0,z)
 desk:SetAttribute('StaffSpot',at.Rotation+rb.Vector3.new(at.X,floor,at.Z))
 desk:SetAttribute('StaffRole',role)
end

function Fixtures.clothing(p,lettering,x,z)
 for index,offset in {-11,11} do
  local u=x+offset
  for _,side in {-1,1} do
   p('Rack foot',1.35,.22,2.5,u+side*4.2,1.5,z,steel,'Metal')
   p('Rack upright',.22,6.1,.22,u+side*4.2,4.55,z,steel,'Metal')
  end
  p('Hanging rail',8.6,.2,.22,u,7.5,z,steel,'Metal')
  for j=-2,2 do
   local pos=u+j*1.44
   local cloth=stock[(j+index+3)%3+1]
   p('Hanger hook',.13,.55,.18,pos,7.15,z,steel,'Metal')
   for _,side in {-1,1} do
    local sleeve=p('Garment shoulder',.54,.8,1.12,pos,6.40,z+side*.66,cloth,'Fabric')
    sleeve.CFrame*=rb.CFrame.Angles(side*.31,0,0)
   end
   p('Hanging garment',.55,2.65,1.42,pos,5.21,z,cloth,'Fabric')
  end
 end
 display(p,'dress-form','Window dress form',x-11,1.4,z-7,3.3,6.4,3,-15,rgb(210,184,147))
 local tableX=x+10
 p('Display plinth',8,2.2,4,tableX,2.45,z+6,oak,'Wood')
 for j=-1,1 do for layer=0,2 do
  p('Folded stock',2.1,.3,2.4,tableX+j*2.3,3.7+layer*.30,z+6,stock[j+2],'Fabric')
 end end
 local card=p('Collection card',8,1.55,.18,tableX,5.8,z+7.35,steel,'Metal')
 lettering(card,'LAST SEASON')
end

function Fixtures.coffee(p)
 p('Espresso machine',5.0,2.3,2.3,-5,5.9,14,steel,'Metal')
 p('Drip tray',4.9,.23,1.1,-5,4.92,12.65,'stone','Metal')
 for _,u in {-6,-4} do p('Brew group',.44,.57,.54,u,5.85,12.74,'cream','Metal') end
 for n=0,2 do
  local cup=p('Stacked takeaway cups',1.12,.8,1.12,0,5.1+n*.32,14.25,'cream','SmoothPlastic')
  cup.Shape=rb.Enum.PartType.Cylinder;cup.CFrame*=rb.CFrame.Angles(0,0,math.pi/2)
 end
 display(p,'pastry-case','Bakery display case',5.3,4.66,14,7,3.7,4.4,0,rgb(194,185,164))
end
return Fixtures
