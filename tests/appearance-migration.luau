local appearance=require('../src/ResidentAppearance')
local options={Hair={'Close crop','Twists'},Height={'Short','Medium','Tall'},HairColor={'Black','Copper'}}
local old={Name='Imani Lewis',Hair='Unavailable legacy asset',Height='Tall',Cash=900}
local look=appearance.restore(old,options)
assert(look.Name=='Imani Lewis' and look.Height=='Tall' and look.Hair=='Close crop' and look.HairColor=='Black')
assert(not look.Cash and old.Hair=='Unavailable legacy asset','Migration must isolate appearance from account state')
assert(appearance.restore({Name='',Height=0/0},options).Name=='Avery Bell')
assert(appearance.restore({Hair='Twists',HairColor='Copper'},options).HairColor=='Copper')
local a,b=appearance.new(),appearance.new();a.Hair='Shaved';assert(b.Hair=='Close crop')
print('PASS legacy missing invalid and valid saved appearance migration')
