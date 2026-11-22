local Players=game:GetService('Players')
local UIS=game:GetService('UserInputService')
local CAS=game:GetService('ContextActionService')
local Run=game:GetService('RunService')
local Tween=game:GetService('TweenService')
local Debris=game:GetService('Debris')
local p=Players.LocalPlayer
local event=game:GetService('ReplicatedStorage'):WaitForChild('CityAction')
-- The game exposes its own nearby-player roster. The default leaderboard covers the phone and creator controls.
task.spawn(function()
 for _=1,12 do
  if pcall(function() game:GetService('StarterGui'):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList,false) end) then break end
  task.wait(.25)
 end
end)
local mouse=p:GetMouse()
local openPhone,showGuide,handset
local catalog=require(game:GetService('ReplicatedStorage'):WaitForChild('WorkCatalog'))
local itemCards=require(game.ReplicatedStorage:WaitForChild('ItemCard'))
local itemCatalog=require(game.ReplicatedStorage:WaitForChild('ItemCatalog'))
local gui=Instance.new('ScreenGui'); gui.Name='NorthsideHUD'; gui.DisplayOrder=12; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=false; gui.Parent=p:WaitForChild('PlayerGui')
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
gui.Enabled=p.Character~=nil
p.CharacterAdded:Connect(function() gui.Enabled=true end)
local theme=require(game.ReplicatedStorage:WaitForChild('UITheme'))
local dark=theme.Background; local cream=theme.Text; local gold=theme.Accent
local function make(class,props,parent)
 local v=Instance.new(class); for k,val in props do v[k]=val end; v.Parent=parent; return v
end
local function text(parent,value,size,pos,fontSize,color)
 return make('TextLabel',{Text=value,Size=size,Position=pos,TextSize=fontSize or 16,TextColor3=color or cream,BackgroundTransparency=1,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true},parent)
end
local function button(parent,value,size,pos,fn)
 local b=make('TextButton',{Text=value,Size=size,Position=pos,BackgroundColor3=theme.Surface,TextColor3=cream,TextSize=14,Font=theme.BodyFont,AutoButtonColor=true,BorderSizePixel=0,Selectable=true},parent)
 make('UICorner',{CornerRadius=UDim.new(0,3)},b); b.Activated:Connect(fn); return b
end
local city=workspace:WaitForChild('Baltimore')
local hud=require(game.ReplicatedStorage:WaitForChild('StreetHUD'))(gui,make,text,city)
local notice=text(gui,'',UDim2.new(0.8,0,0,60),UDim2.fromScale(0.1,0.75),18)
notice.TextXAlignment=Enum.TextXAlignment.Center; notice.TextStrokeTransparency=0.3
local noticeId=0
local function notify(s)
 noticeId+=1; local id=noticeId; notice.Text=s
 task.delay(6,function() if noticeId==id then notice.Text='' end end)
