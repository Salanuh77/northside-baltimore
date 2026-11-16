local players=game:GetService('Players')
local run=game:GetService('RunService')
local city=workspace:WaitForChild('Baltimore')
local drive=game:GetService('ReplicatedStorage'):WaitForChild('DriveCar')
local signals=city:WaitForChild('Streets & alleys'):WaitForChild('Traffic signals'):GetChildren()
local colors={Red=Color3.fromRGB(251,65,52),Amber=Color3.fromRGB(255,181,53),Green=Color3.fromRGB(66,224,138)}
local function lights(axis,phase)
 for _,head in signals do
  local active=head:GetAttribute('Axis')==axis and phase or 'Red'
  head:SetAttribute('Phase',active)
  local crossing=head['Crossing signal'].SurfaceGui
  crossing.Walk.Visible=active=='Green'; crossing.Stop.Visible=active~='Green'
  for name,color in colors do
   local lens=head[name]
   lens.Material=name==active and Enum.Material.Neon or Enum.Material.SmoothPlastic
   lens.Color=name==active and color or color:Lerp(Color3.fromRGB(18,25,26),.87)
  end
 end
end
task.spawn(function()
 while true do
  for axis=0,1 do
   lights(axis,'Green'); task.wait(12)
   lights(axis,'Amber'); task.wait(3)
   lights(axis,'Red'); task.wait(1)
  end
 end
end)
local physics=game:GetService('PhysicsService')
for _,name in {'NorthsideVehicle','NorthsideDriver'} do
 if not physics:IsCollisionGroupRegistered(name) then physics:RegisterCollisionGroup(name) end
end
physics:CollisionGroupSetCollidable('NorthsideVehicle','NorthsideDriver',false)

local function alignDriver(seat,human)
 local char=human.Parent
 local head=char and char:FindFirstChild('Head')
 local weld=seat:FindFirstChild('SeatWeld')
 if not head or not weld or not weld:IsA('Weld') or weld.Part0~=seat or not weld.Part1 then return end
 -- Solve in seat space using the weld's intended pose even before physics settles.
 local seatToHead=weld.C0*weld.C1:Inverse()*weld.Part1.CFrame:ToObjectSpace(head.CFrame)
 local hairTop=head.Size.Y/2
 local hair=head:FindFirstChild('Northside hair')
 if hair then
  for _,lock in hair:GetChildren() do
   hairTop=math.max(hairTop,head.CFrame:PointToObjectSpace(lock.Position).Y+lock.Size.Y/2)
  end
 end
 local targetY=seat:GetAttribute('CabinCeiling')-hairTop-.10
 local correction=Vector3.new(-seatToHead.X,math.min(0,targetY-seatToHead.Y),0)
 weld.C0=CFrame.new(correction)*weld.C0
end

local function exitAtDoor(seat,human)
 local char=human.Parent
 local root=char and char:FindFirstChild('HumanoidRootPart')
 if not root or human.Health<=0 then return end
 -- Occupant can clear before the physics step detaches the resident's assembly.
 local deadline=os.clock()+.75
 while (human.SeatPart==seat or root.AssemblyRootPart==seat.AssemblyRootPart) and os.clock()<deadline do
  run.Heartbeat:Wait()
 end
 if not root.Parent or human.SeatPart or root.AssemblyRootPart==seat.AssemblyRootPart or (root.Position-seat.Position).Magnitude>14 then return end
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={char,seat.Parent};params.RespectCanCollide=true
 for _,offset in {Vector3.new(-seat:GetAttribute('DoorDistance'),0,0),Vector3.new(seat:GetAttribute('DoorDistance')+2.8,0,0),Vector3.new(0,0,10)} do
  local door=seat.CFrame:PointToWorldSpace(offset)
  local wall=workspace:Raycast(seat.Position+Vector3.yAxis*2,door-seat.Position,params)
  local floor=workspace:Raycast(door+Vector3.yAxis*3,-Vector3.yAxis*10,params)
  if not wall and floor and floor.Normal.Y>.65 then
   local canOwn=root:CanSetNetworkOwnership()
   if canOwn then root:SetNetworkOwner(nil) end
   root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero
   char:PivotTo(CFrame.new(floor.Position+Vector3.yAxis*(human.HipHeight+root.Size.Y/2+.25))*seat.CFrame.Rotation*root.CFrame:ToObjectSpace(char:GetPivot()))
   if canOwn then
    task.delay(.15,function()
     if root.Parent and not human.SeatPart and root:CanSetNetworkOwnership() then root:SetNetworkOwnershipAuto() end
    end)
   end
   return
  end
 end
