local Players=game:GetService('Players')
local storage=game:GetService('ReplicatedStorage')
local input=game:GetService('UserInputService')
local player=Players.LocalPlayer
local style=require(storage:WaitForChild('StreetStyle'))
local template=storage:WaitForChild('ResidentRig')
local event=storage:WaitForChild('CityAction')
local cream=Color3.fromRGB(246,247,248)
local paper=Color3.fromRGB(163,170,180)
local ink=Color3.fromRGB(16,19,25)
local slate=Color3.fromRGB(32,37,46)
local gold=Color3.fromRGB(159,211,190)
local function make(class,props,parent)
 local v=Instance.new(class)
 for k,value in props do v[k]=value end
 v.Parent=parent
 return v
end
local screen=make('ScreenGui',{Name='ResidentStudio',DisplayOrder=24,ResetOnSpawn=false,IgnoreGuiInset=false},player:WaitForChild('PlayerGui'))
local page=make('Frame',{Name='Studio',Size=UDim2.fromScale(1,1),BackgroundColor3=ink,BorderSizePixel=0,Active=true},screen)
local function frame(parent,color)
 return make('Frame',{BorderSizePixel=0,BackgroundColor3=color},parent)
end
local function label(parent,value,size,color)
 return make('TextLabel',{BackgroundTransparency=1,Font=Enum.Font.GothamMedium,Text=value,TextSize=size,TextColor3=color,TextXAlignment=Enum.TextXAlignment.Left,BorderSizePixel=0},parent)
end
local function button(parent,value,callback)
 local b=make('TextButton',{Name=value,Text=value,TextColor3=cream,TextSize=14,Font=Enum.Font.GothamMedium,BackgroundColor3=slate,BorderSizePixel=0},parent)
 b.Activated:Connect(callback)
 b.MouseEnter:Connect(function() b.BackgroundTransparency=.16 end)
 b.MouseLeave:Connect(function() b.BackgroundTransparency=0 end)
 return b
end
local function at(v,x,y,w,h)
 v.Position=UDim2.fromOffset(x,y);v.Size=UDim2.fromOffset(math.max(1,w),math.max(1,h))
end
local set=frame(page,paper);set.Name='Character preview'
set.ClipsDescendants=true
make('UIGradient',{Rotation=90,Color=ColorSequence.new(Color3.fromRGB(100,113,125),Color3.fromRGB(44,51,63))},set)
local viewport=make('ViewportFrame',{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Ambient=Color3.fromRGB(190,193,202),LightColor=Color3.fromRGB(255,243,230),LightDirection=Vector3.new(-.65,-.35,-1)},set)
local world=make('WorldModel',{},viewport)
local camera=make('Camera',{FieldOfView=35},viewport)
viewport.CurrentCamera=camera
local panel=frame(page,ink)
local imprint=label(panel,'BALTIMORE  /  ONLINE',10,gold)
local title=label(panel,'CHOOSE YOUR RESIDENT',24,cream);title.Font=Enum.Font.GothamBold
local function scroller(parent)
 return make('ScrollingFrame',{CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingDirection=Enum.ScrollingDirection.Y,ScrollBarThickness=3,BackgroundTransparency=1,BorderSizePixel=0},parent)
end
local west=frame(page,ink);local east=frame(page,ink)
west.Name='Editor';east.Name='Last name editor'
local pane=scroller(west);local sidePane=scroller(east)
local categoryBar=frame(page,ink);categoryBar.Name='Appearance categories'
local category='Hair'
local caption=label(set,'DRAG TO ROTATE',10,cream)
caption.TextTransparency=.2
local footer=label(panel,'Loading your files…',14,cream);footer.TextWrapped=true
local slot,tab,waiting=nil,'Identity',false
local closeup=false
local mirror=false
local wornOutfit
local close
local room=make('Model',{Name='Fitting room'},world)
local function furnishing(name,size,position,color,material)
 return make('Part',{Name=name,Size=size,CFrame=CFrame.new(position),Anchored=true,Color=Color3.fromRGB(table.unpack(color)),Material=material or Enum.Material.SmoothPlastic},room)
