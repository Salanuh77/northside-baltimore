local Style={}
Style.Heights={'Short','Medium','Tall'}
Style.Builds={'Slender','Average','Broad'}
Style.Hair={'Close crop','Curls','High puff','Twists','Shaved'}
Style.Tones={'Espresso','Umber','Copper','Amber','Olive','Sand','Porcelain'}
Style.Skin={Color3.fromRGB(78,48,39),Color3.fromRGB(106,66,49),Color3.fromRGB(148,90,62),Color3.fromRGB(185,125,86),Color3.fromRGB(189,146,108),Color3.fromRGB(218,178,141),Color3.fromRGB(239,207,181)}
Style.Outfits={{Id='fleet-track',Name='Fleet track jacket',Price=65},{Id='pier-varsity',Name='Pier varsity jacket',Price=95},{Id='foundry-work',Name='Foundry overshirt',Price=55}}
Style.Starters={'Harbor','Clay','Olive'}
Style.Details={'Clean','Freckles','Goatee'}
local shirts={Harbor=Color3.fromRGB(53,98,113),Clay=Color3.fromRGB(151,78,62),Olive=Color3.fromRGB(98,108,72)}
function Style.valid(data)
 if type(data)~='table' or (data.Starter~=nil and not table.find(Style.Starters,data.Starter)) or (data.Detail~=nil and not table.find(Style.Details,data.Detail)) then return false end
 for key,list in {Height=Style.Heights,Build=Style.Builds,Hair=Style.Hair,Tone=Style.Tones} do
  if not table.find(list,data[key]) then return false end
 end
 return true
end
local function hair(head,style)
 local old=head:FindFirstChild('Northside hair'); if old then old:Destroy() end
 if style=='Shaved' then return end
 local folder=Instance.new('Folder'); folder.Name='Northside hair'; folder.Parent=head
 local scale=head.Size.Y
 local function lock(x,y,z,sx,sy,sz,shade)
  local p=Instance.new('Part'); p.Name='Lock'; p.Shape=Enum.PartType.Ball
  p.Color=Color3.fromRGB(shade+12,shade+5,shade+1); p.Material=Enum.Material.Fabric
  p.CanCollide=false; p.CanQuery=false; p.CanTouch=false; p.Massless=true
  p.Size=Vector3.new(sx,sy,sz)*scale; p.CFrame=head.CFrame*CFrame.new(Vector3.new(x,y,z)*scale); p.Parent=folder
  local weld=Instance.new('WeldConstraint'); weld.Part0=head; weld.Part1=p; weld.Parent=p
 end
 lock(0,.33,.02,1.12,.47,1.04,21)
 if style=='Close crop' then return end
 if style=='High puff' then lock(0,.76,.16,.92,.82,.87,24) end
 local count=style=='Twists' and 14 or 12
 for i=1,count do
  local a=i*2*math.pi/count; local long=style=='Twists'; local puff=style=='High puff'
  lock(.46*math.sin(a),puff and .5 or long and .21 or .42,.42*math.cos(a),long and .18 or .33,long and (.64+.15*(i%3)) or .33,long and .18 or .33,16+i%4*3)
 end
end
function Style.apply(c,look,outfit)
 local h=c and c:FindFirstChildOfClass('Humanoid'); local head=c and c:FindFirstChild('Head')
 if not h or not head or not look or not Style.valid(look) then return end
 local height=({.92,1,1.08})[table.find(Style.Heights,look.Height)]
 local width=({.85,1,1.15})[table.find(Style.Builds,look.Build)]
 if h.RigType==Enum.HumanoidRigType.R15 then
  for name,value in {BodyHeightScale=height,BodyWidthScale=width,BodyDepthScale=width} do
   local scale=h:FindFirstChild(name); if scale then scale.Value=value end
  end
 else
  c:ScaleTo(height)
  for _,name in {'Torso','Left Arm','Right Arm','Left Leg','Right Leg'} do
   local limb=c:FindFirstChild(name)
   if limb then local original=limb:GetAttribute('UnscaledWidth') or limb.Size.X/height; limb:SetAttribute('UnscaledWidth',original); limb.Size=Vector3.new(original*height*width,limb.Size.Y,limb.Size.Z) end
  end
 end
 local tone=Style.Skin[table.find(Style.Tones,look.Tone)]
 local colors=c:FindFirstChildOfClass('BodyColors') or Instance.new('BodyColors')
 for _,name in {'Head','Torso','LeftArm','RightArm','LeftLeg','RightLeg'} do colors[name..'Color3']=tone end
 if not outfit then
  colors.TorsoColor3=shirts[look.Starter or 'Harbor'] or shirts.Harbor
  colors.LeftLegColor3=Color3.fromRGB(45,52,65);colors.RightLegColor3=colors.LeftLegColor3
 end
 colors.Parent=c
 for _,v in c:GetChildren() do
  local limb=({Head='Head',Torso='Torso',['Left Arm']='LeftArm',['Right Arm']='RightArm',['Left Leg']='LeftLeg',['Right Leg']='RightLeg'})[v.Name]
  if limb and v:IsA('BasePart') then v.Color=colors[limb..'Color3'] end
 end
 local old=head:FindFirstChild('Face detail');if old then old:Destroy() end
 if look.Detail=='Freckles' or look.Detail=='Goatee' then
  local holder=Instance.new('Folder');holder.Name='Face detail';holder.Parent=head
  local function mark(x,y,width,height)
   local part=Instance.new('Part');part.Name='Mark';part.Shape=Enum.PartType.Ball
   part.Size=Vector3.new(width,height,.12)*head.Size.Y
   part.CanCollide=false;part.CanQuery=false;part.CanTouch=false;part.Massless=true;part.Color=tone:Lerp(Color3.new(),.6)
   part.CFrame=head.CFrame*CFrame.new(x*head.Size.Y,y*head.Size.Y,-head.Size.Z*.49);part.Parent=holder
   local weld=Instance.new('WeldConstraint');weld.Part0=head;weld.Part1=part;weld.Parent=part
  end
  if look.Detail=='Goatee' then mark(0,-.33,.32,.18)
  else for _,side in {-1,1} do for i=1,3 do mark(side*(.17+i*.052),-.09+(i%2)*.04,.03,.03) end end end
 end
 for _,v in c:GetChildren() do
  if v:IsA('Accessory') and (v.AccessoryType==Enum.AccessoryType.Hair or outfit and table.find({'Shirt','Jacket','Sweater','Pants','Shorts','TShirt'},v.AccessoryType.Name)) then v:Destroy() end
 end
 hair(head,look.Hair); h.DisplayName=look.Name
 if outfit and script:GetAttribute(outfit) then
  local shirt=c:FindFirstChildOfClass('Shirt') or Instance.new('Shirt'); shirt.ShirtTemplate='rbxassetid://'..script:GetAttribute(outfit); shirt.Parent=c
  local pants=c:FindFirstChildOfClass('Pants') or Instance.new('Pants'); pants.PantsTemplate='rbxassetid://'..script:GetAttribute('indigo-denim'); pants.Parent=c
  local tee=c:FindFirstChildOfClass('ShirtGraphic'); if tee then tee:Destroy() end
 end
end
return Style
