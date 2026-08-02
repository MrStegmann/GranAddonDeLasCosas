# Sprint Backlog: Sprint 2 — Legacy Decoupling & Micro-Frontend Migration

**Sprint Identifier**: `specs/002-Migration`  
**Parent Document**: [summary.md](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/specs/002-Migration/summary.md)  
**Total Estimated Velocity**: 38 Story Points (SP)  
**Status**: Backlog / Ready for Refinement  

---

## Sprint Goal

Completely eliminate the dual architectural state in `src/` by deprecating legacy monolithic models (`src/Models/`), services (`src/Services/`), and monolithic frame modules (`src/Frames/`, `src/Communication/`). Realign all legacy UI views into autonomous Micro-Frontends under `src/ui/` communicating strictly via `LocalIPCAdapter`, achieving 100% Hexagonal and Micro-Frontend purity.

---

## Epics & User Stories Breakdown

### Epic 1: Legacy Model & Service Deprecation (10 SP)

#### Story 1.1: Legacy Entity Redirection & Global Alias Cleanup (4 SP)
* **Description**: As a system developer, I need all legacy references to `GAC.Character`, `GAC.Item`, `GAC.Armor`, and `GAC.Weapon` to be safely aliased to the pure Lua domain factories in `src/main/domain/` so that no legacy model code is executed.
* **Tasks**:
  1. Verify `src/main/domain/Character.lua`, `Item.lua`, `Armor.lua`, and `Weapon.lua` fulfill all legacy getter/setter interfaces.
  2. Update global `GAC` bindings in `index.lua` to reference `src/main/domain/` factories.
  3. Audit codebase for any hardcoded `GAC.Character:new()` instantiations and replace with `Character.create()`.
* **Acceptance Criteria**:
  - Zero calls to legacy `src/Models/*.lua` files remain.
  - All domain model creations return validated schema instances from `src/main/domain/`.

#### Story 1.2: CharacterService Deprecation & CharacterCalculator Integration (4 SP)
* **Description**: As a developer, I need to refactor all consumer modules calling `GAC.Services.CharacterService` to use `CharacterCalculator.lua` and domain model getters directly so that `CharacterService.lua` can be safely removed.
* **Tasks**:
  1. Audit `src/Services/CharacterService.lua` calls across legacy UI frames.
  2. Replace `GetAttributes()`, `GetTalents()`, and stat math calls with `Character:GetAttributes()`, `Character:GetTalents()`, and `CharacterCalculator` methods.
* **Acceptance Criteria**:
  - No active script imports or invokes `CharacterService`.
  - All stat and attribute calculations evaluate deterministically through `CharacterCalculator.lua`.

#### Story 1.3: Legacy Model & Service File Deletion (2 SP)
* **Description**: As a repository maintainer, I need to remove obsolete files from `src/Models/` and `src/Services/` to prevent confusion and duplicate code paths.
* **Tasks**:
  1. Remove `src/Models/Character.lua`, `src/Models/Item.lua`, `src/Models/Armor.lua`, `src/Models/Weapon.lua`, and `src/Models/Models.xml`.
  2. Remove `src/Services/CharacterService.lua` and `src/Services/Services.xml`.
* **Acceptance Criteria**:
  - `src/Models/` and `src/Services/` directories are completely deleted from `src/`.

---

### Epic 2: Status Plates Micro-Frontend Migration (`src/Frames/` → `src/ui/`) (12 SP)

#### Story 2.1: PlayerPlate Micro-Frontend Migration (4 SP)
* **Description**: Refactor `src/Frames/PlayerPlate/` into an autonomous micro-frontend under `src/ui/player-plate/`.
* **Tasks**:
  1. Scaffold `src/ui/player-plate/` with `components/`, `hooks/`, `api/playerPlateApi.lua`, `index.lua`, and `player-plate.xml`.
  2. Connect `playerPlateApi.lua` to `LocalIPCAdapter` channel `CHARACTER_UPDATED`.
  3. Remove direct WoW event listeners from `PlayerPlateHooks.lua`.
* **Acceptance Criteria**:
  - PlayerPlate frame renders using shared panel templates.
  - Frame updates automatically upon receiving `CHARACTER_UPDATED` IPC broadcasts without accessing domain backend instances directly.

#### Story 2.2: TargetPlate Micro-Frontend Migration (4 SP)
* **Description**: Refactor `src/Frames/TargetPlate/` into an autonomous micro-frontend under `src/ui/target-plate/`.
* **Tasks**:
  1. Scaffold `src/ui/target-plate/` (`targetPlateApi.lua`, `components/`, `hooks/`, `index.lua`, `target-plate.xml`).
  2. Connect `targetPlateApi.lua` to `LocalIPCAdapter` channel `INSPECTION_DATA_READY`.
* **Acceptance Criteria**:
  - TargetPlate operates as an isolated UI view without cross-importing `PlayerPlate` or `RaidPlate` scripts.

