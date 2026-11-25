-- Context-selected original lines. Never invent a witnessed crime or repeat advice.
local Dialogue={}
local lines={
 morning={'Trying to get this shift over with.','Coffee first. Everything else can wait.','Been up since six. Long day already.'},
 evening={'Just grabbing something before I head home.','Finally off work. My feet are done.','The block is still busy tonight.'},
 night={'I am heading in. It is getting late.','Still waiting on my ride.','One more stop, then I am done for the night.'},
 shopping={'They moved everything in this store again.','I came for one thing. Watch me leave with five.','Let me see what I have left after groceries.'},
 social={'We were just catching up. You good?','Hold on, I have not seen them all week.','Same corner, different story every day.'},
 greeting={'What is good?','You doing alright?','How is your day going?','Just passing through. You need something?','Been a minute since this block was quiet.'},
 familiar={'You again. Everything alright?','Still out here?','Good to see you made it back.'},
 warning={'Give me a little room.','Watch where you are going.','You are standing right on me.'},
 fleeing={'I am not staying for this.','Get out of the street!','Nope. I am gone.'},
 defending={'Back up!','I said leave me alone.','You picked the wrong person.'},
 reporting={'Send someone to this corner. Somebody got jumped.','I just saw a fight. We need an officer.','There is trouble outside. I am stepping away.'},
 robbery={'Hand it over. Do not make this worse.','Keep your hands where I can see them.','You heard me. Empty your pockets.'},
 argument={'You still owe me from last week.','I already told you, I do not have it.','Quit coming around starting something.'},
 surrender={'Alright, alright. My hands are up.','I am stopping. Do not shoot.','Okay. I am not running.'},
 officer={'Police. Stop right there.','Keep your hands up and stay still.','Do not reach for anything.'},
 corrupt={'Keep it quiet. I did not see anything.','This is the only time. Move along.','We are done here. Keep walking.'},
 refused={'Put that money away.','That is not how this works.','You are making this worse for yourself.'},
 shoppingDone={'Got what I needed.','That cost more than I thought.','Alright. Time to go.'},
}
function Dialogue.choose(state,context,random)
 local key=context.event
 if not key then
  if context.familiar then key='familiar'
  elseif context.routine=='Shopping' then key='shopping'
  elseif context.routine=='Meeting a neighbor' then key='social'
  elseif context.hour and (context.hour>=22 or context.hour<6) then key='night'
  elseif context.hour and context.hour<10 then key='morning'
  elseif context.hour and context.hour>=18 then key='evening'
  else key='greeting' end
 end
 local list=lines[key] or lines.greeting
 local index=math.clamp(math.floor(random()*#list)+1,1,#list)
 if list[index]==state.last then index=index%#list+1 end
 state.last=list[index];return state.last,key
end
function Dialogue.say(model,text,now)
 if not model.Parent or not model:FindFirstChild('Head') or now<(model:GetAttribute('SpeechReady') or 0) then return false end
 model:SetAttribute('SpeechReady',now+4)
 local old=model.Head:FindFirstChild('Citizen speech');if old then old:Destroy() end
 local gui=Instance.new('BillboardGui');gui.Name='Citizen speech';gui.Size=UDim2.fromOffset(230,64);gui.StudsOffset=Vector3.new(0,2.2,0);gui.MaxDistance=42;gui.Parent=model.Head
 local label=Instance.new('TextLabel');label.Size=UDim2.fromScale(1,1);label.BackgroundColor3=Color3.fromRGB(24,28,31);label.BackgroundTransparency=.15
 label.TextColor3=Color3.fromRGB(244,240,227);label.Font=Enum.Font.GothamMedium;label.TextSize=14;label.TextWrapped=true;label.Text=text;label.Parent=gui
 local corner=Instance.new('UICorner');corner.CornerRadius=UDim.new(0,8);corner.Parent=label
 game:GetService('Debris'):AddItem(gui,4);return true
end
return Dialogue
