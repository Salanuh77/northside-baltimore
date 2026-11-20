local Portrait=require(game.ReplicatedStorage:WaitForChild('ResidentPortrait'))
local Style={}
Style.FaceShapes=Portrait.Shapes
Style.FaceWidths=Portrait.Widths
Style.EyeSpacings=Portrait.Spacings
Style.LipFullness=Portrait.Lips
Style.Heights={'Short','Medium','Tall'}
Style.Builds={'Slender','Average','Broad'}
Style.Depths={'Narrow','Standard','Full'}
Style.FirstNames={'Avery','Andre','Brianna','Cameron','Darius','Devin','Elise','Imani','Jordan','Leah','Malik','Maya','Nia','Quinn','River','Simone'}
Style.LastNames={'Bell','Brooks','Campbell','Carter','Ellis','Ford','Grant','Hayes','James','Lewis','Miles','Morgan','Reed','Shaw','Taylor','Walker'}
Style.HairDetails={'Natural','Sideburns','Baby hairs'}
Style.Pants={'Dark denim','Washed denim','Canvas'}
Style.Shoes={'Bone low-tops','Black low-tops'}
Style.Mouths={'Level','Smile','Set'}
local pantsKeys={'street-denim','washed-denim','canvas-trousers'}
Style.Hair={'Close crop','Curls','High puff','Twists','Shaved','Cornrows','Twin buns','Short locs','Afro','Braids','Ponytail','Side part','Low puff','Twist out','Barrel twists','Bantu knots','Cropped fringe'}
Style.Tones={'Espresso','Umber','Copper','Amber','Olive','Sand','Porcelain'}
Style.Skin={Color3.fromRGB(78,48,39),Color3.fromRGB(106,66,49),Color3.fromRGB(148,90,62),Color3.fromRGB(185,125,86),Color3.fromRGB(189,146,108),Color3.fromRGB(218,178,141),Color3.fromRGB(239,207,181)}
Style.Outfits={{Id='fleet-track',Name='Fleet track jacket',Price=65},{Id='pier-varsity',Name='Burgundy varsity jacket',Price=95},{Id='foundry-work',Name='Foundry overshirt',Price=55},{Id='haste-markdown',Name='Haste & Markdown racing shell',Price=42},{Id='forever-tuesday',Name='Forever Tuesday varsity',Price=58},{Id='last-season',Name='Last Season plaid chore jacket',Price=36}}
Style.Starters={'Ash pullover','Dock denim','Field liner','Harbor','Clay','Olive','Track jacket','Varsity','Overshirt'}
Style.Sets={
 {Name='Ash hoodie & maroon tie',Starter='Ash pullover',Pants='Dark denim',Shoes='Bone low-tops'},
 {Name='Patched dock denim',Starter='Dock denim',Pants='Washed denim',Shoes='Black low-tops'},
 {Name='Surplus field layers',Starter='Field liner',Pants='Canvas',Shoes='Black low-tops'},
}
local starterShirts={['Ash pullover']='ash-pullover',['Dock denim']='dock-denim',['Field liner']='field-liner',Harbor='harbor-warmup',Clay='clay-workshirt',Olive='olive-overshirt',['Track jacket']='fleet-track',Varsity='pier-varsity',Overshirt='foundry-work'}
Style.HairColors={'Black','Espresso','Chestnut','Auburn','Copper','Honey','Blond','Silver','Burgundy','Midnight blue','Violet','Rose'}
local dyes={Black=Color3.fromRGB(44,37,34),Espresso=Color3.fromRGB(63,44,38),Copper=Color3.fromRGB(167,88,53),Blond=Color3.fromRGB(212,183,135),Burgundy=Color3.fromRGB(105,42,59),['Midnight blue']=Color3.fromRGB(49,66,98),Violet=Color3.fromRGB(97,69,125),Rose=Color3.fromRGB(180,104,118),Chestnut=Color3.fromRGB(84,53,35),Auburn=Color3.fromRGB(126,60,39),Honey=Color3.fromRGB(173,126,68),Silver=Color3.fromRGB(160,158,151)}
Style.Dyes=dyes
Style.Expressions={'Calm','Smile','Focused'}
Style.Eyes={'Brown','Hazel','Blue','Gray'}
local iris={Brown=Color3.fromRGB(69,43,30),Hazel=Color3.fromRGB(108,102,60),Blue=Color3.fromRGB(83,114,128),Gray=Color3.fromRGB(105,112,112)}
Style.Details={'Clean','Freckles','Goatee','Mustache','Stubble'}
function Style.restore(data)
 return require(game.ReplicatedStorage.ResidentAppearance).restore(data,{
  Height=Style.Heights,Build=Style.Builds,Depth=Style.Depths,Hair=Style.Hair,Tone=Style.Tones,
  Starter=Style.Starters,Detail=Style.Details,FaceShape=Style.FaceShapes,FaceWidth=Style.FaceWidths,
  EyeSpacing=Style.EyeSpacings,LipFullness=Style.LipFullness,HairColor=Style.HairColors,
  Eye=Style.Eyes,Expression=Style.Expressions,Mouth=Style.Mouths,Pants=Style.Pants,Shoes=Style.Shoes,HairDetail=Style.HairDetails})
