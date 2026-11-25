local Rules={}
function Rules.routine(hour,roll)
 if hour>=22 or hour<6 then return roll<.7 and 'Heading home' or 'Night walk' end
 if roll<.42 then return 'Shopping' end
 if roll<.65 then return 'Meeting a neighbor' end
 return 'Taking a break'
end
function Rules.canStartCrime(i)
 return i.age>=55 and i.health>65 and not i.busy and not i.danger and not i.protected and i.distance<48 and i.active<2 and i.now>=i.ready
end
function Rules.bribe(i)
 if i.now<i.ready or i.distance>7 or not i.visible or i.custody or i.health<=0 or i.heat<1 then return 'unavailable',0 end
 if i.violent or i.armed or i.heat>2 then return 'refused',0 end
 if not i.corrupt then return 'refused',0 end
 if i.cash<150 then return 'insufficient',0 end
 return 'accepted',150
end
function Rules.police(s,now,i)
 if not i.valid then return {mode='Clear'} end
 if i.visible then s.lastSeen=i.position;s.seenAt=now end
 if not s.seenAt or now-s.seenAt>18 then return {mode='Clear'} end
 if not i.visible then s.cuffAt=nil;return {mode='Searching for suspect',goal=s.lastSeen} end
 if i.surrendered and i.distance<4.8 then
  s.cuffAt=s.cuffAt or now
  return {mode='Making arrest',arrest=now-s.cuffAt>=1.2}
 end
 s.cuffAt=nil
 return {mode=i.surrendered and 'Approaching surrender' or 'Pursuing suspect',goal=s.lastSeen}
end
return Rules
