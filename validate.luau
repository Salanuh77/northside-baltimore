local fs=require('@lune/fs')
local luau=require('@lune/luau')
local rb=require('@lune/roblox')
for _,name in {'src/ResidentMenu.client.luau','src/ResidentFiles.luau','src/VehicleHandling.luau','src/WalkingRoutes.luau','src/StreetTrail.luau','src/JobBearing.luau','src/ServerBrowser.luau','src/ServerDirectory.luau','src/CityServer.server.luau','src/CityClient.client.luau','src/RetailUI.luau','src/CityRetail.luau','src/CityClock.server.luau','src/StreetStyle.luau','src/Traffic.server.luau','src/Traffic.client.luau','src/WorkService.luau','src/WorkCatalog.luau','src/NeighborhoodLife.luau','src/Responders.luau','src/Custody.luau','prison.luau','src/LifeUI.luau','downtown.luau','citylife.luau','roads.luau','districts.luau','fleet.luau','build.luau'} do
 local f=luau.load(fs.readFile(name),{debugName=name}); assert(f); print('COMPILES',name)
end
local game=rb.deserializePlace(fs.readFile('Northside Baltimore - Heritage Harbor.rbxl'))
for _,source in game:GetDescendants() do
 if source:IsA('LuaSourceContainer') then assert(luau.load(source.Source,{debugName=source:GetFullName()})) end
end
local world=game:GetService('Workspace'); local city=world:FindFirstChild('Baltimore'); assert(city)
local counts={}; local parts=0
for _,v in city:GetDescendants() do
 if v:IsA('BasePart') then
  parts+=1; assert(v.Anchored,'Unanchored map part: '..v:GetFullName())
  assert(v.Size.X>0 and v.Size.Y>0 and v.Size.Z>0)
  local action=v:GetAttribute('Action'); if action then counts[action]=(counts[action] or 0)+1 end
 end
end
print('Home and store counts',counts.Home,counts.Store)
assert(#city['Motor pool']:GetChildren()==20 and #city['Streets & alleys']['Traffic signals']:GetChildren()==120)
assert(counts.Home==214 and counts.Door>=214,'Missing homes or doors')
assert(counts.Delivery==11 and counts.Store==13 and counts.Market==1 and counts.Fence==1)
assert(counts.WorkStop==13); assert(counts.Mart==3 and counts.Fuel==6 and counts.Club==1 and counts.Residence>=210); assert(counts.Bank==1 and counts.Heal==1 and counts.Job==1)
assert(game:GetService('ServerStorage'):FindFirstChild('OriginalMap_Archive'),'Original map not preserved')
for _,v in game:GetService('ServerStorage').OriginalMap_Archive:GetDescendants() do
 if v:IsA('BaseScript') then assert(v.Disabled,'Archived script is active') end
end
assert(game:GetService('ServerScriptService'):FindFirstChild('CityServer'))
assert(game:GetService('StarterPlayer'):FindFirstChildOfClass('StarterPlayerScripts'):FindFirstChild('CityClient'))
assert(world:FindFirstChild('Baltimore'):FindFirstChild('CommunitySpawn'))
for k,v in counts do print('INTERACTION',k,v) end
print('PASS: place roundtrip, script compilation, '..parts..' anchored map parts, original archive, spawn, interactions.')

local crowns,gateways,murals=0,0,0
for _,v in city:GetDescendants() do
 if v.Name=='Raised crown lettering' then assert(v.Transparency==1 and v:FindFirstChildOfClass('SurfaceGui')); crowns+=1 end
 if v.Name=='Engraved limestone' then gateways+=1 end
 assert(v.Name~='Painted mural' and v.Name~='Brick mural wall','Old mural backing remains')
 if v.Name=='Alley paint' then
  local wall=v.Parent
  assert(wall.Material==rb.Enum.Material.Brick and v:IsA('SurfaceGui') and v.LightInfluence==1 and not v.AlwaysOnTop)
  assert((wall.Name=='Rear' and v.Face==rb.Enum.NormalId.Front) or ((wall.Name=='Back wall' or wall.Name=='Gallery back wall') and v.Face==rb.Enum.NormalId.Back))
  local clip=v:FindFirstChildOfClass('Frame')
  local image=clip:FindFirstChildOfClass('ImageLabel')
  assert(clip.ClipsDescendants and clip.BackgroundTransparency==1 and image.BackgroundTransparency==1)
  local uri=image.ImageContent.Uri
  local art=require('@lune/serde').decode('json',fs.readFile('art/assets.json'))
  assert(uri=='rbxassetid://'..art[v:GetAttribute('ArtCollection')] and image.ImageTransparency>0)
  for _,axis in {'X','Y'} do
   local pos,half=clip.Position[axis].Scale,clip.Size[axis].Scale/2
   assert(pos>=half and pos+half<=1,'Paint crosses wall boundary on '..wall.Parent.Name)
  end
  murals+=1
 end
 assert(v.Name~='Court address' and v.Name~='Retail transom','Superseded facade sign in city')
end
assert(crowns==3 and gateways==7 and murals==22)
print('SIGNAGE',crowns,'tower wordmarks,',gateways,'neighborhood monuments,',murals,'mural surfaces')

local fleet={}
for _,m in city['Motor pool']:GetChildren() do
 assert(m:FindFirstChild('Paint'):IsA('MeshPart') and m:FindFirstChild('Glass'):IsA('MeshPart'))
 fleet[m:GetAttribute('BodyStyle')]=true
end
for _,v in {'Sport','Muscle','Van','Bus','Medic','Patrol','Cab','Estate','Utility','Saloon'} do assert(fleet[v],v) end
assert(counts.BailDesk==2 and counts.EscapeGame==1)
for _,p in city:GetDescendants() do
 assert(p.Name~='Folded standing seam roof' and p.Name~='Shop fascia' and p.Name~='Shop name','Superseded storefront')
end

local paired=0
for _,hall in city:GetDescendants() do
 local floor=hall:IsA('Model') and hall:FindFirstChild('Hall floor')
 if floor then
  local ceiling=assert(hall:FindFirstChild('Continuous ceiling'))
  local volume=assert(hall:FindFirstChild('Upper rear masonry'))
  local top=ceiling.CFrame.Y+ceiling.Size.Y/2
  assert(top>=volume.CFrame.Y-volume.Size.Y/2,'Open ceiling joint in '..hall.Name)
  local transom=assert(hall:FindFirstChild('Upper transom glazing'))
  assert(transom.CFrame.Y+transom.Size.Y/2+.06>=ceiling.CFrame.Y-ceiling.Size.Y/2,'Open transom joint in '..hall.Name)
  if hall.Name:sub(-7)==' Coffee' and hall.Parent:FindFirstChild(hall.Name:sub(1,-8)..' retail walk') then
   local joined=false
   for _,other in hall.Parent:GetChildren() do
    local neighbor=other:FindFirstChild('Hall floor')
    if neighbor and neighbor~=floor and math.abs(neighbor.CFrame.Z-floor.CFrame.Z)<.05 and math.abs(math.abs(neighbor.CFrame.X-floor.CFrame.X)-(floor.Size.X+neighbor.Size.X)/2)<.05 then joined=true end
   end
   assert(joined and hall:FindFirstChild('Round enamel coffee sign'),'Open retail frontage in '..hall.Name); paired+=1
  end
 end
end
assert(paired==12); print('Verified twelve joined retail frontages and all hall ceiling joints.')
