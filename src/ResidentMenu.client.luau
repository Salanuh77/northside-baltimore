local Players=game:GetService('Players')
local storage=game:GetService('ReplicatedStorage')
local input=game:GetService('UserInputService')
local player=Players.LocalPlayer
local style=require(storage:WaitForChild('StreetStyle'))
local template=storage:WaitForChild('ResidentRig')
local event=storage:WaitForChild('CityAction')
local cream=Color3.fromRGB(242,235,216)
local paper=Color3.fromRGB(206,206,185)
local ink=Color3.fromRGB(22,36,40)
local slate=Color3.fromRGB(48,68,71)
local gold=Color3.fromRGB(234,177,89)
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
 return b
end
local function at(v,x,y,w,h)
 v.Position=UDim2.fromOffset(x,y);v.Size=UDim2.fromOffset(math.max(1,w),math.max(1,h))
end
local set=frame(page,paper)
set.ClipsDescendants=true
make('UIGradient',{Rotation=30,Color=ColorSequence.new(Color3.fromRGB(240,236,213),Color3.fromRGB(151,178,175))},set)
local viewport=make('ViewportFrame',{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Ambient=Color3.fromRGB(168,176,177),LightColor=Color3.fromRGB(255,237,204),LightDirection=Vector3.new(-1,-.6,-1)},set)
local world=make('WorldModel',{},viewport)
local camera=make('Camera',{FieldOfView=35},viewport)
viewport.CurrentCamera=camera
local panel=frame(page,ink)
local imprint=label(panel,'NORTHSIDE   /   BALTIMORE',11,gold)
local title=label(panel,'Resident files',29,cream);title.Font=Enum.Font.GothamBold
local function scroller(parent)
 return make('ScrollingFrame',{CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingDirection=Enum.ScrollingDirection.Y,ScrollBarThickness=3,BackgroundTransparency=1,BorderSizePixel=0},parent)
end
local west=frame(page,ink);local east=frame(page,ink)
west.BackgroundTransparency=.08;east.BackgroundTransparency=.08
local pane=scroller(west);local sidePane=scroller(east)
local footer=label(panel,'Loading your files…',14,cream);footer.TextWrapped=true
local slot,tab,waiting=nil,'Identity',false
local closeup=false
local room=make('Model',{Name='Fitting room'},world)
local function furnishing(name,size,position,color,material)
 return make('Part',{Name=name,Size=size,CFrame=CFrame.new(position),Anchored=true,Color=Color3.fromRGB(table.unpack(color)),Material=material or Enum.Material.SmoothPlastic},room)
end
furnishing('Studio floor',Vector3.new(28,.4,24),Vector3.new(0,-.22,0),{124,90,68},Enum.Material.WoodPlanks)
furnishing('Rear brick',Vector3.new(28,13,.6),Vector3.new(0,6.4,5),{145,102,80},Enum.Material.Brick)
for i=-2,2 do
 local x=i*4.6
 furnishing('Window reveal',Vector3.new(3.65,5.4,.3),Vector3.new(x,6,4.55),{49,60,61})
 furnishing('Daylight',Vector3.new(3.3,5,.2),Vector3.new(x,6,4.32),{165,195,193})
 furnishing('Crossbar',Vector3.new(3.4,.12,.25),Vector3.new(x,6.3,4.16),{66,69,66})
 furnishing('Sash',Vector3.new(.12,5,.25),Vector3.new(x,6,4.16),{66,69,66})
end
furnishing('Bench',Vector3.new(6,.35,1.5),Vector3.new(-5.8,1.45,3),{104,66,49},Enum.Material.Wood)
for _,x in {-8,-3.6} do furnishing('Bench foot',Vector3.new(.25,1.4,1.3),Vector3.new(x,.7,3),{63,61,57}) end
local roomOrigin=room:GetPivot()
local rows={}
local function fresh() return {Height='Medium',Build='Average',Tone='Amber',Hair='Close crop',Name='Avery Bell',FirstName='Avery',LastName='Bell',Depth='Standard',Pants='Dark denim',Shoes='Bone low-tops',Mouth='Level',HairDetail='Natural',Starter='Ash pullover',Detail='Clean',HairColor='Black',Eye='Brown',Expression='Calm'} end
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
  center=rig.Head.Position-Vector3.new(0,.18,0);distance=math.max(3.8,2.7/math.max(.5,aspect))
 end
 camera.CFrame=CFrame.lookAt(center+Vector3.new(0,.24,-distance),center)
