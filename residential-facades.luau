local rb = require('@lune/roblox')
local rgb = rb.Color3.fromRGB
local Facade = {}

-- Lay masonry up to each edge of a real opening, including on the room side.
function Facade.bay(p,left,right,bottom,top,z,tint,material,x,y,width,height)
 local a,b=x-width/2,x+width/2
 local sill,head=y-height/2,y+height/2
 local function fill(name,l,r,low,high)
  if r-l>.01 and high-low>.01 then
   p(name,r-l,high-low,.8,(l+r)/2,(low+high)/2,z,tint,material)
  end
 end
 fill('Masonry jamb',left,a,bottom,top)
 fill('Masonry jamb',b,right,bottom,top)
 fill('Masonry apron',a,b,bottom,sill)
 fill('Masonry head',a,b,head,top)
end

function Facade.sash(p,name,x,y,z,width,height,outward,trim,paired)
 local pane=p(name,width-.50,height-.54,.16,x,y,z-outward*.16,rgb(169,193,196),'Glass')
 pane.Transparency=.62
 pane.Reflectance=.045
 local railZ=z+outward*.04
 for _,side in {-1,1} do
  p('Sash jamb',.26,height,.64,x+side*(width/2-.13),y,railZ,trim,'Metal')
  p('Sash rail',width,.28,.64,x,y+side*(height/2-.14),railZ,trim,'Metal')
 end
 p('Meeting rail',width-.45,.19,.29,x,y+height*.08,z+outward*.08,trim,'Metal')
 if paired then p('Center mullion',.27,height-.45,.52,x,y,railZ,trim,'Metal') end
 p('Cast stone sill',width+.65,.33,1.32,x,y-height/2-.13,z+outward*.22,rgb(182,168,145),'Limestone')
 p('Soldier course lintel',width+.74,.54,1.04,x,y+height/2+.24,z+outward*.08,rgb(135,88,66),'Brick')
 return pane
end

-- The pressed panels and hardware ride the swinging leaf in both the editor and game.
function Facade.entry(door,face)
 local surface=rb.Instance.new('SurfaceGui')
 surface.Name='Door finish'
 surface.Face=face
 surface.LightInfluence=1
 surface.MaxDistance=95
 surface.SizingMode=rb.Enum.SurfaceGuiSizingMode.FixedSize
 surface.CanvasSize=rb.Vector2.new(132,204)
 surface.Parent=door
 local shade=door.Color:Lerp(rgb(26,35,36),.38)
 local highlight=door.Color:Lerp(rgb(215,206,179),.24)
 local function rect(name,x,y,w,h,color)
  local tile=rb.Instance.new('Frame')
  tile.Name=name;tile.BorderSizePixel=0
  tile.Position=rb.UDim2.fromOffset(x,y);tile.Size=rb.UDim2.fromOffset(w,h)
  tile.BackgroundColor3=color;tile.Parent=surface
 end
 for _,row in {{18,76},{114,66}} do
  for _,x in {13,70} do
   rect('Recess shadow',x,row[1],48,row[2],shade)
   rect('Painted bevel',x+2,row[1]+2,44,row[2]-3,highlight)
   rect('Inset panel',x+4,row[1]+4,40,row[2]-7,door.Color)
  end
 end
 rect('Lock plate',113,95,8,15,rgb(81,77,67))
 rect('Lever',103,100,16,3,rgb(187,174,145))
 rect('Peephole bezel',64,65,4,4,rgb(129,120,101))
 rect('Peephole lens',65,66,2,2,rgb(40,44,41))
end

return Facade
