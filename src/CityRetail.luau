local Players=game:GetService('Players')
local Market=game:GetService('MarketplaceService')
local Text=game:GetService('TextService')
local Policy=game:GetService('PolicyService')
local Style=require(game.ReplicatedStorage:WaitForChild('StreetStyle'))
local Names=require(game.ReplicatedStorage:WaitForChild('ResidentNames'))
local products=require(game.ReplicatedStorage:WaitForChild('ShopProducts'))
local types={}
for name,product in products do types[product.Id]=name end
return function(profiles,jobs,event,closest,sync,tell,save,tool)
 local requests=setmetatable({},{__mode='k'})
 local function dress(p,d) Style.apply(p.Character,d.Look,d.Outfit) end
 local function setup(p,d)
  p:SetAttribute('NeedsCharacter',d.Look==nil)
  task.spawn(function()
   local ok,info=pcall(function() return Policy:GetPolicyInfoForPlayerAsync(p) end)
   if ok and profiles[p]==d then d.PaidTrading=info.IsPaidItemTradingAllowed==true end
  end)
  p.CharacterAppearanceLoaded:Connect(function(c) if profiles[p]==d then Style.apply(c,d.Look,d.Outfit) end end)
 end
 local function haircut(customer,barber,request)
  local d=profiles[customer]
  if not d or not d.Look or d.Cash<30 or closest(customer,'Barber')~=request.Chair or customer:GetAttribute('CustodyUntil') and customer:GetAttribute('CustodyUntil')>0 then return end
  if barber then
   local bd=profiles[barber]; local shift=jobs[barber]; local root=barber.Character and barber.Character:FindFirstChild('HumanoidRootPart')
   if not bd or not shift or shift.role~='barber' or shift.step~=2 or not root or (root.Position-request.Chair.Position).Magnitude>14 then return end
   bd.Wages+=30; bd.Cash+=30; sync(barber); tell(barber,'Haircut complete. You earned $30.')
  end
  d.Cash-=30; d.Look.Hair=request.Style; dress(customer,d); sync(customer); tell(customer,'Your haircut is saved.')
 end
 local actions={CreateResident=true,Outfit=true,Cut=true,ServeCut=true,Premium=true,PartyItem=true,ArmoryFinish=true}
 local function resolveName(p,data)
  return Names.resolve(data,Style.FirstNames,Style.LastNames,function(name)
   return Text:FilterStringAsync(name,p.UserId):GetNonChatStringForBroadcastAsync()
  end)
 end
 local function handle(p,kind,data,approvedName)
  if not actions[kind] then return false end
  local d=profiles[p]
  if kind=='CreateResident' then
   if d.Look or d.Creating then return true end
   if not Style.valid(data) then tell(p,'Choose one of the available appearance options.');return true end
   d.Creating=true
   local name,reason=approvedName,nil
   if not name then name,reason=resolveName(p,data) end
   d.Creating=nil
   if profiles[p]~=d or d.Leaving then return true end
   if not name then tell(p,reason);return true end
   d.Look={Name=name,Height=data.Height,Build=data.Build,Hair=data.Hair,Tone=data.Tone,Starter=data.Starter or 'Harbor',Detail=data.Detail or 'Clean',Eye=data.Eye or 'Brown',Expression=data.Expression or 'Calm',HairColor=data.HairColor or 'Black'}
   for _,field in {'Depth','Pants','Shoes','Mouth','HairDetail','FaceShape','FaceWidth','EyeSpacing','LipFullness'} do d.Look[field]=data[field] end
   p:SetAttribute('NeedsCharacter',false); dress(p,d); sync(p); event:FireClient(p,'StyleSaved')
  elseif kind=='Outfit' then
   if not closest(p,'Clothing') or not d.Look then return true end
   for _,v in Style.Outfits do if v.Id==data.Item then
    if not d.Wardrobe[v.Id] then
     if d.Cash<v.Price then tell(p,'You need $'..v.Price..' for this outfit.'); return true end
     d.Cash-=v.Price; d.Wardrobe[v.Id]=true
    end
    d.Outfit=v.Id; dress(p,d); sync(p); tell(p,v.Name..' equipped.'); break
   end end
  elseif kind=='Cut' then
   local chair=closest(p,'Barber')
   if not chair or not d.Look or not table.find(Style.Hair,data.Style) then return true end
   if data.Style==d.Look.Hair then tell(p,'You already wear that cut.');return true end
   if d.Cash<30 then tell(p,'Haircuts cost $30.'); return true end
   local req={Style=data.Style,Chair=chair,Expires=os.clock()+25}
   requests[p]=nil
   for worker,shift in jobs do
    local root=worker.Character and worker.Character:FindFirstChild('HumanoidRootPart')
    if worker~=p and shift.role=='barber' and shift.step==2 and root and (root.Position-chair.Position).Magnitude<=14 then
     requests[p]=req; event:FireClient(worker,'CutRequest',{Customer=p.UserId,Name=p.DisplayName,Style=data.Style})
    end
   end
   if requests[p] then tell(p,'Waiting for a barber. Stay beside your chair.')
    task.delay(25,function() if requests[p]==req then requests[p]=nil; if profiles[p] then haircut(p,nil,req) end end end)
   else haircut(p,nil,req) end
  elseif kind=='ServeCut' then
   local customer=type(data.Customer)=='number' and Players:GetPlayerByUserId(data.Customer)
   local req=customer and requests[customer]
   if req and os.clock()<=req.Expires and jobs[p] and jobs[p].role=='barber' and jobs[p].step==2 and p~=customer then
    local root=p.Character and p.Character:FindFirstChild('HumanoidRootPart')
    if root and (root.Position-req.Chair.Position).Magnitude<=14 then requests[customer]=nil; haircut(customer,p,req) end
   end
  elseif kind=='ArmoryFinish' then
   if not d.Look or not d.Items.Pistol or not closest(p,'GunStore') or not table.find({'Slate compact','Silver service','Field carbine'},data.Finish) then return true end
   local bag=p:FindFirstChildOfClass('Backpack');local existing=(p.Character and p.Character:FindFirstChild('Pistol')) or (bag and bag:FindFirstChild('Pistol'))
   if existing and existing:GetAttribute('Reloading') then return true end
   d.Look.Armory=data.Finish
   if existing then existing:Destroy() end
   tool(p,'Pistol');tell(p,data.Finish..' equipped in your inventory.')
  elseif kind=='Premium' then
   local key=data.Item
   if products[key] and (key~='Sidearm' or closest(p,'GunStore')) then event:FireClient(p,'Checkout',products[key].Id) end
  elseif kind=='PartyItem' then
   local key=data.Item; if not products[key] or not products[key].Use then return true end
   local root=p.Character and p.Character:FindFirstChild('HumanoidRootPart')
   if not root or (d.Stock[key] or 0)<1 then tell(p,'Your party bag is empty.');return true end
   if key=='Glow' and root:FindFirstChild('Harbor glow') then tell(p,'Your glow stick is still lit.');return true end
   d.Stock[key]-=1
   if key=='Glow' then
    local light=Instance.new('PointLight'); light.Name='Harbor glow';light.Color=Color3.fromRGB(47,240,178);light.Range=18;light.Brightness=3; light.Parent=root
    local rod=Instance.new('Part');rod.Size=Vector3.new(.16,1,.16);rod.Color=light.Color;rod.Material=Enum.Material.Neon;rod.CanCollide=false;rod.CanTouch=false;rod.CanQuery=false;rod.Massless=true
    local hand=p.Character:FindFirstChild('LeftHand') or p.Character:FindFirstChild('Left Arm') or root;rod.CFrame=hand.CFrame*CFrame.new(0,-.35,-.2);rod.Parent=p.Character
    local weld=Instance.new('WeldConstraint');weld.Part0=hand;weld.Part1=rod;weld.Parent=rod
    game.Debris:AddItem(light,60);game.Debris:AddItem(rod,60)
   elseif key=='Bubbles' or key=='Streamers' then
    local bubbles=key=='Bubbles'
    local emitter=Instance.new('ParticleEmitter');emitter.Name=key
    emitter.Texture=bubbles and 'rbxasset://textures/particles/explosion01_shockwave_main.dds' or 'rbxasset://textures/particles/SquareParticle.png'
    emitter.Color=ColorSequence.new(bubbles and Color3.fromRGB(144,209,242) or Color3.fromRGB(137,83,182),bubbles and Color3.fromRGB(227,185,228) or Color3.fromRGB(251,194,83))
    emitter.Rate=0;emitter.Size=NumberSequence.new(bubbles and .45 or .23)
    emitter.Lifetime=NumberRange.new(2,3);emitter.Speed=NumberRange.new(5,10);emitter.SpreadAngle=Vector2.new(65,65)
    emitter.Transparency=NumberSequence.new(bubbles and .36 or .08,1)
    if not bubbles then emitter.Squash=NumberSequence.new(1.4) end
    emitter.Acceleration=Vector3.new(0,bubbles and 1.6 or -7,0);emitter.RotSpeed=NumberRange.new(-90,90)
    emitter.Parent=root;emitter:Emit(bubbles and 24 or 65);game.Debris:AddItem(emitter,4)
   else
    local effect=Instance.new('ParticleEmitter');effect.Texture='rbxasset://textures/particles/sparkles_main.dds';effect.Color=ColorSequence.new(Color3.fromRGB(240,185,67),Color3.fromRGB(53,163,212));effect.Rate=0;effect.Lifetime=NumberRange.new(1.4,2.2);effect.Speed=NumberRange.new(9,16);effect.SpreadAngle=Vector2.new(70,70);effect.Acceleration=Vector3.new(0,-12,0);effect.Parent=root;effect:Emit(75);game.Debris:AddItem(effect,3)
   end
   sync(p)
  end
  return true
 end
 local function receipt(info)
  local key=types[info.ProductId];local p=Players:GetPlayerByUserId(info.PlayerId);local d=p and profiles[p]
  if not d or not d.Look or not key or d.Leaving or d.Trading then return Enum.ProductPurchaseDecision.NotProcessedYet end
  local id=tostring(info.PurchaseId)
  if not d.Receipts[id] then
   d.Receipts[id]=true
   if key=='Sidearm' then
    d.Stock.Sidearm=(d.Stock.Sidearm or 0)+1
    if not d.Items.Pistol then d.Items.Pistol=true;d.Magazine=12;d.Reserve=math.min(120,d.Reserve+12) end
   elseif key=='Sampler' then
    for name,product in products do if product.Use then d.Stock[name]=(d.Stock[name] or 0)+3 end end
   else d.Stock[key]=(d.Stock[key] or 0)+5 end
  end
  if not save(p,false) then return Enum.ProductPurchaseDecision.NotProcessedYet end
  if key=='Sidearm' and d.Items.Pistol then tool(p,'Pistol') end
  sync(p);return Enum.ProductPurchaseDecision.PurchaseGranted
 end
 Market.ProcessReceipt=receipt
 return {handle=handle,resolveName=resolveName,setup=setup,dress=dress,receipt=receipt}
end
