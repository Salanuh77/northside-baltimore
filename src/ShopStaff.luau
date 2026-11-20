local Players=game:GetService('Players')
local Storage=game:GetService('ReplicatedStorage')
local Tags=game:GetService('CollectionService')
local Tween=game:GetService('TweenService')
local Reactions=require(script.Parent.NpcReactions)
local looks={
 {'Copper','Cropped fringe','Short','Average','Dock denim','Oval'},
 {'Umber','High puff','Medium','Slender','Field liner','Heart'},
 {'Amber','Twists','Tall','Broad','Clay','Square'},
 {'Espresso','Close crop','Medium','Average','Overshirt','Oblong'},
 {'Sand','Side part','Short','Broad','Track jacket','Round'},
 {'Olive','Short locs','Tall','Average','Ash pullover','Diamond'},
}
local function build(station)
 local model=Storage.ResidentRig:Clone()
 local role=station:GetAttribute('StaffRole')
 model.Name=role
 local index=math.floor(math.abs(station.Position.X)+math.abs(station.Position.Z))%#looks+1
 local l=looks[index]
 model.HumanoidRootPart.Anchored=true
 model.Parent=station.Parent
 local outfit=role=='Stylist' and 'forever-tuesday' or nil
 require(Storage.StreetStyle).apply(model,{Name=role,Height=l[3],Build=l[4],Hair=l[2],Tone=l[1],FaceShape=l[6],Starter=l[5]},outfit)
 local spot=station:GetAttribute('StaffSpot')
 model:PivotTo(spot)
 local foot=model.LeftFoot
 model:PivotTo(spot+Vector3.yAxis*(spot.Y-foot.Position.Y+foot.Size.Y/2))
 for _,piece in model:GetDescendants() do
  if piece:IsA('BasePart') then piece.CanCollide=false;piece.CanTouch=false;piece.CanQuery=false end
 end
 local humanoid=model.Humanoid
 humanoid.DisplayName=role..' · NPC';humanoid.NameDisplayDistance=13;humanoid.HealthDisplayDistance=0
 model:SetAttribute('RouteDesk',station.Position);Tags:AddTag(model,'RouteClerk')
 local neck=model:FindFirstChild('Neck',true)
 if neck and not neck:IsA('Motor6D') then neck=nil end
 local protective={}
 for _,name in {'Waist','LeftShoulder','RightShoulder'} do
  local joint=model:FindFirstChild(name,true)
  if joint and joint:IsA('Motor6D') then table.insert(protective,{joint=joint,rest=joint.C0,name=name}) end
 end
 return {model=model,neck=neck,rest=neck and neck.C0,protective=protective,unseen=0}
end

return function(city)
 local stations={}
 for _,item in city:GetDescendants() do
  if item:GetAttribute('StaffSpot') then table.insert(stations,item) end
 end
 local staff={}
 task.spawn(function()
  while city.Parent do
   local visitors={}
   for _,player in Players:GetPlayers() do
    local char=player.Character;local root=char and char:FindFirstChild('HumanoidRootPart')
    if root and char:FindFirstChildOfClass('Humanoid') and char.Humanoid.Health>0 then table.insert(visitors,{root=root,armed=char:FindFirstChild('Pistol')~=nil or char:FindFirstChild('Knife')~=nil or char:FindFirstChild('Bat')~=nil}) end
   end
   for _,station in stations do
    local spot=station:GetAttribute('StaffSpot')
    local guest,dist=nil,math.huge
    for _,v in visitors do
     local delta=(v.root.Position-spot.Position).Magnitude
     if delta<dist then guest=v;dist=delta end
    end
    local clerk=staff[station]
    if dist<125 and not clerk then clerk=build(station);staff[station]=clerk end
    if clerk then
     if dist>160 then clerk.unseen+=1 else clerk.unseen=0 end
     if clerk.unseen>=12 then clerk.model:Destroy();staff[station]=nil;continue end
     local seen=false;local nearest=math.huge
     -- A closer passerby behind the wall must not hide a visible customer.
     for _,visitor in visitors do
      local range=(visitor.root.Position-clerk.model.Head.Position).Magnitude
      local score=range-(visitor.armed and 24 or 0)
      if range>=18 or score>=nearest then continue end
      local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Exclude;ray.FilterDescendantsInstances={clerk.model,station};ray.RespectCanCollide=true
      local hit=workspace:Raycast(clerk.model.Head.Position,visitor.root.Position+Vector3.yAxis-clerk.model.Head.Position,ray)
      if not hit or hit.Instance:IsDescendantOf(visitor.root.Parent) then guest=visitor;nearest=score;seen=true end
     end
     local mode,alarm=Reactions.step(clerk,os.clock(),{alarmUntil=clerk.model:GetAttribute('AlarmUntil'),visible=seen,armed=seen and guest.armed})
     clerk.model:SetAttribute('Activity',mode)
     if clerk.sheltering~=alarm then
      clerk.sheltering=alarm
      for _,pose in clerk.protective do
       local tilt=alarm and (pose.name=='Waist' and -.35 or 1.1) or 0
       Tween:Create(pose.joint,TweenInfo.new(.3),{C0=pose.rest*CFrame.Angles(tilt,0,0)}):Play()
      end
     end
     if clerk.neck then
      local yaw=0
      if seen then
       local q=spot:PointToObjectSpace(guest.root.Position)
       yaw=math.clamp(math.atan2(-q.X,-q.Z),-.85,.85)
      end
      if clerk.yaw==nil or math.abs(clerk.yaw-yaw)>.05 or clerk.mode~=mode then
       clerk.yaw=yaw;clerk.mode=mode
       Tween:Create(clerk.neck,TweenInfo.new(.35),{C0=clerk.rest*CFrame.Angles((alarm or mode=='Alarmed') and -.22 or 0,yaw,0)}):Play()
      end
     end
    end
   end
   task.wait(1)
  end
 end)
end
