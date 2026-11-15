local p=game:GetService('Players').LocalPlayer
local rs=game:GetService('ReplicatedStorage')
local remote=rs:WaitForChild('TestDrive')
local action=rs:WaitForChild('CityAction')
remote.OnClientInvoke=function(kind,data)
 if kind=='Prompt' then
  local prompt=data:WaitForChild('ProximityPrompt',5)
  assert(prompt,'Interaction prompt missing')
  local camera=workspace.CurrentCamera; camera.CameraType=Enum.CameraType.Scriptable
  camera.CFrame=CFrame.lookAt(p.Character.Head.Position,data.Position); task.wait(.65)
  prompt:InputHoldBegin(); task.wait(0.7); prompt:InputHoldEnd(); task.wait(0.3)
  camera.CameraType=Enum.CameraType.Custom
  return true
 end
 if kind=='ActivatePistol' then
  p.Character.Pistol:Activate(); task.wait(.45); return true
 end
 if kind=='DriveInput' then
  local seat=p.Character.Humanoid.SeatPart
  local run=game:GetService('RunService')
  local function moveSeat() seat.ThrottleFloat=data.gas; seat.SteerFloat=data.steer end
  run:BindToRenderStep('ProbeDrive',Enum.RenderPriority.Last.Value,moveSeat)
  local sim=run.PreSimulation:Connect(moveSeat)
  task.wait(data.duration or 1.2); sim:Disconnect(); run:UnbindFromRenderStep('ProbeDrive'); return true
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
