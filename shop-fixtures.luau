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
 p('Sales floor lighting track',24,.20,.34,x,12.8,z,steel,'Metal')
 for _,u in {-10,0,10} do
  p('Track light head',.85,.64,.9,x+u,12.4,z,steel,'Metal')
  local lens=p('Track light diffuser',.65,.12,.65,x+u,12.05,z,rgb(246,213,158),'Neon')
  Fixtures.spot(lens,rgb(255,220,172),15,.75)
 end
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
-- These details share the original register's frame. Queries continue to hit the till.
function Fixtures.register(till)
 local function detail(name,size,offset,color,angle)
  local part=rb.Instance.new('Part');part.Name=name;part.Size=size
  part.CFrame=till.CFrame*offset*rb.CFrame.Angles(angle or 0,0,0)
  part.Color=color;part.Material=rb.Enum.Material.SmoothPlastic;part.Anchored=true
  part.CanCollide=false;part.CanTouch=false;part.CanQuery=false;part.Parent=till
  return part
 end
 local v,cf=rb.Vector3.new,rb.CFrame.new
 till.Color=rgb(79,84,78)
 local y=till.Size.Y/2
 detail('Drawer edge',v(2.45,.23,1.97),cf(0,-y+.19,-.04),steel)
 detail('Receipt display',v(1.73,.72,.25),cf(0,y+.32,.32),rgb(52,60,58),-.13)
 detail('LCD panel',v(1.43,.47,.035),cf(0,y+.34,.16),rgb(128,164,142),-.13)
 for row=0,1 do for col=0,3 do
  detail('Till key',v(.22,.10,.21),cf(-.52+col*.32,y+.065,-.53+row*.29),col==3 and stock[row+1] or rgb(190,188,171))
 end end
 detail('Receipt tape',v(.35,.05,.47),cf(.98,y+.035,-.34),rgb(224,217,197))
end

function Fixtures.spot(body,color,range,brightness)
 local light=rb.Instance.new('SpotLight')
 light.Face=rb.Enum.NormalId.Bottom; light.Angle=92; light.Color=color
 light.Range=range;light.Brightness=brightness;light.Parent=body
 return light
end
return Fixtures
