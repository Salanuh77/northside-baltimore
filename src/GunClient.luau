local Players=game:GetService('Players')
local Run=game:GetService('RunService')
local UIS=game:GetService('UserInputService')
local CAS=game:GetService('ContextActionService')
return function(gui,menuOpen)
 local player=Players.LocalPlayer;local event=game.ReplicatedStorage.CityAction
 local aiming,held,nextShot=false,false,0;local session;local touch=false
 local reticle=Instance.new('Frame');reticle.Name='Weapon reticle';reticle.AnchorPoint=Vector2.new(.5,.5);reticle.Position=UDim2.fromScale(.5,.5);reticle.Size=UDim2.fromOffset(28,28);reticle.BackgroundTransparency=1;reticle.Visible=false;reticle.Parent=gui
 for _,shape in {{12,0,2,9},{12,19,2,9},{0,12,9,2},{19,12,9,2}} do
  local p=Instance.new('Frame');p.Size=UDim2.fromOffset(shape[3],shape[4]);p.Position=UDim2.fromOffset(shape[1],shape[2]);p.BackgroundColor3=Color3.fromRGB(238,238,230);p.BorderSizePixel=0;p.Parent=reticle
 end
 local function weapon()
  local c=player.Character;local t=c and c:FindFirstChild('Pistol');local h=c and c:FindFirstChildOfClass('Humanoid')
  return t and h and h.Health>0 and not h.SeatPart and not c:GetAttribute('Ragdolled') and c:GetAttribute('CombatState')~='Stunned' and not menuOpen() and t or nil
 end
 local api={}
 function api.stop() held=false end
 function api.trigger()
  local t=weapon();if not t or os.clock()<nextShot then return end
  nextShot=os.clock()+(t:GetAttribute('Interval') or .3)
  local camera=workspace.CurrentCamera;local ray=camera:ViewportPointToRay(camera.ViewportSize.X/2,camera.ViewportSize.Y/2)
  local mouse=player:GetMouse();local point=aiming or UIS.GamepadEnabled and not UIS.MouseEnabled
  event:FireServer('Shoot',{Position=point and ray.Origin+ray.Direction*500 or mouse.Hit.Position,Aiming=aiming})
  held=t:GetAttribute('Automatic')==true
 end
 local function release() aiming=false;held=false end
 UIS.WindowFocusReleased:Connect(release);player.CharacterRemoving:Connect(release)
 CAS:BindAction('WeaponAim',function(_,phase)
  if phase==Enum.UserInputState.End or phase==Enum.UserInputState.Cancel then aiming=false
  elseif weapon() and not UIS:GetFocusedTextBox() then aiming=true end
  return Enum.ContextActionResult.Pass
 end,false,Enum.UserInputType.MouseButton2,Enum.KeyCode.ButtonL2)
 CAS:BindAction('WeaponFire',function(_,phase)
  if phase==Enum.UserInputState.Begin then api.trigger() else api.stop() end
  return weapon() and Enum.ContextActionResult.Sink or Enum.ContextActionResult.Pass
 end,false,Enum.KeyCode.ButtonR2)
 Run.RenderStepped:Connect(function(dt)
  local t=weapon();local camera=workspace.CurrentCamera
  if not t then release() end
  if held and os.clock()>=nextShot then api.trigger() end
  reticle.Visible=t~=nil and aiming
  local inset=game.GuiService:GetGuiInset()
  reticle.Position=UDim2.fromOffset(camera.ViewportSize.X/2-(gui.IgnoreGuiInset and 0 or inset.X),camera.ViewportSize.Y/2-(gui.IgnoreGuiInset and 0 or inset.Y))
  if t and aiming then
   local h=player.Character.Humanoid
   if not session then session={camera=camera,fov=camera.FieldOfView,human=h,offset=h.CameraOffset,mouse=UIS.MouseBehavior} end
   camera.FieldOfView+=( (t:GetAttribute('Scope') and 30 or 55)-camera.FieldOfView)*math.min(1,dt*12)
   h.CameraOffset=h.CameraOffset:Lerp(Vector3.new(1.4,.25,0),math.min(1,dt*12))
   if UIS.MouseEnabled then UIS.MouseBehavior=Enum.MouseBehavior.LockCenter end
  elseif session then
   session.camera.FieldOfView=session.fov
   if session.human.Parent then session.human.CameraOffset=session.offset end
   UIS.MouseBehavior=session.mouse;session=nil
  end
  if UIS.TouchEnabled and (t~=nil)~=touch then
   touch=t~=nil
   if touch then
    CAS:BindAction('TouchWeaponAim',function(_,phase) if phase==Enum.UserInputState.Begin then aiming=not aiming end end,true)
    CAS:SetTitle('TouchWeaponAim','Aim');CAS:SetPosition('TouchWeaponAim',UDim2.new(1,-190,1,-160))
   else CAS:UnbindAction('TouchWeaponAim') end
  end
 end)
 function api.effect(data)
  local source=Instance.new('Part');source.Name='Local shot audio';source.Size=Vector3.one;source.Transparency=1;source.Anchored=true;source.CanCollide=false;source.CanTouch=false;source.CanQuery=false;source.Position=data.From;source.Parent=workspace
  local sound=Instance.new('Sound');sound.SoundId='rbxasset://sounds/impact_explosion_03.mp3';sound.PlaybackSpeed=data.Suppressed and 3 or 2.4;sound.Volume=data.Suppressed and .13 or .55;sound.RollOffMinDistance=4;sound.RollOffMaxDistance=data.SoundRange or 110;sound.Parent=source;sound:Play()
  if not data.Suppressed then
   local light=Instance.new('PointLight');light.Brightness=2;light.Range=7;light.Color=Color3.fromRGB(255,202,123);light.Parent=source
   game.Debris:AddItem(light,.04)
  end
  task.delay(.23,function() if sound.Parent then sound:Stop() end end)
  game.Debris:AddItem(source,.4)
 end
 return api
end
