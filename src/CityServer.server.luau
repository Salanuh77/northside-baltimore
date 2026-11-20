-- All currency, damage, inventory and timed actions are owned by the server.
local Players=game:GetService('Players')
Players.CharacterAutoLoads=false
local RS=game:GetService('ReplicatedStorage')
local Files=require(script.Parent:WaitForChild('ResidentFiles'))
local rest=require(script.Parent:WaitForChild('HomeRest'))
local accounts={}
local DSS=game:GetService('DataStoreService')
local Run=game:GetService('RunService')
local Debris=game:GetService('Debris')
local event=RS:WaitForChild('CityAction')
local city=workspace:WaitForChild('Baltimore')
-- GetDataStore itself errors for unpublished places, even before a read/write.
local store=not Run:IsStudio() and DSS:GetDataStore('SquishyBaltimore_v1') or nil
local session=game.JobId~='' and game.JobId or 'studio'
local profiles,limits,busy,offers,robbed,jobs={},{},{},{},{},{}
local items={Bat={price=80,color=Color3.fromRGB(177,127,79)},Knife={price=55,color=Color3.fromRGB(121,128,139)},Pistol={color=Color3.fromRGB(45,48,51)},Crowbar={price=90,color=Color3.fromRGB(141,48,42)},Medkit={price=70,color=Color3.fromRGB(210,213,201)}}
local function tell(p,text) if p.Parent then event:FireClient(p,'Notice',text) end end
local function alive(p)
 local c=p and p.Character; local h=c and c:FindFirstChildOfClass('Humanoid'); local root=c and c:FindFirstChild('HumanoidRootPart')
 return root and h and h.Health>0 and root,h
end
local function near(p,pos,range) local root=alive(p); return root and (root.Position-pos).Magnitude<=range end
local function safe(p)
 local root=alive(p); if not root then return true end
 for _,z in city.SafeZones:GetChildren() do
  local v=z.CFrame:PointToObjectSpace(root.Position); local s=z.Size/2
  if math.abs(v.X)<=s.X and math.abs(v.Y)<=s.Y and math.abs(v.Z)<=s.Z then return true end
 end
 return p.Character:FindFirstChildOfClass('ForceField')~=nil
end
local sharedCounters={Barber=true,Clothing=true,Sporting=true,GunStore=true,Market=true}
local function sight(p,pos,target)
 local root=alive(p); if not root then return false end
 local origin=root.Position+Vector3.new(0,1.5,0)
 local ray=RaycastParams.new(); ray.FilterType=Enum.RaycastFilterType.Exclude
 local ignore={p.Character}
 if target and sharedCounters[target:GetAttribute('Action')] then
  for _,other in Players:GetPlayers() do if other~=p and other.Character then table.insert(ignore,other.Character) end end
 end
 if target and target:GetAttribute('Action')=='Fuel' then table.insert(ignore,city['Motor pool']) end
 ray.FilterDescendantsInstances=ignore
 local hit=workspace:Raycast(origin,pos-origin,ray)
 return not hit or target and (hit.Instance==target or hit.Instance:IsDescendantOf(target))
end
local function equipped(p,name) return p.Character and p.Character:FindFirstChild(name) and p.Character[name]:IsA('Tool') end
local function sync(p)
 local d=profiles[p]; if not d then return end
 p:SetAttribute('Cash',d.Cash); p:SetAttribute('Bank',d.Bank); p:SetAttribute('Loot',d.Loot); p:SetAttribute('Heat',d.Heat)
 for _,item in {'Water','Coffee','Sandwich','Bandage','Flashlight'} do p:SetAttribute('Bag'..item,d.Supplies[item] or 0) end
 p:SetAttribute('ReserveAmmo',d.Reserve); p:SetAttribute('Employment',d.Employment); p:SetAttribute('Wages',d.Wages)
 local stats=p:FindFirstChild('leaderstats'); if stats then stats.Cash.Value=d.Cash end
 event:FireClient(p,'State',{Cash=d.Cash,Bank=d.Bank,Loot=d.Loot,Heat=d.Heat,Items=d.Items,Stock=d.Stock,Wardrobe=d.Wardrobe,Hair=d.Look and d.Look.Hair,HairColor=d.Look and d.Look.HairColor})
end

local function givePhone(p)
 local bag=p:FindFirstChildOfClass('Backpack')
 if not bag or bag:FindFirstChild('Phone') or equipped(p,'Phone') then return end
 local phone=Instance.new('Tool'); phone.Name='Phone'; phone.CanBeDropped=false; phone.ToolTip='Jobs, wallet and city map'
 local handle=Instance.new('Part'); handle.Name='Handle'; handle.Size=Vector3.new(.85,1.45,.12); handle.Color=Color3.fromRGB(31,47,48); handle.CanCollide=false; handle.Massless=true; handle.Parent=phone
 local screen=Instance.new('SurfaceGui'); screen.Face=Enum.NormalId.Front; screen.CanvasSize=Vector2.new(120,210); screen.Parent=handle
 local display=Instance.new('TextLabel'); display.Size=UDim2.fromScale(1,1); display.Text='NORTHSIDE\n\nCITY PHONE'; display.TextSize=18; display.Font=Enum.Font.GothamBold; display.TextColor3=Color3.fromRGB(242,217,162); display.BackgroundColor3=Color3.fromRGB(30,84,81); display.Parent=screen
 phone.Parent=bag
