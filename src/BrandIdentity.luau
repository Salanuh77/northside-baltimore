-- One atlas cell per operator. Transparent artwork is shared by signs and shop menus.
local BrandIdentity={}
local order={'roast','donut','bagel','diner','market','discount','fresh','pharmacy','books','record','camera','print','gallery','press','wear','shoes','sports','outdoors','hardware','wash','barber','club','arcade','cinema','bank','clinic','goose','roost','late','police','housing','dock'}
function BrandIdentity.cell(key)
 local index=table.find(order,key);if not index then return nil end
 local atlas=index<=16 and 'store-emblems-a' or 'store-emblems-b'
 local slot=(index-1)%16;local x,y=slot%4,math.floor(slot/4)
 -- The generated sheets are 1261 x 1247, not a power-of-two atlas.
 local left,top=math.floor(x*1261/4),math.floor(y*1247/4)
 return {atlas=atlas,x=left,y=top,w=math.floor((x+1)*1261/4)-left,h=math.floor((y+1)*1247/4)-top}
end
function BrandIdentity.image(parent,key,assets)
 local cell=assert(BrandIdentity.cell(key),'Unknown business emblem '..tostring(key))
 local image=Instance.new('ImageLabel');image.Name='Business emblem';image.BackgroundTransparency=1
 image.Image='rbxassetid://'..tostring(assets[cell.atlas]);image.ImageRectOffset=Vector2.new(cell.x,cell.y)
 image.ImageRectSize=Vector2.new(cell.w,cell.h);image.ScaleType=Enum.ScaleType.Fit
 image:SetAttribute('BrandEmblem',key);image.Size=UDim2.fromScale(1,1);image.Parent=parent
 return image
end
return BrandIdentity