#### Story 2.3: RaidPlate Micro-Frontend Migration (4 SP)
* **Description**: Refactor `src/Frames/RaidPlate/` into an autonomous micro-frontend under `src/ui/raid-plate/`.
* **Tasks**:
  1. Scaffold `src/ui/raid-plate/` (`raidPlateApi.lua`, `components/`, `hooks/`, `index.lua`, `raid-plate.xml`).
  2. Connect `raidPlateApi.lua` to `LocalIPCAdapter` for party/raid roster state changes.
* **Acceptance Criteria**:
  - Group roster frames update strictly over IPC payload dispatches.

---

### Epic 3: Menu, Inspection & Action Micro-Frontends Migration (10 SP)

#### Story 3.1: MainMenu & Character Sheet Sub-Tabs Migration (4 SP)
* **Description**: Refactor legacy `src/Frames/MainMenu/` (Inventory, Attributes, Experience) into `src/ui/sheet/` or `src/ui/main-menu/`.
* **Tasks**:
  1. Move `AttributesTab.lua`, `InventoryScreen.lua`, and `ExperienceScreen.lua` into `src/ui/sheet/components/`.
  2. Move `MinimapButton.lua` hook to `src/ui/shared/`.
* **Acceptance Criteria**:
  - MainMenu tabs render using shared UI templates and bind strictly to `sheetApi.lua`.

#### Story 3.2: InspectionMenu & QuickButtons Migration (3 SP)
* **Description**: Refactor `src/Frames/InspectionMenu/` and `src/Frames/QuickButtonsMenu/` into `src/ui/inspection/` and `src/ui/quick-actions/`.
* **Tasks**:
  1. Create `src/ui/inspection/` (`inspectionApi.lua`, `index.lua`, `inspection.xml`).
  2. Create `src/ui/quick-actions/` (`quickActionsApi.lua`, `index.lua`, `quick-actions.xml`).
* **Acceptance Criteria**:
  - Inspection and Quick Action frames operate autonomously without holding direct references to backend services.

#### Story 3.3: Economy, Initiative & ExpBar Migration (3 SP)
* **Description**: Refactor `EconomyCalculator`, `InitiativeOrders`, and `ExpBar` into `src/ui/economy/`, `src/ui/initiative/`, and `src/ui/exp-bar/`.
* **Tasks**:
  1. Scaffold individual micro-frontend manifests and indices for economy, initiative, and exp-bar.
* **Acceptance Criteria**:
  - All remaining legacy frames in `src/Frames/` are relocated to `src/ui/`.

---

### Epic 4: Infrastructure Realignment & Legacy Manifest Cleanup (6 SP)

#### Story 4.1: Network Communication & TRP3 Realignment (3 SP)
* **Description**: Encapsulate P2P network transmission (`src/Communication/`) and TRP3 hooks inside backend infrastructure adapters.
* **Tasks**:
  1. Move `Transmitter.lua` and `Receiver.lua` into `src/main/adapters/network/`.
  2. Refactor `TRP3ArmorHook.lua` and `TRP3Inventory.lua` into `src/main/adapters/TRP3Adapter.lua`.
  3. Delete `src/Communication/`.
* **Acceptance Criteria**:
  - All network messaging and TRP3 queries route through `NetworkAdapter` and `TRP3Adapter`.

#### Story 4.2: Data & Locales Integration (2 SP)
* **Description**: Realign `src/Data/` tables and `src/Locales/` into clean backend modules.
* **Tasks**:
  1. Inject static game tables (`LevelTable.lua`, `Races.lua`, `AttributesAndTalents.lua`) into domain calculator services.
  2. Move localization files (`src/Locales/`) to `src/main/adapters/locales/`.
* **Acceptance Criteria**:
  - Data tables no longer pollute the global `GAC` table directly.

#### Story 4.3: Legacy Directory & Manifest Deletion (1 SP)
* **Description**: Remove all remaining legacy directories under `src/` and consolidate `GAC_DEV.toc`.
* **Tasks**:
  1. Remove legacy directories: `Communication/`, `Constants/`, `Enums/`, `Events/`, `Frames/`, `Hooks/`, `Locales/`, `Models/`, `Services/`, `Utils/`.
  2. Remove `GranAddonDeLasCosas.xml` from `GAC_DEV.toc` and delete the file.
* **Acceptance Criteria**:
  - `src/` contains **only** `main/`, `ui/`, and `src.xml`.
  - `GAC_DEV.toc` loads strictly `src\src.xml` and `index.lua`.

---

## Definition of Done (DoD) Checklist

- [ ] **Domain Purity**: All files inside `src/main/domain/` are 100% pure Lua 5.1 with zero WoW client API references.
- [ ] **Micro-Frontend Autonomy**: UI features inside `src/ui/` do not import cross-feature scripts or listen directly to WoW events; all communications flow over `LocalIPCAdapter`.
- [ ] **Cascading Manifest Integrity**: Every folder inside `src/main/` and `src/ui/` contains a valid `[folder].xml` manifest loaded bottom-up.
- [ ] **Zero Global Leaks**: All Lua scripts strictly enforce `local` scoping.
- [ ] **Directory Hygiene**: `src/` contains only `main/`, `ui/`, and `src.xml`.
- [ ] **Memory Sync**: `memory-bank/activeContext.md` and `memory-bank/progress.md` updated upon completion.
