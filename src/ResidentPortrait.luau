local Portrait={}
Portrait.Shapes={'Oval','Square','Round','Heart','Oblong','Diamond'}
Portrait.Widths={'Narrow','Balanced','Wide'}
Portrait.Spacings={'Close','Balanced','Wide'}
Portrait.Lips={'Thin','Medium','Full'}

function Portrait.scale(head,look)
 local width=({Narrow=.91,Balanced=1,Wide=1.09})[look.FaceWidth or 'Balanced']
 return head.Size*Vector3.new(.88*width,1.10,1.04)
end

local function fit(part,head,folder,position,rotation)
 part.Anchored=false;part.CanCollide=false;part.CanQuery=false;part.CanTouch=false;part.Massless=true
 part.CFrame=head.CFrame*CFrame.new(position)*(rotation or CFrame.identity);part.Parent=folder
 local weld=Instance.new('WeldConstraint');weld.Part0=head;weld.Part1=part;weld.Parent=part
 return part
end

function Portrait.draw(head,look,art,tone,dye,iris)
 local previous=head:FindFirstChild('Face detail')
 if previous then previous:Destroy() end
 local folder=Instance.new('Folder');folder.Name='Face detail';folder.Parent=head
 local scale=Portrait.scale(head,look)
 local profile=game.ReplicatedStorage.ResidentProfiles:FindFirstChild(look.FaceShape or 'Oval',true)
 local skin=profile:Clone();skin.Name='Head sculpt';skin.Color=tone;skin.Material=Enum.Material.SmoothPlastic
 skin.Size=profile.Size*scale
 -- The imported sculpt faces local +Z. Roblox residents look along local -Z.
 fit(skin,head,folder,Vector3.new(0,0,-profile.CFrame.Position.Z)*scale,CFrame.Angles(0,math.pi,0))
 head.Transparency=1
 local function feature(name,x,y,z,w,h,d,color)
  local part=Instance.new('Part');part.Name=name;part.Shape=Enum.PartType.Ball;part.Color=color
  part.Size=Vector3.new(w,h,d)*scale;return fit(part,head,folder,Vector3.new(x,y,z)*scale)
 end
 local function plate(name,key,color,kind,variant)
  local source=game.ReplicatedStorage.ResidentFeatures:FindFirstChild((look.FaceShape or 'Oval')..' '..kind..' '..variant,true)
  local surface=source:Clone();surface.Name=name;surface.CastShadow=false
  surface.Size=source.Size*scale;surface.Color=color
  local previousMaterial=surface:FindFirstChildOfClass('SurfaceAppearance');if previousMaterial then previousMaterial:Destroy() end
  surface.TextureID=''
  local material=game.ReplicatedStorage.ResidentFaceMaterials:FindFirstChild(key):Clone()
  material.Color=color;material.Parent=surface
  -- Each overlay follows this specific sculpt, including cheeks and chin in profile.
  fit(surface,head,folder,source:GetAttribute('FeatureCenter')*scale,CFrame.Angles(0,math.pi,0))
 end
 -- Keep brows and lids legible at normal conversation distance, not only in a close-up.
 plate('Resident face','portrait-'..string.lower(look.Expression or 'Calm'),iris:Lerp(Color3.new(1,1,1),.86),'Eyes',look.EyeSpacing or 'Balanced')
 local mouth=look.Mouth or (look.Expression=='Smile' and 'Smile' or 'Level')
 plate('Resident mouth','lips-'..string.lower(mouth),Color3.new(1,1,1),'Mouth',look.LipFullness or 'Medium')
 for _,side in {-1,1} do
  feature('Ear',side*profile.Size.X*.48,-.018,.015,.126,.232,.145,tone)
  if look.Detail=='Freckles' then
   for i=1,3 do feature('Freckle',side*(.12+i*.04),-.045+(i%2)*.025,-.453,.016,.014,.019,tone:Lerp(dye,.53)) end
  end
 end
 if look.Detail=='Goatee' then feature('Beard',0,-.322,-.368,.27,.115,.083,dye)
 elseif look.Detail=='Mustache' then feature('Mustache',0,-.165,-.452,.29,.037,.067,dye)
 elseif look.Detail=='Stubble' then
  for i=-3,3 do feature('Stubble',i*.071,-.32+.006*i*i,-.376+.003*i*i,.062,.045,.045,tone:Lerp(dye,.55)) end
 end
 return scale
end

return Portrait
