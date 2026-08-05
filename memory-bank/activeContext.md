# Active Context & Current Focus

## Current Phase: Core Data Specification & Planning (Completed)

## Recent Architectural Deliverables
0. **Core Data Feature Specification & Planning (`specs/002-core-data/`):**
   - Updated `SPEC.md` to Approved status incorporating user scenarios, functional requirements, key entities, edge cases, and success criteria.
   - Created `plan.md` adhering to `.specify/templates/plan-template.md` defining the technical context, constitution gates, project structure, and complexity tracking for immutable domain data transpilation.
1. **Third-Party WoW Addon Libraries (`libs/` & `libs.xml`):**
   - Integrated `LibStub` and `CallbackHandler-1.0` base framework dependencies.
   - Integrated complete **Ace3 Suite**: `AceAddon-3.0`, `AceEvent-3.0`, `AceDB-3.0`, `AceDBOptions-3.0`, `AceConsole-3.0`, `AceGUI-3.0`, `AceComm-3.0`, and `AceSerializer-3.0`.
   - Integrated Minimap & Data Broker libraries: `LibDataBroker-1.1` and `LibDBIcon-1.0`.
   - Integrated high-performance payload compression library: `LibDeflate`.
   - Created `libs/libs.xml` master manifest and registered it in `GAC_DEV.toc` before `src/src.xml`.
2. **Transpiled Domain Database Tables (`src/main/domain/database/`):**
   - Transpiled all 7 TS types/constants into pure Lua 5.1 tables: `ArmorDatabase.lua`, `AttributesTalentsDatabase.lua`, `LevelDatabase.lua`, `RaceDatabase.lua`, `ShieldDatabase.lua`, `TraitsDatabase.lua`, and `WeaponsDatabase.lua`.
   - Created `src/main/domain/database/database.xml` and wired into `src/main/domain/domain.xml`.
3. **Metadata Read-Only Access Ports (`src/main/ports/metadata/`):**
   - Implemented `ArmorPort.lua`, `AttributesTalentsPort.lua`, `LevelPort.lua`, `RacePort.lua`, `ShieldPort.lua`, `TraitsPort.lua`, and `WeaponsPort.lua`.
   - Created `src/main/ports/metadata/metadataPorts.xml` and wired into `src/main/ports/ports.xml`.
4. **Mechanical Trait Services (`src/main/adapters/services/traits/`):**
   - Implemented `combatTraitsService.lua`, `talentTraitsService.lua`, and `progressionTraitsService.lua`.
   - Created `traitsServices.xml` & `services.xml` and wired into `src/main/adapters/adapters.xml`.
5. **Domain Model Schema Parity (`src/main/domain/models/`):**
   - Updated `Armor.lua`, `Shield.lua`, `Weapon.lua`, and `Character.lua` to ensure 100% parity with `*-types.ts` specifications.

## Active Architectural Principles
* **Hexagonal Domain Purity:** Logic in `src/main/domain/` operates exclusively in pure Lua 5.1 with zero WoW client API references.
* **Micro-Frontend UI Isolation:** UI views communicate exclusively over `LocalIPCAdapter` using feature-scoped client APIs.
* **Cascading XML Load Order:** All files are declared in bottom-up cascading XML manifests (`[folder].xml`).