end
local handling=require(script.Parent.VehicleHandling)
local cars={}
for _,model in city:WaitForChild('Motor pool'):GetChildren() do
 local base=model.Chassis
 local seat=model.Driver
 local attachment=Instance.new('Attachment',base)
 local motion=Instance.new('LinearVelocity')
 motion.VelocityConstraintMode=Enum.VelocityConstraintMode.Plane
 motion.PrimaryTangentAxis=Vector3.xAxis; motion.SecondaryTangentAxis=Vector3.zAxis
 motion.MaxForce=120000; motion.Attachment0=attachment; motion.Parent=base
 local turn=Instance.new('AlignOrientation')
 turn.Mode=Enum.OrientationAlignmentMode.OneAttachment; turn.Attachment0=attachment
 turn.MaxTorque=220000; turn.Responsiveness=23; turn.CFrame=base.CFrame.Rotation; turn.Parent=base
 local _,yaw=base.CFrame:ToOrientation()
 local state={model=model,base=base,seat=seat,motion=motion,turn=turn,home=model:GetPivot(),homeYaw=yaw,yaw=yaw,speed=0,gas=0,steer=0,updated=0}
 model:SetAttribute('Fuel',100); state.fuelUsed=0; state.lastPosition=base.Position
 model:GetAttributeChangedSignal('Fuel'):Connect(function() if model:GetAttribute('Fuel')==100 then state.fuelUsed=0 end end)
 cars[seat]=state
 for _,p in model:GetChildren() do
  if p:IsA('BasePart') then
   if p~=base then
    local weld=Instance.new('WeldConstraint'); weld.Part0=base; weld.Part1=p; weld.Parent=p
    p.Massless=true
   end
   p.CollisionGroup='NorthsideVehicle';p.CanCollide=p==base or p.Name=='Tire'
   if p==seat then p.CanTouch=false end
   p.CustomPhysicalProperties=PhysicalProperties.new(.8,.18,0)
  end
 end
 for _,p in model:GetChildren() do if p:IsA('BasePart') then p.Anchored=false end end
 base:SetNetworkOwner(nil)
 local prompt=Instance.new('ProximityPrompt'); prompt.ActionText='Drive'; prompt.ObjectText=model.Name; prompt.RequiresLineOfSight=false; prompt.MaxActivationDistance=10; prompt.Parent=seat
 prompt.Triggered:Connect(function(player)
  local character=player.Character
  local human=character and character:FindFirstChildOfClass('Humanoid')
  local root=character and character:FindFirstChild('HumanoidRootPart')
  if human and root and human.Health>0 and not human.SeatPart and not seat.Occupant and (root.Position-seat.Position).Magnitude<=12 then seat:Sit(human) end
 end)
 local previousDriver
 local collisionGroups={}
 seat:GetPropertyChangedSignal('Occupant'):Connect(function()
  local human=seat.Occupant
  if previousDriver and previousDriver~=human then
   for part,group in collisionGroups do if part.Parent then part.CollisionGroup=group end end
   table.clear(collisionGroups)
   task.defer(exitAtDoor,seat,previousDriver)
  end
  previousDriver=human
  if human and human.Parent then
   for _,part in human.Parent:GetDescendants() do
    if part:IsA('BasePart') then collisionGroups[part]=part.CollisionGroup;part.CollisionGroup='NorthsideDriver' end
   end
   task.spawn(function()
    local weld=seat:WaitForChild('SeatWeld',2)
    if weld and seat.Occupant==human then alignDriver(seat,human) end
    task.wait(.45)
    if seat.Occupant==human then alignDriver(seat,human) end
   end)
  end
  state.gas=0; state.steer=0; state.brake=false;state.wheel=0;state.updated=0; prompt.Enabled=seat.Occupant==nil
  if base:CanSetNetworkOwnership() then base:SetNetworkOwner(nil) end
 end)
end
drive.OnServerEvent:Connect(function(player,gas,steer,brake)
 local human=player.Character and player.Character:FindFirstChildOfClass('Humanoid')
 local car=human and cars[human.SeatPart]
 if not car or car.seat.Occupant~=human or typeof(gas)~='number' or typeof(steer)~='number' then return end
 if not (math.abs(gas)<=1 and math.abs(steer)<=1) then return end
 local now=os.clock()
 if now-car.updated<.035 then return end
 car.gas=gas; car.steer=steer; car.brake=brake==true; car.updated=now
end)
run.Heartbeat:Connect(function(dt)
 for _,c in cars do
  local pos=c.base.Position
  if pos.Y< -12 or pos.X< -789 or pos.X>726 or pos.Z< -554 or pos.Z>1098 then
   if c.seat.Occupant then c.seat.Occupant.Sit=false end
   c.model:PivotTo(c.home); c.base.AssemblyLinearVelocity=Vector3.zero; c.base.AssemblyAngularVelocity=Vector3.zero
   c.speed=0; c.gas=0; c.steer=0; c.yaw=c.homeYaw; pos=c.base.Position; c.lastPosition=pos
  end
  if os.clock()-c.updated>.5 then c.gas=0; c.steer=0 end
  local fuel=c.model:GetAttribute('Fuel') or 0
  local delta=pos-c.lastPosition; c.lastPosition=pos
  local distance=Vector2.new(delta.X,delta.Z).Magnitude
  if c.seat.Occupant and fuel>0 and distance<=math.max(6,90*dt) then
   c.fuelUsed+=distance/60
   local used=math.floor(c.fuelUsed)
   if used>0 then
    c.fuelUsed-=used; fuel=math.max(0,fuel-used); c.model:SetAttribute('Fuel',fuel)
   end
  end
  local braking=c.brake or not c.seat.Occupant or os.clock()-c.updated>.5
  c.speed,c.wheel,c.yaw=handling.step(c.speed,c.wheel or 0,c.yaw,c.gas,c.steer,braking,fuel,dt)
  local heading=CFrame.Angles(0,c.yaw,0)
  c.turn.CFrame=heading
  -- Let the body turn before applying lateral thrust, including when a curb blocks yaw.
  local facing=c.base.CFrame.LookVector
  local planar=Vector2.new(facing.X,facing.Z)
  c.motion.PlaneVelocity=planar.Magnitude>.01 and planar.Unit*c.speed or Vector2.zero
 end
end)
