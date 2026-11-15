local city=workspace:WaitForChild("Baltimore",30)
local mills,floors,windows=0,0,0
local function contains(part,point)
 local p=part.CFrame:PointToObjectSpace(point):Abs()-part.Size/2
 return math.max(p.X,p.Y,p.Z)<.012
end
local function seam(a,b,point)
 assert(contains(a,point) and contains(b,point),"Open joint between "..a:GetFullName().." and "..b.Name)
end
for _,mill in city:GetDescendants() do
 if not mill:IsA("Model") or not mill:FindFirstChild("Kiln chimney") then continue end
 mills+=1
 local walls={}
 for _,wall in mill:GetChildren() do
  if wall.Name=="Foundry masonry" then walls[wall]=0; floors+=1 end
 end
 assert(next(walls),"Missing mill masonry")
 for _,bay in mill:GetChildren() do
  if bay.Name~="Foundry sash" then continue end
  local sill,left,right=bay["Limestone sill"],bay["Left jamb"],bay["Right jamb"]
  local inward=sill.CFrame.LookVector
  local supporting
  for wall in walls do
   if contains(wall,left.Position+inward*.4) then supporting=wall; break end
  end
  assert(supporting,"Window above roof or detached from wall in "..mill.Name)
  walls[supporting]+=1
  for _,jamb in {left,right} do
   seam(jamb,sill,jamb.Position-jamb.CFrame.UpVector*jamb.Size.Y/2)
  end
  local prev=left
  local joint=left.Position+left.CFrame.UpVector*left.Size.Y/2
  for i=1,8 do
   local brick=bay["Voussoir "..i]
   seam(prev,brick,joint)
   local inner=brick.Position+inward*.4
   seam(brick,supporting,inner)
   -- Step just inside the far end to sample physical overlap with its neighbor.
   joint=brick.Position+brick.CFrame.RightVector*(brick.Size.X/2-.05)
   prev=brick
  end
  seam(prev,right,right.Position+right.CFrame.UpVector*right.Size.Y/2)
  windows+=1
 end
 for wall,count in walls do assert(count==20,"Incomplete window storey in "..mill.Name) end
 assert(not mill:FindFirstChild("Arched brick header"),"Superseded floating headers")
end
assert(mills==6 and floors==15 and windows==300,"Missing mills or window bays")
print("FOUNDRY_JOINTS_PASS",mills,floors,windows,windows*8)
