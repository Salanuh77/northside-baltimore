local players=game.Players
local test=game:GetService('StudioTestService')
local drive=game.ReplicatedStorage:WaitForChild('TestDrive')
local function check(value,message) assert(value,message);print('ACCESS_PASS',message) end
local function waitFor(fn,seconds)
 local deadline=os.clock()+seconds
 repeat if fn() then return true end;task.wait(.1) until os.clock()>=deadline
 return fn()
end
local function call(p,kind,data) return drive:InvokeClient(p,kind,data or {}) end
local function position(p,frame)
 local root=p.Character.HumanoidRootPart
 p:RequestStreamAroundAsync(frame.Position,5)
 p.Character:PivotTo(frame*root.CFrame:ToObjectSpace(p.Character:GetPivot()))
 root.AssemblyLinearVelocity=Vector3.zero;task.wait(.4)
end
local ok,err=pcall(function()
 check(waitFor(function()
  if #players:GetPlayers()~=2 then return false end
  for _,p in players:GetPlayers() do if not p.Character or not p.Character:FindFirstChild('HumanoidRootPart') or p:GetAttribute('Cash')==nil or not p:GetAttribute('ProbeSpawnFinished') then return false end end
  return true
 end,70),'Two residents ready')
 local a,b=table.unpack(players:GetPlayers())
 local flat=workspace.Baltimore:FindFirstChild('Lanvale Court A',true)
 local door
 for _,part in flat:GetChildren() do if part.Name=='Apartment door' and (not door or part.Position.Y<door.Position.Y) then door=part end end
 local closed=door.CFrame
 local residence=door.Residence.Value
 position(a,closed*CFrame.new(0,-1,-5));position(b,closed*CFrame.new(9,-1,-5))
 call(a,'Lease');check(residence:GetAttribute('Tenant')==a.UserId,'Intercom reserves the correct flat (tenant='..tostring(residence:GetAttribute('Tenant'))..', player='..tostring(a.Character.HumanoidRootPart.Position)..', intercom='..tostring(residence.Position)..')')
 position(a,closed*CFrame.new(9,-1,-5));position(b,closed*CFrame.new(0,-1,-5))
 call(b,'Prompt',door);check(not door:GetAttribute('Open'),'Stranger cannot open a rented flat')
 local crossed=call(b,'WalkTo',closed:PointToWorldSpace(Vector3.new(0,-1,5)))
 check(not crossed and closed:PointToObjectSpace(b.Character.HumanoidRootPart.Position).Z<0,'Closed leaf physically stops entry')
 position(b,closed*CFrame.new(door.Size.X/2+.4,-1,-5))
 crossed=call(b,'WalkTo',closed:PointToWorldSpace(Vector3.new(door.Size.X/2+.4,-1,5)))
 check(not crossed and closed:PointToObjectSpace(b.Character.HumanoidRootPart.Position).Z<0,'Door-to-masonry seam cannot be walked through')
 position(b,closed*CFrame.new(9,-1,-5));position(a,closed*CFrame.new(0,-1,-5))
 call(a,'HostParty');call(a,'InviteParty',{Target=b.UserId});call(b,'PartyReply',{Accept=true})
 position(a,closed*CFrame.new(9,-1,-5));position(b,closed*CFrame.new(0,-1,-5))
 call(b,'Prompt',door);check(door:GetAttribute('Open'),'Accepted guest operates the entrance')
 check(call(b,'WalkTo',closed:PointToWorldSpace(Vector3.new(0,-1,5))),'Guest walks inside through the open doorway')
 call(a,'EndParty')
 call(b,'Prompt',door);check(not door:GetAttribute('Open'),'Revoked guest inside can close the door')
 task.wait(.9);call(b,'Prompt',door);check(door:GetAttribute('Open'),'Revoked guest can still open from inside to leave')
 check(call(b,'WalkTo',closed:PointToWorldSpace(Vector3.new(0,-1,-5))),'Revoked guest leaves on foot')
 position(b,closed*CFrame.new(9,-1,-5));position(a,closed*CFrame.new(0,-1,-5))
 call(a,'Prompt',door);check(not door:GetAttribute('Open'),'Tenant closes the entrance')
 position(a,closed*CFrame.new(9,-1,-5));position(b,closed*CFrame.new(0,-1,-5))
 call(b,'Prompt',door);check(not door:GetAttribute('Open'),'Revoked guest cannot reopen from the street')
 call(a,'ReleaseHome');check(residence:GetAttribute('Tenant')==nil,'Release removes tenant lock')
 call(b,'Lease');check(residence:GetAttribute('Tenant')==b.UserId,'A new tenant can claim the released flat')
end)
print(ok and 'NORTHSIDE_ACCESS_PASS' or 'NORTHSIDE_ACCESS_FAIL',err or '')
test:EndTest({ok=ok,error=err})
