# Patapsco street and custody playtest

The second November 15 street build passed two separate two-player Roblox Studio tests. `tests/Patapsco-final-155907.log` records the sports-car and custody run. `tests/Patapsco-city-155703.log` records the city-life regression run.

- A client loaded the replacement Harbor GT meshes, entered the driver's seat, spent its last fuel unit by driving and lost propulsion. An empty-to-full fill cost $20. A second interaction charged nothing, and the car drove away.
- All four heads at the sampled junction completed both traffic directions and the all-red interval. At every sampled phase, one vehicle axis stayed red and each pedestrian indication matched its direction.
- The player bought and equipped a pistol, defeated a responding NPC officer and gained a wanted level. Another NPC officer booked the player. Character reset returned the prisoner to intake with the same deadline.
- A second player paid the listed bail. The defeated officer returned, a new booking started, a wrong game input kept the prisoner inside, and a correct sequence released the prisoner as wanted. Police recaptured the escapee and the full sentence ran to expiry.
- The city-life run exercised leasing, parties, the Franklin fuel mart and dispenser, jobs, player police processing and NPC medical response.
- The place validator reloaded the binary, checked all twelve joined neighborhood café blocks, and checked the ceiling and transom joint in every commercial hall.

The GT preview is a render of the replacement model. Studio tests used temporary player profiles and desktop clients.

# Northside Baltimore validation

Roblox Studio ran the City Life build with two local clients.

20 City Life gameplay checks passed.

- Voucher apartment can be leased without cash
- A second tenant cannot take the occupied home
- House party starts with local music
- Phone party invite reaches guest
- Guest accepts invitation
- Ending party removes music
- Unit returns to leasing pool
- Waterfront lease charges the listed fee
- Fuel mart sells items into the inventory
- Food restores health and consumes one serving
- Reusable flashlight illuminates
- Fuel pump fills nearby tank and charges cash
- Club DJ changes the music tempo
- Police and paramedic bots spawn
- On-duty player medic treats a patient and earns pay
- Police career accepts a player on duty
- Off-book shift produces an actual police case
- On-duty player officer processes a surrendered wanted character
- NPC paramedic answers and treats an injured player
- No gameplay script runtime errors

The previous downtown multiplayer suite covered driving, traffic signals, the twelfth-floor lift, tradable inventory, gun damage, magazine and reserve ammo, robberies, banking, the phone and paid shifts. Its result is in tests/downtown-verify.log.

All seven jobs also passed tests/work-contracts.luau for station ordering, payout, duplicate completion and wanted-level changes. The release validator checked 30,501 anchored map parts, 227 residence intercoms, twenty vehicles, three skyline wordmarks, seven entrance monuments and thirteen mural surfaces.

The tests used desktop clients and temporary Studio profiles. Live account persistence and mobile controls were outside the session.

## Hollins Alley, published revision 13

Two local Studio clients created residents and checked a daytime barber shift and its overnight closure. One client booked a haircut and paid the other player $30. The customer bought and re-equipped an original jacket, bought a bat and a knife for city cash, and attempted a cash purchase of a sidearm at the market.

The Studio-only receipt fixture delivered a sidearm twice with the same purchase ID. The seller transferred exactly one sidearm to the second client for $110. A second simulated receipt supplied glow sticks and the client activated the light. The test clients loaded the two paint sheets and clothing textures, and the city clock moved between daylight and night. The test used synthetic purchase receipts.

The joint test checked 300 arched windows across six mills and 15 upper floors. The binary downloaded from Roblox for published revision 13 matched the local release byte for byte. All three developer products were verified on sale.
