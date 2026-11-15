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
 local car
 for _,m in city['Motor pool']:GetChildren() do if m:GetAttribute('FleetNumber')==2 then car=m end end
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
   local seen={}; local stop=os.clock()+40
   repeat
    local axes={}
    for _,h in junction do
     local axis=h:GetAttribute('Axis'); local phase=h:GetAttribute('Phase')
     assert(not axes[axis] or axes[axis]==phase,'Opposite heads disagree'); axes[axis]=phase
     local ped=h['Crossing signal'].SurfaceGui
     assert(ped.Walk.Visible==(phase=='Green') and ped.Stop.Visible~=ped.Walk.Visible,'Pedestrian indication disagrees')
     assert(h[phase].Material==Enum.Material.Neon,'Dark active lens')
    end
    assert(axes[0]=='Red' or axes[1]=='Red','Conflicting phases')
    seen[axes[0]..'/'..axes[1]]=true
    task.wait(.12)
   until os.clock()>stop or (seen['Green/Red'] and seen['Amber/Red'] and seen['Red/Red'] and seen['Red/Green'] and seen['Red/Amber'])
   check(seen['Green/Red'] and seen['Amber/Red'] and seen['Red/Red'] and seen['Red/Green'] and seen['Red/Amber'],'Both directions cycle through green, amber and all red with matching crossings')
  end)
  trafficError=not passed and tostring(message) or nil; trafficDone=true
 end)
 sit(); car:SetAttribute('Fuel',1)
 local start=car.Chassis.Position
 call('DriveInput',{gas=1,steer=0,duration=5}); task.wait(1)
 print('DRIVE_DISTANCE',(car.Chassis.Position-start).Magnitude,car:GetAttribute('Fuel'))
 check((car.Chassis.Position-start).Magnitude>50 and car:GetAttribute('Fuel')==0,'Driving spends the final fuel unit')
 start=car.Chassis.Position; call('DriveInput',{gas=1,steer=0,duration=1.4})
 check((car.Chassis.Position-start).Magnitude<2,'An empty tank cannot accelerate')
 human.Sit=false; task.wait(.6)
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
end)
print(ok and 'STREETS_RUN_PASS' or 'STREETS_RUN_FAIL',err or '')
test:EndTest({ok=ok,error=err})
