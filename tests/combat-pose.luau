local Pose=require('../src/CombatPose')
local Motion=require('../art/combat-motion')
local function contact(name)
 local spec=Motion[name]
 for _,frame in spec.frames do if frame[1]==spec.contact then return frame[2] end end
 error('Missing contact pose')
end
local guard=Motion.Guard.frames[1][2]
assert(guard.LeftShoulder[1]>80 and guard.RightShoulder[1]>80,'Both forearms cover the head')
local jab,cross,hook=contact('Jab'),contact('Cross'),contact('Hook')
assert(jab.LeftElbow[1]<12 and cross.RightElbow[1]<12,'Jab and cross extend alternate arms')
assert(math.abs(hook.RightShoulder[2])>40,'Finisher has a different hook arc')
assert(Motion.Jab.frames[#Motion.Jab.frames][2].LeftElbow[1]>90,'Arm retracts during recovery')
assert(next(Pose.sample('Attacking',1,.18))==nil,'Ambient gestures cannot overwrite attack tracks')
assert(next(Pose.sample('Idle',1,4))==nil,'Idle releases the pose')
assert(Pose.sample('Idle',1,0,'Cowering').Waist[1]>0,'Civilian fear has a visible body pose')
assert(Pose.sample('Idle',1,0,'Reporting').RightElbow[1]>1,'Witness call lifts a hand')
print('PASS authored guard, alternating strikes, hook, retraction and independent ambient gestures')
