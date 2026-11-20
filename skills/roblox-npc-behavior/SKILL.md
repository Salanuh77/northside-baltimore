---
name: roblox-npc-behavior
description: Improve Baltimore Hood RP police, medics and shop staff with observable perception, movement and reactions; validate server-owned NPC behavior with unit and multiplayer Studio tests.
---

# City NPC behavior

Use the existing server modules: Responders owns perception and role decisions, ResponderBrain owns combat timing, NpcTactics proposes movement, NpcGround validates destinations, NpcNavigation follows paths, and ShopStaff owns counter interactions. Keep damage, arrests, hearing reports and position authority on the server. The client may render effects but cannot report a successful hit or arrest.

Give each role a legible response. Police request surrender from a wanted resident, react before firing at an active attacker, preserve ammunition when another character blocks the muzzle, maintain separation, and seek cover while reloading. Medics retreat from nearby gunfire and resume treatment after the danger expires. Clerks respond to visible customers, shelter from heard gunfire, and remain briefly wary when a weapon is holstered.

Treat hearing and sight separately. A sound provides a location to investigate, not continuous knowledge of the hidden player's coordinates. Search from the last legitimate report, fan partners into different nearby sectors, expire memory, and clear cached movement when the target changes. Wanted status alone must not trigger shooting.

Validate tactical destinations against ground, slope, body clearance and the movement corridor. Use the pathfinder for obstructed routes. Never replace a failed route with direct walking through walls. Compare waypoint height with the character's feet, not only X/Z or the root center, so stairs are traversed in order. Cancel stale path requests and disconnect obsolete blockage listeners.

Keep decisions bounded: reuse a movement goal briefly rather than changing it every heartbeat, limit raycasts by range, and retain staff activation/deactivation distances. Facing should rotate smoothly and hand control back to Humanoid.AutoRotate when aiming ends.

Test observable behavior. Run the npc-tactics, npc-ground, npc-sight, npc-reactions, npc-navigation, npc-awareness, npc-combat and responder-brain suites. Use the encounters Studio probe with two players to verify actual movement, firing-lane obstruction, reload, surrender, cover and arrest. Wait for LoadCharacterAsync completion before relocating fixtures. Assert live displacement in addition to state labels. Run shop tests for peaceful purchases as well as threat reactions. Test copies must remain separate from the shipped place.

When reviewing third-party systems, inspect the actual source and licensing before importing dependencies. Record the revision and distinguish original implementation from copied or adapted code. See [source review](references/source-review.md) for this iteration's reference and scope.
