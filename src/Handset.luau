-- The city phone reuses the same app pages as world interactions.
local Tween=game:GetService('TweenService')
local rgb=Color3.fromRGB
local paths={
 Work={{{3,8},{21,8},{21,20},{3,20},{3,8}},{{8,8},{8,5},{16,5},{16,8}},{{3,12},{12,15},{21,12}}},
 ['City map']={{{3,6},{9,3},{15,6},{21,3},{21,18},{15,21},{9,18},{3,21},{3,6}},{{9,3},{9,18}},{{15,6},{15,21}}},
 ['My bag']={{{5,9},{19,9},{20,21},{4,21},{5,9}},{{8,10},{8,6},{10,3},{14,3},{16,6},{16,10}}},
 Dispatch={{{9,3},{15,3},{15,9},{21,9},{21,15},{15,15},{15,21},{9,21},{9,15},{3,15},{3,9},{9,9},{9,3}}},
 ['My home']={{{2,11},{12,3},{22,11}},{{5,10},{5,21},{10,21},{10,15},{14,15},{14,21},{19,21},{19,10}}},
 ['Pay / trade']={{{3,8},{20,8},{16,4}},{{20,8},{16,12}},{{21,16},{4,16},{8,12}},{{4,16},{8,20}}},
 ['Party supplies']={{{3,9},{21,9},{21,13},{3,13},{3,9}},{{5,13},{5,21},{19,21},{19,13}},{{12,21},{12,9},{7,7},{6,4},{9,4},{12,9},{15,4},{18,4},{17,7},{12,9}}},
 Servers={{{4,4},{20,4},{20,10},{4,10},{4,4}},{{4,14},{20,14},{20,20},{4,20},{4,14}},{{7,7},{9,7}},{{7,17},{9,17}}},
 Guide={{{2,5},{7,4},{12,7},{17,4},{22,5},{22,19},{17,18},{12,21},{7,18},{2,19},{2,5}},{{12,7},{12,21}}},
 Phone={{{7,2},{17,2},{19,4},{19,20},{17,22},{7,22},{5,20},{5,4},{7,2}},{{10,18},{14,18}}},
}
return function(gui,modal,title,content,close,make,text,button,openHome)
 local function round(parent,r) make('UICorner',{CornerRadius=UDim.new(0,r)},parent) end
 local function block(parent,name,x,y,w,h,color)
  return make('Frame',{Name=name,Position=UDim2.fromScale(x,y),Size=UDim2.fromScale(w,h),BorderSizePixel=0,BackgroundColor3=color},parent)
 end
 local function icon(parent,key)
  local drawing=make('Frame',{Size=UDim2.fromOffset(22,22),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),BackgroundTransparency=1},parent)
  for _,path in paths[key] do for i=2,#path do
   local a,b=path[i-1],path[i]
   local dx,dy=b[1]-a[1],b[2]-a[2]
   make('Frame',{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale((a[1]+b[1])/48,(a[2]+b[2])/48),Size=UDim2.new(math.sqrt(dx*dx+dy*dy)/24,.7,0,1.7),Rotation=math.deg(math.atan2(dy,dx)),BorderSizePixel=0,BackgroundColor3=rgb(255,255,252)},drawing)
  end end
 end
 local shell=make('Frame',{Name='Handset frame',Size=UDim2.fromScale(1,1),BorderSizePixel=0,BackgroundColor3=rgb(21,23,31),Visible=false,ZIndex=0},modal)
 round(shell,24)
 make('UIStroke',{Thickness=2,Color=rgb(101,105,117)},shell)
 local screen=make('Frame',{Name='Glass',Size=UDim2.new(1,-12,1,-12),Position=UDim2.fromOffset(6,6),BackgroundColor3=rgb(28,34,48),BorderSizePixel=0,ClipsDescendants=true,ZIndex=0},shell)
 round(screen,19)
 local wallpaper=block(screen,'Harbor dusk',0,0,1,1,rgb(255,255,255))
 round(wallpaper,19)
 make('UIGradient',{Rotation=67,Color=ColorSequence.new({ColorSequenceKeypoint.new(0,rgb(37,46,89)),ColorSequenceKeypoint.new(.44,rgb(87,78,128)),ColorSequenceKeypoint.new(.7,rgb(192,116,103)),ColorSequenceKeypoint.new(1,rgb(40,54,79))})},wallpaper)
 local sun=block(wallpaper,'Setting sun',.65,.22,.20,.12,rgb(237,181,136));round(sun,40)
 local silhouette=block(wallpaper,'Skyline',.02,.3,.96,.22,rgb(36,43,69));silhouette.BackgroundTransparency=1
 for i,h in {.24,.41,.32,.74,.54,.69,.94,.44,.38,.64,.41,.54} do
  local tower=block(silhouette,'Harbor tower',(i-1)/12,1-h,.085,h,rgb(55,57,83));tower.BackgroundTransparency=.12
 end
 local clock=text(shell,'',UDim2.fromOffset(76,16),UDim2.fromOffset(16,9),10,rgb(249,249,250))
 local lens=make('Frame',{Size=UDim2.fromOffset(32,7),AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,13),BackgroundColor3=rgb(12,13,17),BorderSizePixel=0},shell);round(lens,5)
 for i=1,3 do make('Frame',{Position=UDim2.new(1,-46+i*3,0,23-i*2),Size=UDim2.fromOffset(2,i*2),BackgroundColor3=rgb(230,235,239),BorderSizePixel=0},shell) end
 local battery=make('Frame',{Position=UDim2.new(1,-28,0,16),Size=UDim2.fromOffset(12,6),BackgroundColor3=rgb(219,232,220),BorderSizePixel=0},shell);round(battery,2)
 local home=button(modal,'',UDim2.new(.46,0,0,24),UDim2.new(.27,0,1,-28),openHome)
 home.Name='Home';home.Visible=false;home.BackgroundTransparency=1
 local gesture=block(home,'Home indicator',.18,.5,.64,.12,rgb(228,229,234));round(gesture,2)
 local launcher=button(gui,'',UDim2.fromOffset(42,42),UDim2.new(1,-58,1,-18),openHome)
 launcher.Name='PHONE';launcher.AnchorPoint=Vector2.new(0,1);launcher.BackgroundColor3=rgb(29,37,47);launcher.BackgroundTransparency=.12
 icon(launcher,'Phone')
 local session=false
 local timeString,dayString='2:24 PM','Monday'
 local homeTime,homeDay
 local function fit()
  if not session then return end
  local size=gui.AbsoluteSize
  if size.X<=0 or size.Y<=0 then return end
  local h=math.min(368,size.Y-16)
  local w=math.min(224,math.floor(h*.63),size.X-20)
  modal.Size=UDim2.fromOffset(w,h)
  modal.AnchorPoint=Vector2.one
  modal.Position=UDim2.new(1,-12,1,-8)
 end
 local function style()
  local atHome=title.Text=='CITY PHONE'
  if not session then return end
  title.Visible=not atHome
  title.TextSize=15
  title.Position=UDim2.fromOffset(17,29)
  title.Size=UDim2.new(1,-60,0,33)
  close.Position=UDim2.new(1,-43,0,28)
  close.Size=UDim2.fromOffset(30,30)
  close.BackgroundTransparency=.68
  content.Position=UDim2.fromOffset(15,atHome and 53 or 67)
  content.Size=UDim2.new(1,-30,1,atHome and -84 or -99)
  wallpaper.Visible=atHome
 end
 local function reset()
  session=false
  shell.Visible=false;home.Visible=false;title.Visible=true
  modal.BackgroundTransparency=0
  modal.Size=UDim2.new(1,-24,1,-24);modal.AnchorPoint=Vector2.new(.5,.5);modal.Position=UDim2.fromScale(.5,.5)
  close.Size=UDim2.fromOffset(35,35);close.Position=UDim2.new(1,-48,0,12);close.BackgroundTransparency=0
  title.TextSize=20;title.Size=UDim2.new(1,-70,0,40);title.Position=UDim2.fromOffset(18,10)
  content.Position=UDim2.fromOffset(15,58);content.Size=UDim2.new(1,-30,1,-65)
  launcher.Visible=true
 end
 local function start()
  local fresh=not session
  session=true;launcher.Visible=false;home.Visible=true;shell.Visible=true;modal.BackgroundTransparency=1
  fit();style()
  if fresh then
   modal.Position=UDim2.new(1,-12,1,22)
   Tween:Create(modal,TweenInfo.new(.16,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=UDim2.new(1,-12,1,-8)}):Play()
  end
 end
 modal:GetPropertyChangedSignal('Visible'):Connect(function() if not modal.Visible and session then reset() end end)
 title:GetPropertyChangedSignal('Text'):Connect(style)
 gui:GetPropertyChangedSignal('AbsoluteSize'):Connect(fit)
 local function setClock(time,day)
  timeString,dayString=time,day
  clock.Text=time
  if homeTime and homeTime.Parent then homeTime.Text=time;homeDay.Text=day end
 end
 local walletLabel
 local function drawApps(apps,openWallet)
  local header=make('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,48),LayoutOrder=1},content)
  homeTime=text(header,timeString,UDim2.new(1,0,0,28),UDim2.new(),25,rgb(255,248,240))
  homeDay=text(header,dayString,UDim2.new(1,0,0,17),UDim2.fromOffset(1,28),12,rgb(247,231,221))
  local grid=make('Frame',{Name='Apps',Size=UDim2.new(1,-2,0,159),LayoutOrder=2,BackgroundTransparency=1},content)
  make('UIGridLayout',{CellSize=UDim2.new(1/3,-3,0,51),CellPadding=UDim2.fromOffset(3,3),SortOrder=Enum.SortOrder.LayoutOrder},grid)
  for i,app in apps do
   local tile=button(grid,'',UDim2.new(),UDim2.new(),app[2])
   tile.Name=app[1];tile.LayoutOrder=i;tile.BackgroundTransparency=1
   local badge=make('Frame',{AnchorPoint=Vector2.new(.5,0),Position=UDim2.fromScale(.5,0),Size=UDim2.fromOffset(33,33),BorderSizePixel=0,BackgroundColor3=app[3]},tile)
   round(badge,9);icon(badge,app[1])
   local label=text(tile,app[1],UDim2.new(1,0,0,16),UDim2.fromOffset(0,34),10,rgb(255,255,255))
   label.TextXAlignment=Enum.TextXAlignment.Center;label.TextStrokeTransparency=.64
  end
  local dock=button(content,'Wallet',UDim2.new(1,-3,0,33),UDim2.new(),openWallet)
  dock.LayoutOrder=3;dock.TextSize=12;dock.TextXAlignment=Enum.TextXAlignment.Left
  dock.BackgroundColor3=rgb(37,42,57);dock.BackgroundTransparency=.12
  make('UIPadding',{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10)},dock)
  walletLabel=text(dock,'$'..tostring(game.Players.LocalPlayer:GetAttribute('Cash') or 0),UDim2.new(.67,0,1,0),UDim2.fromScale(.33,0),13,rgb(218,236,213))
  walletLabel.TextXAlignment=Enum.TextXAlignment.Right
 end
 game.Players.LocalPlayer:GetAttributeChangedSignal('Cash'):Connect(function()
  if walletLabel and walletLabel.Parent then walletLabel.Text='$'..tostring(game.Players.LocalPlayer:GetAttribute('Cash') or 0) end
 end)
 return {start=start,reset=reset,draw=drawApps,clock=setClock,isOpen=function() return session end,launcher=launcher}
end