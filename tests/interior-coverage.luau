local rb,fs=require('@lune/roblox'),require('@lune/fs')
local game=rb.deserializePlace(fs.readFile('Northside Baltimore - Heritage Harbor.rbxl'))
local city=game:GetService('Workspace').Baltimore
local sites,logos,homes,types=0,0,0,{}
for _,site in city:GetDescendants() do
 if site:IsA('Model') and site:GetAttribute('RetailBrand') then
  sites+=1
  local count=0
  for _,p in site:GetDescendants() do
   local key=p:GetAttribute('MeshyPropKey');if key then count+=1;types[key]=true end
   if p:IsA('ImageLabel') and p:GetAttribute('BrandEmblem') then
    logos+=1
    assert(p.BackgroundTransparency==1 and p.ImageRectSize.X>250 and p.ImageRectSize.Y>250,site.Name..' invalid logo cell')
    assert(p.ImageContent.Uri:match('^rbxassetid://%d+$'),site.Name..' missing published logo')
   end
  end
  assert(count>=3,site.Name..' still has a primitive-only interior')
  assert(site:GetAttribute('RetailBrandKey'),site.Name..' missing logo identity')
 end
 if site:IsA('Model') and site:GetAttribute('HomeLayout') then
  homes+=1;assert(site:FindFirstChild('Personal wardrobe'),site.Name..' needs lived-in storage')
 end
end
assert(sites>=61 and logos>=sites*2,'Incomplete storefront emblem coverage')
assert(homes>=240,'Missing home furniture coverage')
for _,name in {'District police desk','Medic dispatch','COMMUNITY CENTER','Patapsco Detention Center','Civic clock tower'} do
 local site=assert(city:FindFirstChild(name,true),name)
 local imported=false
 for _,p in site:GetDescendants() do if p:GetAttribute('MeshyPropKey') then imported=true;break end end
 assert(imported,name..' still lacks imported furniture')
end
for _,key in {'stocked-gondola','store-chiller','checkout-counter','clothing-rail','shoe-wall','bookcase','laundry-machines','barber-vanity','diner-booth','clinic-exam','office-desk'} do assert(types[key],'Unused imported prop '..key) end
print('PASS Meshy interiors',sites,'illustrated logos',logos,'furnished homes',homes)
