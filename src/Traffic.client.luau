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
local function watchCharacter(char)
 actions:UnbindAction('LeaveCityCar')
 braking=false;actions:UnbindAction('BrakeCityCar')
 local h=char:WaitForChild('Humanoid')
 h.Seated:Connect(function(active,seat)
  braking=false;actions:UnbindAction('BrakeCityCar')
  actions:UnbindAction('LeaveCityCar')
  if active and seat and seat.Parent:GetAttribute('FleetNumber') then
   actions:BindActionAtPriority('BrakeCityCar',function(_,state)
    braking=state==Enum.UserInputState.Begin or state==Enum.UserInputState.Change
    return Enum.ContextActionResult.Sink
   end,true,3000,Enum.KeyCode.Space,Enum.KeyCode.ButtonL2)
   actions:SetTitle('BrakeCityCar','Brake')
   actions:SetPosition('BrakeCityCar',UDim2.new(1,-235,1,-145))
   actions:BindAction('LeaveCityCar',function(_,state)
    if state==Enum.UserInputState.Begin and h.SeatPart then h.Sit=false;h.Jump=true end
    return Enum.ContextActionResult.Sink
   end,true,Enum.KeyCode.X,Enum.KeyCode.ButtonB)
   actions:SetTitle('LeaveCityCar','Exit car')
   actions:SetPosition('LeaveCityCar',UDim2.new(1,-160,1,-145))
  end
 end)
end
player.CharacterAdded:Connect(watchCharacter)
if player.Character then task.spawn(watchCharacter,player.Character) end
