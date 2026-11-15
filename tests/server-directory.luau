local directory=require('../src/ServerDirectory')
local now=1000
local function city(count,capacity,age) return {Players=count,Capacity=capacity,Updated=now-age} end
local records={{key='here',value=city(2,20,0)},{key='full',value=city(20,20,0)},{key='open',value=city(9,20,10)},{key='old',value=city(2,20,91)},{key='invalid',value={}}}
local choices=directory.choices(records,'here',now)
assert(#choices==2 and choices[1].Id=='open' and choices[2].Id=='full')
assert(choices[1].Players==9 and choices[1].Capacity==20)
assert(directory.available(city(0,20,0),now) and not directory.available(city(20,20,0),now))
assert(not directory.available(city(2,20,91),now) and not directory.available(nil,now))
print('PASS: separate public instances, capacity, expired entries and current-server exclusion')
