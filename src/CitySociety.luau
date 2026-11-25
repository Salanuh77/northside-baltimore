-- Server-owned ambient errands and incidents. NPC decisions never spend player money.
local Rules=require(script.Parent.SocietyRules)
local Dialogue=require(script.Parent.NpcDialogue)
local Ground=require(script.Parent.NpcGround)
local Tactics=require(script.Parent.NpcTactics)
local Society={}
function Society.start(city,civilians,respond,combat,protected)
 local rng=Random.new();local self={scenes={},paused=false,automatic=true};local sequence=0;local crimeAt=os.clock()+60
 local shops,homes={},{}
 for _,part in city:GetDescendants() do if part:IsA('BasePart') then
  local kind=part:GetAttribute('Action')
  if table.find({'Mart','Coffee','Clothing','Market'},kind) then table.insert(shops,part)
  elseif kind=='Door' and part:FindFirstChild('Residence') then table.insert(homes,part) end
 end end
 local function random() return rng:NextNumber() end
 local function alive(model) return model and model.Parent and model:FindFirstChild('HumanoidRootPart') and model.Humanoid.Health>0 end
 local function clear(from,target)
  if not alive(from) or not target or not target.Parent then return false end
  local point=target:IsA('Model') and target.Head.Position or target.Position
  local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Exclude;ray.FilterDescendantsInstances={from};ray.RespectCanCollide=true
  local hit=workspace:Raycast(from.Head.Position,point-from.Head.Position,ray)
  return not hit or hit.Instance==target or hit.Instance:IsDescendantOf(target)
 end
 local function speak(s,event)
  s.dialogue=s.dialogue or {};Dialogue.say(s.model,Dialogue.choose(s.dialogue,{event=event},random),os.clock())
 end
 local function opponent(model,target)
  local link=model:FindFirstChild('AmbientOpponent')
  if not target then if link then link:Destroy() end;return end
  link=link or Instance.new('ObjectValue');link.Name='AmbientOpponent';link.Value=target;link.Parent=model
 end
 local function nearest(parts,position,limit)
  local result,best=nil,limit or 180
  for _,part in parts do local d=(part.Position-position).Magnitude;if d<best then result=part;best=d end end
  return result
 end
 local function streetPoint(position)
  local goal,best=nil,math.huge
  for _,node in civilians.graph.nodes do local d=(node.position-position).Magnitude;if d<best then goal=node.position;best=d end end
  return goal
 end
 function self.shopGoal(s,shop)
  local candidates={}
  for _,offset in {Vector3.new(0,0,-6),Vector3.new(0,0,6),Vector3.new(6,0,0),Vector3.new(-6,0,0)} do
   table.insert(candidates,shop.CFrame:PointToWorldSpace(offset))
  end
  for _,candidate in candidates do
   local goal=Ground.choose(s.model,{candidate},false)
   -- A countertop can satisfy a downward ground ray. Errands stay on the
   -- resident's walking floor rather than treating merchandise as a platform.
   if goal and math.abs(goal.Y-s.model.HumanoidRootPart.Position.Y)<1.4 then return goal end
  end
 end
 function self.errand(s,kind,now)
  if not alive(s.model) or s.scene or s.brain.threat or protected(s.model) then return false end
  local at=s.model.HumanoidRootPart.Position;local goal,partner
  if kind=='Shopping' then local shop=nearest(shops,at,180);goal=shop and self.shopGoal(s,shop)
  elseif kind=='Heading home' then local home=nearest(homes,at,200);goal=home and streetPoint(home.Position)
  elseif kind=='Meeting a neighbor' then
   local best=48
   for model,other in civilians.agents do if model~=s.model and alive(model) and not other.scene and not other.brain.threat then
    local d=(model.HumanoidRootPart.Position-at).Magnitude;if d<best then partner=model;best=d end
   end end
   goal=partner and Ground.choose(s.model,{partner.HumanoidRootPart.Position+Vector3.new(5,0,0),partner.HumanoidRootPart.Position-Vector3.new(5,0,0)},true)
  else goal=civilians.graph.nodes[s.node].position end
  if not goal or (goal-at).Magnitude>200 then return false end
  s.life={kind=kind,goal=goal,partner=partner,untilTime=now+36,hold=rng:NextNumber(6,12)}
  s.model:SetAttribute('Routine',kind);s.model:SetAttribute('ErrandGoal',goal)
  return true
 end
 local function finish(scene,result)
  if scene.done then return end;scene.done=true;scene.result=result
  local s=scene.suspect;s.scene=nil;s.life=nil;s.lifeAt=os.clock()+30;s.crimeReady=os.clock()+150
  if s.model.Parent then
   s.model:SetAttribute('Scene',nil);s.model:SetAttribute('Surrendered',nil);s.model:SetAttribute('IncidentResult',result)
   opponent(s.model,nil);combat:cancel(s.model)
   civilians.resumeRoute(s,os.clock())
  end
  if scene.unit then scene.unit.scene=nil;opponent(scene.unit.model,nil) end
  civilians.field:SetAttribute(result,(civilians.field:GetAttribute(result) or 0)+1)
 end
 local function report(scene,now)
  if scene.reported then return end
  local suspect=scene.suspect.model;local witnessed=false
  for model in civilians.agents do
   if model~=suspect and alive(model) and (model.HumanoidRootPart.Position-suspect.HumanoidRootPart.Position).Magnitude<50 and clear(model,suspect) then witnessed=true;break end
  end
  for _,unit in respond.units do
   if unit.role=='police' and alive(unit.model) and (unit.model.HumanoidRootPart.Position-suspect.HumanoidRootPart.Position).Magnitude<65 and clear(unit.model,suspect) then witnessed=true;break end
  end
  for _,clerk in game:GetService('CollectionService'):GetTagged('RouteClerk') do
   if alive(clerk) and (clerk.HumanoidRootPart.Position-suspect.HumanoidRootPart.Position).Magnitude<35 and clear(clerk,suspect) then witnessed=true;break end
  end
  if witnessed then scene.reported=now;scene.memory={lastSeen=suspect.HumanoidRootPart.Position,seenAt=now};scene.position=scene.memory.lastSeen end
 end
 function self.incident(s,victim,kind,now)
  local active=0;for _,scene in self.scenes do if not scene.done then active+=1 end end
  local target=kind=='Shoplifting' and nearest(shops,s.model.HumanoidRootPart.Position,48) or victim and victim.model
  local point=target and (target:IsA('Model') and target.HumanoidRootPart.Position or target.Position)
  if not point or not alive(s.model) or (victim and (not alive(victim.model) or victim.scene or victim.brain.threat or protected(victim.model))) then return false end
  if not Rules.canStartCrime({age=now-s.born,health=s.model.Humanoid.Health,busy=s.scene~=nil or s.life~=nil,danger=s.brain.threat~=nil,
   protected=protected(s.model),distance=(point-s.model.HumanoidRootPart.Position).Magnitude,active=active,now=now,ready=s.crimeReady or 0}) then return false end
  sequence+=1
  local scene={id=sequence,suspect=s,victim=victim,target=target,kind=kind,started=now,expires=now+65}
  self.scenes[sequence]=scene;s.scene=scene;s.life=nil;s.model:SetAttribute('Scene',kind)
  if victim then speak(s,kind=='Street fight' and 'argument' or 'robbery') end
  return scene
 end
 function self.hit(attacker,target)
  local s=civilians.agents[attacker];local scene=s and s.scene
  if scene and scene.kind=='Mugging' and scene.victim and scene.victim.model==target and not scene.stolen then
   local victim=scene.victim;local amount=math.min(25,victim.wallet or 40)
   victim.wallet=(victim.wallet or 40)-amount;s.wallet=(s.wallet or 40)+amount;scene.stolen=amount
   attacker:SetAttribute('NPCStolenCash',amount)
  end
  civilians.npcIncident(attacker,target)
 end
 local function criminal(s,scene,now)
  local model=s.model;local root=model.HumanoidRootPart;local at=root.Position
  if scene.escort then
   model:SetAttribute('Activity','Being escorted');s.nav:step(scene.unit.model.HumanoidRootPart.Position-scene.unit.model.HumanoidRootPart.CFrame.LookVector*3.5,now,9)
   return true
  end
  local officer=scene.unit and scene.unit.model
  local seenOfficer=alive(officer) and (officer.HumanoidRootPart.Position-at).Magnitude<30 and clear(model,officer)
  if seenOfficer then
   scene.confronted=scene.confronted or now
   if model.Humanoid.Health<40 or now-scene.confronted>9 or (scene.kind=='Shoplifting' and (officer.HumanoidRootPart.Position-at).Magnitude<9) then
    if not model:GetAttribute('Surrendered') then speak(s,'surrender');combat:cancel(model) end
    model:SetAttribute('Surrendered',true);model:SetAttribute('Activity','Surrendering');s.nav:stop();return true
   end
  end
  if model:GetAttribute('Surrendered') then s.nav:stop();return true end
  local target=scene.target
  if not scene.committed then
   if not target.Parent or now-scene.started>14 then finish(scene,'AbandonedIncidents');return false end
   local targetPoint=target:IsA('Model') and target.HumanoidRootPart.Position or target.Position
   if now-scene.started<1.8 then model:SetAttribute('Activity','Arguing');s.nav:stop();return true end
   if scene.kind=='Shoplifting' then
    scene.shopGoal=scene.shopGoal or self.shopGoal(s,target)
    local goal=scene.shopGoal
    if not goal then finish(scene,'AbandonedIncidents');return false end
    model:SetAttribute('Activity','Approaching shop');s.nav:step(goal,now,11)
    if (at-goal).Magnitude<4 and clear(model,target) then
     scene.committed=now;s.wallet=(s.wallet or 40)+25
     for _,clerk in game:GetService('CollectionService'):GetTagged('RouteClerk') do if clerk.Parent and (clerk.HumanoidRootPart.Position-targetPoint).Magnitude<35 then clerk:SetAttribute('AlarmUntil',now+12) end end
     report(scene,now)
    end
   else
    model:SetAttribute('Activity',scene.kind=='Mugging' and 'Threatening neighbor' or 'Fighting')
    if (targetPoint-at).Magnitude>4.5 then s.nav:step(targetPoint,now,12)
    else
     s.nav:stop();root.CFrame=CFrame.lookAt(at,Vector3.new(targetPoint.X,at.Y,targetPoint.Z));opponent(model,target)
     if combat:attack(model) then scene.committed=now;report(scene,now);civilians.npcIncident(model,target) end
    end
   end
   return true
  end
  model:SetAttribute('Activity','Fleeing scene')
  if now>=(scene.fleeAt or 0) then
   scene.fleeAt=now+2
   local danger=seenOfficer and officer.HumanoidRootPart.Position or scene.position or scene.target:GetPivot().Position
   scene.flee=Ground.choose(model,Tactics.flee(at,danger),true)
  end
  if scene.flee then s.nav:step(scene.flee,now,15) else s.nav:stop() end
  return true
 end
 civilians.routine=function(s,now)
  if self.paused then return false end
  if s.scene then return criminal(s,s.scene,now) end
  local life=s.life
  if not life then return false end
  if now>life.untilTime then s.life=nil;s.model:SetAttribute('Routine',nil);s.model:SetAttribute('ErrandGoal',nil);s.lifeAt=now+25;civilians.resumeRoute(s,now);return false end
  local at=s.model.HumanoidRootPart.Position
  if (at-life.goal).Magnitude>3.7 then s.model:SetAttribute('Activity',life.kind);s.nav:step(life.goal,now,s.speed);return true end
  s.nav:stop();s.model:SetAttribute('Activity',life.kind)
  if not life.arrived then
   life.arrived=now;life.untilTime=now+life.hold
   s.model:SetAttribute('ErrandsCompleted',(s.model:GetAttribute('ErrandsCompleted') or 0)+1)
   if life.kind=='Shopping' then s.wallet=math.max(0,(s.wallet or 40)-6);s.model:SetAttribute('ShoppingBags',(s.model:GetAttribute('ShoppingBags') or 0)+1);speak(s,'shoppingDone')
   elseif life.kind=='Meeting a neighbor' then speak(s,'social') end
  end
  if alive(life.partner) then local p=life.partner.HumanoidRootPart.Position;local delta=(p-at)*Vector3.new(1,0,1);if delta.Magnitude>.2 then s.model.HumanoidRootPart.CFrame=CFrame.lookAt(at,at+delta) end end
  return true
 end
 respond.setAmbient(function(unit,now,at,canSee)
  local scene=unit.scene
  if not scene or scene.done or not alive(scene.suspect.model) then return end
  local target=scene.suspect.model
  if scene.escort then
   if (at-unit.home).Magnitude<7 then finish(scene,'NPCsBooked');return end
   if now-scene.escort>25 then finish(scene,'NPCsDetained');return end
   return {mode='Escorting suspect',goal=unit.home}
  end
  local seen=canSee(unit.model,target,75,true)
  local action=Rules.police(scene.memory,now,{valid=target.Humanoid.Health>0,visible=seen,position=target.HumanoidRootPart.Position,
   distance=(target.HumanoidRootPart.Position-at).Magnitude,surrendered=target:GetAttribute('Surrendered')})
  if action.mode=='Clear' then finish(scene,'EscapedIncidents');return end
  if seen and now>=(unit.ambientSpoke or 0) then unit.ambientSpoke=now+10;speak(unit,'officer') end
  if seen and (target.HumanoidRootPart.Position-at).Magnitude<7 and scene.kind=='Shoplifting' and unit.corrupt then
   scene.payoffAt=scene.payoffAt or now
   if now-scene.payoffAt>2 then scene.suspect.wallet=math.max(0,(scene.suspect.wallet or 40)-25);speak(unit,'corrupt');finish(scene,'CorruptDeals');return {mode='Looking the other way'} end
  elseif action.arrest then
   scene.escort=now;opponent(target,nil);combat:cancel(target);speak(unit,'officer')
   return {mode='Escorting suspect',goal=unit.home}
  end
  return action
 end)
 task.spawn(function()
  while city.Parent do
   local now=os.clock()
   if not self.paused then
    for model,s in civilians.agents do if self.automatic and alive(model) and not s.scene then
     s.lifeAt=s.lifeAt or now+rng:NextNumber(20,55)
     if now>=s.lifeAt and not s.life and not s.brain.threat and now>=s.brain.talkUntil then
      s.lifeAt=now+rng:NextNumber(35,75);self.errand(s,Rules.routine(game.Lighting.ClockTime,random()),now)
     end
    end end
    for id,scene in self.scenes do
     if scene.done then self.scenes[id]=nil
     elseif not alive(scene.suspect.model) then finish(scene,'ResolvedIncidents')
     elseif now>scene.expires then finish(scene,'EscapedIncidents')
     elseif scene.unit and (not alive(scene.unit.model) or scene.unit.target) then scene.unit.scene=nil;scene.unit=nil
     elseif scene.reported and now-scene.reported>=2.5 and not scene.unit then
      local best=320
      for _,unit in respond.units do if unit.role=='police' and not unit.scene and not unit.target and alive(unit.model) then
       local d=(unit.model.HumanoidRootPart.Position-scene.position).Magnitude
       if d<best then scene.unit=unit;best=d end
      end end
      if scene.unit then scene.unit.scene=scene end
     end
    end
    if self.automatic and now>=crimeAt then
     crimeAt=now+rng:NextNumber(35,65)
     local pool={};for model,s in civilians.agents do if alive(model) and not s.scene and not s.life and not s.brain.threat then table.insert(pool,s) end end
     if #pool>=3 then
      local s=pool[rng:NextInteger(1,#pool)];local victim,best=nil,35
      for _,other in pool do if other~=s then local d=(other.model.HumanoidRootPart.Position-s.model.HumanoidRootPart.Position).Magnitude;if d<best then victim=other;best=d end end end
      if random()<.35 then self.incident(s,nil,'Shoplifting',now)
      elseif victim then self.incident(s,victim,random()<.5 and 'Street fight' or 'Mugging',now) end
     end
    end
   end
   task.wait(1)
  end
 end)
 return self
end
return Society
