local rb,fs=require('@lune/roblox'),require('@lune/fs')
local V,CF=rb.Vector3.new,rb.CFrame
return function(parent)
 local library=rb.Instance.new('Folder');library.Name='WeaponMeshes';library.Parent=parent
 for _,key in {'sidearm','smg','shotgun','carbine','scope','suppressor'} do
  local roots=rb.deserializeModel(fs.readFile('art/weapon-'..key..'.rbxm'))
  local model=rb.Instance.new('Model');model.Name=key;model:SetAttribute('MeshyAsset',true);model.Parent=library
  local rotation=CF.Angles(0,math.rad((key=='scope' or key=='suppressor') and 90 or -90),0)
  local low,high=V(math.huge,math.huge,math.huge),V(-math.huge,-math.huge,-math.huge)
  local parts={}
  for _,root in roots do
   local list=root:GetDescendants();table.insert(list,root)
   for _,part in list do if part:IsA('MeshPart') then
    part.CFrame=rotation*part.CFrame
    for _,x in {-1,1} do for _,y in {-1,1} do for _,z in {-1,1} do
     local corner=part.CFrame:PointToWorldSpace(part.Size*V(x,y,z)/2);low=low:Min(corner);high=high:Max(corner)
    end end end
    table.insert(parts,part)
   end end
  end
  assert(#parts>0,'Missing weapon geometry: '..key)
  local center=(low+high)/2;local scale=1/(high-low).Z
  for _,part in parts do
   for _,child in part:GetDescendants() do if child:IsA('LuaSourceContainer') then child:Destroy() end end
   part.Size*=scale;part.CFrame=CF.new((part.CFrame.Position-center)*scale)*part.CFrame.Rotation
   part.Anchored=true;part.CanCollide=false;part.CanTouch=false;part.CanQuery=false;part.Massless=true;part.Parent=model
  end
  model.WorldPivot=CF.identity
  model:SetAttribute('NormalizedSize',(high-low)*scale)
 end
 return library
end
