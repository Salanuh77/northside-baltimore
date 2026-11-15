local remote=game.ReplicatedStorage:WaitForChild('CityServers')
local player=game.Players.LocalPlayer
local dialog,body,status
local cream=Color3.fromRGB(244,238,217)
local dark=Color3.fromRGB(24,39,42)
local function control(class,parent,text)
 local obj=Instance.new(class);obj.BackgroundColor3=Color3.fromRGB(48,68,71)
 obj.TextColor3=cream;obj.Text=text;obj.Font=Enum.Font.GothamMedium;obj.TextSize=15
 obj.BorderSizePixel=0;obj.Parent=parent;return obj
end
local function close()
 if dialog then dialog:Destroy();dialog=nil end
end
local function refresh()
 status.Text='Finding public servers…';remote:FireServer('List')
end
remote.OnClientEvent:Connect(function(action,data)
 if not dialog then return end
 if action=='Status' then status.Text=data;return end
 if action~='List' then return end
 for _,child in body:GetChildren() do if child:IsA('GuiObject') then child:Destroy() end end
 local function row(text,id)
  local item=control(id and 'TextButton' or 'TextLabel',body,text)
  item.Size=UDim2.new(1,-6,0,42);item.LayoutOrder=#body:GetChildren()
  if id then item.Activated:Connect(function()
   status.Text='Joining server…';remote:FireServer('Join',id)
  end) end
 end
 row(('%s   ·   %d / %d'):format(data.Current.Name,data.Current.Players,data.Current.Capacity))
 for _,v in data.Rows do
  local open=v.Players<v.Capacity
  row(('City %s   ·   %d / %d   ·   %s'):format(v.Id:sub(1,6):upper(),v.Players,v.Capacity,open and 'Join' or 'Full'),open and v.Id or nil)
 end
 status.Text=data.Message or (#data.Rows==0 and 'No other public servers are running.' or 'Choose a city to join.')
end)
local function open()
 if dialog then return end
 dialog=Instance.new('ScreenGui');dialog.Name='CityServerBrowser';dialog.DisplayOrder=40;dialog.ResetOnSpawn=false;dialog.Parent=player.PlayerGui
 local shade=Instance.new('TextButton');shade.Text='';shade.AutoButtonColor=false;shade.BackgroundColor3=Color3.new();shade.BackgroundTransparency=.22;shade.Size=UDim2.fromScale(1,1);shade.Parent=dialog
 shade.Activated:Connect(close)
 local panel=Instance.new('Frame');panel.Active=true;panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.5);panel.Size=UDim2.fromScale(.9,.85);panel.BackgroundColor3=dark;panel.BorderSizePixel=0;panel.Parent=dialog
 local limit=Instance.new('UISizeConstraint');limit.MaxSize=Vector2.new(520,520);limit.Parent=panel
 local title=control('TextLabel',panel,'City servers');title.TextXAlignment=Enum.TextXAlignment.Left;title.TextSize=24;title.BackgroundTransparency=1;title.Position=UDim2.fromOffset(16,10);title.Size=UDim2.new(1,-110,0,40)
 local exit=control('TextButton',panel,'Close');exit.Size=UDim2.fromOffset(70,36);exit.Position=UDim2.new(1,-86,0,12);exit.Activated:Connect(close)
 body=Instance.new('ScrollingFrame');body.Size=UDim2.new(1,-32,1,-126);body.Position=UDim2.fromOffset(16,60);body.AutomaticCanvasSize=Enum.AutomaticSize.Y;body.CanvasSize=UDim2.new();body.BackgroundTransparency=1;body.ScrollBarThickness=4;body.BorderSizePixel=0;body.Parent=panel
 local list=Instance.new('UIListLayout');list.SortOrder=Enum.SortOrder.LayoutOrder;list.Padding=UDim.new(0,6);list.Parent=body
 status=control('TextLabel',panel,'');status.TextWrapped=true;status.TextSize=13;status.BackgroundTransparency=1;status.TextXAlignment=Enum.TextXAlignment.Left;status.Position=UDim2.new(0,16,1,-55);status.Size=UDim2.new(1,-130,0,45)
 local reload=control('TextButton',panel,'Refresh');reload.Size=UDim2.fromOffset(85,37);reload.Position=UDim2.new(1,-101,1,-52);reload.Activated:Connect(refresh)
 refresh()
end
return {open=open}
