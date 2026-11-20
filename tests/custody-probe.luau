local players=game:GetService('Players')
local test=game:GetService('StudioTestService')
local remote=game.ReplicatedStorage:WaitForChild('TestDrive')
local city=workspace:WaitForChild('Baltimore')
local function check(ok,name) assert(ok,name); print('STREETS_PASS',name) end
local function move(p,pos)
 p.Character:PivotTo(CFrame.new(pos)); p:RequestStreamAroundAsync(pos,6); task.wait(.7)
end
local ok,err=pcall(function()
 local deadline=os.clock()+95
 repeat task.wait(.2) until #players:GetPlayers()>=2 or os.clock()>deadline
 local p=players:GetPlayers()[1]; assert(p)
 repeat task.wait(.25) until p.Character and p:GetAttribute('Cash') or os.clock()>deadline
 local human=p.Character.Humanoid
 local function call(kind,data) return remote:InvokeClient(p,kind,data or {}) end
 for _,resident in players:GetPlayers() do remote:InvokeClient(resident,'CreateResident',{Name='',Height='Tall',Build='Broad',Hair='Twists',Tone='Copper'}) end
 local car
 for _,m in city['Motor pool']:GetChildren() do if m:GetAttribute('FleetNumber')==1 then car=m end end
 local function sit()
  move(p,car.Driver.Position+Vector3.new(-5,2,0))
  for i=1,3 do if car.Driver.Occupant==human then break end; call('Prompt',car.Driver); task.wait(.3) end
  check(car.Driver.Occupant==human,'Driver enters the remodeled car')
 end
 local junction={}
 for _,h in city['Streets & alleys']['Traffic signals']:GetChildren() do
  if h:GetAttribute('Junction')=='3-3' then table.insert(junction,h) end
 end
 check(#junction==4,'Four approach heads on a junction')
 local trafficDone,trafficError=false,nil
 task.spawn(function()
  local passed,message=pcall(function()
   local seen={}; local stop=os.clock()+40;local clearanceOn,clearanceOff=false,false
   repeat
    local axes={}
    for _,h in junction do
     local axis=h:GetAttribute('Axis'); local phase=h:GetAttribute('Phase')
     assert(not axes[axis] or axes[axis]==phase,'Opposite heads disagree'); axes[axis]=phase
     local ped=h['Crossing signal'].SurfaceGui
     assert(not (ped.Walk.Visible and ped.Stop.Visible),'Both pedestrian symbols are lit')
     assert(phase=='Green' or (not ped.Walk.Visible and ped.Stop.Visible),'Crossing stays stopped throughout amber and red')
     if phase=='Green' and not ped.Walk.Visible then
      if ped.Stop.Visible then clearanceOn=true else clearanceOff=true end
     end
     assert(h[phase].Material==Enum.Material.Neon,'Dark active lens')
    end
    assert(axes[0]=='Red' or axes[1]=='Red','Conflicting phases')
    seen[axes[0]..'/'..axes[1]]=true
    task.wait(.12)
   until os.clock()>stop or (seen['Green/Red'] and seen['Amber/Red'] and seen['Red/Red'] and seen['Red/Green'] and seen['Red/Amber'] and clearanceOn and clearanceOff)
   check(seen['Green/Red'] and seen['Amber/Red'] and seen['Red/Red'] and seen['Red/Green'] and seen['Red/Amber'] and clearanceOn and clearanceOff,'Both directions cycle safely and the crossing hand flashes before amber')
  end)
  trafficError=not passed and tostring(message) or nil; trafficDone=true
 end)
 sit();task.wait(.85)
 local seat=car.Driver
 local glassTop=seat:GetAttribute('CabinCeiling')
 local head=p.Character.Head
 local hair=head:FindFirstChild('Northside hair')
 local top=seat.CFrame:PointToObjectSpace(head.Position).Y+head.Size.Y/2
 for _,lock in hair:GetChildren() do top=math.max(top,seat.CFrame:PointToObjectSpace(lock.Position).Y+lock.Size.Y/2) end
 check(top<=glassTop+.10 and math.abs(seat.CFrame:PointToObjectSpace(head.Position).X)<.55,'Tall broad driver and hairstyle fit below GT roof and within the seat')
 car:SetAttribute('Fuel',1)
 check(call('MeshLoad',{number=1}),'Client loads the detailed GT mesh assets')
 local start=car.Chassis.Position
 call('DriveInput',{gas=1,steer=0,duration=5}); task.wait(1)
 print('DRIVE_DISTANCE',(car.Chassis.Position-start).Magnitude,car:GetAttribute('Fuel'))
 check((car.Chassis.Position-start).Magnitude>50 and car:GetAttribute('Fuel')==0,'Driving spends the final fuel unit')
 start=car.Chassis.Position; call('DriveInput',{gas=1,steer=0,duration=1.4})
 check((car.Chassis.Position-start).Magnitude<2,'An empty tank cannot accelerate')
 call('ExitCar')
 local exitDeadline=os.clock()+3
 local relative
 repeat
  task.wait(.1)
  relative=seat.CFrame:PointToObjectSpace(p.Character.HumanoidRootPart.Position)
 until (not human.SeatPart and math.abs(relative.X)>3) or os.clock()>=exitDeadline
 check(not human.SeatPart and math.abs(relative.X)>3 and relative.Magnitude<14,'Driver exits beside the door at '..tostring(relative))
 local pump=city:FindFirstChild('North Avenue Fuel',true):FindFirstChild('Pump face')
 local park=pump.Position+pump.CFrame.LookVector*7
 car:PivotTo(CFrame.new(park.X,2.8,park.Z)); task.wait(1)
 move(p,pump.Position+pump.CFrame.LookVector*4+Vector3.yAxis); p.Character.HumanoidRootPart.Anchored=true
 local wallet=p:GetAttribute('Cash')
 for i=1,3 do call('Prompt',pump); if car:GetAttribute('Fuel')==100 then break end end
 check(car:GetAttribute('Fuel')==100 and p:GetAttribute('Cash')==wallet-20,'Dispenser fills the empty car and charges exactly $20')
 call('Prompt',pump); check(p:GetAttribute('Cash')==wallet-20,'A full tank incurs no second charge')
 p.Character.HumanoidRootPart.Anchored=false
 sit(); start=car.Chassis.Position; call('DriveInput',{gas=1,steer=0,duration=1.5})
 print('EXIT_DISTANCE',(car.Chassis.Position-start).Magnitude,car.Chassis.Position,car.Driver.Occupant)
 check((car.Chassis.Position-start).Magnitude>7,'Refueled vehicle drives away')
 while not trafficDone do task.wait(.2) end
 assert(not trafficError,trafficError)
 human.Sit=false; task.wait(.55)
 local visitor=players:GetPlayers()[2]
 local prison=city['Patapsco Detention Center']
 local function approach(actor,part)
  move(actor,part.Position+part.CFrame.LookVector*4+Vector3.yAxis); actor.Character.HumanoidRootPart.Anchored=true
 end
 local function waitFor(fn,seconds)
  local untilT=os.clock()+seconds
  repeat if fn() then return true end; task.wait(.2) until os.clock()>=untilT
  return fn()
 end
 local market
 for _,v in city:GetDescendants() do if v:GetAttribute('Action')=='Market' then market=v; break end end
 approach(p,market); assert(game.ServerStorage.TestReceipt:Invoke(p,{PlayerId=p.UserId,ProductId=3732000729,PurchaseId='custody-test'})=='PurchaseGranted')
 local pistol=p.Backpack:WaitForChild('Pistol',5); assert(pistol); human:EquipTool(pistol)
 local field=workspace:WaitForChild('Emergency responders')
 local npc=field:WaitForChild('Westside officer')
 local function beside(actor,bot,range)
  local pos=bot:GetPivot().Position
  local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances={bot,actor.Character}
  for n=0,11 do
   local offset=Vector3.new(range*math.cos(n*math.pi/6),1.25,range*math.sin(n*math.pi/6))
   if not workspace:Raycast(pos,offset,params) then
    move(actor,pos+offset); actor.Character.HumanoidRootPart.Anchored=true; return
   end
  end
  error('Officer has no accessible approach')
 end
 beside(p,npc,12)
 for i=1,10 do
  if not npc.Parent then break end
  local hit=workspace:Raycast(p.Character.Head.Position,(npc.UpperTorso.Position-p.Character.Head.Position).Unit*80,(function()
   local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances={p.Character}; return params end)())
  call('Shoot',{Position=npc.UpperTorso.Position}); print('PATROL_SHOT',i,npc.Parent and npc.Humanoid.Health,p:GetAttribute('Heat'),pistol:GetAttribute('Ammo'),hit and hit.Instance:GetFullName()); task.wait(.1)
 end
 check(not npc.Parent and p:GetAttribute('Heat')>=3,'Player gun defeats an NPC officer and creates a wanted case')
 local officer=field['District officer']; beside(p,officer,5)
 call('Surrender'); call('CallResponder',{Role='police'})
 check(waitFor(function() return (p:GetAttribute('CustodyUntil') or 0)>os.time() end,18),'NPC officer arrests and books the player')
 check((p.Character:GetPivot().Position-prison.Intake.Position).Magnitude<9,'Booked player reaches the dayroom')
 local due=p:GetAttribute('CustodyUntil'); local cost=p:GetAttribute('Bail')
 p:LoadCharacterAsync(); check(waitFor(function() return (p.Character:GetPivot().Position-prison.Intake.Position).Magnitude<10 end,10) and p:GetAttribute('CustodyUntil')==due,'Reset preserves sentence and returns to intake')
 local before=visitor:GetAttribute('Cash')
 approach(visitor,prison['Visitor bail window']); remote:InvokeClient(visitor,'Prompt',prison['Visitor bail window'])
 remote:InvokeClient(visitor,'PostBail',{Target=p.UserId})
 check(visitor:GetAttribute('Cash')==before-cost and p:GetAttribute('CustodyUntil')==0,'Visitor pays listed bail and releases prisoner')
 check(waitFor(function() return field:FindFirstChild('Westside officer')~=nil end,24),'Defeated officer respawns')
 local function booking()
  local bot=field['Westside officer']; beside(p,bot,7)
  local char=p.Character; local h=char.Humanoid
  local ff=char:FindFirstChildOfClass('ForceField'); if ff then ff:Destroy() end
  h:EquipTool(p.Backpack.Pistol); call('Shoot',{Position=bot.UpperTorso.Position})
  check(p:GetAttribute('Heat')>=1,'Officer registers the new incident')
  call('Surrender'); check(waitFor(function() return p:GetAttribute('CustodyUntil')>os.time() end,18),'Second booking processed')
 end
 booking()
 local term=prison['Recreation game terminal']; approach(p,term); call('Prompt',term)
 local clue=call('LightClue'); check(type(clue)=='table' and #clue==4,'Prison escape puzzle appears on the player HUD')
 call('LightPress',{Symbol='Miss'}); check(p:GetAttribute('CustodyUntil')>os.time(),'Failed escape keeps sentence active')
 task.wait(5.2); call('Prompt',term); clue=call('LightClue'); assert(type(clue)=='table')
 for _,symbol in clue do call('LightPress',{Symbol=symbol}) end
 check(p:GetAttribute('CustodyUntil')==0 and p:GetAttribute('Heat')==3,'Successful escape grants wanted status outside the walls')
 task.wait(.5); beside(p,field['Westside officer'],5)
 task.wait(2)
 check(p:GetAttribute('CustodyUntil')==0,'A healthy resisting escapee is not automatically teleported back into custody')
 p.Character.Humanoid.Health=20
 check(waitFor(function() return p:GetAttribute('CustodyUntil')>os.time() end,15),'Officer subdues a wounded stationary escapee at close range')
 local expiry=p:GetAttribute('CustodyUntil')
 check(waitFor(function() return p:GetAttribute('CustodyUntil')==0 end,expiry-os.time()+4),'Full sentence expires and releases the player')
 check((p.Character:GetPivot().Position-prison.Release.Position).Magnitude<10,'Timed release returns player to visitor entrance')
end)
print(ok and 'STREETS_RUN_PASS' or 'STREETS_RUN_FAIL',err or '')
test:EndTest({ok=ok,error=err})
