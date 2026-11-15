local directory=require('../src/ServerDirectory')
local now=1000
local function city(count,capacity,age) return {Players=count,Capacity=capacity,Updated=now-age} end
local records={{key='here',value=city(2,20,0)},{key='full',value=city(20,20,0)},{key='open',value=city(9,20,10)},{key='old',value=city(2,20,91)},{key='invalid',value={}}}
local choices=directory.choices(records,'here',now)
assert(#choices==2 and choices[1].Id=='open' and choices[2].Id=='full')
assert(choices[1].Players==9 and choices[1].Capacity==20)
assert(directory.available(city(0,20,0),now) and not directory.available(city(20,20,0),now))
assert(not directory.available(city(2,20,91),now) and not directory.available(nil,now))
print('PASS: separate public instances, capacity, expired entries and current-server exclusion')

local fs=require('@lune/fs')
local luau=require('@lune/luau')
local realEnum=require('@lune/roblox').Enum
local function signal()
 return {Connect=function(self,fn) self.fire=fn end}
end
local id='309a678a-0064-41ac-8585-234e4bf91483'
local source='a7345fa3-84b0-4761-8935-560beebc62cb'
local t=100
local p={Parent=true}
local allowed=true
local writes,visits=0,0
local row={Players=2,Capacity=20,Updated=t}
local map={
 GetAsync=function(_,key) if key==id then return row end end,
 GetRangeAsync=function() return {{key=id,value=row}} end,
}
local remote={OnServerEvent=signal(),FireClient=function(self,_,kind,data) self.kind=kind;self.message=data end}
local players={MaxPlayers=20,PlayerRemoving=signal(),GetPlayers=function() return {p} end}
local tele={TeleportInitFailed=signal(),TeleportAsync=function(_,place,people,options)
 assert(allowed and writes>0 and place==78 and people[1]==p and options.ServerInstanceId==id)
 visits+=1
end}
local game={JobId=source,PlaceId=78,PrivateServerId='',BindToClose=function() end,GetService=function(_,key)
 return ({Players=players,RunService={IsStudio=function() return false end},TeleportService=tele,MemoryStoreService={GetSortedMap=function() return map end}})[key]
end}
local directory=luau.load(fs.readFile('src/ServerDirectory.luau'),{environment={game=game,Enum=realEnum,Instance={new=function() return {} end},task={spawn=function() end},os={clock=function() return t end,time=function() return t end}},injectGlobals=true})()
directory.start(remote,function() writes+=1;return allowed end)
local function action(kind,target) t+=2;remote.OnServerEvent.fire(p,kind,target) end
action('List');assert(remote.message.Current.Players==1 and remote.message.Rows[1].Id==id)
action('Join',source);assert(visits==0)
row.Players=20;action('Join',id);assert(visits==0 and writes==0)
row.Players=2;row.Updated=t-100;action('Join',id);assert(visits==0)
row.Updated=t;allowed=false;action('Join',id);assert(writes==1 and visits==0)
allowed=true;action('Join',id);assert(writes==2 and visits==1)
action('Join',id);assert(visits==1)
tele.TeleportInitFailed.fire(p);action('Join',id);assert(visits==2)
print('PASS: server browser list, full/stale rejection, checkpoint refusal, exact destination, duplicate prevention, retry after Roblox teleport failure')
