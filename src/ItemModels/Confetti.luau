return function(b)
 b.part('Popper',{.45,.92,.45},{0,-.25,0},{163,90,145},'Cylinder',{0,0,math.pi/2})
 b.part('Gold ring',{.47,.14,.47},{0,.16,0},{224,182,83},'Cylinder',{0,0,math.pi/2})
 for i=1,9 do
  local a=i*2.4
  b.part('Confetti',{.11,.16,.03},{math.sin(a)*.62,.34+i*.08,math.cos(a)*.25},{i%2==0 and 227 or 90,175,i%2==0 and 97 or 197},nil,{0,a,a})
 end
end
