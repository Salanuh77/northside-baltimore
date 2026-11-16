local catalog=require(game:GetService('ReplicatedStorage'):WaitForChild('WorkCatalog'))
local offers={}
for _,job in catalog do offers[job.Id]=job end
return function(city,event,profiles,jobs,sync,tell,heat)
 local stops={}
 for _,p in city:GetDescendants() do
  if p:GetAttribute('Station') then stops[p:GetAttribute('Station')]=p end
 end
 local function route(player,job,index)
  local taskInfo=job.Stops[index]
  local marker=stops[taskInfo[1]]
  if not marker then return false end
  local from=player.Character and player.Character:FindFirstChild('HumanoidRootPart')
  if not from then return false end
  local instruction=taskInfo[2]..' • '..(marker.Parent:GetAttribute('RetailBrand') or marker.Parent.Name)
  jobs[player]={role=job.Id,step=index,dest=marker,earliest=os.clock()+(from.Position-marker.Position).Magnitude/65}
  player:SetAttribute('ShiftTask',instruction)
  event:FireClient(player,'Job',{Position=marker.Position,Text=instruction})
  return true
 end
 local function finish(player)
  jobs[player]=nil
  player:SetAttribute('ShiftTask','')
  event:FireClient(player,'Job',false)
 end
 local function handle(player,kind,data)
  local d=profiles[player]
  if kind=='ApplyJob' then
   local job=offers[data.Role]
   if not job then return end
   if jobs[player] then return tell(player,'Finish or cancel your shift first.') end
   d.Employment=job.Id; sync(player)
   tell(player,'Application accepted by '..job.Employer..'. Start a shift on your phone.')
  elseif kind=='StartShift' then
   local job=offers[d.Employment]
   if not job then return tell(player,'Apply for a job on your phone first.') end
   if jobs[player] then return tell(player,'A shift is already active.') end
   if job.Start and (game.Lighting.ClockTime-job.Start)%24 >= (job.Close-job.Start)%24 then return tell(player,string.format('Next shift opens at %02d:00 city time.',job.Start)) end
   if route(player,job,1) then tell(player,'Shift started • '..job.Title) end
  elseif kind=='CancelShift' then
   finish(player); tell(player,'Shift cancelled.')
  elseif kind=='Resign' then
   finish(player); d.Employment=''; sync(player); tell(player,'You left your job.')
  end
 end
 local function interact(player,marker)
  local shift=jobs[player]
  if not shift or not shift.role or shift.dest~=marker then return tell(player,'Check your phone for your assigned work stop.') end
  local job=offers[shift.role]
  if os.clock()<shift.earliest then return tell(player,'Your dispatch is still in transit. Try again shortly.') end
  if job.Id=='barber' and shift.step==2 then return tell(player,'Accept a nearby customer?s haircut request to earn your fee.') end
  if shift.step<#job.Stops then
   route(player,job,shift.step+1)
   tell(player,'Pickup recorded. Your next stop is marked.')
  else
   finish(player)
   local d=profiles[player]
   d.Cash+=job.Pay; d.Wages+=job.Pay
   if job.Illegal then heat(player,1) else sync(player) end
    tell(player,'Shift complete • +$'..job.Pay..(job.Illegal and ' • Wanted level increased.' or ''))
  end
 end
 return {handle=handle,interact=interact,finish=finish,offers=offers}
end