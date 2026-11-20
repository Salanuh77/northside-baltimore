local rb=require('@lune/roblox');local luau=require('@lune/luau');local fs=require('@lune/fs')
local target={};local mode='target';local position=rb.Vector3.new(0,3,-25)
function target:FindFirstChild() return {Position=position} end
local Sight=luau.load(fs.readFile('src/NpcSight.luau'),{environment={
 RaycastParams={new=function() return {} end},Enum={RaycastFilterType={Exclude='Exclude'}},
 workspace={Raycast=function(_,origin,direction,params)
  assert(params.RespectCanCollide==false,'Check noncolliding bystanders and officers')
  if mode=='empty' then return nil end
  return {Instance={IsDescendantOf=function(_,candidate) return mode=='target' and candidate==target end}}
 end},
},injectGlobals=true})()
local officer={Head={Position=rb.Vector3.new(0,3,0)},HumanoidRootPart={CFrame=rb.CFrame.new()}}
assert(Sight.clearShot(officer,target))
for _,blocker in {'wall','bystander','officer','empty'} do mode=blocker;assert(not Sight.clearShot(officer,target),blocker..' must suppress fire') end
mode='target';position=rb.Vector3.new(0,3,-100);assert(not Sight.clearShot(officer,target),'Cannot fire beyond range')
assert(not Sight.clearShot(officer,nil),'Deleted target is safe')
print('PASS: clear firing lanes, bystanders, other officers, walls and target lifetime')
