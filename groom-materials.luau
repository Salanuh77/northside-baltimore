-- A textured MeshPart alone can keep its source RGB. Make dye tint explicit.
return function(rb,library)
 for _,mesh in library:GetDescendants() do
  if mesh:IsA('MeshPart') then
   local material=mesh:FindFirstChildOfClass('SurfaceAppearance')
   local texture=mesh.TextureContent.Uri
   if not material and texture and texture~='' then
    material=rb.Instance.new('SurfaceAppearance');material.Name='Hair fibers'
    material.ColorMap=texture;material.AlphaMode=rb.Enum.AlphaMode.Overlay
    material.Parent=mesh
   end
   if material then mesh.TextureID='' end
  end
 end
end
