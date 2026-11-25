local Players=game:GetService('Players')
local Brain=require(script.Parent.ResponderBrain)
local Navigation=require(script.Parent.NpcNavigation)
local Awareness=require(script.Parent.NpcAwareness)
local Tactics=require(script.Parent.NpcTactics)
local Ground=require(script.Parent.NpcGround)
local Sight=require(script.Parent.NpcSight)
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
return function(city,event,profiles,jobs,sync,tell,safe,near,sight,arrest,addHeat,melee)
 local field=Instance.new('Folder');field.Name='Emergency responders';field.Parent=workspace
 local calls={police={},medic={}};local cooldown={};local reports={};local units={}
 local random=Random.new()
 local function valid(role,p)
  local h=p.Character and p.Character:FindFirstChildOfClass('Humanoid')
  if not h or h.Health<=0 or not profiles[p] or (p:GetAttribute('CustodyUntil') or 0)>0 then return false end
  return role=='medic' and h.Health<h.MaxHealth-1 or role=='police' and profiles[p].Heat>=1 and not safe(p)
 end
 local function visible(model,character,range,focused)
  local root=character and character:FindFirstChild('HumanoidRootPart')
  if not root or not model.Parent then return false end
  local head=model.Head;local delta=root.Position+Vector3.yAxis-head.Position
  if delta.Magnitude>range then return false end
  if not Awareness.inView(delta.Magnitude,delta.Magnitude>.01 and head.CFrame.LookVector:Dot(delta.Unit) or 1,focused) then return false end
  local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Exclude;ray.FilterDescendantsInstances={model};ray.RespectCanCollide=true
  local hit=workspace:Raycast(head.Position,delta,ray)
  return not hit or hit.Instance:IsDescendantOf(character)
 end
 local function settle(role,target,responder,caught)
  if not valid(role,target) then return false end
  if role=='police' and not caught and not target:GetAttribute('Surrendered') then return false end
  if responder then
   local root=target.Character:FindFirstChild('HumanoidRootPart')
   if responder==target or not root or not near(responder,root.Position,8) or not sight(responder,root.Position,target.Character) then return false end
  end
  if role=='medic' then target.Character.Humanoid.Health=target.Character.Humanoid.MaxHealth;tell(target,'A paramedic treated you.')
  elseif not arrest(target) then return false end
  calls[role][target]=nil;reports[target]=nil
  if responder then
   local last=cooldown[target] or {};cooldown[target]=last
   if os.clock()>=(last[role] or 0) then
    last[role]=os.clock()+90;local pay=role=='medic' and 85 or 95;local d=profiles[responder]
    d.Cash+=pay;d.Wages+=pay;sync(responder);tell(responder,'Dispatch complete • +$'..pay)
   end
  end
  return true
 end
 local function request(p,role)
  if not calls[role] then return end
  if not valid(role,p) then return tell(p,role=='medic' and 'Treatment is available when you are injured.' or 'Police processing is available for a wanted character.') end
  if calls[role][p] then return tell(p,'Dispatch already has your call.') end
  calls[role][p]={position=p.Character:GetPivot().Position,time=os.clock()}
  for _,other in Players:GetPlayers() do
   if other~=p and jobs[other] and jobs[other].role==role then tell(other,'Dispatch • '..p.DisplayName..' requested assistance. Open Phone → Dispatch.') end
  end
  tell(p,'Dispatch received your location.')
 end
 local function warnClerks(origin,suspect)
  local witnessed=false
  for _,clerk in game:GetService('CollectionService'):GetTagged('RouteClerk') do
   local root=clerk:FindFirstChild('HumanoidRootPart')
   if not root then continue end
   local seen=suspect and visible(clerk,suspect.Character,45,false)
   if seen or (root.Position-origin).Magnitude<85 then clerk:SetAttribute('AlarmUntil',os.clock()+9) end
   witnessed=witnessed or seen==true
  end
  return witnessed
 end
 -- Only validated server attacks can call this; there is no client alert remote.
 local function alert(p,origin,kind,victim)
  if not profiles[p] or safe(p) then return end
  local now=os.clock();local witnessed=false
  for _,unit in units do
   if unit.model.Parent and unit.model.Humanoid.Health>0 then
    local distance=(unit.model.HumanoidRootPart.Position-origin).Magnitude
    if (kind=='gunfire' and distance<100) or (distance<55 and visible(unit.model,p.Character,55,false)) or victim==unit.model then
     unit.danger={position=origin,untilTime=now+7}
     if unit.role=='police' then witnessed=true end
    end
   end
  end
  if kind=='gunfire' then witnessed=warnClerks(origin,p) or witnessed
  else
   for _,clerk in game:GetService('CollectionService'):GetTagged('RouteClerk') do
    if clerk.Parent and visible(clerk,p.Character,45,false) then clerk:SetAttribute('AlarmUntil',now+9);witnessed=true end
   end
  end
  if witnessed then
   local previous=reports[p]
   reports[p]={position=origin,time=now,seenAt=previous and previous.seenAt,violentUntil=kind=='robbery' and (previous and previous.violentUntil or 0) or now+12}
   if addHeat and (not previous or now-previous.time>6) then addHeat(p,1) end
  end
 end
 local function cover(unit,threat)
  local root=unit.model.HumanoidRootPart
  local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Exclude;ray.FilterDescendantsInstances={unit.model};ray.RespectCanCollide=true
  local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Exclude;overlap.FilterDescendantsInstances={unit.model};overlap.RespectCanCollide=true
  for i=0,7 do
   local a=i*math.pi/4;local candidate=root.Position+Vector3.new(math.cos(a)*9,0,math.sin(a)*9)
   local ground=workspace:Raycast(candidate+Vector3.new(0,4,0),Vector3.new(0,-12,0),ray)
   if ground and ground.Normal.Y>.7 then
    candidate=ground.Position+Vector3.new(0,3,0)
    local obstruction=workspace:Raycast(threat+Vector3.yAxis,candidate-(threat+Vector3.yAxis),ray)
    if obstruction and (obstruction.Position-candidate).Magnitude<5 and #workspace:GetPartBoundsInBox(CFrame.new(candidate),Vector3.new(3,4,3),overlap)==0 then return candidate end
   end
  end
 end
 local combat=require(script.Parent.NpcCombat)
 local function sceneGunfire(origin)
  warnClerks(origin)
  for _,unit in units do
   if unit.role=='medic' and unit.model.Parent and (unit.model.HumanoidRootPart.Position-origin).Magnitude<100 then
    unit.danger={position=origin,untilTime=os.clock()+7}
   end
  end
 end
 local function shoot(unit,target) return combat(unit,target,valid,safe,visible,event,random,sceneGunfire) end

 local function bot(role,home,name)
  local model=rig(name,home,role=='medic',field);model:SetAttribute('Service',role)
  require(script.Parent.Ragdoll).watch(model);game:GetService('CollectionService'):AddTag(model,'CombatActor')
  local unit={model=model,role=role,brain=Brain.new(),memory={},patrol=1,patrolAt=os.clock(),nextCover=0,side=math.floor(#units/2)%2==0 and 1 or -1,sector=#units}
  unit.nav=Navigation.new(model);table.insert(units,unit)
  local health=model.Humanoid
  local facingAnchor=Instance.new('Attachment');facingAnchor.Name='Responder facing';facingAnchor.Parent=model.HumanoidRootPart
  local facing=Instance.new('AlignOrientation');facing.Name='Aim facing';facing.Attachment0=facingAnchor
  facing.Mode=Enum.OrientationAlignmentMode.OneAttachment;facing.MaxTorque=60000;facing.MaxAngularVelocity=5
  facing.Responsiveness=12;facing.Enabled=false;facing.Parent=model.HumanoidRootPart
  local arm=model:FindFirstChild('RightShoulder',true)
  if arm and not arm:IsA('Motor6D') then arm=nil end
  local armRest=arm and arm.C0
  if role=='police' then
   local tool=Instance.new('Tool');tool.Name='Service pistol';tool.CanBeDropped=false
   local handle=Instance.new('Part');handle.Name='Handle';handle.CanCollide=false;handle.Massless=true;handle.Parent=tool
   require(script.Parent.PistolVisual)(tool,'Slate compact')
   health:EquipTool(tool);unit.weapon=tool
  end
  health.HealthChanged:Connect(function(current)
   if current>0 or not model.Parent then return end
   unit.nav:stop();task.delay(12,function() model:Destroy() end)
   local index=table.find(units,unit);if index then table.remove(units,index) end
   task.delay(20,function() if field.Parent then bot(role,home,name) end end)
  end)
  task.spawn(function()
   local route={Vector3.zero,Vector3.new(0,0,24),Vector3.new(0,0,42),Vector3.new(0,0,18)}
   while model.Parent and health.Health>0 do
    if model:GetAttribute('Ragdolled') or model:GetAttribute('CombatState')=='Stunned' then
     unit.nav:stop();facing.Enabled=false;task.wait(.2);continue
    end
    local now=os.clock();local at=model.HumanoidRootPart.Position
    local target,best,goal,direct=nil,math.huge,nil,false
    for _,p in Players:GetPlayers() do
     if valid(role,p) then
      local broadcast=reports[p]
      local seen=visible(model,p.Character,70,unit.target==p or (broadcast and now-broadcast.time<12))
      if seen then
       local position=p.Character.HumanoidRootPart.Position;unit.memory[p]={position=position,time=now}
       if role=='police' then
        local previous=reports[p];reports[p]={position=position,time=now,seenAt=now,violentUntil=previous and previous.violentUntil or 0}
        profiles[p].HeatNext=now+30
       end
      end
      local memory=unit.memory[p];local report=role=='police' and reports[p];local call=calls[role][p]
      local known=Awareness.contact(now,memory,report,call)
      if known then
       local score=(known.position-at).Magnitude-(unit.target==p and 18 or 0)-(seen and 12 or 0)
       if score<best then target=p;best=score;goal=known.position;direct=seen end
      end
     else unit.memory[p]=nil end
    end
    if unit.target~=target then
     unit.footworkAt=0;unit.footworkThreat=nil;unit.searchCenter=nil;unit.searchStep=0;unit.nextCover=0;unit.cover=nil
    end
    unit.target=target
    local action={mode='Patrolling',goal=home+route[unit.patrol]}
    if role=='police' and target then
     local human=target.Character.Humanoid;local root=target.Character.HumanoidRootPart
     local report=reports[target]
     local armed=target.Character:FindFirstChild('Pistol') or target.Character:FindFirstChild('Knife') or target.Character:FindFirstChild('Bat')
     local threat=armed and report and (report.violentUntil or 0)>now
     local clearShot=direct and threat and Sight.clearShot(model,target.Character)
     action=Brain.step(unit.brain,now,{id=target.UserId,valid=true,visible=direct,distance=(root.Position-at).Magnitude,surrendered=target:GetAttribute('Surrendered'),health=human.Health,ownHealth=health.Health,speed=root.AssemblyLinearVelocity.Magnitude,threat=threat,goal=goal,clearShot=clearShot})
     if action.mode=='Searching' then
      -- A search uses a frozen report location, never the hidden character position.
      if not unit.searchCenter or (unit.searchCenter-goal).Magnitude>4 then
       unit.searchCenter=goal;unit.searchStep=0;unit.searchAt=now+2
      end
      if (at-goal).Magnitude<5 or unit.searchStep>0 then
       if now>=unit.searchAt then unit.searchStep+=1;unit.searchAt=now+2.2 end
       action.goal=Ground.choose(model,{Tactics.search(unit.searchCenter,unit.searchStep,unit.sector)},false) or goal
      end
     else unit.searchCenter=nil;unit.searchStep=0 end
     if action.arrest and settle(role,target,nil,true) then action={mode='Patrolling',goal=home} end
     if action.fire then shoot(unit,target) end
     if melee and not armed and report and (report.violentUntil or 0)>now and direct and (root.Position-at).Magnitude<5 and not target:GetAttribute('Surrendered') then
      -- An active unarmed assault gets a bounded nonlethal response, not gunfire.
      if unit.weapon and unit.weapon.Parent==model then unit.weapon.Parent=game.ServerStorage end
      local delta=(root.Position-at)*Vector3.new(1,0,1)
      if delta.Magnitude>.1 then model.HumanoidRootPart.CFrame=model.HumanoidRootPart.CFrame:Lerp(CFrame.lookAt(at,at+delta),.55) end
      melee:guard(model,target.Character:GetAttribute('CombatState')=='Attacking')
      if now>=(unit.punchAt or 0) then melee:attack(model);unit.punchAt=now+1.2 end
      action={mode='Restraining attacker'}
     elseif melee then
      melee:guard(model,false)
      if unit.weapon and unit.weapon.Parent~=model then health:EquipTool(unit.weapon) end
     end
     if action.mode=='Requesting surrender' and direct and now>=(unit.spokeAt or 0) then unit.spokeAt=now+12;tell(target,'Police: put your hands up to surrender, or break line of sight to lose the search.') end
    elseif role=='medic' and unit.danger and now<unit.danger.untilTime then
     if now>=(unit.fleeAt or 0) then
      unit.fleeAt=now+1.6;unit.fleeGoal=Ground.choose(model,Tactics.flee(at,unit.danger.position),true)
     end
     action={mode='Waiting for a safe scene',goal=unit.fleeGoal};unit.treatAt=nil
    elseif role=='medic' and target then
     action={mode=direct and 'Responding' or 'Searching for patient',goal=goal}
     if direct and (goal-at).Magnitude<6 then
      action.mode='Treating patient';action.goal=nil
      if unit.patient~=target then unit.patient=target;unit.treatAt=nil end
      unit.treatAt=unit.treatAt or now
      if now-unit.treatAt>=2.5 then settle(role,target,nil,false);unit.treatAt=nil end
     else unit.treatAt=nil end
    else
     Brain.step(unit.brain,now,{valid=false});unit.treatAt=nil
     if (action.goal-at).Magnitude<3 or now-unit.patrolAt>15 then unit.patrol=unit.patrol%#route+1;unit.patrolAt=now end
    end
    local aiming=action.mode=='Engaging'
    if unit.weapon then
     for _,piece in unit.weapon:GetChildren() do if piece:IsA('BasePart') then piece.Transparency=aiming and piece.Name~='Handle' and 0 or 1 end end
    end
    if arm then arm.C0=armRest*(aiming and CFrame.Angles(math.rad(65),0,0) or CFrame.new()) end
    if action.cover and goal then
     if now>=unit.nextCover then
      unit.nextCover=now+2;unit.cover=cover(unit,goal) or Ground.choose(model,Tactics.ranged(at,goal,unit.side,true),true)
     end
     action.goal=unit.cover
    elseif aiming and direct and goal then
     if now>=(unit.footworkAt or 0) or not unit.footworkThreat or (goal-unit.footworkThreat).Magnitude>6 then
      unit.footworkAt=now+1.8;unit.footworkThreat=goal
      unit.footwork=Ground.choose(model,Tactics.ranged(at,goal,unit.side,false),true)
      unit.side=-unit.side
     end
     action.goal=unit.footwork
    else unit.footwork=nil;unit.footworkAt=0 end
    local direction=aiming and direct and goal and (goal-at)*Vector3.new(1,0,1)
    facing.Enabled=direction~=nil and direction~=false and direction.Magnitude>.1
    health.AutoRotate=not facing.Enabled
    if facing.Enabled then facing.CFrame=CFrame.lookAt(Vector3.zero,direction) end
    if not aiming then unit.footworkThreat=nil end
    if not action.goal then
     model:SetAttribute('NavigationGoal',nil)
    else
     model:SetAttribute('NavigationGoal',action.goal)
    end
    model:SetAttribute('Activity',action.mode);model:SetAttribute('Magazine',unit.brain.ammo)
    if action.goal then unit.nav:step(action.goal,now,aiming and 9 or target and role=='police' and 16 or unit.danger and now<unit.danger.untilTime and 15 or 11) else unit.nav:stop() end
    task.wait(.2)
   end
   unit.nav:stop()
  end)
 end
 bot('police',Vector3.new(-26,3.8,87),'District officer');bot('medic',Vector3.new(26,3.8,135),'City paramedic')
 bot('police',Vector3.new(-426,3.8,740),'Westside officer');bot('medic',Vector3.new(217,3.8,838),'Downtown paramedic')
 task.spawn(function()
  while field.Parent do
   local now=os.clock()
   for _,p in Players:GetPlayers() do
    local report=reports[p]
    p:SetAttribute('PoliceContact',valid('police',p) and Awareness.status(now,report) or '')
    if report and now-report.time>45 then reports[p]=nil end
    for _,role in {'medic','police'} do local call=calls[role][p];if call and now-call.time>45 then calls[role][p]=nil end end
   end
   task.wait(.5)
  end
 end)
 Players.PlayerRemoving:Connect(function(p)
  calls.police[p]=nil;calls.medic[p]=nil;cooldown[p]=nil;reports[p]=nil
  for _,unit in units do unit.memory[p]=nil end
 end)
 local function handle(p,kind,data)
  if kind=='CallResponder' then return request(p,data.Role) end
  local job=jobs[p];local role=job and job.role
  if role~='medic' and role~='police' then return tell(p,'Start a police or paramedic shift first.') end
  if kind=='DispatchList' then
   local list={};local now=os.clock()
   for _,target in Players:GetPlayers() do
    local known=Awareness.contact(now,nil,role=='police' and reports[target],calls[role][target])
    if target~=p and valid(role,target) and known and now-known.time<45 then table.insert(list,{Id=target.UserId,Name=target.DisplayName,Position=known.position}) end
   end
   event:FireClient(p,'DispatchList',list)
  elseif kind=='Assist' and type(data.Target)=='number' and data.Target%1==0 then
   local target=Players:GetPlayerByUserId(data.Target)
   if target and not settle(role,target,p) then tell(p,'Move beside the eligible patient or surrendered wanted player.') end
  end
 end
 local function witness(p,position)
  if not profiles[p] or safe(p) or typeof(position)~='Vector3' then return end
  local previous=reports[p]
  -- Preserve fresher direct sightings rather than overwriting them with a witness snapshot.
  if previous and os.clock()-previous.time<3 then return end
  reports[p]={position=position,time=os.clock(),violentUntil=0}
  if addHeat and profiles[p].Heat<1 then addHeat(p,1) end
 end
 return {handle=handle,alert=alert,witness=witness}
end
