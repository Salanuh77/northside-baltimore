local players=game:GetService('Players')
local test=game:GetService('StudioTestService')
local drive=game.ReplicatedStorage:WaitForChild('TestDrive')
local city=workspace:WaitForChild('Baltimore')
local function check(value,label)
 assert(value,label)
 print('HOME_PASS',label)
end
local function call(p,kind,data) return drive:InvokeClient(p,kind,data or {}) end
local function position(p,point)
 p:RequestStreamAroundAsync(point,5)
 local root=p.Character.HumanoidRootPart
 p.Character:PivotTo(CFrame.new(point)*root.CFrame:ToObjectSpace(p.Character:GetPivot()))
 root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero
 task.wait(.5)
end
local function waitFor(condition,seconds)
 local finish=os.clock()+seconds
 repeat if condition() then return true end; task.wait(.1) until os.clock()>=finish
 return condition()
end
local function walk(p,origin,x,z)
 local target=origin:PointToWorldSpace(Vector3.new(x,3,z))
 local ok,actual=call(p,'WalkTo',target)
 assert(ok,'Blocked walk toward '..tostring(target)..' from '..tostring(actual))
 assert(math.abs(p.Character.HumanoidRootPart.Position.Y-target.Y)<3,'Wrong floor')
end
local ok,err=pcall(function()
 assert(waitFor(function() return #players:GetPlayers()==2 end,65))
 local a,b=table.unpack(players:GetPlayers())
 for _,p in {a,b} do assert(waitFor(function() return p.Character and p.Character:FindFirstChild('HumanoidRootPart') and p:GetAttribute('Cash')~=nil and p:GetAttribute('ProbeSpawnFinished') end,65)) end
 local flat=assert(city:FindFirstChild('Lanvale Court A',true))
 local room=flat['Home furnishings 101']
 local door
 local tap=room['Kitchen sink'].Controls
 for _,p in flat:GetChildren() do
  if p.Name=='Apartment door' and (not door or (p.Position-tap.Position).Magnitude<(door.Position-tap.Position).Magnitude) then door=p end
 end
 local origin=door.CFrame*CFrame.new(8.7,-5.2,17)
 position(a,origin:PointToWorldSpace(Vector3.new(-8.7,3,-21)))
 local loaded,why=call(a,'PreloadFurniture',room)
 check(loaded,'Required residential furniture and all additional meshes load on client: '..tostring(why))
 call(a,'Prompt',door)
 check(door:GetAttribute('Open'),'Player opens gallery door')
 walk(a,origin,-8.7,-11)
 walk(a,origin,-4,-7)
 walk(a,origin,5,-6.6)
 local sofa=room['Living room sofa']
 local seats={}
 for _,v in sofa:GetChildren() do if v:IsA('Seat') then table.insert(seats,v) end end
 table.sort(seats,function(l,r) return (l.Position-a.Character.HumanoidRootPart.Position).Magnitude<(r.Position-a.Character.HumanoidRootPart.Position).Magnitude end)
 call(a,'Prompt',seats[1])
 check(waitFor(function() return seats[1].Occupant==a.Character.Humanoid end,2),'Walk in and sit on sofa')
 position(b,seats[2].Position+seats[2].CFrame.LookVector*3.2+Vector3.new(0,2,0))
 call(b,'Prompt',seats[2])
 check(seats[2].Occupant==b.Character.Humanoid and seats[1].Occupant==a.Character.Humanoid,'Two residents share a couch')
 call(b,'StandUp');call(a,'StandUp')
 check(waitFor(function() return not seats[1].Occupant and not seats[2].Occupant end,2),'Jump frees both seats')
 position(b,origin:PointToWorldSpace(Vector3.new(-8.7,3,-22)))
 walk(a,origin,2,-6)
 walk(a,origin,-8.6,-4)
 call(a,'Prompt',tap)
 local water=tap.Parent['Running water']
 check(water.Transparency<1,'Sink runs from the aisle')
 walk(a,origin,-8.9,.5)
 local stove=room.Stove.Controls
 a.Character.Humanoid.Health=45
 call(a,'Prompt',stove)
 check(stove:GetAttribute('InUse'),'Cooking starts at range')
 walk(a,origin,-1,-1)
 check(waitFor(function() return not stove:GetAttribute('InUse') end,2) and a.Character.Humanoid.Health<65,'Walking away cancels cooking')
 check(waitFor(function() return water.Transparency==1 end,5),'Tap shuts off')
 walk(a,origin,-8.9,.5)
 call(a,'Prompt',stove)
 check(waitFor(function() return a.Character.Humanoid.Health>=65 end,6),'Finished meal restores health')
 walk(a,origin,-10,1.5)
 walk(a,origin,-10,9)
 walk(a,origin,-5,9)
 walk(a,origin,2,9)
 local bed=room.Bed.Rest
 a.Character.Humanoid.Health=60
 call(a,'Prompt',bed)
 check(bed.Occupant==a.Character.Humanoid,'Bedroom reached on foot and bed occupied')
 check(waitFor(function()
  local torso=a.Character.UpperTorso
  return math.abs(torso.CFrame.UpVector.Y)<.18 and torso.CFrame.LookVector.Y>.85
 end,2),'Rest visibly lies the resident on their back, rather than sitting upright')
 check(call(b,'ObserveRest',{UserId=a.UserId}),'A second player sees the same lying-down pose')
 check(waitFor(function() return a.Character.Humanoid.Health>=75 end,6),'Rest restores health')
 call(a,'StandUp')
 check(waitFor(function() return not bed.Occupant end,2),'Player leaves bed')
 check(waitFor(function()
  return not a.Character:GetAttribute('Resting') and a.Character.UpperTorso.CFrame.UpVector.Y>.9
 end,2),'Getting up restores an upright character')
 walk(a,origin,2,9)
 a.Character.Humanoid.Health=50
 call(a,'Prompt',bed)
 call(a,'StandUp')
 task.wait(4.2)
 check(a.Character.Humanoid.Health<65,'Getting up early cancels the rest reward')
 walk(a,origin,2,9)
 call(a,'Prompt',bed)
 a.Character.Humanoid.Health=40
 task.wait(4.2)
 check(a.Character.Humanoid.Health<55,'Incoming damage cancels rest healing')
 call(a,'StandUp')
 -- Opposite door orientation and narrow clearance in the compact rowhouse.
 local cottage=assert(city:FindFirstChild('Hollins Row 1503',true))
 local front=cottage['Rowhouse door']
 local cottageFrame=front.CFrame*CFrame.new(4.4,-4.8,-14.3)
 position(a,cottageFrame:PointToWorldSpace(Vector3.new(-4.4,3,18)))
 print('HOME_APPROACH',a.Character.HumanoidRootPart.Position,a.Character.HumanoidRootPart.CFrame.UpVector,a.Character.Humanoid:GetState(),a.Character:GetAttribute('Resting'),a.Character.Humanoid.SeatPart)
 call(a,'Prompt',front)
 print('HOME_AFTER_PROMPT',a.Character.HumanoidRootPart.Position,a.Character.Humanoid:GetState(),front:GetAttribute('Open'))
 check(front:GetAttribute('Open'),'Open Hollins rowhouse')
 walk(a,cottageFrame,-4.4,9)
 walk(a,cottageFrame,1.4,5)
 walk(a,cottageFrame,-2,0)
 walk(a,cottageFrame,-3,-7)
 walk(a,cottageFrame,-3.5,5)
 walk(a,cottageFrame,-4.4,18)
 check(true,'Walk through furnished Hollins home and back to stoop')
end)
print(ok and 'NORTHSIDE_HOMES_PASS' or 'NORTHSIDE_HOMES_FAIL',err or '')
test:EndTest({ok=ok,error=err})
