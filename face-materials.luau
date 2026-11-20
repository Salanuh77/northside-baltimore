-- Bake plugin-protected texture properties into the place; clients only clone them.
return function(rb,parent,assets)
 local library=rb.Instance.new('Folder');library.Name='ResidentFaceMaterials'
 for _,key in {'portrait-calm','portrait-smile','portrait-focused','lips-level','lips-smile','lips-set'} do
  local material=rb.Instance.new('SurfaceAppearance');material.Name=key
  material.AlphaMode=rb.Enum.AlphaMode.Transparency
  material.ColorMap='rbxassetid://'..assert(assets[key],key)
  material.Color=rb.Color3.new(1,1,1);material.Parent=library
 end
 library.Parent=parent
 return library
end
