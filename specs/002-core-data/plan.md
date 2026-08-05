# Implementation Plan: Core Hardcoded Domain Data Layer

**Branch**: `002-core-data` | **Date**: 2026-08-05 | **Spec**: [SPEC.md](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/specs/002-core-data/SPEC.md)

**Input**: Feature specification from `/specs/002-core-data/SPEC.md`

## Summary

Build an immutable, hardcoded domain database layer in pure Lua 5.1 containing all core reference datasets from `specs/002-core-data/` (17 JSON files: `arcane.json`, `chi.json`, `constitution_skills.json`, `dex_skills.json`, `elemental.json`, `elune.json`, `fel.json`, `holy_light.json`, `levels.json`, `nature.json`, `necromance.json`, `races.json`, `shadow.json`, `shields.json`, `strength_skills.json`, `weapons.json`, `worgenCurse.json`; and 2 TypeScript files: `armor-types.ts`, `traits-types.ts`).

All transpiled Lua tables act as the single source of truth for character creation, character inspection, and combat/gameplay calculations (armor mitigation, dice damage, skill checks). They are isolated in `src/main/domain/database/`, strictly read-only, and exposed exclusively through abstract metadata port endpoints (`GetAll()` and `GetById(id)`) in `src/main/ports/metadata/`. Inline technical comments in `traits-types.ts` for `PositiveTraits` and `NegativeTraits` are preserved in `TraitsDatabase.lua`. Every endpoint is probed to verify 1:1 structural equality with Lua database tables.

## Technical Context

**Language/Version**: Pure Lua 5.1 (World of Warcraft Retail Addon FrameScript Environment)

**Primary Dependencies**: None (Pure Lua 5.1 domain layer, zero WoW Client APIs)

**Storage**: Immutable in-memory Lua tables (`src/main/domain/database/`), zero disk mutations to `SavedVariablesPerCharacter`.

**Testing**: Lua unit probing suite asserting exact structural and content equality between Lua database tables and port endpoint returns (`GetAll()` / `GetById()`).

**Target Platform**: World of Warcraft Retail Client (`Interface/AddOns/GAC_DEV`)

**Project Type**: WoW Addon Domain Database & Metadata Architecture

**Performance Goals**: Instant O(1) key/ID lookups; zero garbage-collection table allocations during lookup queries.

**Constraints**:
- Pure Lua 5.1 ONLY in domain database and ports (zero WoW API calls such as `CreateFrame`, `RegisterEvent`, `C_ChatInfo`).
- Objects and lists in `specs/002-core-data/` are authoritative definitions of truth and MUST NOT be structurally changed.
- `PositiveTraits` and `NegativeTraits` MUST conserve inline comments from `traits-types.ts`.
- All domain database tables MUST be independent, isolated in `src/main/domain/database/`, and read-only.
- All access MUST be mediated via endpoints in `src/main/ports/metadata/`.
- Every endpoint MUST be probed and verified against source Lua tables.

**Scale/Scope**: 19 data sources (17 JSONs + 2 TS files), 8 Lua database modules (`ArmorDatabase.lua`, `TraitsDatabase.lua`, `LevelDatabase.lua`, `RaceDatabase.lua`, `ShieldDatabase.lua`, `WeaponsDatabase.lua`, `SkillsDatabase.lua`, `SpellsDatabase.lua`), 8 matching read-only metadata ports, and 2 cascading XML manifests (`database.xml`, `metadataPorts.xml`).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Rule 01 (Domain Purity)**: `src/main/domain/database/` contains strictly pure Lua 5.1 logic with ZERO WoW API calls (`CreateFrame`, `RegisterEvent`, `DEFAULT_CHAT_FRAME`). -> **PASS**
- **Rule 02 (Hexagonal Adapters & Ports)**: Domain database tables are hidden behind abstract read-only interfaces defined in `src/main/ports/metadata/`. -> **PASS**
- **Rule 04 (XML Load Order)**: Database files are declared in `src/main/domain/database/database.xml`, and metadata ports are declared in `src/main/ports/metadata/metadataPorts.xml` following strict bottom-up load order. -> **PASS**
- **Rule 05 (Lua Good Practices)**: All database modules explicitly declare `local` tables, enforce definition-of-truth schema fidelity, conserve inline trait comments, and return immutable table references. -> **PASS**

## Project Structure

### Documentation (this feature)

```text
specs/002-core-data/
├── SPEC.md              # Feature specification (Approved)
└── plan.md              # Implementation plan (This file)
```

### Source Code (repository root)