end
local ammo=text(gui,'',UDim2.fromOffset(200,40),UDim2.new(1,-220,1,-110),22,gold)
local progress=make('Frame',{Size=UDim2.fromOffset(300,5),Position=UDim2.new(0.5,-150,0.73,0),BackgroundColor3=gold,BorderSizePixel=0,Visible=false},gui)
local progressTween
local modal=make('Frame',{Size=UDim2.new(1,-32,1,-82),Position=UDim2.fromOffset(16,64),BackgroundColor3=dark,Visible=false,BorderSizePixel=0},gui)
modal.ZIndex=20
make('UISizeConstraint',{MaxSize=Vector2.new(350,460)},modal)
make('UICorner',{CornerRadius=UDim.new(0,4)},modal)
local title=text(modal,'',UDim2.new(1,-70,0,40),UDim2.fromOffset(16,8),22,cream);title.Font=theme.TitleFont
local content=make('ScrollingFrame',{Size=UDim2.new(1,-30,1,-65),Position=UDim2.fromOffset(15,58),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=4,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new()},modal)
make('UIListLayout',{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},content)
local closeButton=button(modal,'×',UDim2.fromOffset(35,35),UDim2.new(1,-48,0,12),function() modal.Visible=false end)
closeButton.Name='Close'
handset=require(game.ReplicatedStorage:WaitForChild('Handset'))(gui,modal,title,content,closeButton,make,text,button,function() openPhone() end)
if UIS.TouchEnabled then handset.launcher.Position=UDim2.new(1,-54,0,106) end
local order=0
local identityModule=game.ReplicatedStorage:WaitForChild('BrandIdentity')
local identities=require(identityModule)
local brandAssets={['store-emblems-a']=identityModule:GetAttribute('store-emblems-a'),['store-emblems-b']=identityModule:GetAttribute('store-emblems-b')}
local storeScreens={['FUEL MART']=true,['EASTERN OUTFITTERS']=true,['UNION ATHLETICS']=true,['SHOP CLOTHING']=true,
 ['BARBER CHAIR']=true,['CUT & COLOR']=true,['CHARM CITY CREDIT']=true,['BACKROOM EXCHANGE']=true}
local function shopHeading()
 local root=p.Character and p.Character:FindFirstChild('HumanoidRootPart');if not root then return end
 local nearest,distance=nil,65
 for _,site in city:GetDescendants() do
  if site:IsA('Model') and site:GetAttribute('RetailBrandKey') then
   local floor=site:FindFirstChild('Shop floor') or site:FindFirstChild('Floor') or site:FindFirstChild('Hall floor') or site:FindFirstChild('Terrazzo floor') or site:FindFirstChild('Tile floor')
   if floor then local d=(root.Position-floor.Position).Magnitude;if d<distance then nearest=site;distance=d end end
  end
 end
 if not nearest then return end
 local panel=make('Frame',{Name='Shop identity',Size=UDim2.new(1,-6,0,70),BackgroundColor3=theme.Surface,BorderSizePixel=0,LayoutOrder=0},content)
 local emblem=identities.image(panel,nearest:GetAttribute('RetailBrandKey'),brandAssets)
 emblem.Size=UDim2.fromOffset(64,64);emblem.Position=UDim2.fromOffset(3,3)
 local wordmark=text(panel,nearest:GetAttribute('RetailBrand'),UDim2.new(1,-83,1,-10),UDim2.fromOffset(76,5),17,cream)
 wordmark.Font=theme.TitleFont
end
local function clear(name)
 if not modal.Visible or title.Text~=name then content.CanvasPosition=Vector2.zero end
 for _,v in content:GetChildren() do if not v:IsA('UIListLayout') then v:Destroy() end end
 title.Text=name; modal.Visible=true; order=0
 if storeScreens[name] then shopHeading() end
end
local function row(s,fn)
 order+=1; local b=button(content,s,UDim2.new(1,-6,0,44),UDim2.new(),fn); b.LayoutOrder=order
 b.TextXAlignment=Enum.TextXAlignment.Left;b.TextWrapped=true
 make('UIPadding',{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10)},b)
 local function focus() b.BackgroundColor3=cream;b.TextColor3=dark end
 local function blur() b.BackgroundColor3=theme.Surface;b.TextColor3=cream end
 b.MouseEnter:Connect(focus);b.SelectionGained:Connect(focus);b.MouseLeave:Connect(blur);b.SelectionLost:Connect(blur)
 return b
