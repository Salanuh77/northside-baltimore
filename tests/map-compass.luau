local compass=require('../src/MapCompass')
for _,v in {{0,-1,0},{1,0,90},{0,1,180},{-1,0,-90}} do
 assert(math.abs(compass.heading(v[1],v[2]))==180 and v[3]==180 or math.abs(compass.heading(v[1],v[2])-v[3])<.001)
end
local x,y=compass.project(-790,-605)
assert(x==0 and y==0)
x,y=compass.project(730,1100)
assert(x==1 and y==1)
print('PASS north-up map bounds and cardinal headings')
