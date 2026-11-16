local fs = require('@lune/fs')
local rb = require('@lune/roblox')
local city = rb.deserializePlace(fs.readFile('Northside Baltimore - Heritage Harbor.rbxl')):GetService('Workspace').Baltimore
local candidates = {['Gallery window']=true,['Bedroom sash']=true,['Double hung sash']=true,['Upper window']=true,['Ground window']=true,['Rear sash']=true,['Office glazing']=true}
local totals = {}
local function inspect(building)
 local walls = {}
 for _,part in building:GetChildren() do
  if part:IsA('BasePart') and part.Transparency < .1 and part.Size.Y > 1 and (part.Material==rb.Enum.Material.Brick or part.Material==rb.Enum.Material.Concrete or part.Material==rb.Enum.Material.Wood or part.Material==rb.Enum.Material.Limestone) then
   table.insert(walls,{cf=part.CFrame,half=part.Size/2,name=part.Name})
  end
 end
 for _,pane in building:GetChildren() do
  if not candidates[pane.Name] then continue end
  for _,wall in walls do
   local relative=wall.cf:ToObjectSpace(pane.CFrame)
   local reach=pane.Size.Magnitude/2+1.1
   local c=relative.Position
   local h=wall.half
   if math.abs(c.X)>h.X+reach or math.abs(c.Y)>h.Y+reach or math.abs(c.Z)>h.Z+reach then continue end
   for _,horizontal in {-.28,.28} do
    for _,vertical in {-.22,.22} do
     for depth=-4,4 do
      local point=relative:PointToWorldSpace(rb.Vector3.new(pane.Size.X*horizontal,pane.Size.Y*vertical,depth*.27))
      assert(math.abs(point.X)>=h.X-.01 or math.abs(point.Y)>=h.Y-.01 or math.abs(point.Z)>=h.Z-.01,building.Name..' / '..pane.Name..' is blocked by '..wall.name)
     end
    end
   end
  end
  assert(pane.Transparency >= .3 and pane.Transparency < 1,building.Name..' / '..pane.Name..' needs glazing you can see through')
  totals[pane.Name]=(totals[pane.Name] or 0)+1
 end
end
inspect(assert(city:FindFirstChild('Ashland Courts Walkups',true)))
for _,building in city:GetDescendants() do
 if building:IsA('Model') and building.Name~='Ashland Courts Walkups' and (building:FindFirstChild('Gallery window') or building:FindFirstChild('Hall floor') or building.Name:match('^Rowhome %d+$') or building.Name:match('^Hollins Row %d+$')) then inspect(building) end
end
for name in candidates do assert(totals[name] and totals[name]>0,'No windows inspected for '..name); print(name,totals[name]) end
print('PASS clear openings through occupied residential facades')