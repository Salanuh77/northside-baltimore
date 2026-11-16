local fs = require('@lune/fs')
local rb = require('@lune/roblox')
local place = rb.deserializePlace(fs.readFile('Northside Baltimore - Heritage Harbor.rbxl'))
local city = place:GetService('Workspace').Baltimore
local total = 0
local layouts = {}
for _,building in city:GetDescendants() do
 if not building:IsA('Model') then continue end
 local doors = 0
 for _,item in building:GetChildren() do
  if item:GetAttribute('Action')=='Door' and table.find({'Door','Apartment door','Rowhouse door','Townhouse door'},item.Name) and (item.Name~='Door' or building.Name:match('^Rowhome %d+$')) then doors+=1 end
 end
 if doors==0 then continue end
 local homes = 0
 for _,room in building:GetChildren() do
  if not room:GetAttribute('HomeLayout') then continue end
  homes+=1
  layouts[room:GetAttribute('HomeLayout')]=true
  local assets,actions={},{}
  for _,item in room:GetDescendants() do
   if item:IsA('MeshPart') then
    assert(item.Anchored and not item.CanCollide and not item.CanQuery,'Detailed mesh affects navigation')
    assets[item.Name]=true
   end
   local kind=item:GetAttribute('Action')
   if kind then
    actions[kind]=(actions[kind] or 0)+1
    if kind=='SitHome' or kind=='RestHome' then assert(item:IsA('Seat') and not item.CanTouch,'Seat must be intentional') end
   end
  end
  for _,name in {'Sofa upholstery','Quilted bed','Kitchen sink','Kitchen range'} do assert(assets[name],room:GetFullName()..' missing '..name) end
  assert(actions.SitHome==2 and actions.RestHome==1 and actions.UseTap==1 and actions.Cook==1,room:GetFullName()..' missing interactions')
 end
 assert(homes==doors,building:GetFullName()..' has '..doors..' residential doors but '..homes..' furnished homes')
 total+=homes
end
assert(total>100 and layouts.Flat and layouts.Rowhome and layouts.Hollins and layouts.Waterfront,'Missing residential layouts')
print('Furnished homes verified:',total)