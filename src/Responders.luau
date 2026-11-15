local Players=game:GetService('Players')
local Path=game:GetService('PathfindingService')
local function rig(name,home,medical,parent)
 local model=Instance.new('Model'); model.Name=name; model.Parent=parent
 local uniform=medical and Color3.fromRGB(46,116,116) or Color3.fromRGB(38,56,82)
 local function part(name,size,offset,color)
  local p=Instance.new('Part'); p.Name=name; p.Size=size; p.CFrame=CFrame.new(home+offset); p.Anchored=true; p.CanCollide=false; p.CanQuery=name~='HumanoidRootPart'; p.CanTouch=false; p.Color=color; p.Parent=model; return p
 end
 local root=part('HumanoidRootPart',Vector3.one,Vector3.zero,uniform); root.Transparency=1; model.PrimaryPart=root
 local head=part('Head',Vector3.new(1.6,1.4,1.4),Vector3.new(0,1.72,0),Color3.fromRGB(158,116,86))
 local face=Instance.new('Decal'); face.Texture='rbxasset://textures/face.png'; face.Parent=head
 part('Uniform',Vector3.new(2.2,2,1.15),Vector3.zero,uniform)
 part('Cap',Vector3.new(1.7,.4,1.8),Vector3.new(0,2.43,-.12),uniform)
 part('Badge',Vector3.new(.42,.48,.16),Vector3.new(.55,.5,-.61),medical and Color3.fromRGB(246,242,218) or Color3.fromRGB(243,198,91))
 for _,s in {-1,1} do
  part('Arm',Vector3.new(.65,1.85,.8),Vector3.new(s*1.43,0,0),uniform)
  part('Trouser leg',Vector3.new(.85,2,1),Vector3.new(s*.53,-1.95,0),Color3.fromRGB(40,49,59))
 end
 local title=Instance.new('BillboardGui'); title.Size=UDim2.fromOffset(135,24); title.StudsOffset=Vector3.new(0,2,0); title.MaxDistance=42; title.Parent=head
 local label=Instance.new('TextLabel'); label.Size=UDim2.fromScale(1,1); label.BackgroundTransparency=.25; label.BackgroundColor3=uniform; label.TextColor3=Color3.new(1,1,1); label.Text=name; label.TextSize=13; label.Parent=title
 local health=Instance.new('Humanoid'); health.RequiresNeck=false; health.BreakJointsOnDeath=false; health.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None; health.Parent=model
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
      local budget=target and 45 or 14
      for _,point in path:GetWaypoints() do
       local pos=model:GetPivot().Position; local waypoint=point.Position+Vector3.new(0,3,0)
       local delta=waypoint-pos; local horizontal=Vector3.new(delta.X,0,delta.Z)
       if horizontal.Magnitude>.6 then
        local length=math.min(delta.Magnitude,budget); local steps=math.max(1,math.ceil(length/1.65))
        for k=1,steps do if not model.Parent then return end; local q=pos+delta.Unit*(length*k/steps); model:PivotTo(CFrame.lookAt(q,q+horizontal.Unit)); task.wait(.09) end
        budget-=length
       end
       if budget<=.1 then break end
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