end
local function heat(p,n)
 local d=profiles[p]
 if d then d.Heat=math.clamp(d.Heat+n,0,5); d.HeatNext=os.clock()+30; sync(p) end
end
local workService=require(script.Parent:WaitForChild('WorkService'))(city,event,profiles,jobs,sync,tell,heat)
local function tool(p,name)
 if not items[name] then return end
 local bag=p:FindFirstChildOfClass('Backpack'); if not bag then return end
 if bag:FindFirstChild(name) or equipped(p,name) then return end
 local t=Instance.new('Tool'); t.Name=name; t.CanBeDropped=false; t.RequiresHandle=true; t.ToolTip=name=='Pistol' and 'Equip, aim and fire. R to reload.' or name=='Crowbar' and 'Needed to search house lockboxes.' or 'Equip and use to heal.'
 local handle=Instance.new('Part'); handle.Name='Handle'; handle.Size=name=='Pistol' and Vector3.new(0.5,0.9,1.6) or name=='Crowbar' and Vector3.new(0.35,3,0.35) or Vector3.new(1.4,1,0.5)
 handle.Color=items[name].color; handle.Material=Enum.Material.Metal; handle.CanCollide=false; handle.Massless=true; handle.Parent=t
 if name=='Bat' or name=='Knife' then
  t.ToolTip='Equip and tap a nearby target.'
  handle.Size=name=='Bat' and Vector3.new(.24,1.05,.24) or Vector3.new(.25,.8,.32)
  handle.Color=Color3.fromRGB(79,61,52)
  local head=Instance.new(name=='Bat' and 'Part' or 'WedgePart');head.Name='Head'
  head.Size=name=='Bat' and Vector3.new(2.1,.48,.48) or Vector3.new(.12,.85,.29)
  head.Material=name=='Bat' and Enum.Material.Wood or Enum.Material.Metal;head.Color=items[name].color
  head.CanCollide=false;head.CanTouch=false;head.Massless=true
  if name=='Bat' then head.Shape=Enum.PartType.Cylinder end
  head.CFrame=handle.CFrame*CFrame.new(0,name=='Bat' and 1.52 or .8,0)*CFrame.Angles(0,0,name=='Bat' and math.pi/2 or 0)
  head.Parent=t;local weld=Instance.new('WeldConstraint');weld.Part0=handle;weld.Part1=head;weld.Parent=head
 end
 if name=='Pistol' then
  t:SetAttribute('Ammo',profiles[p].Magazine); t:SetAttribute('Reloading',false)
  require(script.Parent.PistolVisual)(t,(profiles[p].Look or {}).Armory or 'Slate compact')
 end
 t.Parent=bag
end
local function removeTool(p,name)
 for _,container in {p.Character,p:FindFirstChildOfClass('Backpack')} do
  if container then local t=container:FindFirstChild(name); if t and t:IsA('Tool') then t:Destroy() end end
 end
end
local function payload(d)
 return {Cash=d.Cash,Bank=d.Bank,Loot=d.Loot,Items=table.clone(d.Items),Supplies=table.clone(d.Supplies),Magazine=d.Magazine,Reserve=d.Reserve,Employment=d.Employment,Wages=d.Wages,CustodyUntil=d.CustodyUntil,Bail=d.Bail,Look=d.Look and table.clone(d.Look),Outfit=d.Outfit,Wardrobe=table.clone(d.Wardrobe),Stock=table.clone(d.Stock),Receipts=table.clone(d.Receipts),PendingSale=d.PendingSale and table.clone(d.PendingSale),Trades=table.clone(d.Trades),Lock=session,Lease=os.time()+150}
end
local function save(p,release)
 local account=accounts[p]
 if not account then return false end
 if release then
  local deadline=os.clock()+20
  while account.Saving and os.clock()<deadline do task.wait(.1) end
 end
 if account.Saving then return false end
 account.Saving=true
 local d=profiles[p]
 local nextState=account.State
 if d and d.Look and account.Index then nextState=Files.write(nextState,account.Index,payload(d)) else nextState=table.clone(nextState) end
 nextState.Lock=session
 if release then nextState.Lock=nil end
 nextState.Lease=release and 0 or os.time()+150
 local ok,result=true,nextState
 if store then
  ok,result=pcall(function()
   return store:UpdateAsync('u'..p.UserId,function(old)
    if not old or old.Lock~=session then return nil end
    return nextState
   end)
  end)
 end
 account.Saving=false
 if not ok or not result then
  if os.time()>account.LastSave+100 and p.Parent then p:Kick('Your save is unavailable. Rejoin to protect your progress.') end
  return false
 end
 account.State=nextState; account.LastSave=os.time()
 return true
end
require(script.Parent.ServerDirectory).start(RS.CityServers,function(p) return accounts[p] and save(p,false) end)
local function finiteInt(v,max)
 return typeof(v)=='number' and v==v and v%1==0 and v>=1 and v<=(max or 100000)
end
local function validUserId(v)
 return typeof(v)=='number' and finiteInt(math.abs(v),9007199254740991)
end
local function allowed(p)
 local t=os.clock(); local l=limits[p] or {tokens=25,time=t}; limits[p]=l
 l.tokens=math.min(25,l.tokens+(t-l.time)*12); l.time=t
 if l.tokens<1 then return false end; l.tokens-=1; return true
end
local markerIndex={}
for _,part in city:GetDescendants() do
 if part:IsA('BasePart') then
  local kind=part:GetAttribute('Action')
  if kind then markerIndex[kind]=markerIndex[kind] or {}; table.insert(markerIndex[kind],part) end
 end
