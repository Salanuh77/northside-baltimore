local Players=game:GetService('Players')
local Storage=game:GetService('ReplicatedStorage')
local Tags=game:GetService('CollectionService')
local Brain=require(script.Parent.CivilianBrain)
local Navigation=require(script.Parent.NpcNavigation)
local Ground=require(script.Parent.NpcGround)
local Tactics=require(script.Parent.NpcTactics)
local Ragdoll=require(script.Parent.Ragdoll)
local Routes=require(script.Parent.CivilianRoutes)
local Phases=require(script.Parent.TrafficPhases)
local Civilians={}
local function visible(model,character,range)
 local root=character and character:FindFirstChild('HumanoidRootPart');if not root then return false end
 local origin=model.Head.Position;local delta=root.Position+Vector3.yAxis-origin
 if delta.Magnitude>range or (delta.Magnitude>9 and model.HumanoidRootPart.CFrame.LookVector:Dot(delta.Unit)<-.1) then return false end
 local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Exclude;ray.FilterDescendantsInstances={model};ray.RespectCanCollide=true
 local hit=workspace:Raycast(origin,delta,ray)
 return not hit or hit.Instance:IsDescendantOf(character)
end
local function say(model,text,now)
 if now<(model:GetAttribute('SpeechReady') or 0) then return end
 model:SetAttribute('SpeechReady',now+4)
 local old=model.Head:FindFirstChild('Citizen speech');if old then old:Destroy() end
 local gui=Instance.new('BillboardGui');gui.Name='Citizen speech';gui.Size=UDim2.fromOffset(230,64);gui.StudsOffset=Vector3.new(0,2.2,0);gui.MaxDistance=42;gui.Parent=model.Head
 local label=Instance.new('TextLabel');label.Size=UDim2.fromScale(1,1);label.BackgroundColor3=Color3.fromRGB(24,28,31);label.BackgroundTransparency=.15
 label.TextColor3=Color3.fromRGB(244,240,227);label.Font=Enum.Font.GothamMedium;label.TextSize=14;label.TextWrapped=true;label.Text=text;label.Parent=gui
 local corner=Instance.new('UICorner');corner.CornerRadius=UDim.new(0,8);corner.Parent=label
 game:GetService('Debris'):AddItem(gui,4)
