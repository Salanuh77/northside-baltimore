local Compass = {}
Compass.bounds = {west=-790, north=-605, width=1520, depth=1705}
function Compass.project(x,z)
 local b=Compass.bounds
 return (x-b.west)/b.width,(z-b.north)/b.depth
end
function Compass.heading(x,z)
 return math.deg(math.atan2(x,-z))
end
function Compass.pin(make,map)
 local pin=make('Frame',{Name='Resident heading',Size=UDim2.fromOffset(23,23),AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=Color3.fromRGB(22,32,41),BorderSizePixel=0,ZIndex=6},map)
 make('UICorner',{CornerRadius=UDim.new(1,0)},pin)
 make('UIStroke',{Thickness=1.5,Color=Color3.fromRGB(101,229,235)},pin)
 make('TextLabel',{Text='▲',Font=Enum.Font.GothamBold,TextSize=17,TextColor3=Color3.new(1,1,1),Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ZIndex=7},pin)
 return pin
end
return Compass
