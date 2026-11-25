local Rules=require('../src/SocietyRules');local Dialogue=require('../src/NpcDialogue')
assert(Rules.routine(23,.3)=='Heading home' and Rules.routine(12,.3)=='Shopping')
local d={};local first=Dialogue.choose(d,{event='greeting'},function() return 0 end)
assert(Dialogue.choose(d,{event='greeting'},function() return 0 end)~=first,'Do not repeat the last line')
local _,context=Dialogue.choose({}, {hour=23,routine='Shopping'},function() return 0 end);assert(context=='shopping')
local input={now=100,ready=0,distance=4,visible=true,health=100,heat=1,corrupt=true,cash=300}
local outcome,cost=Rules.bribe(input);assert(outcome=='accepted' and cost==150)
for _,field in {'violent','armed','custody'} do input[field]=true;assert(Rules.bribe(input)~='accepted');input[field]=false end
input.corrupt=false;assert(Rules.bribe(input)=='refused');input.corrupt=true
input.cash=149;assert(Rules.bribe(input)=='insufficient');input.cash=300
input.distance=8;assert(Rules.bribe(input)=='unavailable');input.distance=4
input.ready=101;assert(Rules.bribe(input)=='unavailable')
local memory={}
local action=Rules.police(memory,1,{valid=true,visible=true,position='corner',distance=20})
assert(action.mode=='Pursuing suspect')
action=Rules.police(memory,5,{valid=true,visible=false,position='hidden',distance=3})
assert(action.goal=='corner' and action.mode=='Searching for suspect','Hidden targets cannot update last sighting')
assert(Rules.police(memory,20,{valid=true,visible=false}).mode=='Clear','Search expires')
Rules.police(memory,21,{valid=true,visible=true,position='street',distance=3,surrendered=true})
assert(Rules.police(memory,22.3,{valid=true,visible=true,position='street',distance=3,surrendered=true}).arrest)
local crime={age=60,health=100,distance=20,active=1,now=100,ready=90}
assert(Rules.canStartCrime(crime));crime.protected=true;assert(not Rules.canStartCrime(crime));crime.protected=false
crime.active=2;assert(not Rules.canStartCrime(crime),'Incidents have a population-independent cap')
print('PASS context dialogue, routines, crime cap, bribery eligibility, honest refusal and sight-limited police search')
