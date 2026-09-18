# Tasks: Critical Fixes & Infrastructure Setup

**Input**: Design documents from `/specs/001-critical-infrastructure-setup/`

**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, quickstart.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- Single World of Warcraft Add-on project: `src/`, root manifests at repository root `j:\Juegos\Epsilon927\Epsilon\_retail_\Interface\AddOns\GAC_DEV`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Verify manifest structure and entry points before modifications

- [x] T001 Audit existing manifest files and directory paths against `plan.md` in `j:\Juegos\Epsilon927\Epsilon\_retail_\Interface\AddOns\GAC_DEV`
- [x] T002 Inspect `src/index.lua` entry point and event registration structure

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Prepare core add-on namespace exposure prerequisites

- [x] T003 Verify local add-on table initialization in `src/index.lua`

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Root Manifest XML Ingestion (Priority: P1) 🎯 MVP

**Goal**: Fix root XML manifest declaration (`GranAddonDeLasCosas.xml`) to use `<Include>` semantics for submanifest loading.

**Independent Test**: Launch WoW client (Interface 90207) or execute `/reload` and verify `GranAddonDeLasCosas.xml` loads `src/GAC.xml` without XML parser errors.

### Implementation for User Story 1

- [x] T004 [US1] Change line 3 in `GranAddonDeLasCosas.xml` from `<Script file="src\GAC.xml"/>` to `<Include file="src\GAC.xml"/>`

**Checkpoint**: At this point, `GranAddonDeLasCosas.xml` correctly includes `src/GAC.xml` as a valid XML submanifest.

---

## Phase 4: User Story 2 - Submanifest Script Source Alignment (Priority: P1)

**Goal**: Fix all submanifest XML files to use `<Script file="*.lua"/>` for Lua files and `<Include file="*.xml"/>` for XML files.

**Independent Test**: Inspect client load frame logs and verify all submanifests load Lua sources cleanly without XML schema errors.

### Implementation for User Story 2

- [x] T005 [P] [US2] Update `src/Communication/Communication.xml` to load Lua files (`TRP3Bridge.lua`, `Transmitter.lua`, `Receiver.lua`, `GroupEvents.lua`) with `<Script>` tags
- [x] T006 [P] [US2] Update `src/Data/Data.xml` to load Lua files (`AttributesAndTalents.lua`, `LevelTable.lua`, `WorgenTable.lua`, `Armor.lua`, `Weapons.lua`, `Shield.lua`) with `<Script>` tags
- [x] T007 [P] [US2] Update `src/Utils/Utils.xml` to load Lua files (`VersionBridge.lua`, `Helpers.lua`) with `<Script>` tags
- [x] T008 [P] [US2] Update `src/Frames/UI/UI.xml` to load Lua files (`ExpBar.lua`, `PlayerPlate.lua`, `TargetPlate.lua`, `RaidPlate.lua`) with `<Script>` tags
- [x] T009 [P] [US2] Update `src/Frames/MainMenu/Screens/Screens.xml` to load Lua files (`CharSheetContent.lua`, `InventoryContent.lua`, `ExperienceConfigurator.lua`) with `<Script>` tags
- [x] T010 [P] [US2] Update `src/Frames/MainMenu/Components/Components.xml` to load Lua files (`FontString.lua`, `InfoBox.lua`, `StatInput.lua`, `SubTabButton.lua`, `Card.lua`) with `<Script>` tags
- [x] T011 [P] [US2] Update `src/Frames/QuickButtonsMenu/Components/Components.xml` to load Lua files (`QuickButton.lua`, `Tooltip.lua`, `ContextMenus.lua`) with `<Script>` tags
- [x] T012 [P] [US2] Update `src/Frames/InitiativeOrders/Components/Components.xml` to load Lua files (`InitiativeRow.lua`, `IconButton.lua`) with `<Script>` tags
- [x] T013 [P] [US2] Audit and fix remaining submanifest files (`src/Frames/Frames.xml`, `src/Frames/MainMenu/MainMenu.xml`, `src/Frames/InspectionMenu/InspectionMenu.xml`) for XML schema tag compliance

**Checkpoint**: At this point, 100% of XML submanifest tags align with WoW UI XML schema specifications.

---

## Phase 5: User Story 3 - Global Namespace Exposure (Priority: P1)

**Goal**: Expose root add-on table to `_G.GAC` and `_G.GranAddonDeLasCosas` in `src/index.lua`.

**Independent Test**: Execute `/run print(GAC.name)` and `/run print(GranAddonDeLasCosas.version)` in chat console to verify global availability.

### Implementation for User Story 3

- [x] T014 [US3] Update `src/index.lua` to bind `_G.GAC = GAC` and `_G.GranAddonDeLasCosas = GAC` at file scope

**Checkpoint**: All user stories are now independently functional and testable.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: End-to-end verification and documentation

- [x] T015 [P] Run validation scenarios from `specs/001-critical-infrastructure-setup/quickstart.md`
- [x] T016 Update task progress and mark completed tasks in `audit.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - starts immediately.
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS user stories.
- **User Stories (Phase 3+)**: Depend on Foundational phase completion.
  - User Story 1 (P1), User Story 2 (P1), User Story 3 (P1) can proceed sequentially or in parallel.
- **Polish (Phase 6)**: Depends on all user stories completing.

### Parallel Opportunities

- Tasks T005 through T012 in Phase 4 (User Story 2) touch independent XML manifest files and can run in parallel.
- Task T015 (Quickstart verification) can run in parallel once T004, T013, and T014 complete.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1 (T004)
4. **STOP and VALIDATE**: Verify root manifest inclusion in client.

### Full Incremental Delivery

1. Complete Setup + Foundational
2. Add User Story 1 (T004) → Validate root manifest
3. Add User Story 2 (T005-T013) → Validate submanifest tags
4. Add User Story 3 (T014) → Validate global namespace in chat console
5. Complete Polish (T015-T016) → Done!