end
local function paragraph(s)
 order+=1; local l=text(content,s,UDim2.new(1,-6,0,22),UDim2.new(),14); l.AutomaticSize=Enum.AutomaticSize.Y; l.LayoutOrder=order; return l
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
 paragraph('Cash $'..tostring(p:GetAttribute('Cash') or 0)..'   ·   Bank $'..tostring(p:GetAttribute('Bank') or 0))
 row('Raise hands',function() event:FireServer('Surrender');modal.Visible=false end)
 paragraph('Select a player to pay, trade, or rob. Robbery requires an equipped pistol, a surrendered target, and no safe zone.')
 local count=0; local root=p.Character and p.Character:FindFirstChild('HumanoidRootPart')
 for _,other in Players:GetPlayers() do
  local r=other.Character and other.Character:FindFirstChild('HumanoidRootPart')
  if other~=p and root and r and (root.Position-r.Position).Magnitude<=30 then count+=1; row(other.DisplayName..'  (@'..other.Name..')',function() playerDetail(other) end) end
 end
 if count==0 then paragraph('No players nearby. Multiplayer actions require a second player.'); end
end
local bearing=require(game.ReplicatedStorage:WaitForChild('JobBearing'))
local jobMarker
local shopRoute=false
local updateTrail=require(game.ReplicatedStorage.StreetTrail)()
local nextTrail=0
local radarTarget
local firstJobOverride
local routeCard=make('Frame',{Name='JobDirections',AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-66),Size=UDim2.new(.65,0,0,44),BackgroundColor3=dark,BackgroundTransparency=.1,Visible=false,BorderSizePixel=0},gui)
make('UISizeConstraint',{MaxSize=Vector2.new(360,44)},routeCard)
make('UICorner',{CornerRadius=UDim.new(0,7)},routeCard)
local arrow=text(routeCard,'↑',UDim2.fromOffset(30,30),UDim2.fromOffset(7,7),22,gold)
arrow.TextXAlignment=Enum.TextXAlignment.Center
local routeText=text(routeCard,'',UDim2.new(1,-47,1,0),UDim2.fromOffset(42,0),13,cream)
local function showPickup()
 if firstJobOverride~=nil then return firstJobOverride end
 return p:GetAttribute('ShowFirstJob')==true
end
Run.RenderStepped:Connect(function()
 local target=jobMarker and jobMarker:GetAttribute('Target') or (shopRoute and city:GetAttribute('OutfittersDesk')) or (showPickup() and city:GetAttribute('CourierDesk'))
 local root=p.Character and p.Character:FindFirstChild('HumanoidRootPart')
 local camera=workspace.CurrentCamera
 routeCard.Visible=typeof(target)=='Vector3' and root~=nil and camera~=nil and not modal.Visible and (p:GetAttribute('CustodyUntil') or 0)==0
 radarTarget=target
 if os.clock()>=nextTrail then
  nextTrail=os.clock()+.12
  updateTrail(root,routeCard.Visible and target or nil,root~=nil and not modal.Visible and (p:GetAttribute('CustodyUntil') or 0)==0)
 end
 if not routeCard.Visible then return end
 local angle,distance=bearing(camera.CFrame.LookVector,target-root.Position)
 arrow.Rotation=angle
 local objective=jobMarker and jobMarker:GetAttribute('Objective') or shopRoute and 'River Pro Outfitters · sales counter' or 'Community Center · pick up a $90 delivery'
 routeText.Text=objective..'\n'..(distance<=9 and 'Use the nearby prompt' or math.ceil(distance)..' studs')
end)
event.OnClientEvent:Connect(function(kind,data)
 if handset.isOpen() and table.find({'Mart','GunStore','Market','Bank','BailDesk','Barber','Clothing','Sporting','Club','Lift','Residence','LightRun','PartyInvite','Offer'},kind) then handset.reset() end
 if kind=='GunStore' then shopRoute=false end
 if retailUI.handle(kind,data) then return end
 if kind=='Notice' then notify(data)
 elseif kind=='State' then state=data; hud.wallet.Text='$'..tostring(data.Cash)
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
  for _,key in {'Ammo','Knife','Crowbar','Medkit'} do
   local entry=itemCatalog[key]
   itemCards.decorate(row('',function() if key=='Ammo' then event:FireServer('BuyAmmo') else event:FireServer('Buy',{Item=key}) end end),entry.Icon,entry.Name,entry.Description,'$'..entry.Price)
  end
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
   shopRoute=false; firstJobOverride=false
   a:SetAttribute('Target',data.Position)
   a:SetAttribute('Objective',data.Text)
   local bb=make('BillboardGui',{Size=UDim2.fromOffset(180,60),AlwaysOnTop=true},a)
   local l=text(bb,'▼ '..data.Text,UDim2.fromScale(1,1),UDim2.new(),16,gold); l.TextXAlignment=Enum.TextXAlignment.Center
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
 if processed or not p.Character then return end
 if key.KeyCode==Enum.KeyCode.H then event:FireServer('Surrender')
 elseif key.KeyCode==Enum.KeyCode.T then playersMenu()
 elseif (key.KeyCode==Enum.KeyCode.P or key.KeyCode==Enum.KeyCode.DPadUp) and openPhone then
  if handset.isOpen() then modal.Visible=false else openPhone() end
 elseif key.KeyCode==Enum.KeyCode.R then event:FireServer('Reload')
 elseif key.KeyCode==Enum.KeyCode.Escape then modal.Visible=false; event:FireServer('Cancel') end
end)
local function bind(name,label,pos,fn)
 CAS:BindAction(name,function(_,phase) if phase==Enum.UserInputState.Begin then fn() end end,true)
 CAS:SetTitle(name,label); CAS:SetPosition(name,pos)
