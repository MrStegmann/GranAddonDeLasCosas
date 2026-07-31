# Product Context & Domain Rules

## Problem Statement
Standard WoW roleplay relies on improvised `/e` (emotes) or basic `/roll` mechanics without structured stats, action point (AP) economies, or combat initiative queues. Existing tools don't support custom tabletop system rules directly within the WoW UI.

## Product Capabilities

### 1. Character Sheet System
* Custom attribute allocation (e.g., Strength, Agility, Custom Stamina Pools).
* Derived stats (e.g., Evasion, Crit, Armor Mitigation) calculated automatically based on `/data/stats_reference.md`.
* Class/origin multipliers and resource pool limits based on `/data/sheet_creation.md`.

### 2. Turn-Based Combat Engine
* Initiative rolling and real-time turn queue tracker based on `/data/combat_mechanics.md`.
* Action Point (AP) expenditure, range rules, and skill execution driven by `/data/actions_dictionary.md`.
* Dice engine that outputs formatted combat emotes/results into custom chat channels or emote logs.

### 3. P2P Remote Inspection
* Inspecting another player opens a custom remote sheet view.
* Low-bandwidth version pinging ensures target sheets load instantly if already cached in memory.

## Integration Boundaries
* **Total RP 3 (TRP3):** Read-only source of truth for full character names, RP titles, and basic profile info.
* **TRP3 Extended (TRP3-E):** Optional read adapter for custom item/inventory flags.