-- Temporary physical knockdowns and persistent death poses for the game's R15 rigs.
local Run=game:GetService('RunService')
local Players=game:GetService('Players')
local Ragdoll={}
local active={}
local watched=setmetatable({},{__mode='k'})
local function restore(model,s)
 active[model]=nil
 for _,v in s.created do v:Destroy() end
 for _,v in s.joints do if v.joint.Parent then v.joint.Enabled=v.enabled end end
 for part,value in s.collision do if part.Parent then part.CanCollide=value end end
 if not model.Parent then return end
 local h=s.human;h.RequiresNeck=s.neck;h.PlatformStand=s.platform;h.AutoRotate=s.rotate
 model:SetAttribute('Ragdolled',nil)
 if h.Health>0 then
  local root=model:FindFirstChild('HumanoidRootPart')
  if root then
   local look=root.CFrame.LookVector*Vector3.new(1,0,1)
   if look.Magnitude<.1 then look=Vector3.new(0,0,-1) end
   local frame=CFrame.lookAt(root.Position+Vector3.yAxis*.6,root.Position+Vector3.yAxis*.6+look)
   model:PivotTo(frame*root.CFrame:ToObjectSpace(model:GetPivot()))
   root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero
   if Players:GetPlayerFromCharacter(model) then pcall(function() root:SetNetworkOwnershipAuto() end) end
  end
  h:ChangeState(Enum.HumanoidStateType.GettingUp)
 end
end
function Ragdoll.apply(model,duration,direction)
 local human=model:FindFirstChildOfClass('Humanoid');local root=model:FindFirstChild('HumanoidRootPart')
 if not human or not root or not model.Parent or model:GetAttribute('Resting') then return false end
 local untilTime=os.clock()+math.clamp(duration or 2.3,.2,5)
 if active[model] then active[model].untilTime=math.max(active[model].untilTime,untilTime);return true end
 local s={human=human,untilTime=untilTime,created={},joints={},collision={},neck=human.RequiresNeck,rotate=human.AutoRotate,platform=human.PlatformStand}
 active[model]=s;human.RequiresNeck=false;human.BreakJointsOnDeath=false;human.Sit=false
 human.AutoRotate=false;human.PlatformStand=true
 local bodies={}
 for _,joint in model:GetDescendants() do
  if joint:IsA('Motor6D') and joint.Part0 and joint.Part1 and joint.Part0.Name~='HumanoidRootPart' and joint.Part1.Name~='HumanoidRootPart' then
   local a=Instance.new('Attachment');a.Name='Ragdoll joint';a.CFrame=joint.C0;a.Parent=joint.Part0
   local b=Instance.new('Attachment');b.Name='Ragdoll joint';b.CFrame=joint.C1;b.Parent=joint.Part1
   local socket=Instance.new('BallSocketConstraint');socket.Name='Knockdown socket';socket.Attachment0=a;socket.Attachment1=b
   socket.LimitsEnabled=true;socket.UpperAngle=joint.Name=='Neck' and 25 or 55
   socket.TwistLimitsEnabled=true;socket.TwistLowerAngle=-35;socket.TwistUpperAngle=35;socket.MaxFrictionTorque=8;socket.Parent=joint.Parent
   table.insert(s.joints,{joint=joint,enabled=joint.Enabled});joint.Enabled=false
   for _,item in {a,b,socket} do table.insert(s.created,item) end
  end
 end
 for _,part in model:GetChildren() do
  if part:IsA('BasePart') then
   s.collision[part]=part.CanCollide
   if part~=root then part.CanCollide=true;table.insert(bodies,part) else part.CanCollide=false end
  end
 end
 for i=1,#bodies do for j=i+1,#bodies do
  local no=Instance.new('NoCollisionConstraint');no.Part0=bodies[i];no.Part1=bodies[j];no.Parent=root;table.insert(s.created,no)
 end end
 model:SetAttribute('Ragdolled',true)
 root.Anchored=false;pcall(function() root:SetNetworkOwner(nil) end)
 human:ChangeState(Enum.HumanoidStateType.Physics)
 if direction and direction.Magnitude>.01 then root:ApplyImpulse((direction.Unit*12+Vector3.yAxis*3)*root.AssemblyMass) end
 return true
end
function Ragdoll.watch(model)
 if watched[model] then return end;watched[model]=true
 local h=model:FindFirstChildOfClass('Humanoid');if not h then return end
 h.BreakJointsOnDeath=false
 h.Died:Connect(function() Ragdoll.apply(model,5) end)
 model.Destroying:Connect(function() if active[model] then restore(model,active[model]) end;watched[model]=nil end)
end
Run.Heartbeat:Connect(function()
 for model,s in active do
  if not model.Parent or (s.human.Health>0 and os.clock()>=s.untilTime) then restore(model,s) end
 end
end)
return Ragdoll