end
furnishing('Studio floor',Vector3.new(28,.4,24),Vector3.new(0,-.22,0),{88,94,104},Enum.Material.Concrete)
furnishing('Backdrop',Vector3.new(28,13,.6),Vector3.new(0,6.4,5),{115,124,133})
for i=-3,3 do furnishing('Wall seam',Vector3.new(.025,13,.03),Vector3.new(i*3,6.4,4.68),{95,104,113}) end
furnishing('Floor trim',Vector3.new(28,.12,.1),Vector3.new(0,.18,4.64),{152,164,173})
local roomOrigin=room:GetPivot()
local rows={}
local function fresh() return {Height='Medium',Build='Average',Tone='Amber',Hair='Close crop',Name='Avery Bell',FirstName='Avery',LastName='Bell',FaceShape='Oval',FaceWidth='Balanced',EyeSpacing='Balanced',LipFullness='Medium',Depth='Standard',Pants='Dark denim',Shoes='Bone low-tops',Mouth='Level',HairDetail='Natural',Starter='Ash pullover',Detail='Clean',HairColor='Black',Eye='Brown',Expression='Calm'} end
local draft=fresh()
local yaw=.22
local rig
local function pose()
 if not rig then return end
 rig:PivotTo(CFrame.Angles(0,yaw,0))
 local bounds,size=rig:GetBoundingBox()
 local center=bounds.Position
 local aspect=viewport.AbsoluteSize.X/math.max(1,viewport.AbsoluteSize.Y)
 room:PivotTo(CFrame.new(0,center.Y-size.Y/2,0)*roomOrigin)
 local distance=math.max(size.Y*1.04,size.X/math.max(.5,aspect))*1.82
 if closeup and slot and tab=='Appearance' then
  center=rig.Head.Position+Vector3.new(0,.20,0);distance=math.max(4.6,2.7/math.max(.5,aspect))
 end
 camera.CFrame=CFrame.lookAt(center+Vector3.new(0,.24,-distance),center)
end
local function rebuild()
 if rig then rig:Destroy() end
 rig=template:Clone();rig.Parent=world;rig.HumanoidRootPart.Anchored=true
 style.apply(rig,draft,wornOutfit);pose()
end
local function turn(delta) yaw+=delta;pose() end
local left=button(set,'Turn left',function() turn(-math.pi/6) end)
local right=button(set,'Turn right',function() turn(math.pi/6) end)
local drag,last
viewport.Active=true
viewport.InputBegan:Connect(function(key)
 if key.UserInputType==Enum.UserInputType.MouseButton1 or key.UserInputType==Enum.UserInputType.Touch then drag=key;last=key.Position.X end
end)
input.InputChanged:Connect(function(key)
 if drag and (key==drag or key.UserInputType==Enum.UserInputType.MouseMovement) then turn((key.Position.X-last)*.015);last=key.Position.X end
end)
input.InputEnded:Connect(function(key) if key==drag then drag=nil end end)
local draw
local function chooseFile(index)
 if waiting then return end
 local record=rows[index]
 if not record then return end
 if record.Name then
  waiting=true;footer.Text='Loading '..record.Name..'…';event:FireServer('SelectFile',{Index=index})
 else
  slot=index;tab='Identity';draft=fresh();yaw=.22;footer.Text='';rebuild();draw()
 end
end
local function send()
 if waiting or not slot then return end
 if mirror then waiting=true;footer.Text='Updating face…';event:FireServer('MirrorLook',draft);return end
 waiting=true;footer.Text='Saving resident…'
 local request=table.clone(draft);request.Index=slot
 event:FireServer('CreateResident',request)
