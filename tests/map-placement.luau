local rb=require('@lune/roblox')
local fs=require('@lune/fs')
local city=rb.deserializePlace(fs.readFile('Northside Baltimore - Heritage Harbor.rbxl')):GetService('Workspace').Baltimore
local roads,shops,props,walks={},{},{},{}
local names={Trunk=true,Crown=true,['Tree trunk']=true,['Tree canopy']=true,['Slatted seat']=true,['Park bench seat']=true,['Trash bin']=true}
local floors={['Tile floor']=true,['Shop floor']=true,['Hall floor']=true,['Apartment floor']=true,['Terrazzo floor']=true,['Station house floor']=true,['Ground floor']=true,['Stone floor']=true,['Floor']=true,['Foundation']=true}
local paving={['Park path']=true,['Entrance walk']=true,['Courtyard walk']=true,['Access walk']=true,['Sidewalk extension']=true,['Station apron']=true,['Gallery deck']=true,['Public walk']=true,['Tower entrances']=true}
for _,v in city:GetDescendants() do
 if not v:IsA('BasePart') then continue end
 if v.Name=='Carriageway' then table.insert(roads,v)
 elseif floors[v.Name] and v.CFrame.Y<2 then table.insert(shops,v)
 elseif names[v.Name] then table.insert(props,v)
 elseif paving[v.Name] and v.CFrame.Y<2 then table.insert(walks,v) end
end
local function extent(p)
 local f=p.CFrame
 local h=p.Size/2
 return math.abs(f.RightVector.X)*h.X+math.abs(f.LookVector.X)*h.Z,math.abs(f.RightVector.Z)*h.X+math.abs(f.LookVector.Z)*h.Z
end
local function overlaps(a,b)
 local ax,az=extent(a);local bx,bz=extent(b)
 return math.abs(a.CFrame.X-b.CFrame.X)<ax+bx-.08 and math.abs(a.CFrame.Z-b.CFrame.Z)<az+bz-.08
end
local issues={}
local function issue(a,b)
 issues[a.Parent.Name..' / '..a.Name..' at '..math.floor(a.CFrame.X)..','..math.floor(a.CFrame.Z)..' overlaps '..b.Parent.Name..' / '..b.Name]=true
end
for _,p in props do
 for _,r in roads do if overlaps(p,r) then issue(p,r) end end
 for _,f in shops do if p.Parent~=f.Parent and overlaps(p,f) then issue(p,f) end end
end
for _,p in walks do for _,r in roads do if overlaps(p,r) then issue(p,r) end end end
for message in issues do print(message) end
assert(not next(issues),'Street furnishing, interior or road overlap')
print('MAP_PLACEMENT_PASS',#roads,'carriageways',#shops,'ground floors',#props,'furnishings',#walks,'walks and aprons')
