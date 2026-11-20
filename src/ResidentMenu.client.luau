local Players=game:GetService('Players')
local storage=game:GetService('ReplicatedStorage')
local input=game:GetService('UserInputService')
local player=Players.LocalPlayer
local style=require(storage:WaitForChild('StreetStyle'))
local geometry=require(storage:WaitForChild('CreatorLayout'))
local template=storage:WaitForChild('ResidentRig')
local event=storage:WaitForChild('CityAction')
local theme=require(storage:WaitForChild('UITheme'))
local cream,paper,ink,slate,gold=theme.Text,theme.Muted,theme.Background,theme.Surface,theme.Accent
local function make(class,props,parent)
 local v=Instance.new(class)
 for k,value in props do v[k]=value end
 v.Parent=parent
 return v
end
local screen=make('ScreenGui',{Name='ResidentStudio',DisplayOrder=24,ResetOnSpawn=false,IgnoreGuiInset=false,ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets,ClipToDeviceSafeArea=true},player:WaitForChild('PlayerGui'))
local page=make('Frame',{Name='Studio',Size=UDim2.fromScale(1,1),BackgroundColor3=ink,BorderSizePixel=0,Active=true},screen)
local canvas=make('Frame',{Name='Creator canvas',BackgroundTransparency=1,Size=UDim2.fromScale(1,1)},page)
local function frame(parent,color)
 return make('Frame',{BorderSizePixel=0,BackgroundColor3=color},parent)
end
local function label(parent,value,size,color)
 return make('TextLabel',{BackgroundTransparency=1,Font=Enum.Font.GothamMedium,Text=value,TextSize=size,TextColor3=color,TextXAlignment=Enum.TextXAlignment.Left,BorderSizePixel=0},parent)
end
local function button(parent,value,callback)
 local b=make('TextButton',{Name=value,Text=value,TextColor3=cream,TextSize=14,Font=Enum.Font.GothamMedium,BackgroundColor3=slate,BorderSizePixel=0},parent)
 b.Selectable=true
 b.Activated:Connect(callback)
 b.SelectionGained:Connect(function() b.BackgroundTransparency=.18 end)
 b.SelectionLost:Connect(function() b.BackgroundTransparency=0 end)
 b.MouseEnter:Connect(function() b.BackgroundTransparency=.16 end)
 b.MouseLeave:Connect(function() b.BackgroundTransparency=0 end)
 return b
end
local function at(v,x,y,w,h)
 v.Position=UDim2.fromOffset(x,y);v.Size=UDim2.fromOffset(math.max(1,w),math.max(1,h))
end
local set=frame(canvas,paper);set.Name='Character preview'
set.ClipsDescendants=true
make('UIGradient',{Rotation=90,Color=ColorSequence.new(Color3.fromRGB(100,113,125),Color3.fromRGB(44,51,63))},set)
local viewport=make('ViewportFrame',{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Ambient=Color3.fromRGB(190,193,202),LightColor=Color3.fromRGB(255,243,230),LightDirection=Vector3.new(-.65,-.35,-1)},set)
local world=make('WorldModel',{},viewport)
local camera=make('Camera',{FieldOfView=35},viewport)
viewport.CurrentCamera=camera
local panel=frame(canvas,ink)
local imprint=label(panel,'BALTIMORE  /  RESIDENT REGISTRATION',10,gold)
local title=label(panel,'CHOOSE YOUR RESIDENT',24,cream);title.Font=theme.TitleFont
local function scroller(parent)
 return make('ScrollingFrame',{CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingDirection=Enum.ScrollingDirection.Y,ScrollBarThickness=3,BackgroundTransparency=1,BorderSizePixel=0},parent)
end
local west=frame(canvas,ink);local east=frame(canvas,ink)
west.Name='Editor';east.Name='Last name editor'
local pane=scroller(west);local sidePane=scroller(east)
local categoryBar=frame(canvas,ink);categoryBar.Name='Appearance categories'
local category='Hair'
local caption=label(set,'DRAG TO ROTATE',10,cream)
caption.TextTransparency=.2
local actionBar=frame(canvas,ink);actionBar.Name='Actions'
local footer=label(actionBar,'Loading your files…',14,cream);footer.TextWrapped=true
local slot,tab,waiting=nil,'Identity',false
local enter
local requestSerial=0
local selectedFile
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
local function fresh() return require(storage.ResidentAppearance).new() end
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
local function waitForResident(message)
 requestSerial+=1;local request=requestSerial
 waiting=true;footer.Text=message
 if enter then enter.Text='Loading…' end
 task.delay(18,function()
  if requestSerial==request and waiting and screen.Enabled then
   waiting=false;footer.Text='Taking longer than expected. Try Enter city again.'
   if enter then enter.Text='Enter city' end
  end
 end)
