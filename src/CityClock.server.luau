local lighting=game:GetService('Lighting')
local city=workspace:WaitForChild('Baltimore')
local streetLight=require(script.Parent.StreetLighting)
local hands,lamps,windows={},{},{}
local wasNight
for _,p in city:GetDescendants() do
 if (p.Name=='Warm lamp' or p:GetAttribute('DuskLamp')) and p:FindFirstChildOfClass('PointLight') then table.insert(lamps,p) end
 if p:GetAttribute('EveningGlass') then table.insert(windows,p) end
 if p:GetAttribute('ClockPivot') then table.insert(hands,p) end
end
-- One city minute per real second, synchronized across servers.
while true do
 local total=math.floor(workspace:GetServerTimeNow())
 local minutes=total%1440
 lighting.ClockTime=minutes/60
 streetLight(lighting,minutes/60)
 local night=minutes<360 or minutes>=1140
 if night~=wasNight then
  for _,lamp in lamps do lamp.PointLight.Enabled=night;lamp.Material=night and Enum.Material.Neon or Enum.Material.Glass end
  for _,window in windows do
   window.Color=window:GetAttribute(night and 'EveningGlass' or 'DayGlass')
   window.Material=night and Enum.Material.Neon or Enum.Material.SmoothPlastic
  end
  wasNight=night
 end
 city:SetAttribute('CityMinute',minutes)
 city:SetAttribute('CityDay',math.floor(total/1440)%7+1)
 for _,p in hands do
  local rotation=p.Name=='Clock minute hand' and minutes%60/60 or minutes%720/720
  p.CFrame=p:GetAttribute('ClockPivot')*CFrame.Angles(0,0,rotation*2*math.pi)*CFrame.new(0,p.Size.Y/2,0)
 end
 task.wait(1)
end