end
local enter=button(panel,'Continue',function()
 if waiting then return end
 if tab=='Identity' then
  for _,value in {draft.FirstName,draft.LastName} do
   local length=utf8.len(value:match('^%s*(.-)%s*$'))
   if not length or length<1 or length>20 then footer.Text='Enter 1 to 20 characters for each name.';return end
  end
  tab='Appearance';category='Hair';closeup=true;draw()
 else send() end
end)
enter.BackgroundColor3=gold;enter.TextColor3=ink
local back=button(panel,'Back',function()
 if waiting then return end
 if mirror then close();return end
 if tab=='Appearance' then tab='Identity' else slot=nil;draft=fresh() end
 closeup=false;footer.Text='';rebuild();draw()
end)
local servers=button(panel,'City servers',function() require(storage.ServerBrowser).open() end)
local zoom=button(set,'Face view',function() closeup=not closeup;pose() end)
zoom.Activated:Connect(function() zoom.Text=closeup and 'Full body' or 'Face view' end)
local function layout()
 local w,h=page.AbsoluteSize.X,page.AbsoluteSize.Y
 local portrait=w<560 and h>w
 local header=h<420 and 42 or 66
 local footerHeight=h<420 and 44 or 58
 local editor=portrait and w-24 or math.clamp(math.floor(w*.31),226,350)
 local top=portrait and math.floor(h*.46) or header+10
 local tabs=slot and tab=='Appearance' and 38 or 0
 local available=h-top-footerHeight-10-tabs
 local identity=slot~=nil and tab=='Identity'
 if portrait then at(set,0,header,w,top-header-6)
 else at(set,editor+24,header+10,w-editor-36,h-header-footerHeight-20) end
 at(panel,0,0,w,header);panel.ClipsDescendants=false
 at(imprint,18,header<50 and 2 or 9,w-36,13);at(title,18,header<50 and 16 or 27,w-155,header<50 and 23 or 30);title.TextSize=header<50 and 17 or 24
 at(servers,w-126,header<50 and 6 or 20,110,30)
 categoryBar.Visible=tabs>0
 at(categoryBar,12,top,editor,tabs)
 local column=identity and (editor-8)/2 or editor
 at(west,12,top+tabs,column,available)
 at(east,20+column,top+tabs,column,available)
 east.Visible=identity
 at(pane,6,6,column-12,available-12);at(sidePane,6,6,column-12,available-12)
 at(back,14,h-footerHeight+7,70,footerHeight-14);at(enter,w-137,h-footerHeight+7,123,footerHeight-14)
 at(footer,98,h-footerHeight+5,w-250,footerHeight-10);footer.TextSize=h<420 and 12 or 14
 local center=set.AbsoluteSize.X/2;local yy=set.AbsoluteSize.Y-42
 at(left,center-91,yy,40,34);at(right,center+51,yy,40,34);at(zoom,center-47,yy,94,34)
 at(caption,12,10,set.AbsoluteSize.X-24,16)
 left.Text='‹';right.Text='›';zoom.TextSize=11
 pose()
end
local function clear(parent) for _,v in parent:GetChildren() do v:Destroy() end end
local function chosenName()
 draft.Name=draft.FirstName..' '..draft.LastName
 footer.Text=draft.Name