end
function Style.valid(data)
 if type(data)~='table' or (data.Starter~=nil and not table.find(Style.Starters,data.Starter)) or (data.Detail~=nil and not table.find(Style.Details,data.Detail)) then return false end
 for key,list in {FaceShape=Style.FaceShapes,FaceWidth=Style.FaceWidths,EyeSpacing=Style.EyeSpacings,LipFullness=Style.LipFullness,HairColor=Style.HairColors,Eye=Style.Eyes,Expression=Style.Expressions,Mouth=Style.Mouths,Pants=Style.Pants,Shoes=Style.Shoes,Depth=Style.Depths,HairDetail=Style.HairDetails} do if data[key]~=nil and not table.find(list,data[key]) then return false end end
 for key,list in {Height=Style.Heights,Build=Style.Builds,Hair=Style.Hair,Tone=Style.Tones} do
  if not table.find(list,data[key]) then return false end
 end
 return true
end
local function hair(head,style,dye,detail,scale)
 local old=head:FindFirstChild('Northside hair'); if old then old:Destroy() end
 if style=='Shaved' then return end
 local folder=Instance.new('Folder'); folder.Name='Northside hair'; folder.Parent=head
 local function lock(x,y,z,sx,sy,sz,shade)
  local p=Instance.new('Part'); p.Name='Lock'; p.Shape=Enum.PartType.Ball
  p.Color=dye:Lerp(Color3.new(1,1,1),math.max(0,shade-15)/180); p.Material=Enum.Material.Fabric
  p.CanCollide=false; p.CanQuery=false; p.CanTouch=false; p.Massless=true
  p.Size=Vector3.new(sx,sy,sz)*scale; p.CFrame=head.CFrame*CFrame.new(Vector3.new(x,y,z)*scale); p.Parent=folder
  local weld=Instance.new('WeldConstraint'); weld.Part0=head; weld.Part1=p; weld.Parent=p
 end
 local groom=game.ReplicatedStorage.ResidentGrooms:FindFirstChild(style,true)
 local source=groom or game.ReplicatedStorage.ResidentHair:FindFirstChild(style)
 if source then
  local handle=source:Clone();handle.Name='Hair mesh';handle.Anchored=false
  handle.CanCollide=false;handle.CanTouch=false;handle.CanQuery=false;handle.Massless=true
  local cage=handle:FindFirstChildOfClass('WrapLayer');if cage then cage:Destroy() end
  local offset
  if groom then
   handle.Size=source.Size*scale;offset=source:GetAttribute('GroomCenter')
   handle.Color=dye;handle.Material=Enum.Material.SmoothPlastic
   local surface=handle:FindFirstChildOfClass('SurfaceAppearance')
   if surface then surface.Color=dye end
  else
   local proportions={
    ['Close crop']=Vector3.new(1.08,.76,1.10),Curls=Vector3.new(1.12,.88,1.13),
    Afro=Vector3.new(1.38,1.12,1.38),Braids=Vector3.new(1.13,1.45,1.21),
    ['Side part']=Vector3.new(1.09,.88,1.15),Ponytail=Vector3.new(1.16,1.49,1.53)
   }
   handle.Size=scale*proportions[style]
   local surface=handle:FindFirstChildOfClass('SurfaceAppearance')
   if surface then
    surface.Color=dye;handle.Color=dye
   elseif dye~=dyes.Black then
    handle.TextureID='';handle.Color=dye
   end
   offset=style=='Ponytail' and Vector3.new(0,.18,.23) or style=='Braids' and Vector3.new(0,.16,.11) or Vector3.new(0,.34,.04)
  end
  local rotation=groom and CFrame.Angles(0,math.pi,0) or CFrame.identity
  handle.CFrame=head.CFrame*CFrame.new(offset*scale)*rotation;handle.Parent=folder
  local weld=Instance.new('WeldConstraint');weld.Part0=head;weld.Part1=handle;weld.Parent=handle
 end
 if detail=='Sideburns' then
  for _,side in {-1,1} do lock(.45*side,.045,-.18,.065,.29,.09,18) end
 elseif detail=='Baby hairs' then
  for _,side in {-1,1} do
   for i=1,3 do lock(side*(.28+i*.035),.29-i*.02,-.42+i*.022,.08,.037,.05,17) end
  end
 end
