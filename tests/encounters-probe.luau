-- Real server responder loops and real client weapon actions in an isolated test arena.
local players=game.Players
local test=game:GetService('StudioTestService')
local drive=game.ReplicatedStorage:WaitForChild('TestDrive')
local function check(value,message) assert(value,message);print('ENCOUNTER_PASS',message) end
local function waitFor(fn,seconds)
 local deadline=os.clock()+seconds
 repeat if fn() then return true end;task.wait(.1) until os.clock()>=deadline
 return fn()
end
local function call(p,kind,data) return drive:InvokeClient(p,kind,data or {}) end
local function park(model,position,look)
 local root=model.HumanoidRootPart;root.Anchored=true
 local frame=CFrame.lookAt(position,position+(look or Vector3.new(0,0,-1)))
 model:PivotTo(frame*root.CFrame:ToObjectSpace(model:GetPivot()))
 root.AssemblyLinearVelocity=Vector3.zero
end
local ok,err=pcall(function()
 check(waitFor(function()
  if #players:GetPlayers()~=2 then return false end
  for _,p in players:GetPlayers() do if not p.Character or not p.Character:FindFirstChild('HumanoidRootPart') or p:GetAttribute('Cash')==nil or not p:GetAttribute('ProbeSpawnFinished') then return false end end
  return true
 end,65),'Two live residents ready')
 local a,b=table.unpack(players:GetPlayers())
 local arena=Instance.new('Part');arena.Name='Encounter test floor';arena.Anchored=true;arena.Size=Vector3.new(140,1,140);arena.Position=Vector3.new(1800,40,1800);arena.Parent=workspace
 for _,p in {a,b} do
  p:RequestStreamAroundAsync(arena.Position,5)
  local ff=p.Character:FindFirstChildOfClass('ForceField');if ff then ff:Destroy() end
 end
 local field=workspace:WaitForChild('Emergency responders')
 local cop=field:WaitForChild('District officer')
 local medic=field:WaitForChild('City paramedic')
 park(field:WaitForChild('Westside officer'),Vector3.new(2200,44,2200))
 park(field:WaitForChild('Downtown paramedic'),Vector3.new(2250,44,2200))
 park(cop,Vector3.new(1800,44,1800))
 park(medic,Vector3.new(1825,44,1800))
 park(a.Character,Vector3.new(1800,44,1778),Vector3.zAxis)
 park(b.Character,Vector3.new(1860,44,1830))
 local shop=Instance.new('Folder');shop.Name='Encounter staff fixture';shop.Parent=workspace
 local counter=Instance.new('Part');counter.Name='Counter';counter.Anchored=true;counter.CanCollide=false;counter.CanQuery=false
 counter.Position=Vector3.new(1800,41,1840);counter:SetAttribute('StaffRole','Cashier');counter:SetAttribute('StaffSpot',CFrame.new(1800,40.5,1840));counter.Parent=shop
 require(game.ServerScriptService.ShopStaff)(shop)
 check(waitFor(function() return shop:FindFirstChild('Cashier') end,4),'Real shop staff system creates a nearby clerk')
 local clerk=shop.Cashier
 local human=a.Character.Humanoid;human.MaxHealth=1000;human.Health=1000
 cop.Humanoid.MaxHealth=1000;cop.Humanoid.Health=1000
 assert(game.ServerStorage.TestReceipt:Invoke(a,{PlayerId=a.UserId,ProductId=3732000729,PurchaseId='encounter-test'})=='PurchaseGranted')
 local pistol=a.Backpack:WaitForChild('Pistol',5)
 check(call(a,'Equip',{Name='Pistol'}) and waitFor(function() return pistol.Parent==a.Character end,3),'Client equips its owned pistol and server confirms it')
 local health=human.Health
 call(a,'Shoot',{Position=cop.UpperTorso.Position})
 local accepted=waitFor(function() return pistol:GetAttribute('Ammo')==11 end,3)
 check(accepted,string.format('Server accepts the first live weapon shot after spawn completion (ammo=%s equipped=%s protected=%s health=%s surrendered=%s at=%s)',
  tostring(pistol:GetAttribute('Ammo')),tostring(pistol.Parent==a.Character),tostring(a.Character:FindFirstChildOfClass('ForceField')~=nil),tostring(human.Health),tostring(a:GetAttribute('Surrendered')),tostring(a.Character.HumanoidRootPart.Position)))
 local reacted=waitFor(function() return a:GetAttribute('Heat')>=1 and cop:GetAttribute('Activity')=='Engaging' end,5)
 check(reacted,string.format('Officer reacts to a witnessed real weapon attack (heat=%s, activity=%s, ammo=%s, equipped=%s, protected=%s, player=%s, officer=%s)',
  tostring(a:GetAttribute('Heat')),tostring(cop:GetAttribute('Activity')),tostring(pistol:GetAttribute('Ammo')),
  tostring(pistol.Parent==a.Character),tostring(a.Character:FindFirstChildOfClass('ForceField')~=nil),
  tostring(a.Character.HumanoidRootPart.Position),tostring(cop.HumanoidRootPart.Position)))
 check(waitFor(function() return human.Health<health and (cop:GetAttribute('Magazine') or 12)<12 end,6),'Officer fire consumes ammunition and hits the attacking resident')
 check(medic:GetAttribute('Activity')=='Waiting for a safe scene','Paramedic holds off during the exchange of fire')
 check(waitFor(function() return clerk:GetAttribute('Activity')=='Taking shelter' end,3),'Clerk beyond visual range shelters after hearing real gunfire')
 -- A bystander crossing the muzzle must suppress fire, not merely absorb it.
 local midpoint=(cop.Head.Position+cop.HumanoidRootPart.CFrame.LookVector*.8+a.Character.HumanoidRootPart.Position)/2
 local torsoOffset=b.Character.UpperTorso.Position-b.Character.HumanoidRootPart.Position
 park(b.Character,midpoint-torsoOffset)
 check(not require(game.ServerScriptService.NpcSight).clearShot(cop,a.Character),'Bystander torso actually intersects the firing line')
 task.wait(.6)
 local held=cop:GetAttribute('Magazine');local protectedHealth=human.Health
 task.wait(1)
 check(cop:GetAttribute('Magazine')==held and human.Health>=protectedHealth,string.format('Officer holds fire while a bystander blocks the firing lane (ammo %s -> %s, health %s -> %s, clear=%s, bystander=%s)',
  tostring(held),tostring(cop:GetAttribute('Magazine')),tostring(protectedHealth),tostring(human.Health),tostring(require(game.ServerScriptService.NpcSight).clearShot(cop,a.Character)),tostring(b.Character.HumanoidRootPart.Position)))
 park(b.Character,Vector3.new(1860,44,1830))
 -- Let the real pathfinder and humanoid perform the authored combat footwork.
 local beforeMove=cop.HumanoidRootPart.Position
 cop.HumanoidRootPart.Anchored=false
 check(waitFor(function() return ((cop.HumanoidRootPart.Position-beforeMove)*Vector3.new(1,0,1)).Magnitude>2 end,6),'Officer moves to a clear lateral firing position')
 park(cop,Vector3.new(1800,44,1800))
 local medicalStart=medic.HumanoidRootPart.Position
 medic.HumanoidRootPart.Anchored=false
 check(waitFor(function() return ((medic.HumanoidRootPart.Position-medicalStart)*Vector3.new(1,0,1)).Magnitude>2 end,6),'Paramedic moves away from an active exchange of fire')
 park(medic,Vector3.new(1825,44,1800))
 local emptied,reloaded=false,false
 local deadline=os.clock()+15;local refresh=os.clock()+3
 repeat
  local count=cop:GetAttribute('Magazine')
  if count==0 then emptied=true end
  if emptied and count==12 then reloaded=true end
  if os.clock()>=refresh then call(a,'Shoot',{Position=cop.UpperTorso.Position});refresh=os.clock()+3 end
  task.wait(.1)
 until reloaded or os.clock()>=deadline
 check(emptied and reloaded,'Officer empties and reloads a bounded magazine in the running game')
 call(a,'Surrender');task.wait(.5);health=human.Health
 local rounds=cop:GetAttribute('Magazine');task.wait(1.3)
 check(human.Health>=health and cop:GetAttribute('Magazine')==rounds,'Surrender stops police fire')
 check((a:GetAttribute('CustodyUntil') or 0)==0,'Officer cannot remotely cuff a distant surrendered player')
 call(a,'Surrender');check(call(a,'Equip',{Name='Pistol'}),'Resident re-equips after lowering hands')
 local wall=Instance.new('Part');wall.Name='Encounter sight blocker';wall.Anchored=true;wall.Size=Vector3.new(40,18,2);wall.Position=Vector3.new(1800,48,1760);wall.Parent=workspace
 park(a.Character,Vector3.new(1800,44,1748),Vector3.xAxis);task.wait(.5)
 call(a,'Shoot',{Position=Vector3.new(1860,44,1748)})
 check(waitFor(function() return a:GetAttribute('PoliceContact')=='Searching' and cop:GetAttribute('Activity')=='Searching' end,4),'A heard shot behind cover produces a search instead of visual tracking')
 health=human.Health;rounds=cop:GetAttribute('Magazine');task.wait(1.5)
 check(human.Health>=health and cop:GetAttribute('Magazine')==rounds,'Solid cover prevents police firing through the wall')
 call(a,'Surrender');park(a.Character,Vector3.new(1800,44,1796.5),Vector3.zAxis)
 check(waitFor(function() return (a:GetAttribute('CustodyUntil') or 0)>os.time() end,8),'Nearby surrendered suspect is booked after a sustained arrest')
 local intake=workspace.Baltimore['Patapsco Detention Center'].Intake
 check((a.Character:GetPivot().Position-intake.Position).Magnitude<10,'Arrest delivers the resident to prison intake')
 shop:Destroy()
end)
print(ok and 'NORTHSIDE_ENCOUNTERS_PASS' or 'NORTHSIDE_ENCOUNTERS_FAIL',err or '')
test:EndTest({ok=ok,error=err})
