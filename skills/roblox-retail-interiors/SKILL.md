---
name: roblox-retail-interiors
description: Stock and brand walk-in shops and fuel marts for Baltimore Hood RP. Use when designing a parody operator, stocking shelves and service counters, or reviewing an empty or generic retail interior.
---

# Fit out a Baltimore storefront

Start at the curb. Identify the real retail format and name an original Baltimore operator. Match a signature service customers recognize. A Wawa-inspired station can have a hoagie counter, while a Royal Farms-inspired station can have a chicken warmer. Carry the fictional operator through the canopy, fascia, department headers, till prompt and job directions. Keep the underlying location IDs stable for saved data and routes.

Plan the view from the entrance, the cashier's sightline, the staff station and the route back to the street before placing stock. Fill the walls and visible ends of aisles first. A low central display can provide depth where a player can still turn around it. Set display height according to use: customers should see across a convenience-store gondola, browse record sleeves from above and read a pharmacy header from the door. Match neighboring businesses to their category and give repeat branches details appropriate to their neighborhood.

Give every major display a recognizable silhouette and contents. Stock cold cases with bottles and cartons, set snack bags and auto supplies in distinct bays, give a bakery trays of rolls, a record shop browsable sleeves and a listening deck, and a clothing store rails, denim stacks and shoeboxes. Group related products and vary a few facings. Put small high-frequency details in shared printed art. Model the casework, shelves and items a player can see in profile. Keep each shelf's collision simple and reserve raycast targets and staff space for actual interactions.

In this project, select identities and product lines in `retail-brands.luau` and fit the floor model in `retail-interiors.luau`. The shelf sheet uses four columns of 256-by-128 pixel rows in `art/retail_aisles.py`. Render and inspect the atlas when changing its layout, since the world-facing UVs use the same order. Run `tests/retail-merchandising` on a freshly built place together with the station and map clearance checks. For visual review, take eye-level Studio captures of the street sign, doorway and cashier view on the same candidate. Show which view was captured in Edit mode.
