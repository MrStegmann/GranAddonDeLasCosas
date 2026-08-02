# Project Architecture & State Summary

**Role:** Scrum Master Report  
**Date:** 02/08/2026  
**AddOn:** GAC_DEV (Gran Addon De Las Cosas)  
**Target Architecture:** Hexagonal Backend (`src/main/`) & Autonomous Micro-Frontends (`src/ui/`)

---

## 1. Project Description

`GAC_DEV` is a World of Warcraft Retail AddOn for tabletop roleplay character management, stat/attribute tracking, custom armor/weapon math, dice rolling, and peer-to-peer player communication (with Total RP 3 integration). 

The team is actively executing an architectural migration to transition the project from a legacy monolithic layout into a clean **Hexagonal Architecture** (`src/main/`) and **Micro-Frontend UI Architecture** (`src/ui/`), enforcing domain purity, bottom-up XML dependency loading, and decoupled event messaging.

---

## 2. Current State of the Project

Sprint 1 ([spec.md](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/specs/001-architectural-realignment-hexagonal-infrastructure/spec.md)) has been successfully completed (`Status: DONE`). The core foundation is operational:

* **Hexagonal Core (`src/main/`):**
  * **Domain Layer (`src/main/domain/`):** `Character.lua`, `Item.lua`, `Armor.lua`, `Weapon.lua`, and `CharacterCalculator.lua` are implemented in pure Lua 5.1 with schema validation factories (`Model.create(raw_data)`), zero WoW engine dependencies, and side-effect-free math functions.
  * **Ports Layer (`src/main/ports/`):** Abstract interfaces defined for messaging (`IPCMessagePort`), persistence (`StoragePort`), and remote player data (`RemotePlayerPort`).
  * **Adapters Layer (`src/main/adapters/`):** `EventDispatcher.lua` (driving adapter for WoW events), `LocalIPCAdapter.lua` (synchronous pub/sub bus for UI communication), `SavedVarsStorageAdapter.lua` (persistence gateway for `GAC_CharacterDB`), `TRP3Adapter.lua` (defensive TRP3 wrapper), `NetworkAdapter.lua`, and `RemoteCacheAdapter.lua`.
* **Micro-Frontend UI Foundation (`src/ui/`):**
  * Shared panel templates ([Templates.xml](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/src/ui/shared/Templates.xml)) and visual utilities ([UIHelpers.lua](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/src/ui/shared/UIHelpers.lua)).
  * Character Sheet micro-frontend ([src/ui/sheet/](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/src/ui/sheet/)) communicating strictly via [sheetApi.lua](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/src/ui/sheet/api/sheetApi.lua) over `LocalIPCAdapter`.
* **Cascading XML Manifest Hierarchy:**
  * Top-level entry point updated in [GAC_DEV.toc](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/GAC_DEV.toc) pointing to [src/src.xml](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/src/src.xml), loading `main/main.xml` and `ui/ui.xml` in strict bottom-up order.
* **TypeScript Cleanup:**
  * All legacy non-executable `.ts` files removed from `src/Models/modelosTS/` and archived to [.specs/modelosTS/](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/.specs/modelosTS/).

---

## 3. Mismatches Between Context & Actual Codebase

While the high-level documentation (`memory-bank/systemPatterns.md`, `memory-bank/activeContext.md`) emphasizes `src/main/` and `src/ui/`, **the active codebase under `src/` is currently in a hybrid transitional state** and still contains 11 legacy directories alongside the new architecture:

```text
src/
├── main/              # NEW: Hexagonal Backend (domain, ports, adapters)
├── ui/                # NEW: Micro-Frontends (shared, sheet, combat)
├── Communication/     # LEGACY: Network receivers, transmitters, TRP3 hooks
├── Constants/         # LEGACY: Global GameConstants.lua
├── Data/              # LEGACY: LevelTable.lua, Races.lua, Armor.lua, Weapons.lua
├── Enums/             # LEGACY: EventsName.lua
├── Events/            # LEGACY: Monolithic event handlers
├── Frames/            # LEGACY: MainMenu, PlayerPlate, TargetPlate, RaidPlate, etc.
├── Hooks/             # LEGACY: UI hooks
├── Locales/           # LEGACY: ES_es.lua localization
├── Models/            # LEGACY: Legacy Character.lua, Item.lua, Armor.lua, Weapon.lua
├── Services/          # LEGACY: Legacy CharacterService.lua
└── Utils/             # LEGACY: Helpers.lua, VersionBridge.lua
```

