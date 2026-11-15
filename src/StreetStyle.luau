local Style={}
Style.Heights={'Short','Medium','Tall'}
Style.Builds={'Slender','Average','Broad'}
Style.Hair={'Close crop','Curls','High puff','Twists','Shaved','Cornrows','Twin buns','Short locs','Afro','Braids','Ponytail','Side part'}
Style.Tones={'Espresso','Umber','Copper','Amber','Olive','Sand','Porcelain'}
Style.Skin={Color3.fromRGB(78,48,39),Color3.fromRGB(106,66,49),Color3.fromRGB(148,90,62),Color3.fromRGB(185,125,86),Color3.fromRGB(189,146,108),Color3.fromRGB(218,178,141),Color3.fromRGB(239,207,181)}
Style.Outfits={{Id='fleet-track',Name='Fleet track jacket',Price=65},{Id='pier-varsity',Name='Pier varsity jacket',Price=95},{Id='foundry-work',Name='Foundry overshirt',Price=55}}
Style.Starters={'Harbor','Clay','Olive','Track jacket','Varsity','Overshirt'}
local starterShirts={Harbor='harbor-warmup',Clay='clay-workshirt',Olive='olive-overshirt',['Track jacket']='fleet-track',Varsity='pier-varsity',Overshirt='foundry-work'}
Style.HairColors={'Black','Chestnut','Auburn','Honey','Silver'}
local dyes={Black=Color3.fromRGB(31,25,23),Chestnut=Color3.fromRGB(84,53,35),Auburn=Color3.fromRGB(126,60,39),Honey=Color3.fromRGB(173,126,68),Silver=Color3.fromRGB(160,158,151)}
Style.Expressions={'Calm','Smile','Focused'}
Style.Eyes={'Brown','Hazel','Blue','Gray'}
local iris={Brown=Color3.fromRGB(69,43,30),Hazel=Color3.fromRGB(108,102,60),Blue=Color3.fromRGB(83,114,128),Gray=Color3.fromRGB(105,112,112)}
Style.Details={'Clean','Freckles','Goatee','Mustache','Stubble'}
function Style.valid(data)
 if type(data)~='table' or (data.Starter~=nil and not table.find(Style.Starters,data.Starter)) or (data.Detail~=nil and not table.find(Style.Details,data.Detail)) then return false end
 for key,list in {HairColor=Style.HairColors,Eye=Style.Eyes,Expression=Style.Expressions} do if data[key]~=nil and not table.find(list,data[key]) then return false end end
 for key,list in {Height=Style.Heights,Build=Style.Builds,Hair=Style.Hair,Tone=Style.Tones} do
  if not table.find(list,data[key]) then return false end
 end
 return true
end
local function hair(head,style,dye)
 local old=head:FindFirstChild('Northside hair'); if old then old:Destroy() end
 if style=='Shaved' then return end
 local folder=Instance.new('Folder'); folder.Name='Northside hair'; folder.Parent=head
 local scale=head.Size
 local function lock(x,y,z,sx,sy,sz,shade)
  local p=Instance.new('Part'); p.Name='Lock'; p.Shape=Enum.PartType.Ball
  p.Color=dye:Lerp(Color3.new(1,1,1),math.max(0,shade-15)/180); p.Material=Enum.Material.Fabric
  p.CanCollide=false; p.CanQuery=false; p.CanTouch=false; p.Massless=true
  p.Size=Vector3.new(sx,sy,sz)*scale; p.CFrame=head.CFrame*CFrame.new(Vector3.new(x,y,z)*scale); p.Parent=folder
  local weld=Instance.new('WeldConstraint'); weld.Part0=head; weld.Part1=p; weld.Parent=p
 end
 local foundation=({Twists='Curls',['Short locs']='Braids',Cornrows='Braids',['Twin buns']='Close crop',['High puff']='Close crop'})[style] or style
 local source=game.ReplicatedStorage:WaitForChild('ResidentHair'):FindFirstChild(foundation)
 if source then
  local handle=source:Clone();handle.Name='Hair mesh';handle.Anchored=false;handle.CanCollide=false;handle.CanTouch=false;handle.CanQuery=false;handle.Massless=true
  local shape=handle:FindFirstChildOfClass('SpecialMesh')
  local fitting=handle:FindFirstChild('HairAttachment') or handle:FindFirstChild('HatAttachment')
  local mount=head:FindFirstChild(fitting.Name)
  local h=head.Parent:GetScale()
  if shape then shape.Scale*=h else handle.Size*=h end
  if dye~=dyes.Black then
   if shape then shape.TextureId='';shape.VertexColor=Vector3.new(dye.R,dye.G,dye.B)
   elseif handle:IsA('MeshPart') then handle.TextureID='' end
   handle.Color=dye
  end
  local localMount=CFrame.new(fitting.Position*h)*fitting.CFrame.Rotation
  handle.CFrame=head.CFrame*mount.CFrame*localMount:Inverse();handle.Parent=folder
  local w=Instance.new('WeldConstraint');w.Part0=head;w.Part1=handle;w.Parent=handle
 end
 if style=='High puff' then lock(0,.65,.11,.76,.65,.76,21)
 elseif style=='Twin buns' then for _,side in {-1,1} do lock(side*.35,.55,.18,.44,.47,.46,21) end
 elseif style=='Twists' or style=='Short locs' then
  -- Keep the forehead open; shortened strands follow the sideburns and nape.
  for i=0,12 do
   local a=(i/12-.5)*math.pi*1.12
   local length=(style=='Twists' and .27 or .40)+.06*(i%3)
   lock(.43*math.sin(a),.21-length*.28,.41*math.cos(a),.105,length,.12,18+i%3)
  end
 end
