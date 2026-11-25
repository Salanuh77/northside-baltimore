---
name: roblox-npc-behavior
description: Improve Baltimore Hood RP civilians, police, medics and shop staff with state machines, social interactions, witness memory and combat reactions. Validate server-owned decisions and visible behavior in multiplayer Studio.
---

# City NPC behavior

Use the existing server modules: Responders owns perception and role decisions, ResponderBrain owns combat timing, NpcTactics proposes movement, NpcGround validates destinations, NpcNavigation follows paths, and ShopStaff owns counter interactions. Keep damage, arrests, hearing reports and position authority on the server. The client may render effects but cannot report a successful hit or arrest.

Civilians owns the bounded nearby population and sidewalk routines; CivilianRoutes connects pavement strips, corners and crossing edges and avoids immediate reversals. CivilianBrain chooses between routine, social, danger and defensive states using a supplied clock and observations. StreetCombatRules owns combo timing, stamina, frontal guard and interruption; StreetCombat validates actual range, facing and obstruction at the delayed hit moment. Ragdoll owns physical joints and restoration. CombatPose and CombatClient present those server states. Read [civilian and combat reference](references/civilian-combat.md) when extending these systems.

Use explicit interruption priorities: death/knockdown, immediate danger, self-defense, conversation, crowd avoidance, then routine. A conversation or waypoint pause must be interruptible by a witnessed assault or heard shot. Distinguish cautious retreat from a bold victim's brief self-defense. Crowding alone produces yielding or a warning; it does not justify lethal combat. Do not arm every civilian or chase an attacker indefinitely.

Keep witness evidence honest. Sounds identify an incident location; sight or a direct assault can identify a suspect. Calls require a safe pause and occur once per incident. A witness report must preserve its original location and must not replace a fresher officer sighting. Expire memories and explicitly recover into routine behavior. Check that a route has real floor, clearance and a path; when no escape is available, show sheltering instead of walking into the obstacle.

Make combat readable at normal camera distance. Show a windup before impact, alternate jab/cross arms, distinguish the hook, lift both forearms when guarding, and retract after the swing. Separate temporary knockdown from death. Physical sockets replace limb motors during knockdown; restore motor enablement, collision flags, neck requirements, platform state, camera ownership and movement afterward. Never award damage from a visual effect or accept a client-supplied victim, damage value, combo index or ragdoll duration.

Give each role a legible response. Police request surrender from a wanted resident, react before firing at an active attacker, preserve ammunition when another character blocks the muzzle, maintain separation, and seek cover while reloading. Medics retreat from nearby gunfire and resume treatment after the danger expires. Clerks respond to visible customers, shelter from heard gunfire, and remain briefly wary when a weapon is holstered.

Treat hearing and sight separately. A sound provides a location to investigate, not continuous knowledge of the hidden player's coordinates. Search from the last legitimate report, fan partners into different nearby sectors, expire memory, and clear cached movement when the target changes. Wanted status alone must not trigger shooting.

Validate tactical destinations against ground, slope, body clearance and the movement corridor. Use the pathfinder for obstructed routes. Never replace a failed route with direct walking through walls. Compare waypoint height with the character's feet, not only X/Z or the root center, so stairs are traversed in order. Cancel stale path requests and disconnect obsolete blockage listeners.

Keep decisions bounded: reuse a movement goal briefly rather than changing it every heartbeat, limit raycasts by range, and retain staff activation/deactivation distances. Facing should rotate smoothly and hand control back to Humanoid.AutoRotate when aiming ends.

Test observable behavior. Run the npc-tactics, npc-ground, npc-sight, npc-reactions, npc-navigation, npc-awareness, npc-combat and responder-brain suites. Use the encounters Studio probe with two players to verify actual movement, firing-lane obstruction, reload, surrender, cover and arrest. Wait for LoadCharacterAsync completion before relocating fixtures. Assert live displacement in addition to state labels. Run shop tests for peaceful purchases as well as threat reactions. Test copies must remain separate from the shipped place.

Also run street-combat, civilian-brain, civilian-routes, civilian-map, weapon-inventory and combat-pose suites, then combat, civilians and weapons Studio probes. Test front/rear guard, spam, walls, missed swings, protection, incapacitation, three-hit timing and another client's view of a knockdown. Verify that a neighbor actually changes position, can converse, reacts to danger and resumes a routine. Input tests must use a deliberate camera direction because shoulder-camera facing affects melee hit cones. Run Studio harnesses sequentially; concurrent launches can connect to the wrong test server.

When reviewing third-party systems, inspect the actual source and licensing before importing dependencies. Record the revision and distinguish original implementation from copied or adapted code. See [source review](references/source-review.md) for this iteration's reference and scope.
