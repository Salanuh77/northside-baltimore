local Players=game:GetService('Players')
local UIS=game:GetService('UserInputService')
local CAS=game:GetService('ContextActionService')
local Run=game:GetService('RunService')
local Tween=game:GetService('TweenService')
local Debris=game:GetService('Debris')
local p=Players.LocalPlayer
local event=game:GetService('ReplicatedStorage'):WaitForChild('CityAction')
local mouse=p:GetMouse()
local openPhone
local catalog=require(game:GetService('ReplicatedStorage'):WaitForChild('WorkCatalog'))
local gui=Instance.new('ScreenGui'); gui.Name='NorthsideHUD'; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=false; gui.Parent=p:WaitForChild('PlayerGui')
local dark=Color3.fromRGB(21,27,29); local cream=Color3.fromRGB(236,229,212); local gold=Color3.fromRGB(224,176,83)
local function make(class,props,parent)
 local v=Instance.new(class); for k,val in props do v[k]=val end; v.Parent=parent; return v
end
local function text(parent,value,size,pos,fontSize,color)
 return make('TextLabel',{Text=value,Size=size,Position=pos,TextSize=fontSize or 16,TextColor3=color or cream,BackgroundTransparency=1,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true},parent)
end
local function button(parent,value,size,pos,fn)
 local b=make('TextButton',{Text=value,Size=size,Position=pos,BackgroundColor3=Color3.fromRGB(45,57,59),TextColor3=cream,TextSize=15,Font=Enum.Font.GothamMedium,AutoButtonColor=true,BorderSizePixel=0},parent)
 make('UICorner',{CornerRadius=UDim.new(0,6)},b); b.Activated:Connect(fn); return b
end
local top=make('Frame',{Size=UDim2.new(0,310,0,147),Position=UDim2.fromOffset(18,16),BackgroundColor3=dark,BackgroundTransparency=0.08,BorderSizePixel=0},gui)
make('UICorner',{CornerRadius=UDim.new(0,8)},top)
text(top,'N O R T H S I D E',UDim2.fromOffset(270,25),UDim2.fromOffset(16,9),19,gold)
local clockText=text(top,'BALTIMORE',UDim2.fromOffset(280,20),UDim2.fromOffset(16,33),11)
local wallet=text(top,'Cash $500   Bank $0',UDim2.fromOffset(280,25),UDim2.fromOffset(16,57),16)
local status=text(top,'Wanted 0/5   •   Goods 0',UDim2.fromOffset(280,20),UDim2.fromOffset(16,82),12)
local vital=text(top,'Health 100',UDim2.fromOffset(280,19),UDim2.fromOffset(16,103),12)
local healthTrack=make('Frame',{Size=UDim2.fromOffset(278,5),Position=UDim2.fromOffset(16,128),BackgroundColor3=Color3.fromRGB(55,67,65),BorderSizePixel=0},top)
local healthFill=make('Frame',{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(109,185,155),BorderSizePixel=0},healthTrack)
local notice=text(gui,'',UDim2.new(0.8,0,0,60),UDim2.fromScale(0.1,0.75),18)
notice.TextXAlignment=Enum.TextXAlignment.Center; notice.TextStrokeTransparency=0.3
local noticeId=0
local function notify(s)
 noticeId+=1; local id=noticeId; notice.Text=s
 task.delay(6,function() if noticeId==id then notice.Text='' end end)
