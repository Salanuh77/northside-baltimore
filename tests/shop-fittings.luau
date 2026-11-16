local fs=require('@lune/fs')
local rb=require('@lune/roblox')
local game=rb.deserializePlace(fs.readFile('Northside Baltimore - Heritage Harbor.rbxl'))
local storage=game:GetService('ReplicatedStorage')
local city=game:GetService('Workspace').Baltimore
for _,label in {'haste-markdown','last-season','forever-tuesday'} do
 assert(tonumber(storage.StreetStyle:GetAttribute(label)),label..' missing wearable texture')
end
local staffed,shops,cases=0,0,0
local roles={}
local stations={}
for _,piece in city:GetDescendants() do
 if piece:GetAttribute('StaffSpot') then
  staffed+=1;roles[piece:GetAttribute('StaffRole')]=true
  assert(typeof(piece:GetAttribute('StaffSpot'))=='CFrame')
  stations[piece.Parent]=true
 end
 if piece.Name=='Bakery display case' then
  assert(piece:IsA('MeshPart') and piece.Anchored and not piece.CanCollide);cases+=1
 end
 if piece:GetAttribute('Action')=='Clothing' then
  local mannequin=piece.Parent:FindFirstChild('Window dress form')
  assert(mannequin and mannequin:IsA('MeshPart') and mannequin.Anchored and not mannequin.CanCollide)
  shops+=1
 end
end
for _,p in city:GetDescendants() do
 local kind=p:GetAttribute('Action')
 if kind=='Clothing' or kind=='Mart' or kind=='Barber' or kind=='Sporting' or kind=='GunStore' or kind=='Coffee' then
  assert(stations[p.Parent],p.Parent.Name..' needs a staffed counter')
 end
end
for _,r in {'Grocer','Club host','Stylist','Barista','Barber','Mart cashier','Bank teller','Clinic registrar','Booking clerk'} do assert(roles[r],r) end
local detention=assert(city:FindFirstChild('Patapsco Detention Center',true))
assert(detention:FindFirstChild('Booking safety glass') and detention:FindFirstChild('Bail receipt'))
for _,model in city['Gas stations']:GetChildren() do
 local till=model:FindFirstChild('Mart till')
 if till then
  assert(model['Cash drawer']:GetAttribute('Action')=='Store' and model['Cash drawer']:GetAttribute('SecondaryPrompt'))
  assert(till:FindFirstChild('LCD panel') and model:FindFirstChild('Cooler strip'):FindFirstChildOfClass('SpotLight'))
  assert(model:FindFirstChild('Chilled drink') and model:FindFirstChild('Cooler glass').Transparency>.5)
 end
end
assert(city:FindFirstChild('Hollins Row 1503',true):FindFirstChild('Porch lantern'):GetAttribute('DuskLamp'))
assert(shops==2 and cases>=1 and staffed>=20)
assert(storage.ServiceCap:IsA('MeshPart'))
assert(city:FindFirstChild('Occupied tower bay',true):GetAttribute('EveningGlass'))
print('PASS shop staff stations',staffed,'clothing counters',shops,'bakery cases',cases)
