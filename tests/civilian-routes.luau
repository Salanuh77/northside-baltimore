local rb=require('@lune/roblox')
local Routes=require('../src/CivilianRoutes')
local V=rb.Vector3.new
local graph=Routes.build({{position=V(0,3,0),size=V(150,1,9)},{position=V(95,3,65),size=V(9,1,140)},{position=V(0,3,130),size=V(150,1,9)},{position=V(-95,3,65),size=V(9,1,140)}})
assert(#graph.nodes>12,'Subdivide long sidewalks into actual destinations')
local real=Routes.build({{position=V(0,3,21.5),size=V(148,1,9)},{position=V(100-21.5,3,100),size=V(9,1,166)},{position=V(100+21.5,3,100),size=V(9,1,166)}})
local joins,crossings=0,0
for _,node in real.nodes do for _,edge in node.edges do if edge.crossing then crossings+=1 else joins+=1 end end end
assert(joins>0 and crossings>0,'Join corners and distinct crossing edges')
local seen={};local current=1;local previous;local recent={};local rng=Random and Random.new(42)
local seed=42;local function random() seed=(seed*16807)%2147483647;return seed/2147483647 end
for _=1,25 do
 local edge=Routes.next(real,current,previous,recent,random)
 assert(edge,'Connected sidewalk has a next destination')
 if #real.nodes[current].edges>1 then assert(edge.to~=previous,'Never reverse when another exit exists') end
 recent[current]=true;seen[current]=true;previous,current=current,edge.to
end
local count=0;for _ in seen do count+=1 end
assert(count>=5,'Roaming visits more than two endpoints')
assert(Routes.population(1)==18 and Routes.population(0)==0 and Routes.population(20)==30,'Population grows with players but is bounded')
assert(not Routes.canRetire(90,100,false,false) and Routes.canRetire(90,400,false,false),'Retirement has a minimum lifetime')
assert(not Routes.canRetire(90,400,true,false) and not Routes.canRetire(90,400,false,true),'Visible or threatened residents persist')
print('PASS civilian routes, corner links, crossings, no reversal, population and retirement')
