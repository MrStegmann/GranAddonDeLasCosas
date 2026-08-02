# Feature Specification: Legacy Decoupling & Micro-Frontend Migration

**Feature Branch**: `002-Migration`

**Created**: 02/08/2026

**Status**: DONE

**Input**: [sprint.md](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/specs/002-Migration/sprint.md)

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Legacy Entity Redirection & Global Alias Cleanup (Priority: P1)

As a system developer, I need all legacy instantiations of `GAC.Character`, `GAC.Item`, `GAC.Armor`, and `GAC.Weapon` to map directly to pure Lua domain factories in `src/main/domain/` so that legacy model files are no longer executed or referenced by the system.

**Why this priority**: Critical Blocker (P1). Legacy models in `src/Models/` contain direct WoW engine calls (`UnitName`). Transitioning all instantiations to `src/main/domain/` factories ensures domain purity across all add-on execution paths.

**Independent Test**: Can be tested by instantiating characters, items, armors, and weapons via `GAC.Character.create({})` or `Character.create({})` without loading `src/Models/`, verifying that schema defaults are populated correctly without invoking `UnitName`.

**Acceptance Scenarios**:

1. **Given** global `GAC` context, **When** any module instantiates a character or item model, **Then** execution is handled by `src/main/domain/` factories (`Character.create()`).
2. **Given** legacy data structures, **When** passed to domain entity factories, **Then** raw data is validated and serialized cleanly into standard schema tables.

---

### User Story 2 - CharacterService Deprecation & CharacterCalculator Integration (Priority: P1)

As a developer, I need legacy calls to `GAC.Services.CharacterService` to be refactored to use `CharacterCalculator.lua` and domain model methods directly so that `CharacterService.lua` can be safely deleted.

**Why this priority**: P1 (Critical Blocker). `CharacterService.lua` is a legacy monolithic service that accesses character state directly and creates tight coupling across legacy frames.

**Independent Test**: Can be tested by executing stat queries (attributes, max health, talent modifiers) against `CharacterCalculator.lua` and `Character:GetAttributes()` without initializing `GAC.Services.CharacterService`.

**Acceptance Scenarios**:

1. **Given** a character model instance, **When** UI frames query character attributes or talents, **Then** data is retrieved directly from domain getters (`Character:GetAttributes()`) without invoking `CharacterService`.
2. **Given** character level and constitution inputs, **When** calculating max health, **Then** `CharacterCalculator.CalculateMaxHealth()` returns deterministic math outputs.

---

### User Story 3 - Status Plates Micro-Frontend Migration (`src/Frames/` → `src/ui/`) (Priority: P1)

As a UI micro-frontend agent, I need to refactor `PlayerPlate`, `TargetPlate`, and `RaidPlate` out of `src/Frames/` into autonomous micro-frontends under `src/ui/player-plate/`, `src/ui/target-plate/`, and `src/ui/raid-plate/` communicating strictly via `LocalIPCAdapter`.

**Why this priority**: P1. Status plates are core visual UI elements. Decoupling them from raw WoW `OnEvent` handlers and direct backend state prevents memory leaks and visual desynchronization.

**Independent Test**: Can be tested by mounting `src/ui/player-plate/` and `src/ui/target-plate/` with a mock `LocalIPCAdapter`, publishing `CHARACTER_UPDATED` or `INSPECTION_DATA_READY` dispatches, and verifying frames render accurately without cross-feature imports.

**Acceptance Scenarios**:

1. **Given** `playerPlateApi.lua` subscribed to `CHARACTER_UPDATED`, **When** the backend emits a character state update, **Then** `PlayerPlate` updates its frame health, mana, and shield displays.
2. **Given** `targetPlateApi.lua` subscribed to `INSPECTION_DATA_READY`, **When** target data is received over IPC, **Then** `TargetPlate` updates unit information without listening to raw WoW events directly.

---

### User Story 4 - MainMenu & Character Sheet Sub-Tabs Migration (Priority: P2)

As a user, I need the MainMenu sub-tabs (Inventory, Attributes, Experience) to integrate into `src/ui/sheet/` and `src/ui/main-menu/` using shared UI panel templates.

**Why this priority**: P2. Reorganizing menu tabs enforces uniform visual styling and ensures attribute state updates flow through `sheetApi.lua`.

