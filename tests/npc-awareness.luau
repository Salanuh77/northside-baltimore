local Awareness=require('../src/NpcAwareness')
assert(not Awareness.inView(45,-1,false),'Unalerted NPC cannot spot distant suspect behind it')
assert(Awareness.inView(10,-1,false),'Close-range awareness')
assert(Awareness.inView(40,0,true),'Alerted NPC can look around')
assert(not Awareness.inView(71,1,true),'Alert never grants unlimited vision')
local seen={time=0,position='alley'}
local call={time=1,position='phone location'}
local report={time=4,position='corner'}
assert(Awareness.contact(5,seen,report,call)==report,'Latest legitimate observation wins')
assert(Awareness.contact(16,seen,report,call)==call,'Expired sighting falls back to the original call location')
assert(Awareness.contact(46,seen,report,call)==nil,'Search and call expire')
assert(Awareness.contact(10,seen,nil,nil).position=='alley','Hidden movement cannot update a remembered position')
assert(Awareness.contact(12,seen,nil,nil)==nil,'Sight memory expires on the boundary')
assert(Awareness.status(0,{time=0})=='Searching','Hearing gunfire must not claim visual contact')
assert(Awareness.status(.5,{time=0,seenAt=0})=='Spotted')
assert(Awareness.status(1,{time=0,seenAt=0})=='Searching')
assert(Awareness.status(12,{time=0,seenAt=0})=='')
print('PASS: field of view, awareness range, shared sightings, snapshot locations and search expiry')
