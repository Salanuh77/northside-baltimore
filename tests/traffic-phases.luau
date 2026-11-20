local phases=require('../src/TrafficPhases')
for _,offset in {0,4,13,28} do
 local total={Green=0,Amber=0,Red=0,clear=0,walk=0,hand=0,dark=0}
 for t=0,33 do
  local a,walk=phases.at(t,0,offset)
  local b,otherWalk=phases.at(t,1,offset)
  assert(a=='Red' or b=='Red')
  assert(walk=='Stop' or a=='Green')
  assert(otherWalk=='Stop' or b=='Green')
  assert(walk=='Walk' or walk=='Stop' or walk=='Clear','Unknown crossing state')
  assert(a==phases.at(t+34,0,offset))
  total[a]+=1; if a=='Red' and b=='Red' then total.clear+=1 end
  if walk=='Walk' then total.walk+=1 end
  if a=='Green' and walk=='Stop' then total.hand+=1 end
  if walk=='Clear' then total.dark+=1 end
 end
 assert(total.Green==12 and total.Amber==3 and total.clear==4 and total.walk==9 and total.hand==2 and total.dark==1,'Nine walk seconds followed by a three-second flashing hand')
end
print('PASS coordinated opposing signals, amber, clearance, pedestrian phases and offsets')
