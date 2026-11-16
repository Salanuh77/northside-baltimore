local Names=require('../src/ResidentNames')
local first={'Avery','Andre'}
local last={'Bell','Brooks'}
local function resolve(input,filter)
 return Names.resolve(input,first,last,filter)
end
local function never() error('Curated names should work offline') end
assert(resolve({FirstName='Andre',LastName='Brooks'},never)=='Andre Brooks')
assert(resolve({Name=''},never)=='Avery Bell') -- Legacy creation payload
local seen
assert(resolve({FirstName='  Zora ',LastName="O'Neal"},function(name)
 seen=name; return name
end)=="Zora O'Neal" and seen=="Zora O'Neal")
assert(not resolve({FirstName='Zora',LastName=''},never))
assert(not resolve({FirstName=string.rep('z',21),LastName='Bell'},never))
assert(not resolve({Name='Custom Name'},function() return '##### Name' end))
assert(not resolve({Name='Custom Name'},function() error('Unavailable') end))
assert(resolve({Name='Custom Name'},function() return 'Approved Name' end)=='Approved Name')
print('PASS custom identity input, curation, filtering and service failure')
