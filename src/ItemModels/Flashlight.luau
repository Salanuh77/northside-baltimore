return function(b)
 b.part('Grip',{1.45,.42,.42},{0,0,0},{39,46,48},'Cylinder')
 b.part('Head',{.48,.68,.68},{-.86,0,0},{59,68,70},'Cylinder')
 b.part('Lens',{.025,.53,.53},{-1.11,0,0},{209,230,211},'Cylinder')
 for i=1,5 do b.part('Grip ring',{.045,.46,.46},{-.45+i*.2,0,0},{26,31,33},'Cylinder') end
 b.part('Switch',{.18,.08,.17},{-.25,.24,0},{188,140,63})
end
