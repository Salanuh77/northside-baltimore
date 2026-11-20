# Reference review

Reviewed [Froredion/Comprehensive-NPC-System](https://github.com/Froredion/Comprehensive-NPC-System) at revision `6df7308cea86a124db4ee0bf67e261e9814b4c66` on November 20, 2026. The checkout contains documentation for movement, perception, modular NPC services and collision planning; it contains no `SKILL.md` entrypoints.

Its LICENSE includes additional restrictions on AI-assisted use. No source, bundled framework, place file, assets or dependencies from that checkout are incorporated into Baltimore Hood RP. Our code extends the existing NPC system with original tests and implementation. The review helped identify the feature areas to address: role-specific movement, bounded perception, cleanup and separation of server decisions from presentation.

Engine references used for the implementation: [WorldRoot spatial queries](https://create.roblox.com/docs/reference/engine/classes/WorldRoot), [AlignOrientation](https://create.roblox.com/docs/reference/engine/classes/AlignOrientation), and [Player character loading](https://create.roblox.com/docs/reference/engine/classes/Player).
