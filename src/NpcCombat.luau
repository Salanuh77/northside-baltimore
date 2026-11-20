return function(unit,target,valid,safe,visible,event,random,onShot)
  if not valid('police',target) or safe(target) or target:GetAttribute('Surrendered') or not visible(unit.model,target.Character,70,true) then return end
  local root=target.Character.HumanoidRootPart
  local muzzle=unit.model.Head.Position+unit.model.HumanoidRootPart.CFrame.LookVector*.8
  local spread=math.clamp((root.Position-muzzle).Magnitude*.035,.6,2.8)
  local aim=root.Position+Vector3.new(random:NextNumber(-spread,spread),random:NextNumber(-spread,spread),0)
  local direction=aim-muzzle;if direction.Magnitude<.1 then return end
  local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Exclude;ray.FilterDescendantsInstances={unit.model};ray.RespectCanCollide=false
  local hit=workspace:Raycast(muzzle,direction.Unit*80,ray)
  event:FireAllClients('Shot',{From=muzzle,To=hit and hit.Position or muzzle+direction.Unit*80})
  if onShot then onShot(muzzle) end
  -- An intervening officer or bystander stops the shot and takes no damage.
  if hit and hit.Instance:IsDescendantOf(target.Character) and not safe(target) and not target:GetAttribute('Surrendered') then target.Character.Humanoid:TakeDamage(9) end
 end