end
local function rebuild()
 if rig then rig:Destroy() end
 rig=template:Clone();rig.Parent=world;rig.HumanoidRootPart.Anchored=true
 style.apply(rig,draft,nil);pose()
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
  tab='Appearance';draw()
 else send() end
end)
enter.BackgroundColor3=gold;enter.TextColor3=ink
local back=button(panel,'Back',function()
 if waiting then return end
 if tab=='Appearance' then tab='Identity' else slot=nil;draft=fresh() end
 closeup=false;footer.Text='';rebuild();draw()
end)
local servers=button(panel,'City servers',function() require(storage.ServerBrowser).open() end)
local zoom=button(set,'Face view',function() closeup=not closeup;pose() end)
zoom.Activated:Connect(function() zoom.Text=closeup and 'Full body' or 'Face view' end)
local function layout()
 local w,h=page.AbsoluteSize.X,page.AbsoluteSize.Y
 local compact=w<620
 local header=h<420 and 41 or 57
 local footerHeight=h<420 and 42 or 52
 local top=compact and math.floor(h*.49) or header+8
 local column=compact and math.floor((w-18)/2) or math.min(252,math.floor(w*.265))
 local available=h-top-footerHeight-8
 at(set,0,header,w,compact and top-header or h-header-footerHeight)
 at(panel,0,0,w,header);panel.ClipsDescendants=false
 at(imprint,14,3,w-28,13);at(title,14,15,w-30,header-16);title.TextSize=header<50 and 19 or 25
 at(servers,w-117,6,106,30)
 at(west,7,top,column,available);at(east,w-column-7,top,column,available)
 at(pane,5,4,column-10,available-8);at(sidePane,5,4,column-10,available-8)
 at(back,8,h-footerHeight+5,73,footerHeight-10);at(enter,w-111,h-footerHeight+5,103,footerHeight-10)
 at(footer,89,h-footerHeight+4,w-206,footerHeight-8)
 local center=w/2;local yy=set.AbsoluteSize.Y-36
 at(left,center-71,yy,35,32);at(right,center+36,yy,35,32);at(zoom,center-35,yy,70,32)
 left.Text='‹';right.Text='›';zoom.TextSize=11
 pose()
end
local function clear(parent) for _,v in parent:GetChildren() do v:Destroy() end end
local function chosenName()
 draft.Name=draft.FirstName..' '..draft.LastName
 footer.Text=draft.Name