**Independent Test**: Can be tested by toggling MainMenu tabs in isolation and verifying components render using `src/ui/shared/Templates.xml` without accessing legacy `src/Frames/MainMenu/` files.

**Acceptance Scenarios**:

1. **Given** the Character Sheet frame opened, **When** switching between Attributes, Inventory, and Experience tabs, **Then** views render using shared panel templates without script errors.
2. **Given** attribute updates in `AttributesTab`, **When** modifications occur, **Then** changes trigger IPC dispatches via `sheetApi.lua`.

---

### User Story 5 - InspectionMenu & QuickButtons Micro-Frontend Migration (Priority: P2)

As a player, I need `InspectionMenu` and `QuickButtonsMenu` refactored into `src/ui/inspection/` and `src/ui/quick-actions/` so that target inspection and action triggers operate independently of main character state.

**Why this priority**: P2. Isolating inspection and quick actions into micro-frontends ensures external player queries do not mutate local character state tables.

**Independent Test**: Can be verified by mounting `src/ui/inspection/` independently, passing mock remote player profile dispatches, and confirming inspection views render without requiring main character sheet frames.

**Acceptance Scenarios**:

1. **Given** an inspection trigger on a target unit, **When** inspection data is received via `inspectionApi.lua`, **Then** `InspectionMenu` renders target attributes and equipped armor.
2. **Given** user interaction on Quick Action buttons, **When** clicked, **Then** actions execute via `quickActionsApi.lua` without direct global frame dependencies.

---

### User Story 6 - Economy, Initiative & ExpBar Micro-Frontend Migration (Priority: P2)

As a system, utility views (`EconomyCalculator`, `InitiativeOrders`, `ExpBar`) must be migrated from `src/Frames/` into autonomous micro-frontends under `src/ui/economy/`, `src/ui/initiative/`, and `src/ui/exp-bar/`.

**Why this priority**: P2. Completing the migration of secondary frame modules ensures all visual components reside under `src/ui/`.

**Independent Test**: Verified by checking that `src/Frames/` can be completely deleted without breaking economy, initiative, or experience bar rendering.

**Acceptance Scenarios**:

1. **Given** initiative order changes in combat, **When** updated, **Then** `src/ui/initiative/` receives IPC broadcasts and updates turn ordering.
2. **Given** experience point gains, **When** triggered, **Then** `src/ui/exp-bar/` updates progress bar fill ratios.

---

### User Story 7 - Network Communication & TRP3 Adapter Realignment (Priority: P2)

As an infrastructure agent, I need to relocate `src/Communication/` network logic (`Transmitter.lua`, `Receiver.lua`) into `src/main/adapters/network/` and wrap TRP3 hooks into `TRP3Adapter.lua`.

**Why this priority**: P2. Isolating network serialization and add-on hook overrides inside technical adapters prevents external network and add-on changes from breaking core domain modules.

**Independent Test**: Tested by simulating addon message receipt via `NetworkAdapter` and mocking TRP3 profile calls within `TRP3Adapter` without loading `src/Communication/`.

**Acceptance Scenarios**:

1. **Given** incoming P2P addon messages, **When** received, **Then** `NetworkAdapter` deserializes payloads and passes them to internal event handlers.
2. **Given** TRP3 profile queries, **When** executed, **Then** `TRP3Adapter` defensively queries TRP3 globals or returns fallback defaults.

---

### User Story 8 - Static Data Tables & Locales Integration (Priority: P2)

As a domain developer, static roleplay data tables in `src/Data/` (`LevelTable.lua`, `Races.lua`, `AttributesAndTalents.lua`) must be injected into domain calculators, and `src/Locales/` must be relocated to `src/main/adapters/locales/`.

**Why this priority**: P2. Removing static data table mutations from the global `GAC` namespace ensures domain calculators operate on clean, immutable configuration data.

**Independent Test**: Verified by querying level stats and localized strings without referencing global `GAC.levelsTable` directly.

**Acceptance Scenarios**:

1. **Given** level scaling lookups, **When** queried by `CharacterCalculator`, **Then** data is fetched from encapsulated domain configuration tables.
2. **Given** localized interface strings, **When** evaluated, **Then** strings resolve through `src/main/adapters/locales/`.

---

### User Story 9 - Legacy Monolithic Directory & Manifest Cleanup (Priority: P1)

