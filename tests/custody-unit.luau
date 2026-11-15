local fs=require('@lune/fs')
local luau=require('@lune/luau')
local function fixture(heat,cash)
 local function user(id) return {UserId=id,DisplayName=tostring(id),SetAttribute=function(self,k,v) self[k]=v end} end
 local a,b=user(1),user(2)
 local users={a,b}
 local players={GetPlayerByUserId=function(_,id) return users[id] end,PlayerRemoving={Connect=function() end}}
 local state={time=100,near=true}
 local service=luau.load(fs.readFile('src/Custody.luau'),{environment={
  game={GetService=function() return players end},os={clock=function() return state.time end,time=function() return state.time end},task={spawn=function() end}},injectGlobals=true})()
 local d={Heat=heat,Cash=cash}
 local payer={Heat=0,Cash=cash}
 local facility={Intake={},Release={},['Escape landing']={}}
 local event={FireClient=function(_,p,key,data) if key=='LightRun' then state.sequence=data end end}
 local noop=function() end
 local custody=service({WaitForChild=function() return facility end},event,{[a]=d,[b]=payer},noop,noop,function() return state.near end,noop)
 return custody,a,b,d,payer,state
end
for level=0,5 do
 local c,a,_,d,_,s=fixture(level,500)
 assert(c.arrest(a)==(level>0))
 if level>0 then
  assert(d.CustodyUntil==s.time+45+15*level and d.Bail==60+level*20 and d.Heat==0)
  assert(not c.arrest(a));c.restore(a);assert(a.CustodyUntil==d.CustodyUntil)
  s.time=d.CustodyUntil;c.restore(a);assert(d.CustodyUntil==0 and d.Bail==0 and a.Bail==0)
 end
end
for _,case in {{false,true,500,true},{true,true,500,true},{false,false,500,false},{false,true,79,false}} do
 local self,near,cash,allowed=table.unpack(case)
 local c,a,b,d,payer,s=fixture(1,cash);c.arrest(a);s.near=near
 local who=self and a or b
 c.handle(who,'PostBail',{Target=1});c.handle(who,'PostBail',{Target=1})
 assert((d.CustodyUntil==0)==allowed and (self and d or payer).Cash==cash-(allowed and 80 or 0))
end
for _,kind in {'complete','wrong','expired','away'} do
 local c,a,b,d,payer,s=fixture(2,500);c.arrest(a);c.prompt(a,'EscapeGame')
 assert(#s.sequence==4)
 if kind=='expired' then s.time+=25 end
 if kind=='away' then s.near=false end
 for _,symbol in s.sequence do c.handle(a,'LightStep',{Symbol=kind=='wrong' and '' or symbol}) end
 assert((d.CustodyUntil==0)==(kind=='complete'))
 assert(d.Heat==(kind=='complete' and 3 or 0))
end
print('PASS: 14 custody scenarios for sentencing, restoration, bail and escape')