end
draw=function()
 clear(pane);clear(sidePane)
 pane.CanvasPosition=Vector2.zero;sidePane.CanvasPosition=Vector2.zero
 title.Text=not slot and 'Resident files' or tab=='Identity' and 'Choose a roleplay name' or 'Customize your resident'
 servers.Visible=slot==nil;east.Visible=slot~=nil
 back.Visible=slot~=nil;enter.Visible=slot~=nil
 zoom.Visible=slot~=nil and tab=='Appearance'
 enter.Text=tab=='Identity' and 'Continue' or 'Enter city'
 if slot then chosenName() end
 layout()
 local function hint(parent,text)
  local v=label(parent,text,13,gold);v.Size=UDim2.new(1,-4,0,26)
 end
 if not slot then
  hint(pane,'Your save files')
  for i,record in rows do
   local b=button(pane,record.Name or 'New resident',function() chooseFile(i) end)
   b.Text=string.format('%02d   %s',i,record.Name or 'New resident')
   b.Position=UDim2.fromOffset(0,30+(i-1)*43);b.Size=UDim2.new(1,-4,0,39)
  end
  return
 end
 if tab=='Identity' then
  local function names(parent,field,caption,list)
   hint(parent,caption)
   local box=make('TextBox',{Name=field..' input',Text=draft[field],PlaceholderText=caption,
    ClearTextOnFocus=false,MultiLine=false,TextSize=16,Font=Enum.Font.GothamMedium,TextColor3=cream,
    BackgroundColor3=slate,BorderSizePixel=0,Size=UDim2.new(1,-4,0,38),Position=UDim2.fromOffset(0,28)},parent)
   box:GetPropertyChangedSignal('Text'):Connect(function()
    draft[field]=box.Text;chosenName()
   end)
   local suggestions=label(parent,'Suggestions',12,paper)
   suggestions.Position=UDim2.fromOffset(2,72);suggestions.Size=UDim2.new(1,-4,0,20)
   local buttons={}
   for i,value in list do
    local b=button(parent,value,function()
     box.Text=value
     for name,item in buttons do item.BackgroundColor3=name==value and gold or slate;item.TextColor3=name==value and ink or cream end
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
   local y=(offset or 0)+(i-1)*49
   local l=label(parent,caption,12,paper);l.Position=UDim2.fromOffset(3,y);l.Size=UDim2.new(1,-6,0,16)
   local current=label(parent,draft[key],13,cream);current.TextXAlignment=Enum.TextXAlignment.Center
   current.Position=UDim2.fromOffset(30,y+17);current.Size=UDim2.new(1,-64,0,27)
   for _,delta in {-1,1} do
    local b=button(parent,delta==1 and '›' or '‹',function()
     local index=table.find(values,draft[key]) or 1
     draft[key]=values[(index-1+delta)%#values+1];current.Text=draft[key];rebuild()
    end)
    b.Name=key..(delta==1 and ' next' or ' previous');b.TextSize=20
    b.Position=UDim2.new(delta==1 and 1 or 0,delta==1 and -32 or 0,0,y+16);b.Size=UDim2.fromOffset(28,30)
   end
  end
 end
 hint(pane,'Starter outfits')
 for i,set in style.Sets do
  local preset=button(pane,set.Name,function()
   draft.Starter=set.Starter;draft.Pants=set.Pants;draft.Shoes=set.Shoes
   rebuild();draw()
  end)
  preset.Name='Preset '..i; preset.Position=UDim2.fromOffset(0,28+(i-1)*33);preset.Size=UDim2.new(1,-4,0,30)
  if draft.Starter==set.Starter and draft.Pants==set.Pants and draft.Shoes==set.Shoes then preset.BackgroundColor3=gold;preset.TextColor3=ink end
 end
 controls(pane,{{'Hair','Primary hair',style.Hair},{'HairDetail','Hair detail',style.HairDetails},{'HairColor','Hair color',style.HairColors},{'Starter','Shirt',style.Starters},{'Pants','Pants',style.Pants},{'Shoes','Shoes',style.Shoes}},130)
 controls(sidePane,{{'Expression','Eye shape',style.Expressions},{'Mouth','Mouth',style.Mouths},{'Eye','Eye color',style.Eyes},{'Tone','Skin',style.Tones},{'Height','Height',style.Heights},{'Build','Width',style.Builds},{'Depth','Depth',style.Depths},{'Detail','Facial hair & details',style.Details}})
end
local function files()
 local encoded=player:GetAttribute('ResidentFiles')
 if encoded then rows=game.HttpService:JSONDecode(encoded);footer.Text='';draw() end
end
local function close()
 if not screen.Enabled then return end
 local focused=input:GetFocusedTextBox();if focused and focused:IsDescendantOf(screen) then focused:ReleaseFocus() end
 screen.Enabled=false
 if rig then rig:Destroy();rig=nil end
end
event.OnClientEvent:Connect(function(kind,data)
 if screen.Enabled and kind=='Notice' and waiting and not player.Character then
  footer.Text=tostring(data);waiting=false
 end
end)
player.CharacterAdded:Connect(close)
player:GetAttributeChangedSignal('ResidentFiles'):Connect(files)
page:GetPropertyChangedSignal('AbsoluteSize'):Connect(layout)
draw();rebuild();files()
if player.Character then close() end