end
local reloadBound=false
local lastHud=0
Run.Heartbeat:Connect(function()
 if os.clock()-lastHud<.1 then return end
 lastHud=os.clock()
 local t=weapon()
 local character=p.Character
 local hum=character and character:FindFirstChildOfClass('Humanoid')
 local root=character and character:FindFirstChild('HumanoidRootPart')
 if root and hum then hud.update(root,hum,radarTarget) end
 local armed=t and t.Name=='Pistol'
 if UIS.TouchEnabled then
  local needsReload=armed==true and not modal.Visible
  if needsReload~=reloadBound then
   reloadBound=needsReload
   if needsReload then bind('NorthsideReload','Reload',UDim2.new(1,-90,.55,0),function() event:FireServer('Reload') end)
   else CAS:UnbindAction('NorthsideReload') end
  end
 end
 ammo.Text=armed and (t:GetAttribute('Reloading') and 'RELOADING' or tostring(t:GetAttribute('Ammo') or 0)..' / '..tostring(p:GetAttribute('ReserveAmmo') or 0)) or ''
 local sentence=p:GetAttribute('CustodyUntil') or 0
 if sentence>0 then
  hud.status.Text='Custody '..math.max(0,sentence-math.floor(workspace:GetServerTimeNow()))..'s   Bail $'..(p:GetAttribute('Bail') or 0)
 else
  local heat=math.clamp(state.Heat or 0,0,5)
  local goods=state.Loot or 0
  local contact=p:GetAttribute('PoliceContact') or ''
  hud.status.Text=(goods>0 and ('Goods '..goods..'  ') or '')..(heat>0 and ((contact~='' and contact..'  ' or '')..string.rep('★',heat)) or '')
 end
end)
local function setClock()
 local minutes=city:GetAttribute('CityMinute') or 864
 local hour=math.floor(minutes/60)
 local day=({'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'})[city:GetAttribute('CityDay') or 1]
 handset.clock(string.format('%d:%02d %s',(hour+11)%12+1,minutes%60,hour<12 and 'AM' or 'PM'),day)
end
setClock();city:GetAttributeChangedSignal('CityMinute'):Connect(setClock);city:GetAttributeChangedSignal('CityDay'):Connect(setClock)
local compass=require(game.ReplicatedStorage:WaitForChild('MapCompass'))
local mapPin,mapGoal
local function location(x,z)
 return UDim2.fromScale(compass.project(x,z))
