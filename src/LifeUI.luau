local Players=game:GetService('Players')
local cards=require(game.ReplicatedStorage:WaitForChild('ItemCard'))
local catalog=require(game.ReplicatedStorage:WaitForChild('ItemCatalog'))
return function(p,event,modal,title,clear,row,paragraph,notify)
 local pins={}
 local function pin(key,data)
  if pins[key] then pins[key]:Destroy(); pins[key]=nil end
  if not data then return end
  local base=Instance.new('Part'); base.Size=Vector3.one; base.Transparency=1; base.Anchored=true; base.CanCollide=false; base.CanQuery=false; base.CanTouch=false; base.Position=data.Position+Vector3.new(0,9,0); base.Parent=workspace
  local bb=Instance.new('BillboardGui'); bb.Size=UDim2.fromOffset(230,42); bb.AlwaysOnTop=true; bb.Parent=base
  local label=Instance.new('TextLabel'); label.Size=UDim2.fromScale(1,1); label.Text=data.Text; label.TextSize=15; label.TextColor3=Color3.fromRGB(247,201,115); label.BackgroundTransparency=.35; label.Parent=bb; pins[key]=base
 end
 local track,connection
 local function dance()
  local h=p.Character and p.Character:FindFirstChildOfClass('Humanoid'); local animator=h and h:FindFirstChildOfClass('Animator')
  if not animator then return end
  if connection then connection:Disconnect(); connection=nil end
  if track and track.IsPlaying then track:Stop(); return end
  local anim=Instance.new('Animation'); anim.AnimationId=h.RigType==Enum.HumanoidRigType.R15 and 'rbxassetid://507771019' or 'rbxassetid://182435998'
  local ok,result=pcall(function() return animator:LoadAnimation(anim) end); anim:Destroy()
  if ok then track=result; track.Looped=true; track.Priority=Enum.AnimationPriority.Action; track:Play(); connection=h.Running:Connect(function(speed) if speed>2 then track:Stop(); connection:Disconnect(); connection=nil end end) end
 end
 local function bag()
  clear('MY BAG')
  for _,item in {'Water','Coffee','Sandwich','Bandage','Flashlight'} do
   local entry=catalog[item];local count=p:GetAttribute('Bag'..item) or 0
   local card=cards.decorate(row('',function() if count>0 then event:FireServer('UseSupply',{Item=item}) end end),entry.Icon,entry.Name,entry.Description,count>0 and ('USE · '..count..' in bag') or 'NOT OWNED')
   card.button.Selectable=count>0;card.button.Active=count>0
  end
 end
 local function homes()
  clear('HOME & PARTIES')
  local address=p:GetAttribute('Residence'); paragraph(address and address~='' and address or 'Use an apartment intercom to claim a home for this server. Voucher units are free. Harbor East waterfront leases cost $200.')
  if address and address~='' then
   if p:GetAttribute('Hosting') then
    row('End party',function() event:FireServer('EndParty') end)
    for _,g in Players:GetPlayers() do if g~=p then row('Invite '..g.DisplayName,function() event:FireServer('InviteParty',{Target=g.UserId}) end) end end
   else row('Start party at home',function() event:FireServer('HostParty') end) end
   row('Release residence',function() event:FireServer('ReleaseHome') end)
  end
  if p:GetAttribute('InvitedBy') then row('Accept pending invitation',function() event:FireServer('PartyReply',{Accept=true}); modal.Visible=false end) end
  if pins.party then row('Leave party',function() event:FireServer('LeaveParty'); modal.Visible=false end) end
  row('Dance / stop',function() modal.Visible=false; dance() end)
 end
 local function dispatch()
  clear('CITY DISPATCH')
  row('Request a paramedic',function() event:FireServer('CallResponder',{Role='medic'}) end)
  row('Request police processing',function() event:FireServer('CallResponder',{Role='police'}) end)
  local role=p:GetAttribute('Employment'); if role=='police' or role=='medic' then row('View calls on duty',function() event:FireServer('DispatchList') end) end
 end
 for _,attr in {'Hosting','Residence','InvitedBy','BagWater','BagCoffee','BagSandwich','BagBandage','BagFlashlight'} do
  p:GetAttributeChangedSignal(attr):Connect(function() if modal.Visible and title.Text=='HOME & PARTIES' then homes() elseif modal.Visible and title.Text=='MY BAG' then bag() end end)
 end
 event.OnClientEvent:Connect(function(kind,data)
  if kind=='Mart' then
   clear('FUEL MART')
   for _,key in {'Water','Coffee','Sandwich','Bandage','Flashlight'} do
    local entry=catalog[key]
    cards.decorate(row('',function() event:FireServer('BuySupply',{Item=key}) end),entry.Icon,entry.Name,entry.Description,'$'..entry.Price)
   end
   row('Open my bag',bag)
  elseif kind=='Residence' then
   clear(data.Name:upper()); paragraph(data.Taken and 'This unit has a tenant.' or ('Session lease  •  '..(data.Price==0 and 'No move-in fee' or '$'..data.Price)))
   if not data.Taken then row('Claim residence',function() event:FireServer('Lease'); modal.Visible=false end) end; row('Home & parties',homes)
  elseif kind=='PartyInvite' then
   clear('HOUSE PARTY'); paragraph(data.Host..' invited you to '..data.Address..'.')
   row('Accept & mark address',function() event:FireServer('PartyReply',{Accept=true}); modal.Visible=false end); row('Decline',function() event:FireServer('PartyReply',{Accept=false}); modal.Visible=false end)
  elseif kind=='PartyRoute' then pin('party',data)
  elseif kind=='Dance' then dance()
  elseif kind=='Club' then clear('MERIDIAN / DJ BOOTH'); row('Switch DJ tempo',function() event:FireServer('ClubMix') end); row('Dance / stop',function() modal.Visible=false; dance() end)
  elseif kind=='DispatchList' then
   clear('ACTIVE DISPATCH'); if #data==0 then paragraph('No active calls. Complete your regular duty route from the phone.') end
   for _,v in data do row('Mark '..v.Name,function() pin('dispatch',{Position=v.Position,Text='DISPATCH • '..v.Name}); modal.Visible=false end); row('Assist '..v.Name..' in person',function() event:FireServer('Assist',{Target=v.Id}); modal.Visible=false end) end
  end
 end)
 return {bag=bag,homes=homes,dispatch=dispatch}
end
