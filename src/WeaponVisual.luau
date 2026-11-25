local Catalog=require(game.ReplicatedStorage.WeaponCatalog)
return function(tool,id,scope,suppressed)
 local spec=Catalog.get(id);local library=game.ReplicatedStorage:FindFirstChild('WeaponMeshes')
 local source=library and library:FindFirstChild(spec.Mesh)
 if not source then require(script.Parent.PistolVisual)(tool,spec.Length>2 and 'Field carbine' or 'Slate compact');return end
 local handle=tool.Handle;handle.Transparency=1;handle.Size=Vector3.new(.25,.6,.3);handle.CanTouch=false;handle.CanQuery=false
 tool.Grip=CFrame.new(0,-.08,0)
 local function mount(template,length,offset)
  local model=template:Clone();model.Name=template.Name..' exterior'
  local bounds,size=model:GetBoundingBox();local scale=length/size.Z
  model:ScaleTo(model:GetScale()*scale);bounds,size=model:GetBoundingBox()
  model:PivotTo(handle.CFrame*offset*bounds:ToObjectSpace(model:GetPivot()))
  for _,part in model:GetDescendants() do
   if part:IsA('BasePart') then
    part.Anchored=false;part.CanCollide=false;part.CanTouch=false;part.CanQuery=false;part.Massless=true
    local weld=Instance.new('WeldConstraint');weld.Part0=handle;weld.Part1=part;weld.Parent=part
   end
  end
  model.Parent=tool
 end
 -- Each anchor is measured on the source silhouette in normalized body space.
 -- Put the grip at the palm; do not float every receiver over a shared offset.
 local bodyY,bodyZ=-spec.GripY*spec.Length,-spec.GripZ*spec.Length
 mount(source,spec.Length,CFrame.new(0,bodyY,bodyZ))
 if scope and spec.Scope and library:FindFirstChild('scope') then
  local size=library.scope:GetAttribute('NormalizedSize');local length=.4
  mount(library.scope,length,CFrame.new(0,bodyY+spec.RailY*spec.Length+size.Y*length/2-.01,bodyZ+spec.ScopeZ*spec.Length))
 end
 if suppressed and spec.Suppressor and library:FindFirstChild('suppressor') then
  local length=.4
  mount(library.suppressor,length,CFrame.new(0,bodyY+spec.MuzzleY*spec.Length,bodyZ-spec.Length/2-length/2+.025))
 end
end
