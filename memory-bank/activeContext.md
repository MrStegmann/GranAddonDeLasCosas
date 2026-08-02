# Active Context & Current Focus

## Current Phase: Sprint 2 — Legacy Decoupling & Micro-Frontend Migration (Completed)

## Recent Architectural Deliverables
1. **Legacy Model & Service Deprecation:**
   - Removed legacy `src/Models/` and `src/Services/` directories.
   - Aliased `GAC.Character`, `GAC.Item`, `GAC.Armor`, `GAC.Weapon`, `GAC.CharacterCalculator`, and `GAC.Services.CharacterService` in `index.lua` to pure Lua domain modules under `src/main/domain/`.
2. **Micro-Frontend Realignment (`src/ui/`):**
   - Refactored all visual frames into autonomous micro-frontends: `player-plate`, `target-plate`, `raid-plate`, `main-menu`, `inspection`, `quick-actions`, `economy`, `initiative`, `exp-bar`, `sheet`, `combat`.
   - Connected all UI views to `LocalIPCAdapter` via dedicated client APIs (`playerPlateApi`, `targetPlateApi`, `raidPlateApi`, `inspectionApi`, `quickActionsApi`, `sheetApi`).
3. **Infrastructure & Data Consolidation (`src/main/`):**
   - Encapsulated roleplay data tables into `src/main/domain/DataTables.lua`.
   - Encapsulated localization strings into `src/main/adapters/locales/LocalesAdapter.lua`.
   - Realigned P2P messaging into `NetworkAdapter.lua` and TRP3 profile queries into `TRP3Adapter.lua`.
4. **Complete Directory Cleanup & TOC Consolidation:**
   - Deleted all 11 legacy subdirectories from `src/` (`Models/`, `Services/`, `Frames/`, `Communication/`, `Constants/`, `Enums/`, `Events/`, `Hooks/`, `Locales/`, `Utils/`) and deleted `GranAddonDeLasCosas.xml`.
   - `src/` now contains **strictly** `main/`, `ui/`, and `src.xml`.
   - `GAC_DEV.toc` loads strictly `src\src.xml` and `index.lua`.

## Active Architectural Principles
* **Hexagonal Domain Purity:** Logic in `src/main/domain/` operates exclusively in pure Lua 5.1 with zero WoW client API references.
* **Micro-Frontend UI Isolation:** UI views communicate exclusively over `LocalIPCAdapter` using feature-scoped client APIs.
* **Cascading XML Load Order:** All files are declared in bottom-up cascading XML manifests (`[folder].xml`).
