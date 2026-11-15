local Players=game:GetService('Players')
local Market=game:GetService('MarketplaceService')
local Style=require(game.ReplicatedStorage:WaitForChild('StreetStyle'))
local p=Players.LocalPlayer
local products={Sidearm={3732000729,'Sidearm'},Glow={3732000733,'5 harbor glow sticks'},Confetti={3732000737,'5 club confetti bursts'}}
return function(event,modal,content,clear,row,paragraph,input,state)
 local function premium(key)
  local product=products[key]
  local b=row(product[2]..' · Robux',function() event:FireServer('Premium',{Item=key}) end)
  task.spawn(function()
   local ok,info=pcall(function() return Market:GetProductInfoAsync(product[1],Enum.InfoType.Product) end)
   if ok and b.Parent and info.PriceInRobux then b.Text=product[2]..' · '..info.PriceInRobux..' Robux' end
  end)
 end
 local function creator()
  clear('YOUR NORTHSIDE CHARACTER')
  local choices={Height='Medium',Build='Average',Hair='Close crop',Tone='Amber',Name=p.DisplayName}
  local preview=Instance.new('ViewportFrame');preview.Size=UDim2.new(1,-6,0,158);preview.BackgroundColor3=Color3.fromRGB(48,65,65);preview.LayoutOrder=0;preview.Parent=content
  preview.Ambient=Color3.fromRGB(179,168,153);preview.LightColor=Color3.fromRGB(255,238,202)
  local camera=Instance.new('Camera');camera.CFrame=CFrame.lookAt(Vector3.new(2.4,2.1,-8),Vector3.new(0,.4,0));camera.FieldOfView=39;camera.Parent=preview;preview.CurrentCamera=camera
  local function render()
   local old=preview:FindFirstChildOfClass('WorldModel'); if old then old:Destroy() end
   local c=p.Character;if not c or not c:FindFirstChild('Head') then return end
   local archive=c.Archivable;c.Archivable=true;local clone=c:Clone();c.Archivable=archive
   for _,v in clone:GetDescendants() do if v:IsA('LuaSourceContainer') or v:IsA('Tool') then v:Destroy() end end
   local world=Instance.new('WorldModel');world.Parent=preview;clone.Parent=world;clone:PivotTo(CFrame.new())
   local root=clone:FindFirstChild('HumanoidRootPart');if root then root.Anchored=true end
   Style.apply(clone,choices,nil)
  end
  render()
  local name=input('Roleplay name · blank uses your display name')
  for _,opt in {{'Height','Height',Style.Heights},{'Build','Build / weight',Style.Builds},{'Tone','Skin tone',Style.Tones},{'Hair','Haircut',Style.Hair}} do
   local key,label,list=table.unpack(opt);local b
   b=row(label..' · '..choices[key],function()
    choices[key]=list[table.find(list,choices[key])%#list+1];b.Text=label..' · '..choices[key];render()
   end)
  end
  row('Save character',function() choices.Name=name.Text;event:FireServer('CreateResident',choices) end)
 end
 local function bag()
  clear('PARTY SUPPLIES')
  for _,key in {'Glow','Confetti'} do
   premium(key)
   local owned=(state().Stock or {})[key] or 0
   row('Use '..(key=='Glow' and 'glow stick' or 'confetti')..' · '..owned..' in bag',function() event:FireServer('PartyItem',{Item=key});modal.Visible=false end)
  end
 end
 local function handle(kind,data)
  if kind=='StyleSaved' then modal.Visible=false
  elseif kind=='Checkout' then
   for _,prod in products do if prod[1]==data then Market:PromptProductPurchase(p,data);break end end
  elseif kind=='GunStore' then
   clear('EASTERN OUTFITTERS');premium('Sidearm')
   paragraph('For a city-cash purchase, use the player trade menu to buy a sidearm from another eligible player.')
   row('Box of 12 rounds · $30',function() event:FireServer('BuyAmmo') end)
  elseif kind=='Sporting' then
   clear('UNION ATHLETICS');row('Wood baseball bat · $80',function() event:FireServer('Buy',{Item='Bat'}) end)
  elseif kind=='Clothing' then
   clear('EXCHANGE STREETWEAR')
   for _,v in Style.Outfits do
    local owned=(state().Wardrobe or {})[v.Id]
    row(v.Name..(owned and ' · Wear' or ' · $'..v.Price),function() event:FireServer('Outfit',{Item=v.Id});modal.Visible=false end)
   end
  elseif kind=='Barber' then
   clear('BARBER CHAIR');paragraph('Choose a cut for $30. A barber on shift can take your appointment here.')
   for _,cut in Style.Hair do row(cut,function() event:FireServer('Cut',{Style=cut});modal.Visible=false end) end
  elseif kind=='CutRequest' then
   clear('BARBER APPOINTMENT');paragraph(data.Name..' requested '..data.Style..'. Complete the cut to receive $30.')
   row('Serve customer',function() event:FireServer('ServeCut',{Customer=data.Customer});modal.Visible=false end)
  else return false end
  return true
 end
 return {handle=handle,creator=creator,bag=bag}
end