end
require(script.Parent.WalkingRoutes)(city,markerIndex,jobs)
local function closest(p,kind)
 local root=alive(p); if not root then return end
 local pick,best=nil,11.001
 for _,v in markerIndex[kind] or {} do
  local distance=(root.Position-v.Position).Magnitude
  if distance<best and sight(p,v.Position,v) then pick,best=v,distance end
 end
 return pick
end
local life=require(script.Parent:WaitForChild('NeighborhoodLife'))(city,event,profiles,closest,near,sync,tell)

local retail=require(script.Parent.CityRetail)(profiles,jobs,event,closest,sync,tell,save,tool)
local lifeActions={BuySupply=true,UseSupply=true,Lease=true,ReleaseHome=true,HostParty=true,EndParty=true,InviteParty=true,PartyReply=true,LeaveParty=true,ClubMix=true}
local function cancelBusy(p)
 local b=busy[p]; if b then b.cancel=true; if b.marker then b.marker:SetAttribute('InUse',nil) end; busy[p]=nil end
end
local custody=require(script.Parent:WaitForChild('Custody'))(city,event,profiles,sync,tell,closest,function(p)
 cancelBusy(p); workService.finish(p); offers[p]=nil
end)
local respond=require(script.Parent:WaitForChild('Responders'))(city,event,profiles,jobs,sync,tell,safe,near,sight,custody.arrest,heat)
local function timed(p,marker,seconds,valid,done,message)
 if busy[p] then return tell(p,'Finish your current action first.') end
 local _,h=alive(p); if not h then return end
 local health=h.Health; local b={marker=marker}; busy[p]=b
 if marker then marker:SetAttribute('InUse',true) end
 event:FireClient(p,'Progress',{Duration=seconds,Text=message or 'Stay nearby · action in progress'})
 task.spawn(function()
  local finish=os.clock()+seconds
  while os.clock()<finish do
   if b.cancel or not p.Parent or h.Health<health or h.Health<=0 or not valid() then
    if busy[p]==b then cancelBusy(p); tell(p,'Action cancelled: stay nearby and avoid damage.'); event:FireClient(p,'Progress',false) end
    return
   end
   task.wait(0.2)
  end
  if busy[p]~=b then return end
  cancelBusy(p); event:FireClient(p,'Progress',false)
  if valid() then done() end
 end)
