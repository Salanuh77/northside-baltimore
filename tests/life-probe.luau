local players=game:GetService('Players')
local test=game:GetService('StudioTestService')
local drive=game.ReplicatedStorage:WaitForChild('TestDrive')
local city=workspace:WaitForChild('Baltimore')
local errors={}
game:GetService('ScriptContext').Error:Connect(function(msg,_,source) if source and ({CityServer=true,CityClient=true,NeighborhoodLife=true,LifeUI=true,Responders=true,TrafficServer=true,WorkService=true})[source.Name] then table.insert(errors,msg) end end)
local function check(ok,label) assert(ok,label); print('LIFE_PASS',label) end
local function call(p,k,d) return drive:InvokeClient(p,k,d or {}) end
local function move(p,pos)
 p.Character:PivotTo(CFrame.new(pos)); p.Character.HumanoidRootPart.Anchored=true; p:RequestStreamAroundAsync(pos,4); task.wait(.4)
end
local function find(kind,name)
 for _,v in city:GetDescendants() do if v:GetAttribute('Action')==kind and (not name or v.Parent.Name==name) then return v end end
 error('Missing '..kind)
end
local function approach(p,v) move(p,v.Position+v.CFrame.LookVector*4+Vector3.new(0,1,0)) end
local ok,err=pcall(function()
 local due=os.clock()+65
 while #players:GetPlayers()<2 and os.clock()<due do task.wait(.2) end
 local a,b=table.unpack(players:GetPlayers()); assert(a and b)
 for _,p in {a,b} do
  while not p.Character or not p.Character:FindFirstChild('HumanoidRootPart') or p:GetAttribute('Cash')==nil do task.wait(.2) end
  call(p,'CreateResident',{Name='',Height='Tall',Build='Broad',Hair='Twists',Tone='Copper'})
  assert(call(p,'HUD')); local ff=p.Character:FindFirstChildOfClass('ForceField'); if ff then ff:Destroy() end
 end
 local housing=find('Residence','Lanvale Court A')
 approach(a,housing); call(a,'Lease'); check(housing:GetAttribute('Tenant')==a.UserId and a:GetAttribute('Cash')==500,'Voucher apartment can be leased without cash')
 approach(b,housing); call(b,'Lease'); check(not b:GetAttribute('Residence') or b:GetAttribute('Residence')=='','A second tenant cannot take the occupied home')
 call(a,'HostParty'); check(a:GetAttribute('Hosting') and housing:FindFirstChild('HouseMix'),'House party starts with local music')
 call(a,'InviteParty',{Target=b.UserId}); check(b:GetAttribute('InvitedBy')==a.UserId,'Phone party invite reaches guest')
 call(b,'PartyReply',{Accept=true}); check(b:GetAttribute('InvitedBy')==nil,'Guest accepts invitation')
 call(a,'EndParty'); check(not a:GetAttribute('Hosting') and not housing:FindFirstChild('HouseMix'),'Ending party removes music')
 call(a,'ReleaseHome'); check(not housing:GetAttribute('Tenant'),'Unit returns to leasing pool')
 local premium=find('Residence','Harbor East Residence 1')
 approach(a,premium); call(a,'Lease'); check(a:GetAttribute('Cash')==300 and premium:GetAttribute('Tenant')==a.UserId,'Waterfront lease charges the listed fee')
 local till=find('Mart','Franklin Fuel'); approach(a,till); call(a,'BuySupply',{Item='Sandwich'}); call(a,'BuySupply',{Item='Flashlight'})
 check(a:GetAttribute('Cash')==266 and a:GetAttribute('BagSandwich')==1,'Fuel mart sells items into the inventory')
 a.Character.Humanoid.Health=45; call(a,'UseSupply',{Item='Sandwich'})
 check(a.Character.Humanoid.Health>=67 and a:GetAttribute('BagSandwich')==0,'Food restores health and consumes one serving')
 call(a,'UseSupply',{Item='Flashlight'}); check(a.Character.Head:FindFirstChild('Handlamp'),'Reusable flashlight illuminates')
 local pump=find('Fuel','Franklin Fuel'); local car=city['Motor pool']:GetChildren()[1]; local bay=pump.Position+pump.CFrame.LookVector*9
 car:PivotTo(CFrame.new(bay.X,2.7,bay.Z)*car.Chassis.CFrame.Rotation); car:SetAttribute('Fuel',55); task.wait(1.2)
 approach(a,pump); for i=1,3 do call(a,'Prompt',pump); if car:GetAttribute('Fuel')==100 then break end end; print('PUMP_TEST',car:GetAttribute('Fuel'),a:GetAttribute('Cash'),(car.Chassis.Position-pump.Position).Magnitude); check(car:GetAttribute('Fuel')==100 and a:GetAttribute('Cash')==257,'Fuel pump fills nearby tank and charges cash')
 local dj=find('Club'); approach(a,dj); call(a,'ClubMix'); check(dj.Afterhours.PlaybackSpeed>1,'Club DJ changes the music tempo')
 local bots=workspace:WaitForChild('Emergency responders'); check(#bots:GetChildren()==4,'Police and paramedic bots spawn')
 move(a,Vector3.new(-520,5,-321)); move(b,Vector3.new(-515,5,-321))
 call(a,'ApplyJob',{Role='medic'}); call(a,'StartShift'); b.Character.Humanoid.Health=48
 local start=a:GetAttribute('Cash'); call(a,'Assist',{Target=b.UserId})
 check(b.Character.Humanoid.Health==100 and a:GetAttribute('Cash')==start+85,'On-duty player medic treats a patient and earns pay')
 call(a,'CancelShift'); call(a,'ApplyJob',{Role='police'}); call(a,'StartShift'); check(a:GetAttribute('Employment')=='police','Police career accepts a player on duty')
 local desk,drop
 for _,v in city:GetDescendants() do if v:GetAttribute('Station')=='NightDesk' then desk=v elseif v:GetAttribute('Station')=='NightDrop' then drop=v end end
 workspace:SetAttribute('TestMinute',1320);task.wait(1.3)
 approach(b,desk); call(b,'ApplyJob',{Role='night'}); call(b,'StartShift'); call(b,'Prompt',desk); approach(b,drop); task.wait((drop.Position-desk.Position).Magnitude/65+.7); call(b,'Prompt',drop)
 check(b:GetAttribute('Heat')>0,'Off-book shift produces an actual police case')
 call(b,'Surrender'); move(a,b.Character:GetPivot().Position+Vector3.new(3,0,0)); start=a:GetAttribute('Cash'); call(a,'Assist',{Target=b.UserId})
 check(b:GetAttribute('Heat')==0 and not b:GetAttribute('Surrendered') and a:GetAttribute('Cash')==start+95,'On-duty player officer processes a surrendered wanted character')
 local visitorDesk=city['Patapsco Detention Center']['Visitor bail window']
 approach(a,visitorDesk); call(a,'PostBail',{Target=b.UserId}); check(b:GetAttribute('CustodyUntil')==0,'On-duty officer can post visitor bail')
 local bot=bots:FindFirstChild('City paramedic'); move(b,bot:GetPivot().Position+Vector3.new(3,1,0)); b.Character.Humanoid.Health=42; call(b,'CallResponder',{Role='medic'})
 local limit=os.clock()+15; while b.Character.Humanoid.Health<95 and os.clock()<limit do task.wait(.25) end
 check(b.Character.Humanoid.Health>=95,'NPC paramedic answers and treats an injured player')
 call(a,'CancelShift')
 local courierDesk=find('Job')
 approach(a,courierDesk)
 local cashBefore=a:GetAttribute('Cash')
 call(a,'Prompt',courierDesk)
 local taskText=a:GetAttribute('ShiftTask')
 local mailbox
 for _,part in city:GetDescendants() do
  if part:GetAttribute('Action')=='Delivery' and taskText=='Deliver to '..tostring(part:GetAttribute('Label')) then mailbox=part; break end
 end
 check(mailbox~=nil,'Courier pickup names a real mailbox')
 check(call(a,'JobArrow',{Label=mailbox:GetAttribute('Label')}),'Active courier arrow names the mailbox')
 approach(a,mailbox)
 task.wait((mailbox.Position-courierDesk.Position).Magnitude/60+.6)
 call(a,'Prompt',mailbox)
 check(a:GetAttribute('Cash')==cashBefore+90 and a:GetAttribute('ShiftTask')=='','Community delivery pays the advertised $90 and ends the route')
 check(call(a,'JobArrow',{Hidden=true}),'Courier compass clears on payment')
 call(a,'Prompt',mailbox)
 check(a:GetAttribute('Cash')==cashBefore+90,'Repeated mailbox prompt cannot duplicate the payout')
 check(#errors==0,'No gameplay script runtime errors')
end)
print(ok and 'NORTHSIDE_LIFE_PASS' or 'NORTHSIDE_LIFE_FAIL',err or '')
test:EndTest({ok=ok,error=err})