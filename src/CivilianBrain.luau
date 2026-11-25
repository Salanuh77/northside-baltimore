-- Hierarchical priorities: incapacitation > danger > social interaction > routine.
-- A remembered position is a snapshot. Hearing never grants suspect identity.
local Brain={}
function Brain.new(personality,now)
 return {personality=personality or 'cautious',mode='Walking',since=now,talkUntil=0,recoverUntil=0}
end
function Brain.notice(s,now,incident)
 if s.mode=='Dead' then return end
 local old=s.threat
 if old and (old.kind=='assault' or old.kind=='gunfire') and incident.kind=='weapon' then return end
 local same=old and old.kind==incident.kind and old.suspect==incident.suspect and now-old.time<3
 s.threat={kind=incident.kind,position=incident.position,time=now,
  suspect=incident.seen and incident.suspect or nil,victim=incident.victim==true,reported=same and old.reported or false}
 s.talkUntil=0;s.reportAt=nil
end
function Brain.step(s,now,i)
 local mode,report='Walking',nil
 local t=s.threat
 if t and now-t.time>=18 then s.threat=nil;t=nil;s.recoverUntil=now+3;s.reportAt=nil end
 if i.health<=0 then mode='Dead'
 elseif i.ragdoll then mode='Knocked down'
 elseif t then
  local armed=i.armed or t.kind=='gunfire'
  if t.kind=='weapon' and i.visibleThreat and (i.distance or 100)>8 then mode='Wary'
  elseif t.kind=='assault' and t.victim and s.personality=='bold' and i.visibleThreat and not armed and (i.distance or 100)<9 and i.health>35 and now-t.time<7 then mode='Defending'
  elseif i.safeDistance then
   if t.suspect and not t.reported and t.kind~='weapon' then
    mode='Reporting';s.reportAt=s.reportAt or now
    if now-s.reportAt>=2.5 then report={suspect=t.suspect,position=t.position,time=t.time};t.reported=true end
   else mode='Cowering';s.reportAt=nil end
  else mode='Fleeing';s.reportAt=nil end
 elseif now<s.recoverUntil then mode='Recovering'
 elseif i.talk or now<s.talkUntil then
  if i.talk then s.talkUntil=now+4 end;mode='Talking';s.crowdedAt=nil
 elseif i.crowded then
  s.crowdedAt=s.crowdedAt or now;mode=now-s.crowdedAt>2 and 'Warning' or 'Yielding'
 elseif i.arrived then mode='Idling';s.crowdedAt=nil
 else s.crowdedAt=nil end
 if mode~='Reporting' then s.reportAt=nil end
 if mode~=s.mode then s.mode=mode;s.since=now end
 return {mode=mode,report=report,threat=t and t.position}
end
return Brain
