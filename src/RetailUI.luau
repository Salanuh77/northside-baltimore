local Players=game:GetService('Players')
local Market=game:GetService('MarketplaceService')
local Style=require(game.ReplicatedStorage:WaitForChild('StreetStyle'))
local p=Players.LocalPlayer
local products=require(game.ReplicatedStorage:WaitForChild('ShopProducts'))
local cards=require(game.ReplicatedStorage:WaitForChild('ItemCard'))
local catalog=require(game.ReplicatedStorage:WaitForChild('ItemCatalog'))
local weapons=require(game.ReplicatedStorage:WaitForChild('WeaponCatalog'))
return function(event,modal,content,clear,row,paragraph,input,state)
 local function item(key,fn,price)
  local entry=catalog[key]
  return cards.decorate(row('',fn),entry.Icon,entry.Name,entry.Description,price or '$'..entry.Price)
 end
 local function premium(key)
  local product=products[key]
  local card
  if key=='Sidearm' then
   card=cards.decorate(row('',function() event:FireServer('Premium',{Item=key}) end),'Pistol',weapons.Guns.Carbine.Name,'Premium precision carbine. Slower shots, greater reach.','Check Robux price',{Weapon='Carbine'})
  else card=item(key,function() event:FireServer('Premium',{Item=key}) end,'Check Robux price') end
  task.spawn(function()
   local ok,info=pcall(function() return Market:GetProductInfoAsync(product.Id,Enum.InfoType.Product) end)
   if ok and card.button.Parent and info.PriceInRobux then card.price.Text=info.PriceInRobux..' Robux' end
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
   clear('RIVER PRO ARMORY')
   paragraph('Cash weapons include a loaded magazine. Owned weapons can be equipped here without buying them again.')
   for _,id in weapons.Order do
    local spec=weapons.Guns[id];local owned=((state().Weapons or {})[id] or 0)>0
    if spec.Price or owned then
     cards.decorate(row('',function() event:FireServer('BuyWeapon',{Item=id});modal.Visible=false end),'Pistol',spec.Name,spec.Capacity..' rounds · '..(spec.Automatic and 'Automatic' or spec.Pellets>1 and 'Pump action' or 'Semi-auto'),owned and 'OWNED · Equip' or '$'..spec.Price,{Weapon=id})
    end
   end
   premium('Sidearm')
   item('Ammo',function() event:FireServer('BuyAmmo') end)
   paragraph('Attachments for '..weapons.get(state().Weapon).Name)
   for _,id in {'Scope','Suppressor'} do
    local spec=weapons.Attachments[id];local owned=(state().Attachments or {})[id];local active=(state().AttachmentEnabled or {})[id]
    if weapons.supports(state().Weapon,id) then
     cards.decorate(row('',function() event:FireServer('WeaponAttachment',{Item=id});modal.Visible=false end),'Pistol',spec.Name,spec.Description,owned and (active and 'OWNED · Remove' or 'OWNED · Attach') or '$'..spec.Price,{Attachment=id})
    end
   end
  elseif kind=='Sporting' then
   clear('UNION ATHLETICS');item('Bat',function() event:FireServer('Buy',{Item='Bat'}) end)
  elseif kind=='Clothing' then
   clear('SHOP CLOTHING')
   local colors={{37,48,58},{113,40,47},{77,87,66},{47,78,120},{173,109,55},{115,84,61}}
   for index,v in Style.Outfits do
    local owned=(state().Wardrobe or {})[v.Id]
    cards.decorate(row('',function() event:FireServer('Outfit',{Item=v.Id});modal.Visible=false end),'Clothing',v.Name,owned and 'In your wardrobe. Select to wear.' or 'Add this outfit to your wardrobe.',owned and 'OWNED · Wear' or '$'..v.Price,{color=colors[index]})
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
   row('Face mirror',function() event:FireServer('OpenMirror');modal.Visible=false end)
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