end
local function chooseFile(index)
 if waiting then return end
 local record=rows[index]
 if not record then return end
 if record.Name then
  selectedFile=index;slot=nil;draft=style.restore(record.Look)
  wornOutfit=record.Outfit;footer.Text=record.Name;closeup=false;rebuild();draw()
 else
  selectedFile=nil;wornOutfit=nil;slot=index;tab='Identity';draft=fresh();yaw=.22;footer.Text='';rebuild();draw()
 end
end
local function send()
 if waiting or not slot then return end
 if mirror then waitForResident('Updating face…');event:FireServer('MirrorLook',draft);return end
 if player:GetAttribute('ResidentSlot')==slot and player:GetAttribute('NeedsCharacter')==false then
  waitForResident('Loading saved resident…');event:FireServer('SelectFile',{Index=slot});return
 end
 waitForResident('Saving resident…')
 local request=table.clone(draft);request.Index=slot
 event:FireServer('CreateResident',request)
end
local function advance()
 if waiting then return end
 if selectedFile and not slot then
  waitForResident('Loading '..draft.Name..'…');event:FireServer('SelectFile',{Index=selectedFile});return
 end
 if tab=='Identity' then
  for _,value in {draft.FirstName,draft.LastName} do
   local length=utf8.len(value:match('^%s*(.-)%s*$'))
   if not length or length<1 or length>20 then footer.Text='Enter 1 to 20 characters for each name.';return end
  end
  tab='Appearance';category='Hair';closeup=true;draw()
 else send() end