end
local hint=text(gui,'E · interact    H · surrender    T · players    R · reload',UDim2.new(0.8,0,0,26),UDim2.fromScale(0.1,0.94),13)
hint.TextXAlignment=Enum.TextXAlignment.Center; hint.TextStrokeTransparency=0.4
local ammo=text(gui,'',UDim2.fromOffset(200,40),UDim2.new(1,-220,1,-110),22,gold)
local progress=make('Frame',{Size=UDim2.fromOffset(300,5),Position=UDim2.new(0.5,-150,0.73,0),BackgroundColor3=gold,BorderSizePixel=0,Visible=false},gui)
local progressTween
local modal=make('Frame',{Size=UDim2.new(1,-24,1,-24),Position=UDim2.fromScale(0.5,0.5),AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=dark,Visible=false,BorderSizePixel=0},gui)
make('UISizeConstraint',{MaxSize=Vector2.new(380,440)},modal)
make('UICorner',{CornerRadius=UDim.new(0,10)},modal)
local title=text(modal,'',UDim2.new(1,-70,0,40),UDim2.fromOffset(18,10),20,gold)
local content=make('ScrollingFrame',{Size=UDim2.new(1,-30,1,-65),Position=UDim2.fromOffset(15,58),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=4,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new()},modal)
make('UIListLayout',{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder},content)
button(modal,'×',UDim2.fromOffset(35,35),UDim2.new(1,-48,0,12),function() modal.Visible=false end)
local order=0
local function clear(name)
 if not modal.Visible or title.Text~=name then content.CanvasPosition=Vector2.zero end
 for _,v in content:GetChildren() do if not v:IsA('UIListLayout') then v:Destroy() end end
 title.Text=name; modal.Visible=true; order=0
end
local function row(s,fn)
 order+=1; local b=button(content,s,UDim2.new(1,-6,0,43),UDim2.new(),fn); b.LayoutOrder=order; return b
end
local function paragraph(s)
 order+=1; local l=text(content,s,UDim2.new(1,-6,0,70),UDim2.new(),14); l.LayoutOrder=order; return l
end
local function input(placeholder)
 order+=1
 local b=make('TextBox',{Size=UDim2.new(1,-6,0,42),PlaceholderText=placeholder,Text='',ClearTextOnFocus=false,TextSize=16,TextColor3=cream,BackgroundColor3=Color3.fromRGB(38,45,47),Font=Enum.Font.Gotham,LayoutOrder=order},content)
 return b
