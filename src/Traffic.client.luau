local player=game:GetService('Players').LocalPlayer
local drive=game:GetService('ReplicatedStorage'):WaitForChild('DriveCar')
local elapsed=0
local braking=false
game:GetService('RunService').Heartbeat:Connect(function(dt)
 elapsed+=dt
 if elapsed<.06 then return end
 elapsed=0
 local human=player.Character and player.Character:FindFirstChildOfClass('Humanoid')
 local seat=human and human.SeatPart
 if seat and seat:IsA('VehicleSeat') and seat.Parent:GetAttribute('FleetNumber') then
  drive:FireServer(seat.ThrottleFloat,seat.SteerFloat,braking)
 end
end)
local actions=game:GetService('ContextActionService')
local input=game:GetService('UserInputService')
local overlay=Instance.new('ScreenGui')
overlay.Name='VehicleControls';overlay.ResetOnSpawn=false;overlay.Parent=player:WaitForChild('PlayerGui')
local exit=Instance.new('TextButton')
exit.Name='ExitVehicle';exit.AnchorPoint=Vector2.new(1,1)
exit.Size=UDim2.fromOffset(128,40)
exit.Position=input.TouchEnabled and UDim2.new(1,-80,1,-208) or UDim2.new(1,-18,1,-36)
exit.BackgroundColor3=Color3.fromRGB(29,37,42);exit.TextColor3=Color3.fromRGB(246,238,224)
exit.Font=Enum.Font.GothamMedium;exit.TextSize=15;exit.Visible=false;exit.Parent=overlay
Instance.new('UICorner',exit).CornerRadius=UDim.new(0,8)
local function exitLabel()
 local kind=input:GetLastInputType()
 exit.Text=kind.Name:match('Gamepad') and 'B   Exit vehicle' or kind==Enum.UserInputType.Touch and 'Exit vehicle' or 'F   Exit vehicle'
end
exitLabel();input.LastInputTypeChanged:Connect(exitLabel)
local function requestExit()
 if exit.Visible then drive:FireServer('Exit') end
end
exit.Activated:Connect(requestExit)
local function reset()
 braking=false;exit.Visible=false
 actions:UnbindAction('BrakeCityCar');actions:UnbindAction('LeaveCityCar')
end
local function watchCharacter(char)
 reset()
 local h=char:WaitForChild('Humanoid')
 local function seated(active,seat)
  if player.Character~=char then return end
  reset()
  if not active or not seat or not seat:IsA('VehicleSeat') or not seat.Parent:GetAttribute('FleetNumber') then return end
  exit.Visible=true; exitLabel()
  actions:BindActionAtPriority('BrakeCityCar',function(_,state)
   braking=state==Enum.UserInputState.Begin or state==Enum.UserInputState.Change
   return Enum.ContextActionResult.Sink
  end,true,3000,Enum.KeyCode.Space,Enum.KeyCode.ButtonL2)
  actions:SetTitle('BrakeCityCar','Brake')
  actions:SetPosition('BrakeCityCar',UDim2.new(1,-235,1,-145))
  actions:BindActionAtPriority('LeaveCityCar',function(_,state)
   if input:GetFocusedTextBox() then return Enum.ContextActionResult.Pass end
   if state==Enum.UserInputState.Begin then requestExit() end
   return Enum.ContextActionResult.Sink
  end,false,3000,Enum.KeyCode.F,Enum.KeyCode.X,Enum.KeyCode.ButtonB)
 end
 h.Seated:Connect(seated)
 seated(h.SeatPart~=nil,h.SeatPart)
end
player.CharacterRemoving:Connect(reset)
player.CharacterAdded:Connect(watchCharacter)
if player.Character then task.spawn(watchCharacter,player.Character) end
