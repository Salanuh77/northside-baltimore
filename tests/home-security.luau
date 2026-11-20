local fs=require('@lune/fs')
local rb=require('@lune/roblox')
local city=rb.deserializePlace(fs.readFile('Northside Baltimore - Heritage Harbor.rbxl')):GetService('Workspace').Baltimore
local count,leased=0,0
for _,door in city:GetDescendants() do
 if not door:IsA('BasePart') or door:GetAttribute('Action')~='Door' then continue end
 count+=1
 local solids={}
 for _,p in door.Parent:GetChildren() do
  if p:IsA('BasePart') and p.CanCollide and p~=door then table.insert(solids,p) end
 end
 for _,side in {-1,1} do
  for _,height in {-.4,0,.4} do
   local point=door.CFrame:PointToWorldSpace(rb.Vector3.new(side*(door.Size.X/2+.02),height*door.Size.Y,0))
   local sealed=false
   for _,p in solids do
    local q=p.CFrame:PointToObjectSpace(point);local h=p.Size/2
    if math.abs(q.X)<=h.X+.001 and math.abs(q.Y)<=h.Y+.001 and math.abs(q.Z)<=h.Z+.001 then sealed=true;break end
   end
   assert(sealed,door:GetFullName()..' has an unsealed side of the entrance')
  end
 end
 local link=door:FindFirstChild('Residence')
 if door.Name=='Apartment door' then assert(link,'Apartment must link to its own lease marker') end
 if link then
  leased+=1
  assert(link.Value and link.Value.Parent==door.Parent and link.Value:GetAttribute('Action')=='Residence','Lease reference must belong to the same building, including clones')
  assert(math.abs(link.Value.CFrame.Y-door.CFrame.Y)<3,'Door linked to another floor')
 end
end
assert(count>=240,'All home entrances must be inspected')
assert(leased==227,'Every rentable home needs a secured entrance')
print('PASS: '..count..' home entrances have solid jambs and apartments have floor-specific lease links')
