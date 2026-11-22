local identity=require('../src/BrandIdentity')
local brands=require('../retail-brands').brands
local used={};local count=0
for key,b in brands do
 assert(b.Key==key)
 local cell=assert(identity.cell(key));local signature=cell.atlas..':'..cell.x..':'..cell.y
 assert(not used[signature],'Two businesses accidentally share one logo');used[signature]=true
 -- Roblox resized both uploaded sheets to 1023 x 1012; use the delivered image's pixel coordinates.
 assert(cell.x>=0 and cell.y>=0 and cell.x+cell.w<=1023 and cell.y+cell.h<=1012,'Logo crop exceeds the delivered Roblox atlas')
 assert(cell.w>=255 and cell.w<=256 and cell.h==253,'Logo crop does not match a delivered emblem cell')
 count+=1
end
assert(count==29 and not identity.cell('unknown'))
print('PASS 29 distinct business identities and atlas bounds')
