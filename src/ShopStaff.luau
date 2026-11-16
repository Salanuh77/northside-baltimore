local Players=game:GetService('Players')
local Storage=game:GetService('ReplicatedStorage')
local Tags=game:GetService('CollectionService')
local Tween=game:GetService('TweenService')
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
 return {model=model,neck=neck,rest=neck and neck.C0,unseen=0}
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
    if root then table.insert(visitors,{root=root,armed=char:FindFirstChild('Pistol')~=nil}) end
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
     local seen=dist<16
     if seen then
      local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Exclude;ray.FilterDescendantsInstances={clerk.model,guest.root.Parent,station};ray.RespectCanCollide=true
      local head=clerk.model.Head
      seen=not workspace:Raycast(head.Position,guest.root.Position+Vector3.yAxis-head.Position,ray)
     end
     local mode=seen and (guest.armed and 'Alarmed' or 'Serving') or 'On duty'
     clerk.model:SetAttribute('Activity',mode)
     if clerk.neck then
      local yaw=0
      if seen then
       local q=spot:PointToObjectSpace(guest.root.Position)
       yaw=math.clamp(math.atan2(-q.X,-q.Z),-.85,.85)
      end
      if clerk.yaw==nil or math.abs(clerk.yaw-yaw)>.05 or clerk.mode~=mode then
       clerk.yaw=yaw;clerk.mode=mode
       Tween:Create(clerk.neck,TweenInfo.new(.35),{C0=clerk.rest*CFrame.Angles(mode=='Alarmed' and -.22 or 0,yaw,0)}):Play()
      end
     end
    end
   end
   task.wait(1)
  end
 end)
end
