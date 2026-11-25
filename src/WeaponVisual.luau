local Catalog=require(game.ReplicatedStorage.WeaponCatalog)
return function(tool,id,scope,suppressed)
 local spec=Catalog.get(id);local library=game.ReplicatedStorage:FindFirstChild('WeaponMeshes')
 local source=library and library:FindFirstChild(spec.Mesh)
 if not source then require(script.Parent.PistolVisual)(tool,spec.Length>2 and 'Field carbine' or 'Slate compact');return end
 local handle=tool.Handle;handle.Transparency=1;handle.Size=Vector3.new(.25,.6,.3);handle.CanTouch=false;handle.CanQuery=false
 tool.Grip=CFrame.new(0,-.12,0)
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
 mount(source,spec.Length,CFrame.new(0,.28,-spec.Length*.22))
 if scope and library:FindFirstChild('scope') then mount(library.scope,.65,CFrame.new(0,.88,-.35)) end
 if suppressed and library:FindFirstChild('suppressor') then mount(library.suppressor,.65,CFrame.new(0,id=='Compact' and .66 or .53,-spec.Length*.72-.30)) end
end
