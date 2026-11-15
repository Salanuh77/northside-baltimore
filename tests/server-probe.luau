local Players=game:GetService('Players')
local STS=game:GetService('StudioTestService')
local drive=game:GetService('ReplicatedStorage'):WaitForChild('TestDrive')
local city=workspace:WaitForChild('Baltimore')
local failures={}
game:GetService('ScriptContext').Error:Connect(function(message,stack,source)
 if source and (source.Name=='CityServer' or source.Name=='CityClient' or source.Name=='TrafficServer' or source.Name=='TrafficClient' or source.Name=='WorkService') then table.insert(failures,message) end
end)
local function check(value,message) assert(value,message); print('GAMEPLAY_PASS',message) end
local function find(kind)
 for _,v in city:GetDescendants() do if v:IsA('BasePart') and v:GetAttribute('Action')==kind then return v end end
end
local function move(p,pos)
 local root=p.Character.HumanoidRootPart
 root.Anchored=true
 p.Character:PivotTo(CFrame.new(pos)*root.CFrame:ToObjectSpace(p.Character:GetPivot()))
 p:RequestStreamAroundAsync(pos,3); task.wait(0.3)
end
local function call(p,kind,data) drive:InvokeClient(p,kind,data or {}) end
local ok,err=pcall(function()
 local deadline=os.clock()+55
 while #Players:GetPlayers()<2 and os.clock()<deadline do task.wait(0.5) end
 local ps=Players:GetPlayers(); check(#ps==2,'Two clients joined')
 local a,b=ps[1],ps[2]
 for _,p in ps do
  while (not p.Character or not p.Character:FindFirstChild('HumanoidRootPart') or p:GetAttribute('Cash')==nil) and os.clock()<deadline do task.wait(0.2) end
  call(p,'CreateResident',{Name='',Height='Tall',Build='Broad',Hair='Twists',Tone='Copper'})
  call(p,'HUD'); check(p:GetAttribute('Cash')==500,'Initial balance and HUD '..p.Name)
  local ff=p.Character:FindFirstChildOfClass('ForceField'); if ff then ff:Destroy() end
 end
 local car
 for _,m in city['Motor pool']:GetChildren() do if m:GetAttribute('FleetNumber')==2 then car=m end end
 a.Character.Humanoid:UnequipTools()
 move(a,car.Driver.Position+Vector3.new(-5,1,0)); a.Character.HumanoidRootPart.Anchored=false
 for attempt=1,3 do
  if car.Driver.Occupant==a.Character.Humanoid then break end
  call(a,'Prompt',car.Driver); task.wait(.4)
 end
 check(car.Driver.Occupant==a.Character.Humanoid,'Driver prompt seats player')
 local start=car.Chassis.Position
 print('DRIVE start',start,car.Chassis.CFrame.LookVector)
 call(a,'DriveInput',{gas=1,steer=0,duration=.86})
 check((car.Chassis.Position-start).Magnitude>7,'Vehicle accelerates under native seat input')
 local facing=car.Chassis.CFrame.LookVector
 call(a,'DriveInput',{gas=1,steer=.65,duration=.87})
 print('DRIVE turn',car.Chassis.Position,car.Chassis.CFrame.LookVector,facing,car.Chassis.AlignOrientation.CFrame.LookVector,car.Chassis.LinearVelocity.PlaneVelocity,car.Driver.Occupant)
 local thrust=car.Chassis.LinearVelocity.PlaneVelocity
 local body=car.Chassis.CFrame.LookVector
 check(facing:Dot(body)<.97,'Vehicle steering changes heading')
 check(thrust.Magnitude>1 and thrust.Unit:Dot(Vector2.new(body.X,body.Z).Unit)>.96,'Thrust follows actual chassis heading')
 a.Character.Humanoid.Sit=false; task.wait(.5)
 check(car.Driver.Occupant==nil,'Driver can exit')
 local reverseCar
 for _,model in city['Motor pool']:GetChildren() do if model:GetAttribute('FleetNumber')==3 then reverseCar=model end end
 move(a,reverseCar.Driver.Position+Vector3.new(-5,1,0)); a.Character.HumanoidRootPart.Anchored=false
 for attempt=1,3 do
  if reverseCar.Driver.Occupant==a.Character.Humanoid then break end
  call(a,'Prompt',reverseCar.Driver); task.wait(.4)
 end
 assert(reverseCar.Driver.Occupant==a.Character.Humanoid,'Reverse car entry')
 task.wait(.65)
 local driver,head=reverseCar.Driver,a.Character.Head
 local top=driver.CFrame:PointToObjectSpace(head.Position).Y+head.Size.Y/2
 for _,lock in head['Northside hair']:GetChildren() do top=math.max(top,driver.CFrame:PointToObjectSpace(lock.Position).Y+lock.Size.Y/2) end
 check(top<=driver:GetAttribute('CabinCeiling')+.1,'Foundry V8 driver fits underneath the roof')
 local reverseStart=reverseCar.Chassis.Position
 local reverseHeading=reverseCar.Chassis.CFrame.LookVector
 call(a,'DriveInput',{gas=-1,steer=0,duration=2})
 check((reverseCar.Chassis.Position-reverseStart):Dot(reverseHeading)<-3,'Vehicle reverses under native seat input')
 a.Character.Humanoid.Sit=false; task.wait(.4)
 local head=city['Streets & alleys']['Traffic signals']:GetChildren()[1]
 local initial=head:GetAttribute('Phase'); local changed=false
 for i=1,70 do task.wait(.25); if head:GetAttribute('Phase')~=initial then changed=true; break end end
 check(changed,'Junction signals advance through phases')
 local apt=city['Lanvale Courts']['Lanvale Court A']
 local path=game:GetService('PathfindingService'):CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=true})
 local highest
 for _,p in apt:GetChildren() do if p.Name=='Apartment lockbox' and (not highest or p.Position.Y>highest.Position.Y) then highest=p end end
 local door=apt['Entrance walk']
 path:ComputeAsync(door.Position+Vector3.new(0,3,0),highest.Position+Vector3.new(0,2,3))
 if path.Status~=Enum.PathStatus.Success then
  local origin=door.CFrame*CFrame.new(0,.85,33)
  local last=door.Position+Vector3.new(0,3,0)
  for _,q in {{31,3,-18},{31,16,20},{42,16,-21},{31,29,20},{42,29,-21},{31,42,20},{42,42,-21},{-36,42,-21},{-36,42,-10},{-36,42,8}} do
   local goal=origin:PointToWorldSpace(Vector3.new(table.unpack(q)))
   path:ComputeAsync(last,goal)
   print('NAV_SEGMENT',q[1],q[2],q[3],path.Status.Name)
   last=goal
  end
  error('No complete top-floor navigation path')
 end
 check(path.Status==Enum.PathStatus.Success,'Street entrance connects to a furnished top-floor apartment')
 move(a,Vector3.new(-240,5,320)); move(b,Vector3.new(-235,5,320))
 call(a,'Pay',{Target=b.UserId,Amount=50})
 check(a:GetAttribute('Cash')==450 and b:GetAttribute('Cash')==550,'Payment conserves currency')
 for _,n in {-50,0,0/0,math.huge,0.5,999999999} do call(a,'Pay',{Target=b.UserId,Amount=n}) end
 check(a:GetAttribute('Cash')==450 and b:GetAttribute('Cash')==550,'Invalid payment values rejected')
 call(a,'Buy',{Item='Pistol'}); check(a:GetAttribute('Cash')==450,'Remote market purchase rejected')
 local market=find('Market'); move(a,market.Position+Vector3.new(0,2,-5))
 call(a,'Buy',{Item='Crowbar'}); assert(game.ServerStorage.TestReceipt:Invoke(a,{PlayerId=a.UserId,ProductId=3732000729,PurchaseId='gameplay-test'})=='PurchaseGranted')
 check(a:GetAttribute('Cash')==360,'Market prices enforced')
 check(a.Backpack:FindFirstChild('Crowbar') and a.Backpack:FindFirstChild('Pistol'),'Purchased tools granted')
 call(a,'Buy',{Item='Pistol'}); check(a:GetAttribute('Cash')==360,'Duplicate purchase rejected')
 move(a,Vector3.new(-240,5,320)); move(b,Vector3.new(-235,5,320))
 call(a,'Offer',{Target=b.UserId,Item='Crowbar',Amount=40}); call(b,'Accept')
 check(a:GetAttribute('Cash')==400 and b:GetAttribute('Cash')==510,'Trade settles both balances')
 check(not a.Backpack:FindFirstChild('Crowbar') and b.Backpack:FindFirstChild('Crowbar'),'Trade transfers item once')
 call(b,'Accept'); check(b:GetAttribute('Cash')==510,'Trade cannot be accepted twice')
 a.Character.Humanoid:EquipTool(a.Backpack.Pistol); task.wait(0.3)
 call(b,'Surrender'); check(b:GetAttribute('Surrendered'),'Surrender sets server state')
 call(a,'RobPlayer',{Target=b.UserId}); task.wait(8.5)
 check(a:GetAttribute('Cash')==527 and b:GetAttribute('Cash')==383,'Timed player robbery transfers capped cash')
 call(a,'RobPlayer',{Target=b.UserId}); task.wait(0.5)
 check(b:GetAttribute('Cash')==383,'Repeat robbery cooldown enforced')
 call(b,'Surrender')
 local pistol=a.Character.Pistol
 call(a,'ActivatePistol')
 check(pistol:GetAttribute('Ammo')==11,'Equipped tool activation fires a shot')
 call(a,'Reload'); task.wait(2.2)
 local health=b.Character.Humanoid.Health
 call(a,'Shoot',{Position=b.Character.Head.Position})
 check(b.Character.Humanoid.Health<=health-22,'Server raycast damages valid target')
 check(pistol:GetAttribute('Ammo')==11,'Firing consumes ammunition')
 call(a,'Reload'); task.wait(2.2); check(pistol:GetAttribute('Ammo')==12,'Reload restores magazine after delay')
 move(b,Vector3.new(160,5,34)); move(a,Vector3.new(164,5,34))
 health=b.Character.Humanoid.Health; call(a,'Shoot',{Position=b.Character.Head.Position})
 check(b.Character.Humanoid.Health>=health and pistol:GetAttribute('Ammo')==12,'Safe zone blocks combat')
 local atm=find('Bank'); move(a,atm.Position+Vector3.new(0,1,-5))
 call(a,'Bank',{Mode='Deposit',Amount=100})
 local deadline=os.clock()+3
 while a:GetAttribute('Bank')~=100 and os.clock()<deadline do task.wait(.1) end
 local ray=RaycastParams.new();ray.FilterDescendantsInstances={a.Character};ray.FilterType=Enum.RaycastFilterType.Exclude
 local eye=a.Character.HumanoidRootPart.Position+Vector3.new(0,1.5,0)
 local hit=workspace:Raycast(eye,atm.Position-eye,ray)
 check(a:GetAttribute('Cash')==427 and a:GetAttribute('Bank')==100,('ATM deposit conserves funds (cash %s, bank %s, custody %s, eye %s, line %s)'):format(a:GetAttribute('Cash'),a:GetAttribute('Bank'),a:GetAttribute('CustodyUntil'),tostring(eye),hit and hit.Instance:GetFullName() or 'clear'))
 call(a,'Bank',{Mode='Withdraw',Amount=40}); check(a:GetAttribute('Cash')==467 and a:GetAttribute('Bank')==60,'ATM withdrawal conserves funds')
 -- Wait at the community center while the second player tests housing. The officer on the previous street can book a wanted player.
 move(a,city.CommunitySpawn.Position+Vector3.new(0,3,0)); call(a,'Bank',{Mode='Withdraw',Amount=60})
 check(a:GetAttribute('Bank')==60,'Remote ATM access rejected')
 -- Exercise real ProximityPrompt input, including cancellation and cooldowns.
 local home=highest; move(b,home.Position+Vector3.new(0,2,-4))
 b.Character.Humanoid:EquipTool(b.Backpack.Crowbar); task.wait(0.3)
 call(b,'Prompt',home); check(home:GetAttribute('InUse'),'Home robbery starts from a real prompt')
 move(b,Vector3.new(-240,5,320)); task.wait(0.4)
 check(not home:GetAttribute('InUse') and b:GetAttribute('Loot')==0,'Leaving cancels home robbery without reward')
 move(b,home.Position+Vector3.new(0,2,-4)); call(b,'Prompt',home); task.wait(9.5)
 check(b:GetAttribute('Loot')==1,'Completed home robbery awards stolen goods')
 local fence=find('Fence'); move(b,fence.Position+Vector3.new(0,2,-5)); call(b,'Prompt',fence)
 check(b:GetAttribute('Loot')==0 and b:GetAttribute('Cash')==493,'Fence exchanges goods for cash once')
 local register=city['Inner Harbor • Quay District']['Boiler House Market']['Market till']; move(a,register.Position+register.CFrame.LookVector*5+Vector3.new(0,1,0))
 check(a:GetAttribute('CustodyUntil')==0 and a.Character:FindFirstChild('Pistol'),'Customer-side approach with equipped pistol outside custody')
 for attempt=1,3 do
  call(a,'Prompt',register); if register:GetAttribute('InUse') then break end
 end
 check(register:GetAttribute('InUse'),'Harbor market register starts from a real prompt')
 task.wait(12.5)
 check(a:GetAttribute('Cash')==692,'Completed store robbery pays reward')
 call(a,'Prompt',register); task.wait(0.3)
 check(a:GetAttribute('Cash')==692 and not register:GetAttribute('InUse'),'Store cooldown rejects repeat robbery')
 check(a.Backpack:FindFirstChild('Phone'),'Players receive a handheld phone')
 a.Character.Humanoid:EquipTool(a.Backpack.Phone)
 call(a,'PhoneScreen')
 check(a.Character:FindFirstChild('Phone'),'Equipping the handset opens the phone UI')
 a.Character.Humanoid:UnequipTools()
 check(a:GetAttribute('ReserveAmmo')==10,'Reloads consume reserve rounds')
 local balance=a:GetAttribute('Cash')
 call(a,'BuyAmmo'); check(a:GetAttribute('ReserveAmmo')==10,'Off-site ammo purchase rejected')
 move(a,market.Position+Vector3.new(0,2,-5)); call(a,'BuyAmmo')
 check(a:GetAttribute('ReserveAmmo')==22 and a:GetAttribute('Cash')==balance-30,'Ammo box charges cash and adds twelve rounds')
 local stops={}
 for _,part in city:GetDescendants() do if part:GetAttribute('Station') then stops[part:GetAttribute('Station')]=part end end
 local function workShift(id,pickup,drop,pay)
  workspace:SetAttribute('TestMinute',id=='night' and 1320 or 840);task.wait(1.2)
  local first,last=stops[pickup],stops[drop]
  move(a,first.Position+Vector3.new(0,0,-4))
  call(a,'ApplyJob',{Role=id}); check(a:GetAttribute('Employment')==id,'Application accepted for '..id)
  local opening=a:GetAttribute('Cash'); local wages=a:GetAttribute('Wages')
  call(a,'StartShift'); check(a:GetAttribute('ShiftTask')~='','Phone starts '..id..' shift')
  call(a,'StartShift'); call(a,'Prompt',first)
  move(a,last.Position+Vector3.new(0,0,-4)); task.wait((last.Position-first.Position).Magnitude/65+.4)
  local heat=a:GetAttribute('Heat'); call(a,'Prompt',last); check(a:GetAttribute('Cash')==opening+pay and a:GetAttribute('Wages')==wages+pay and a:GetAttribute('ShiftTask')=='','Completed '..id..' shift pays once')
  call(a,'Prompt',last); check(a:GetAttribute('Cash')==opening+pay,'Duplicate '..id..' delivery pays nothing')
  if id=='night' then check(a:GetAttribute('Heat')==math.min(5,heat+1),'Off-book shift raises wanted level') end
 end
 workShift('porter','Lobby','Recycling',125); workShift('night','NightDesk','NightDrop',190)
 call(a,'StartShift'); call(a,'CancelShift'); check(a:GetAttribute('ShiftTask')=='','Phone can cancel a shift')
 call(a,'Resign'); check(a:GetAttribute('Employment')=='','Player can resign')
 local tower=city['Eastside • Harbor View Homes']['Harbor View Tower']
 local ground,top
 for _,p in tower:GetChildren() do if p:GetAttribute('Floor')==1 then ground=p elseif p:GetAttribute('Landing')==12 then top=p end end
 move(a,ground.Position+Vector3.new(0,0,3))
 call(a,'RideLift',{Floor=12})
 check((a.Character.HumanoidRootPart.Position-top.Position).Magnitude<7,'Estate lift reaches the twelfth-floor gallery')
 check(#failures==0,'No game script runtime errors')
end)
print(ok and 'SQUISHY_MULTIPLAYER_PASS' or 'SQUISHY_MULTIPLAYER_FAIL',err or '')
STS:EndTest({ok=ok,error=err})