end
function Style.apply(c,look,outfit)
 local h=c and c:FindFirstChildOfClass('Humanoid'); local head=c and c:FindFirstChild('Head')
 if not h or not head or not look or not Style.valid(look) then return end
 local height=({.92,1,1.08})[table.find(Style.Heights,look.Height)]
 local width=({.85,1,1.15})[table.find(Style.Builds,look.Build)]
 local depth=({.92,1,1.10})[table.find(Style.Depths,look.Depth or 'Standard')]
 if c:GetAttribute('ResidentHeight')~=height or c:GetAttribute('ResidentWidth')~=width or c:GetAttribute('ResidentDepth')~=depth then
  c:ScaleTo(height)
  local previous=c:GetAttribute('ResidentWidth') or 1
  local factor=width/previous
  local depthFactor=depth/(c:GetAttribute('ResidentDepth') or 1)
  local function lateral(cf)
   local pos=cf.Position
   return CFrame.new(pos.X*factor,pos.Y,pos.Z*depthFactor)*cf.Rotation
  end
  for _,part in c:GetChildren() do
   if part:IsA('BasePart') then
    part.Size=Vector3.new(part.Size.X*factor,part.Size.Y,part.Size.Z*depthFactor)
    for _,joint in part:GetChildren() do
     if joint:IsA('Motor6D') and joint.Part0 and joint.Part1 and joint.Part1.Parent==c then
      joint.C0=lateral(joint.C0);joint.C1=lateral(joint.C1)
     elseif joint:IsA('Attachment') then joint.CFrame=lateral(joint.CFrame) end
    end
   end
  end
  c:SetAttribute('ResidentHeight',height);c:SetAttribute('ResidentWidth',width)
  c:SetAttribute('ResidentDepth',depth)
 end
 outfit=outfit or starterShirts[look.Starter or 'Harbor'] or starterShirts.Harbor
 local tone=Style.Skin[table.find(Style.Tones,look.Tone)]
 local colors=c:FindFirstChildOfClass('BodyColors') or Instance.new('BodyColors')
 for _,name in {'Head','Torso','LeftArm','RightArm','LeftLeg','RightLeg'} do colors[name..'Color3']=tone end
 local cloth=({['Dark denim']=Color3.fromRGB(38,46,57),['Washed denim']=Color3.fromRGB(86,102,118),Canvas=Color3.fromRGB(125,111,86)})[look.Pants or 'Dark denim']
 colors.LeftLegColor3=cloth; colors.RightLegColor3=cloth
 colors.Parent=c
 for _,v in c:GetChildren() do
  if v:IsA('BasePart') and v.Name~='HumanoidRootPart' then
   local covered=v.Name=='LowerTorso' or v.Name:find('Leg') or v.Name:find('Foot')
   v.Color=covered and cloth or tone
  end
 end
 local dye=dyes[look.HairColor or 'Black']
 local headScale=Portrait.draw(head,look,script,tone,dye,iris[look.Eye or 'Brown'])
 local scalpWidth=game.ReplicatedStorage.ResidentProfiles:FindFirstChild(look.FaceShape or 'Oval',true).Size.X
 for _,v in c:GetChildren() do
  if v:IsA('Accessory') and (v.AccessoryType==Enum.AccessoryType.Hair or outfit and table.find({'Shirt','Jacket','Sweater','Pants','Shorts','TShirt'},v.AccessoryType.Name)) then v:Destroy() end
 end
 hair(head,look.Hair,dye,look.HairDetail,headScale*Vector3.new(scalpWidth/.96,1,1)); h.DisplayName=look.Name
 if outfit and script:GetAttribute(outfit) then
  local shirt=c:FindFirstChildOfClass('Shirt') or Instance.new('Shirt'); shirt.ShirtTemplate='rbxassetid://'..script:GetAttribute(outfit); shirt.Parent=c
  local key=pantsKeys[table.find(Style.Pants,look.Pants or 'Dark denim')]..(look.Shoes=='Black low-tops' and '-black' or '')
  local pants=c:FindFirstChildOfClass('Pants') or Instance.new('Pants'); pants.PantsTemplate='rbxassetid://'..script:GetAttribute(key); pants.Parent=c
  local tee=c:FindFirstChildOfClass('ShirtGraphic'); if tee then tee:Destroy() end
 end
end
return Style
