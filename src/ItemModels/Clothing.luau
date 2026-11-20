return function(b)
 local color=b.options and b.options.color or {98,125,116}
 b.part('Jacket body',{1.15,1.20,.26},{0,0,0},color)
 for _,side in {-1,1} do
  b.part('Sleeve',{.38,1.02,.28},{side*.72,.05,0},color,nil,{0,0,side*.23})
  b.part('Cuff',{.38,.14,.30},{side*.83,-.43,0},{44,51,51})
  b.part('Collar',{.28,.16,.12},{side*.17,.57,-.16},{204,192,161},nil,{0,0,side*.35})
 end
 b.part('Zipper',{.025,1.05,.03},{0,-.02,-.15},{202,199,183})
 b.part('Waist rib',{1.17,.14,.29},{0,-.57,0},{45,53,52})
 b.part('Hanger',{.65,.06,.08},{0,.78,0},{173,145,99})
end
