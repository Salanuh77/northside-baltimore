return function(b)
 b.part('Box',{1.25,.73,.74},{0,-.13,0},{145,112,63})
 b.part('Paper band',{1.27,.24,.76},{0,-.1,0},{231,218,173})
 for i=-2,2 do
  b.part('Brass case',{.17,.55,.17},{i*.21,.47,0},{177,137,60},'Cylinder',{0,0,math.pi/2})
  b.part('Round tip',{.15,.2,.15},{i*.21,.83,0},{129,98,62},'Ball')
 end
end
