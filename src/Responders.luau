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
 local function request(p,role)
  if not calls[role] then return end
  if not valid(role,p) then return tell(p,role=='medic' and 'Treatment is available when you are injured.' or 'Police processing is available for a wanted character.') end
  if calls[role][p] then return tell(p,'Dispatch already has your call.') end
  calls[role][p]=os.clock()
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
   local patrol=false; local observed=nil; local observedAt=0
   while model.Parent do
    local at=model:GetPivot().Position; local target,best=nil,math.huge
    for _,p in Players:GetPlayers() do
     local root=p.Character and p.Character:FindFirstChild('HumanoidRootPart')
     if root and valid(role,p) then
      local dist=(at-root.Position).Magnitude
      if (calls[role][p] or dist<70) and dist<best then best=dist; target=p end
     end
    end
    local dest=home+Vector3.new(0,0,patrol and 24 or 0)
    if target and target.Character then dest=target.Character:GetPivot().Position end
    if not target or best>10 then observed=nil end
    if target and best<=10 then
     if observed~=target then observed=target; observedAt=os.clock() end
     local caught=role=='police' and profiles[target].Heat>=2 and os.clock()-observedAt>=4.5
     local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances={model}
     local goal=target.Character:GetPivot().Position
     local hit=workspace:Raycast(at,goal-at,params)
     local visible=not hit or hit.Instance:IsDescendantOf(target.Character)
     if visible and not settle(role,target,nil,caught) and role=='police' and (not model:GetAttribute('Spoke') or os.clock()>model:GetAttribute('Spoke')+12) then model:SetAttribute('Spoke',os.clock()); tell(target,'Officer nearby. Hands up to surrender.') end
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
        if target and (not target.Character or (target.Character:GetPivot().Position-dest).Magnitude>6 or (target.Character:GetPivot().Position-root.Position).Magnitude<9) then break end
       end
      end
     end
    else patrol=not patrol end
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