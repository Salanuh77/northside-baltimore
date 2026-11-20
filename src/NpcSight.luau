local Sight={}
function Sight.clearShot(model,character)
 local root=character and character:FindFirstChild('HumanoidRootPart')
 if not root then return false end
 local origin=model.Head.Position+model.HumanoidRootPart.CFrame.LookVector*.8
 local direction=root.Position-origin
 if direction.Magnitude<.1 or direction.Magnitude>80 then return false end
 local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Exclude
 ray.FilterDescendantsInstances={model};ray.RespectCanCollide=false
 local hit=workspace:Raycast(origin,direction,ray)
 return hit~=nil and hit.Instance:IsDescendantOf(character)
end
return Sight
