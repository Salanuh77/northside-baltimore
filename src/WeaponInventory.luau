local Catalog=script and require(game.ReplicatedStorage.WeaponCatalog) or require('./WeaponCatalog')
local Inventory={}
local function integer(value,maximum)
 return type(value)=='number' and value==value and math.clamp(math.floor(value),0,maximum) or 0
end
function Inventory.capture(d)
 if d.Weapon and d.Guns and (d.Guns[d.Weapon] or 0)>0 then d.GunMags[d.Weapon]=integer(d.Magazine,Catalog.get(d.Weapon).Capacity) end
end
function Inventory.select(d,id)
 if not Catalog.Guns[id] or (d.Guns[id] or 0)<1 then return false end
 Inventory.capture(d);d.Weapon=id;d.Magazine=d.GunMags[id] or 0;d.Items.Pistol=true;d.Stock.Sidearm=d.Guns[id]
 return true
end
function Inventory.restore(d,saved)
 saved=saved or {};d.Guns={};d.GunMags={};d.Attachments={};d.AttachmentEnabled={}
 if type(saved.Guns)=='table' then
  for id,spec in Catalog.Guns do
   local count=integer(saved.Guns[id],100);if count>0 then d.Guns[id]=count;d.GunMags[id]=integer(type(saved.GunMags)=='table' and saved.GunMags[id],spec.Capacity) end
  end
 elseif d.Items.Pistol then
  -- Existing paid sidearms retain their value as premium precision weapons.
  d.Guns.Carbine=math.max(1,integer(d.Stock.Sidearm,100));d.GunMags.Carbine=integer(d.Magazine,12)
 end
 for id in Catalog.Attachments do
  if type(saved.Attachments)=='table' and saved.Attachments[id]==true then
   d.Attachments[id]=true;d.AttachmentEnabled[id]=type(saved.AttachmentEnabled)=='table' and saved.AttachmentEnabled[id]==true
  end
 end
 d.Weapon=nil;d.Items.Pistol=nil;d.Stock.Sidearm=0;d.Magazine=0
 local chosen=Catalog.Guns[saved.Weapon] and (d.Guns[saved.Weapon] or 0)>0 and saved.Weapon
 if not chosen then for _,id in Catalog.Order do if (d.Guns[id] or 0)>0 then chosen=id;break end end end
 if chosen then Inventory.select(d,chosen) end
end
function Inventory.ensure(d)
 if not d.Guns then Inventory.restore(d) end
end
function Inventory.add(d,id,ammo)
 Inventory.ensure(d);if not Catalog.Guns[id] then return false end
 Inventory.capture(d)
 local count=d.Guns[id] or 0;if count>=100 then return false end
 d.Guns[id]=count+1
 -- Copies cannot refill another loaded copy for free.
 if count==0 then d.GunMags[id]=integer(ammo,Catalog.get(id).Capacity) end
 if not d.Weapon then Inventory.select(d,id) elseif d.Weapon==id then d.Stock.Sidearm=d.Guns[id] end
 return true
end
function Inventory.remove(d,id)
 Inventory.ensure(d);Inventory.capture(d)
 if not Catalog.Guns[id] or (d.Guns[id] or 0)<1 then return end
 local ammo=d.GunMags[id] or 0;d.Guns[id]-=1;d.GunMags[id]=0
 if d.Weapon==id then
  d.Weapon=nil;d.Magazine=0;d.Items.Pistol=nil;d.Stock.Sidearm=0
  for _,nextId in Catalog.Order do if (d.Guns[nextId] or 0)>0 then Inventory.select(d,nextId);break end end
 end
 return ammo
end
function Inventory.returnCopy(d,id,ammo)
 if not Inventory.add(d,id,0) then return false end
 Inventory.capture(d)
 local rounds=integer(ammo,Catalog.get(id).Capacity)+(d.GunMags[id] or 0)
 d.GunMags[id]=math.min(rounds,Catalog.get(id).Capacity)
 d.Reserve=math.min(120,(d.Reserve or 0)+math.max(0,rounds-d.GunMags[id]))
 if d.Weapon==id then d.Magazine=d.GunMags[id] end
 return true
end
function Inventory.buy(d,id)
 Inventory.ensure(d);local spec=Catalog.Guns[id]
 if not spec then return false,'Unknown weapon' end
 if (d.Guns[id] or 0)>0 then return Inventory.select(d,id),'Equipped' end
 if not spec.Price then return false,'Premium weapon' end
 if d.Cash<spec.Price then return false,'Not enough cash' end
 d.Cash-=spec.Price;Inventory.add(d,id,spec.Capacity);Inventory.select(d,id)
 return true,'Purchased'
end
function Inventory.attachment(d,id)
 Inventory.ensure(d);local spec=Catalog.Attachments[id]
 if not spec or not d.Weapon or not Catalog.supports(d.Weapon,id) then return false,'Incompatible attachment' end
 if not d.Attachments[id] then
  if d.Cash<spec.Price then return false,'Not enough cash' end
  d.Cash-=spec.Price;d.Attachments[id]=true;d.AttachmentEnabled[id]=true
 else d.AttachmentEnabled[id]=not d.AttachmentEnabled[id] end
 return true,d.AttachmentEnabled[id] and 'Attached' or 'Removed'
end
function Inventory.active(d,id)
 return d.Attachments and d.Attachments[id]==true and d.AttachmentEnabled[id]==true and Catalog.supports(d.Weapon,id)==true
end
return Inventory
