local rb=require('@lune/roblox')
local Door=require('../src/HomeDoor')
for _,angle in {0,math.pi/2,-math.pi/2,math.pi} do
 local closed=rb.CFrame.new(20,6,-30)*rb.CFrame.Angles(0,angle,0)
 for _,exterior in {-1,1} do
  local width=6.36
  local opened=Door.opened(closed,width,exterior)
  for _,x in {-width/2+.1,0,width/2-.1} do
   local point=closed:PointToObjectSpace(opened:PointToWorldSpace(rb.Vector3.new(x,0,0)))
   assert(point.Z*exterior<0,'Open leaf must stay inside, clear of the resident on the stoop')
  end
  local originalHinge=closed:PointToWorldSpace(rb.Vector3.new(-width/2,0,0))
  local openHinge=opened:PointToWorldSpace(rb.Vector3.new(-width/2,0,0))
  assert((originalHinge-openHinge).Magnitude<.001,'The door remains connected to its jamb')
 end
end
print('PASS inward door swing, both exterior faces and four building orientations')
