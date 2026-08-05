# Implementation Plan: 001-Types-Models — Models as Definition & Schema of Truth

**Branch**: `001-Types-Models` | **Date**: 2026-08-05 | **Spec**: [SPEC.md](SPEC.md)

**Input**: Feature specification from `specs/001-Types-Models/SPEC.md`

---

## Summary

The goal of this feature is to establish `specs/001-Types-Models/*.ts` schemas (`Character.ts`, `Combat.ts`, `Heroic.ts`, `Item.ts`, `Pet.ts`, `Profession.ts`, `Skill.ts`, `Spell.ts`) as the single **Schema of Truth** across the entire GAC_DEV addon system. 

All raw data — whether originating from new character creation, persistence storage loaded via `SavedVariablesPerCharacter` (`GAC_CharacterDB`) on `ADDON_LOADED`, custom item inspection via TRP3 Extended, or P2P network sync — **MUST** pass through and be parsed/validated by the domain model factories in `src/main/domain/models/`. 

The technical approach requires updating/replacing pure Lua 5.1 domain model metatables in `src/main/domain/models/` (`Character.lua`, `Armor.lua`, `Weapon.lua`, `Shield.lua`, `Combat.lua`, `Heroic.lua`, `Pet.lua`, `Profession.lua`, `Skill.lua`, `Spell.lua`) with explicit schema validation factories (`Model.create(rawData)`, `Model.sanitize(rawData)`). These factories will validate well-formed raw data and sanitize/reject malformed or corrupted raw data with safe defaults without raising Lua runtime exceptions.

---

## Technical Context

**Language/Version**: Pure Lua 5.1 (LuaJIT subset for Retail 11.0.7+) & TypeScript 5.x schema specifications (`specs/001-Types-Models/*.ts`).

**Primary Dependencies**: None for domain models (Pure Lua 5.1 with zero external libraries or WoW APIs). Integrated via Hexagonal adapters with `SavedVariablesPerCharacter` (`GAC_CharacterDB`), TRP3 Extended (`TRP3_Extends`), and UI IPC API bridges.

**Storage**: `SavedVariablesPerCharacter` (`GAC_CharacterDB.character`), per-character local persistent disk storage, and volatile in-memory cache for remote inspected player data.

**Testing**: Manual test suite, payload verification playgrounds (`operations-playground.html`), and empirical validation tests parsing both valid raw payloads and malformed/corrupted raw payloads.

**Target Platform**: World of Warcraft Client (Epsilon Roleplaying Server - Retail 11.0.7+).

**Project Type**: WoW Addon (Hexagonal Backend Architecture & Micro-Frontend UI Architecture).

**Performance Goals**: Schema validation and parsing execute in under 5ms during `ADDON_LOADED` and character sheet switches, with zero memory leaks or unhandled Lua crashes.

**Constraints**:
1. Pure Lua 5.1 ONLY in `src/main/domain/models/` (ZERO WoW client APIs such as `CreateFrame` or `RegisterEvent`).
2. Must sanitize or reject corrupted/malformed raw input tables without throwing unhandled Lua errors.
3. Must maintain 100% schema property parity with `specs/001-Types-Models/*.ts` TypeScript interfaces.
4. All model files must be registered in bottom-up order in `src/main/domain/models/models.xml`.

**Scale/Scope**: 8 TypeScript schema modules (`Character.ts`, `Combat.ts`, `Heroic.ts`, `Item.ts`, `Pet.ts`, `Profession.ts`, `Skill.ts`, `Spell.ts`) mapped to 10 Lua 5.1 domain model files in `src/main/domain/models/`.

---

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **Rule 01 — Domain Purity**: Domain models reside strictly in `src/main/domain/models/` and operate in pure Lua 5.1 with zero WoW client API references (`CreateFrame`, `UnitName`, `GetTime`, etc.). **PASS**
- [x] **Rule 02 — Hexagonal Adapters**: `SavedVarsStorageAdapter` and `TRP3Adapter` invoke model factories (`Character.create(rawData)`, `Item.create(rawData)`) at adapter boundaries before delivering data to domain or presentation layers. **PASS**
- [x] **Rule 03 — UI Micro-Frontend Autonomy**: UI features consume domain models strictly over `LocalIPCAdapter` (`api/[feature]Api.lua`) without mutating model schema definitions directly. **PASS**
- [x] **Rule 04 — Cascading XML Load Order**: All newly updated model files are explicitly declared in `src/main/domain/models/models.xml` in strict bottom-up order. **PASS**
- [x] **Rule 05 — Lua Good Practices**: All model metatables use `local` declarations, strict schema factories, and prevent global namespace pollution. **PASS**

---

## Project Structure

### Documentation (this feature)

```text
specs/001-Types-Models/
├── SPEC.md              # Feature specification detailing User Stories 1-7 & acceptance criteria
├── plan.md              # Implementation plan (this file)
├── Character.ts         # Character & CombatStats schema definition
├── Combat.ts            # Combat encounter & InitiativeOrder schema definition
├── Heroic.ts            # Heroic narrative card schema definition
├── Item.ts              # Item, Armor, Weapon, & Shield schema definitions
├── Pet.ts               # Pet companion schema definition extending CombatStats
├── Profession.ts        # Trade profession schema definition
├── Skill.ts             # Actionable skill metadata schema definition
└── Spell.ts             # Actionable spell metadata schema definition
```

### Source Code (repository root)

```text
src/
└── main/
    └── domain/
        ├── models/
        │   ├── models.xml      # Cascading XML manifest for domain models
        │   ├── Armor.lua       # Armor domain metatable schema factory
        │   ├── Character.lua   # Character & CombatStats domain metatable schema factory
        │   ├── Combat.lua      # Combat & InitiativeOrder domain metatable schema factory
        │   ├── Heroic.lua      # Heroic card domain metatable schema factory
        │   ├── Pet.lua         # Pet companion domain metatable schema factory
        │   ├── Profession.lua  # Profession progression domain metatable schema factory
        │   ├── Shield.lua      # Shield domain metatable schema factory
        │   ├── Skill.lua       # Skill metadata domain metatable schema factory
        │   ├── Spell.lua       # Spell metadata domain metatable schema factory
        │   └── Weapon.lua      # Weapon domain metatable schema factory
        └── domain.xml          # Master domain manifest loading models.xml
```

**Structure Decision**: Single monorepo project structure where pure Lua 5.1 domain models reside in `src/main/domain/models/`, strictly adhering to Hexagonal architecture principles.

---

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| *None* | *Fully compliant with project rules* | *N/A* |
