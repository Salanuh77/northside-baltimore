local Players=game.Players
local drive=game.ReplicatedStorage:WaitForChild('TestDrive')
local function waitFor(fn,seconds) local due=os.clock()+seconds;repeat if fn() then return true end;task.wait(.1) until os.clock()>due;return fn() end
local function check(ok,label) assert(ok,label);print('SOCIETY_PASS',label) end
local function call(p,k,d) return drive:InvokeClient(p,k,d or {}) end
local function park(model,point,look,anchored)
 local root=model.HumanoidRootPart;root.Anchored=true
 model:PivotTo(CFrame.lookAt(point,point+(look or Vector3.zAxis))*root.CFrame:ToObjectSpace(model:GetPivot()))
 root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero;root.Anchored=anchored==true
end
local ok,err=pcall(function()
 check(waitFor(function() if #Players:GetPlayers()~=2 then return false end;for _,p in Players:GetPlayers() do if not p:GetAttribute('ProbeSpawnFinished') then return false end end;return true end,65),'Two residents ready')
 local a,b=table.unpack(Players:GetPlayers())
 local world=shared.BaltimoreTestSociety;local society=world.society;society.automatic=false
 park(a.Character,Vector3.new(23,4,80),nil,true);park(b.Character,Vector3.new(-23,4,70),nil,true)
 for _,p in {a,b} do local ff=p.Character:FindFirstChildOfClass('ForceField');if ff then ff:Destroy() end end
 local pool={}
 check(waitFor(function() table.clear(pool);for _,s in world.civilians.agents do table.insert(pool,s) end;return #pool>=3 end,20),'Nearby population supplies independent residents')
 local shopper,suspect,victim=pool[1],pool[2],pool[3]
 local shop
 for _,p in workspace.Baltimore:GetDescendants() do if p:IsA('BasePart') and p:GetAttribute('Action')=='Mart' then shop=p;break end end
 check(shop~=nil,'Fuel mart counter exists')
 local sidewalk,best=nil,math.huge
 for _,node in world.civilians.graph.nodes do local distance=(node.position-shop.Position).Magnitude;if distance<best then sidewalk=node.position;best=distance end end
 park(shopper.model,sidewalk,nil,true)
 local goal=assert(society.shopGoal(shopper,shop),'Shop must have a clear customer spot')
 check(math.abs(goal.Y-sidewalk.Y)<1.4,'Shopping destination stays on the walking floor, not a countertop')
 park(shopper.model,goal,nil,true)
 park(a.Character,goal+Vector3.new(0,0,18),nil,true);park(b.Character,goal+Vector3.new(0,0,23),nil,true)
 a:RequestStreamAroundAsync(goal,5)
 check(society.errand(shopper,'Shopping',os.clock()),'Resident selects a real shop interior destination')
 goal=shopper.life.goal
 local departure=require(game.ServerScriptService.NpcGround).choose(shopper.model,{goal+Vector3.new(8,0,0),goal+Vector3.new(-8,0,0),goal+Vector3.new(0,0,8),goal+Vector3.new(0,0,-8)},true)
 check(departure~=nil,'Shop has a clear walking aisle leading to its customer spot')
 park(shopper.model,departure,nil,false)
 local start=shopper.model.HumanoidRootPart.Position
 check(waitFor(function() return (shopper.model:GetAttribute('ShoppingBags') or 0)>0 end,25),'NPC physically reaches the shop customer area and finishes an errand: '..tostring(shopper.model.HumanoidRootPart.Position)..' goal='..tostring(shopper.life and shopper.life.goal)..' activity='..tostring(shopper.model:GetAttribute('Activity'))..' threat='..tostring(shopper.brain.threat))
 check((shopper.model.HumanoidRootPart.Position-start).Magnitude>1,'Shopping changes position, not only its label')
 check((shopper.model.HumanoidRootPart.Position-shopper.life.goal).Magnitude<4,'Purchase happens at the destination')
 shopper.life=nil
 local floor=Instance.new('Part');floor.Name='Society test floor';floor.Anchored=true;floor.Size=Vector3.new(240,1,240);floor.Position=Vector3.new(2400,40,2400);floor.Parent=workspace
 local at=Vector3.new(2400,44,2400)
 park(a.Character,at+Vector3.new(-30,0,-10),nil,true);park(b.Character,at+Vector3.new(-30,0,10),nil,true)
 for _,p in {a,b} do p:RequestStreamAroundAsync(at,5) end
 local officer,corrupt
 for _,unit in world.respond.units do
  park(unit.model,at+Vector3.new(900,0,900),nil,true)
  if unit.model.Name=='District officer' then officer=unit elseif unit.corrupt then corrupt=unit end
 end
 check(officer~=nil and corrupt~=nil,'Honest and corrupt officers have distinct policy')
 park(officer.model,at+Vector3.new(0,0,28),-Vector3.zAxis,false);officer.home=at+Vector3.new(-24,0,0)
 park(suspect.model,at,Vector3.zAxis,false);park(victim.model,at+Vector3.new(0,0,4),-Vector3.zAxis,true)
 suspect.born=os.clock()-80;suspect.life=nil;suspect.brain.threat=nil;victim.life=nil;victim.brain.threat=nil;victim.brain.personality='cautious'
 local before=victim.model.Humanoid.Health
 local scene=assert(society.incident(suspect,victim,'Mugging',os.clock()),'Start eligible incident')
 check(waitFor(function() return victim.model.Humanoid.Health<before end,8),'NPC assault uses real timed melee and deals damage')
 check(victim.model.Humanoid.Health>=before-17,'Ambient assault does not repeatedly drain the victim')
 check(scene.stolen==25 and victim.wallet==15,'Mugging transfers only the NPC wallet after a confirmed hit')
 victim.model.HumanoidRootPart.Anchored=false
 check(waitFor(function() return scene.unit==officer end,8),'Witnessed incident dispatches the available officer')
 start=officer.model.HumanoidRootPart.Position
 check(waitFor(function() return (officer.model.HumanoidRootPart.Position-start).Magnitude>3 end,8),'Officer actually pursues the NPC suspect')
 check(waitFor(function() return scene.escort~=nil end,40),'Surrendered suspect is cuffed after an approach and hold')
 check(waitFor(function() return scene.done and scene.result=='NPCsBooked' end,30),'Officer escorts the suspect to the duty point')
 check(not suspect.model:GetAttribute('Surrendered') and not suspect.model:FindFirstChild('AmbientOpponent'),'Resolved scene releases temporary combat permissions')
 -- Test real bribe prompts using server-owned balances and known officer dispositions.
 for _,unit in world.respond.units do unit.scene=nil;park(unit.model,at+Vector3.new(900,0,900),nil,true) end
 park(corrupt.model,at,Vector3.zAxis,true);park(a.Character,at+Vector3.zAxis*4,-Vector3.zAxis,true)
 a.Character.Humanoid:UnequipTools();game.ServerStorage.TestProfile:Invoke(a,500,1)
 call(a,'Prompt',corrupt.model.Head)
 local profile=game.ServerStorage.TestProfile:Invoke(a)
 check(profile.Cash==350 and (a:GetAttribute('Heat') or 0)==0,'Corrupt officer accepts exactly $150 for one nonviolent wanted level')
 game.ServerStorage.TestProfile:Invoke(a,nil,1);call(a,'Prompt',corrupt.model.Head)
 check(game.ServerStorage.TestProfile:Invoke(a).Cash==350,'Repeated bribe prompt cannot charge during cooldown')
 park(corrupt.model,at+Vector3.new(900,0,900),nil,true);park(officer.model,at,Vector3.zAxis,true)
 call(a,'Prompt',officer.model.Head)
 check(game.ServerStorage.TestProfile:Invoke(a).Cash==350 and (a:GetAttribute('Heat') or 0)>=2,'Honest officer refuses without taking money and reports the attempt')
end)
game:GetService('StudioTestService'):EndTest({ok=ok,error=tostring(err)})
