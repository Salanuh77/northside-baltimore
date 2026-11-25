-- Sidewalk graph. Geometry is supplied by the map; no hard-coded district coordinates.
local V=Vector3 or require('@lune/roblox').Vector3
local Routes={}
function Routes.build(strips)
 local graph={nodes={}}
 local function link(a,b,crossing)
  table.insert(graph.nodes[a].edges,{to=b,crossing=crossing})
  table.insert(graph.nodes[b].edges,{to=a,crossing=crossing})
 end
 for stripId,strip in strips do
  local axis=strip.size.X>strip.size.Z and 'X' or 'Z'
  -- Street-sign masts occupy the exact corner; keep body clearance at each end.
  local length=math.max(strip.size.X,strip.size.Z)-(axis=='Z' and 14 or 6)
  if length<10 then continue end
  local steps=math.max(1,math.ceil(length/34));local prior
  for i=0,steps do
   local along=-length/2+i*length/steps
   local vector=axis=='X' and V.new(along,0,0) or V.new(0,0,along)
   local index=#graph.nodes+1
   table.insert(graph.nodes,{position=strip.position+vector,edges={},strip=stripId,terminal=i==0 or i==steps})
   if prior then link(prior,index,false) end;prior=index
  end
 end
 for i,a in graph.nodes do if a.terminal then
  for j=i+1,#graph.nodes do local b=graph.nodes[j]
   if b.terminal and a.strip~=b.strip then
    local d=b.position-a.position;local distance=d.Magnitude
    if distance<15 then link(i,j,false)
    elseif distance>=32 and distance<=55 and (math.abs(d.X)<6 or math.abs(d.Z)<6) then link(i,j,true) end
   end
  end
 end end
 return graph
end
function Routes.next(graph,current,previous,recent,random,blocked)
 local candidates={};local total=0;local node=graph.nodes[current]
 if not node then return end
 for _,edge in node.edges do
  if edge.to~=previous and not (blocked and blocked[edge.to]) then
   local weight=recent[edge.to] and .08 or 1
   total+=weight;table.insert(candidates,{edge=edge,weight=weight})
  end
 end
 if #candidates==0 then
  for _,edge in node.edges do if not (blocked and blocked[edge.to]) then return edge end end
  return
 end
 local roll=random()*total
 for _,entry in candidates do roll-=entry.weight;if roll<=0 then return entry.edge end end
 return candidates[#candidates].edge
end
function Routes.population(players) return players>0 and math.min(30,18+(players-1)*3) or 0 end
function Routes.canRetire(distance,age,visible,threatened)
 return distance>70 and age>=240 and not visible and not threatened
end
return Routes
