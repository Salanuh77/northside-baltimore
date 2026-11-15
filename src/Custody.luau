local Players=game:GetService('Players')
local symbols={'Wave','Bell','Star','Key'}
return function(city,event,profiles,sync,tell,closest,closeActions)
 local prison=city:WaitForChild('Patapsco Detention Center')
 local intake=prison.Intake.Position
 local puzzles={}
 local function move(p,position)
  local char=p.Character; local h=char and char:FindFirstChildOfClass('Humanoid')
  if not h or not char:FindFirstChild('HumanoidRootPart') then return end
  h.Sit=false; h:UnequipTools(); h.WalkSpeed=16
  char:PivotTo(CFrame.new(position+Vector3.new(0,3,0)))
 end
 local function publish(p,d)
  p:SetAttribute('CustodyUntil',d.CustodyUntil or 0); p:SetAttribute('Bail',d.Bail or 0); sync(p)
 end
 local function release(p,escaped)
  local d=profiles[p]; if not d or (d.CustodyUntil or 0)==0 then return end
  d.CustodyUntil=0; d.Bail=0; puzzles[p]=nil
  d.Heat=escaped and 3 or 0; d.HeatNext=os.clock()+30
  move(p,escaped and prison['Escape landing'].Position or prison.Release.Position)
  publish(p,d); event:FireClient(p,'PrisonClose')
  tell(p,escaped and 'Light Run complete. You escaped and are wanted again.' or 'Released from Patapsco.')
 end
 local function arrest(p)
  local d=profiles[p]; if not d or d.Heat<1 or (d.CustodyUntil or 0)>os.time() then return false end
  local level=d.Heat; closeActions(p)
  d.CustodyUntil=os.time()+45+15*level; d.Bail=60+20*level; d.Heat=0
  p:SetAttribute('Surrendered',false); move(p,intake); publish(p,d)
  tell(p,'Booked at Patapsco for '..(45+15*level)..' seconds. Bail $'..d.Bail..'. Visit the dayroom terminals.'); return true
 end
 local function restore(p)
  local d=profiles[p]; if not d then return end
  if (d.CustodyUntil or 0)>os.time() then move(p,intake); publish(p,d)
  elseif (d.CustodyUntil or 0)>0 then release(p,false) else publish(p,d) end
 end
 local function prompt(p,kind)
  local d=profiles[p]
  if kind=='BailDesk' then
   local list={}
   for other,row in profiles do
    if (row.CustodyUntil or 0)>os.time() and ((d.CustodyUntil or 0)==0 or p==other) then
     table.insert(list,{Id=other.UserId,Name=other.DisplayName,Cost=row.Bail})
    end
   end
   event:FireClient(p,'BailDesk',list); return
  end
  if (d.CustodyUntil or 0)<=os.time() then return end
  if os.clock()<(d.PuzzleReady or 0) then return tell(p,'The recreation terminal is resetting.') end
  local sequence={}
  for i=1,4 do sequence[i]=symbols[math.random(#symbols)] end
  puzzles[p]={sequence=sequence,index=1,expires=os.clock()+24}
  event:FireClient(p,'LightRun',sequence)
 end
 local function handle(p,kind,data)
  local d=profiles[p]
  if kind=='PostBail' then
   if type(data.Target)~='number' or data.Target%1~=0 or not closest(p,'BailDesk') then return end
   local target=Players:GetPlayerByUserId(data.Target); local td=profiles[target]
   if not td or (td.CustodyUntil or 0)<=os.time() or ((d.CustodyUntil or 0)>0 and target~=p) then return tell(p,'That booking is closed.') end
   if d.Cash<td.Bail then return tell(p,'You need $'..td.Bail..' cash for this booking.') end
   local amount=td.Bail; d.Cash-=amount; release(target,false); sync(p); tell(p,'Paid $'..amount..' bail.'); return
  end
  local puzzle=puzzles[p]
  if not puzzle or (d.CustodyUntil or 0)<=os.time() then return end
  if not closest(p,'EscapeGame') or os.clock()>puzzle.expires or puzzle.sequence[puzzle.index]~=data.Symbol then
   puzzles[p]=nil; d.PuzzleReady=os.clock()+5; event:FireClient(p,'PrisonClose'); return tell(p,'Light Run missed. Try again in five seconds.')
  end
  puzzle.index+=1
  if puzzle.index>#puzzle.sequence then release(p,true) else event:FireClient(p,'LightStep',puzzle.index) end
 end
 task.spawn(function()
  while task.wait(.5) do
   for p,d in profiles do
    if (d.CustodyUntil or 0)>0 then
     if d.CustodyUntil<=os.time() then release(p,false)
     else
      local root=p.Character and p.Character:FindFirstChild('HumanoidRootPart')
      if root then
       local offset=root.Position-intake
       if math.abs(offset.X)>40 or offset.Z< -28 or offset.Z>27 or offset.Y>18 or offset.Y< -2 then move(p,intake) end
      end
     end
    end
   end
  end
 end)
 Players.PlayerRemoving:Connect(function(p) puzzles[p]=nil end)
 return {arrest=arrest,restore=restore,prompt=prompt,handle=handle}
end
