# Civilian behavior and third-person combat

Reviewed November 25, 2026: [zirdic's Advanced Civilian AI discussion](https://devforum.roblox.com/t/inspired-by-gta-6-advanced-civilian-ai/2888818) and [the author's earlier NPC showcase](https://devforum.roblox.com/t/feedback-on-this-npc-system-inspired-by-gta-5/2736407). The accessible discussion describes personal-space reactions and distance-sensitive self-defense. Feedback calls for avoidance around players and less relentless attacks. The embedded video was not available through the text fetch, so these notes do not claim a frame-by-frame video review. These are behavioral references for an original implementation, not a dependency or imported NPC package.

## Observable decisions

- Walking follows a short sidewalk route and pauses at its ends. Activation is distance-bounded and population-capped; distant NPCs are retired after a grace period.
- Talking requires a living, nearby, visible player and a cooldown. The speaker faces the visitor and stops walking briefly. Gunfire immediately interrupts it.
- Yielding picks a clear side step. Sustained crowding adds a warning; touching alone does not initiate a fight.
- Wary observes a visible weapon. A nearby weapon, assault or audible shot can trigger fleeing; blocked escape shows cowering.
- Defending is available to a bold assault victim at close range for a limited time. A visible weapon, low health or lost contact ends it. The same server melee policy governs NPC and player punches.
- Reporting needs an identified suspect and a safe interval. Hearing alone cannot create a suspect identity. The call conveys the incident snapshot rather than tracking a hidden player.
- Recovering provides a short transition back to the civilian's route once memory expires.

## Combat presentation and authority

Players equip free Fists or use G / controller D-pad right. Punch uses click, touch Punch or RT. Hold F, touch Block or LT to guard. Three deliberately timed swings form a jab, cross and hook. Guard drains stamina and protects the front; depleted guard breaks. A clean finisher knocks down the target briefly. A safe-zone or protected target cannot be damaged.

Use the server's current character positions for the delayed hit, reject walls and rear-facing attacks, and deduplicate limbs into one victim per swing. Interrupt a pending attack using a serial token when the attacker is hit, knocked down or becomes ineligible. Release guards on focus loss, menu opening, unequip and character removal, with a server lease in case release never arrives.

Cancellation invalidates the pending strike but preserves its recovery deadline and existing hit stun. Re-equipping or surrendering must not reset those costs. Keep an explicit victim flag separate from witness identity: seeing an assault permits retreat and reporting, not joining the fight.

Client pose registries must handle joints arriving after a streamed model's tag. A second-client probe should observe a changed shoulder frame during a real attack, not only a replicated combat-state attribute. Conversation probes should frame the actual head prompt, verify its Triggered event, and separately exercise the server's wall rejection with client-side prompt occlusion disabled in the disposable fixture.

Ragdoll attachments use the original Motor6D C0/C1 frames. Limit ball-socket twist and swing; prevent self-collision between body pieces. Retain root linkage, set RequiresNeck before disabling the neck joint, and restore saved properties on recovery. See official [BallSocketConstraint](https://create.roblox.com/docs/reference/engine/classes/BallSocketConstraint) and [Humanoid](https://create.roblox.com/docs/reference/engine/classes/Humanoid) documentation. A state named Knocked down is insufficient: verify sockets, disabled motors, actual torso rotation, client replication and successful get-up.

## Evidence boundaries

Pure-state tests establish timing and priority rules. Spatial-query tests establish server hit rejection. Native Studio multiplayer probes establish motion, UI inputs, physics and replication. A compiled script or an attribute change alone does not prove the visual or physical result. Do not describe this as GTA's proprietary simulation or full GTA feature parity.
