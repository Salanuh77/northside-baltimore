-- Original shop identities. The reference column is production metadata for the art team.
local brands = {
 roast={'Crow & Kettle','Starbucks','coffee','244D48','E4BE72','COFFEE ROASTERS'},
 donut={'Counterclock Donuts','Dunkin\'','bakery','984D3E','F7C77D','DONUTS & COFFEE'},
 bagel={'Everything Twice','Einstein Bros. Bagels','deli','644052','F5CB99','BAGELS & BAKES'},
 diner={'Night Shift Grill','Waffle House','deli','493B37','F3C965','GRIDDLE & GRILL'},
 market={'Tall Basket','Giant Food','grocery','466B4E','E2AB59','NEIGHBORHOOD GROCER'},
 discount={'Quarter General','Dollar General','variety','54473A','F4CB55','EVERYDAY GOODS'},
 fresh={'Offbeat Orchard','Trader Joe\'s','produce','934F43','EAD598','FRUIT & PROVISIONS'},
 pharmacy={'Script Stop','CVS Pharmacy','pharmacy','8D464A','F0D6B7','PHARMACY & CARE'},
 books={'Spines & Noble','Barnes & Noble','books','385648','E8C595','BOOKSELLERS'},
 record={'Wax Traffik','The Sound Garden','records','454258','E7B465','RECORDS & TAPES'},
 camera={'Aperture Hour','Ritz Camera','camera','50415C','F2C878','CAMERAS & FILM'},
 print={'Ink in a Blink','FedEx Office','print','4D526A','E9AD89','COPY & PRINT'},
 gallery={'Odd Lobby','Hobby Lobby','art','485E70','D8AD8B','ART & FRAMING'},
 press={'Paper Trail','Hudson News','news','65473F','EBC978','NEWS & PERIODICALS'},
 wear={'Hem & Mayhem','H&M','fashion','7F414C','F3D5AA','CLOTHING CO.'},
 shoes={'Lace Locker','Foot Locker','sneakers','393F45','E8AB64','SNEAKERS & STREETWEAR'},
 sports={'Bench Authority','Sports Authority','sports','335D65','ECC782','ATHLETIC SUPPLY'},
 outdoors={'River Pro Outfitters','Bass Pro Shops','outdoor','465542','DBC180','OUTDOOR SUPPLY'},
 hardware={'Freight Expectations','Harbor Freight Tools','hardware','773F3C','EAC89A','TOOLS & SALVAGE'},
 wash={'Spin Cycle Express','Speed Queen Laundry','laundry','416876','E3BD95','COIN LAUNDRY'},
 barber={'Short Notice Cuts','Sport Clips','barber','525B58','D7AB77','BARBERS'},
 club={'Hard Brick Social','Hard Rock Cafe','club','5D435D','E5B067','LIVE MUSIC'},
 arcade={'Tokens & Busters','Dave & Buster\'s','arcade','454862','F5B768','ARCADE'},
 cinema={'Reel Estate','Regal Cinemas','cinema','784548','E6BB70','TICKETS & CONCESSIONS'},
 bank={'Small Change Bank','Capital One','bank','394F65','E1B871','NEIGHBORHOOD BANK'},
 clinic={'Quickish Care','Patient First','clinic','386967','E7C8A6','WALK-IN CLINIC'},
 goose={'Goose & Griddle','Wawa','fuel','8C4237','F5C66F','FUEL & DELI'},
 roost={'Crown Roost','Royal Farms','fuel','335E4A','E4C486','CHICKEN & FUEL'},
 late={'Eight Till Late','7-Eleven','fuel','2C5664','FFAE68','MART & FUEL'},
}
for key,brand in brands do brand.Key=key end
local exact={
 ['North Avenue Fuel']='goose',['Franklin Fuel']='roost',['Eastside Fuel']='late',
 ['MONUMENT MARKET']='discount',['Wharf Produce']='fresh',['Boiler House Market']='discount',
 ['NORTHSIDE CLINIC']='clinic',['CHARM CITY CREDIT']='bank',['HARBOR FREIGHT']='hardware',
 ['Union Athletics']='sports',['Eastern Outfitters']='outdoors',['Exchange Streetwear']='shoes',
 ['Park Avenue Clothiers']='wear',['Foundry Canteen']='diner',['Charles Center Deli']='bagel',
 ['Tidewater Books & Art']='books',['Pratt Arcade']='arcade',['Exchange Books']='books',
 ['Meridian Social Club']='club',['Lexington Box Office']='cinema',['Lexington Produce']='fresh',
 ['Commerce Provisions']='market',['Baltimore Press']='press',['The Newsstand']='press',
 ['Calvert Pharmacy']='pharmacy',['Harbor Roasters']='roast',['Seafarers Hall']='gallery',
}
local patterns={{'Music Hall','record'},{'Photo Lab','camera'},{'Book Arcade','books'},{'Print Exchange','print'},
 {'Studio Exchange','gallery'},{'Design Hall','gallery'},{'Gallery','gallery'},{'Laundry','wash'},{'Barber','barber'},{'Market','market'}}
local function brandFor(name)
 local key=exact[name]
 if not key and name:match('Coffee$') then
  local signature=0
  for index=1,#name do signature+=string.byte(name,index) end
  key=({'roast','donut','bagel'})[signature%3+1]
 end
 if not key then
  for _,entry in patterns do if name:sub(-#entry[1])==entry[1] then key=entry[2];break end end
 end
 return key and brands[key]
end

-- Shelf strip indices follow the 4-column print sheet in art/retail_aisles.py.
local assortment={
 coffee={6,7,8,5,30,10},bakery={8,6,2,7,5,30},deli={5,8,32,10,3,6},
 grocery={9,10,11,1,32,30},produce={9,11,10,32,8,5},variety={1,2,18,29,31,3},
 pharmacy={19,31,17,29,30,18},books={12,13,29,26,16,27},records={14,13,12,15,26,28},
 camera={15,26,16,12,28,29},print={16,29,26,15,12,13},art={26,16,29,12,15,13},news={13,12,29,2,14,30},
 fashion={21,22,20,24,21,22},sneakers={20,22,21,23,20,22},sports={23,20,24,22,21,30},
 outdoor={24,25,23,22,20,4},hardware={25,4,24,29,31,15},laundry={18,31,17,29,7,13},
 barber={17,31,13,18,29,15},club={3,30,13,14,7,10},arcade={28,14,3,2,1,13},
 cinema={2,1,3,27,13,30},bank={29,13,12,29,13,12},clinic={19,31,29,13,19,31},
 fuel={1,2,3,4,5,30,11,10,32,6,8,9},
}
local lineNames={'Bay chips','Fruit chews','Pop cans','Motor oil','Deli wraps','Roasted beans','Loose leaf tea','Fresh bakery',
 'Orchard crate','Pantry tins','Bay spices','Bound books','Periodicals','Vinyl sleeves','Film cartons','Color inks',
 'Hair care','Laundry soap','Counter care','Court shoes','Folded denim','Folded fleece','League balls','Field kits',
 'Workshop tools','Art editions','Ticket booklets','Arcade boxes','Paper goods','Sparkling drinks','Hand care','Hot sauce'}
return {forSite=brandFor,lines=assortment,names=lineNames,brands=brands}
