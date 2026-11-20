return function(b)
 b.part('Gauze roll',{.72,.9,.9},{0,0,0},{230,220,192},'Cylinder')
 b.part('Roll core',{.735,.28,.28},{0,0,0},{144,130,106},'Cylinder')
 b.part('Loose gauze',{.65,.05,.65},{0,-.43,-.66},{229,216,183})
 for i=-2,2 do b.part('Woven seam',{.03,.052,.58},{i*.12,-.43,-.66},{191,183,160}) end
end
