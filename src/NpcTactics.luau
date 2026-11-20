-- Original, deterministic movement choices. Callers supply observed positions only.
local Tactics={}
local horizontal=Vector3.new(1,0,1)
local function basis(at,threat)
 local delta=(threat-at)*horizontal
 local direction=delta.Magnitude>.05 and delta.Unit or Vector3.new(0,0,-1)
 return direction,Vector3.new(-direction.Z,0,direction.X),delta.Magnitude
end
function Tactics.ranged(at,threat,side,reloading)
 local forward,right,distance=basis(at,threat)
 right*=side<0 and -1 or 1
 if distance<18 or reloading then
  return {at-forward*9+right*4,at-forward*9-right*4,at-forward*7}
 elseif distance>42 then
  local step=math.min(12,distance-30)
  return {at+forward*step+right*3,at+forward*step-right*3}
 end
 return {at+right*6-forward*2,at-right*6-forward*2}
end
function Tactics.flee(at,threat)
 local forward,right,distance=basis(at,threat)
 if distance>=62 then return {} end
 return {at-forward*18,at-forward*12+right*12,at-forward*12-right*12}
end
function Tactics.search(lastSeen,step,sector)
 if step==0 then return lastSeen end
 local angle=((step-1+sector)%6)*math.pi/3
 return lastSeen+Vector3.new(math.cos(angle)*8,0,math.sin(angle)*8)
end
return Tactics
