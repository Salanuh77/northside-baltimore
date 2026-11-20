local rb = require('@lune/roblox')
local fs = require('@lune/fs')
local cf, v3, rgb = rb.CFrame, rb.Vector3.new, rb.Color3.fromRGB
local templates = {}
for _,key in {'sofa','bed','sink','stove','sideboard'} do
 local imported=rb.deserializeModel(fs.readFile('art/home-'..key..'.rbxm'))[1]
 templates[key]=assert(imported:FindFirstChildWhichIsA('MeshPart',true),key)
end

local function model(parent,name)
 local m=rb.Instance.new('Model')
 m.Name=name
 m.Parent=parent
 return m
end
local function part(parent,name,frame,size,color,material)
 local p=rb.Instance.new('Part')
 p.Name=name
 p.Size=size
 p.CFrame=frame
 p.Anchored=true
 p.CanTouch=false
 p.CanCollide=false
 p.CanQuery=false
 p.Color=color
 p.Material=rb.Enum.Material[material]
 p.Parent=parent
 return p
end
local function furniture(parent,title,key,meshName,frame,width)
 local m=model(parent,title)
 local mesh=templates[key]:Clone()
 mesh.Size*=width/mesh.Size.X
 mesh.Name=meshName
 mesh.CFrame=frame*cf.new(0,mesh.Size.Y/2,0)
 mesh.Anchored=true
 mesh.CanCollide=false
 mesh.CanQuery=false
 mesh.CanTouch=false
 mesh.Parent=m
 return m,mesh.Size
end
local function base(m,frame,width,height,depth)
 local body=part(m,'Furniture base',frame*cf.new(0,height/2,0),v3(width,height,depth),rgb(120,96,80),'Wood')
 body.Transparency=1
 body.CanCollide=true
 body.CanQuery=true
end
local function action(p,kind,label)
 p:SetAttribute('Action',kind)
 p:SetAttribute('Label',label)
 p:SetAttribute('Reach',6)
 p:SetAttribute('Hold',.2)
end
local function seat(m,frame,kind,label)
 local s=rb.Instance.new('Seat')
 s.Name=label
 s.Size=v3(2,.22,1.55)
 s.CFrame=frame
 s.Anchored=true
 s.Transparency=1
 s.CanTouch=false
 s.CanCollide=false
 s.CanQuery=false
 s.Parent=m
 action(s,kind,label)
 return s
end
local function couch(room,frame,width,variant)
 local m,s=furniture(room,'Living room sofa','sofa','Sofa upholstery',frame,width)
 base(m,frame,width*.92,s.Y*.39,s.Z*.85)
 for _,side in {-1,1} do
  seat(m,frame*cf.new(side*width*.215,s.Y*.45,-s.Z*.12),'SitHome','Sit down')
 end
 local colors={rgb(114,132,114),rgb(166,113,84),rgb(91,115,133)}
 local rug=frame*cf.new(0,.036,-s.Z*.68)
 part(m,'Flatweave rug',rug,v3(width+.65,.06,s.Z+1.8),colors[variant%3+1],'Fabric')
 for _,side in {-1,1} do
  part(m,'Woven border',rug*cf.new(side*(width/2-.12),.035,0),v3(.12,.02,s.Z+1.45),rgb(211,197,163),'Fabric')
 end
end
local function bed(room,frame,width)
 local m,s=furniture(room,'Bed','bed','Quilted bed',frame,width)
 base(m,frame,width*.94,s.Y*.47,s.Z*.93)
 -- Prompt stays at the foot; the body rests across the mattress instead of sitting here.
 local rest=seat(m,frame*cf.new(0,s.Y*.54,-s.Z*.36),'RestHome','Rest')
 rest:SetAttribute('RestSurface',frame*cf.new(0,s.Y*.54,-.15))
 rest:SetAttribute('RestExit',frame*cf.new(0,.12,-s.Z*.5-1.7))
end
local function appliance(room,frame,key,width)
 local sink=key=='sink'
 local m,s=furniture(room,sink and 'Kitchen sink' or 'Stove',key,sink and 'Kitchen sink' or 'Kitchen range',frame,width)
 base(m,frame,s.X*.95,s.Y*(sink and .59 or .67),s.Z*.93)
 local control=part(m,'Controls',frame*cf.new(0,s.Y*.62,-s.Z*.51),v3(.4,.4,.24),rgb(0,0,0),'Metal')
 control.Transparency=1
 action(control,sink and 'UseTap' or 'Cook',sink and 'Run tap' or 'Cook a meal')
 if sink then
  local stream=part(m,'Running water',frame*cf.new(0,s.Y*.72,.04),v3(.08,s.Y*.19,.08),rgb(170,213,223),'Glass')
  stream.Transparency=1
 end
end

