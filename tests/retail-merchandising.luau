local rb = require('@lune/roblox')
local fs = require('@lune/fs')
local city = rb.deserializePlace(fs.readFile('Northside Baltimore - Heritage Harbor.rbxl')):GetService('Workspace').Baltimore
local public = {['Booking clerk']=true, ['Parcel dispatcher']=true, ['Municipal Records']=true}
local brands, stores, bays, families = {}, 0, 0, {}
for _,site in city:GetDescendants() do
 if not site:IsA('Model') then continue end
 local role
 for _,counter in site:GetChildren() do role=counter:GetAttribute('StaffRole') or role end
 if not role or public[role] or public[site.Name] then continue end
 local brand=assert(site:GetAttribute('RetailBrand'),site.Name..' lacks a real-world retail parody')
 assert(site:GetAttribute('RetailReference') and site:GetAttribute('RetailDepartment'),site.Name)
 local stock=assert(site:FindFirstChild('Retail merchandising'),site.Name)
 local glyph=assert(stock:FindFirstChild('Brand face',true),brand)
 assert(glyph:FindFirstChildOfClass('SurfaceGui'),brand..' needs a legible storefront')
 local localBays,rows,lines=0,0,{}
 for _,part in stock:GetDescendants() do
  if part.Name=='Shelf bay' then
   localBays+=1
   local physical=0
   for _,pack in part:GetChildren() do
    if pack.Name=='Shelf merchandise' and pack:IsA('BasePart') and not pack.CanCollide then physical+=1 end
   end
   assert(physical>=12,brand..' needs merchandise visible from either end of the rack')
  end
  if part:IsA('ImageLabel') then
   assert(part.ImageContent.Uri:match('^rbxassetid://%d+$') and part.ImageRectSize.X==256 and part.ImageRectSize.Y==128)
   local line=assert(part:GetAttribute('StockLine'));lines[line]=true; families[line]=true;rows+=1
  end
 end
 assert(localBays>=3 and rows>=localBays*3 and next(lines) and next(lines,next(lines)),site.Name..' stock density')
 local floor=site:FindFirstChild('Shop floor') or site:FindFirstChild('Hall floor') or site:FindFirstChild('Terrazzo floor') or site:FindFirstChild('Tile floor') or site:FindFirstChild('Floor')
 if floor.Name=='Terrazzo floor' or floor.Name=='Hall floor' then
  assert(localBays>=8,brand..' leaves large wall runs bare')
 end
 if site:FindFirstChild('Window dress form') then
  assert(stock:FindFirstChild('Apparel wall',true),brand..' needs a visible clothing collection')
 end
 local staff={}
 for _,p in site:GetChildren() do
  local at=p:GetAttribute('StaffSpot')
  if at then table.insert(staff,at.Position) end
 end
 local function allowPoint(part,point,padding,reason)
  local relative=part.CFrame:PointToObjectSpace(point)
  assert(math.abs(relative.X)>part.Size.X/2+padding or math.abs(relative.Z)>part.Size.Z/2+padding,
   site.Name..' '..part.Name..' crowds '..reason)
 end
 for _,solid in stock:GetDescendants() do
  if not solid:IsA('BasePart') or not solid.CanCollide or solid.Name=='Brand face' then continue end
  for _,at in staff do allowPoint(solid,at,1.4,'staff station') end
  for z=-floor.Size.Z/2,-floor.Size.Z*.12,1 do
   allowPoint(solid,floor.CFrame:PointToWorldSpace(rb.Vector3.new(0,0,z)),2.4,'entry aisle')
  end
  for _,x in {-1,1} do for _,z in {-1,1} do
   local corner=solid.CFrame:PointToWorldSpace(rb.Vector3.new(solid.Size.X*x/2,0,solid.Size.Z*z/2))
   local pos=floor.CFrame:PointToObjectSpace(corner)
   assert(math.abs(pos.X)<floor.Size.X/2 and math.abs(pos.Z)<floor.Size.Z/2,site.Name..' furniture outside')
  end end
 end
 local saleDesk=site:FindFirstChild('Mart till')
 if saleDesk then
  assert(stock:FindFirstChild('Hot food counter') and stock:FindFirstChild('Pump canopy emblem'),brand)
  assert(not brands[brand], 'Gas stations need distinct operators')
  brands[brand]=true
 end
 stores+=1;bays+=localBays
end
local count=0;for _ in families do count+=1 end
assert(stores>=58 and count>=28,'Missing store formats')
print('PASS citywide parody storefronts',stores,'shelf bays',bays,'illustrated stock lines',count)
