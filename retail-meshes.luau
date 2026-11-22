local rb=require('@lune/roblox')
local props=require('./interior-props')
local CF,V=rb.CFrame,rb.Vector3.new
local function remove(site,names)
 for _,p in site:GetChildren() do if names[p.Name] then p:Destroy() end end
end
local function booth(stock,at)
 local m,s=props.add(stock,'diner-booth','Upholstered diner booth',at,V(10.4,5.2,7.5),false)
 -- Separate bench and table hulls leave the seating spaces open.
 for _,side in {-1,1} do
  props.hull(m,at*CF.new(side*s.X*.37,0,0),V(s.X*.22,s.Y*.42,s.Z*.86))
  local seat=rb.Instance.new('Seat');seat.Name='Diner seat';seat.Size=V(2,.22,1.6)
  seat.CFrame=at*CF.new(side*s.X*.32,s.Y*.45,-s.Z*.10)*CF.Angles(0,side*math.pi/2,0)
  seat.Anchored=true;seat.Transparency=1;seat.CanCollide=false;seat.CanTouch=false;seat.CanQuery=false;seat.Parent=m
  seat:SetAttribute('Action','SitHome');seat:SetAttribute('Label','Sit in booth');seat:SetAttribute('Reach',6);seat:SetAttribute('Hold',.2)
 end
 props.hull(m,at*CF.new(0,0,-s.Z*.03),V(s.X*.39,s.Y*.66,s.Z*.53))
 return m
end
return function(site,stock,frame,width,depth,b)
 local kind=b[3]
 local function place(key,name,x,z,w,h,d,yaw)
  return props.add(stock,key,name,frame*CF.new(x,0,z)*CF.Angles(0,math.rad(yaw or 0),0),V(w,h,d),true)
 end
 if kind=='laundry' then
  remove(site,{Washer=true,['Washer door']=true,Controls=true})
  for i=-2,2 do place('laundry-machines','Stacked washer and dryer',i*7,10,4.5,9,4.2) end
 elseif kind=='barber' then
  remove(site,{['Mirror surround']=true,Mirror=true,['Tool cabinet']=true,['Porcelain worktop']=true,['Pomade tin']=true})
  for _,x in {-12,0,12} do
   -- The supplied workstation includes a small utility chair, kept behind the styling chair.
   place('barber-vanity','Grooming workstation',x,11.8,6,8.7,5.5)
  end
 elseif kind=='clinic' then
  for _,side in {-1,1} do place('clinic-exam','Examination couch',side*14,8,10,5.6,4.5,side*90) end
  place('office-desk','Clinical records',-15,-8,8.8,5,6.5)
  local till=site:FindFirstChild('First aid station')
  if till then
   local position=frame:PointToObjectSpace(till.CFrame.Position)
   till.Transparency=1
   place('checkout-counter','Patient registration counter',position.X,position.Z,8,4.4,3.2)
  end
  for _,side in {-1,1} do
   local at=frame*CF.new(side*26,0,-9)*CF.Angles(0,side*math.pi/2,0)
   local sofa,size=props.add(stock,'waiting-sofa','Clinic waiting sofa',at,V(10,5,4.4),false)
   props.hull(sofa,at,V(size.X*.92,size.Y*.39,size.Z*.85))
   for _,u in {-1,1} do
    local seat=rb.Instance.new('Seat');seat.Name='Waiting seat';seat.Size=V(2,.22,1.6)
    seat.CFrame=at*CF.new(u*size.X*.215,size.Y*.45,-size.Z*.12)
    seat.Anchored=true;seat.Transparency=1;seat.CanCollide=false;seat.CanTouch=false;seat.CanQuery=false;seat.Parent=sofa
    seat:SetAttribute('Action','SitHome');seat:SetAttribute('Label','Wait here');seat:SetAttribute('Reach',6);seat:SetAttribute('Hold',.2)
   end
  end
  -- Waiting-area literature, supplies and reception still occupy the original wall bays.
 elseif kind=='pharmacy' then
  for i=-1,1 do place('office-desk','Prescription consultation',i*17,6.5,8,4.5,5.8) end
 elseif kind=='fuel' then
  -- Replace the exposed middle gondolas; keep the chilled wall and all till/coffee prompts.
  remove(site,{['Gondola plinth']=true,['Retail pegboard']=true,['Gondola shelf']=true,['Boxed groceries']=true,['Package band']=true})
  for _,p in stock:GetChildren() do if p.Name=='Branded snack facing' then p:Destroy() end end
  for _,side in {-1,1} do
   for _,face in {-1,1} do place('stocked-gondola','Two-sided grocery aisle',side*11+face*.80,-3,7.35,5.65,1.6,-face*90) end
  end
  place('store-chiller','Grab-and-go drinks',8,9.7,4.3,5.3,2.4)
 elseif kind=='coffee' or kind=='bakery' or kind=='deli' then
  -- Replace existing table groups at their original locations so the room circulation is unchanged.
  local tables={}
  for _,p in site:GetChildren() do if p.Name=='Oak tabletop' then table.insert(tables,frame:PointToObjectSpace(p.CFrame.Position)) end end
  remove(site,{['Cafe pedestal']=true,['Oak tabletop']=true,['Chair frame']=true,['Chair seat']=true,['Chair back']=true})
  for _,p in tables do booth(stock,frame*CF.new(p.X,0,p.Z)) end
 end
 if kind=='fashion' or kind=='sneakers' then
  -- Detailed hanging garments replace the block garments on the central rails.
  local rails={}
  for _,p in site:GetChildren() do if p.Name=='Hanging rail' then table.insert(rails,frame:PointToObjectSpace(p.CFrame.Position)) end end
  remove(site,{['Rack foot']=true,['Rack upright']=true,['Hanging rail']=true,['Hanger hook']=true,['Garment shoulder']=true,['Hanging garment']=true})
  for _,pos in rails do place('clothing-rail','Streetwear collection',pos.X,pos.Z,8,7,3.6) end
 end
 if kind=='grocery' or kind=='variety' then
  local old={}
  for _,p in site:GetChildren() do if p.Name=='Shelving' then table.insert(old,frame:PointToObjectSpace(p.CFrame.Position)) end end
  remove(site,{Shelving=true,Goods=true})
  for _,pos in old do place('stocked-gondola','Stocked center aisle',pos.X,pos.Z,12,6.3,3.1) end
 end
 -- Checkout furniture is placed at the back perimeter, away from the active cashier's standing point.
 if kind=='hardware' or kind=='camera' or kind=='print' or kind=='art' then
  place('checkout-counter','Service packing counter',width*.30,depth/2-6.3,11,6.5,4.6)
 elseif kind=='bank' then
  for _,side in {-1,1} do place('office-desk','Account service desk',side*14,-8,8.5,4.8,6.3) end
 end
end