end
local deliveries={}
for _,p in city:GetDescendants() do if p:IsA('BasePart') and p:GetAttribute('Action')=='Delivery' then table.insert(deliveries,p) end end
local function interact(p,marker)
 local d=profiles[p]; if not d or not near(p,marker.Position,marker:GetAttribute('Reach') or 11) or not sight(p,marker.Position,marker) then return end
 local kind=marker:GetAttribute('Action')
 if kind=='BailDesk' or kind=='EscapeGame' then return custody.prompt(p,kind) end
 if (d.CustodyUntil or 0)>0 then return end
 if kind=='Door' then
  if not life.canUseDoor(p,marker) then return tell(p,'This residence is locked. The tenant can invite you from their phone.') end
  local now=os.clock(); if now<(marker:GetAttribute('DoorNext') or 0) then return end; marker:SetAttribute('DoorNext',now+0.8)
  local open=not marker:GetAttribute('Open'); marker:SetAttribute('Open',open); local closed=marker:GetAttribute('ClosedFrame') or marker.CFrame
  marker:SetAttribute('ClosedFrame',closed)
  local hinge=marker.Size.X/2
  local opened=closed*CFrame.new(-hinge,0,0)*CFrame.Angles(0,-math.pi/2,0)*CFrame.new(hinge,0,0)
  marker.CanCollide=true
  game:GetService('TweenService'):Create(marker,TweenInfo.new(.28),{CFrame=open and opened or closed}):Play()
 elseif kind=='SitHome' or kind=='RestHome' then
  local _,human=alive(p)
  if not human or not marker:IsA('Seat') or marker.Occupant or human.SeatPart then return end
  if kind=='RestHome' then
   if busy[p] or not rest.start(p,marker,human) then return end
   timed(p,marker,4,function() return marker.Occupant==human end,function()
    human.Health=math.min(human.MaxHealth,human.Health+15)
    tell(p,'You feel rested. Press jump or Get up to leave the bed.')
   end,'Resting · jump or Get up to stand')
  else marker:Sit(human)
  end
 elseif kind=='UseTap' then
  local water=marker.Parent:FindFirstChild('Running water')
  if not water or water.Transparency<1 then return end
  water.Transparency=.28
  task.delay(5,function() if water.Parent then water.Transparency=1 end end)
 elseif kind=='Cook' then
  if marker:GetAttribute('InUse') then return tell(p,'Someone is using the stove.') end
  local _,human=alive(p)
  if human then
   timed(p,marker,4,function() return near(p,marker.Position,6) and sight(p,marker.Position,marker) end,function()
    human.Health=math.min(human.MaxHealth,human.Health+20)
    tell(p,'You cooked and ate a hot meal.')
   end)
  end
 elseif kind=='Store' or kind=='Home' then
  if busy[p] or marker:GetAttribute('InUse') then return tell(p,'This location is busy.') end
  if os.time()<(marker:GetAttribute('ReadyAt') or 0) then return tell(p,'Already searched. Come back later.') end
  local needed=kind=='Store' and 'Pistol' or 'Crowbar'
  if not equipped(p,needed) then return tell(p,'Equip a '..needed..' first.') end
  local duration=kind=='Store' and 12 or 9
  if kind=='Store' then local root=alive(p);if root and not safe(p) then respond.alert(p,root.Position,'robbery') end end
  timed(p,marker,duration,function() return near(p,marker.Position,10) and sight(p,marker.Position,marker) and equipped(p,needed) and not safe(p) end,function()
   if os.time()<(marker:GetAttribute('ReadyAt') or 0) then return end
   marker:SetAttribute('ReadyAt',os.time()+180)
   if kind=='Store' then d.Cash+=225; tell(p,'Register emptied: +$225. Wanted level increased.') else d.Loot=math.min(d.Loot+1,20); tell(p,'Stolen goods collected. Sell them at Freight Expectations.') end
   heat(p,kind=='Store' and 2 or 1); sync(p)
  end)
 elseif table.find({'Market','Bank','Clothing','GunStore','Barber','Sporting'},kind) then event:FireClient(p,kind,{})
 elseif kind=='Fence' then
  if d.Loot==0 then return tell(p,'No stolen goods to sell.') end
  local amount=d.Loot*110; d.Loot=0; d.Cash+=amount; sync(p); tell(p,'Goods sold for $'..amount..'.')
 elseif kind=='Heal' then
  local _,h=alive(p); if not h or h.Health>=h.MaxHealth then return tell(p,'You are already healthy.') end
  if d.Cash<50 then return tell(p,'Treatment costs $50 cash.') end
  d.Cash-=50; h.Health=h.MaxHealth; sync(p); tell(p,'Treatment complete.')
 elseif kind=='Residence' then
  event:FireClient(p,'Residence',{Name=marker:GetAttribute('Address'),Price=marker:GetAttribute('LeasePrice') or 0,Taken=marker:GetAttribute('Tenant')~=nil})
 elseif kind=='Fuel' then life.refuel(p,marker)
 elseif kind=='Coffee' then life.handle(p,'BuySupply',{Item='Coffee'})
 elseif kind=='Mart' or kind=='Dance' or kind=='Club' then event:FireClient(p,kind,{})
 elseif kind=='Lift' then
  event:FireClient(p,'Lift',{Floors=marker.Parent:GetAttribute('Floors'),Floor=marker:GetAttribute('Floor'),Name=marker.Parent.Name})
 elseif kind=='WorkStop' then
  workService.interact(p,marker)
 elseif kind=='Job' then
  if jobs[p] then return tell(p,'Complete your active delivery first.') end
  if #deliveries==0 then return end
  local dest=deliveries[math.random(1,#deliveries)]
  p:SetAttribute('ShiftTask','Deliver to '..dest:GetAttribute('Label'))
  jobs[p]={dest=dest,earliest=os.clock()+(dest.Position-marker.Position).Magnitude/60}
  event:FireClient(p,'Job',{Position=dest.Position,Text=dest:GetAttribute('Label')}); tell(p,'Deliver the parcel to the marked mailbox. Reward: $90.')
 elseif kind=='Delivery' then
  local j=jobs[p]; if not j or j.dest~=marker then return tell(p,'Pick up a delivery at the community center.') end
  if os.clock()<j.earliest then return end
  workService.finish(p); d.Cash+=90; d.Wages+=90; sync(p); tell(p,'Delivery complete: +$90.')
 end
end
for _,marker in city:GetDescendants() do
 if marker:IsA('BasePart') and marker:GetAttribute('Action') then
  local prompt=Instance.new('ProximityPrompt'); prompt.ActionText=marker:GetAttribute('Label') or 'Interact'; prompt.ObjectText=marker.Parent:GetAttribute('RetailBrand') or marker.Parent.Name
  prompt.HoldDuration=marker:GetAttribute('Hold') or 0.5; prompt.MaxActivationDistance=marker:GetAttribute('Reach') or 10; prompt.RequiresLineOfSight=marker:GetAttribute('Action')~='Fuel' and not sharedCounters[marker:GetAttribute('Action')]; prompt.Parent=marker
  if marker:GetAttribute('SecondaryPrompt') then
   prompt.KeyboardKeyCode=Enum.KeyCode.F;prompt.GamepadKeyCode=Enum.KeyCode.ButtonY
   prompt.UIOffset=Vector2.new(0,70)
  end
  prompt.Triggered:Connect(function(p) if allowed(p) then interact(p,marker) end end)
 end
end
local function saveConfirmed(p,d)
 for _=1,4 do
  if profiles[p]~=d or d.Leaving then return false end
  if save(p,false) then return true end
  task.wait(1)
 end
 return false
end
-- The seller stores the reserved sidearm before the buyer receives it. The
-- buyer's debit, new inventory and trade receipt share one profile update.
local activeSales={}
local function reconcileSale(seller)
 local sd=profiles[seller]; local sale=sd and sd.PendingSale
 if not sale or sd.Leaving or activeSales[seller] then return end
 activeSales[seller]=true
 local buyer=Players:GetPlayerByUserId(sale.Buyer)
 local bd=buyer and profiles[buyer]
 local decided,paid=false,false
 if bd and not bd.Leaving then
  paid=bd.Trades[sale.Id]==true or Files.hasTrade(accounts[buyer].State,sale.Id)
  decided=not paid or saveConfirmed(buyer,bd)
 elseif store then
  local ok,snapshot=pcall(function()
   return store:UpdateAsync('u'..sale.Buyer,function(old)
    if not old then return nil end
    return old
   end)
  end)
  if ok and snapshot then
   paid=Files.hasTrade(Files.open(snapshot),sale.Id)
   decided=paid or not snapshot.Lock or (snapshot.Lease or 0)<os.time()
  end
 elseif Run:IsStudio() then decided=true end
 if decided and profiles[seller]==sd and not sd.Leaving and sd.PendingSale==sale then
  if paid then sd.Cash+=sale.Price; tell(seller,'Trade complete: +$'..sale.Price)
  else sd.Stock.Sidearm=(sd.Stock.Sidearm or 0)+1; sd.Items.Pistol=true; sd.Magazine=math.max(sd.Magazine,sale.Ammo);tool(seller,'Pistol');tell(seller,'Uncompleted trade returned to your inventory.') end
  sd.PendingSale=nil;sync(seller);saveConfirmed(seller,sd)
 end
 activeSales[seller]=nil
end
local function settleSidearm(seller,buyer,price)
 local sd,bd=profiles[seller],profiles[buyer]
 if sd.Trading or bd.Trading or sd.PendingSale or (sd.Stock.Sidearm or 0)<1 then return end
 sd.Trading=true;bd.Trading=true;activeSales[seller]=true
 local sale={Id=game:GetService('HttpService'):GenerateGUID(false),Buyer=buyer.UserId,Price=price,Ammo=sd.Magazine}
 sd.Stock.Sidearm-=1;sd.Items.Pistol=sd.Stock.Sidearm>0 or nil;sd.Magazine=sd.Items.Pistol and 12 or 0
 sd.PendingSale=sale;removeTool(seller,'Pistol');if sd.Items.Pistol then tool(seller,'Pistol') end;sync(seller)
 local reserved=saveConfirmed(seller,sd)
 if reserved and profiles[buyer]==bd and not bd.Leaving and not bd.Items.Pistol and bd.Cash>=price then
  bd.Cash-=price;bd.Items.Pistol=true;bd.Stock.Sidearm=(bd.Stock.Sidearm or 0)+1;bd.Magazine=sale.Ammo;bd.Trades[sale.Id]=true
  if saveConfirmed(buyer,bd) then tool(buyer,'Pistol');tell(buyer,'Sidearm trade complete.') end
  sync(buyer)
 end
 activeSales[seller]=nil
 reconcileSale(seller);sd.Trading=nil;bd.Trading=nil
end
local function join(p)
 local account
 if store then
  local ok,result
  for attempt=1,5 do
   ok,result=pcall(function()
   return store:UpdateAsync('u'..p.UserId,function(old)
    if old and old.Lock and old.Lock~=session and (old.Lease or 0)>os.time() then return nil end
    local state=Files.open(old)
    state.Lock=session;state.Lease=os.time()+150
    return state
   end)
  end)
  if ok and result or not p.Parent then break end
   if attempt<5 then task.wait(2) end
  end
  if not ok or not result then p:Kick('Your save is unavailable or open on another server. Please rejoin shortly.');return end
  account=result
 else account=Files.open(nil) end
 accounts[p]={State=account,LastSave=os.time()}
 if not p.Parent then save(p,true);accounts[p]=nil;return end
 p:SetAttribute('ResidentFiles',game.HttpService:JSONEncode(Files.list(account)))
end
local function selectFile(p,index,creating)
 local account=accounts[p]
 if not account or account.Index or not Files.valid(index) then tell(p,'Your resident list is not ready. Please try again.');return end
 local existing=account.State.Files[tostring(index)]
 if not creating and (not existing or not existing.Look) then tell(p,'Create a resident in this file first.');return end
 account.Index=index
 local result=account.State.Files[tostring(index)]
 local d={Cash=500,Bank=0,Loot=0,Items={},Supplies={},Magazine=0,Reserve=0,Employment='',Wages=0,Heat=0,LastSave=os.time(),Wardrobe={},Stock={},Receipts={},Trades={}}
 if result then
  d.Cash=math.clamp(tonumber(result.Cash) or 500,0,10000000); d.Bank=math.clamp(tonumber(result.Bank) or 0,0,10000000); d.Loot=math.clamp(tonumber(result.Loot) or 0,0,20)
  for name in items do if type(result.Items)=='table' and result.Items[name]==true then d.Items[name]=true end end
  for _,key in {'Wardrobe','Stock','Receipts','Trades'} do if type(result[key])=='table' then d[key]=result[key] end end
  d.Look=result.Look; d.Outfit=result.Outfit; d.PendingSale=result.PendingSale
  d.Stock.Sidearm=math.max(d.Items.Pistol and 1 or 0,tonumber(d.Stock.Sidearm) or 0)
  d.Magazine=d.Items.Pistol and math.clamp(math.floor(tonumber(result.Magazine) or 12),0,12) or 0
  d.Reserve=math.clamp(math.floor(tonumber(result.Reserve) or (d.Items.Pistol and 24 or 0)),0,120)
  d.Employment=workService.offers[result.Employment] and result.Employment or ''
  d.Wages=math.max(0,math.floor(tonumber(result.Wages) or 0))
  d.CustodyUntil=math.min(os.time()+120,math.max(0,math.floor(tonumber(result.CustodyUntil) or 0)))
  d.Bail=math.clamp(math.floor(tonumber(result.Bail) or 0),0,160)
  if type(result.Supplies)=='table' then
   for _,item in {'Water','Coffee','Sandwich','Bandage','Flashlight'} do d.Supplies[item]=math.clamp(math.floor(tonumber(result.Supplies[item]) or 0),0,item=='Flashlight' and 1 or 10) end
  end
 end
 d.Receipts=table.clone(account.State.Receipts or {})
 profiles[p]=d; p:SetAttribute('ResidentSlot',index);retail.setup(p,d)
 if d.PendingSale then task.defer(reconcileSale,p) end
 local stats=Instance.new('Folder'); stats.Name='leaderstats'; stats.Parent=p; local cash=Instance.new('IntValue'); cash.Name='Cash'; cash.Parent=stats
 local function character(c)
  cancelBusy(p); workService.finish(p); p:SetAttribute('Surrendered',false)
  local h=c:WaitForChild('Humanoid'); h.WalkSpeed=16
  c:WaitForChild('HumanoidRootPart'); custody.restore(p)
  retail.dress(p,d); givePhone(p); for name in d.Items do tool(p,name) end
  h.Died:Connect(function()
   cancelBusy(p); workService.finish(p); offers[p]=nil
   task.delay(Players.RespawnTime,function() if p.Parent and profiles[p]==d and p.Character==c then p:LoadCharacterAsync() end end)
   local lost=math.min(d.Cash,75); d.Cash-=lost; d.Loot=0; d.Heat=0; sync(p); tell(p,'Hospital fee: $'..lost..'. Unbanked stolen goods were lost.')
  end)
 end
 p.CharacterAdded:Connect(character)
 if d.Look then task.spawn(function() p:LoadCharacterAsync() end) end
 sync(p)
end
Players.PlayerAdded:Connect(join); for _,p in Players:GetPlayers() do task.spawn(join,p) end
Players.PlayerRemoving:Connect(function(p)
 local d=profiles[p]; if d then d.Leaving=true end
 cancelBusy(p); save(p,true); accounts[p]=nil;profiles[p]=nil; limits[p]=nil; offers[p]=nil; jobs[p]=nil; robbed[p]=nil
 for buyer,o in offers do if o.Seller==p then offers[buyer]=nil end end
end)
local naming=setmetatable({},{__mode='k'})
event.OnServerEvent:Connect(function(p,kind,data)
 if not allowed(p) or typeof(kind)~='string' then return end
 if naming[p] then return end
 local approvedName
 if kind=='CreateResident' and typeof(data)=='table' and data.Index~=nil then
  local account=accounts[p]
  if not account or account.Index or not Files.valid(data.Index) or (account.State.Files[tostring(data.Index)] and account.State.Files[tostring(data.Index)].Look) then
   tell(p,'That file is unavailable. Select a free file.');return
  end
  if not require(game.ReplicatedStorage.StreetStyle).valid(data) then tell(p,'Choose an available appearance.');return end
  naming[p]=true
  local reason
  approvedName,reason=retail.resolveName(p,data)
  naming[p]=nil
  if accounts[p]~=account or not p.Parent then return end
  if not approvedName then tell(p,reason);return end
  selectFile(p,data.Index,true)
 end
 if kind=='SelectFile' then if typeof(data)=='table' then selectFile(p,data.Index) end;return end
 if not profiles[p] then return end
 local d=profiles[p]; data=typeof(data)=='table' and data or {}
 if kind=='Ready' then sync(p); return end
 if kind=='StandFromBed' then rest.stand(p); return end
 if kind=='CreateResident' then
  local before=d.Look
  retail.handle(p,kind,data,approvedName)
  if not before and d.Look and not d.Spawning and not p.Character and profiles[p]==d then
   d.Spawning=true
   if not saveConfirmed(p,d) then
    if p.Parent then p:Kick('Your resident could not be saved. Rejoin to try again.') end
   elseif p.Parent then
    p:SetAttribute('ShowFirstJob',true)
    p:LoadCharacterAsync()
   end
  end
  return
 end
 if not alive(p) then return end
 if kind=='PostBail' or kind=='LightPress' then return custody.handle(p,kind,data) end
 if (d.CustodyUntil or 0)>0 then return end
 if kind=='Cancel' then cancelBusy(p); return end
 if kind=='Surrender' then
  cancelBusy(p); local state=not p:GetAttribute('Surrendered'); p:SetAttribute('Surrendered',state)
  local _,h=alive(p); h.WalkSpeed=state and 5 or 16; if state then h:UnequipTools() end
  tell(p,state and 'Surrendering. Nearby armed players can rob your cash. Press H to stop.' or 'Surrender ended.'); return
 end
 if p:GetAttribute('Surrendered') then return end
 if d.Trading or d.Leaving then return end
 if retail.handle(p,kind,data) then return end
 if lifeActions[kind] then life.handle(p,kind,data)
 elseif kind=='CallResponder' or kind=='DispatchList' or kind=='Assist' then respond.handle(p,kind,data)
 elseif kind=='ApplyJob' or kind=='StartShift' or kind=='CancelShift' or kind=='Resign' then
  workService.handle(p,kind,data)
 elseif kind=='RideLift' then
  local panel=closest(p,'Lift')
  if not panel or not finiteInt(data.Floor,panel.Parent:GetAttribute('Floors')) then return end
  local root,human=alive(p)
  if not root or human.SeatPart then return end
  -- Only landings belonging to the tower at the player's current panel are eligible.
  for _,pad in panel.Parent:GetChildren() do
   if pad:GetAttribute('Landing')==data.Floor then
    p.Character:PivotTo(pad.CFrame*CFrame.new(0,3.8,0))
    root.AssemblyLinearVelocity=Vector3.zero
    tell(p,panel.Parent.Name..' • floor '..data.Floor); break
   end
  end
 elseif kind=='BuyAmmo' then
  if not closest(p,'Market') and not closest(p,'GunStore') then return end
  if not d.Items.Pistol then return tell(p,'Buy a pistol first.') end
  if d.Reserve>108 then return tell(p,'Reserve capacity is 120 rounds.') end
  if d.Cash<30 then return tell(p,'Ammo costs $30 per box.') end
  d.Cash-=30; d.Reserve+=12; sync(p); tell(p,'Added 12 reserve rounds.')
 elseif kind=='Buy' then
  if data.Item=='Pistol' then return tell(p,'Sidearms are sold at River Pro Outfitters for Robux or traded by players for city cash.') end
  local retailType=data.Item=='Bat' and 'Sporting' or 'Market'
  if not items[data.Item] or not closest(p,retailType) then return end
  local item=items[data.Item]
  if d.Items[data.Item] then return tell(p,'You already own this item.') end
  if d.Cash<item.price then return tell(p,'Not enough cash.') end
  d.Cash-=item.price; d.Items[data.Item]=true; tool(p,data.Item); sync(p); tell(p,data.Item..' purchased.')
 elseif kind=='Bank' then
  if not closest(p,'Bank') or not finiteInt(data.Amount) then return end
  local n=data.Amount
  if data.Mode=='Deposit' and d.Cash>=n then d.Cash-=n; d.Bank+=n
  elseif data.Mode=='Withdraw' and d.Bank>=n then d.Bank-=n; d.Cash+=n else return tell(p,'Insufficient funds.') end
  sync(p)
 elseif kind=='Pay' or kind=='Offer' then
  if not validUserId(data.Target) or not finiteInt(data.Amount) then return end
  local target=Players:GetPlayerByUserId(data.Target); local td=target and profiles[target]
  local root=target and alive(target)
  if not td or target==p or not root or not near(p,root.Position,14) or not sight(p,root.Position,target.Character) then return tell(p,'Player must be nearby and alive.') end
  if kind=='Pay' then
   if d.Cash<data.Amount then return tell(p,'Not enough cash.') end
   d.Cash-=data.Amount; td.Cash+=data.Amount; sync(p); sync(target); tell(p,'Paid $'..data.Amount..' to @'..target.Name); tell(target,'Received $'..data.Amount..' from @'..p.Name)
  else
   if data.Item=='Pistol' and (not d.PaidTrading or not td.PaidTrading or d.PendingSale) then return tell(p,'Paid-item trading is unavailable for this pair right now.') end
   if not items[data.Item] or not d.Items[data.Item] or td.Items[data.Item] then return tell(p,'Select an owned item the buyer does not own.') end
   if offers[target] then return tell(p,'That player already has an offer pending.') end
   offers[target]={Seller=p,Item=data.Item,Price=data.Amount,Expires=os.clock()+20}
   event:FireClient(target,'Offer',{Seller=p.Name,Item=data.Item,Price=data.Amount}); tell(p,'Offer sent. It expires in 20 seconds.')
  end
 elseif kind=='Accept' or kind=='Decline' then
  local o=offers[p]; offers[p]=nil
  if kind=='Decline' or not o or os.clock()>o.Expires then return end
  local seller=o.Seller; local sd=profiles[seller]; local root=alive(seller)
  if not sd or sd.Trading or sd.Leaving or not root or not near(p,root.Position,14) or not sight(p,root.Position,seller.Character) or seller:GetAttribute('Surrendered') or not sd.Items[o.Item] or d.Items[o.Item] or d.Cash<o.Price then return tell(p,'Offer no longer valid.') end
  if o.Item=='Pistol' then
   if not d.PaidTrading or not sd.PaidTrading or sd.PendingSale then return tell(p,'Sidearm trade unavailable.') end
   settleSidearm(seller,p,o.Price); return
  end
  -- No yielding between validation and settlement: item and funds move together.
  d.Cash-=o.Price; sd.Cash+=o.Price; sd.Items[o.Item]=nil; d.Items[o.Item]=true
  if o.Item=='Pistol' then d.Magazine=sd.Magazine; sd.Magazine=0 end
  removeTool(seller,o.Item); tool(p,o.Item); sync(seller); sync(p); tell(p,'Trade complete.'); tell(seller,'Trade complete: +$'..o.Price)
 elseif kind=='RobPlayer' then
  if busy[p] or safe(p) or not equipped(p,'Pistol') or not validUserId(data.Target) then return end
  local target=Players:GetPlayerByUserId(data.Target); local td=target and profiles[target]; local root=target and alive(target)
  if not td or target==p or not root or safe(target) or not target:GetAttribute('Surrendered') or not near(p,root.Position,10) then return tell(p,'Target must surrender (H) outside a safe zone.') end
  if (robbed[target] or 0)>os.clock() then return tell(p,'That player was recently robbed.') end
  tell(target,'You are being robbed. Moving away or ending surrender cancels it.')
  timed(p,nil,8,function()
   local tr=alive(target)
   return tr and near(p,tr.Position,10) and sight(p,tr.Position,target.Character) and equipped(p,'Pistol') and not p:GetAttribute('Surrendered') and not safe(p) and not safe(target) and target:GetAttribute('Surrendered') and profiles[target]==td
  end,function()
   if (robbed[target] or 0)>os.clock() then return end
   local amount=math.min(200,math.floor(td.Cash*0.25)); td.Cash-=amount; d.Cash+=amount; robbed[target]=os.clock()+300
   sync(target); heat(p,1); tell(p,'Took $'..amount..'.'); tell(target,'Lost $'..amount..' cash. Bank funds are protected.')
  end)
 elseif kind=='Reload' then
  if not equipped(p,'Pistol') then return end
  local t=p.Character.Pistol; if t:GetAttribute('Reloading') or t:GetAttribute('Ammo')>=12 then return end
  if d.Reserve<=0 then return tell(p,'Out of reserve ammo. Freight Expectations sells 12 rounds for $30.') end
  t:SetAttribute('Reloading',true)
  task.delay(2,function()
   if not t.Parent then return end
   if profiles[p]==d and t.Parent==p.Character and d.Items.Pistol then
    local amount=math.min(12-d.Magazine,d.Reserve)
    d.Magazine+=amount; d.Reserve-=amount; t:SetAttribute('Ammo',d.Magazine); sync(p)
   end
   t:SetAttribute('Reloading',false)
  end)
 elseif kind=='Use' and equipped(p,'Medkit') and d.Items.Medkit then
  local _,h=alive(p); if h.Health>=h.MaxHealth then return end
  d.Items.Medkit=nil; removeTool(p,'Medkit'); h.Health=math.min(h.MaxHealth,h.Health+60); sync(p)
 elseif kind=='Swing' then
  if safe(p) or not (equipped(p,'Bat') or equipped(p,'Knife')) or os.clock()<(d.NextSwing or 0) then return end
  local head=p.Character:FindFirstChild('Head'); local aim=data.Position
  if not head or typeof(aim)~='Vector3' or not ((aim-head.Position).Magnitude>.01 and (aim-head.Position).Magnitude<10000) then return end
  d.NextSwing=os.clock()+.8; local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Exclude;ray.FilterDescendantsInstances={p.Character}
  local hit=workspace:Raycast(head.Position,(aim-head.Position).Unit*7,ray)
  local model=hit and hit.Instance:FindFirstAncestorOfClass('Model')
  local hum=model and model:FindFirstChildOfClass('Humanoid');local victim=model and Players:GetPlayerFromCharacter(model)
  if hum and hum.Health>0 and ((victim and not safe(victim) and (victim:GetAttribute('CustodyUntil') or 0)==0) or model.Parent==workspace:FindFirstChild('Emergency responders')) then respond.alert(p,head.Position,'assault',model);hum:TakeDamage(equipped(p,'Bat') and 16 or 20);heat(p,1) end
 elseif kind=='Shoot' then
  if safe(p) or not equipped(p,'Pistol') or typeof(data.Position)~='Vector3' then return end
  local pos=data.Position
  if pos.X~=pos.X or pos.Y~=pos.Y or pos.Z~=pos.Z or math.abs(pos.X)>1000000 or math.abs(pos.Y)>1000000 or math.abs(pos.Z)>1000000 then return end
  local t=p.Character.Pistol; local now=os.clock()
  if now<(d.NextShot or 0) or t:GetAttribute('Reloading') or (t:GetAttribute('Ammo') or 0)<=0 then return end
  local head=p.Character:FindFirstChild('Head'); if not head then return end
  local origin=head.Position; local direction=pos-origin; if direction.Magnitude<0.1 then return end
  d.NextShot=now+0.3; d.Magazine-=1; t:SetAttribute('Ammo',d.Magazine)
  local ray=RaycastParams.new(); ray.FilterDescendantsInstances={p.Character}; ray.FilterType=Enum.RaycastFilterType.Exclude
  local hit=workspace:Raycast(origin,direction.Unit*250,ray); local endPos=hit and hit.Position or origin+direction.Unit*250
  event:FireAllClients('Shot',{From=origin,To=endPos})
  respond.alert(p,origin,'gunfire',hit and hit.Instance:FindFirstAncestorOfClass('Model'))
  if hit then
   local model=hit.Instance:FindFirstAncestorOfClass('Model'); local victim=model and Players:GetPlayerFromCharacter(model)
   if victim and victim~=p and not safe(victim) then
    local _,h=alive(victim); if h and (victim:GetAttribute('CustodyUntil') or 0)==0 then h:TakeDamage(24); heat(p,1) end
   elseif model and model.Parent==workspace:FindFirstChild('Emergency responders') then
    local h=model:FindFirstChildOfClass('Humanoid'); if h and h.Health>0 then h:TakeDamage(24); heat(p,1) end
   end
  end
 end
end)
task.spawn(function()
 while task.wait(30) do
  for p in accounts do if not profiles[p] then task.spawn(save,p,false) end end
  for p,d in profiles do
   if d.Heat>0 and os.clock()>=(d.HeatNext or 0) then d.Heat-=1; d.HeatNext=os.clock()+30; sync(p) end
   if d.PendingSale then task.spawn(reconcileSale,p) end
   task.spawn(save,p,false)
  end
  for p,o in offers do if os.clock()>o.Expires then offers[p]=nil end end
 end
end)
game:BindToClose(function()
 local pending=0
 for p in accounts do pending+=1; task.spawn(function() save(p,true); pending-=1 end) end
 local deadline=os.clock()+25; while pending>0 and os.clock()<deadline do task.wait(0.1) end
end)
print('Baltimore server ready: secure economy, combat, robberies, trading, deliveries.')
