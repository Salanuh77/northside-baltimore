local players=game.Players
local test=game:GetService('StudioTestService')
local drive=game.ReplicatedStorage:WaitForChild('TestDrive')
local city=workspace:WaitForChild('Baltimore')
local function check(ok,msg) assert(ok,msg);print('RETAIL_PASS',msg) end
local function waitFor(f,seconds)
 local deadline=os.clock()+seconds;repeat if f() then return true end;task.wait(.15) until os.clock()>deadline
 return false
end
local function call(p,kind,data) return drive:InvokeClient(p,kind,data or {}) end
local function marker(kind)
 for _,v in city:GetDescendants() do if v:GetAttribute('Action')==kind then return v end end
end
local function approach(p,part,dx)
 local pos=part.Position+part.CFrame.LookVector*(part:GetAttribute('Action')=='Barber' and -4 or 5)+Vector3.new(dx or 0,1.7,0)
 p.Character:PivotTo(CFrame.new(pos));p.Character.HumanoidRootPart.Anchored=true; p:RequestStreamAroundAsync(pos,4);task.wait(.25)
end
local ok,err=pcall(function()
 check(waitFor(function() return #players:GetPlayers()==2 and players:GetPlayers()[2]:GetAttribute('ResidentFiles') and players:GetPlayers()[1]:GetAttribute('ResidentFiles') end,90),'Two account file lists loaded')
 local a,b=table.unpack(players:GetPlayers())
 local library=Instance.new('Folder');library.Name='InteriorTestFixtures';library.Parent=game.ReplicatedStorage
 local models={}
 for _,v in city:GetDescendants() do
  local key=v:GetAttribute('MeshyPropKey')
  if key and not models[key] then models[key]=true;v:Clone().Parent=library end
 end
 for _,key in {'stocked-gondola','store-chiller','checkout-counter','clothing-rail','shoe-wall','bookcase','laundry-machines','barber-vanity','diner-booth','clinic-exam','office-desk','home-wardrobe'} do
  check(models[key],'Imported fixture shipped: '..key)
 end
 local artLoaded,artDetails=call(a,'InteriorArt');check(artLoaded,'Client loaded imported furniture and PBR textures '..tostring(artDetails))
 library:Destroy()
 for _,p in {a,b} do
  check(call(p,'HUD') and not p.Character and not p:GetAttribute('ResidentSlot'),'First-spawn creation')
  call(p,'CreateResident',{Name='',Height='Tall',Build='Broad',Hair='Twists',Tone='Copper'})
  check(waitFor(function() return p:GetAttribute('NeedsCharacter')==false and p.Character and p.Character:FindFirstChild('Head') and p.Character.Head:FindFirstChild('Northside hair') end,22),'Saved resident and visible hairstyle')
 end
 local cut=city:FindFirstChild('Juniper Barber',true);local sign=cut:FindFirstChild('Shift book')
 for _,shopName in {'Juniper Barber','Waverly Barber'} do
  local shop=city:FindFirstChild(shopName,true)
  local seats,models=0,0
  for _,v in shop:GetChildren() do
   if v:IsA('Seat') and v.Name=='Swivel seat' then seats+=1 end
   if v:IsA('MeshPart') and v.Name=='Barber chair' then
    assert(v.MeshId~='' and v.TextureID~='' and math.abs(v.Size.Y-7.2)<.05,'Chair needs its imported mesh and upholstery')
    models+=1
   end
  end
  check(seats==3 and models==3,shopName..' has three textured styling chairs and seats')
 end
 local chair; for _,v in cut:GetChildren() do if v:GetAttribute('Station')=='BarberChair' then chair=v end end
 workspace:SetAttribute('TestMinute',60);task.wait(1.4)
 call(b,'ApplyJob',{Role='barber'});call(b,'StartShift')
 check(b:GetAttribute('ShiftTask')=='','Barber shop off shift overnight')
 workspace:SetAttribute('TestMinute',600);task.wait(1.3)
 check(city:GetAttribute('CityMinute')==600 and math.abs(game.Lighting.ClockTime-10)<.03,'Daylight and city clocks share one time')
 approach(b,sign);call(b,'StartShift');call(b,'Prompt',sign)
 check((b:GetAttribute('ShiftTask') or ''):find('customer')~=nil,'Barber clocked in')
 approach(b,chair,2);approach(a,chair,-2)
 call(a,'Cut',{Style='High puff',Color='Burgundy'});call(b,'ServeCut',{Customer=a.UserId})
 check(a:GetAttribute('Cash')==470 and b:GetAttribute('Wages')==30,'Customer pays working barber')
 local puff=a.Character.Head:FindFirstChild('Hair mesh',true)
 check(puff and puff.Color==require(game.ReplicatedStorage.StreetStyle).Dyes.Burgundy,'Player barber applies the selected dye')
 call(a,'Cut',{Style='High puff',Color='Burgundy'})
 call(a,'Cut',{Style='Twists',Color='Unknown dye'})
 check(a:GetAttribute('Cash')==470 and b:GetAttribute('Wages')==30,'Duplicate and invalid dyes do not charge the customer')
 local mirror={FaceShape='Diamond',FaceWidth='Narrow',EyeSpacing='Wide',LipFullness='Full',Expression='Focused',Mouth='Set',Eye='Hazel',Detail='Clean',Hair='Shaved'}
 call(a,'MirrorLook',mirror)
 local function sculpt() return a.Character.Head:FindFirstChild('Head sculpt',true).MeshId end
 check(sculpt()==game.ReplicatedStorage.ResidentProfiles:FindFirstChild('Diamond',true).MeshId,'Mirror switches the visible head profile')
 check(a.Character.Head:FindFirstChild('Hair mesh',true).MeshId==puff.MeshId and a:GetAttribute('Cash')==470,'Mirror preserves paid hair and cash')
 local clothing=marker('Clothing');approach(a,clothing)
 mirror.FaceShape='Square';call(a,'MirrorLook',mirror)
 check(sculpt()==game.ReplicatedStorage.ResidentProfiles:FindFirstChild('Diamond',true).MeshId,'Mirror cannot restyle a resident across town')
 call(a,'Outfit',{Item='pier-varsity'});call(a,'Outfit',{Item='pier-varsity'})
 check(a:GetAttribute('Cash')==375 and a.Character:FindFirstChildOfClass('Shirt').ShirtTemplate:find(game.ReplicatedStorage.StreetStyle:GetAttribute('pier-varsity'),1,true)~=nil,'Original varsity outfit bought once and equipped')
 approach(a,marker('Sporting'));call(a,'Prompt',marker('Sporting'))
 check(call(a,'ShopIdentity','sports'),'Athletics shop shows the illustrated operator emblem')
 check(call(a,'ItemCard',{Key='Bat',Price='$80',Buy=true}),'Athletics picture card completes a real purchase')
 check(a.Backpack:FindFirstChild('Bat') and a:GetAttribute('Cash')==295,'Athletics sells cash bats')
 approach(a,marker('Market'));call(a,'Buy',{Item='Knife'});call(a,'Buy',{Item='Pistol'})
 check(a.Backpack:FindFirstChild('Knife') and not a.Backpack:FindFirstChild('Pistol') and a:GetAttribute('Cash')==240,'Knife for cash, gun store cash bypass rejected')
 local probe=game.ServerStorage:WaitForChild('TestReceipt')
 local function receipt(who,id,order) return probe:Invoke(who,{PlayerId=who.UserId,ProductId=id,PurchaseId=order}) end
 check(receipt(a,3732000729,'studio-sidearm')=='PurchaseGranted' and receipt(a,3732000729,'studio-sidearm')=='PurchaseGranted','Duplicate sidearm receipt acknowledged')
 check(a.Backpack:FindFirstChild('Pistol'),'Sidearm delivered')
 local spot=marker('GunStore');approach(a,spot,-2);approach(b,spot,2)
 call(a,'ArmoryFinish',{Finish='Field carbine'})
 check(a.Backpack.Pistol:FindFirstChild('Stock silhouette') and a.Backpack.Pistol:GetAttribute('Ammo')==12,'Included carbine appearance preserves the purchased loadout')
 call(a,'Offer',{Item='Pistol',Target=b.UserId,Amount=110});call(b,'Accept')
 check(a:GetAttribute('Cash')==350 and b:GetAttribute('Cash')==420 and not a.Backpack:FindFirstChild('Pistol') and b.Backpack:FindFirstChild('Pistol'),'One sidearm transferred once for city cash')
 check(receipt(a,3732000733,'studio-party')=='PurchaseGranted','Party product receipt')
 call(a,'PartyItem',{Item='Glow'});check(a.Character.HumanoidRootPart:FindFirstChild('Harbor glow'),'Purchased glow effect used')
 check(receipt(a,3732000729,'studio-sidearm')=='PurchaseGranted' and not a.Backpack:FindFirstChild('Pistol'),'Receipt replay preserves completed trade')
 check(receipt(a,3732068679,'studio-sampler')=='PurchaseGranted','Sampler grants on the resident file')
 for _,item in {'Bubbles','Streamers'} do call(a,'PartyItem',{Item=item});check(a.Character.HumanoidRootPart:FindFirstChild(item),'Purchased party effect: '..item) end
 local images,seen={},{}
 for _,key in {'store-emblems-a','store-emblems-b'} do
  local loaded,detail=call(a,'PreloadArt',{'rbxassetid://'..game.ReplicatedStorage.BrandIdentity:GetAttribute(key)})
  check(loaded,'Transparent business logo atlas loaded '..key..' '..tostring(detail))
 end
 for _,v in city:GetDescendants() do
  if v.Name=='Alley paint' then
   local id=v:FindFirstChildWhichIsA('ImageLabel',true).Image
   if not seen[id] then table.insert(images,id);seen[id]=true end
  end
 end
 for _,key in {'fleet-track','indigo-denim','pier-varsity','foundry-work','harbor-warmup','clay-workshirt','olive-overshirt','street-denim','mouth-level','mouth-smile','mouth-set','washed-denim','canvas-trousers','washed-denim-black','street-denim-black','canvas-trousers-black','resident-calm','resident-focused','resident-smile'} do
  table.insert(images,'rbxassetid://'..game.ReplicatedStorage.StreetStyle:GetAttribute(key))
 end
 check(#images==23,'Mural sheets, streetwear and face textures present')
 local loaded,details=call(a,'PreloadArt',images);check(loaded,'Client loaded transparent paint and clothing textures '..tostring(details))
 local cafe=assert(city:FindFirstChild('Harbor Roasters',true))
 local booth=assert(cafe:FindFirstChild('Upholstered diner booth',true))
 local seat=assert(booth:FindFirstChildWhichIsA('Seat'))
 local boothFrame=booth:GetAttribute('FurnitureFrame')
 local boothSize=booth:GetAttribute('FurnitureSize')
 local seatOffset=boothFrame:PointToObjectSpace(seat.Position)
 local entry=boothFrame:PointToWorldSpace(Vector3.new(seatOffset.X,3,-boothSize.Z/2-1.5))
 a:RequestStreamAroundAsync(entry,5)
 a.Character.HumanoidRootPart.Anchored=false
 a.Character:PivotTo(CFrame.new(entry));task.wait(.5)
 call(a,'Prompt',seat)
 check(waitFor(function() return seat.Occupant==a.Character.Humanoid end,3),'New diner booth accepts a seated resident')
 call(a,'StandUp')
 check(waitFor(function() return not seat.Occupant and not a.Character.Humanoid.SeatPart end,3),'Resident stands out of the diner booth')
 check(call(a,'WalkTo',entry),'Resident can walk away from the diner booth')
 workspace:SetAttribute('TestMinute',1200);task.wait(1.4)
 check(city:GetAttribute('CityMinute')==1200 and math.abs(game.Lighting.ClockTime-20)<.03,'Night lighting and city time')
end)
print(ok and 'NORTHSIDE_RETAIL_PASS' or 'NORTHSIDE_RETAIL_FAIL',tostring(err))
test:EndTest({ok=ok,error=tostring(err)})
