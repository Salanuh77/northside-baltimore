-- Original procedural R15 motion; no copied or permission-dependent animation assets.
local Pose={}
local function smooth(x) x=math.clamp(x,0,1);return x*x*(3-2*x) end
function Pose.sample(mode,combo,elapsed,activity)
 local p={}
 if mode=='Blocking' then
  p.LeftShoulder={1.15,0,-.22};p.RightShoulder={1.15,0,.22};p.LeftElbow={1.25,0,0};p.RightElbow={1.25,0,0};p.Waist={.12,0,0}
 elseif mode=='Attacking' then
  local hit=combo==1 and .18 or combo==2 and .22 or .3
  local duration=combo==1 and .55 or combo==2 and .62 or .95
  local drive=elapsed<hit and smooth(elapsed/hit) or 1-smooth((elapsed-hit)/(duration-hit))
  local left=combo==1;local side=left and 'Left' or 'Right';local other=left and 'Right' or 'Left'
  p[side..'Shoulder']={.65+drive*.95,(combo==3 and -.6 or 0)*drive,left and -.16 or .16}
  p[side..'Elbow']={1.1*(1-drive),0,0};p[other..'Shoulder']={.8,0,0};p[other..'Elbow']={1,0,0}
  p.Waist={.07,(left and -.28 or .35)*drive,0};p.Neck={0,(left and .12 or -.12)*drive,0}
 elseif mode=='Stunned' then p.Waist={-.23,0,.08};p.Neck={-.15,0,0}
 elseif activity=='Cowering' or activity=='Wary' then
  p.Waist={.32,0,0};p.LeftShoulder={1.4,0,-.3};p.RightShoulder={1.4,0,.3};p.LeftElbow={1,0,0};p.RightElbow={1,0,0}
 elseif activity=='Reporting' then p.RightShoulder={.9,0,.2};p.RightElbow={1.5,0,0};p.Neck={0,-.15,0}
 elseif activity=='Talking' then p.RightShoulder={.4,0,.25};p.RightElbow={.6,0,0}
 elseif mode=='Ready' then
  p.LeftShoulder={.5,0,-.16};p.RightShoulder={.5,0,.16};p.LeftElbow={.8,0,0};p.RightElbow={.8,0,0};p.Waist={0,-.12,0}
 end
 return p
end
return Pose
