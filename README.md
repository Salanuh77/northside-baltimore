# Baltimore Hood RP

Open **Northside Baltimore - Heritage Harbor.rbxl** in Roblox Studio. The source project lives in this folder, separate from the basketball app workspace.

## Heritage Harbor

Walk east on the waterfront promenade to the timber pier and cross the ramp to USS Constellation. Seven Foot Knoll Lighthouse stands west of the ferry hall. Inside Pier 8 Maritime Gallery, the mural pairs Frederick Douglass with Thurgood Marshall. Twenty-one other walls carry neighborhood paint, community portraits and basketball or football art.

The placements and models interpret the real waterfront at game scale. Historical references include [Historic Ships in Baltimore](https://historicships.org/explore), the [National Park Service biography of Frederick Douglass](https://www.nps.gov/places/frederick-douglass-national-historic-site.htm) and its [Thurgood Marshall biography](https://home.nps.gov/poch/learn/historyculture/thurgood-marshall-biography.htm).

Run `scripts/ci.ps1` on Windows to build and run the same checks as GitHub Actions. To promote the hosted main artifact, run `scripts/release.ps1 -RunId <CI run ID> -ExpectedVersion <live revision>` in a clean checkout with GitHub CLI and an authorized Roblox Studio session. This command acquires the candidate, checks its commit and checksum, runs the Studio suites on disposable copies, then publishes the tested bytes and verifies the live revision.

## What is built

- A 1,460 × 1,660-stud land area with 42 connected city blocks, named street blades, zebra crossings and 30 signal-controlled junctions. The waterfront extends past the northern edge.
- Ten housing estates, 198 furnished apartments, and 16 original rowhomes. Upper apartments have gallery access and stairs. The four newest residential towers offer lifts serving 8–12 floors. The court buildings include laundries, barbershops and small libraries. Downtown has seven office and hotel towers with public lobbies.
- Ten market registers, eleven delivery stops, a credit union with an ATM, a clinic and a community center. The harbor has six commercial landmarks with walk-in lobbies, market halls, piers and a beacon.
- Twenty drivable vehicles including sports cars, muscle cars, wagons, patrol SUVs, service vans, buses and cabs, a basketball court, a pocket park and a freight warehouse with a black market and stolen-goods buyer.
- Server-controlled cash, bank balance, inventory, gun damage and ammunition, reloads, robberies, player payments, item sales, delivery jobs and healing.
- Safe zones at the bank and community center. Spawn protection, robbery cooldowns, distance checks, line-of-sight checks and input rate limits.
- Session-locked persistence on published servers. Studio progress is deliberately temporary and does not touch live saves.

The pre-existing warehouse, church props and loose map parts remain in **ServerStorage / OriginalMap_Archive**, with their scripts disabled. The exact untouched binary download is **Squishy-original.rbxlx.rbxl**. The `.rbxlx` suffix in that backup's name came from Studio appending its binary extension; its content is a valid binary place.

## Resident files

Each account gets three resident files. Choose an occupied file to resume its saved look, wallet, purchases and job. A new file opens the character studio with a neutral city model. Rotate it and choose height, build, skin tone, haircut, face detail, starter-shirt color and roleplay name. Enter city confirms the resident before the first spawn. Existing single-resident accounts migrate to File 1. Rejoin to pick a different file.

## Play

Press **Play**, select a resident file and enter the city. Press **P** or use the phone icon to open **City map**, **Work**, **My bag**, **Dispatch** and **Guide**. Press **M** or tap the radar for the map. Use **Drive** at a parked car, steer with movement controls, hold **Space** to brake and press **F** or **X** to exit beside the vehicle. Controller players use **LT** to brake and **B** to exit; touch players have on-screen controls.

- **E** / touch prompts: interact; doors open and close.
- **H**: surrender / stop surrendering.
- **T**: nearby player payments, item offers and robbery.
- Equipped pistol: click/tap to fire; **R** reloads. Mobile buttons cover player menu, surrender and reload.
- Freight Expectations sells a knife for $55, a crowbar for $90, and a medkit for $70. Bench Authority sells a wood bat for $80. River Pro Outfitters sells sidearms for Robux. Eligible players can agree on a city-cash price in the nearby player trade menu.
- House lockbox: equip crowbar and stay nearby for 9 seconds. Sell stolen goods at the warehouse salvage counter for $110 each.
- Store register: equip pistol and stay nearby for 12 seconds for $225. Locations reset after 3 minutes.
- Player robbery: target must surrender; remain nearby for 8 seconds. Takes 25% of cash, capped at $200, with a 5 minute victim cooldown. Bank money is protected.
- Your new resident gets an optional arrow to the Community Center courier desk. Pick up a parcel and follow the new bearing and distance to the mailbox for $90. Open GUIDE to hide or restore the pickup directions. The same compass follows active shift stops.
- Credit union ATM: deposit / withdraw. Clinic: heal for $50. Medkit restores up to 60 health.
- Death charges up to $75 and removes carried stolen goods; owned equipment returns on respawn.

The city wallet tracks earned cash. Roblox handles optional sidearm purchases, five-use packs of bubbles, glow sticks, confetti and streamers, and a twelve-use party sampler. The phone displays the current Roblox product price at checkout.

New residents choose their name, height, build, skin tone, and haircut. Exchange Streetwear sells three original jackets with denim for city cash. A saved outfit can be worn again at the counter. Juniper and Waverly barbershops offer $30 cuts, and a player employed as a barber can serve another customer after clocking in at Juniper.

Each city day lasts 24 real minutes. The HUD and all four City Hall clock faces follow city time. Check your phone for job opening hours. The night runner takes new shifts from 20:00 through 05:59.

## Source and reproducible build

`build.luau` reconstructs the map from the original binary, archives the original geometry, and installs the scripts from `src/`.

From PowerShell in this folder:

```powershell
.\tools\lune.exe run build.luau
.\tools\lune.exe run validate.luau
```

Lune v0.11.1 is bundled in `tools/` from the official [lune-org/lune release](https://github.com/lune-org/lune/releases/tag/v0.11.1). It reads the Roblox place format without needing Studio UI automation. Its current reader reports an unsupported `Terrain.VoxelGridAssetContentMap` field in the original; the untouched original binary is retained for recovery.

`validate.luau` compiles both gameplay scripts, reads the final binary back, checks anchored geometry and interaction counts, and verifies the original archive and spawn. `studio-smoke.luau` verifies the place loads in the Roblox engine. `tests/` contains command-line multiplayer probes; these are injected only into temporary test sessions and are not included in the delivered game.

**The full two-client Roblox Studio test passed**, including actual house and store robbery prompts, cancellation when moving away, stolen-goods sale, payment validation, item trading, purchases, player robbery, cooldowns, shooting/reloading, safe zones and ATM transactions. See **TEST_RESULTS.md** for the recorded checks. This does not verify live DataStore persistence or mobile controls.

## Neighborhoods and venues

Downtown has a clock-tower sightline, attached commercial frontages and crown signs on three landmark towers. The housing courts have engraved entrance monuments. Hollins Row is a narrow, patched residential street with stoops and boarded vacancies. Harbor East has waterfront townhouses with $200 session leases. Free units are available at the housing courts.

Claim a home at its intercom and use **PHONE → Home & parties** to host, invite guests or accept an invitation. Parties have a local music source and lighting. Meridian Social Club has a dance floor and DJ tempo controls. Three fuel marts sell food, bandages and a reusable flashlight. Use supplies from **PHONE → My bag**. Pumps refill a parked car for $1 per five units of missing fuel.

Renting a home locks its door controls to the tenant and accepted party guests. Ending the party revokes guest entry; visitors already inside can still leave. Leases are per server and release when the tenant leaves. A deliberately open door remains a physical opening. All 243 home doors now have solid jambs and thresholds, and all 227 rentable entrances link to their own intercom.

The crime RP direction prioritizes readable police pursuits and consequences. NPC officers use limited vision, heard incidents and shared last-known positions; hidden players are searched for rather than tracked live. Armed aggressors trigger a reaction delay, inaccurate three-shot bursts, twelve-round magazines and reloads. Officers seek nearby cover while reloading or wounded. Surrender stops firing immediately; arrest requires contact at close range. Paramedics wait out nearby gunfire before a timed treatment, and shop staff react to witnessed incidents. The HUD distinguishes Spotted from Searching. Studio multiplayer tests cover combat decisions, cover occlusion, surrender and booking; unit tests cover policy, navigation and damage boundaries. Every release reruns the full Studio gate against its CI artifact.

Two NPC officers and two NPC paramedics patrol and respond. Use **Phone → Dispatch** for help. Police book surrendered wanted residents into Patapsco; a nearby stationary suspect below 25 health can also be subdued. A healthy resisting player must be pursued. Paramedics treat injured players. Players can apply to either service and start a paid shift. Additional in-person dispatch payments are capped by a per-recipient cooldown.

## Interiors

Use the phone or press **P** to apply for work, begin a shift, check its objective, view your balances or open the map. Parcel courier, building porter and dockworker shifts pay $110, $125 and $145. The off-book runner and unauthorized poster jobs pay $190 and $155 and raise the wanted level on completion. Route shifts pay once at the final marked stop. Barbers earn the customer fee for each completed cut.

Freight Expectations sells twelve reserve rounds for $30. Reloading transfers rounds from the reserve. The HUD shows health, cash, bank balance, wanted level, stolen goods, and ammo when the pistol is equipped.

Follow the open galleries and end stairs at the housing courts to reach the flats. Each flat has a living area, kitchen, bedroom and lockbox. Commercial towers have furnished ground-floor lobbies. Their upper office and hotel floors are exterior scenery.

## Published place

Baltimore Hood RP uses place `131234846449292` and universe `10755218391`. The current Roblox revision and publication status are recorded in `publish-receipt.json` and `published-place.json`.

`lune run update-listing` updates and verifies only the game description from `release-metadata.json`, retaining the current place revision and saving an ignored local receipt. Listing updates do not deploy gameplay changes.

Open **City servers** from the resident files or city phone to see public instances and available seats. Choosing **Join** checkpoints your file before Roblox starts the transfer. Studio lists the local session. Live transfers require the Roblox player.

Residents use the city?s articulated R15 body. Players can change their build, skin, twelve haircuts, hair color, expression, eyes, facial hair and starter outfit. The camera moves in for face and hair edits. Use X, controller B or **Exit car** on touch to leave the driver seat.