As a maintainer, I need to delete all legacy directories under `src/` (`Communication/`, `Constants/`, `Enums/`, `Events/`, `Frames/`, `Hooks/`, `Locales/`, `Models/`, `Services/`, `Utils/`) and remove `GranAddonDeLasCosas.xml` from `GAC_DEV.toc` so that `src/` contains 100% pure Hexagonal and Micro-Frontend structures.

**Why this priority**: P1 (Critical Cleanup). Eliminating legacy directories prevents duplicate code paths, eliminates context drift, and enforces strict architecture compliance.

**Independent Test**: Can be tested by running a directory inspection across `src/` to confirm only `main/`, `ui/`, and `src.xml` remain, followed by booting the add-on via `GAC_DEV.toc`.

**Acceptance Scenarios**:

1. **Given** the add-on package build tree, **When** inspecting `src/`, **Then** only `main/`, `ui/`, and `src.xml` exist.
2. **Given** `GAC_DEV.toc`, **When** evaluated by the game engine, **Then** loading proceeds strictly through `src\src.xml` and `index.lua` without calling `GranAddonDeLasCosas.xml`.

---

### Edge Cases

- **Partial Legacy Frame Calls**: If an external add-on or macro invokes legacy functions like `GAC.Services.CharacterService:GetPlayerCharacter()`, `index.lua` must maintain lightweight backward-compatible aliases pointing to `src/main/domain/` instances to prevent runtime nil errors.
- **Unmapped Micro-Frontend Channels**: If a UI micro-frontend publishes an event before backend adapters register subscribers, `LocalIPCAdapter` must swallow the event silently.
- **TRP3 Unload Mid-Session**: If Total RP 3 is disabled during a session, `TRP3Adapter.lua` must defensively return unit defaults without throwing nil table access exceptions.

---

## Requirements *(mandatory)*

### Functional Requirements

* **FR-001**: The system MUST encapsulate all domain entity instantiation within `src/main/domain/` factories (`Character.create()`, `Item.create()`, `Armor.create()`, `Weapon.create()`).
* **FR-002**: Mathematical stat calculations MUST be performed exclusively by `CharacterCalculator.lua`.
* **FR-003**: All UI feature modules under `src/ui/` MUST communicate with backend domain logic strictly via `LocalIPCAdapter` channels.
* **FR-004**: No UI micro-frontend (`src/ui/[feature]/`) MAY directly import or execute scripts from another sibling UI micro-frontend.
* **FR-005**: All UI frames MUST inherit shared visual panel templates from `src/ui/shared/Templates.xml`.
* **FR-006**: P2P network serialization and add-on communication MUST be encapsulated within `src/main/adapters/network/NetworkAdapter.lua`.
* **FR-007**: Defensive Total RP 3 integration MUST be isolated within `src/main/adapters/TRP3Adapter.lua`.
* **FR-008**: The active runtime directory `src/` MUST contain ONLY `main/`, `ui/`, and `src.xml`.
* **FR-009**: The primary manifest entry point in `GAC_DEV.toc` MUST load strictly `src\src.xml` and `index.lua`.
* **FR-010**: All Lua files strictly enforce standard `local` variable scoping to eliminate global scope pollution.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

* **SC-001**: 0 legacy subdirectories remaining in `src/` outside of `main/`, `ui/`, and `src.xml`.
* **SC-002**: 100% of UI feature views in `src/ui/` route data dispatches through `LocalIPCAdapter` without direct backend class coupling or cross-feature script imports.
* **SC-003**: 100% domain purity in `src/main/domain/` with zero WoW engine API calls (`UnitName`, `CreateFrame`, `RegisterEvent`).
* **SC-004**: 0 references to legacy `GranAddonDeLasCosas.xml` remaining in `GAC_DEV.toc`.
* **SC-005**: 100% pass rate on automated Lua domain unit tests for `Character.create()` and `CharacterCalculator.lua`.

---

## Assumptions

* **Target Environment**: World of Warcraft Retail Lua 5.1 environment utilizing standard `.toc` and cascading `.xml` manifests.
* **Backward Compatibility**: Global `GAC` table aliases are maintained in `index.lua` for legacy macro and external add-on compatibility.
* **Addon Isolation**: Third-party add-ons (TRP3) are optional dependencies with defensive fallback defaults.
