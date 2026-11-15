-- Check the real Studio collision geometry from the end of the existing public pier.
local ship=assert(workspace.Baltimore:FindFirstChild('USS Constellation',true))
local lastHeight
for x=416,384,-1 do
 local hit=workspace:Raycast(Vector3.new(x,10,-610),Vector3.new(0,-12,0))
 assert(hit and hit.Instance.CanCollide,'Missing walking surface at '..x)
 if lastHeight then assert(math.abs(lastHeight-hit.Position.Y)<1.15,'Boarding route step at '..x) end
 lastHeight=hit.Position.Y
end
assert(lastHeight>7 and lastHeight<7.5,'Route did not finish on spar deck')
print('HARBOR_ACCESS_PASS')