```text
src/
├── main/
│   ├── domain/
│   │   ├── database/
│   │   │   ├── database.xml                   # Cascading manifest loading all database modules
│   │   │   ├── ArmorDatabase.lua              # Transpiled from armor-types.ts (base armor, reductions, durability, slots, penalties, combinable)
│   │   │   ├── TraitsDatabase.lua             # Transpiled from traits-types.ts (PositiveTraits & NegativeTraits with preserved inline comments)
│   │   │   ├── LevelDatabase.lua              # Transpiled from levels.json (level progression, attribute caps, health/resource scaling)
│   │   │   ├── RaceDatabase.lua               # Transpiled from races.json (playable races, base attributes, racial traits)
│   │   │   ├── ShieldDatabase.lua             # Transpiled from shields.json (shield types, block values, damage reduction, speed penalties)
│   │   │   ├── WeaponsDatabase.lua            # Transpiled from weapons.json (weapon categories, damage ranges, critical ranges, dual-wield penalties)
│   │   │   ├── SkillsDatabase.lua             # Transpiled from strength_skills.json, dex_skills.json, constitution_skills.json
│   │   │   └── SpellsDatabase.lua             # Transpiled from arcane.json, chi.json, elemental.json, elune.json, fel.json, holy_light.json, nature.json, necromance.json, shadow.json, worgenCurse.json
│   │   └── domain.xml                         # Domain master manifest referencing database/database.xml
│   ├── ports/
│   │   ├── metadata/
│   │   │   ├── metadataPorts.xml              # Manifest for metadata access ports
│   │   │   ├── ArmorPort.lua                  # Read-only query endpoints (GetAll, GetById) for ArmorDatabase
│   │   │   ├── TraitsPort.lua                 # Read-only query endpoints (GetAll, GetPositiveTraits, GetNegativeTraits, GetPositiveTraitById, GetNegativeTraitById) for TraitsDatabase
│   │   │   ├── LevelPort.lua                  # Read-only query endpoints (GetAll, GetByLevel) for LevelDatabase
│   │   │   ├── RacePort.lua                   # Read-only query endpoints (GetAll, GetById) for RaceDatabase
│   │   │   ├── ShieldPort.lua                 # Read-only query endpoints (GetAll, GetById) for ShieldDatabase
│   │   │   ├── WeaponsPort.lua                # Read-only query endpoints (GetAll, GetById) for WeaponsDatabase
│   │   │   ├── SkillsPort.lua                 # Read-only query endpoints (GetAll, GetStrengthSkills, GetDexSkills, GetConstitutionSkills, GetSkillById) for SkillsDatabase
│   │   │   └── SpellsPort.lua                 # Read-only query endpoints (GetAll, GetSpellsBySchool, GetSpellById) for SpellsDatabase
│   │   └── ports.xml                          # Ports master manifest referencing metadata/metadataPorts.xml
```

**Structure Decision**: WoW Addon Hexagonal Architecture. Transpiled immutable core tables are strictly isolated within `src/main/domain/database/`, while external callers (character creation UI, inspection panel, dice combat mechanics) access them exclusively through read-only metadata ports in `src/main/ports/metadata/`.

## Planned Execution Phases

### Phase 1: Database Transpilation & Data Isolation (`src/main/domain/database/`)
- Transpile Lua database tables from all 19 source files into `src/main/domain/database/`.
- Ensure objects/lists retain their exact definition of truth (property keys, data types, nested array formats).
- Retain all inline technical comments from `traits-types.ts` directly above corresponding trait entries in `TraitsDatabase.lua`.
- Enforce immutability and read-only protection on all domain database tables.

### Phase 2: Cascading XML Manifest Resolution
- Create `src/main/domain/database/database.xml` declaring all database Lua scripts.
- Wire `database.xml` into `src/main/domain/domain.xml`.
- Create `src/main/ports/metadata/metadataPorts.xml` declaring all metadata port scripts.
- Wire `metadataPorts.xml` into `src/main/ports/ports.xml`.

### Phase 3: Metadata Ports Implementation (`src/main/ports/metadata/`)
- Implement abstract read-only interface ports for every domain database table.
- Provide `GetAll()` endpoints returning the complete reference dataset.
- Provide `GetById(id)` / `GetByKey(key)` endpoints returning specific entries or `nil` if not found.

### Phase 4: Probing & Table Parity Verification
- Probe each port endpoint by querying returned tables and comparing them against source Lua database tables.
- Verify 100% data parity, comment retention in traits, zero WoW API leakage, and zero runtime mutation vulnerability.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |
