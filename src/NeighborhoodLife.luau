local Players=game:GetService('Players')
local costs={Water={4,8},Sandwich={9,22},Bandage={15,35},Flashlight={25,0}}
return function(city,event,profiles,closest,near,sync,tell)
 local homes,open,guests,invites={}, {}, {}, {}
 local club=city:FindFirstChild('DJ console',true)
 local music=club:FindFirstChildOfClass('Sound')
 local tiles={}
 for _,v in club.Parent:GetChildren() do if v:GetAttribute('BeatTile') then table.insert(tiles,v) end end
 music:Play()
 local function stop(host)
  local home=homes[host]
  open[host]=nil
  if home then
   local audio=home:FindFirstChild('HouseMix'); if audio then audio:Destroy() end
   local light=home:FindFirstChild('Party light'); if light then light:Destroy() end
  end
  host:SetAttribute('Hosting',false)
  for guest in Players:GetPlayers() do
   if invites[guest]==host then invites[guest]=nil; guest:SetAttribute('InvitedBy',nil) end
   if guests[guest]==host then guests[guest]=nil; event:FireClient(guest,'PartyRoute',false) end
  end
 end
 local function release(host)
  stop(host); local home=homes[host]
  if home then home:SetAttribute('Tenant',nil) end
  homes[host]=nil; host:SetAttribute('Residence','')
 end
 Players.PlayerRemoving:Connect(function(p) release(p); invites[p]=nil; guests[p]=nil end)
 task.spawn(function()
  local colors={Color3.fromRGB(55,142,150),Color3.fromRGB(147,79,139),Color3.fromRGB(236,165,83)}
  local i=0
  while club.Parent do
   task.wait(.8); i+=1
   for _,v in tiles do v.Color=colors[(v:GetAttribute('BeatTile')+i)%3+1] end
   for host in open do local h=homes[host]; local l=h and h:FindFirstChild('Party light'); if l then l.Color=colors[i%3+1] end end
  end
 end)
 local function buy(p,item)
  if type(item)~='string' or not costs[item] or not closest(p,'Mart') then return end
  local d=profiles[p]; local count=d.Supplies[item] or 0
  if count>=(item=='Flashlight' and 1 or 10) then return tell(p,'Your bag is full for this item.') end
  if d.Cash<costs[item][1] then return tell(p,'You need more cash.') end
  d.Cash-=costs[item][1]; d.Supplies[item]=count+1; sync(p); tell(p,item..' added to your phone bag.')
 end
 local function use(p,item)
  local d=profiles[p]; if type(item)~='string' or not costs[item] or (d.Supplies[item] or 0)<1 then return end
  local h=p.Character and p.Character:FindFirstChildOfClass('Humanoid')
  if not h or h.Health<=0 then return end
  if item=='Flashlight' then
   local head=p.Character:FindFirstChild('Head'); if not head then return end
   local lamp=head:FindFirstChild('Handlamp')
   if lamp then lamp:Destroy() else lamp=Instance.new('SpotLight'); lamp.Name='Handlamp'; lamp.Range=45; lamp.Angle=65; lamp.Brightness=3; lamp.Parent=head end
   return
  end
  if h.Health>=h.MaxHealth then return tell(p,'Your health is full. The item stays in your bag.') end
  d.Supplies[item]-=1; h.Health=math.min(h.MaxHealth,h.Health+costs[item][2]); sync(p); tell(p,'Used '..item..'.')
 end
 local function handle(p,kind,data)
  local home=homes[p]
  if kind=='BuySupply' then buy(p,data.Item)
  elseif kind=='UseSupply' then use(p,data.Item)
  elseif kind=='Lease' then
   local marker=closest(p,'Residence'); if not marker then return end
   if home==marker then return tell(p,'This is already your home.') end
   if home then return tell(p,'Release your current residence from your phone first.') end
   if marker:GetAttribute('Tenant') then return tell(p,'This home has a tenant.') end
   local price=marker:GetAttribute('LeasePrice') or 0; local d=profiles[p]
   if d.Cash<price then return tell(p,'Insufficient cash for this lease.') end
   d.Cash-=price; homes[p]=marker; marker:SetAttribute('Tenant',p.UserId); p:SetAttribute('Residence',marker:GetAttribute('Address')); sync(p)
   tell(p,'Residence reserved for this server. Open Phone → Home & parties.')
  elseif kind=='ReleaseHome' then release(p)
  elseif kind=='HostParty' then
   if not home or not near(p,home.Position,20) then return tell(p,'Start the party from your leased home.') end
   if open[p] then return end
   open[p]=true; p:SetAttribute('Hosting',true)
   local light=Instance.new('PointLight'); light.Name='Party light'; light.Brightness=2; light.Range=24; light.Parent=home
   local sound=music:Clone(); sound.Name='HouseMix'; sound.Volume=.23; sound.RollOffMaxDistance=36; sound.Parent=home; sound:Play()
   tell(p,'Party started. Invite players from your phone.')
  elseif kind=='EndParty' then stop(p)
  elseif kind=='InviteParty' then
   if not open[p] or type(data.Target)~='number' or data.Target%1~=0 then return end
   local target=Players:GetPlayerByUserId(data.Target)
   if not target or p==target or invites[target]==p or guests[target]==p then return end
   invites[target]=p; target:SetAttribute('InvitedBy',p.UserId)
   event:FireClient(target,'PartyInvite',{Host=p.DisplayName,Address=home:GetAttribute('Address')})
  elseif kind=='PartyReply' then
   local host=invites[p]; invites[p]=nil; p:SetAttribute('InvitedBy',nil)
   if data.Accept==true and host and open[host] and homes[host] then
    guests[p]=host; local marker=homes[host]
    event:FireClient(p,'PartyRoute',{Position=marker.Position,Text=marker:GetAttribute('Address')}); tell(host,p.DisplayName..' accepted the invitation.')
   end
  elseif kind=='LeaveParty' then guests[p]=nil; event:FireClient(p,'PartyRoute',false)
  elseif kind=='ClubMix' then
   if not closest(p,'Club') then return end
   local now=os.clock(); if now<(club:GetAttribute('MixReady') or 0) then return end
   club:SetAttribute('MixReady',now+5); music.PlaybackSpeed=music.PlaybackSpeed>1 and 1 or 1.12; tell(p,'DJ tempo changed.')
  end
 end
 local function refuel(p,pump)
  local best,dist=nil,20
  local human=p.Character and p.Character:FindFirstChildOfClass('Humanoid')
  local seat=human and human.SeatPart
  for _,car in city['Motor pool']:GetChildren() do
   local driver=car.Driver.Occupant; local delta=(car.Chassis.Position-pump.Position).Magnitude
   if delta<dist and (not seat or seat==car.Driver) and (not driver or driver.Parent==p.Character) then best=car; dist=delta end
  end
  if not best then return tell(p,'Park a car beside this pump first.') end
  if best.Chassis.AssemblyLinearVelocity.Magnitude>3 then return tell(p,'Stop beside the pump to fill up.') end
  local gas=best:GetAttribute('Fuel') or 100; if gas>=100 then return tell(p,'Tank is full.') end
  local cost=math.ceil((100-gas)/5); local d=profiles[p]
  if d.Cash<cost then return tell(p,'Refill costs $'..cost..'.') end
  d.Cash-=cost; best:SetAttribute('Fuel',100); sync(p); tell(p,'Tank filled for $'..cost..'.')
 end
 return {handle=handle,refuel=refuel,costs=costs}
end