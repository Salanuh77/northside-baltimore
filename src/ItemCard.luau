local theme=require(game.ReplicatedStorage.UITheme)
local images=require(game.ReplicatedStorage.ItemThumbnail)
local Card={}
function Card.decorate(button,key,name,description,price,options)
 button.Name='Item '..key;button.Text='';button:SetAttribute('ItemKey',key)
 if options then button:SetAttribute('WeaponId',options.Weapon);button:SetAttribute('AttachmentId',options.Attachment) end
 button.Size=UDim2.new(1,-6,0,116);button.BackgroundColor3=theme.Surface
 for _,v in button:GetChildren() do if v:IsA('UIPadding') then v:Destroy() end end
 local frame=Instance.new('Frame');frame.Name='Product';frame.BackgroundColor3=theme.Raised
 frame.BorderSizePixel=0;frame.Parent=button
 images.attach(frame,key,options)
 local function label(value,size,color,font)
  local l=Instance.new('TextLabel');l.BackgroundTransparency=1;l.Text=value;l.Font=font or theme.BodyFont
  l.TextSize=size;l.TextColor3=color;l.TextXAlignment=Enum.TextXAlignment.Left;l.TextWrapped=true;l.Parent=button;return l
 end
 local heading=label(name,15,theme.Text)
 local detail=label(description,12,theme.Muted)
 local cost=label(price,14,theme.Accent);cost.Name='Price'
 local function layout()
  local compact=button.AbsoluteSize.X<260;local side=compact and 52 or 84
  frame.Position=UDim2.fromOffset(8,12);frame.Size=UDim2.fromOffset(side,88)
  local x=side+20
  heading.Position=UDim2.fromOffset(x,8);heading.Size=UDim2.new(1,-x-10,0,34)
  detail.Position=UDim2.fromOffset(x,42);detail.Size=UDim2.new(1,-x-10,0,39)
  cost.Position=UDim2.fromOffset(x,84);cost.Size=UDim2.new(1,-x-10,0,24)
 end
 local function focus() heading.TextColor3=theme.Background;detail.TextColor3=theme.Background;cost.TextColor3=theme.Background end
 local function blur() heading.TextColor3=theme.Text;detail.TextColor3=theme.Muted;cost.TextColor3=theme.Accent end
 button.MouseEnter:Connect(focus);button.SelectionGained:Connect(focus)
 button.MouseLeave:Connect(blur);button.SelectionLost:Connect(blur)
 button:GetPropertyChangedSignal('AbsoluteSize'):Connect(layout);layout()
 return {button=button,price=cost,heading=heading,detail=detail}
end
return Card
