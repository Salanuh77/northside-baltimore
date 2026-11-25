local Players=game:GetService('Players')
local Run=game:GetService('RunService')
local Rules=require(script.Parent.StreetCombatRules)
local Ragdoll=require(script.Parent.Ragdoll)
local Combat={};Combat.__index=Combat
function Combat.new(event,policy)
 local self=setmetatable({states={},event=event,policy=policy},Combat)
 local elapsed=0
 self.connection=Run.Heartbeat:Connect(function(dt)
  elapsed+=dt;if elapsed<.1 then return end;elapsed=0
  local now=workspace:GetServerTimeNow()
  for model,s in self.states do
   if not model.Parent then self.states[model]=nil;continue end
   Rules.update(s,now)
   if s.phase=='Blocking' and now>(s.guardUntil or 0) then Rules.guard(s,now,false) end
   if not self:eligible(model) and not model:GetAttribute('Ragdolled') then Rules.cancel(s,now) end
   self:publish(model,s)
  end
 end)
 return self
end
function Combat:eligible(model)
 local h=model and model:FindFirstChildOfClass('Humanoid');local root=model and model:FindFirstChild('HumanoidRootPart')
 if not h or h.Health<=0 or not root or h.SeatPart or model:GetAttribute('Resting') or model:GetAttribute('Ragdolled') then return false end
 local tool=model:FindFirstChildOfClass('Tool');if tool and tool.Name~='Fists' then return false end
 return not self.policy.allowed or self.policy.allowed(model)
end
function Combat:state(model)
 local s=self.states[model]
 if not s then
  s=Rules.new(workspace:GetServerTimeNow());self.states[model]=s;Ragdoll.watch(model)
  game:GetService('CollectionService'):AddTag(model,'CombatActor')
 end
 return s
end
function Combat:publish(model,s)
 model:SetAttribute('CombatState',s.phase);model:SetAttribute('CombatStamina',math.floor(s.stamina))
 if s.phase~='Idle' then
  local h=model:FindFirstChildOfClass('Humanoid')
  if h then s.oldSpeed=s.oldSpeed or h.WalkSpeed;h.WalkSpeed=s.phase=='Blocking' and 8 or s.phase=='Attacking' and 10 or 0 end
 elseif s.oldSpeed then
  local h=model:FindFirstChildOfClass('Humanoid');local p=Players:GetPlayerFromCharacter(model)
  if h then h.WalkSpeed=p and p:GetAttribute('Surrendered') and 5 or s.oldSpeed end;s.oldSpeed=nil
 end
end
function Combat:guard(model,enabled)
 if type(enabled)~='boolean' then return false end
 local s=self:state(model);local now=workspace:GetServerTimeNow()
 if enabled and not self:eligible(model) then return false end
 local ok=Rules.guard(s,now,enabled);if ok then s.guardUntil=now+.85;self:publish(model,s) end
 return ok
end
function Combat:cancel(model)
 local s=self.states[model];if s then Rules.cancel(s,workspace:GetServerTimeNow());self:publish(model,s) end
end
function Combat:attack(model)
 if not self:eligible(model) then return false end
 local s=self:state(model);local now=workspace:GetServerTimeNow();local attack=Rules.attack(s,now)
 if not attack then return false end
 model:SetAttribute('CombatStarted',now);model:SetAttribute('CombatCombo',attack.combo);self:publish(model,s)
 task.delay(attack.windup,function()
  if not self:eligible(model) or self.states[model]~=s or s.serial~=attack.serial then return end
  local root=model.HumanoidRootPart
  local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Exclude;overlap.FilterDescendantsInstances={model};overlap.MaxParts=100
  local targets={};local seen={}
  for _,part in workspace:GetPartBoundsInBox(root.CFrame*CFrame.new(0,0,-2.8),Vector3.new(4.5,5,5),overlap) do
   local target=part:FindFirstAncestorOfClass('Model')
   if target and target~=model and not seen[target] and target:FindFirstChildOfClass('Humanoid') and target:FindFirstChild('HumanoidRootPart') then
    seen[target]=true;table.insert(targets,target)
   end
  end
  table.sort(targets,function(a,b) return (a.HumanoidRootPart.Position-root.Position).Magnitude<(b.HumanoidRootPart.Position-root.Position).Magnitude end)
  for _,target in targets do
   local other=target.HumanoidRootPart;local delta=other.Position-root.Position
   if target.Humanoid.Health<=0 or target:GetAttribute('Ragdolled') or delta.Magnitude>5.8 or delta.Magnitude<.1 or root.CFrame.LookVector:Dot(delta.Unit)<.15 then continue end
   if self.policy.canDamage and not self.policy.canDamage(model,target) then continue end
   local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Exclude;ray.FilterDescendantsInstances={model}
   local hit=workspace:Raycast(root.Position+Vector3.yAxis,other.Position+Vector3.yAxis-root.Position-Vector3.yAxis,ray)
   if hit and not hit.Instance:IsDescendantOf(target) then continue end
   local defender=self:state(target);local frontal=other.CFrame.LookVector:Dot(-delta.Unit)>.25
   local result=Rules.hit(defender,workspace:GetServerTimeNow(),attack.damage,frontal,attack.knockdown)
   target:SetAttribute('CombatHitAt',workspace:GetServerTimeNow());target:SetAttribute('CombatHitBlocked',result.blocked)
   self:publish(target,defender);target.Humanoid:TakeDamage(result.damage)
   if result.knockdown then Ragdoll.apply(target,2.3,delta) end
   if self.policy.incident then self.policy.incident(model,target,result) end
   self.event:FireAllClients('MeleeImpact',{Target=target,Blocked=result.blocked,Broken=result.broken,Position=other.Position})
   break -- one victim per swing, even with overlapping characters or accessories
  end
 end)
 return true
end
return Combat
