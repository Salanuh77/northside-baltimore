-- Exercise each listing against the stations baked into the actual release place.
local fs=require('@lune/fs')
local luau=require('@lune/luau')
local rb=require('@lune/roblox')
local place=rb.deserializePlace(fs.readFile('Northside Baltimore - Heritage Harbor.rbxl'))
local stationList,stations={},{}
for _,part in place:GetService('Workspace').Baltimore:GetDescendants() do
 local key=part:GetAttribute('Station')
 if key then
  assert(not stations[key],key..' is ambiguous')
  local marker={Parent=part.Parent,Position=part.CFrame.Position,GetAttribute=function(_,arg) return arg=='Station' and key or nil end}
  stations[key]=marker; table.insert(stationList,marker)
 end
end
local clock=0
local catalog=require('../src/WorkCatalog')
local storage={WaitForChild=function() return 'WorkCatalog' end}
local lighting={ClockTime=12}
local loadService=luau.load(fs.readFile('src/WorkService.luau'),{
 debugName='WorkService',environment={game={Lighting=lighting,GetService=function() return storage end},require=function() return catalog end,os={clock=function() return clock end}},injectGlobals=true,
})()
local root={Position=rb.Vector3.zero}
local user={Character={FindFirstChild=function() return root end},SetAttribute=function(self,name,value) self[name]=value end}
local d={Cash=500,Wages=0,Heat=0,Employment=''}
local jobs={}
local service=loadService({GetDescendants=function() return stationList end},{FireClient=function() end},{[user]=d},jobs,function() end,function() end,function(_,n) d.Heat+=n end)
for _,job in catalog do
 local pickup,drop=stations[job.Stops[1][1]],stations[job.Stops[2][1]]
 assert(pickup and drop and pickup~=drop,job.Id)
 local opening,career,heat=d.Cash,d.Wages,d.Heat
 root.Position=pickup.Position; service.handle(user,'ApplyJob',{Role=job.Id})
 if job.Start then
  lighting.ClockTime=job.Close;service.handle(user,'StartShift',{});assert(not jobs[user],'Closed shift accepted')
  lighting.ClockTime=job.Start
 end
 service.handle(user,'StartShift',{})
 service.interact(user,drop); assert(jobs[user].step==1 and d.Cash==opening)
 service.interact(user,pickup); assert(jobs[user].step==2)
 service.interact(user,drop); assert(d.Cash==opening)
 clock+=100; root.Position=drop.Position; service.interact(user,drop); service.interact(user,drop)
 if job.Id=='barber' then assert(jobs[user] and d.Cash==opening,'Barber paid without a customer');service.finish(user);print('CONTRACT_PASS',job.Id);continue end
 assert(d.Cash==opening+job.Pay and d.Wages==career+job.Pay and not jobs[user])
 assert(d.Heat==heat+(job.Illegal and 1 or 0)); print('CONTRACT_PASS',job.Id,job.Pay)
end