end
local function locateResident()
 if not modal.Visible or not mapPin or not mapPin.Parent then return end
 local char=p.Character
 local root=char and char:FindFirstChild('HumanoidRootPart')
 if not root then return end
 local human=char:FindFirstChildOfClass('Humanoid')
 local look=((human and human.SeatPart) or root).CFrame.LookVector
 mapPin.Position=location(root.Position.X,root.Position.Z)
 mapPin.Rotation=compass.heading(look.X,look.Z)
 mapGoal.Visible=typeof(radarTarget)=='Vector3'
 if mapGoal.Visible then mapGoal.Position=location(radarTarget.X,radarTarget.Z) end
end
local function showMap()
 clear('CITY MAP')
 local map=make('Frame',{Size=UDim2.new(1,-6,0,276),BackgroundColor3=Color3.fromRGB(52,71,68),BorderSizePixel=0,ClipsDescendants=true},content)
 local bounds=compass.bounds
 make('Frame',{Size=UDim2.fromScale(1,50/bounds.depth),BackgroundColor3=Color3.fromRGB(50,108,135),BorderSizePixel=0},map)
 local roads=game:GetService('HttpService'):JSONDecode(city:GetAttribute('RadarRoads') or '[]')
 for _,r in roads do
  make('Frame',{AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromScale(r[3]/bounds.width,r[4]/bounds.depth),Position=location(r[1],r[2]),BackgroundColor3=Color3.fromRGB(143,153,146),BorderSizePixel=0},map)
 end
 for _,v in {{'INNER HARBOR',-160,-345},{'LANVALE',-480,-96},{'EASTGATE',510,-100},{'FREIGHT',110,281},{'MADISON',-96,519},{'FRANKLIN',-510,780},{'DOWNTOWN',20,870}} do
  local label=text(map,v[1],UDim2.fromOffset(77,17),location(v[2],v[3]),10)
  label.AnchorPoint=Vector2.new(.5,.5);label.TextXAlignment=Enum.TextXAlignment.Center;label.TextStrokeTransparency=.24
 end
 local north=text(map,'N ↑',UDim2.fromOffset(31,18),UDim2.fromOffset(5,2),12);north.TextStrokeTransparency=.2
 mapGoal=make('Frame',{Name='Destination',Size=UDim2.fromOffset(10,10),Rotation=45,AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=gold,BorderSizePixel=0,ZIndex=4,Visible=false},map)
 make('UIStroke',{Thickness=2,Color=Color3.fromRGB(57,42,21)},mapGoal)
 mapPin=compass.pin(make,map)
 locateResident()
 paragraph('▲  You, facing your direction of travel.   ◆  Active destination.')
end
hud.tap.Activated:Connect(showMap)
UIS.InputBegan:Connect(function(key,handled)
 if handled or key.KeyCode~=Enum.KeyCode.M or UIS:GetFocusedTextBox() then return end
 if modal.Visible and mapPin and mapPin.Parent then modal.Visible=false else showMap() end
end)
Run.Heartbeat:Connect(locateResident)
local function jobOffer()
 for _,job in catalog do if job.Id==p:GetAttribute('Employment') then return job end end
end
local function jobBoard()
 clear('JOB APPLICATIONS')
 for _,job in catalog do
  local prefix=job.Illegal and 'Off-book' or 'Payroll'
  row(job.Title..'  ·  $'..job.Pay..'  ·  '..prefix,function()
   clear(job.Title:upper())
   if job.Id=='barber' then paragraph('08:00?22:00. Sign in at Short Notice Cuts on Juniper. Each requested haircut pays $30, and your shift stays open for the next customer.') else paragraph((job.Start and string.format('%02d:00?%02d:00. ',job.Start,job.Close) or 'All hours. ')..job.Employer..' pays $'..job.Pay..' for each completed shift. '..job.Stops[1][2]..', then '..job.Stops[2][2]..'.'..(job.Illegal and ' Completing this contract raises your wanted level.' or '')) end
   row('Apply for this role',function() event:FireServer('ApplyJob',{Role=job.Id}); openPhone() end)
   row('Back to listings',jobBoard)
  end)
 end
