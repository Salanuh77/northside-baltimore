-- Keep bed placement and cleanup on the server; no client-supplied destination.
local Rest={}
local sessions={}

function Rest.stand(player)
 local session=sessions[player]
 if session then session.human.Sit=false;session.finish() end
end

function Rest.start(player,seat,human)
 local character=human.Parent
 local root=character:FindFirstChild('HumanoidRootPart')
 local surface=seat:GetAttribute('RestSurface')
 if not root or typeof(surface)~='CFrame' or sessions[player] then return false end
 seat:Sit(human)
 local weld=seat:FindFirstChild('SeatWeld') or seat:WaitForChild('SeatWeld',1)
 if not weld or seat.Occupant~=human or not weld.Part1 then human.Sit=false;return false end
 human:UnequipTools()
 local session={human=human,connections={}}
 sessions[player]=session
 local oldRotate=human.AutoRotate
 human.AutoRotate=false
 character:SetAttribute('Resting',true)
 -- Face up, with the crown pointing toward the pillows at local +Z.
 local rootPose=surface*CFrame.new(0,root.Size.Z*.5+.15,0)*CFrame.Angles(math.pi/2,0,0)
 local relative=root.CFrame:ToObjectSpace(weld.Part1.CFrame)
 weld.C0=seat.CFrame:ToObjectSpace(rootPose*relative)*weld.C1
 local finished=false
 session.finish=function()
  if finished then return end
  finished=true;sessions[player]=nil
  for _,connection in session.connections do connection:Disconnect() end
  character:SetAttribute('Resting',nil)
  human.AutoRotate=oldRotate
  if weld.Parent then weld:Destroy() end
  if root.Parent and human.Health>0 and (root.Position-seat.Position).Magnitude<12 then
   local exit=seat:GetAttribute('RestExit')
   if typeof(exit)=='CFrame' then
    root.CFrame=exit*CFrame.new(0,human.HipHeight+root.Size.Y*.5,0)
    root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero
   end
   human:ChangeState(Enum.HumanoidStateType.GettingUp)
  end
 end
 table.insert(session.connections,seat:GetPropertyChangedSignal('Occupant'):Connect(function()
  if seat.Occupant~=human then session.finish() end
 end))
 table.insert(session.connections,human.Died:Connect(session.finish))
 table.insert(session.connections,character.AncestryChanged:Connect(function(_,parent)
  if not parent then session.finish() end
 end))
 return true
end

game.Players.PlayerRemoving:Connect(Rest.stand)
return Rest
