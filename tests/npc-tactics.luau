local rb=require('@lune/roblox');local luau=require('@lune/luau');local fs=require('@lune/fs')
local v=rb.Vector3.new
local T=luau.load(fs.readFile('src/NpcTactics.luau'),{environment={Vector3=rb.Vector3},injectGlobals=true})()
local at=v(0,3,0);local near=v(0,3,-9);local far=v(0,3,-60)
for _,point in T.ranged(at,near,1,false) do assert((point-near).Magnitude>(at-near).Magnitude,'Back away from a close armed suspect') end
for _,point in T.ranged(at,far,1,false) do assert((point-at).Magnitude<=13 and (point-far).Magnitude>25,'Approach in bounded steps with room to stop') end
local left=T.ranged(at,v(0,3,-30),-1,false)[1];local right=T.ranged(at,v(0,3,-30),1,false)[1]
assert(left.X*right.X<0 and left.Y==at.Y,'Different officers can use opposite flanks')
for _,point in T.ranged(at,far,1,true) do assert((point-far).Magnitude>(at-far).Magnitude,'Reloading increases separation') end
for _,point in T.flee(at,near) do assert((point-near).Magnitude>20,'Medic retreats away from the observed threat') end
assert(#T.flee(at,v(0,3,-70))==0,'Medic stops fleeing once safely separated')
for _,point in T.flee(at,at) do assert(point.X==point.X and point.Z==point.Z,'Coincident threat cannot create NaN routes') end
local seen=v(100,3,50)
assert(T.search(seen,0,0)==seen,'First inspect the last reported point')
local visited={}
for step=1,6 do local point=T.search(seen,step,0);assert(math.abs((point-seen).Magnitude-8)<.01);visited[tostring(point)]=true end
local n=0;for _ in visited do n+=1 end;assert(n==6,'Search samples multiple positions without tracking the hidden player')
assert(T.search(seen,1,0)~=T.search(seen,1,1),'Partners search different sectors')
print('PASS: bounded approach, retreat, flanks, reload spacing, safe flee and last-seen searches')
