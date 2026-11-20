# Resident and rest follow-up, November 19

The former bed implementation failed the new Studio assertion: the occupant remained upright. The replacement passes horizontal, face-up torso checks, healing, standing upright, early cancellation, shared sofa seating, kitchen use and walking through both tested homes. Static checks cover rest and get-up frames in all 243 furnished residences. A first rerun was blocked on the later Hollins entrance route; the subsequent complete run passed. Failure diagnostics now report nearby colliders for that route.

The creator's new sidebar/category layout passed 52 checks each at desktop and iPhone 7 sizes, including preview/editor separation, independent facial controls, outfits, naming, saved appearance on entry and phone navigation. The mobile run initially exposed a phone app overlapping the touch controls; the HUD now renders above them. Later release runs additionally cycle and load all 17 hair choices. The face regression suite checks all 54 head/eye-spacing/lip-fullness combinations and three headings. Source-space front and profile renders prompted replacement of the floating flat eye/lip cards with conforming geometry; those renders are not in-engine screenshots.

All 28 unit/build suites pass. The final release still requires all nine Studio suites on the exact hosted CI artifact, with game-script errors monitored on both clients and the server. The prior upload was rejected for an ongoing Team Create session, so that upload did not change live revision 19.

# November 19 Alpha regression pass

The Windows unit/build pipeline runs 28 suites, including deterministic responder policy, navigation, damage, housing permissions, purchases, saved residents, map geometry, vehicle handling and traffic timing. The candidate gameplay binary has SHA256 `E0D633BE76E223C403E9AE02095FE63C634876BAACAD3383EAA6B8E526098206`.

Red/green regressions reproduced and fixed three gameplay issues: a retired blocked-path callback invalidating an NPC's new route, heard incidents being labelled as visual police contact, and police gunfire failing to keep nearby paramedics away. The new unit cases passed after those fixes. Multiplayer runs then confirmed police damage, twelve-round magazines and reloads, searching behind cover, no fire through cover, surrender stopping fire, close-range arrest and paramedic scene safety. The isolated combat arena holds actors in position to measure these decisions; the city custody test exercises the moving police units.

Two-player Studio runs also verified tenant locks with actual walking, the door-to-wall seam, accepted party guests, revoked access and safe exits. The vehicle tests now press the real Space brake while holding throttle and the real F exit key. Custody checks cover officer defeat and respawn, booking, reset, visitor bail, escape, no automatic capture of a healthy resisting player, subduing a wounded stationary escapee and a full sentence expiring.

Desktop and iPhone 7 Studio emulation passed resident creation, face and hair asset loading, the resident file picker, compact phone layout, map, work, bag, home, payments, dispatch, server browser, home navigation and keyboard dismissal. Additional multiplayer checks covered retail, synthetic purchase receipts, trading, robberies, banking, ammo, jobs, food, fuel, parties, NPC medical response and street navigation. Furnished-home walking, shared seating, kitchen interactions and bed use passed after the asset check was expanded to include the new sideboard.

Studio 0.748 now receives serialized JSON results across its multiplayer process boundary. Missing results, timeouts, game-script errors on either multiplayer client or the server, and changed candidate bytes fail the gate. The release command requires successful main-branch CI, downloads its checksummed artifact, reruns all nine Studio suites on disposable copies and verifies the published bytes. Receipts and raw engine logs stay outside Git. Simulated receipts do not charge Robux; Studio saves are temporary. Public-server transfers, live DataStore recovery and physical-device performance remain separate live-service checks.

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
