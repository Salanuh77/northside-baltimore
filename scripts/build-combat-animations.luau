local rb,fs=require('@lune/roblox'),require('@lune/fs')
local motion=require('../art/combat-motion')
local hierarchy={
 {'LowerTorso','HumanoidRootPart','Root'},{'UpperTorso','LowerTorso','Waist'},{'Head','UpperTorso','Neck'},
 {'LeftUpperArm','UpperTorso','LeftShoulder'},{'LeftLowerArm','LeftUpperArm','LeftElbow'},{'LeftHand','LeftLowerArm','LeftWrist'},
 {'RightUpperArm','UpperTorso','RightShoulder'},{'RightLowerArm','RightUpperArm','RightElbow'},{'RightHand','RightLowerArm','RightWrist'},
 {'LeftUpperLeg','LowerTorso','LeftHip'},{'LeftLowerLeg','LeftUpperLeg','LeftKnee'},{'LeftFoot','LeftLowerLeg','LeftAnkle'},
 {'RightUpperLeg','LowerTorso','RightHip'},{'RightLowerLeg','RightUpperLeg','RightKnee'},{'RightFoot','RightLowerLeg','RightAnkle'},
}
for name,spec in motion do
 local sequence=rb.Instance.new('KeyframeSequence');sequence.Name='Baltimore '..name;sequence.Loop=spec.loop==true;sequence.Priority=rb.Enum.AnimationPriority[spec.priority]
 for _,frame in spec.frames do
  local key=rb.Instance.new('Keyframe');key.Time=frame[1];key.Name='Pose';key.Parent=sequence
  if spec.contact and math.abs(key.Time-spec.contact)<.001 then
   key.Name='Contact';local marker=rb.Instance.new('KeyframeMarker');marker.Name='Contact';marker.Value=name;marker.Parent=key
  end
  local root=rb.Instance.new('Pose');root.Name='HumanoidRootPart';root.Weight=0;root.Parent=key
  local poses={HumanoidRootPart=root}
  for _,node in hierarchy do
   local p=rb.Instance.new('Pose');p.Name=node[1];p.Parent=poses[node[2]];poses[node[1]]=p
   local angles=frame[2][node[3]]
   p.Weight=angles and 1 or 0;p.EasingStyle=rb.Enum.PoseEasingStyle.Cubic;p.EasingDirection=rb.Enum.PoseEasingDirection.InOut
   if angles then p.CFrame=rb.CFrame.new(angles[4] or 0,angles[5] or 0,angles[6] or 0)*rb.CFrame.Angles(math.rad(angles[1]),math.rad(angles[2]),math.rad(angles[3])) end
  end
 end
 fs.writeFile('art/combat-'..name..'.rbxm',rb.serializeModel({sequence}))
 print('ANIMATION_BUILT',name,#spec.frames)
end
