local fs=require('@lune/fs')
local luau=require('@lune/luau')
local enum=require('@lune/roblox').Enum
local decision=enum.ProductPurchaseDecision
local Inventory=require('../src/WeaponInventory')
local Weapons=require('../src/WeaponCatalog')
local source=fs.readFile('src/CityRetail.luau')
local function fixture()
 local p={UserId=8}
 local profile={Look={},Receipts={},Stock={},Items={},Reserve=110,Cash=100,Wardrobe={}}
 local profiles={[p]=profile}
 local state={tools=0,canSave=true}
 local services={Players={GetPlayerByUserId=function(_,id) return id==8 and p or nil end},MarketplaceService={}}
 local game={ReplicatedStorage={WaitForChild=function(_,name) return name end},GetService=function(_,key) return services[key] or {} end}
 local catalog=require('../src/ShopProducts')
 local style=luau.load(fs.readFile('src/StreetStyle.luau'),{environment={game=game,Color3=require('@lune/roblox').Color3,require=function() return {} end},injectGlobals=true})()
 style.apply=function(_,_,outfit) state.equipped=outfit end
 local factory=luau.load(source,{environment={game=game,Enum=enum,script={Parent={WeaponInventory='WeaponInventory'}},require=function(name) return name=='ShopProducts' and catalog or name=='StreetStyle' and style or name=='WeaponCatalog' and Weapons or name=='WeaponInventory' and Inventory or {} end},injectGlobals=true})()
 local noop=function() end
 local function atCounter(_,kind) return kind=='Clothing' and state.atStore end
 local retail=factory(profiles,{}, {},atCounter,noop,noop,function() return state.canSave end,function() state.tools+=1 end)
 state.wear=function(id) return retail.handle(p,'Outfit',{Item=id}) end
 local function buy(product,id,player)
  return services.MarketplaceService.ProcessReceipt({PlayerId=player or 8,ProductId=product,PurchaseId=id or 'first'})
 end
 return buy,profile,state
end
local gun,glow,confetti=3732000729,3732000733,3732000737
local cases={
 {'parody collection uses cash and remembers ownership',function(_,d,s)
  for id,price in {['haste-markdown']=42,['forever-tuesday']=58,['last-season']=36} do
   d.Cash=price;s.atStore=false;s.wear(id)
   assert(d.Cash==price and not d.Wardrobe[id])
   s.atStore=true;d.Cash=price-1;s.wear(id);assert(not d.Wardrobe[id])
   d.Cash=price;s.wear(id);assert(d.Cash==0 and d.Wardrobe[id] and s.equipped==id)
   s.equipped=nil;s.wear(id);assert(d.Cash==0 and s.equipped==id)
  end
 end},
 {'offline player',function(buy) assert(buy(gun,nil,9)==decision.NotProcessedYet) end},
 {'unknown product',function(buy,d) assert(buy(123)==decision.NotProcessedYet and next(d.Receipts)==nil) end},
 {'leaving',function(buy,d) d.Leaving=true;assert(buy(glow)==decision.NotProcessedYet and next(d.Stock)==nil) end},
 {'trading',function(buy,d) d.Trading=true;assert(buy(gun)==decision.NotProcessedYet and next(d.Items)==nil) end},
 {'owned loadout and ammo cap',function(buy,d,s) assert(buy(gun)==decision.PurchaseGranted and d.Stock.Sidearm==1 and d.Magazine==12 and d.Reserve==120 and s.tools==1) end},
 {'distinct sidearms',function(buy,d) buy(gun);d.Magazine=2;buy(gun,'second');assert(d.Stock.Sidearm==2 and d.Magazine==2) end},
 {'full premium inventory keeps receipt pending',function(buy,d)
  Inventory.restore(d,{Guns={Carbine=100},Weapon='Carbine',GunMags={Carbine=7}})
  assert(buy(gun,'full')==decision.NotProcessedYet and not d.Receipts.full and d.Guns.Carbine==100)
  Inventory.remove(d,'Carbine');assert(buy(gun,'full')==decision.PurchaseGranted and d.Guns.Carbine==100)
 end},
 {'retry a failed save',function(buy,d,s) s.canSave=false;assert(buy(gun)==decision.NotProcessedYet and s.tools==0);s.canSave=true;assert(buy(gun)==decision.PurchaseGranted and d.Stock.Sidearm==1 and s.tools==1) end},
 {'replayed receipt after trade',function(buy,d,s) buy(gun);Inventory.remove(d,'Carbine');s.tools=0;assert(buy(gun)==decision.PurchaseGranted and s.tools==0,'reissued a traded item') end},
 {'glow pack',function(buy,d) buy(glow);buy(glow);assert(d.Stock.Glow==5) end},
 {'confetti packs',function(buy,d) buy(confetti);buy(confetti,'second');assert(d.Stock.Confetti==10) end},
 {'bubble pack',function(buy,d) buy(3732068670);assert(d.Stock.Bubbles==5) end},
 {'streamers',function(buy,d) buy(3732068672);assert(d.Stock.Streamers==5) end},
 {'sampler survives a receipt retry',function(buy,d,s) s.canSave=false;assert(buy(3732068679)==decision.NotProcessedYet);s.canSave=true;assert(buy(3732068679)==decision.PurchaseGranted);for _,k in {'Glow','Confetti','Bubbles','Streamers'} do assert(d.Stock[k]==3,k) end end},
}
local failures=0
for _,case in cases do
 local ok,err=pcall(case[2],fixture())
 if not ok then failures+=1 end
 print(ok and 'PASS' or 'FAIL',case[1],err or '')
end
assert(failures==0,tostring(failures)..' receipt regressions')
