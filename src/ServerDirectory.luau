local Directory={}

local function fresh(row,now)
 return type(row)=='table' and type(row.Players)=='number' and type(row.Capacity)=='number'
  and row.Players>=0 and row.Capacity>0 and type(row.Updated)=='number' and row.Updated>now-90
end
function Directory.available(row,now)
 return fresh(row,now) and row.Players<row.Capacity
end
function Directory.choices(records,current,now)
 local rows={}
 for _,record in records do
  local row=record.value
  if record.key~=current and fresh(row,now) then
   table.insert(rows,{Id=record.key,Players=row.Players,Capacity=row.Capacity})
  end
 end
 table.sort(rows,function(a,b)
  if (a.Players<a.Capacity)~=(b.Players<b.Capacity) then return a.Players<a.Capacity end
  if a.Players~=b.Players then return a.Players>b.Players end
  return a.Id<b.Id
 end)
 return rows
end

function Directory.start(remote,checkpoint)
 local players=game:GetService('Players')
 local teleport=game:GetService('TeleportService')
 local live=not game:GetService('RunService'):IsStudio()
 local map=live and game:GetService('MemoryStoreService'):GetSortedMap('NorthsidePublic-'..game.PlaceId)
 local function snapshot()
  return {Players=#players:GetPlayers(),Capacity=players.MaxPlayers,Updated=os.time()}
 end
 local running=true
 if map and game.PrivateServerId=='' then
  task.spawn(function()
   while running do
    local row=snapshot()
    pcall(function() map:SetAsync(game.JobId,row,90,row.Updated) end)
    task.wait(20)
   end
  end)
  game:BindToClose(function()
   running=false
   pcall(function() map:RemoveAsync(game.JobId) end)
  end)
 end
 local previous,transferring={},{}
 local cachedRows,lastRead={},-100
 local function fail(p,message)
  transferring[p]=nil
  if p.Parent then remote:FireClient(p,'Status',message) end
 end
 teleport.TeleportInitFailed:Connect(function(p)
  if transferring[p] then fail(p,'Transfer failed. Refresh to choose another server.') end
 end)
 players.PlayerRemoving:Connect(function(p) previous[p]=nil;transferring[p]=nil end)
 remote.OnServerEvent:Connect(function(p,action,id)
  local now=os.clock()
  if action~='List' and action~='Join' then return end
  local times=previous[p] or {};previous[p]=times
  if now<(times[action] or 0) then
   remote:FireClient(p,'Status','Please wait a moment and try again.');return
  end
  times[action]=now+1
  if action=='List' then
   local message
   if map and now-lastRead>=5 then
    local ok,records=pcall(function() return map:GetRangeAsync(Enum.SortDirection.Descending,100) end)
    if ok then cachedRows=Directory.choices(records,game.JobId,os.time());lastRead=now
    else message='Directory unavailable. Refresh to try again.' end
   end
   local current=snapshot();current.Id=game.JobId
   current.Name=live and (game.PrivateServerId~='' and 'Private server' or 'Current server') or 'Studio session'
   if not live then message='Public servers appear when playing on Roblox.' end
   remote:FireClient(p,'List',{Current=current,Rows=cachedRows,Message=message})
  elseif action=='Join' then
   if transferring[p] or type(id)~='string' or #id~=36 or not id:match('^[%x%-]+$') or id==game.JobId or not map then
    if not transferring[p] then remote:FireClient(p,'Status','Choose another available public server.') end
    return
   end
   transferring[p]=true
   local ok,row=pcall(function() return map:GetAsync(id) end)
   if not ok or not Directory.available(row,os.time()) then return fail(p,'This server is full or has closed. Refresh the list.') end
   if not checkpoint(p) then return fail(p,'Your file is still saving. Try again in a moment.') end
   if not p.Parent then return end
   local options=Instance.new('TeleportOptions');options.ServerInstanceId=id
   local sent=pcall(function() teleport:TeleportAsync(game.PlaceId,{p},options) end)
   if not sent then fail(p,'Roblox could not start the transfer. Try again.') end
  end
 end)
end
return Directory
