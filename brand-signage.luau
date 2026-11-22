local rb=require('@lune/roblox')
local identity=require('./src/BrandIdentity')
local assets=require('@lune/serde').decode('json',require('@lune/fs').readFile('art/assets.json'))
local CF,V,C,E,U=rb.CFrame,rb.Vector3.new,rb.Color3,rb.Enum,rb.UDim2
local M={}
function M.image(parent,key)
 local cell=assert(identity.cell(key),key)
 local image=rb.Instance.new('ImageLabel');image.Name='Business emblem';image.BackgroundTransparency=1
 image.Image='rbxassetid://'..assert(assets[cell.atlas],cell.atlas);image.ImageRectOffset=rb.Vector2.new(cell.x,cell.y)
 image.ImageRectSize=rb.Vector2.new(cell.w,cell.h);image.ScaleType=E.ScaleType.Fit
 image:SetAttribute('BrandEmblem',key);image.Size=U.fromScale(1,1);image.Parent=parent;return image
end
function M.blade(stock,frame,width,depth,b)
 local function part(name,size,at,color)
  local p=rb.Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=at;p.Color=color;p.Material=E.Material.Metal
  p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Parent=stock;return p
 end
 local location=frame*CF.new(width*.34,9.2,-depth/2-2.5)
 part('Emblem wall bracket',V(.22,.22,4.6),location*CF.new(0,2.25,.1),C.fromRGB(61,64,62))
 for _,z in {-1.4,1.4} do part('Emblem hanger',V(.14,.6,.14),location*CF.new(0,1.94,z),C.fromRGB(174,137,82)) end
 local sign=part('Illustrated shop blade',V(3.65,3.65,.26),location*CF.Angles(0,math.pi/2,0),C.fromHex(b[4]))
 for _,face in {E.NormalId.Front,E.NormalId.Back} do
  local gui=rb.Instance.new('SurfaceGui');gui.Name='Operator emblem';gui.Face=face;gui.CanvasSize=rb.Vector2.new(320,320)
  gui.LightInfluence=.35;gui.MaxDistance=145;gui.Parent=sign;M.image(gui,b.Key)
 end
 local lamp=rb.Instance.new('PointLight');lamp.Color=C.fromRGB(255,218,164);lamp.Range=10;lamp.Brightness=.35;lamp.Parent=sign
end
return M
