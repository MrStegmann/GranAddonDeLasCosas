# Implementation Plan: Core Hardcoded Domain Data Layer

**Branch**: `002-core-data` | **Date**: 2026-08-05 | **Spec**: [SPEC.md](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/specs/002-core-data/SPEC.md)

**Input**: Feature specification from `specs/002-core-data/SPEC.md`

## Summary

Migrate all 19 core reference data sources (17 JSON files and 2 TypeScript files in `specs/002-core-data/`) into strictly isolated, independent read-only Lua 5.1 tables in `src/main/domain/database/`. Expose every database table exclusively through its own dedicated read-only port interface in `src/main/ports/metadata/` with `GetAll()` and `GetById(id)` functions. Empty source JSON files (`fel.json`, `chi.json`, `nature.json`, `necromance.json`) will be instantiated as isolated empty tables `{}` with dedicated ports. `PositiveTraits` and `NegativeTraits` from `traits-types.ts` will conserve all inline comments as Lua documentation comments. Probing test coverage will verify 100% structural equality for all endpoints.

## Technical Context

**Language/Version**: Pure Lua 5.1 (Addon backend domain & ports)  
**Primary Dependencies**: None (pure Lua 5.1 domain logic without external libraries or WoW APIs)  
**Storage**: Static immutable Lua tables in `src/main/domain/database/` (Read-only reference data)  
**Testing**: Lua test runner probing endpoints for 1:1 structural equality against domain database tables  
**Target Platform**: World of Warcraft Retail Client (11.x / 12.x Lua 5.1 sandbox)  
**Project Type**: WoW Addon Domain Database & Metadata Ports Layer  
**Performance Goals**: Instantaneous sub-millisecond in-memory lookups for `GetAll()` and `GetById()` queries  
**Constraints**: 
- Zero World of Warcraft Client API calls inside `src/main/domain/database/` and `src/main/ports/` (Domain Purity).
- 1:1 file isolation (no grouping across files or spell schools).
- Definition of truth preserved from JSON/TS files without structural alterations.
- Read-only safety (returned tables protected against runtime mutation).  
**Scale/Scope**: 19 data sources (17 JSON files, 2 TS files), 19 isolated Lua database files, 19 metadata port files.

## Constitution Check

- **Domain Purity Gate**: PASSED. All database tables and port interfaces consist strictly of pure Lua 5.1 without WoW API dependencies (`CreateFrame`, `RegisterEvent`, etc.).
- **Boundary Isolation Gate**: PASSED. Database tables are isolated in `src/main/domain/database/` and accessible exclusively through `src/main/ports/metadata/`. UI layer and external adapters cannot access database tables directly.
- **1:1 File Isolation Gate**: PASSED. Every single JSON and TS file maps 1:1 to its own distinct `.lua` database file and `.lua` port file without grouping.
- **Comment Retention Gate**: PASSED. Inline comments from `traits-types.ts` are preserved as Lua documentation comments in `TraitsDatabase.lua`.

## Project Structure

### Documentation (this feature)

```text
specs/002-core-data/
├── SPEC.md              # Feature specification
├── plan.md              # Implementation plan (this file)
├── research.md          # Technology & transpilation decisions
├── data-model.md        # Entity definitions & 1:1 file mapping schema
├── quickstart.md        # Validation & endpoint probing guide
└── contracts/           # Metadata Port interface contract definitions
    └── metadata-ports.md # Contract schemas for all 19 ports
```

### Source Code (repository root)

```text
src/
├── main/
│   ├── domain/
│   │   └── database/
│   │       ├── database.xml                     # Cascading manifest for all 19 database tables
│   │       ├── ArcaneDatabase.lua               # Transpiled from arcane.json
│   │       ├── ArmorDatabase.lua                # Transpiled from armor-types.ts
│   │       ├── ChiDatabase.lua                  # Transpiled from chi.json (Empty table {})
│   │       ├── ConstitutionSkillsDatabase.lua   # Transpiled from constitution_skills.json
│   │       ├── DexSkillsDatabase.lua            # Transpiled from dex_skills.json
│   │       ├── ElementalDatabase.lua            # Transpiled from elemental.json
│   │       ├── EluneDatabase.lua                # Transpiled from elune.json
│   │       ├── FelDatabase.lua                  # Transpiled from fel.json (Empty table {})
│   │       ├── HolyLightDatabase.lua            # Transpiled from holy_light.json
│   │       ├── LevelDatabase.lua                # Transpiled from levels.json
│   │       ├── NatureDatabase.lua               # Transpiled from nature.json (Empty table {})
│   │       ├── NecromanceDatabase.lua           # Transpiled from necromance.json (Empty table {})
│   │       ├── RaceDatabase.lua                 # Transpiled from races.json
│   │       ├── ShadowDatabase.lua               # Transpiled from shadow.json
│   │       ├── ShieldDatabase.lua               # Transpiled from shields.json
│   │       ├── StrengthSkillsDatabase.lua       # Transpiled from strength_skills.json
│   │       ├── TraitsDatabase.lua               # Transpiled from traits-types.ts (with inline comments)
│   │       ├── WeaponsDatabase.lua              # Transpiled from weapons.json
│   │       └── WorgenCurseDatabase.lua          # Transpiled from worgenCurse.json
│   └── ports/
│       └── metadata/
│           ├── metadataPorts.xml                # Cascading manifest for all 19 ports
│           ├── ArcanePort.lua                   # Interface endpoint for ArcaneDatabase
│           ├── ArmorPort.lua                    # Interface endpoint for ArmorDatabase
│           ├── ChiPort.lua                      # Interface endpoint for ChiDatabase
│           ├── ConstitutionSkillsPort.lua       # Interface endpoint for ConstitutionSkillsDatabase
│           ├── DexSkillsPort.lua                # Interface endpoint for DexSkillsDatabase
│           ├── ElementalPort.lua                # Interface endpoint for ElementalDatabase
│           ├── ElunePort.lua                    # Interface endpoint for EluneDatabase
│           ├── FelPort.lua                      # Interface endpoint for FelDatabase
│           ├── HolyLightPort.lua                # Interface endpoint for HolyLightDatabase
│           ├── LevelPort.lua                    # Interface endpoint for LevelDatabase
│           ├── NaturePort.lua                   # Interface endpoint for NatureDatabase
│           ├── NecromancePort.lua               # Interface endpoint for NecromanceDatabase
│           ├── RacePort.lua                     # Interface endpoint for RaceDatabase
│           ├── ShadowPort.lua                   # Interface endpoint for ShadowDatabase
│           ├── ShieldPort.lua                   # Interface endpoint for ShieldDatabase
│           ├── StrengthSkillsPort.lua           # Interface endpoint for StrengthSkillsDatabase
│           ├── TraitsPort.lua                   # Interface endpoint for TraitsDatabase
│           ├── WeaponsPort.lua                  # Interface endpoint for WeaponsDatabase
│           └── WorgenCursePort.lua              # Interface endpoint for WorgenCurseDatabase
```

**Structure Decision**: Standard Hexagonal Single Project architecture (`src/main/domain/database/` for isolated pure Lua models/tables and `src/main/ports/metadata/` for isolated read-only port contracts).

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| 19 separate database & port files | Strict 1:1 table isolation requirement without grouping | Grouping tables into aggregated files (e.g. SpellsDatabase) violates explicit user requirement for complete data isolation. |

