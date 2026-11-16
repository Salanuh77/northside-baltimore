local Players=game:GetService('Players')
local Market=game:GetService('MarketplaceService')
local Style=require(game.ReplicatedStorage:WaitForChild('StreetStyle'))
local p=Players.LocalPlayer
local products=require(game.ReplicatedStorage:WaitForChild('ShopProducts'))
return function(event,modal,content,clear,row,paragraph,input,state)
 local function premium(key)
  local product=products[key]
  local b=row(product.Title..' · Robux',function() event:FireServer('Premium',{Item=key}) end)
  task.spawn(function()
   local ok,info=pcall(function() return Market:GetProductInfoAsync(product.Id,Enum.InfoType.Product) end)
   if ok and b.Parent and info.PriceInRobux then b.Text=product.Title..' · '..info.PriceInRobux..' Robux' end
  end)
 end
 local function bag()
  clear('PARTY SUPPLIES')
  for _,key in {'Bubbles','Glow','Confetti','Streamers'} do
   premium(key)
   local owned=(state().Stock or {})[key] or 0
   if owned>0 then row('Use '..products[key].Use..' · '..owned..' in bag',function() event:FireServer('PartyItem',{Item=key});modal.Visible=false end) end
  end
  premium('Sampler')
 end
 local function handle(kind,data)
  if kind=='StyleSaved' then modal.Visible=false
  elseif kind=='Checkout' then
   for _,prod in products do if prod.Id==data then Market:PromptProductPurchase(p,data);break end end
  elseif kind=='GunStore' then
   clear('EASTERN OUTFITTERS');premium('Sidearm')
   paragraph('For a city-cash purchase, use the player trade menu to buy a sidearm from another eligible player.')
   row('Box of 12 rounds · $30',function() event:FireServer('BuyAmmo') end)
   if (state().Items or {}).Pistol then
    for _,name in {'Slate compact','Silver service','Field carbine'} do
     row(name..' · Included appearance',function() event:FireServer('ArmoryFinish',{Finish=name});modal.Visible=false end)
    end
   end
  elseif kind=='Sporting' then
   clear('UNION ATHLETICS');row('Wood baseball bat · $80',function() event:FireServer('Buy',{Item='Bat'}) end)
  elseif kind=='Clothing' then
   clear('EXCHANGE STREETWEAR')
   for _,v in Style.Outfits do
    local owned=(state().Wardrobe or {})[v.Id]
    row(v.Name..(owned and ' · Wear' or ' · $'..v.Price),function() event:FireServer('Outfit',{Item=v.Id});modal.Visible=false end)
   end
  elseif kind=='Barber' then
   local function chooseDye(cut)
    clear('CUT & COLOR');paragraph(cut..' · Choose a finish. The appointment costs $30.')
    local function book(color)
     event:FireServer('Cut',{Style=cut,Color=color});modal.Visible=false
    end
    row('Keep current color',function() book(state().HairColor or 'Black') end)
    for _,color in Style.HairColors do row(color,function() book(color) end) end
   end
   clear('BARBER CHAIR');paragraph('Choose a haircut and dye for $30.')
   if state().Hair then row('Dye current haircut',function() chooseDye(state().Hair) end) end
   for _,cut in Style.Hair do row(cut,function() chooseDye(cut) end) end
  elseif kind=='CutRequest' then
   clear('BARBER APPOINTMENT');paragraph(data.Name..' requested '..data.Style..' in '..data.Color..'. Complete the cut to receive $30.')
   row('Serve customer',function() event:FireServer('ServeCut',{Customer=data.Customer});modal.Visible=false end)
  else return false end
  return true
 end
 return {handle=handle,bag=bag}
end
