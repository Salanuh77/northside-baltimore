-- Original deterministic melee policy; the server supplies time and confirmed hits.
local Rules={}
local punches={
 {windup=.18,recovery=.55,damage=9,cost=12},
 {windup=.22,recovery=.62,damage=11,cost=15},
 {windup=.3,recovery=.95,damage=17,cost=22},
}
function Rules.new(now)
 return {phase='Idle',combo=0,stamina=100,updated=now,ready=0,lastAttack=-100,stunUntil=0,serial=0}
end
function Rules.update(s,now)
 local dt=math.max(0,now-s.updated);s.updated=now
 s.stamina=math.clamp(s.stamina+dt*(s.phase=='Blocking' and -5 or now>=s.ready and 14 or 0),0,100)
 if s.phase=='Blocking' and s.stamina<=0 then s.phase='Stunned';s.stunUntil=now+.9;s.serial+=1 end
 if (s.phase=='Stunned' or s.phase=='Knocked down') and now>=s.stunUntil then s.phase='Idle' end
 if s.phase=='Attacking' and now>=s.ready then s.phase='Idle' end
 return s
end
function Rules.attack(s,now)
 Rules.update(s,now)
 if s.phase~='Idle' or now<s.ready or now<s.stunUntil then return end
 local combo=now-s.lastAttack<=1.05 and s.combo%3+1 or 1
 local p=punches[combo];if s.stamina<p.cost then return end
 s.combo=combo;s.lastAttack=now;s.ready=now+p.recovery;s.stamina-=p.cost;s.phase='Attacking';s.serial+=1
 return {combo=combo,damage=p.damage,windup=p.windup,duration=p.recovery,serial=s.serial,knockdown=combo==3}
end
function Rules.guard(s,now,enabled)
 Rules.update(s,now)
 if not enabled then if s.phase=='Blocking' then s.phase='Idle' end;return true end
 if s.phase~='Idle' and s.phase~='Blocking' or now<s.stunUntil or now<s.ready or s.stamina<=0 then return false end
 s.phase='Blocking';s.combo=0;return true
end
function Rules.hit(s,now,damage,frontal,finisher)
 Rules.update(s,now)
 local blocked=s.phase=='Blocking' and frontal
 local cost=damage*1.8;local broken=blocked and s.stamina<cost
 if blocked then s.stamina=math.max(0,s.stamina-cost) end
 local down=finisher and not blocked
 if not blocked or broken then
  s.serial+=1;s.combo=0;s.phase=down and 'Knocked down' or 'Stunned'
  s.stunUntil=now+(down and 2.3 or broken and 1.1 or .32);s.ready=math.max(s.ready,s.stunUntil)
 end
 return {blocked=blocked and not broken,broken=broken,damage=blocked and not broken and math.max(1,damage*.15) or damage,knockdown=down}
end
function Rules.cancel(s,now)
 s.serial+=1;s.combo=0;s.phase='Idle';s.ready=now;s.stunUntil=now
end
return Rules
