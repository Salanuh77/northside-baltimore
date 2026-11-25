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
print('PASS behavior boundary regressions:',passed)
