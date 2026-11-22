-- Imported visuals keep their PBR materials. Simple independent hulls own collisions.
local rb,fs=require('@lune/roblox'),require('@lune/fs')
local CF,V=rb.CFrame,rb.Vector3.new
local cache={}
local Props={}
local function template(key)
 if cache[key] then return cache[key] end
 local roots=rb.deserializeModel(fs.readFile(key=='waiting-sofa' and 'art/home-sofa.rbxm' or 'art/interior-'..key..'.rbxm'))
 local parts={};local low,high=V(math.huge,math.huge,math.huge),V(-math.huge,-math.huge,-math.huge)
 for _,root in roots do
  local descendants=root:GetDescendants();table.insert(descendants,root)
  for _,p in descendants do
   if p:IsA('MeshPart') then
    table.insert(parts,p)
    for _,x in {-1,1} do for _,y in {-1,1} do for _,z in {-1,1} do
     local corner=p.CFrame:PointToWorldSpace(p.Size*V(x,y,z)/2)
     low=low:Min(corner);high=high:Max(corner)
    end end end
   end
  end
 end
 assert(#parts>0,'Missing Meshy visual '..key)
 cache[key]={parts=parts,size=high-low,origin=V((low.X+high.X)/2,low.Y,(low.Z+high.Z)/2)}
 return cache[key]
end
function Props.size(key) return template(key).size end
function Props.add(parent,key,name,frame,limits,collision)
 local source=template(key);local s=source.size
 local scale=math.min(limits.X/s.X,limits.Y/s.Y,limits.Z/s.Z)
 local model=rb.Instance.new('Model');model.Name=name;model:SetAttribute('MeshyPropKey',key)
 model:SetAttribute('FurnitureFrame',frame);model:SetAttribute('FurnitureSize',s*scale);model.Parent=parent
 for _,original in source.parts do
  local mesh=original:Clone()
  for _,child in mesh:GetDescendants() do if child:IsA('LuaSourceContainer') then child:Destroy() end end
  mesh.Size=original.Size*scale;mesh.CFrame=frame*CF.new((original.CFrame.Position-source.origin)*scale)*original.CFrame.Rotation
  mesh.Anchored=true;mesh.CanCollide=false;mesh.CanTouch=false;mesh.CanQuery=false;mesh.CastShadow=true
  mesh.Parent=model
 end
 if collision then Props.hull(model,frame,s*scale) end
 return model,s*scale
end
function Props.hull(parent,frame,size)
 local p=rb.Instance.new('Part');p.Name='Furniture collision';p.Size=size;p.CFrame=frame*CF.new(0,size.Y/2,0)
 p.Transparency=1;p.Anchored=true;p.CanCollide=true;p.CanQuery=true;p.CanTouch=false;p.Parent=parent;return p
end
return Props
