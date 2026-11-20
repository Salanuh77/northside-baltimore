local Layout=require('../src/CreatorLayout')
for _,screen in {{320,480},{390,780},{666,316},{943,552},{1920,1022},{2560,1382},{3840,2102}} do
 for _,mode in {{false,false},{false,true},{true,false}} do
  local p=Layout.measure(screen[1],screen[2],mode[1],mode[2]);local r=p.preview
  assert(p.width<=screen[1] and p.x>=0,'Canvas exceeds safe viewport')
  assert(r[1]>=0 and r[2]>=p.header and r[3]>0 and r[4]>0,'Preview invalid')
  assert(r[1]+r[3]<=p.width and r[2]+r[4]<screen[2]-p.footer,'Preview overlaps action bar')
  assert(p.top+p.tabs+p.available<=screen[2]-p.footer,'Editor obscures actions')
  assert(p.column>=100 and p.available>=60,'Controls collapse on a supported display')
 end
end
print('PASS safe creator rectangles across seven display sizes and three modes')
