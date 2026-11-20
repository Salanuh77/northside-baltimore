return function(t,finish)
 local handle=t.Handle
  local long=finish=='Field carbine'
  local steel=finish=='Silver service' and Color3.fromRGB(157,162,161) or Color3.fromRGB(72,78,82)
  local charcoal=Color3.fromRGB(43,46,47)
  local trim=long and Color3.fromRGB(146,129,98) or charcoal
  handle.Size=Vector3.new(.27,.64,.36);handle.Transparency=1;handle.CanTouch=false;handle.CanQuery=false
  t.Grip=CFrame.new(0,-.12,0)
  t:SetAttribute('Finish',finish)
  local function shell(label,size,pose,color,wedge)
   local part=Instance.new(wedge and 'WedgePart' or 'Part');part.Name=label;part.Size=size;part.Color=color
   part.Material=Enum.Material.SmoothPlastic;part.CanCollide=false;part.CanTouch=false;part.CanQuery=false;part.Massless=true
   part.CFrame=handle.CFrame*pose;part.Parent=t
   local join=Instance.new('WeldConstraint');join.Part0=handle;join.Part1=part;join.Parent=part
  end
  shell('Palm',Vector3.new(.28,.66,.36),CFrame.new(0,0,.03)*CFrame.Angles(-.20,0,0),charcoal)
  shell('Lower silhouette',Vector3.new(.31,.20,long and 1.68 or 1.05),CFrame.new(0,.28,-.32),trim)
  shell('Upper silhouette',Vector3.new(.31,.22,long and 1.9 or 1.12),CFrame.new(0,.45,-.3),steel)
  shell('Sloped back',Vector3.new(.30,.16,.18),CFrame.new(0,.42,.31),steel,true)
  shell('Guard base',Vector3.new(.13,.08,.43),CFrame.new(0,-.004,-.30),charcoal)
  shell('Guard edge',Vector3.new(.13,.29,.08),CFrame.new(0,.13,-.49)*CFrame.Angles(.16,0,0),charcoal)
  for _,side in {-1,1} do
   shell('Inset grip panel',Vector3.new(.032,.44,.235),CFrame.new(side*.147,-.02,.04)*CFrame.Angles(-.20,0,0),trim)
   shell('Slide highlight',Vector3.new(.02,.036,long and 1.58 or .88),CFrame.new(side*.155,.50,-.32),steel:Lerp(Color3.new(1,1,1),.18))
  end
  if long then
   shell('Stock silhouette',Vector3.new(.30,.45,.92),CFrame.new(0,.27,.86),trim)
   shell('Fore-end',Vector3.new(.32,.27,.95),CFrame.new(0,.30,-1.05),trim)
   shell('Front silhouette',Vector3.new(.15,.16,.58),CFrame.new(0,.45,-1.65),charcoal)
  end
end