end
local lifeApps=require(game:GetService('ReplicatedStorage'):WaitForChild('LifeUI'))(p,event,modal,title,clear,row,paragraph,notify)
local function workApp()
 clear('WORK')
 local role=jobOffer()
 local taskText=p:GetAttribute('ShiftTask') or ''
 paragraph((role and role.Title or 'Unemployed')..'  ·  Lifetime pay $'..(p:GetAttribute('Wages') or 0))
 if taskText~='' then
  paragraph(taskText)
  row('Close phone and follow marker',function() modal.Visible=false end)
  row('Cancel this shift',function() event:FireServer('CancelShift') end)
 elseif role then
  row('Start shift  ·  $'..role.Pay,function() event:FireServer('StartShift') end)
  row('Leave '..role.Employer,function() event:FireServer('Resign') end)
 end
 row('Job applications',jobBoard)
end
openPhone=function()
 clear('CITY PHONE')
 handset.start()
 local rgb=Color3.fromRGB
 handset.draw({
  {'Work',workApp,rgb(195,127,65)},{'City map',showMap,rgb(58,132,104)},{'My bag',lifeApps.bag,rgb(144,92,141)},
  {'My home',lifeApps.homes,rgb(65,116,157)},{'Pay / trade',playersMenu,rgb(71,139,114)},{'Dispatch',lifeApps.dispatch,rgb(182,83,75)},
  {'Party supplies',retailUI.bag,rgb(160,99,155)},{'Servers',function() modal.Visible=false;require(game.ReplicatedStorage.ServerBrowser).open() end,rgb(71,119,159)},{'Guide',showGuide,rgb(116,107,149)},
 },playersMenu)
end
showGuide=function()
 clear('WELCOME TO NORTHSIDE')
 if not jobMarker then
  row(showPickup() and 'Hide courier directions' or 'Find the $90 courier desk',function()
   shopRoute=false; firstJobOverride=not showPickup(); modal.Visible=false
  end)
  row(shopRoute and 'Hide shop directions' or 'Directions to River Pro Outfitters',function()
   shopRoute=not shopRoute; firstJobOverride=false; modal.Visible=false
  end)
 end
 paragraph('A Baltimore-inspired neighborhood RP. Start with $500. Community center and credit union are safe zones. This is fictional, non-graphic gameplay.')
 paragraph('On the waterfront, visit Seven Foot Knoll Lighthouse. Board USS Constellation from the eastern timber pier. Find the Douglass and Marshall mural inside Pier 8 Maritime Gallery.')
 paragraph('E / tap prompt: interact. H: surrender. T: nearby players and transactions. Equip pistol and click/tap to fire; R reloads. Hold E on marked registers or lockboxes to start a timed robbery.')
 paragraph('Freight Expectations, south of Harbor Way: black market and stolen-goods buyer. Knife $55, crowbar $90, medkit $70. River Pro Outfitters sells sidearms for Robux. Bench Authority sells bats for $80. A crowbar is required for house lockboxes.')
 paragraph('Community center: courier jobs ($90 each). Credit union: deposit and withdraw. Clinic: treatment $50. Death costs up to $75 and loses stolen goods.')
 paragraph('Wanted level fades over time. Player robbery takes 8 seconds and at most 25% of cash, capped at $200. The same player is protected from another robbery for 5 minutes.')
 paragraph('Use Drive to enter. Steer with movement controls. Brake with Space, LT or the Brake button. Press F or X, controller B, or tap Exit vehicle to get out.')
 paragraph('Fuel drops with distance. Park at a dispenser to refill for $1 per 5%. The quay is north of Monument Street, Lanvale Courts is west, and Eastgate Terrace is east.')
end
event:FireServer('Ready')
notify('Open your phone for jobs and the city map.')
