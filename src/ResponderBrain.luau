-- Deterministic gameplay policy. Perception and damage remain server-owned.
local Brain={}
function Brain.new() return {ammo=12,nextShot=0,burst=0,seenAt=nil,cuffAt=nil,target=nil} end
function Brain.step(s,now,i)
 if not i.valid or i.expired then
  s.seenAt=nil;s.cuffAt=nil;s.target=nil;s.threatAt=nil
  return {mode='Patrolling'}
 end
 if s.target~=i.id then s.target=i.id;s.seenAt=nil;s.cuffAt=nil;s.burst=0;s.threatAt=nil end
 if not i.visible then s.seenAt=nil;s.cuffAt=nil
 elseif not s.seenAt then s.seenAt=now end
 if i.visible and i.distance<=4.5 and (i.surrendered or (i.health<25 and i.speed<3)) then
  s.cuffAt=s.cuffAt or now
  return {mode='Making arrest',arrest=now-s.cuffAt>=1,goal=i.goal}
 end
 s.cuffAt=nil
 if not i.threat or not i.visible or i.surrendered then s.threatAt=nil end
 if i.surrendered and i.visible then return {mode='Approaching surrender',goal=i.goal} end
 if s.ammo==0 then
  s.reloadAt=s.reloadAt or now+2.2
  if now<s.reloadAt then return {mode='Reloading',goal=i.goal,cover=true} end
  s.ammo=12;s.reloadAt=nil;s.burst=0;s.nextShot=now+.25
 end
 if not i.visible then return {mode='Searching',goal=i.goal} end
 if not i.threat then return {mode='Requesting surrender',goal=i.goal} end
 s.threatAt=s.threatAt or now
 local fire=i.clearShot~=false and now-s.seenAt>=.75 and now-s.threatAt>=.45 and now>=s.nextShot and i.distance<=70
 if fire then
  s.ammo-=1;s.burst+=1
  s.nextShot=now+(s.burst>=3 and .9 or .2)
  if s.burst>=3 then s.burst=0 end
 end
 return {mode='Engaging',goal=i.goal,fire=fire,cover=i.ownHealth<45}
end
return Brain
