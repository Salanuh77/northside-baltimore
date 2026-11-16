local compass=require(game.ReplicatedStorage:WaitForChild('MapCompass'))
local rgb=Color3.fromRGB
return function(gui,make,text,city)
 local touch=game:GetService('UserInputService').TouchEnabled
 local size=touch and Vector2.new(107,64) or Vector2.new(145,82)
 local root=make('Frame',{Name='StreetRadar',Size=UDim2.fromOffset(size.X,size.Y+6),AnchorPoint=Vector2.new(0,touch and 0 or 1),Position=touch and UDim2.fromOffset(9,4) or UDim2.new(0,16,1,-18),BackgroundColor3=rgb(19,25,26),BorderSizePixel=0},gui)
 local map=make('Frame',{Name='Neighborhood',ClipsDescendants=true,Size=UDim2.new(1,-4,1,-8),Position=UDim2.fromOffset(2,2),BackgroundColor3=rgb(63,77,73),BorderSizePixel=0},root)
 local layer=make('Frame',{Size=UDim2.fromOffset(0,0),BackgroundTransparency=1},map)
 local zoom=touch and .28 or .35
 local roads=game:GetService('HttpService'):JSONDecode(city:GetAttribute('RadarRoads') or '[]')
 for _,r in roads do
  make('Frame',{Size=UDim2.fromOffset(math.max(2,r[3]*zoom),math.max(2,r[4]*zoom)),Position=UDim2.fromOffset(r[1]*zoom,r[2]*zoom),AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=rgb(137,150,141),BorderSizePixel=0},layer)
 end
 local arrow=compass.pin(make,map)
 arrow.Position=UDim2.fromScale(.5,.5)
 local tap=make('TextButton',{Name='Open map',Text='',BackgroundTransparency=1,Size=UDim2.fromScale(1,1),ZIndex=9},map)
 local blip=make('Frame',{Name='Active destination',AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(8,8),Rotation=45,ZIndex=4,Visible=false,BackgroundColor3=rgb(255,198,91),BorderSizePixel=0},map)
 make('UIStroke',{Thickness=1.5,Color=rgb(49,37,23)},blip)
 local north=text(map,'N',UDim2.fromOffset(13,15),UDim2.fromOffset(3,1),10,Color3.new(1,1,1));north.TextStrokeTransparency=.3
 local fill=make('Frame',{Name='Health',Position=UDim2.new(0,2,1,-5),Size=UDim2.new(1,-4,0,3),BackgroundColor3=rgb(109,203,149),BorderSizePixel=0},root)
 local wallet=text(gui,'',UDim2.fromOffset(155,25),UDim2.new(1,-167,0,4),19,rgb(179,232,184))
 wallet.Font=Enum.Font.GothamBold;wallet.TextXAlignment=Enum.TextXAlignment.Right;wallet.TextStrokeTransparency=.22
 local status=text(gui,'',UDim2.fromOffset(210,29),UDim2.new(1,-222,0,27),14,rgb(255,208,125))
 status.TextXAlignment=Enum.TextXAlignment.Right;status.TextStrokeTransparency=.18
 local fuel=text(root,'',UDim2.new(1,0,0,17),UDim2.new(0,2,0,touch and size.Y+8 or -18),12,Color3.new(1,1,1))
 fuel.TextStrokeTransparency=.2
 local function update(characterRoot,humanoid,destination)
  local point=characterRoot.Position
  layer.Position=UDim2.new(.5,-point.X*zoom,.5,-point.Z*zoom)
  local look=(humanoid.SeatPart or characterRoot).CFrame.LookVector
  arrow.Rotation=compass.heading(look.X,look.Z)
  blip.Visible=typeof(destination)=='Vector3'
  if blip.Visible then
   local half=map.AbsoluteSize/2
   local delta=Vector2.new(destination.X-point.X,destination.Z-point.Z)*zoom
   local factor=math.max(1,math.abs(delta.X)/math.max(1,half.X-5),math.abs(delta.Y)/math.max(1,half.Y-5))
   blip.Position=UDim2.new(.5,delta.X/factor,.5,delta.Y/factor)
  end
  local hp=math.clamp(humanoid.Health/math.max(1,humanoid.MaxHealth),0,1)
  fill.Size=UDim2.new(hp,-4*hp,0,3)
  local seat=humanoid.SeatPart
  local gas=seat and seat.Parent:GetAttribute('Fuel')
  fuel.Text=gas and ('Fuel '..gas..'%') or ''
 end
 return {update=update,wallet=wallet,status=status,tap=tap}
end