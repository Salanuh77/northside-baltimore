local Players=game:GetService('Players')
local Path=game:GetService('PathfindingService')
local function rig(name,home,medical,parent)
 local storage=game:GetService('ReplicatedStorage')
 local model=storage.ResidentRig:Clone()
 model.Name=name; model.Parent=parent
 require(storage.StreetStyle).apply(model,{Name=name,Height='Medium',Build='Average',Tone=medical and 'Copper' or 'Umber',Hair='Close crop',Starter=medical and 'Olive' or 'Harbor'})
 local health=model.Humanoid
 health.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.Viewer
 health.NameDisplayDistance=24;health.HealthDisplayDistance=0;health.WalkSpeed=12
 health.BreakJointsOnDeath=false
 if not medical then
  local cap=storage.ServiceCap:Clone()
  local head=model.Head
  local hair=head:FindFirstChild('Northside hair');if hair then hair:Destroy() end
  cap.Name='Service cap';cap.Size=head.Size*Vector3.new(.96,.59,1.24)
  cap.Color=Color3.fromRGB(45,57,75);cap.Material=Enum.Material.Fabric
  cap.Anchored=false;cap.CanCollide=false;cap.CanTouch=false;cap.CanQuery=false;cap.Massless=true
  cap.CFrame=head.CFrame*CFrame.new(0,head.Size.Y*.54,-head.Size.Z*.08);cap.Parent=model
  local join=Instance.new('WeldConstraint');join.Part0=head;join.Part1=cap;join.Parent=cap
 end
 local torso=model.UpperTorso
 local badge=Instance.new('Part'); badge.Name='Service badge'
 badge.Size=Vector3.new(.27,.32,.07);badge.Color=medical and Color3.fromRGB(236,242,240) or Color3.fromRGB(225,176,72)
 badge.CanCollide=false;badge.CanTouch=false;badge.Massless=true
 badge.CFrame=torso.CFrame*CFrame.new(torso.Size.X*.22,torso.Size.Y*.17,-torso.Size.Z*.49)
 badge.Parent=model
 local weld=Instance.new('WeldConstraint');weld.Part0=torso;weld.Part1=badge;weld.Parent=badge
 model:PivotTo(CFrame.new(home))
 for _,part in model:GetDescendants() do if part:IsA('BasePart') then part.Anchored=false end end
 model.HumanoidRootPart:SetNetworkOwner(nil)
 local animator=health:FindFirstChildOfClass('Animator') or Instance.new('Animator',health)
 task.spawn(function()
  local anim=Instance.new('Animation');anim.AnimationId='rbxassetid://507777826'
  local ok,walk=pcall(animator.LoadAnimation,animator,anim)
  if ok and model.Parent then
   walk.Looped=true; walk.Priority=Enum.AnimationPriority.Movement
   health.Running:Connect(function(speed)
    if speed>1 then if not walk.IsPlaying then walk:Play(.18) end; walk:AdjustSpeed(speed/13)
    elseif walk.IsPlaying then walk:Stop(.16) end
   end)
  end
 end)
 return model
