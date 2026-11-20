-- Seat animations bend knees as if using a chair. Beds use a neutral supine pose.
local players=game:GetService('Players')
local actions=game:GetService('ContextActionService')
local input=game:GetService('UserInputService')
local event=game.ReplicatedStorage:WaitForChild('CityAction')
local active={}
local function watch(character)
 local function changed()
  if character:GetAttribute('Resting') then
   if active[character] then return end
   local animate=character:FindFirstChild('Animate')
   active[character]={animate=animate,enabled=animate and animate.Enabled,joints={}}
   if animate then animate.Enabled=false end
   for _,joint in character:GetDescendants() do
    if joint:IsA('Motor6D') then table.insert(active[character].joints,joint) end
   end
   if character==players.LocalPlayer.Character then
    actions:BindActionAtPriority('LeaveBed',function(_,state)
     if input:GetFocusedTextBox() then return Enum.ContextActionResult.Pass end
     if state==Enum.UserInputState.Begin then event:FireServer('StandFromBed') end
     return Enum.ContextActionResult.Sink
    end,true,3100,Enum.KeyCode.Space,Enum.KeyCode.ButtonB)
    actions:SetTitle('LeaveBed','Get up')
    actions:SetPosition('LeaveBed',UDim2.new(1,-190,1,-160))
   end
  else
   local previous=active[character];active[character]=nil
   if previous and previous.animate and previous.animate.Parent then previous.animate.Enabled=previous.enabled end
   if character==players.LocalPlayer.Character then actions:UnbindAction('LeaveBed') end
  end
 end
 character:GetAttributeChangedSignal('Resting'):Connect(changed)
 character.AncestryChanged:Connect(function(_,parent)
  if not parent then active[character]=nil end
 end)
 changed()
end
local function playerAdded(player)
 player.CharacterAdded:Connect(watch)
 if player.Character then watch(player.Character) end
end
players.PlayerAdded:Connect(playerAdded)
for _,player in players:GetPlayers() do playerAdded(player) end
players.LocalPlayer.CharacterRemoving:Connect(function() actions:UnbindAction('LeaveBed') end)
game:GetService('RunService').PreSimulation:Connect(function()
 for character,session in active do
  local humanoid=character:FindFirstChildOfClass('Humanoid')
  local animator=humanoid and humanoid:FindFirstChildOfClass('Animator')
  if animator then for _,track in animator:GetPlayingAnimationTracks() do track:Stop(0) end end
  for _,joint in session.joints do if joint.Parent then joint.Transform=CFrame.identity end end
 end
end)
