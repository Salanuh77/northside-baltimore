-- Validate a walking destination against actual map geometry before routing there.
local Ground={}
function Ground.choose(model,candidates,direct)
 local root=model.HumanoidRootPart
 local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Exclude
 ray.FilterDescendantsInstances={model};ray.RespectCanCollide=true
 local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Exclude
 overlap.FilterDescendantsInstances={model};overlap.RespectCanCollide=true;overlap.MaxParts=1
 local height=model.Humanoid.HipHeight+root.Size.Y/2
 for _,point in candidates do
  local floor=workspace:Raycast(point+Vector3.new(0,4,0),Vector3.new(0,-10,0),ray)
  if not floor or floor.Normal.Y<.75 or floor.Material==Enum.Material.Water then continue end
  local goal=floor.Position+Vector3.new(0,height,0)
  if math.abs(goal.Y-root.Position.Y)>3 then continue end
  local volume=Vector3.new(2.4,3.8,2.4)
  if #workspace:GetPartBoundsInBox(CFrame.new(goal+Vector3.yAxis*.4),volume,overlap)>0 then continue end
  local delta=goal-root.Position
  if direct and delta.Magnitude>.1 and workspace:Blockcast(CFrame.new(root.Position+Vector3.yAxis*.4),volume,delta,ray) then continue end
  return goal
 end
end
return Ground
