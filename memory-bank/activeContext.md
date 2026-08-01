# Active Context & Current Focus

## Current Phase: Sprint 1 — Architectural Realignment & Hexagonal Migration (Completed)

## Recent Architectural Deliverables
1. **Directory & Manifest Scaffolding (`src/main/`, `src/ui/`):**
   - Created `src/src.xml`, `src/main/main.xml`, `src/ui/ui.xml`, and sub-folder XML manifests.
   - Updated [GAC_DEV.toc](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/GAC_DEV.toc) to load `src/src.xml` as primary entry manifest.
2. **Domain Models & Calculation Engine (`src/main/domain/`):**
   - Implemented pure Lua 5.1 domain entity factories: `Item.create()`, `Armor.create()`, `Weapon.create()`, `Character.create()`.
   - Created `CharacterCalculator.lua` encapsulating deterministic stat, health, and attribute math without WoW API calls.
3. **Ports & Technical Infrastructure Adapters (`src/main/ports/`, `src/main/adapters/`):**
   - Defined port interfaces: `IPCMessagePort.lua`, `StoragePort.lua`, `RemotePlayerPort.lua`.
   - Implemented `EventDispatcher.lua`, `LocalIPCAdapter.lua`, `SavedVarsStorageAdapter.lua`, `TRP3Adapter.lua`, `NetworkAdapter.lua`, and `RemoteCacheAdapter.lua`.
4. **UI Micro-Frontend Scaffolding (`src/ui/`):**
   - Implemented shared UI layout templates (`Templates.xml`) and helper functions (`UIHelpers.lua`).
   - Scaffolded Character Sheet micro-frontend (`src/ui/sheet/`) with IPC client API adapter (`sheetApi.lua`).
5. **Clean Runtime Tree:**
   - Removed all non-executable TypeScript (`.ts`) files from `src/Models/modelosTS/` and archived reference definitions into `.specs/modelosTS/`.

## Active Architectural Principles
* **Hexagonal Domain Purity:** Logic in `src/main/domain/` operates exclusively in pure Lua 5.1 with zero WoW client API references.
* **Micro-Frontend UI Isolation:** UI views communicate exclusively over `LocalIPCAdapter` using feature-scoped client APIs (`sheetApi.lua`).
* **Cascading XML Load Order:** All files are declared in bottom-up cascading XML manifests (`[folder].xml`).
