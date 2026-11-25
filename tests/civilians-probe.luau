local Players=game.Players
local drive=game.ReplicatedStorage:WaitForChild('TestDrive')
local function waitFor(fn,seconds) local due=os.clock()+seconds;repeat if fn() then return true end;task.wait(.1) until os.clock()>due;return fn() end
local function check(ok,label) assert(ok,label);print('CIVILIAN_PASS',label) end
local function call(p,k,d) return drive:InvokeClient(p,k,d or {}) end
local function park(model,at,look)
 local root=model.HumanoidRootPart;root.Anchored=true
 model:PivotTo(CFrame.lookAt(at,at+(look or Vector3.zAxis))*root.CFrame:ToObjectSpace(model:GetPivot()))
 root.AssemblyLinearVelocity=Vector3.zero
end
local ok,err=pcall(function()
 check(waitFor(function() if #Players:GetPlayers()~=2 then return false end;for _,p in Players:GetPlayers() do if not p:GetAttribute('ProbeSpawnFinished') then return false end end;return true end,65),'Two live residents ready')
 local a,b=table.unpack(Players:GetPlayers())
 -- Isolate route/reaction assertions; the society suite exercises errands and crime.
 shared.BaltimoreTestSociety.society.paused=true
 for _,p in {a,b} do local ff=p.Character:FindFirstChildOfClass('ForceField');if ff then ff:Destroy() end end
 park(a.Character,Vector3.new(23,4,80));park(b.Character,Vector3.new(-23,4,70))
 a:RequestStreamAroundAsync(Vector3.new(0,4,100),5)
 local field=workspace:WaitForChild('City civilians',15)
 check(waitFor(function() return #field:GetChildren()>=2 end,15),'Civilian population activates around players')
 check(#field:GetChildren()<=(field:GetAttribute('PopulationLimit') or 30),'Active population stays bounded')
 local npc
 for _,model in field:GetChildren() do if model:GetAttribute('Personality')~='bold' then npc=model;break end end
 npc=npc or field:GetChildren()[1]
 local start=npc.HumanoidRootPart.Position
 check(waitFor(function() return (npc.HumanoidRootPart.Position-start).Magnitude>3 end,10),'Routine changes the actual civilian position')
 local destinations={};local stopStart=npc:GetAttribute('VisitedStops') or 0;local trace={};local traceAt=0
 check(waitFor(function()
  if not npc.Parent then return false end
  -- Follow the subject outside its personal space so a legitimate distance cull
  -- cannot masquerade as a navigation failure during this route observation.
  park(a.Character,npc.HumanoidRootPart.Position+Vector3.new(0,0,24))
  local dest=npc:GetAttribute('Destination');if dest then destinations[tostring(dest)]=true end
  if os.clock()>traceAt then traceAt=os.clock()+6;table.insert(trace,tostring(npc.HumanoidRootPart.Position)..' -> '..tostring(dest)..' / '..tostring(npc:GetAttribute('Activity'))..' / stops '..tostring(npc:GetAttribute('VisitedStops'))) end
  return (npc:GetAttribute('VisitedStops') or 0)-stopStart>=4
 end,70),'Civilian walks through four actual sidewalk destinations: '..table.concat(trace,'; '))
 local destinationCount=0;for _ in destinations do destinationCount+=1 end
 check(destinationCount>=4,'Roaming is not the same two endpoints')
 local floor=Instance.new('Part');floor.Name='Civilian arena';floor.Anchored=true;floor.Size=Vector3.new(180,1,180);floor.Position=Vector3.new(2100,40,2100);floor.Parent=workspace
 local at=Vector3.new(2100,44,2100)
 park(npc,at,Vector3.zAxis);park(a.Character,at+Vector3.zAxis*4.5,-Vector3.zAxis);park(b.Character,at+Vector3.new(40,0,30))
 for _,p in {a,b} do p:RequestStreamAroundAsync(at,5) end
 local talked,detail=call(a,'TalkProbe',npc.Head)
 check(talked,'Player can use the real Talk prompt: '..tostring(detail))
 check(waitFor(function() return npc:GetAttribute('Activity')=='Talking' end,2),string.format('Conversation pauses the civilian routine (mode=%s enabled=%s distance=%s health=%s speech=%s)',tostring(npc:GetAttribute('Activity')),tostring(npc.Head.Talk.Enabled),(npc.HumanoidRootPart.Position-a.Character.HumanoidRootPart.Position).Magnitude,npc.Humanoid.Health,tostring(npc.Head:FindFirstChild('Citizen speech'))))
 check(npc.Head:FindFirstChild('Citizen speech')~=nil,'Conversation creates visible speech')
 task.wait(6.1)
 local divider=Instance.new('Part');divider.Anchored=true;divider.Size=Vector3.new(12,12,.5);divider.Position=at+Vector3.zAxis*2;divider.Parent=workspace
 -- Exercise the server check even when a modified client ignores prompt LOS.
 npc.Head.Talk.RequiresLineOfSight=false
 check(call(a,'TalkProbe',npc.Head),'Blocked conversation request reaches the prompt')
 task.wait(.4)
 check(npc:GetAttribute('Activity')~='Talking' and not npc.Head:FindFirstChild('Citizen speech'),'Wall rejects conversation on the server')
 divider:Destroy();npc.Head.Talk.RequiresLineOfSight=true
 park(npc,at,Vector3.zAxis);park(a.Character,at+Vector3.zAxis*2.5,-Vector3.zAxis)
 npc.HumanoidRootPart.Anchored=false
 start=npc.HumanoidRootPart.Position
 check(waitFor(function() return (npc.HumanoidRootPart.Position-start).Magnitude>1.5 end,7),'Crowded civilian physically yields instead of pushing through the player')
 park(npc,at,Vector3.zAxis);park(a.Character,at+Vector3.new(0,0,-30),Vector3.zAxis)
 local wall=Instance.new('Part');wall.Size=Vector3.new(25,12,1);wall.Position=at+Vector3.new(0,0,-15);wall.Anchored=true;wall.Parent=workspace
 assert(game.ServerStorage.TestReceipt:Invoke(a,{PlayerId=a.UserId,ProductId=3732000729,PurchaseId='civilian-probe'})=='PurchaseGranted')
 call(a,'Equip',{Name='Pistol'});call(a,'Shoot',{Position=at+Vector3.new(20,15,-15)})
 check(waitFor(function() return npc:GetAttribute('Activity')=='Fleeing' or npc:GetAttribute('Activity')=='Cowering' end,4),'Heard gunfire interrupts peaceful behavior')
 check(npc:GetAttribute('KnownSuspect')==nil,'Hidden gunshot does not reveal shooter identity')
 local remembered=npc:GetAttribute('IncidentPosition');check(typeof(remembered)=='Vector3','Sound location is remembered')
 park(a.Character,at+Vector3.new(45,0,-30))
 check((npc:GetAttribute('IncidentPosition')-remembered).Magnitude<.1,'Moving hidden shooter cannot update the snapshot')
 npc.HumanoidRootPart.Anchored=false;start=npc.HumanoidRootPart.Position
 check(waitFor(function() return (npc.HumanoidRootPart.Position-start).Magnitude>5 end,8),'Civilian actually runs from the incident')
 check(waitFor(function() local mode=npc:GetAttribute('Activity');return mode=='Recovering' or mode=='Walking' end,24),'Expired danger returns to the routine')
 check(npc:GetAttribute('KnownSuspect')==nil and npc:GetAttribute('IncidentPosition')==nil,'Expired witness memory clears')
 wall:Destroy()
 local oldIds={};for _,m in field:GetChildren() do oldIds[m:GetAttribute('CivilianId')]=true end
 park(a.Character,Vector3.new(450,4,800));park(b.Character,Vector3.new(430,4,800))
 check(waitFor(function()
  for _,m in field:GetChildren() do if not oldIds[m:GetAttribute('CivilianId')] then return true end end
 end,20),'New residents populate another block as players travel')
 check(waitFor(function() return not npc.Parent end,20),'Distant residents retire and free population slots')
end)
game:GetService('StudioTestService'):EndTest({ok=ok,error=tostring(err)})