end
local state={Items={}}
local retailUI=require(game.ReplicatedStorage:WaitForChild('RetailUI'))(event,modal,content,clear,row,paragraph,input,function() return state end)
local selectedItem='Pistol'
local function playerDetail(other)
 clear('@'..other.Name)
 paragraph('Payments transfer immediately. Item offers show the buyer the item and price before they accept. Both players must be nearby.')
 local amount=input('Amount / asking price in cash')
 row('Pay cash',function() event:FireServer('Pay',{Target=other.UserId,Amount=tonumber(amount.Text)}) end)
 local selector=row('Item: '..selectedItem,function() end)
 local list={'Pistol','Crowbar','Medkit','Bat','Knife'}; local index=1
 selector.Activated:Connect(function() index=index%#list+1; selectedItem=list[index]; selector.Text='Item: '..selectedItem end)
 row('Offer selected item for sale',function() event:FireServer('Offer',{Target=other.UserId,Item=selectedItem,Amount=tonumber(amount.Text)}) end)
 row('Rob surrendered player · hold position 8s',function() event:FireServer('RobPlayer',{Target=other.UserId}); modal.Visible=false end)
end
local function playersMenu()
 clear('NEARBY PLAYERS')
 paragraph('Select a player to pay, trade, or rob. Robbery requires an equipped pistol, a surrendered target, and no safe zone.')
 local count=0; local root=p.Character and p.Character:FindFirstChild('HumanoidRootPart')
 for _,other in Players:GetPlayers() do
  local r=other.Character and other.Character:FindFirstChild('HumanoidRootPart')
  if other~=p and root and r and (root.Position-r.Position).Magnitude<=30 then count+=1; row(other.DisplayName..'  (@'..other.Name..')',function() playerDetail(other) end) end
 end
 if count==0 then paragraph('No players nearby. Multiplayer actions require a second player.'); end
end
local jobMarker
event.OnClientEvent:Connect(function(kind,data)
 if retailUI.handle(kind,data) then return end
 if kind=='Notice' then notify(data)
 elseif kind=='State' then state=data; wallet.Text='Cash $'..data.Cash..'   Bank $'..data.Bank; status.Text='Wanted '..data.Heat..'/5   •   Goods '..data.Loot
 elseif kind=='BailDesk' then
  clear('PATAPSCO  /  BAIL')
  if #data==0 then paragraph('There are no active bookings.') end
  for _,entry in data do
   row('Post $'..entry.Cost..' for '..entry.Name,function()
    clear('CONFIRM BAIL'); paragraph('Release '..entry.Name..' for $'..entry.Cost..' from your cash balance?')
    row('Pay $'..entry.Cost,function() modal.Visible=false; event:FireServer('PostBail',{Target=entry.Id}) end)
   end)
  end
 elseif kind=='LightRun' then
  clear('RECREATION  /  LIGHT RUN')
  local clue=paragraph('Memorize the sequence: '..table.concat(data,'  /  '))
  for _,v in {'Wave','Bell','Star','Key'} do row(v,function() event:FireServer('LightPress',{Symbol=v}) end) end
  if clue then task.delay(3,function() if clue.Parent then clue.Text='Repeat the four symbols in order.' end end) end
 elseif kind=='LightStep' then notify('Light Run  '..(data-1)..' / 4')
 elseif kind=='PrisonClose' then modal.Visible=false
 elseif kind=='Progress' then
  if progressTween then progressTween:Cancel() end
  progress.Visible=data~=false
  if data then progress.Size=UDim2.fromOffset(300,5); progressTween=Tween:Create(progress,TweenInfo.new(data.Duration,Enum.EasingStyle.Linear),{Size=UDim2.fromOffset(0,5)}); progressTween:Play(); notify(data.Text) end
 elseif kind=='Lift' then
  clear(data.Name:upper())
  paragraph('You are on floor '..data.Floor..'. Select a landing.')
  for floor=1,data.Floors do row('Floor '..floor,function() event:FireServer('RideLift',{Floor=floor}); modal.Visible=false end) end
 elseif kind=='Market' then
  clear('BACKROOM EXCHANGE')
  paragraph('Cash only. Sell stolen goods at the salvage counter. Owned equipment returns after respawn; consumed medkits must be replaced.')
  row('Ammo box · 12 rounds / $30',function() event:FireServer('BuyAmmo') end)
  for _,item in {{'Knife',55},{'Crowbar',90},{'Medkit',70}} do row(item[1]..'  /  $'..item[2],function() event:FireServer('Buy',{Item=item[1]}) end) end
 elseif kind=='Bank' then
  clear('CHARM CITY CREDIT')
  paragraph('Banked money is protected from player robberies. Stay next to the ATM to make a transaction.')
  local amount=input('Enter a whole dollar amount')
  row('Deposit cash',function() event:FireServer('Bank',{Mode='Deposit',Amount=tonumber(amount.Text)}) end)
  row('Withdraw cash',function() event:FireServer('Bank',{Mode='Withdraw',Amount=tonumber(amount.Text)}) end)
 elseif kind=='Offer' then
  clear('ITEM OFFER')
  paragraph('@'..data.Seller..' offers '..data.Item..' for $'..data.Price..'. Offer expires in 20 seconds. Stay nearby to complete the trade.')
  row('Accept and pay $'..data.Price,function() event:FireServer('Accept'); modal.Visible=false end)
  row('Decline',function() event:FireServer('Decline'); modal.Visible=false end)
 elseif kind=='Shot' then
  local distance=(data.To-data.From).Magnitude
  local beam=make('Part',{Name='ShotTracer',Anchored=true,CanCollide=false,CanQuery=false,CanTouch=false,Material=Enum.Material.Neon,Color=gold,Size=Vector3.new(0.045,0.045,distance),CFrame=CFrame.lookAt((data.From+data.To)/2,data.To)},workspace)
  Debris:AddItem(beam,0.07)
 elseif kind=='Job' then
  if jobMarker then jobMarker:Destroy(); jobMarker=nil end
  if data then
   local a=make('Part',{Anchored=true,CanCollide=false,CanQuery=false,CanTouch=false,Transparency=1,Position=data.Position+Vector3.new(0,8,0),Size=Vector3.one},workspace)
   local bb=make('BillboardGui',{Size=UDim2.fromOffset(180,60),AlwaysOnTop=true},a)
   local l=text(bb,'▼ DELIVERY\n'..data.Text,UDim2.fromScale(1,1),UDim2.new(),16,gold); l.TextXAlignment=Enum.TextXAlignment.Center
   jobMarker=a
  end
 end
end)
local function weapon()
 local c=p.Character; return c and c:FindFirstChildOfClass('Tool')
end
local function fire()
 if modal.Visible then return end
 local t=weapon(); if not t then return end
 if t.Name=='Phone' and openPhone then openPhone() elseif t.Name=='Pistol' then event:FireServer('Shoot',{Position=mouse.Hit.Position}) elseif t.Name=='Bat' or t.Name=='Knife' then event:FireServer('Swing',{Position=mouse.Hit.Position}) elseif t.Name=='Medkit' then event:FireServer('Use') end
end
local connectedTools=setmetatable({},{__mode='k'})
local function connectTool(v)
 if v.Name=='Phone' and openPhone then task.defer(function() if v.Parent==p.Character then openPhone() end end) end
 if v:IsA('Tool') and not connectedTools[v] then connectedTools[v]=v.Activated:Connect(fire) end
end
local function character(c)
 c.ChildAdded:Connect(connectTool)
 for _,v in c:GetChildren() do connectTool(v) end
end
p.CharacterAdded:Connect(character); if p.Character then character(p.Character) end
UIS.InputBegan:Connect(function(key,processed)
 if processed then return end
 if key.KeyCode==Enum.KeyCode.H then event:FireServer('Surrender')
 elseif key.KeyCode==Enum.KeyCode.T then playersMenu()
 elseif key.KeyCode==Enum.KeyCode.P and openPhone then openPhone()
 elseif key.KeyCode==Enum.KeyCode.R then event:FireServer('Reload')
 elseif key.KeyCode==Enum.KeyCode.Escape then modal.Visible=false; event:FireServer('Cancel') end
end)
local function bind(name,label,pos,fn)
 CAS:BindAction(name,function(_,phase) if phase==Enum.UserInputState.Begin then fn() end end,true)
 CAS:SetTitle(name,label); CAS:SetPosition(name,pos)
end
bind('NorthsidePlayers','Players',UDim2.new(1,-80,0.4,0),playersMenu)
bind('NorthsideHands','Hands up',UDim2.new(1,-160,0.4,0),function() event:FireServer('Surrender') end)
bind('NorthsideReload','Reload',UDim2.new(1,-80,0.6,0),function() event:FireServer('Reload') end)
Run.RenderStepped:Connect(function()
 local t=weapon()
 local hum=p.Character and p.Character:FindFirstChildOfClass('Humanoid')
 if hum then
  local seat=hum.SeatPart; local fuel=seat and seat.Parent:GetAttribute('Fuel')
  vital.Text='Health '..math.ceil(hum.Health)..' / '..math.ceil(hum.MaxHealth)..(fuel and '    Fuel '..fuel..'%' or '')
  healthFill.Size=UDim2.fromScale(math.clamp(hum.Health/math.max(1,hum.MaxHealth),0,1),1)
 end
 ammo.Text=t and t.Name=='Pistol' and (t:GetAttribute('Reloading') and 'RELOADING' or tostring(t:GetAttribute('Ammo') or 0)..' loaded  ·  '..tostring(p:GetAttribute('ReserveAmmo') or 0)..' spare') or ''
 local sentence=p:GetAttribute('CustodyUntil') or 0
 if sentence>0 then
  status.Text='Patapsco  '..math.max(0,sentence-math.floor(workspace:GetServerTimeNow()))..'s    Bail $'..(p:GetAttribute('Bail') or 0)
 elseif state and state.Heat then status.Text='Wanted '..state.Heat..'/5   •   Goods '..state.Loot end
end)
local city=workspace:WaitForChild('Baltimore')
local function setClock()
 local minutes=city:GetAttribute('CityMinute') or 864
 local hour=math.floor(minutes/60);local day=({'MON','TUE','WED','THU','FRI','SAT','SUN'})[city:GetAttribute('CityDay') or 1]
 clockText.Text=string.format('BALTIMORE    /    %s   %d:%02d %s',day,(hour+11)%12+1,minutes%60,hour<12 and 'AM' or 'PM')
end
setClock();city:GetAttributeChangedSignal('CityMinute'):Connect(setClock)
local mapDot
local function showMap()
 clear('NORTHSIDE STREET MAP')
 local map=make('Frame',{Size=UDim2.new(1,-6,0,274),BackgroundColor3=Color3.fromRGB(55,80,71),BorderSizePixel=0,ClipsDescendants=true},content)
 local function location(x,z) return UDim2.fromScale((x+790)/1520,(z+605)/1705) end
 local function bar(size,position,color)
  return make('Frame',{Size=size,Position=position,BackgroundColor3=color,BorderSizePixel=0},map)
 end
 bar(UDim2.fromScale(1,50/1705),UDim2.new(),Color3.fromRGB(54,121,141))
 for _,x in {-660,-450,-240,0,240,450,660} do bar(UDim2.fromScale(.009,1500/1705),location(x,-460),Color3.fromRGB(142,151,138)) end
 bar(UDim2.fromScale(.008,640/1705),location(-734,-210),Color3.fromRGB(142,151,138))
 for _,z in {-460,-210,0,210,430,610,830,1040} do bar(UDim2.fromScale(1320/1520,.009),location(-660,z),Color3.fromRGB(142,151,138)) end
 for _,v in {{'INNER HARBOR',0,-341},{'LANVALE',-480,-96},{'ROWHOMES',0,-98},{'EASTGATE',510,-100},{'COMMUNITY',145,67},{'BROADWAY',515,104},{'FREIGHT',110,281},{'MADISON',-96,519},{'FRANKLIN',-510,780},{'DOWNTOWN',0,845},{'HARBOR EAST',413,-492},{'HARBOR VIEW',525,790}} do
  local l=text(map,v[1],UDim2.fromOffset(84,18),location(v[2],v[3]),10)
  l.AnchorPoint=Vector2.new(.5,.5); l.TextXAlignment=Enum.TextXAlignment.Center; l.TextStrokeTransparency=.35
 end
 mapDot=bar(UDim2.fromOffset(10,10),UDim2.new(),gold); mapDot.AnchorPoint=Vector2.new(.5,.5)
 make('UICorner',{CornerRadius=UDim.new(1,0)},mapDot)
 local root=p.Character and p.Character:FindFirstChild('HumanoidRootPart')
 if root then mapDot.Position=location(root.Position.X,root.Position.Z) end
 paragraph('Gold dot · your location. North is up. The apartment courts have open galleries and stairs at one end of each building.')
end
button(gui,'MAP',UDim2.fromOffset(82,34),UDim2.new(1,-100,0,58),showMap)
Run.Heartbeat:Connect(function()
 if modal.Visible and mapDot and mapDot.Parent then
  local root=p.Character and p.Character:FindFirstChild('HumanoidRootPart')
  if root then mapDot.Position=UDim2.fromScale(math.clamp((root.Position.X+790)/1520,0,1),math.clamp((root.Position.Z+605)/1705,0,1)) end
 end
end)
local function jobOffer()
 for _,job in catalog do if job.Id==p:GetAttribute('Employment') then return job end end
end
local function jobBoard()
 clear('JOB APPLICATIONS')
 for _,job in catalog do
  local prefix=job.Illegal and 'Off-book' or 'Payroll'
  row(job.Title..'  ·  $'..job.Pay..'  ·  '..prefix,function()
   clear(job.Title:upper())
   if job.Id=='barber' then paragraph('08:00?22:00. Sign in at Juniper Barber. Each requested haircut pays $30, and your shift stays open for the next customer.') else paragraph((job.Start and string.format('%02d:00?%02d:00. ',job.Start,job.Close) or 'All hours. ')..job.Employer..' pays $'..job.Pay..' for each completed shift. '..job.Stops[1][2]..', then '..job.Stops[2][2]..'.'..(job.Illegal and ' Completing this contract raises your wanted level.' or '')) end
   row('Apply for this role',function() event:FireServer('ApplyJob',{Role=job.Id}); openPhone() end)
   row('Back to listings',jobBoard)
  end)
 end
end
local lifeApps=require(game:GetService('ReplicatedStorage'):WaitForChild('LifeUI'))(p,event,modal,title,clear,row,paragraph,notify)
openPhone=function()
 clear('CITY PHONE')
 local role=jobOffer()
 local taskText=p:GetAttribute('ShiftTask') or ''
 paragraph('Cash $'..(p:GetAttribute('Cash') or 0)..'   •   Bank $'..(p:GetAttribute('Bank') or 0)..'\nLifetime job pay $'..(p:GetAttribute('Wages') or 0)..'   •   '..(role and role.Title or 'Unemployed'))
 if taskText~='' then
  paragraph(taskText)
  row('Close phone and follow marker',function() modal.Visible=false end)
  row('Cancel this shift',function() event:FireServer('CancelShift') end)
 elseif role then
  row('Start shift  ·  $'..role.Pay,function() event:FireServer('StartShift') end)
  row('Leave '..role.Employer,function() event:FireServer('Resign') end)
 end
 if p:GetAttribute('NeedsCharacter') then row('Create your character',retailUI.creator) end
 row('Party supplies',retailUI.bag);row('Job applications',jobBoard); lifeApps()
 row('City map',showMap)
 row('Pay or trade with a nearby player',playersMenu)
end
for _,attr in {'Employment','ShiftTask','Wages','Cash','Bank'} do
 p:GetAttributeChangedSignal(attr):Connect(function()
  if modal.Visible and title.Text=='CITY PHONE' then openPhone() end
 end)
end
button(gui,'PHONE',UDim2.fromOffset(82,34),UDim2.new(1,-100,0,98),openPhone)
button(gui,'GUIDE',UDim2.fromOffset(82,34),UDim2.new(1,-100,0,18),function()
 clear('WELCOME TO NORTHSIDE')
 paragraph('A Baltimore-inspired neighborhood RP. Start with $500. Community center and credit union are safe zones. This is fictional, non-graphic gameplay.')
 paragraph('On the waterfront, visit Seven Foot Knoll Lighthouse. Board USS Constellation from the eastern timber pier. Find the Douglass and Marshall mural inside Pier 8 Maritime Gallery.')
 paragraph('E / tap prompt: interact. H: surrender. T: nearby players and transactions. Equip pistol and click/tap to fire; R reloads. Hold E on marked registers or lockboxes to start a timed robbery.')
 paragraph('Harbor Freight, south of Harbor Way: black market and stolen-goods buyer. Knife $55, crowbar $90, medkit $70. Eastern Outfitters sells sidearms for Robux. Union Athletics sells bats for $80. A crowbar is required for house lockboxes.')
 paragraph('Community center: courier jobs ($90 each). Credit union: deposit and withdraw. Clinic: treatment $50. Death costs up to $75 and loses stolen goods.')
 paragraph('Wanted level fades over time. Player robbery takes 8 seconds and at most 25% of cash, capped at $200. The same player is protected from another robbery for 5 minutes.')
 paragraph('Use Drive at a parked vehicle. Fuel drops with distance. Park at a dispenser to fill up for $1 per 5%. Use movement controls to steer, accelerate and reverse. Jump to exit. The quay is north of Monument Street, Lanvale Courts is west, and Eastgate Terrace is east.')
end)
p:GetAttributeChangedSignal('NeedsCharacter'):Connect(function() if p:GetAttribute('NeedsCharacter') then retailUI.creator() end end)
if p:GetAttribute('NeedsCharacter') then task.defer(retailUI.creator) end
event:FireServer('Ready')
notify('Open PHONE to apply for work. MAP shows downtown, the housing courts and the harbor.')
