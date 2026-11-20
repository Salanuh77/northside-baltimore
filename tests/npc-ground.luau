local rb=require('@lune/roblox');local luau=require('@lune/luau');local fs=require('@lune/fs')
local v=rb.Vector3.new;local state={floor=true,normal=1,height=0,water=false,occupied=false,blocked=false}
local ground=luau.load(fs.readFile('src/NpcGround.luau'),{environment={
 Vector3=rb.Vector3,CFrame=rb.CFrame,RaycastParams={new=function() return {} end},OverlapParams={new=function() return {} end},
 Enum={RaycastFilterType={Exclude='Exclude'},Material={Water='Water'}},
 workspace={Raycast=function(_,start)
  if not state.floor then return nil end
  return {Position=v(start.X,state.height,start.Z),Normal=v(0,state.normal,0),Material=state.water and 'Water' or 'Concrete'}
 end,GetPartBoundsInBox=function() return state.occupied and {true} or {} end,Blockcast=function() return state.blocked and {} or nil end},
},injectGlobals=true})()
local model={HumanoidRootPart={Position=v(0,3,0),Size=v(2,2,1)},Humanoid={HipHeight=2}}
local points={v(8,3,0)}
assert(ground.choose(model,points,true)==v(8,3,0))
for _,flag in {'water','occupied','blocked'} do state[flag]=true;assert(not ground.choose(model,points,true),flag..' rejects tactical movement');state[flag]=false end
state.floor=false;assert(not ground.choose(model,points,true),'Do not walk off a missing floor');state.floor=true
state.normal=.5;assert(not ground.choose(model,points,true),'Reject steep ledges');state.normal=1
state.height=7;assert(not ground.choose(model,points,true),'Do not choose a rooftop from the street');state.height=0
state.blocked=true;assert(ground.choose(model,points,false),'Search destination can be routed around walls by the pathfinder')
assert(not ground.choose(model,{},true))
print('PASS: ground clearance, blocked movement, slopes, water, drop-offs and search routing')
