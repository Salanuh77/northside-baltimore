return function(b)
 b.part('Case',{1.4,.94,.48},{0,0,0},{225,218,196})
 b.part('Top handle',{.6,.12,.14},{0,.64,0},{90,111,85})
 for _,x in {-.24,.24} do b.part('Handle support',{.12,.18,.14},{x,.52,0},{90,111,85}) end
 b.part('Cross vertical',{.18,.49,.025},{0,0,-.255},{176,61,49})
 b.part('Cross horizontal',{.49,.18,.03},{0,0,-.26},{176,61,49})
 for _,x in {-.48,.48} do b.part('Latch',{.12,.18,.04},{x,.38,-.27},{96,111,93}) end
end
