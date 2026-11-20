local fs=require('@lune/fs');local luau=require('@lune/luau');local rb=require('@lune/roblox')
local v=rb.Vector3.new;local queue,paths,moves={},{},{}
local clock=0;local success=true
local pathfinder={CreatePath=function()
 local path={Status='Success'}
 function path:ComputeAsync(start,goal) self.goal=goal;self.Status=success and 'Success' or 'NoPath' end
 function path:GetWaypoints() return {{Position=v(0,0,0)},{Position=self.goal,Action='Walk'}} end
 function path:Destroy() self.destroyed=true end
 path.Blocked={Connect=function(_,fn) path.block=fn;return {Disconnect=function() path.disconnected=true end} end}
 table.insert(paths,path);return path
end}
local Nav=luau.load(fs.readFile('src/NpcNavigation.luau'),{environment={
 game={GetService=function() return pathfinder end},task={spawn=function(fn) table.insert(queue,fn) end},os={clock=function() return clock end},Vector3=rb.Vector3,
 Enum={PathStatus={Success='Success'},PathWaypointAction={Jump='Jump'}},
},injectGlobals=true})()
local model={Parent=true,HumanoidRootPart={Position=v(0,0,0)},Humanoid={MoveTo=function(_,goal) table.insert(moves,goal) end}}
local nav=Nav.new(model)
local function flush() local fn=table.remove(queue,1);assert(fn);fn() end
nav:step(v(20,0,0),clock,16);assert(#queue==1)
nav:step(v(20,0,0),clock,16);assert(#queue==1,'Only one path computation in flight')
nav:step(v(40,0,0),clock,16);flush()
assert(paths[1].destroyed and not nav.points,'Stale destination discarded')
nav:step(v(40,0,0),clock,16);flush();nav:step(v(40,0,0),clock,16)
assert(moves[#moves]==v(40,0,0),'Follow current path')
paths[2].block(2);assert(paths[2].destroyed and paths[2].disconnected,'Blocked path releases connections')
nav:step(v(40,0,0),clock,16);nav:stop();flush()
assert(not nav.points and paths[3].destroyed,'Stopping cancels an in-flight route')
clock=3;success=false;nav:step(v(40,0,0),clock,16);flush()
assert(not nav.points and moves[#moves]==model.HumanoidRootPart.Position,'No direct walk through wall when path fails')
clock=5;success=true;nav:step(v(40,0,0),clock,16);flush()
local currentPath=nav.path
paths[2].block(2)
assert(nav.path==currentPath and not currentPath.destroyed,'Queued blockage from a retired path cannot discard the replacement route')
-- Arriving below a stair landing is not the same as reaching the waypoint.
currentPath.GetWaypoints=function() return {{Position=v(0,0,0)},{Position=v(0,8,0),Action='Jump'},{Position=v(40,8,0),Action='Walk'}} end
nav.points=currentPath:GetWaypoints();nav.index=2;nav.goal=v(40,8,0)
nav:step(v(40,8,0),clock,16)
assert(nav.index==2,'Do not skip a raised waypoint just because its X/Z matches')
model.HumanoidRootPart.Position=v(0,11,0);nav:step(v(40,8,0),clock,16)
assert(nav.index==3,'Advance once the feet reach the stair landing')
model.Parent=false;nav:stop();assert(currentPath.destroyed,'Death disconnects navigation')
print('PASS: navigation concurrency, moving targets, blockage, cancellation, no-path safety and cleanup')
