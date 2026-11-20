local Awareness={}
function Awareness.inView(distance,dot,focused)
 return distance<=70 and (distance<=14 or focused or dot>=.25)
end
function Awareness.contact(now,personal,broadcast,call)
 local newest
 for _,entry in {{personal,12},{broadcast,12},{call,45}} do
  local memory,ttl=entry[1],entry[2]
  if memory and now-memory.time<ttl and (not newest or memory.time>newest.time) then newest=memory end
 end
 return newest
end
return Awareness