end
return function(city,event,profiles,jobs,sync,tell,safe,near,sight,arrest)
 local field=Instance.new('Folder'); field.Name='Emergency responders'; field.Parent=workspace
 local calls={police={},medic={}}; local cooldown={}
 local function valid(role,p)
  local h=p.Character and p.Character:FindFirstChildOfClass('Humanoid')
  if not h or h.Health<=0 or not profiles[p] then return false end
  return role=='medic' and h.Health<h.MaxHealth-1 or role=='police' and profiles[p].Heat>=1 and not safe(p)
 end
 local function settle(role,target,responder,caught)
  if not valid(role,target) then return false end
  if role=='police' and not caught and not target:GetAttribute('Surrendered') then return false end
  if responder then
   local h=target.Character:FindFirstChild('HumanoidRootPart')
   if responder==target or not h or not near(responder,h.Position,12) or not sight(responder,h.Position,target.Character) then return false end
  end
  if role=='medic' then target.Character.Humanoid.Health=target.Character.Humanoid.MaxHealth; tell(target,'A paramedic treated you.')
  else
   if not arrest(target) then return false end
  end
  calls[role][target]=nil
  if responder then
   local last=cooldown[target] or {}; cooldown[target]=last
   if os.clock()>=(last[role] or 0) then
    last[role]=os.clock()+90; local pay=role=='medic' and 85 or 95; local d=profiles[responder]; d.Cash+=pay; d.Wages+=pay; sync(responder); tell(responder,'Dispatch complete • +$'..pay)
   end
  end
  return true
 end
 local function visible(model,character,range)
  local root=character and character:FindFirstChild('HumanoidRootPart')
  if not root then return false end
  local origin=model.HumanoidRootPart.Position+Vector3.yAxis
  local goal=root.Position+Vector3.yAxis
  if (goal-origin).Magnitude>range then return false end
  local ray=RaycastParams.new()
  ray.FilterType=Enum.RaycastFilterType.Exclude
  ray.FilterDescendantsInstances={model}
  ray.RespectCanCollide=true
  local hit=workspace:Raycast(origin,goal-origin,ray)
  return not hit or hit.Instance:IsDescendantOf(character)
 end
 local function request(p,role)
  if not calls[role] then return end
  if not valid(role,p) then return tell(p,role=='medic' and 'Treatment is available when you are injured.' or 'Police processing is available for a wanted character.') end
  if calls[role][p] then return tell(p,'Dispatch already has your call.') end
  if role=='medic' then
   for _,unit in field:GetChildren() do
    if unit:GetAttribute('Service')=='medic' and unit.Humanoid.Health>0 and visible(unit,p.Character,10) then
     settle(role,p,nil,false)
     return
    end
   end
  end
  calls[role][p]=p.Character:GetPivot().Position
  for _,other in Players:GetPlayers() do
   if other~=p and jobs[other] and jobs[other].role==role then tell(other,'Dispatch • '..p.DisplayName..' requested assistance. Open Phone → Dispatch.') end
  end
  tell(p,'Dispatch received your location.')
 end
 local function bot(role,home,name)
  local model=rig(name,home,role=='medic',field); model:SetAttribute('Service',role)
  local health=model.Humanoid
  health.HealthChanged:Connect(function(current)
   if current>0 or not model.Parent then return end
   model:Destroy(); task.delay(20,function() if field.Parent then bot(role,home,name) end end)
  end)
  task.spawn(function()
   local patrol=1;local observed=nil;local observedAt=0
   local route={Vector3.zero,Vector3.new(0,0,24),Vector3.new(0,0,42),Vector3.new(0,0,18)}
   local lastSeen={}
   local patrolSince=os.clock()
   while model.Parent do
    local at=model:GetPivot().Position;local target,best,goal=nil,math.huge,nil
    local now=os.clock()
    for p,memory in lastSeen do
     if not p.Parent or now-memory.time>10 then lastSeen[p]=nil end
    end
    for _,p in Players:GetPlayers() do
     local root=p.Character and p.Character:FindFirstChild('HumanoidRootPart')
     if root and valid(role,p) then
      local direct=visible(model,p.Character,70)
      if direct then lastSeen[p]={position=root.Position,time=now} end
      local memory=lastSeen[p]
      local call=calls[role][p]
      local known=direct and root.Position or memory and memory.position or call
      if known then
       local score=(known-at).Magnitude-(call and 24 or 0)
       if score<best then best=score;target=p;goal=known end
      end
     end
    end
    local dest=goal or home+route[patrol]
    local close=target and visible(model,target.Character,10)
    if not close then observed=nil end
    model:SetAttribute('Activity',target and (close and (role=='medic' and 'Treating patient' or 'Requesting surrender') or lastSeen[target] and now-lastSeen[target].time>.01 and 'Searching' or 'Responding') or 'Patrolling')
    health.WalkSpeed=target and role=='police' and 16 or 12
    if close then
     if observed~=target then observed=target; observedAt=os.clock() end
     local caught=role=='police' and profiles[target].Heat>=2 and os.clock()-observedAt>=4.5
     if not settle(role,target,nil,caught) and role=='police' and (not model:GetAttribute('Spoke') or os.clock()>model:GetAttribute('Spoke')+12) then model:SetAttribute('Spoke',os.clock()); tell(target,'Officer nearby. Hands up to surrender.') end
    elseif (dest-at).Magnitude>4 then
     local path=Path:CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=true})
     local ok=pcall(function() path:ComputeAsync(at,dest) end)
     if not model.Parent then break end
     if ok and path.Status==Enum.PathStatus.Success then
      local start=at
      for _,point in path:GetWaypoints() do
       if not model.Parent then return end
       local root=model.PrimaryPart
       local planar=(point.Position-root.Position)*Vector3.new(1,0,1)
       if planar.Magnitude>1.5 then
        if point.Action==Enum.PathWaypointAction.Jump then health.Jump=true end
        health:MoveTo(point.Position)
        local deadline=os.clock()+math.min(3,planar.Magnitude/health.WalkSpeed+1)
        repeat task.wait(.10) until not model.Parent or os.clock()>=deadline or ((point.Position-root.Position)*Vector3.new(1,0,1)).Magnitude<1.6
        if not model.Parent then return end
        if os.clock()>=deadline or (root.Position-start).Magnitude>=14 then break end
        if target and (not target.Character or visible(model,target.Character,10)) then break end
       end
      end
     elseif not target and os.clock()-patrolSince>5 then
      patrol=patrol%#route+1;patrolSince=os.clock()
     end
     path:Destroy()
    elseif target then
     if not visible(model,target.Character,70) then calls[role][target]=nil;lastSeen[target]=nil end
    else patrol=patrol%#route+1;patrolSince=os.clock() end
    task.wait(target and .55 or 1.6)
   end
  end)
 end
 bot('police',Vector3.new(-26,3.8,87),'District officer'); bot('medic',Vector3.new(26,3.8,135),'City paramedic')
 bot('police',Vector3.new(-426,3.8,740),'Westside officer'); bot('medic',Vector3.new(217,3.8,838),'Downtown paramedic')
 Players.PlayerRemoving:Connect(function(p) calls.police[p]=nil; calls.medic[p]=nil; cooldown[p]=nil end)
 return function(p,kind,data)
  if kind=='CallResponder' then return request(p,data.Role) end
  local job=jobs[p]; local role=job and job.role
  if role~='medic' and role~='police' then return tell(p,'Start a police or paramedic shift first.') end
  if kind=='DispatchList' then
   local list={}
   for _,target in Players:GetPlayers() do if target~=p and valid(role,target) and (calls[role][target] or role=='police') then table.insert(list,{Id=target.UserId,Name=target.DisplayName,Position=target.Character:GetPivot().Position}) end end
   event:FireClient(p,'DispatchList',list)
  elseif kind=='Assist' and type(data.Target)=='number' and data.Target%1==0 then
   local target=Players:GetPlayerByUserId(data.Target)
   if target and not settle(role,target,p) then tell(p,'Move beside the eligible patient or surrendered wanted player.') end
  end
 end
end