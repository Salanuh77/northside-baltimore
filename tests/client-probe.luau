local p=game:GetService('Players').LocalPlayer
local rs=game:GetService('ReplicatedStorage')
local remote=rs:WaitForChild('TestDrive')
local action=rs:WaitForChild('CityAction')
local lastNotice=''
action.OnClientEvent:Connect(function(kind,message) if kind=='Notice' then lastNotice=tostring(message) end end)
remote.OnClientInvoke=function(kind,data)
 if kind=='CombatCamera' then
  local camera=workspace.CurrentCamera;camera.CameraType=Enum.CameraType.Scriptable
  camera.CFrame=CFrame.lookAt(data.From,data.To);return true
 end
 if kind=='CombatBurst' then for _=1,12 do action:FireServer('Punch') end;task.wait(.4);return true end
 if kind=='ObserveKnockdown' then
  local model=data.Model;local due=os.clock()+3
  repeat
   local sockets=0;local loose=0
   if model and model.Parent then for _,v in model:GetDescendants() do
    if v:IsA('BallSocketConstraint') and v.Name=='Knockdown socket' then sockets+=1 end
    if v:IsA('Motor6D') and not v.Enabled then loose+=1 end
   end end
   if model and model:GetAttribute('Ragdolled') and sockets>=10 and loose>=10 then return true end
   task.wait(.05)
  until os.clock()>due
  return false
 end
 if kind=='ObservePunch' then
  local model=data.Model;local due=os.clock()+1;local maximum=0;local found=false
  repeat
   local joint=model and model:FindFirstChild('LeftShoulder',true)
   if joint then found=true;maximum=math.max(maximum,math.abs(select(1,joint.C0:ToOrientation())));if maximum>.6 then return true end end
   task.wait(.03)
  until os.clock()>due
  return false,string.format('shoulder=%s angle=%.2f tagged=%s state=%s',tostring(found),maximum,tostring(game:GetService('CollectionService'):HasTag(model,'CombatActor')),tostring(model:GetAttribute('CombatState')))
 end
 if kind=='LastNotice' then return lastNotice end
 if kind=='InteriorView' then
  for _,gui in p.PlayerGui:GetChildren() do if gui:IsA('ScreenGui') then gui.Enabled=false end end
  game:GetService('StarterGui'):SetCoreGuiEnabled(Enum.CoreGuiType.All,false)
  local camera=workspace.CurrentCamera
  camera.CameraType=Enum.CameraType.Scriptable;camera.FieldOfView=70;camera.CFrame=data.Frame;camera.Focus=data.Focus
  return true
 end
 if kind=='Equip' then
  local tool=p.Backpack:WaitForChild(data.Name,5)
  assert(tool,'Owned tool missing: '..data.Name)
  p.Character.Humanoid:EquipTool(tool);task.wait(.4)
  return tool.Parent==p.Character
 end
 if kind=='CreateResident' and not p:GetAttribute('ResidentSlot') then data=table.clone(data);data.Index=1 end
 if kind=='ItemCard' then
  local gui=p.PlayerGui:WaitForChild('NorthsideHUD')
  local deadline=os.clock()+6;local card
  repeat card=gui:FindFirstChild('Item '..data.Key,true);if card then break end;task.wait(.1) until os.clock()>deadline
  assert(card,'Missing product card '..data.Key)
  local view=card:FindFirstChildWhichIsA('ViewportFrame',true)
  assert(view and view.CurrentCamera and #view:FindFirstChildOfClass('WorldModel'):GetDescendants()>4,'Product image has no visible geometry')
  assert(card.Price.Text==data.Price,'Wrong displayed item price: '..card.Price.Text)
  if data.Buy then
   local scroll=card:FindFirstAncestorOfClass('ScrollingFrame')
   scroll.CanvasPosition=Vector2.new(0,math.max(0,scroll.CanvasPosition.Y+card.AbsolutePosition.Y-scroll.AbsolutePosition.Y))
   task.wait(.2)
   local input=game.UserInputService:CreateVirtualInput()
   local point=card.AbsolutePosition+card.AbsoluteSize/2+game.GuiService:GetGuiInset()
   input:SendMousePosition(point);input:SendMouseButton(point,Enum.UserInputType.MouseButton1,true,0)
   task.wait(.1);input:SendMouseButton(point,Enum.UserInputType.MouseButton1,false,0);task.wait(.5)
  end
  return true
 end
 if kind=='RuntimeErrors' then return runtimeErrors end
 if kind=='ShopIdentity' then
  local gui=p.PlayerGui:WaitForChild('NorthsideHUD')
  local panel=gui:FindFirstChild('Shop identity',true)
  assert(panel and panel.AbsoluteSize.Y>=64,'Missing shop identity header')
  local emblem=panel:FindFirstChild('Business emblem')
  assert(emblem and emblem:GetAttribute('BrandEmblem')==data,'Wrong operator logo in shop menu')
  game:GetService('ContentProvider'):PreloadAsync({emblem})
  assert(emblem.IsLoaded,'Shop emblem did not load')
  return true
 end
 if kind=='InteriorArt' then
  local fixtures=rs:WaitForChild('InteriorTestFixtures',10)
  local failures={}
  game:GetService('ContentProvider'):PreloadAsync(fixtures:GetChildren(),function(id,status)
   if status~=Enum.AssetFetchStatus.Success then table.insert(failures,id..' '..status.Name) end
  end)
  return #failures==0,table.concat(failures,', ')
 end
 if kind=='ObserveRest' then
  local other=game.Players:GetPlayerByUserId(data.UserId)
  local deadline=os.clock()+3
  repeat
   local c=other and other.Character
   local torso=c and c:FindFirstChild('UpperTorso')
   if torso and c:GetAttribute('Resting') and math.abs(torso.CFrame.UpVector.Y)<.18 and torso.CFrame.LookVector.Y>.85 then return true end
   task.wait(.1)
  until os.clock()>deadline
  return false
 end
 if kind=='Prompt' then
  local prompt=data:FindFirstChildWhichIsA('ProximityPrompt') or data:WaitForChild('ProximityPrompt',5)
  assert(prompt,'Interaction prompt missing')
  local camera=workspace.CurrentCamera; camera.CameraType=Enum.CameraType.Scriptable
  local head=p.Character:WaitForChild('Head')
  local eye=head.Position
  local direction=data.Position-eye
  if direction.Magnitude>.2 then eye+=direction.Unit*math.min(1.75,direction.Magnitude*.45) end
  camera.CFrame=CFrame.lookAt(eye,data.Position); task.wait(.65)
  prompt:InputHoldBegin(); task.wait(prompt.HoldDuration+.35); prompt:InputHoldEnd(); task.wait(0.3)
  camera.CameraType=Enum.CameraType.Custom
  return true
 end
 if kind=='TalkProbe' then
  local prompt=data:FindFirstChildWhichIsA('ProximityPrompt');assert(prompt)
  local triggered=false;local listener=prompt.Triggered:Connect(function() triggered=true end)
  local camera=workspace.CurrentCamera;camera.CameraType=Enum.CameraType.Scriptable
  camera.CFrame=CFrame.lookAt(data.Position+Vector3.new(0,1,6),data.Position)
  task.wait(1)
  prompt:InputHoldBegin();task.wait(prompt.HoldDuration+.5);prompt:InputHoldEnd();task.wait(.3)
  listener:Disconnect()
  return triggered,string.format('enabled=%s service=%s distance=%.2f',tostring(prompt.Enabled),tostring(game:GetService('ProximityPromptService').Enabled),(p.Character.HumanoidRootPart.Position-data.Position).Magnitude)
 end
 if kind=='WalkTo' then
  local human=p.Character.Humanoid
  local root=p.Character.HumanoidRootPart
  local run=game:GetService('RunService')
  local distance=math.huge
  run:BindToRenderStep('Walk furnished room',Enum.RenderPriority.Last.Value,function()
   local delta=(data-root.Position)*Vector3.new(1,0,1)
   distance=delta.Magnitude
   human:Move(distance>.8 and delta.Unit or Vector3.zero,false)
  end)
  local deadline=os.clock()+5
  repeat task.wait(.05) until distance<=.8 or os.clock()>=deadline
  run:UnbindFromRenderStep('Walk furnished room')
  human:Move(Vector3.zero)
  local detail=tostring(root.Position)
  if distance>1.15 then
   local nearby={}
   for _,part in workspace:GetPartBoundsInBox(root.CFrame,Vector3.new(5,7,5)) do
    if part.CanCollide and not part:IsDescendantOf(p.Character) then table.insert(nearby,part:GetFullName()) end
   end
   detail..=' state='..human:GetState().Name..' blockers='..table.concat(nearby,',')
  end
  return distance<=1.15,detail
 end
 if kind=='PreloadFurniture' then
  local parts,names={},{}
  for _,v in data:GetDescendants() do if v:IsA('MeshPart') then table.insert(parts,v);names[v.Name]=true end end
  for _,name in {'Sofa upholstery','Quilted bed','Kitchen sink','Kitchen range'} do
   if not names[name] then return false,'Missing required furniture: '..name end
  end
  if data:GetAttribute('HomeLayout')=='Flat' and not names['Walnut sideboard'] then return false,'Flat has no hallway cabinet' end
  local failed={}
  game:GetService('ContentProvider'):PreloadAsync(parts,function(id,status)
   if status~=Enum.AssetFetchStatus.Success then table.insert(failed,id..' '..status.Name) end
  end)
  return #failed==0,#failed>0 and table.concat(failed,', ') or (tostring(#parts)..' furnished assets loaded')
 end
 if kind=='ActivatePistol' then
  p.Character.Pistol:Activate(); task.wait(.45); return true
 end
 if kind=='ExitCar' then
  local human=p.Character.Humanoid
  assert(human.SeatPart,'Driver must be seated before using exit control')
  assert(p.PlayerGui.VehicleControls.ExitVehicle.Visible,'Driver exit button is missing')
  local input=assert(game:GetService('UserInputService'):CreateVirtualInput())
  input:SendKey(true,Enum.KeyCode.F,false);task.wait(.1);input:SendKey(false,Enum.KeyCode.F,false)
  return true
 end
 if kind=='StandUp' then
  local seat=p.Character.Humanoid.SeatPart
  assert(seat and seat:IsA('Seat') and not seat:IsA('VehicleSeat'),'Furniture stand-up requires a furniture seat')
  local input=assert(game:GetService('UserInputService'):CreateVirtualInput())
  input:SendKey(true,Enum.KeyCode.Space,false);task.wait(.15);input:SendKey(false,Enum.KeyCode.Space,false)
  return true
 end
 if kind=='DriveInput' then
  local seat=p.Character.Humanoid.SeatPart
  local run=game:GetService('RunService')
  local function moveSeat() seat.ThrottleFloat=data.gas; seat.SteerFloat=data.steer end
  run:BindToRenderStep('ProbeDrive',Enum.RenderPriority.Last.Value,moveSeat)
  local sim=run.PreSimulation:Connect(moveSeat)
  local input=data.brake and assert(game:GetService('UserInputService'):CreateVirtualInput())
  if input then input:SendKey(true,Enum.KeyCode.Space,false) end
  task.wait(data.duration or 1.2)
  if input then input:SendKey(false,Enum.KeyCode.Space,false) end
  sim:Disconnect();run:UnbindFromRenderStep('ProbeDrive');return true
 end
 if kind=='RouteState' then
  local directions=workspace:WaitForChild('Local street directions',5)
  local deadline=os.clock()+8
  repeat
   local outline=directions['Nearby contact']
   local visible=directions:FindFirstChild('Street arrow')~=nil
   if (data.arrows==nil or visible==data.arrows) and (data.contact==nil or (outline.Enabled and outline.Adornee~=nil)==data.contact) then return true end
   task.wait(.1)
  until os.clock()>=deadline
  return false
 end
 if kind=='PhoneScreen' then
  local gui=p.PlayerGui:WaitForChild('NorthsideHUD')
  local untilTime=os.clock()+5
  repeat
   for _,label in gui:GetDescendants() do
    if label:IsA('TextLabel') and label.Text=='CITY PHONE' and label.Parent.Visible then label.Parent.Visible=false; return true end
   end
   task.wait(.1)
  until os.clock()>untilTime
  error('Handset screen did not open')
 end
 if kind=='LightClue' then
  for _,v in p.PlayerGui.NorthsideHUD:GetDescendants() do
   if v:IsA('TextLabel') and v.Text:match('^Memorize the sequence: ') then return v.Text:sub(#'Memorize the sequence: '+1):split('  /  ') end
  end
  return false
 end
 if kind=='MeshLoad' then
  local folder=workspace:WaitForChild('Baltimore')['Motor pool']; local car
  for _,v in folder:GetChildren() do if v:GetAttribute('FleetNumber')==(data.number or 2) then car=v end end
  local meshes={}; for _,part in car:GetChildren() do if part:IsA('MeshPart') then table.insert(meshes,part) end end; assert(#meshes>=3)
  local failed={}; game:GetService('ContentProvider'):PreloadAsync(meshes,function(id,status)
   if status~=Enum.AssetFetchStatus.Success then table.insert(failed,id..' '..status.Name) end
  end); return #failed==0,table.concat(failed,',')
 end
 if kind=='PreloadArt' then
  local labels,failures={},{}
  for _,id in data do
   local label=Instance.new('ImageLabel');label.Size=UDim2.fromOffset(1,1);label.BackgroundTransparency=1;label.Image=id;label.Parent=p.PlayerGui.NorthsideHUD;table.insert(labels,label)
  end
  game:GetService('ContentProvider'):PreloadAsync(labels,function(id,status)
   if status~=Enum.AssetFetchStatus.Success then table.insert(failures,id..' '..status.Name) end
  end)
  for _,label in labels do if not label.IsLoaded then table.insert(failures,label.Image..' not loaded') end;label:Destroy() end
  return #failures==0,table.concat(failures,', ')

 end
 if kind=='JobArrow' then
  local card=p.PlayerGui.NorthsideHUD:WaitForChild('JobDirections',5)
  if data.Hidden then return not card.Visible end
  for _,label in card:GetChildren() do
   if label:IsA('TextLabel') and label.Text:find(data.Label,1,true) then return card.Visible end
  end
  return false
 end
 if kind=='HUD' then
  local gui=p:WaitForChild('PlayerGui'):WaitForChild('NorthsideHUD',15)
  assert(gui,'HUD did not start')
  return true
 end
 action:FireServer(kind,data)
 task.wait(0.4)
 return true
end
p:SetAttribute('ProbeReady',true)

-- Gameplay suites join through the real file-selection and creation remotes.
task.spawn(function()
 while not p:GetAttribute('ResidentFiles') do task.wait(.05) end
 if script:GetAttribute('CreateFixture') then
  action:FireServer('CreateResident',{Index=1,Name='',Height='Tall',Build='Broad',Hair='High puff',Tone='Copper'})
 end
end)