end
function Style.apply(c,look,outfit)
 local h=c and c:FindFirstChildOfClass('Humanoid'); local head=c and c:FindFirstChild('Head')
 if not h or not head or not look or not Style.valid(look) then return end
 local height=({.92,1,1.08})[table.find(Style.Heights,look.Height)]
 local width=({.85,1,1.15})[table.find(Style.Builds,look.Build)]
 if c:GetAttribute('ResidentHeight')~=height or c:GetAttribute('ResidentWidth')~=width then
  c:ScaleTo(height)
  local previous=c:GetAttribute('ResidentWidth') or 1
  local factor=width/previous
  local function lateral(cf)
   local pos=cf.Position
   return CFrame.new(pos.X*factor,pos.Y,pos.Z)*cf.Rotation
  end
  for _,part in c:GetChildren() do
   if part:IsA('BasePart') then
    part.Size=Vector3.new(part.Size.X*factor,part.Size.Y,part.Size.Z)
    for _,joint in part:GetChildren() do
     if joint:IsA('Motor6D') and joint.Part0 and joint.Part1 and joint.Part1.Parent==c then
      joint.C0=lateral(joint.C0);joint.C1=lateral(joint.C1)
     elseif joint:IsA('Attachment') then joint.CFrame=lateral(joint.CFrame) end
    end
   end
  end
  c:SetAttribute('ResidentHeight',height);c:SetAttribute('ResidentWidth',width)
 end
 outfit=outfit or starterShirts[look.Starter or 'Harbor'] or starterShirts.Harbor
 local tone=Style.Skin[table.find(Style.Tones,look.Tone)]
 local colors=c:FindFirstChildOfClass('BodyColors') or Instance.new('BodyColors')
 for _,name in {'Head','Torso','LeftArm','RightArm','LeftLeg','RightLeg'} do colors[name..'Color3']=tone end
 colors.Parent=c
 for _,v in c:GetChildren() do
  if v:IsA('BasePart') and v.Name~='HumanoidRootPart' then v.Color=tone end
 end
 local old=head:FindFirstChild('Face detail');if old then old:Destroy() end
 local holder=Instance.new('Folder');holder.Name='Face detail';holder.Parent=head
 local dye=dyes[look.HairColor or 'Black']
 local function mark(name,x,y,z,w,h,d,color)
  local part=Instance.new('Part');part.Name=name;part.Shape=Enum.PartType.Ball
  part.Size=Vector3.new(w,h,d)*head.Size;part.Color=color
  part.CanCollide=false;part.CanQuery=false;part.CanTouch=false;part.Massless=true
  part.CFrame=head.CFrame*CFrame.new(Vector3.new(x,y,z)*head.Size);part.Parent=holder
  local weld=Instance.new('WeldConstraint');weld.Part0=head;weld.Part1=part;weld.Parent=part
 end
 local face=head:FindFirstChild('Resident face') or Instance.new('Decal')
 face.Name='Resident face';face.Face=Enum.NormalId.Front;face.Texture='rbxassetid://'..script:GetAttribute('resident-'..string.lower(look.Expression or 'Calm'))
 face.Color3=iris[look.Eye or 'Brown']:Lerp(Color3.new(1,1,1),.72);face.Parent=head
 for _,side in {-1,1} do
  if look.Detail=='Freckles' then
   for i=1,3 do mark('Freckle',side*(.16+i*.045),-.044+(i%2)*.027,-.438,.025,.022,.03,tone:Lerp(dye,.5)) end
  end
 end
 if look.Detail=='Goatee' then mark('Beard',0,-.29,-.405,.34,.16,.10,dye)
 elseif look.Detail=='Mustache' then mark('Mustache',0,-.155,-.475,.38,.052,.08,dye)
 elseif look.Detail=='Stubble' then
  for i=-3,3 do mark('Stubble',i*.095,-.29+.012*i*i,-.411+.004*i*i,.09,.07,.055,tone:Lerp(dye,.62)) end
 end
 for _,v in c:GetChildren() do
  if v:IsA('Accessory') and (v.AccessoryType==Enum.AccessoryType.Hair or outfit and table.find({'Shirt','Jacket','Sweater','Pants','Shorts','TShirt'},v.AccessoryType.Name)) then v:Destroy() end
 end
 hair(head,look.Hair,dye); h.DisplayName=look.Name
 if outfit and script:GetAttribute(outfit) then
  local shirt=c:FindFirstChildOfClass('Shirt') or Instance.new('Shirt'); shirt.ShirtTemplate='rbxassetid://'..script:GetAttribute(outfit); shirt.Parent=c
  local pants=c:FindFirstChildOfClass('Pants') or Instance.new('Pants'); pants.PantsTemplate='rbxassetid://'..script:GetAttribute('street-denim'); pants.Parent=c
  local tee=c:FindFirstChildOfClass('ShirtGraphic'); if tee then tee:Destroy() end
 end
end
return Style
