local identity=require('../src/BrandIdentity')
local brands=require('../retail-brands').brands
local used={};local count=0
for key,b in brands do
 assert(b.Key==key)
 local cell=assert(identity.cell(key));local signature=cell.atlas..':'..cell.x..':'..cell.y
 assert(not used[signature],'Two businesses accidentally share one logo');used[signature]=true
 assert(cell.x>=0 and cell.y>=0 and cell.x+cell.w<=1261 and cell.y+cell.h<=1247,'Logo crop exceeds its atlas')
 assert(cell.w>=315 and cell.h>=311,'Logo crop truncates an emblem')
 count+=1
end
assert(count==29 and not identity.cell('unknown'))
print('PASS 29 distinct business identities and atlas bounds')
