local fs=require('@lune/fs')
local luau=require('@lune/luau')
local rb=require('@lune/roblox')
local function user(id,z)
 local p={UserId=id,DisplayName=tostring(id)}
 function p:SetAttribute(k,v) self[k]=v end
 p.Character=rb.Instance.new('Model')
 local root=rb.Instance.new('Part');root.Name='HumanoidRootPart';root.CFrame=rb.CFrame.new(0,0,z);root.Parent=p.Character
 return p
end
local a,b,c=user(1,-3),user(2,-3),user(3,-3)
local removed
local players={GetPlayers=function() return {a,b,c} end,GetPlayerByUserId=function(_,id) return ({a,b,c})[id] end,PlayerRemoving={Connect=function(_,fn) removed=fn end}}
local club={Parent={GetChildren=function() return {} end},FindFirstChildOfClass=function() return {Play=function() end} end}
local city={FindFirstChild=function() return club end}
local create=luau.load(fs.readFile('src/NeighborhoodLife.luau'),{environment={game={GetService=function() return players end},task={spawn=function() end},Instance=rb.Instance},injectGlobals=true})()
local home=rb.Instance.new('Part');home:SetAttribute('Address','Unit 101');home:SetAttribute('LeasePrice',0)
local door=rb.Instance.new('Part');door.Size=rb.Vector3.new(6,10,.5);door:SetAttribute('ExteriorSign',-1)
local link=rb.Instance.new('ObjectValue');link.Name='Residence';link.Value=home;link.Parent=door
local noop=function() end
local state={[a]={Cash=500},[b]={Cash=500},[c]={Cash=500}}
local service=create(city,{FireClient=noop},state,function() return home end,function() return true end,noop,noop)
assert(service.canUseDoor(b,door),'Unleased homes can be viewed')
service.handle(a,'Lease',{})
assert(home:GetAttribute('Tenant')==1 and service.canUseDoor(a,door))
assert(not service.canUseDoor(b,door),'Stranger cannot operate a leased door')
service.handle(b,'Lease',{});assert(home:GetAttribute('Tenant')==1,'Lease cannot be stolen')
-- Party state normally also creates audiovisual instances; exercise its real
-- authorization tables with a minimal sound/light fixture.
local audio={Play=noop,Clone=function() return {Play=noop} end}
-- HostParty uses the startup sound clone; override fixture clone before reinit.
-- A separate service avoids injecting its private guest table.
club.FindFirstChildOfClass=function() return audio end
home:SetAttribute('Tenant',nil)
service=create(city,{FireClient=noop},state,function() return home end,function() return true end,noop,noop)
service.handle(a,'Lease',{});service.handle(a,'HostParty',{})
service.handle(a,'InviteParty',{Target=2});assert(not service.canUseDoor(b,door),'Invitation alone does not grant access')
service.handle(b,'PartyReply',{Accept=true});assert(service.canUseDoor(b,door),'Accepted guest can enter')
service.handle(a,'EndParty',{});assert(not service.canUseDoor(b,door),'Ending party revokes guest access')
b.Character.HumanoidRootPart.CFrame=rb.CFrame.new(0,0,3)
assert(service.canUseDoor(b,door),'Former guest can exit from indoors')
b.Character.HumanoidRootPart.CFrame=rb.CFrame.new(20,0,3)
assert(not service.canUseDoor(b,door),'Neighboring flat is not an interior exit')
b.Character.HumanoidRootPart.CFrame=rb.CFrame.new(0,13,3)
assert(not service.canUseDoor(b,door),'Upstairs player cannot use downstairs exit exception')
b.Character.HumanoidRootPart.CFrame=rb.CFrame.new(0,0,-3)
door:SetAttribute('ClosedFrame',rb.CFrame.new());door.CFrame=rb.CFrame.Angles(0,math.pi/2,0)
assert(not service.canUseDoor(b,door),'Open leaf rotation does not change the permitted side')
removed(a);assert(service.canUseDoor(b,door) and home:GetAttribute('Tenant')==nil,'Departing tenant releases the lock')
print('PASS: home ownership, invitations, revocation, safe exit, floor isolation and disconnect release')