end
function Civilians.start(city,combat,report)
 local field=Instance.new('Folder');field.Name='City civilians';field.Parent=workspace
 local strips={};local agents={};local slots={};local count=0;local spawnAt=0;local birth=0;local rng=Random.new()
 local streets=city:FindFirstChild('Streets & alleys')
 for _,part in streets:GetChildren() do
  if part.Name=='Pavement' then
   table.insert(strips,{position=part.Position+Vector3.yAxis*3.3,size=part.Size})
  end
 end
 local graph=Routes.build(strips);local routes=graph.nodes
 local self={agents=agents,field=field};local signals=streets:FindFirstChild('Traffic signals')
 local function random() return rng:NextNumber() end
 local function pick(list) return list[rng:NextInteger(1,#list)] end
 local function nextDestination(s,now)
  local blocked={};for id,untilTime in s.blocked do if now<untilTime then blocked[id]=true else s.blocked[id]=nil end end
  s.edge=Routes.next(graph,s.node,s.previous,s.recent,random,blocked)
  s.enteredCrossing=false;s.routeStarted=now;s.progressAt=now;s.progress=s.model.HumanoidRootPart.Position
  if s.edge then s.model:SetAttribute('Destination',routes[s.edge.to].position) end
 end
 local function crossingOpen(s,at)
  if not s.edge or not s.edge.crossing or s.enteredCrossing then return true end
  local dest=routes[s.edge.to].position;local delta=dest-routes[s.node].position
  local axis=math.abs(delta.X)>math.abs(delta.Z) and 1 or 0
  local closest,distance=nil,65
  if signals then for _,signal in signals:GetChildren() do
   local mast=signal:FindFirstChild('Mast')
   if mast and signal:GetAttribute('Axis')==axis then
    local d=((mast.Position-at)*Vector3.new(1,0,1)).Magnitude
    if d<distance then closest=signal;distance=d end
   end
  end end
  if closest then
   local _,ped=Phases.at(workspace:GetServerTimeNow(),axis,closest:GetAttribute('SignalOffset') or 0)
   if ped~='Walk' then return false end
  end
  s.enteredCrossing=true;return true
 end
 local function spawn(index)
  local route=routes[index];local model=Storage.ResidentRig:Clone();model.Name='Neighborhood resident';model.Parent=field
  local personality=pick({'cautious','sociable','bold'});birth+=1
  require(Storage.StreetStyle).apply(model,{Name='Resident',Height=pick({'Medium','Tall','Short'}),Build=pick({'Average','Slender'}),
   Tone=pick({'Umber','Copper','Olive','Espresso','Sand'}),Hair=pick({'Close crop','Twists','High puff','Side part'}),
   Starter=pick({'Dock denim','Field liner','Ash pullover'})})
  model:PivotTo(CFrame.new(route.position));local h=model.Humanoid;h.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None;h.WalkSpeed=10
  local clear=Ground.choose(model,{route.position},false)
  if not clear then model:Destroy();return end
  model:PivotTo(CFrame.new(clear))
  for _,part in model:GetDescendants() do if part:IsA('BasePart') then part.Anchored=false end end
  model.HumanoidRootPart:SetNetworkOwner(nil);Ragdoll.watch(model);Tags:AddTag(model,'CombatActor');Tags:AddTag(model,'Civilian')
  model:SetAttribute('Personality',personality);model:SetAttribute('CivilianId',birth)
  local state={model=model,brain=Brain.new(personality,os.clock()),nav=Navigation.new(model),node=index,index=index,pauseUntil=0,unseen=0,nextGoal=0,
   born=os.clock(),speed=rng:NextNumber(9,12.5),recent={},history={},blocked={},stops=0,trip=0,stepsUntilPause=rng:NextInteger(3,7)}
  nextDestination(state,os.clock())
  agents[model]=state;slots[index]=state;count+=1
  local prompt=Instance.new('ProximityPrompt');prompt.Name='Talk';prompt.ActionText='Talk';prompt.ObjectText='Neighbor';prompt.MaxActivationDistance=7;prompt.HoldDuration=.2;prompt.RequiresLineOfSight=true;prompt.Parent=model.Head
  state.prompt=prompt
  prompt.Triggered:Connect(function(p)
   local root=p.Character and p.Character:FindFirstChild('HumanoidRootPart')
   if not root or h.Health<=0 or (root.Position-model.HumanoidRootPart.Position).Magnitude>8 or not visible(model,p.Character,9) or state.brain.threat or model:GetAttribute('Ragdolled') then return end
   local now=os.clock();if now<(state.talkReady or 0) then return end;state.talkReady=now+6;state.talk=true;state.guest=p
   local replies={'You good? Keep an eye out at the crossings.','Need work? The job desk can set you up with a shift.','The fuel mart is open. Keep the doorway clear.','I am heading home soon. Stay safe out here.'}
   say(model,replies[(index+math.floor(now/20))%#replies+1],now)
  end)
  task.spawn(function()
   local animation=Instance.new('Animation');animation.AnimationId='rbxassetid://507777826'
   local animator=h:FindFirstChildOfClass('Animator') or Instance.new('Animator',h)
   local ok,track=pcall(animator.LoadAnimation,animator,animation);animation:Destroy()
   if ok and model.Parent then
    track.Looped=true;track.Priority=Enum.AnimationPriority.Movement
    h.Running:Connect(function(speed) if speed>1 and not model:GetAttribute('Ragdolled') then if not track.IsPlaying then track:Play(.15) end;track:AdjustSpeed(speed/13) elseif track.IsPlaying then track:Stop(.15) end end)
   end
  end)
  return state
 end
 function self.alert(player,origin,kind,victim,hearing)
  local now=os.clock()
  for model,s in agents do
   if model.Humanoid.Health<=0 then continue end
   local seen=player and visible(model,player.Character,55)
   if model==victim or seen or kind=='gunfire' and (model.HumanoidRootPart.Position-origin).Magnitude<(hearing or 90) then
    Brain.notice(s.brain,now,{kind=kind,position=origin,suspect=player and player.UserId,seen=seen or model==victim,victim=model==victim})
    s.nextGoal=0
   end
  end
 end
 task.spawn(function()
  while city.Parent and field.Parent do
   local now=os.clock();local people={}
   for _,p in Players:GetPlayers() do
    local c=p.Character;local h=c and c:FindFirstChildOfClass('Humanoid');local root=c and c:FindFirstChild('HumanoidRootPart')
    if root and h and h.Health>0 then table.insert(people,{p=p,root=root,armed=c:FindFirstChild('Pistol')~=nil or c:FindFirstChild('Knife')~=nil or c:FindFirstChild('Bat')~=nil}) end
   end
   local limit=Routes.population(#people);field:SetAttribute('PopulationLimit',limit)
   if now>=spawnAt and count<limit then
    spawnAt=now+1.1
    local candidates={}
    for i,route in routes do if #route.edges>0 and not slots[i] and now>=(route.blockedUntil or 0) then
     local nearest=math.huge;local inView=false
     for _,v in people do
      local delta=route.position-v.root.Position;nearest=math.min(nearest,delta.Magnitude)
      if delta.Magnitude<130 and v.root.CFrame.LookVector:Dot(delta.Unit)>.25 then inView=true end
     end
     if nearest>65 and nearest<185 and not inView then
      local clear=true;for m in agents do if m.Parent and (m.HumanoidRootPart.Position-route.position).Magnitude<14 then clear=false;break end end
      if clear then table.insert(candidates,i) end
     end
    end end
    local best=#candidates>0 and pick(candidates)
    if best then
     local created=spawn(best)
     if not created then routes[best].blockedUntil=now+30 end
    end
   end
   for model,s in agents do
    if not model.Parent then agents[model]=nil;slots[s.index]=nil;count-=1;continue end
    local at=model.HumanoidRootPart.Position;local human=model.Humanoid;local closest,dist=nil,math.huge
    for _,v in people do local d=(v.root.Position-at).Magnitude;if d<dist then closest=v;dist=d end end
    local obstacle=closest and closest.root;local clearance=dist
    for other in agents do
     if other~=model and other.Parent and other.Humanoid.Health>0 then
      local d=(other.HumanoidRootPart.Position-at).Magnitude
      if d<clearance then clearance=d;obstacle=other.HumanoidRootPart end
     end
    end
    if dist>240 then s.unseen+=.25 else s.unseen=0 end
    local inView=false
    for _,v in people do local delta=at-v.root.Position;if delta.Magnitude<150 and v.root.CFrame.LookVector:Dot(delta.Unit)>.1 then inView=true;break end end
    if s.unseen>12 or Routes.canRetire(dist,now-s.born,inView,s.brain.threat~=nil or now<s.brain.talkUntil) or human.Health<=0 and now>(s.deadAt or math.huge) then s.nav:stop();combat:cancel(model);model:Destroy();continue end
    if human.Health<=0 then s.deadAt=s.deadAt or now+12 end
    local threat=s.brain.threat;local suspect=threat and threat.suspect and Players:GetPlayerByUserId(threat.suspect)
    local seen=suspect and visible(model,suspect.Character,45);local target=seen and suspect.Character.HumanoidRootPart
    local weapon=suspect and suspect.Character and (suspect.Character:FindFirstChild('Pistol') or suspect.Character:FindFirstChild('Knife') or suspect.Character:FindFirstChild('Bat'))
    if not threat and closest and closest.armed and dist<20 and visible(model,closest.p.Character,20) then
     Brain.notice(s.brain,now,{kind='weapon',position=closest.root.Position,suspect=closest.p.UserId,seen=true});threat=s.brain.threat;target=closest.root;seen=true;weapon=true
    end
    if not s.edge and now-s.routeStarted>3 then nextDestination(s,now) end
    local goal=s.edge and routes[s.edge.to].position or at
    if s.edge and (goal-at).Magnitude<3.7 then
     s.previous=s.node;s.node=s.edge.to;s.stops+=1;s.stepsUntilPause-=1
     table.insert(s.history,s.node);s.recent[s.node]=true
     if #s.history>8 then local old=table.remove(s.history,1);s.recent[old]=nil end
     model:SetAttribute('VisitedStops',s.stops)
     if s.stepsUntilPause<=0 then s.pauseUntil=now+rng:NextNumber(1.5,5);s.stepsUntilPause=rng:NextInteger(3,7);s.trip+=1;model:SetAttribute('TripId',s.trip) end
     nextDestination(s,now);goal=s.edge and routes[s.edge.to].position or at
    end
    local crossing=not crossingOpen(s,at)
    local arrived=now<s.pauseUntil or not s.edge or crossing
    local mode=Brain.step(s.brain,now,{health=human.Health,ragdoll=model:GetAttribute('Ragdolled'),visibleThreat=seen,distance=target and (target.Position-at).Magnitude,
     armed=weapon~=nil and weapon~=false,safeDistance=threat and (at-threat.position).Magnitude>34 and not seen,talk=s.talk,crowded=clearance<4,arrived=arrived})
    s.talk=nil;model:SetAttribute('Activity',mode.mode);s.prompt.Enabled=not s.brain.threat and human.Health>0 and not model:GetAttribute('Ragdolled')
    model:SetAttribute('KnownSuspect',s.brain.threat and s.brain.threat.suspect)
    model:SetAttribute('IncidentPosition',s.brain.threat and s.brain.threat.position)
    if mode.mode~=s.lastMode then
     if mode.mode=='Warning' then say(model,'Give me some room, please.',now)
     elseif mode.mode=='Fleeing' then say(model,'I am getting out of here!',now)
     elseif mode.mode=='Defending' then say(model,'Back off!',now)
     elseif mode.mode=='Reporting' then say(model,'I need police at this corner.',now) end
     s.lastMode=mode.mode
    end
    if mode.report then local p=Players:GetPlayerByUserId(mode.report.suspect);if p then report(p,mode.report.position) end end
    if mode.mode=='Defending' and target then
     local delta=(target.Position-at)*Vector3.new(1,0,1)
     if delta.Magnitude>.1 then model.HumanoidRootPart.CFrame=model.HumanoidRootPart.CFrame:Lerp(CFrame.lookAt(at,at+delta),.55) end
     local guard=target.Parent:GetAttribute('CombatState')=='Attacking'
     combat:guard(model,guard)
     if delta.Magnitude<5 and not guard and now>=(s.attackAt or 0) then combat:attack(model);s.attackAt=now+1.1 end
     if delta.Magnitude>4.5 then s.nav:step(target.Position,now,10) else s.nav:stop() end
    elseif mode.mode=='Fleeing' then
     combat:guard(model,false)
     if now>=s.nextGoal then s.nextGoal=now+1.6;s.flee=Ground.choose(model,Tactics.flee(at,mode.threat),false) end
     if s.flee then s.nav:step(s.flee,now,16) else s.nav:stop();model:SetAttribute('Activity','Cowering') end
    elseif (mode.mode=='Yielding' or mode.mode=='Warning') and obstacle then
     if now>=s.nextGoal then
      s.nextGoal=now+1.5;local delta=(obstacle.Position-at)*Vector3.new(1,0,1);local right=delta.Magnitude>.1 and Vector3.new(-delta.Z,0,delta.X).Unit or Vector3.xAxis
      s.yield=Ground.choose(model,{at+right*4,at-right*4,at-model.HumanoidRootPart.CFrame.LookVector*3},true)
     end
     if s.yield then s.nav:step(s.yield,now,8) else s.nav:stop() end
    elseif mode.mode=='Walking' then
     combat:guard(model,false);s.nav:step(goal,now,s.speed)
     if (at-s.progress).Magnitude>2 then s.progress=at;s.progressAt=now end
     if now-s.progressAt>10 and s.edge then
      s.blocked[s.edge.to]=now+20;nextDestination(s,now)
     end
    else
     s.nav:stop();combat:guard(model,false)
     s.progressAt=now;s.progress=at
     if crossing and mode.mode=='Idling' then model:SetAttribute('Activity','Waiting to cross') end
     if mode.mode=='Talking' and s.guest and s.guest.Character then
      local delta=(s.guest.Character:GetPivot().Position-at)*Vector3.new(1,0,1)
      if delta.Magnitude>.1 then model.HumanoidRootPart.CFrame=model.HumanoidRootPart.CFrame:Lerp(CFrame.lookAt(at,at+delta),.3) end
     end
    end
   end
   task.wait(.25)
  end
  for model,s in agents do s.nav:stop();model:Destroy() end
 end)
 return self
end
return Civilians
