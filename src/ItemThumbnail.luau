-- Small, self-contained product photographs rendered from game-owned geometry.
local storage=game:GetService('ReplicatedStorage')
local Thumbnail={}
function Thumbnail.attach(parent,key)
 local view=Instance.new('ViewportFrame');view.Name='Item image';view.BackgroundTransparency=1
 view.Size=UDim2.fromScale(1,1);view.Ambient=Color3.fromRGB(200,200,200)
 view.LightColor=Color3.fromRGB(255,246,228);view.LightDirection=Vector3.new(-1,-1,-1)
 view.Parent=parent
 local world=Instance.new('WorldModel');world.Parent=view
 local model=Instance.new('Model');model.Name=key;model.Parent=world
 local builder={model=model}
 function builder.part(name,size,position,color,shape,rotation)
  local part=Instance.new(shape=='Wedge' and 'WedgePart' or 'Part')
  part.Name=name;part.Size=Vector3.new(table.unpack(size));part.Color=Color3.fromRGB(table.unpack(color))
  part.Anchored=true;part.CanCollide=false;part.CanQuery=false;part.CanTouch=false
  part.Material=Enum.Material.SmoothPlastic
  if shape=='Ball' then part.Shape=Enum.PartType.Ball elseif shape=='Cylinder' then part.Shape=Enum.PartType.Cylinder end
  part.CFrame=CFrame.new(table.unpack(position))*(rotation and CFrame.Angles(table.unpack(rotation)) or CFrame.identity)
  part.Parent=model;return part
 end
 function builder.label(part,value,color)
  local gui=Instance.new('SurfaceGui');gui.Face=Enum.NormalId.Front;gui.CanvasSize=Vector2.new(256,128);gui.Parent=part
  local text=Instance.new('TextLabel');text.Size=UDim2.fromScale(1,1);text.BackgroundTransparency=1
  text.Text=value;text.Font=Enum.Font.Oswald;text.TextScaled=true;text.TextColor3=color or Color3.new(1,1,1);text.Parent=gui
 end
 local source=storage.ItemModels:FindFirstChild(key)
 if source then require(source)(builder) else builder.part('Parcel',{1,.8,.7},{0,0,0},{164,134,96}) end
 local bounds,size=model:GetBoundingBox()
 local camera=Instance.new('Camera');camera.FieldOfView=34
 local distance=math.max(size.X,size.Y,size.Z)*2.05
 camera.CFrame=CFrame.lookAt(bounds.Position+Vector3.new(.62,.35,-1).Unit*distance,bounds.Position)
 camera.Parent=view;view.CurrentCamera=camera
 view:SetAttribute('ItemKey',key)
 return view
end
return Thumbnail
