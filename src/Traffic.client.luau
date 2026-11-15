local player=game:GetService('Players').LocalPlayer
local drive=game:GetService('ReplicatedStorage'):WaitForChild('DriveCar')
local elapsed=0
game:GetService('RunService').Heartbeat:Connect(function(dt)
 elapsed+=dt
 if elapsed<.09 then return end
 elapsed=0
 local human=player.Character and player.Character:FindFirstChildOfClass('Humanoid')
 local seat=human and human.SeatPart
 if seat and seat:IsA('VehicleSeat') and seat.Parent:GetAttribute('FleetNumber') then
  drive:FireServer(seat.ThrottleFloat,seat.SteerFloat)
 end
end)
local actions=game:GetService('ContextActionService')
local function watchCharacter(char)
 actions:UnbindAction('LeaveCityCar')
 local h=char:WaitForChild('Humanoid')
 h.Seated:Connect(function(active,seat)
  actions:UnbindAction('LeaveCityCar')
  if active and seat and seat.Parent:GetAttribute('FleetNumber') then
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
