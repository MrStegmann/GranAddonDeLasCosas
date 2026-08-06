# Active Context & Current Focus

## Current Phase: WoW 9.2.7 (Shadowlands) Environmental Alignment

## Recent Architectural Deliverables
1. **Synchronized Addon Environment & Versioning for WoW 9.2.7 (Shadowlands Expansion):**
   - Updated `GAC_DEV.toc` Interface header to `90207` (Shadowlands 9.2.7).
   - Synchronized `CONTEXT.md`, `README.md`, `specs/`, and `memory-bank/` to target WoW 9.2.7 (Shadowlands).

2. **Executed Feature 002 Core Data (`specs/002-core-data/tasks.md` Tasks T001–T045):**
   - [x] **Setup & Foundational (Phases 1-2)**: Created `ReadOnlyHelper.lua`, `database.xml`, and `metadataPorts.xml`.
   - [x] **Core Reference Data (Phase 3)**: Transpiled `RaceDatabase`, `LevelDatabase`, `TraitsDatabase` (100% comments preserved) and created `RacePort`, `LevelPort`, `TraitsPort`.
   - [x] **Equipment Datasets (Phase 4)**: Transpiled `ArmorDatabase`, `WeaponsDatabase` (36 weapons), `ShieldDatabase` and created `ArmorPort`, `WeaponsPort`, `ShieldPort`.
   - [x] **Skills & Spells Datasets (Phase 5)**: Transpiled `StrengthSkillsDatabase`, `DexSkillsDatabase`, `ConstitutionSkillsDatabase`, `ArcaneDatabase`, `ElementalDatabase`, `EluneDatabase`, `HolyLightDatabase`, `ShadowDatabase`, `WorgenCurseDatabase` and empty datasets (`ChiDatabase`, `FelDatabase`, `NatureDatabase`, `NecromanceDatabase`) with corresponding read-only ports.
   - [x] **Probing Test Suite & Parity (Phase 6)**: Implemented 5 unit test probing suites and master runner [`run_all_probing_tests.lua`](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/tests/probing/run_all_probing_tests.lua) confirming 100% structural parity across all 19 port endpoints.
   - [x] **Polish & Cross-Cutting (Phase 7)**: Validated cascading XML manifests (`database.xml`, `metadataPorts.xml`) and synced memory bank.




2. **Executed Phase 3 User Story 1 (`specs/002-core-data/tasks.md`):**
   - Transpiled `races.json`, `levels.json`, and `traits-types.ts` into isolated Lua database tables and ports with full comment retention.


2. **Executed Phase 1 Setup (`specs/002-core-data/tasks.md`):**
   - [x] `T001`: Verified directory structures for domain database (`src/main/domain/database/`) and metadata ports (`src/main/ports/metadata/`).
   - [x] `T002`: Verified `database.xml` manifest and its include link in `src/main/domain/domain.xml`.
   - [x] `T003`: Created initial `src/main/ports/metadata/metadataPorts.xml` manifest and confirmed link in `src/main/ports/ports.xml`.

2. **Created Core Data Task Breakdown (`specs/002-core-data/tasks.md`):**
   - Generated using `.specify/templates/tasks-template.md` based on `SPEC.md` and `plan.md`.
   - Broken down into 7 sequential phases (45 prioritized tasks).

2. **Created Core Data Implementation Plan (`specs/002-core-data/plan.md`):**
   - Formatted following `.specify/templates/plan-template.md` based on `specs/002-core-data/SPEC.md`.
   - Detailed technical context, constitution gates, project directory trees for 19 isolated database tables and 19 metadata ports, and complexity tracking.
3. **Updated Core Data Specification (`specs/002-core-data/SPEC.md`):**
   - Defined 1:1 isolated migration requirements for all 19 JSON and TS source files into standalone read-only Lua database tables (`src/main/domain/database/`) and metadata ports (`src/main/ports/metadata/`).
   - Enforced strict table isolation (zero grouping across skills or spell schools).
   - Added explicit requirement for empty source JSON files (`fel.json`, `chi.json`, `nature.json`, `necromance.json`) to be created as valid empty tables `{}` with dedicated ports.



2. **Third-Party WoW Addon Libraries (`libs/` & `libs.xml`):**
   - Integrated `LibStub` and `CallbackHandler-1.0` base framework dependencies.
   - Integrated complete **Ace3 Suite**: `AceAddon-3.0`, `AceEvent-3.0`, `AceDB-3.0`, `AceDBOptions-3.0`, `AceConsole-3.0`, `AceGUI-3.0`, `AceComm-3.0`, and `AceSerializer-3.0`.
   - Integrated Minimap & Data Broker libraries: `LibDataBroker-1.1` and `LibDBIcon-1.0`.
   - Integrated high-performance payload compression library: `LibDeflate`.
3. **Domain Model & Port Infrastructure:**
   - Standardized ports and domain database interfaces following hexagonal architecture principles.

## Active Architectural Principles
* **1:1 Data Isolation:** Every JSON/TS file in `specs/002-core-data/` maps to its own isolated Lua database table and port without grouping.
* **Hexagonal Domain Purity:** Logic in `src/main/domain/` operates exclusively in pure Lua 5.1 with zero WoW client API references.
* **Micro-Frontend UI Isolation:** UI views communicate exclusively over `LocalIPCAdapter` using feature-scoped client APIs.
* **Cascading XML Load Order:** All files are declared in bottom-up cascading XML manifests (`[folder].xml`).