### Key Mismatches Identified:

1. **Dual Architectural Structure:** `src/` contains both the new Hexagonal/Micro-Frontend structure (`src/main/`, `src/ui/`) and the legacy monolithic structure (`src/Frames/`, `src/Models/`, `src/Services/`, `src/Communication/`).
2. **Duplicate Entity Declarations:** Domain models exist in both `src/main/domain/` (pure Lua entities) and `src/Models/` (legacy `GAC.Character` entities). `index.lua` bridges them, but legacy models are still loaded via `GranAddonDeLasCosas.xml`.
3. **Legacy UI Coupling:** Legacy UI frames in `src/Frames/` (e.g. `PlayerPlate`, `TargetPlate`, `InspectionMenu`, `MainMenu`) still call `GAC` global methods and legacy services directly, rather than listening to `LocalIPCAdapter` channels via feature `api/` adapters.
4. **Direct WoW API Leakage in Legacy Code:** `src/Communication/`, `src/Frames/`, and `src/Models/` directly invoke WoW client APIs (`UnitName`, `CreateFrame`, `UnitRace`, `UnitClass`) instead of using `src/main/adapters/`.
5. **Data Table Coupling:** `src/Data/` tables (`LevelTable.lua`, `Races.lua`, `AttributesAndTalents.lua`) pollute the global `GAC` table directly rather than being cleanly injected into domain entities and calculators.

---

## 4. Next Steps (Recommended Sprint Backlog)

To resolve architectural mismatches and achieve 100% Hexagonal and Micro-Frontend realignment, the following upcoming Sprints are recommended:

### Sprint 2: Legacy Model & UI Micro-Frontend Migration

* **Story 2.1: Legacy Model & Service Deprecation**
  * Redirect all callers of legacy `GAC.Character` and `GAC.Services.CharacterService` to `src/main/domain/Character.lua` and `CharacterCalculator.lua`.
  * Delete legacy files in `src/Models/` and `src/Services/`.
* **Story 2.2: Status Plates Micro-Frontend Migration (`src/Frames/` → `src/ui/`)**
  * Refactor `PlayerPlate`, `TargetPlate`, and `RaidPlate` into autonomous micro-frontends under `src/ui/player-plate/`, `src/ui/target-plate/`, and `src/ui/raid-plate/`.
  * Connect views to `LocalIPCAdapter` via dedicated client APIs (`playerPlateApi.lua`, `targetPlateApi.lua`).
* **Story 2.3: Menu & Inspection Micro-Frontend Migration**
  * Refactor `MainMenu`, `InspectionMenu`, `QuickButtonsMenu`, and `InitiativeOrders` into `src/ui/main-menu/`, `src/ui/inspection/`, `src/ui/quick-actions/`, and `src/ui/initiative/`.

### Sprint 3: Infrastructure Realignment & Legacy Manifest Cleanup

* **Story 3.1: Network & Communication Adapters Realignment**
  * Migrate `src/Communication/` (`Transmitter.lua`, `Receiver.lua`) into `src/main/adapters/network/`.
  * Fully encapsulate TRP3 hooks (`src/Communication/TRP3/`) inside `src/main/adapters/TRP3Adapter.lua`.
* **Story 3.2: Data & Localization Integration**
  * Inject `src/Data/` tables into domain calculator services.
  * Move `src/Locales/` to `src/main/adapters/locales/`.
* **Story 3.3: Legacy Directory & Manifest Deletion**
  * Remove obsolete legacy directories (`src/Communication/`, `src/Constants/`, `src/Events/`, `src/Frames/`, `src/Hooks/`, `src/Models/`, `src/Services/`, `src/Utils/`).
  * Remove `GranAddonDeLasCosas.xml` from `GAC_DEV.toc`, leaving `src/src.xml` as the single root manifest.
