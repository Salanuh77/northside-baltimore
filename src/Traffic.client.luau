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