local rb,fs=require('@lune/roblox'),require('@lune/fs')
local city=rb.deserializePlace(fs.readFile('Northside Baltimore - Heritage Harbor.rbxl')):GetService('Workspace').Baltimore
for _,name in {'Chesapeake Gallery','North Avenue Fuel','Juniper Barber','NORTHSIDE CLINIC','Calvert Pharmacy','HARBOR FREIGHT','Harbor Roasters'} do
 local site=city:FindFirstChild(name,true);local floor=site:FindFirstChild('Floor') or site:FindFirstChild('Hall floor') or site:FindFirstChild('Shop floor') or site:FindFirstChild('Tile floor') or site:FindFirstChild('Terrazzo floor')
 print(name,floor.Size)
 for _,p in site:GetChildren() do
  if p:GetAttribute('StaffSpot') then print('STAFF',p.Name,floor.CFrame:PointToObjectSpace(p:GetAttribute('StaffSpot').Position)) end
 end
 for _,p in site:GetDescendants() do
  if p:GetAttribute('MeshyPropKey') then print(p.Name,p:GetAttribute('MeshyPropKey'),floor.CFrame:PointToObjectSpace(p:GetAttribute('FurnitureFrame').Position),p:GetAttribute('FurnitureSize')) end
 end
end
