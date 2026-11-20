return function(b)
 for i=-1,1 do
  local colors={{100,205,173},{204,122,205},{227,193,92}}
  b.part('Glow stick',{.16,1.42,.16},{i*.33,0,0},colors[i+2],'Cylinder',{0,0,-i*.20})
  b.part('End cap',{.18,.1,.18},{i*.47,.72,0},{225,224,211},'Cylinder',{0,0,-i*.20})
 end
end
