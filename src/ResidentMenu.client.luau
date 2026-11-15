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
-- Painted measuring marks provide a fixed reference as the resident's height changes.
for i=1,15 do
 local tick=frame(set,Color3.fromRGB(124,141,135))
 tick.Position=UDim2.fromScale(.04,i/17);tick.Size=UDim2.new(i%3==0 and .17 or .055,0,0,1)
end
local viewport=make('ViewportFrame',{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Ambient=Color3.fromRGB(168,176,177),LightColor=Color3.fromRGB(255,237,204),LightDirection=Vector3.new(-1,-.6,-1)},set)
local world=make('WorldModel',{},viewport)
local camera=make('Camera',{FieldOfView=35},viewport)
viewport.CurrentCamera=camera
local panel=frame(page,ink)
local imprint=label(panel,'NORTHSIDE   /   BALTIMORE',11,gold)
local title=label(panel,'Resident files',29,cream);title.Font=Enum.Font.GothamBold
local tabs=frame(panel,ink)
local pane=make('ScrollingFrame',{CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingDirection=Enum.ScrollingDirection.Y,ScrollBarThickness=4,BackgroundTransparency=1,BorderSizePixel=0},panel)
local footer=label(panel,'Loading your files…',12,gold);footer.TextWrapped=true
local slot,tab,waiting=nil,'Identity',false
local rows={}
local function fresh() return {Height='Medium',Build='Average',Tone='Amber',Hair='Close crop',Name='',Starter='Varsity',Detail='Clean',HairColor='Black',Eye='Brown'} end
local draft=fresh()
local yaw=.22
local rig
local function pose()
 if not rig then return end
 rig:PivotTo(CFrame.Angles(0,yaw,0))
 local bounds,size=rig:GetBoundingBox()
 local center=bounds.Position
 local aspect=viewport.AbsoluteSize.X/math.max(1,viewport.AbsoluteSize.Y)
 local distance=math.max(size.Y*1.17,size.X/math.max(.5,aspect))*1.95
 if slot and (tab=='Face' or tab=='Style') then
  center=rig.Head.Position-Vector3.new(0,tab=='Face' and .08 or .33,0)
  distance=math.max(tab=='Face' and 2.8 or 4.3,2.2/math.max(.5,aspect))
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
 event:FireServer('SelectFile',{Index=slot})
 event:FireServer('CreateResident',table.clone(draft))
end
local enter=button(panel,'Enter city',send);enter.BackgroundColor3=gold;enter.TextColor3=ink
local back=button(panel,'Files',function()
 if waiting or player:GetAttribute('ResidentSlot') then return end
 slot=nil;draft=fresh();footer.Text='';rebuild();draw()
end)
local servers=button(panel,'City servers',function() require(storage.ServerBrowser).open() end)
local function layout()
 local w,h=page.AbsoluteSize.X,page.AbsoluteSize.Y
 local portrait=w<h and w<650
 local sw=portrait and w or math.floor(w*(w>880 and .55 or .47))
 local sh=portrait and math.floor(h*.34) or h
 at(set,0,0,sw,sh)
 local pw=portrait and w or w-sw
 local ph=portrait and h-sh or h
 at(panel,portrait and 0 or sw,portrait and sh or 0,pw,ph)
 local pad=pw<390 and 12 or 22
 local top=ph<360 and 5 or 18
 at(imprint,pad,top,pw-2*pad,14);at(title,pad,top+17,pw-2*pad,35)
 at(servers,pw-100-pad,top+16,100,33)
 at(tabs,pad,top+54,pw-2*pad,31)
 local contentTop=top+(slot and 92 or 58)
 at(pane,pad,contentTop,pw-pad*2,ph-contentTop-(slot and 77 or 30))
 at(footer,pad,ph-(slot and 73 or 27),pw-pad*2,24)
 at(enter,pw-146-pad,ph-45,146,37);at(back,pad,ph-45,70,37)
 at(left,10,sh-41,77,31);at(right,sw-94,sh-41,84,31)
 pose()
end
local function clear(parent) for _,v in parent:GetChildren() do v:Destroy() end end
draw=function()
 clear(pane);clear(tabs);pane.CanvasPosition=Vector2.zero
 title.Text=slot and 'Create your resident' or 'Resident files'
 enter.Visible=slot~=nil;back.Visible=slot~=nil and not player:GetAttribute('ResidentSlot')
 servers.Visible=slot==nil
 tabs.Visible=slot~=nil
 layout()
 local y=0
 local function line(text)
  local l=label(pane,text,13,paper);l.Position=UDim2.fromOffset(0,y);l.Size=UDim2.new(1,-5,0,20);y+=23
 end
 local function options(key,caption,values,columns)
  line(caption)
  local first=y
  for i,v in values do
   local b=button(pane,v,function() draft[key]=v;rebuild();draw() end)
   local column=(i-1)%columns
   b.Position=UDim2.new(column/columns,0,0,first+math.floor((i-1)/columns)*34);b.Size=UDim2.new(1/columns,-4,0,30)
   if key=='Tone' then
    b.BackgroundColor3=style.Skin[i];b.Text='';b.Name=v
    if draft[key]==v then make('UIStroke',{Color=gold,Thickness=2,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},b) end
   elseif draft[key]==v then b.BackgroundColor3=gold;b.TextColor3=ink end
  end
  y=first+math.ceil(#values/columns)*34+5
 end
 if not slot then
  for i,record in rows do
   line('FILE 0'..i..(record.Cash~=nil and '  /  $'..math.floor(record.Cash) or ''))
   local b=button(pane,record.Name or 'New resident',function() chooseFile(i) end)
   b.Position=UDim2.fromOffset(0,y);b.Size=UDim2.new(1,-6,0,38);y+=45
  end
  return
 end
 for i,v in {'Identity','Build','Style','Face'} do
  local b=button(tabs,v,function() tab=v;draw() end)
  b.Position=UDim2.fromScale((i-1)/4,0);b.Size=UDim2.new(1/4,-3,1,0)
  if v==tab then b.BackgroundColor3=paper;b.TextColor3=ink end
 end
 if tab=='Identity' then
  line('Resident name')
  local name=make('TextBox',{Name='ResidentName',Position=UDim2.fromOffset(0,y),Size=UDim2.new(1,-6,0,40),BackgroundColor3=slate,BorderSizePixel=0,ClearTextOnFocus=false,PlaceholderText=player.DisplayName,Text=draft.Name,TextColor3=cream,PlaceholderColor3=paper,Font=Enum.Font.Gotham,TextSize=16},pane)
  name:GetPropertyChangedSignal('Text'):Connect(function() draft.Name=name.Text end)
  y+=50;options('Starter','Starter outfit',style.Starters,3)
 elseif tab=='Build' then
  options('Height','Height',style.Heights,3);options('Build','Build',style.Builds,3)
 elseif tab=='Style' then
  options('Tone','Skin tone  /  '..draft.Tone,style.Tones,7)
  options('Hair','Haircut',style.Hair,3)
  options('HairColor','Hair color',style.HairColors,3)
 else
  options('Eye','Eye color',style.Eyes,3)
  options('Detail','Face detail',style.Details,3)
 end
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