end
draw=function()
 clear(pane);clear(sidePane);clear(categoryBar)
 pane.CanvasPosition=Vector2.zero;sidePane.CanvasPosition=Vector2.zero
 title.Text=not slot and 'CHOOSE YOUR RESIDENT' or tab=='Identity' and 'CREATE YOUR IDENTITY' or 'APPEARANCE'
 servers.Visible=slot==nil;east.Visible=slot~=nil
 back.Visible=slot~=nil;enter.Visible=slot~=nil
 zoom.Visible=slot~=nil and tab=='Appearance';zoom.Text=closeup and 'Full body' or 'Face view'
 enter.Text=tab=='Identity' and 'Continue' or 'Enter city'
 if mirror then title.Text='BARBER MIRROR';enter.Text='Save face';footer.Text=draft.Name
 elseif slot then chosenName() end
 layout()
 local function hint(parent,text)
  local v=label(parent,text,13,gold);v.Size=UDim2.new(1,-4,0,26)
 end
 if not slot then
  hint(pane,'RESIDENT FILES  /  3 SLOTS')
  for i,record in rows do
   local b=button(pane,record.Name or 'New resident',function() chooseFile(i) end)
   b.Text=string.format('%02d   %s',i,record.Name or 'New resident')
   b.Position=UDim2.fromOffset(0,32+(i-1)*68);b.Size=UDim2.new(1,-4,0,60)
   b.TextXAlignment=Enum.TextXAlignment.Left;b.TextSize=14;b.TextWrapped=true
   make('UIPadding',{PaddingLeft=UDim.new(0,12)},b)
  end
  return
 end
 if tab=='Identity' then
  local function names(parent,field,caption,list)
   hint(parent,caption)
   local box=make('TextBox',{Name=field..' input',Text=draft[field],PlaceholderText=caption,
    ClearTextOnFocus=false,MultiLine=false,TextSize=16,Font=Enum.Font.GothamMedium,TextColor3=cream,
    BackgroundColor3=slate,BorderSizePixel=0,Size=UDim2.new(1,-4,0,38),Position=UDim2.fromOffset(0,28)},parent)
   local buttons={}
   box:GetPropertyChangedSignal('Text'):Connect(function()
    draft[field]=box.Text;chosenName()
    for name,item in buttons do
     item.BackgroundColor3=name==box.Text and gold or slate;item.TextColor3=name==box.Text and ink or cream
    end
   end)
   local suggestions=label(parent,'Suggestions',12,paper)
   suggestions.Position=UDim2.fromOffset(2,72);suggestions.Size=UDim2.new(1,-4,0,20)
   for i,value in list do
    local b=button(parent,value,function()
     box.Text=value
    end)
    buttons[value]=b;b.Position=UDim2.fromOffset(0,96+(i-1)*34);b.Size=UDim2.new(1,-4,0,30)
    if draft[field]==value then b.BackgroundColor3=gold;b.TextColor3=ink end
   end
  end
  names(pane,'FirstName','First name',style.FirstNames);names(sidePane,'LastName','Last name',style.LastNames)
  return
 end
 local function controls(parent,fields,offset)
  for i,field in fields do
   local key,caption,values=table.unpack(field)
   local y=(offset or 0)+(i-1)*62
   local l=label(parent,caption,12,paper);l.Position=UDim2.fromOffset(3,y);l.Size=UDim2.new(1,-6,0,16)
   local current=label(parent,draft[key],14,cream);current.TextXAlignment=Enum.TextXAlignment.Center
   current.Position=UDim2.fromOffset(41,y+19);current.Size=UDim2.new(1,-84,0,35)
   for _,delta in {-1,1} do
    local b=button(parent,delta==1 and '›' or '‹',function()
     local index=table.find(values,draft[key]) or 1
     draft[key]=values[(index-1+delta)%#values+1];current.Text=draft[key]
     if key=='FaceShape' or key=='FaceWidth' or key=='EyeSpacing' or key=='LipFullness' or key=='Hair' then
      closeup=true;zoom.Text='Full body'
     end
     rebuild()
    end)
    b.Name=key..(delta==1 and ' next' or ' previous');b.TextSize=20
    b.Position=UDim2.new(delta==1 and 1 or 0,delta==1 and -40 or 0,0,y+18);b.Size=UDim2.fromOffset(38,38)
   end
  end
 end
 local categories=mirror and {'Face'} or {'Face','Hair','Body','Outfit'}
 for i,name in categories do
  local selected=category==name
  local b=button(categoryBar,name,function()
   category=name;closeup=name=='Face' or name=='Hair';draw()
  end)
  b.Name='Category '..name;b.TextSize=12
  b.Size=UDim2.new(1/#categories,-3,0,30);b.Position=UDim2.new((i-1)/#categories,0,0,0)
  b.BackgroundColor3=selected and cream or slate;b.TextColor3=selected and ink or paper
 end
 if category=='Face' then
  controls(pane,{{'FaceShape','Head shape',style.FaceShapes},{'FaceWidth','Face width',style.FaceWidths},{'Expression','Eyes',style.Expressions},{'EyeSpacing','Eye spacing',style.EyeSpacings},{'Eye','Eye color',style.Eyes},{'Mouth','Mouth',style.Mouths},{'LipFullness','Lip fullness',style.LipFullness},{'Detail','Facial hair & details',style.Details}})
 elseif category=='Body' then
  controls(pane,{{'Tone','Skin tone',style.Tones},{'Height','Height',style.Heights},{'Build','Body width',style.Builds},{'Depth','Body depth',style.Depths}})
 elseif category=='Hair' then
  controls(pane,{{'Hair','Haircut',style.Hair},{'HairDetail','Hairline',style.HairDetails}})
  local palette=label(pane,'HAIR COLOR  /  '..draft.HairColor:upper(),11,paper)
  palette.Position=UDim2.fromOffset(3,134);palette.Size=UDim2.new(1,-6,0,24)
  local swatches={}
  for index,color in style.HairColors do
   local swatch=button(pane,'',function()
    draft.HairColor=color;palette.Text='HAIR COLOR  /  '..color:upper()
    for name,tile in swatches do tile.BorderSizePixel=name==color and 2 or 0 end
    closeup=true;zoom.Text='Full body';rebuild()
   end)
   swatch.Name='Dye '..color;swatch.BackgroundColor3=style.Dyes[color];swatch.BorderColor3=cream
   swatch.BorderSizePixel=draft.HairColor==color and 2 or 0
   swatch.Position=UDim2.new((index-1)%4/4,3,0,166+math.floor((index-1)/4)*44)
   swatch.Size=UDim2.new(1/4,-8,0,36);swatches[color]=swatch
  end
 elseif category=='Outfit' then
  hint(pane,'STARTER LOOKS')
  for i,set in style.Sets do
   local preset=button(pane,set.Name,function()
    closeup=false;draft.Starter=set.Starter;draft.Pants=set.Pants;draft.Shoes=set.Shoes
    rebuild();draw()
   end)
   preset.Name='Preset '..i;preset.Position=UDim2.fromOffset(0,30+(i-1)*45);preset.Size=UDim2.new(1,-4,0,39);preset.TextSize=12
   if draft.Starter==set.Starter and draft.Pants==set.Pants and draft.Shoes==set.Shoes then preset.BackgroundColor3=cream;preset.TextColor3=ink end
  end
  controls(pane,{{'Starter','Top',style.Starters},{'Pants','Trousers',style.Pants},{'Shoes','Shoes',style.Shoes}},178)
 end
end
local function files()
 local encoded=player:GetAttribute('ResidentFiles')
 if encoded then rows=game.HttpService:JSONDecode(encoded);footer.Text='';draw() end
end
close=function()
 if not screen.Enabled then return end
 local focused=input:GetFocusedTextBox();if focused and focused:IsDescendantOf(screen) then focused:ReleaseFocus() end
 screen.Enabled=false;waiting=false;mirror=false;wornOutfit=nil
 if rig then rig:Destroy();rig=nil end
end
event.OnClientEvent:Connect(function(kind,data)
 if kind=='FaceMirror' and player.Character then
  draft=fresh()
  for key,value in data.Look do draft[key]=value end
  wornOutfit=data.Outfit;slot=player:GetAttribute('ResidentSlot');tab='Appearance';category='Face';mirror=true
  closeup=true;yaw=.22;waiting=false;screen.Enabled=true;rebuild();draw()
 elseif kind=='MirrorDone' and mirror then close()
 elseif screen.Enabled and kind=='Notice' and waiting then
  footer.Text=tostring(data);waiting=false
 end
end)
player.CharacterAdded:Connect(close)
player:GetAttributeChangedSignal('ResidentFiles'):Connect(files)
page:GetPropertyChangedSignal('AbsoluteSize'):Connect(layout)
draw();rebuild();files()
if player.Character then close() end
