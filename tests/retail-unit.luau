local fs=require('@lune/fs')
local luau=require('@lune/luau')
local enum=require('@lune/roblox').Enum
local decision=enum.ProductPurchaseDecision
local source=fs.readFile('src/CityRetail.luau')
local function fixture()
 local p={UserId=8}
 local profile={Look={},Receipts={},Stock={},Items={},Reserve=110}
 local profiles={[p]=profile}
 local state={tools=0,canSave=true}
 local services={Players={GetPlayerByUserId=function(_,id) return id==8 and p or nil end},MarketplaceService={}}
 local game={ReplicatedStorage={WaitForChild=function() end},GetService=function(_,key) return services[key] or {} end}
 local factory=luau.load(source,{environment={game=game,Enum=enum,require=function() return {} end},injectGlobals=true})()
 local noop=function() end
 factory(profiles,{}, {},noop,noop,noop,function() return state.canSave end,function() state.tools+=1 end)
 local function buy(product,id,player)
  return services.MarketplaceService.ProcessReceipt({PlayerId=player or 8,ProductId=product,PurchaseId=id or 'first'})
 end
 return buy,profile,state
end
local gun,glow,confetti=3732000729,3732000733,3732000737
local cases={
 {'offline player',function(buy) assert(buy(gun,nil,9)==decision.NotProcessedYet) end},
 {'unknown product',function(buy,d) assert(buy(123)==decision.NotProcessedYet and next(d.Receipts)==nil) end},
 {'leaving',function(buy,d) d.Leaving=true;assert(buy(glow)==decision.NotProcessedYet and next(d.Stock)==nil) end},
 {'trading',function(buy,d) d.Trading=true;assert(buy(gun)==decision.NotProcessedYet and next(d.Items)==nil) end},
 {'owned loadout and ammo cap',function(buy,d,s) assert(buy(gun)==decision.PurchaseGranted and d.Stock.Sidearm==1 and d.Magazine==12 and d.Reserve==120 and s.tools==1) end},
 {'distinct sidearms',function(buy,d) buy(gun);d.Magazine=2;buy(gun,'second');assert(d.Stock.Sidearm==2 and d.Magazine==2) end},
 {'retry a failed save',function(buy,d,s) s.canSave=false;assert(buy(gun)==decision.NotProcessedYet and s.tools==0);s.canSave=true;assert(buy(gun)==decision.PurchaseGranted and d.Stock.Sidearm==1 and s.tools==1) end},
 {'replayed receipt after trade',function(buy,d,s) buy(gun);d.Items.Pistol=nil;d.Stock.Sidearm=0;s.tools=0;assert(buy(gun)==decision.PurchaseGranted and s.tools==0,'reissued a traded item') end},
 {'glow pack',function(buy,d) buy(glow);buy(glow);assert(d.Stock.Glow==5) end},
 {'confetti packs',function(buy,d) buy(confetti);buy(confetti,'second');assert(d.Stock.Confetti==10) end},
}
local failures=0
for _,case in cases do
 local ok,err=pcall(case[2],fixture())
 if not ok then failures+=1 end
 print(ok and 'PASS' or 'FAIL',case[1],err or '')
end
assert(failures==0,tostring(failures)..' receipt regressions')
