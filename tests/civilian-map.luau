local rb,fs=require('@lune/roblox'),require('@lune/fs')
local Routes=require('../src/CivilianRoutes')
local place=rb.deserializePlace(fs.readFile('Northside Baltimore - Heritage Harbor.rbxl'))
local strips={}
for _,p in place:GetService('Workspace').Baltimore['Streets & alleys']:GetChildren() do
 if p.Name=='Pavement' then table.insert(strips,{position=p.CFrame.Position+rb.Vector3.new(0,3.3,0),size=p.Size}) end
end
local graph=Routes.build(strips);local seen={};local largest=0;local components=0;local crossings=0
for id,node in graph.nodes do
 for _,edge in node.edges do if edge.crossing then crossings+=1 end end
 if seen[id] then continue end
 components+=1;local queue={id};seen[id]=true;local index=1
 while queue[index] do
  for _,edge in graph.nodes[queue[index]].edges do if not seen[edge.to] then seen[edge.to]=true;table.insert(queue,edge.to) end end
  index+=1
 end
 largest=math.max(largest,#queue)
end
assert(#graph.nodes>500 and largest>#graph.nodes*.9,'Sidewalk routes must connect across the city')
assert(crossings>100,'City graph must provide actual crossing choices')
local library=place:GetService('ReplicatedStorage').WeaponMeshes
for _,model in library:GetChildren() do
 local size=model:GetAttribute('NormalizedSize')
 assert(math.abs(size.Z-1)<.01 and size.X<size.Z and #model:GetDescendants()>0,'Weapon normalized along the firing direction: '..model.Name)
end
print('PASS city navigation graph',#graph.nodes,'nodes',components,'components',crossings/2,'crossings; six weapon imports')
