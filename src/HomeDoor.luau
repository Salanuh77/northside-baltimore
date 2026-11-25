local CF=CFrame or require('@lune/roblox').CFrame
local Door={}
function Door.opened(closed,width,exterior)
 local hinge=width/2
 return closed*CF.new(-hinge,0,0)*CF.Angles(0,(exterior or -1)*math.pi/2,0)*CF.new(hinge,0,0)
end
return Door
