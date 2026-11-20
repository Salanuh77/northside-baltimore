local fs=require('@lune/fs');local luau=require('@lune/luau');local rb=require('@lune/roblox')
local v=rb.Vector3.new
local state={health=100,safe=false,surrender=false,valid=true,visible=true,hit='target',shots=0,rays=0}
local target={Character={HumanoidRootPart={Position=v(0,0,-30)},Humanoid={TakeDamage=function(_,n) state.health-=n end}},GetAttribute=function() return state.surrender end}
local world={Raycast=function(_,origin,direction,params)
 state.rays+=1
 assert(params.RespectCanCollide==false,'Ray must hit queryable noncolliding avatar limbs')
 if state.hit=='miss' then return nil end
 return {Position=origin+direction*.5,Instance={IsDescendantOf=function(_,character) return state.hit=='target' and character==target.Character end}}
end}
local fire=luau.load(fs.readFile('src/NpcCombat.luau'),{environment={workspace=world,Vector3=rb.Vector3,RaycastParams={new=function() return {} end},Enum={RaycastFilterType={Exclude='Exclude'}}},injectGlobals=true})()
local unit={model={Head={Position=v(0,3,0)},HumanoidRootPart={CFrame=rb.CFrame.new()}}}
local function shoot()
 fire(unit,target,function() return state.valid end,function() return state.safe end,function() return state.visible end,{FireAllClients=function(_,kind,data) assert(kind=='Shot' and data.From and data.To);state.shots+=1 end},{NextNumber=function() return 0 end})
end
shoot();assert(state.health==91 and state.shots==1,'Confirmed target hit causes bounded damage')
for _,hit in {'wall','bystander','officer','miss'} do state.hit=hit;shoot();assert(state.health==91,hit..' cannot cause target damage') end
state.hit='target'
for _,flag in {'safe','surrender'} do state[flag]=true;local before=state.rays;shoot();assert(state.health==91 and state.rays==before,'Protected player cannot be fired upon');state[flag]=false end
for _,flag in {'valid','visible'} do state[flag]=false;local before=state.rays;shoot();assert(state.health==91 and state.rays==before,'Invalid or hidden target cannot be fired upon');state[flag]=true end
-- Recheck protection after the ray in case an event changes the character state.
local checks=0
fire(unit,target,function() return true end,function() checks+=1;return checks>1 end,function() return true end,{FireAllClients=function() end},{NextNumber=function() return 0 end})
assert(state.health==91,'Protection is rechecked immediately before damage')
print('PASS: NPC shots, bounded damage, walls, misses, bystanders, friendly fire, protected targets and surrender')