end
enter=button(actionBar,'Continue',advance)
enter.BackgroundColor3=gold;enter.TextColor3=ink
local back=button(actionBar,'Back',function()
 if waiting then return end
 if mirror then close();return end
 if tab=='Appearance' then tab='Identity' else slot=nil;draft=fresh() end
 closeup=false;footer.Text='';rebuild();draw()
end)
local servers=button(panel,'City servers',function() require(storage.ServerBrowser).open() end)
local zoom=button(set,'Face view',function() closeup=not closeup;pose() end)
zoom.Activated:Connect(function() zoom.Text=closeup and 'Full body' or 'Face view' end)
local function layout()
 local g=geometry.measure(page.AbsoluteSize.X,page.AbsoluteSize.Y,slot~=nil and tab=='Appearance',slot~=nil and tab=='Identity')
 local w,h=g.width,g.height
 at(canvas,g.x,0,w,h)
 at(set,table.unpack(g.preview))
 at(panel,g.margin,0,w-g.margin*2,g.header)
 at(imprint,0,8,w-36,14);at(title,0,g.header<60 and 22 or 31,w-155,g.header<60 and 24 or 36)
 title.TextSize=g.header<60 and 20 or 30
 at(servers,w-g.margin*2-126,12,126,36)
 categoryBar.Visible=g.tabs>0;at(categoryBar,g.margin,g.top,g.sidebar,g.tabs)
 at(west,g.margin,g.top+g.tabs,g.column,g.available)
 at(east,g.margin+g.column+12,g.top+g.tabs,g.column,g.available)
 east.Visible=slot~=nil and tab=='Identity'
 at(pane,0,4,g.column,g.available-8);at(sidePane,0,4,g.column,g.available-8)
 at(actionBar,g.margin,h-g.footer,w-g.margin*2,g.footer)
 at(back,0,6,78,g.footer-14);at(enter,w-g.margin*2-150,6,150,g.footer-14)
 at(footer,92,6,math.max(1,w-g.margin*2-256),g.footer-14)
 footer.TextSize=h<430 and 12 or 14
 local center=set.AbsoluteSize.X/2;local yy=set.AbsoluteSize.Y-48
 at(left,center-102,yy,44,40);at(right,center+58,yy,44,40);at(zoom,center-54,yy,108,40)
 at(caption,16,14,set.AbsoluteSize.X-32,18)
 left.Text='‹';right.Text='›';zoom.TextSize=12
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
 title.Text=not slot and 'CHARACTER SELECT' or tab=='Identity' and 'YOUR IDENTITY' or 'CUSTOMIZE CHARACTER'
 servers.Visible=slot==nil;east.Visible=slot~=nil
 back.Visible=slot~=nil;enter.Visible=slot~=nil or selectedFile~=nil
 zoom.Visible=slot~=nil and tab=='Appearance';zoom.Text=closeup and 'Full body' or 'Face view'
 enter.Text=not slot and 'Enter city' or tab=='Identity' and 'Continue' or 'Enter city'
 if mirror then title.Text='BARBER MIRROR';enter.Text='Save face';footer.Text=draft.Name
 elseif slot then chosenName() end
 layout()
 local function hint(parent,text)
  local v=label(parent,text,13,gold);v.Size=UDim2.new(1,-4,0,26)
 end
 if not slot then
  hint(pane,'SELECT A CHARACTER')
  for i,record in rows do
   local b=button(pane,record.Name or 'New resident',function() chooseFile(i) end)
   b.Text='';b.Position=UDim2.fromOffset(0,34+(i-1)*88);b.Size=UDim2.new(1,-4,0,80)
   local marker=label(b,string.format('%02d',i),27,selectedFile==i and ink or gold)
   marker.Font=theme.TitleFont;at(marker,14,12,36,36)
   local name=label(b,record.Name or 'New resident',16,selectedFile==i and ink or cream)
   at(name,58,12,pane.AbsoluteSize.X-76,25);name.TextWrapped=true
   local detail=record.Name and ('$'..tostring(record.Cash or 0)..' cash  /  Saved resident') or record.Occupied and 'Finish setting up this resident' or 'Start a new life in Baltimore'
   local meta=label(b,detail,12,selectedFile==i and ink or paper)
   at(meta,58,42,pane.AbsoluteSize.X-76,26);meta.TextWrapped=true
   local rail=frame(b,selectedFile==i and gold or theme.Line);rail.Size=UDim2.new(0,3,1,0)
   b:SetAttribute('SlotIndex',i)
   if selectedFile==i then b.BackgroundColor3=cream;b.TextColor3=ink end
  end
  return
 end
 if tab=='Identity' then
  footer.Text='Choose a fictional name for roleplay.'
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
   make('UIStroke',{Color=theme.Line,Thickness=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},box)
   make('UIPadding',{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10)},box)
   local suggestions=label(parent,'OR PICK A NAME',11,paper)
   suggestions.Position=UDim2.fromOffset(2,72);suggestions.Size=UDim2.new(1,-4,0,20)
   for i,value in list do
    local b=button(parent,value,function()
     box.Text=value
    end)
    buttons[value]=b;b.Position=UDim2.fromOffset(0,96+(i-1)*44);b.Size=UDim2.new(1,-4,0,40)
    if draft[field]==value then b.BackgroundColor3=gold;b.TextColor3=ink end
   end
  end
  names(pane,'FirstName','First name',style.FirstNames);names(sidePane,'LastName','Last name',style.LastNames)
  return
 end
 local function controls(parent,fields,offset)
  for i,field in fields do
   local key,caption,values=table.unpack(field)
   local y=(offset or 0)+(i-1)*74
   local l=label(parent,caption,12,paper);l.Position=UDim2.fromOffset(3,y);l.Size=UDim2.new(1,-6,0,16)
   local current=label(parent,draft[key],14,cream);current.TextXAlignment=Enum.TextXAlignment.Center
   current.Position=UDim2.fromOffset(49,y+21);current.Size=UDim2.new(1,-100,0,42)
   local line=frame(parent,theme.Line);line.Position=UDim2.new(0,3,0,y+68);line.Size=UDim2.new(1,-6,0,1)
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
    b.Position=UDim2.new(delta==1 and 1 or 0,delta==1 and -46 or 0,0,y+20);b.Size=UDim2.fromOffset(44,44)
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
  b.Size=UDim2.new(1/#categories,-3,0,40);b.Position=UDim2.new((i-1)/#categories,0,0,0)
  b.BackgroundColor3=selected and cream or slate;b.TextColor3=selected and ink or paper
 end
 if category=='Face' then
  for i,name in style.FaceShapes do
   local preset=button(pane,name,function() draft.FaceShape=name;closeup=true;rebuild();draw() end)
   preset.Name='Face preset '..name;preset.TextSize=12
   preset.Size=UDim2.new(1/3,-5,0,40);preset.Position=UDim2.new((i-1)%3/3,0,0,math.floor((i-1)/3)*45)
   if draft.FaceShape==name then preset.BackgroundColor3=cream;preset.TextColor3=ink end
  end
  controls(pane,{{'FaceShape','Head shape',style.FaceShapes},{'FaceWidth','Face width',style.FaceWidths},{'Expression','Eyes',style.Expressions},{'EyeSpacing','Eye spacing',style.EyeSpacings},{'Eye','Eye color',style.Eyes},{'Mouth','Mouth',style.Mouths},{'LipFullness','Lip fullness',style.LipFullness},{'Detail','Facial hair & details',style.Details}},100)
 elseif category=='Body' then
  controls(pane,{{'Tone','Skin tone',style.Tones},{'Height','Height',style.Heights},{'Build','Body width',style.Builds},{'Depth','Body depth',style.Depths}})
 elseif category=='Hair' then
  controls(pane,{{'Hair','Haircut',style.Hair},{'HairDetail','Hairline',style.HairDetails}})
  local palette=label(pane,'HAIR COLOR  /  '..draft.HairColor:upper(),11,paper)
  palette.Position=UDim2.fromOffset(3,156);palette.Size=UDim2.new(1,-6,0,24)
  local swatches={}
  for index,color in style.HairColors do
   local swatch=button(pane,'',function()
    draft.HairColor=color;palette.Text='HAIR COLOR  /  '..color:upper()
    for name,tile in swatches do tile.BorderSizePixel=name==color and 2 or 0 end
    closeup=true;zoom.Text='Full body';rebuild()
   end)
   swatch.Name='Dye '..color;swatch.BackgroundColor3=style.Dyes[color];swatch.BorderColor3=cream
   swatch.BorderSizePixel=draft.HairColor==color and 2 or 0
   swatch.Position=UDim2.new((index-1)%4/4,3,0,190+math.floor((index-1)/4)*50)
   swatch.Size=UDim2.new(1/4,-8,0,44);swatches[color]=swatch
  end
  local cutTitle=label(pane,'ALL HAIRCUTS',11,paper);at(cutTitle,3,350,220,24)
  for i,cut in style.Hair do
   local pick=button(pane,cut,function() draft.Hair=cut;closeup=true;rebuild();draw() end)
   pick.Name='Choose haircut '..cut;pick.TextSize=12
   pick.Size=UDim2.new(.5,-5,0,44);pick.Position=UDim2.new((i-1)%2/2,0,0,382+math.floor((i-1)/2)*49)
   if draft.Hair==cut then pick.BackgroundColor3=cream;pick.TextColor3=ink end
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
input.InputBegan:Connect(function(key,processed)
 if not screen.Enabled or input:GetFocusedTextBox() or processed then return end
 if key.KeyCode==Enum.KeyCode.Left then turn(-math.pi/6)
 elseif key.KeyCode==Enum.KeyCode.Right then turn(math.pi/6)
 elseif key.KeyCode==Enum.KeyCode.Return and enter.Visible then advance()
 elseif key.KeyCode==Enum.KeyCode.ButtonSelect then
  local first=pane:FindFirstChildWhichIsA('GuiButton',true)
  if first then game:GetService('GuiService').SelectedObject=first end
 end
end)
local function files()
 local encoded=player:GetAttribute('ResidentFiles')
 if encoded then
  rows=game.HttpService:JSONDecode(encoded);footer.Text=''
  if not slot and not selectedFile and not waiting then
   for i,record in rows do if record.Name then chooseFile(i);return end end
  end
  draw()
 end
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
  footer.Text=tostring(data);waiting=false;requestSerial+=1;enter.Text=mirror and 'Save face' or 'Enter city'
 end
end)
player.CharacterAdded:Connect(close)
player:GetAttributeChangedSignal('ResidentFiles'):Connect(files)
page:GetPropertyChangedSignal('AbsoluteSize'):Connect(layout)
draw();rebuild();files()
if player.Character then close() end
