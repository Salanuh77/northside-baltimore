local Players=game:GetService('Players')
local Run=game:GetService('RunService')
local UIS=game:GetService('UserInputService')
local CAS=game:GetService('ContextActionService')
local Tags=game:GetService('CollectionService')
local Pose=require(script.Parent.CombatPose)
return function(gui,menuOpen)
 local player=Players.LocalPlayer;local event=game.ReplicatedStorage.CityAction
 local actors={};local guard=false;local nextGuard=0;local cameraSession;local touchBound=false
 local function watch(model)
  if actors[model] then return end
  local joints={}
  for _,j in model:GetDescendants() do if j:IsA('Motor6D') then joints[j.Name]={joint=j,rest=j.C0} end end
  actors[model]={joints=joints}
 end
 Tags:GetInstanceAddedSignal('CombatActor'):Connect(watch)
 Tags:GetInstanceRemovedSignal('CombatActor'):Connect(function(model)
  local state=actors[model];if state then for _,j in state.joints do if j.joint.Parent then j.joint.C0=j.rest end end end
  actors[model]=nil
 end)
 for _,model in Tags:GetTagged('CombatActor') do watch(model) end
 local hint=Instance.new('TextLabel');hint.Name='Fight controls';hint.Size=UDim2.fromOffset(275,46);hint.AnchorPoint=Vector2.new(.5,1);hint.Position=UDim2.new(.5,0,1,-16)
 hint.BackgroundTransparency=.2;hint.BackgroundColor3=Color3.fromRGB(17,20,24);hint.TextColor3=Color3.fromRGB(241,238,228);hint.Font=Enum.Font.GothamMedium;hint.TextSize=13;hint.Visible=false;hint.Parent=gui
 local bar=Instance.new('Frame');bar.Name='Stamina';bar.Size=UDim2.new(1,0,0,3);bar.Position=UDim2.new(0,0,1,-3);bar.BackgroundColor3=Color3.fromRGB(132,192,159);bar.BorderSizePixel=0;bar.Parent=hint
 local function fists() return player.Character and player.Character:FindFirstChild('Fists') end
 local function stopGuard() if guard then guard=false;event:FireServer('Guard',{Enabled=false}) end end
 local function toggle()
  if menuOpen() then return end
  local c=player.Character;local h=c and c:FindFirstChildOfClass('Humanoid');if not h then return end
  if fists() then h:UnequipTools();stopGuard() else local t=player.Backpack:FindFirstChild('Fists');if t then h:EquipTool(t) end end
 end
 CAS:BindAction('FightingStance',function(_,phase)
  if phase==Enum.UserInputState.Begin and not UIS:GetFocusedTextBox() then toggle() end
  return Enum.ContextActionResult.Pass
 end,false,Enum.KeyCode.G,Enum.KeyCode.DPadRight)
 local function block(_,phase)
  if phase==Enum.UserInputState.End or phase==Enum.UserInputState.Cancel then stopGuard()
  elseif phase==Enum.UserInputState.Begin and fists() and not menuOpen() and not UIS:GetFocusedTextBox() then guard=true;event:FireServer('Guard',{Enabled=true});nextGuard=os.clock()+.35 end
  return fists() and Enum.ContextActionResult.Sink or Enum.ContextActionResult.Pass
 end
 CAS:BindAction('CombatGuard',block,false,Enum.KeyCode.F,Enum.KeyCode.ButtonL2)
 CAS:BindAction('CombatPunch',function(_,phase)
  if phase==Enum.UserInputState.Begin and fists() and not menuOpen() then event:FireServer('Punch') end
  return fists() and Enum.ContextActionResult.Sink or Enum.ContextActionResult.Pass
 end,false,Enum.KeyCode.ButtonR2)
 UIS.WindowFocusReleased:Connect(stopGuard);player.CharacterRemoving:Connect(stopGuard)
 event.OnClientEvent:Connect(function(kind,data)
  if kind~='MeleeImpact' or not data.Target or not data.Target.Parent then return end
  local root=data.Target:FindFirstChild('HumanoidRootPart');if not root then return end
  local flash=Instance.new('Highlight');flash.Adornee=data.Target;flash.FillTransparency=.8;flash.OutlineTransparency=1
  flash.FillColor=data.Blocked and Color3.fromRGB(184,208,226) or Color3.fromRGB(226,161,129);flash.Parent=data.Target
  game:GetService('Debris'):AddItem(flash,.12)
  if data.Target==player.Character and data.Broken then hint.Text='GUARD BROKEN' end
 end)
 Run.PreSimulation:Connect(function(dt)
  local now=workspace:GetServerTimeNow()
  for model,state in actors do
   if not model.Parent then actors[model]=nil;continue end
   local root=model:FindFirstChild('HumanoidRootPart')
   if not root then continue end
   local mode=model:GetAttribute('CombatState') or 'Idle'
   if mode=='Idle' and model:FindFirstChild('Fists') then mode='Ready' end
   local targets=not model:GetAttribute('Ragdolled') and not model:GetAttribute('Resting') and Pose.sample(mode,model:GetAttribute('CombatCombo') or 1,now-(model:GetAttribute('CombatStarted') or now),model:GetAttribute('Activity')) or {}
   for name,j in state.joints do
    if j.joint.Parent then
     local q=targets[name];local goal=j.rest*(q and CFrame.Angles(q[1],q[2],q[3]) or CFrame.identity)
     j.joint.C0=j.joint.C0:Lerp(goal,math.min(1,dt*22))
    end
   end
  end
 end)
 Run.RenderStepped:Connect(function(dt)
  local c=player.Character;local h=c and c:FindFirstChildOfClass('Humanoid');local root=c and c:FindFirstChild('HumanoidRootPart')
  local ready=fists()~=nil and not menuOpen() and h and h.Health>0 and not h.SeatPart and not c:GetAttribute('Resting') and not c:GetAttribute('Ragdolled')
  hint.Visible=ready==true
  if ready then
   hint.Text=UIS.TouchEnabled and 'FISTS   •   THREE-HIT COMBO' or 'CLICK  PUNCH     F  BLOCK     G  LOWER'
   bar.Size=UDim2.new((c:GetAttribute('CombatStamina') or 100)/100,0,0,3)
   if not cameraSession then cameraSession={human=h,offset=h.CameraOffset,rotate=h.AutoRotate,min=player.CameraMinZoomDistance,max=player.CameraMaxZoomDistance} end
   h.CameraOffset=h.CameraOffset:Lerp(Vector3.new(1.35,.3,0),math.min(1,dt*9));h.AutoRotate=false
   player.CameraMinZoomDistance=5;player.CameraMaxZoomDistance=13
   local camera=workspace.CurrentCamera
   local look=camera.CFrame.LookVector*Vector3.new(1,0,1)
   if root and look.Magnitude>.1 then root.CFrame=root.CFrame:Lerp(CFrame.lookAt(root.Position,root.Position+look),math.min(1,dt*12)) end
   if guard and os.clock()>=nextGuard then nextGuard=os.clock()+.35;event:FireServer('Guard',{Enabled=true}) end
  else
   stopGuard()
   if cameraSession then
    local previous=cameraSession;cameraSession=nil
    if previous.human.Parent then previous.human.CameraOffset=previous.offset;previous.human.AutoRotate=previous.rotate end
    player.CameraMinZoomDistance=previous.min;player.CameraMaxZoomDistance=previous.max
   end
  end
  if UIS.TouchEnabled and (ready==true)~=touchBound then
   touchBound=ready==true
   if touchBound then
    CAS:BindAction('TouchPunch',function(_,phase) if phase==Enum.UserInputState.Begin and not menuOpen() then event:FireServer('Punch') end end,true)
    CAS:SetTitle('TouchPunch','Punch');CAS:SetPosition('TouchPunch',UDim2.new(1,-190,1,-150))
    CAS:BindAction('TouchGuard',block,true);CAS:SetTitle('TouchGuard','Block');CAS:SetPosition('TouchGuard',UDim2.new(1,-270,1,-150))
   else CAS:UnbindAction('TouchPunch');CAS:UnbindAction('TouchGuard') end
  end
 end)
end
