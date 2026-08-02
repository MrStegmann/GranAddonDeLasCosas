# Active Context & Current Focus

## Current Phase: Feature 003 — Core Data Metadata Tables & Services (Completed)

## Recent Architectural Deliverables
1. **Transpiled Domain Database Tables (`src/main/domain/database/`):**
   - Transpiled all 7 TS types/constants into pure Lua 5.1 tables: `ArmorDatabase.lua`, `AttributesTalentsDatabase.lua`, `LevelDatabase.lua`, `RaceDatabase.lua`, `ShieldDatabase.lua`, `TraitsDatabase.lua`, and `WeaponsDatabase.lua`.
   - Created `src/main/domain/database/database.xml` and wired into `src/main/domain/domain.xml`.
2. **Metadata Read-Only Access Ports (`src/main/ports/metadata/`):**
   - Implemented `ArmorPort.lua`, `AttributesTalentsPort.lua`, `LevelPort.lua`, `RacePort.lua`, `ShieldPort.lua`, `TraitsPort.lua`, and `WeaponsPort.lua`.
   - Created `src/main/ports/metadata/metadataPorts.xml` and wired into `src/main/ports/ports.xml`.
3. **Mechanical Trait Services (`src/main/adapters/services/traits/`):**
   - Implemented `combatTraitsService.lua`, `talentTraitsService.lua`, and `progressionTraitsService.lua`.
   - Created `traitsServices.xml` & `services.xml` and wired into `src/main/adapters/adapters.xml`.
4. **Domain Model Schema Parity (`src/main/domain/models/`):**
   - Updated `Armor.lua`, `Shield.lua`, `Weapon.lua`, and `Character.lua` to ensure 100% parity with `*-types.ts` specifications.

## Active Architectural Principles
* **Hexagonal Domain Purity:** Logic in `src/main/domain/` operates exclusively in pure Lua 5.1 with zero WoW client API references.
* **Micro-Frontend UI Isolation:** UI views communicate exclusively over `LocalIPCAdapter` using feature-scoped client APIs.
* **Cascading XML Load Order:** All files are declared in bottom-up cascading XML manifests (`[folder].xml`).
