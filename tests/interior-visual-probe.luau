-- Native Studio review only; not part of the production place or automated release gates.
local players=game.Players
local drive=game.ReplicatedStorage:WaitForChild('TestDrive')
local views={
 {'North Avenue Fuel',{0,6,-22},{0,4,1}},
 {'North Avenue Fuel',{-5,6,-8},{10,4,5}},
 {'Juniper Barber',{3,6,-10},{0,5,11}},
 {'Harbor Roasters',{0,6,-15},{-16,4,4}},
 {'Exchange Streetwear',{0,6,-17},{13,5,8}},
 {'NORTHSIDE CLINIC',{0,6,-16},{-12,4,8}},
}
local ok,err=pcall(function()
 local deadline=os.clock()+90
 repeat task.wait(.2) until (#players:GetPlayers()==2 and players:GetPlayers()[1]:GetAttribute('ProbeSpawnFinished') and players:GetPlayers()[2]:GetAttribute('ProbeSpawnFinished')) or os.clock()>deadline
 assert(#players:GetPlayers()==2,'Two review clients required')
 for index,v in views do
  local site=assert(workspace.Baltimore:FindFirstChild(v[1],true),v[1])
  local floor=site:FindFirstChild('Shop floor') or site:FindFirstChild('Floor') or site:FindFirstChild('Hall floor') or site:FindFirstChild('Terrazzo floor') or site:FindFirstChild('Tile floor')
  local at=floor.CFrame*CFrame.new(0,floor.Size.Y/2,0)
  local eye,look=at:PointToWorldSpace(Vector3.new(table.unpack(v[2]))),at:PointToWorldSpace(Vector3.new(table.unpack(v[3])))
  for _,p in players:GetPlayers() do
   p:RequestStreamAroundAsync(look,5)
   p.Character:PivotTo(CFrame.new(eye+Vector3.new(0,-12,0)));p.Character.HumanoidRootPart.Anchored=true
   drive:InvokeClient(p,'InteriorView',{Frame=CFrame.lookAt(eye,look),Focus=CFrame.new(look)})
  end
  print('INTERIOR_REVIEW_VIEW',index,v[1]);task.wait(40)
 end
end)
game:GetService('StudioTestService'):EndTest({ok=ok,error=tostring(err)})
