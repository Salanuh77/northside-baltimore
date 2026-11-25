-- Small ambient gestures only. Combat uses published Animator tracks.
local Pose={}
function Pose.sample(mode,combo,elapsed,activity)
 local p={}
 if mode~='Idle' then return p end
 if activity=='Cowering' or activity=='Wary' then
  p.Waist={.32,0,0};p.LeftShoulder={1.4,0,-.3};p.RightShoulder={1.4,0,.3};p.LeftElbow={1,0,0};p.RightElbow={1,0,0}
 elseif activity=='Reporting' then p.RightShoulder={.9,0,.2};p.RightElbow={1.5,0,0};p.Neck={0,-.15,0}
 elseif activity=='Talking' then p.RightShoulder={.4,0,.25};p.RightElbow={.6,0,0}

 end
 return p
end
return Pose
