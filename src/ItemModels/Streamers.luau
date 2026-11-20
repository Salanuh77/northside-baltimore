return function(b)
 for j=-1,1 do
  local color=j==0 and {231,184,91} or {141,94,174}
  for i=1,13 do
   local t=i*.42
   b.part('Ribbon',{.16,.19,.04},{j*.4+math.sin(t)*.17,.9-i*.13,math.cos(t)*.15},color,nil,{0,t,t*.4})
  end
 end
end
