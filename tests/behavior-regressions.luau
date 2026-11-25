-- Independent boundary scenarios for state transitions that are hard to reproduce by hand.
local Rules=require('../src/StreetCombatRules')
local Brain=require('../src/CivilianBrain')
local Pose=require('../src/CombatPose')
local passed=0
local function case(name,run)
 local ok,err=pcall(run);assert(ok,name..': '..tostring(err));passed+=1
end
local function civilian(personality) return Brain.new(personality or 'cautious',0) end
local function step(s,t,input) input=input or {};input.health=input.health or 100;return Brain.step(s,t,input) end
local function incident(s,kind,id,time) Brain.notice(s,time or 0,{kind=kind,position='corner',suspect=id,seen=id~=nil}) end
local function near(a,b) return math.abs(a-b)<.00001 end
-- SCENARIOS
case('Combatants own independent stamina',function()
 local a,b=Rules.new(0),Rules.new(0);Rules.attack(a,0);assert(b.stamina==100 and b.combo==0)
end)
case('Recovery accepts the exact first-punch boundary',function()
 local s=Rules.new(0);Rules.attack(s,0);assert(Rules.attack(s,.55).combo==2)
end)
case('Recovery rejects the frame before its boundary',function()
 local s=Rules.new(0);Rules.attack(s,0);assert(not Rules.attack(s,.549))
end)
case('Combo window includes its final instant',function()
 local s=Rules.new(0);Rules.attack(s,0);assert(Rules.attack(s,1.05).combo==2)
end)
case('Late follow-up restarts the jab',function()
 local s=Rules.new(0);Rules.attack(s,0);assert(Rules.attack(s,1.051).combo==1)
end)
case('Cross recovery cannot be skipped',function()
 local s=Rules.new(0);Rules.attack(s,0);Rules.attack(s,.55);assert(not Rules.attack(s,1.169))
end)
case('Cross recovery permits the hook on time',function()
 local s=Rules.new(0);Rules.attack(s,0);Rules.attack(s,.55);assert(Rules.attack(s,1.171).combo==3)
end)
case('Hook recovery outlasts jab recovery',function()
 local s=Rules.new(0);Rules.attack(s,0);Rules.attack(s,.6);local a=Rules.attack(s,1.25);assert(a.duration>.6 and not Rules.attack(s,1.9))
end)
case('Completed hook wraps to jab',function()
 local s=Rules.new(0);Rules.attack(s,0);Rules.attack(s,.6);Rules.attack(s,1.25);assert(Rules.attack(s,2.21).combo==1)
end)
case('Missed attack still spends stamina',function()
 local s=Rules.new(0);Rules.attack(s,0);assert(s.stamina==88)
end)
print('PASS behavior boundary regressions:',passed)
