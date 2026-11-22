local rb=require('@lune/roblox')
local props=require('./interior-props')
local CF,V=rb.CFrame,rb.Vector3.new
return function(city)
 for _,site in city:GetDescendants() do
  if not site:IsA('Model') then continue end
  local floor=site:FindFirstChild('Station house floor')
  if floor then
   local at=floor.CFrame*CF.new(0,floor.Size.Y/2,0)
   for _,s in {-1,1} do
    props.add(site,'office-desk','Dispatch workstation',at*CF.new(s*11,0,6),V(8,4.5,5.9),true)
    props.add(site,'bookcase','Case records',at*CF.new(s*11,0,13.7),V(8,4,1),true)
   end
  elseif site.Name=='COMMUNITY CENTER' then
   local f=site.Floor;local at=f.CFrame*CF.new(0,f.Size.Y/2,0)
   for _,s in {-1,1} do props.add(site,'office-desk','Parcel sorting office',at*CF.new(s*19,0,7),V(10,5.6,7.4),true) end
  elseif site.Name=='Patapsco Detention Center' then
   local floor=site:FindFirstChild('Visiting lobby floor')
   if floor then
    local at=floor.CFrame*CF.new(0,floor.Size.Y/2,0)
    props.add(site,'office-desk','Custody records office',at*CF.new(-32,0,-2),V(8,4.5,5.9),true)
   end
  elseif site.Name=='Civic clock tower' then
   local f=site:FindFirstChild('Council entrance');local at=f.CFrame*CF.new(0,f.Size.Y/2,0)
   for _,s in {-1,1} do
    props.add(site,'office-desk','Constituent service desk',at*CF.new(s*51,0,6),V(9,5,6.5),true)
    props.add(site,'bookcase','Municipal records',at*CF.new(s*49,0,13.6),V(15,5.6,1.3),true)
   end
  end
 end
end