-- Small two-color neighborhood prints hang on the inside face of an existing wall.
local function printOnWall(room,frame,variant)
 local walnut=rgb(97,66,47)
 local mount=part(room,'Framed block print',frame,v3(3.2,2.5,.12),walnut,'Wood')
 local gui=rb.Instance.new('SurfaceGui')
 gui.Face=rb.Enum.NormalId.Front
 gui.CanvasSize=rb.Vector2.new(160,125)
 gui.LightInfluence=1
 gui.Parent=mount
 local function ink(x,y,w,h,color)
  local block=rb.Instance.new('Frame')
  block.BorderSizePixel=0
  block.Position=rb.UDim2.fromOffset(x,y)
  block.Size=rb.UDim2.fromOffset(w,h)
  block.BackgroundColor3=color
  block.Parent=gui
 end
 local paper,sky,brick=rgb(227,215,185),rgb(139,170,169),rgb(154,94,73)
 ink(5,5,150,115,paper)
 ink(15,15,130,95,sky)
 ink(104,22,16,16,paper)
 for house=0,3 do
  local x=18+house*31
  local y=44+(house+variant)%3*8
  ink(x,y,28,110-y,brick)
  ink(x-1,y,30,4,walnut)
  for window=0,1 do ink(x+5+window*12,y+9,6,10,paper) end
 end
end

-- Coordinates are measured at finished floor level. Each row gives x, z, yaw and width.
local layouts={
 Flat={sofa={7,-11,180,9.3},bed={2,16,0,7.7},sink={-14,-4,-90,4},stove={-14,.5,-90,3.9},table={12.8,-11}},
 Rowhome={sofa={7,-7,90,9.1},bed={5,7,0,8,13.525},sink={9.7,14.8,0,4.1},stove={5.45,14.8,0,4},table={7,-13}},
 Hollins={sofa={7.9,5,90,7.7},bed={4,-8,180,6.8},sink={-8.4,-3,-90,3.65},stove={-8.4,-7.1,-90,3.6},table={7.6,10.4}},
 Waterfront={sofa={12,-3,90,9.1},bed={-10.2,5.6,0,7.8},sink={2,9.3,0,4.25},stove={6.45,9.3,0,4.15},table={12,-9}},
}
return function(building,origin,layout,index)
 local plan=assert(layouts[layout])
 local room=model(building,'Home furnishings '..tostring(index))
 room:SetAttribute('HomeLayout',layout)
 local function anchor(slot)
  return origin*cf.new(slot[1],slot[5] or 0,slot[2])*cf.Angles(0,math.rad(slot[3]),0)
 end
 couch(room,anchor(plan.sofa),plan.sofa[4],index)
 bed(room,anchor(plan.bed),plan.bed[4])
 for _,key in {'sink','stove'} do appliance(room,anchor(plan[key]),key,plan[key][4]) end
 if layout=='Flat' then
  local frame=origin*cf.new(13.9,0,8)*cf.Angles(0,math.pi/2,0)
  local cabinet,size=furniture(room,'Hall sideboard','sideboard','Walnut sideboard',frame,5.3)
  cabinet['Walnut sideboard'].Color=rgb(159,122,89)
  base(cabinet,frame,size.X*.94,size.Y*.88,size.Z*.9)
 end
 local tableFrame=origin*cf.new(plan.table[1],0,plan.table[2])
 local tableModel=model(room,'Reading table')
 base(tableModel,tableFrame,2.4,1.9,2.1)
 local wood,brass=rgb(120,81,57),rgb(156,122,65)
 part(tableModel,'Walnut pedestal',tableFrame*cf.new(0,.9,0),v3(.75,1.8,.75),wood,'Wood')
 part(tableModel,'Oak top',tableFrame*cf.new(0,1.85,0),v3(2.5,.24,2.2),wood,'Wood')
 part(tableModel,'Book',tableFrame*cf.new(-.65,2.06,-.2)*cf.Angles(0,.17,0),v3(.8,.17,1.1),rgb(82,118,115),'Fabric')
 part(tableModel,'Lamp stem',tableFrame*cf.new(.5,2.65,.18),v3(.18,1.4,.18),brass,'Metal')
 local shade=part(tableModel,'Linen shade',tableFrame*cf.new(.5,3.55,.18)*cf.Angles(0,0,math.pi/2),v3(1.05,1.35,1.35),rgb(232,201,151),'Fabric')
 shade.Shape=rb.Enum.PartType.Cylinder
 if index%3~=0 then
  local wallX=({Flat=16.05,Rowhome=12.72,Hollins=10.27,Waterfront=15.56})[layout]
  printOnWall(room,origin*cf.new(wallX,6.2,plan.sofa[2])*cf.Angles(0,math.pi/2,0),index)
 end
end
