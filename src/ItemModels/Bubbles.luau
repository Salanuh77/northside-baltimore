return function(b)
 b.part('Bottle',{.95,.64,.64},{0,0,0},{88,179,183},'Cylinder',{0,0,math.pi/2})
 b.part('Cap',{.16,.68,.68},{0,.55,0},{226,182,70},'Cylinder',{0,0,math.pi/2})
 for i=1,3 do b.part('Bubble',{.28,.28,.28},{.48+i*.11,.6+i*.28,-.1},{192,221,235},'Ball') end
 b.part('Label',{.52,.32,.02},{0,0,-.33},{236,214,122})
end
