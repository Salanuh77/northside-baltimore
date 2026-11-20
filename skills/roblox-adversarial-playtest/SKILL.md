---
name: roblox-adversarial-playtest
description: Review Roblox client and server code against real gameplay and UI behavior before shipping a place. Use for red-green regressions, multidisciplinary release review, and two-player Studio validation.
---

# Adversarial playtesting

Pick a supported player journey and state the observable outcome for each participant. Trace it from the visible control through the client handler to the server state and back to the displayed result. Include the moment an action is declined, delayed, repeated or interrupted.

Record the place version and run probes on a disposable copy. Use Studio's simulated receipts for paid flows. Observe the actual client hierarchy, focus, text fitting, scroll range, close/reopen behavior, and whether the character can still be controlled. Check the smallest supported phone viewport and a desktop viewport. Distinguish measured layout from a screenshot inspection.

For each confirmed regression, write a failing assertion against the existing implementation, capture its actual failure, make a scoped fix and rerun the same test. Cover valid, boundary, retry and cancellation cases. Verify durable balances and receipts with a controlled store fixture and distinguish local fixtures from live service results.

Before release, run the artifact's normal multiplayer journeys. Retain a machine-readable completion result, the tested binary digest, and any uncovered cases. A timeout, missing result, or different binary invalidates that run. Surface findings with the reproduction, expected behavior, observed behavior and player impact.

For rest interactions, assert the visible pose as well as health: the torso lies horizontal and faces upward, other clients see the pose, get-up restores an upright resident in the aisle, and interruption does not award healing. A seated humanoid plus a health increase does not demonstrate sleeping. For mobile menus, exercise real taps with the Roblox touch controls present; ensure jump/joystick overlays cannot intercept phone app buttons.

For creator and shop changes, click the real save card and Enter city button, then check the selected appearance and restored inventory. Wait for GUI insets and layout before computing input coordinates. In the phone, inspect a rendered screen: a descendant with Visible=true can still be hidden by a later wallpaper layer. Set deliberate stacking behavior and verify the app artwork is in front. Check faces for opaque texture rectangles and hair for ignored material tint. Run a pictured item purchase through the actual card, then verify the server balance and inventory. Keep Robux test receipts simulated.
