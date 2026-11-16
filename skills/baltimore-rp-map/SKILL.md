---
name: baltimore-rp-map
description: Build or revise a Baltimore-inspired Roblox roleplay map when designing districts, storefronts, housing, interiors, vehicle models, gas stations, traffic controls or architectural signage. Use for map design and street-level playtesting.
---

# Baltimore RP map

Design each block from the sidewalk and from a driver's seat. Use the supplied photographs in [the reference index](references/index.md) when choosing silhouettes, materials, signs and street proportions.

## Give each district an identity

- Line downtown avenues with buildings close to the sidewalk. Use a mix of metal-and-glass towers, stepped masonry offices, civic stonework and glazed ground-floor retail. Frame a long view with a recognizable civic landmark. Give one or two key towers a wordmark mounted on their crown.
- Give the Inner Harbor an actual water's edge. Use converted brick commercial buildings, reflective office towers, piers and a public promenade. Reserve open views for the water, civic approaches and deliberately designed plazas.
- Make the west-side rowhouse streets feel inhabited. Join narrow brick and painted-stone houses party-wall to party-wall. Vary lintels, flat cornices, stoops, handrails, awnings, porch repairs, painted doors, occupied windows and the occasional boarded opening. Place original murals on appropriate party walls. Give larger subsidized apartment buildings common entrances, usable apartments and shared courtyards. Represent the waterfront residential district through its architecture, amenities and finishes. Keep residents and emergency services playable throughout the city. Give the detention center a visitor entrance, an accessible bail window, a confined dayroom, cells and a clearly marked activity terminal. Test booking, respawn, release, visitor payment and the fictional escape game in multiplayer.
- Ground neighborhood names in masonry gateway signs or a community landmark. Use discreet address numbers, small projecting shop signs and occasional crown lettering. Keep the skyline and sightlines clear of repeated oversized nameplates.

## Build a commercial street wall

Locate the curb, sidewalk, building line and useful gaps before placing a shop. Design continuous retail bays or a covered arcade around an intentional entrance, passage, loading alley or public court. Join adjoining buildings at their party walls. Carry the paving to every threshold. Keep trees and benches out of shops and circulation paths.

Give cafés and markets a flat roof and parapet, deep plate-glass display bays, metal mullions, stone stall risers, a clear entrance and a furnished interior visible from the street. Vary bay counts, upper-floor heights, brick, paint and trim with the block. Shape the front and exposed corner elevations. Overlap the transom, header, ceiling, party wall and roof edge in section. Test for sky visible through unintended seams. Give shops a physical identifier such as a hanging enamel cup and saucer, a ceramic maker mark or letters painted on the glazing. Place awnings over entries and keep signs proportional to a pedestrian. Walk the path from crossing to counter.

## Streets, cars and fuel

Use physical double-sided green blades with a thin light border, narrow white uppercase street names and a smaller raised street-type suffix. Fit the plate to the text and fasten it to a galvanized pole above head height. Mount intersecting blades at right angles. Use black-and-white ONE WAY arrows only along the corresponding one-way route; both faces must point in the same world direction.

Set each traffic head over its inbound lane, facing the approaching driver. Give each head a housing, hoods and distinct lenses. Coordinate opposite approaches, amber transitions and an all-red clearance. At pedestrian crossings use a white walking figure and an amber raised hand. Drive and walk both axes to check visibility.

Design a fleet at avatar scale. Establish wheelbase, tire diameter, track, hood height, roofline and overhangs before drawing details. Vary the relationship between the roof and the tail to distinguish a sedan, wagon, crossover and fastback. Shape the fenders around the tires. Use raked glass, visible pillar structure, integrated lamps, mirrors, wheels and seats. Use the fleet reference for the coupe, muscle car, sedan, patrol SUV, service van and school bus. For a close-up civilian car, start with a well-modeled automotive mesh with documented reuse rights. Inspect the fender-to-tire fit, windshield rake, B pillars, bumper intakes, headlamp lens and wheel dish from a three-quarter view. Preserve the source proportions, shade paint, rubber and glazing separately, and use invisible collision tires beneath detailed wheels. Preload the mesh assets on a Roblox client. Northside stores the adapted templates in art/road-cars.rbxm and the credits in art/vehicle-credits.md. Test seat entry, exit and steering with a player inside.

Lay out stations from the road inward. Provide a drivable apron, room to stop parallel to a pump and a clear exit. Keep columns on pump islands. Show price at the dispenser and fuel in the driver's HUD. Measure distance driven on the server, stop propulsion when empty and refill a stationary nearby vehicle on payment. Leave the mart accessible to pedestrians.

## Apply the design to Northside Baltimore

In the squishy-factory project, check the generators that own the relevant geometry: `districts.luau` for neighborhood shops and homes, `downtown.luau` for the downtown blocks, `citylife.luau` for fuel stations and local amenities, `roads.luau` for intersections and `fleet.luau` for cars. Driving and signals run in `src/Traffic.server.luau`; pump transactions run in `src/NeighborhoodLife.luau`.

Build the place and inspect the exported geometry at eye level. In Studio, test a complete light cycle, seat entry, fuel loss with movement, empty-tank behavior and a paid fill followed by a drive away. Preserve existing homes, interiors and roleplay interactions when changing their surroundings. On Windows, open the matching Studio instance or give the rebuilt place a fresh filename if an earlier file is locked.

## Match the playable block to its key art

Use the Baltimore Hood RP gallery to pick a camera position and a real destination. On Hollins Row, read the continuous wall from stoop height. Model the stone treads, end posts and sloping rail as a set. Recess clear sash glass inside masonry openings. A short shade inside selected rooms and a caged amber lantern beside an occupied door give houses individual character at dusk.

At a mart checkout, line up the cashier, open aisle and storefront in one sightline. Use wire shelves with stock visible behind neutral glass, a cool linear light inside the chiller, and warm light over the register. Reserve the register’s interaction hitbox for the player. Give cosmetic keys, pulls and receipt slips collision and query settings appropriate to that purpose. At a clothing shop, keep hanging garments, a dress form and folded stock outside the entry axis. In the Patapsco lobby, frame the clerk, document tray and bail plaque together and preserve the partition to custody.

Use the street clock to blend a warm late-afternoon key into blue-hour ambient light. Keep brick, skin tones and station entrances readable. Drive window and porch illumination from the same clock, grouping changes at dusk. During an implementation-only pass, inspect the serialized geometry, door clearances and signal phases. Record an in-engine visual check separately when a playtest is requested.
