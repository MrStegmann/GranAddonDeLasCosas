# Tasks: Flux UI Architecture & SOLID Refactoring

**Input**: Design documents from `/specs/002-flux-ui-architecture/`

**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, quickstart.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- Single World of Warcraft Add-on project: `src/Core/`, `src/Frames/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Core directory initialization

- [x] T001 [P] Create `src/Core/` directory per implementation plan

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core Flux enumerations and manifest integration

- [x] T002 [P] Create `src/Core/Actions.lua` defining action type enumerations (`UPDATE_PROGRESS`, `ADD_EXPERIENCE`, `MODIFY_HEALTH`, `MODIFY_SHIELD`, `UPDATE_STORY`)
- [x] T003 Create `src/Core/Core.xml` manifest declaring `Actions.lua`, `Dispatcher.lua`, and `Store.lua` with `<Script file="*.lua"/>` tags
- [x] T004 Include `src/Core/Core.xml` in `src/GAC.xml` prior to UI manifest inclusions

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Core Flux Infrastructure (Priority: P1) 🎯 MVP

**Goal**: Implement `Dispatcher.lua` and `Store.lua` for unidirectional action routing and state management.

**Independent Test**: Dispatch test actions via console and verify store updates state and notifies subscriber callbacks.

### Implementation for User Story 1

- [x] T005 [P] [US1] Implement `src/Core/Dispatcher.lua` with action handler registration and `GAC:SafeCall`-wrapped dispatch method
- [x] T006 [P] [US1] Implement `src/Core/Store.lua` managing `GranAddonDeLasCosasCharDB` state, action reducers, and `GAC:SafeCall`-wrapped subscriber notifications
- [x] T007 [US1] Initialize `GAC.Dispatcher` and `GAC.Store` in `src/index.lua` `ADDON_LOADED` event handler

**Checkpoint**: At this point, `GAC.Dispatcher` and `GAC.Store` are fully functional and independently testable via console dispatches.

---

## Phase 4: User Story 2 - Action Dispatching from UI Screens (Priority: P1)

**Goal**: Refactor UI screen handlers to dispatch actions (`GAC.Actions.*`) instead of performing inline state mutations.

**Independent Test**: Trigger "Save Progression" or "Add Experience" in UI and verify action dispatches to store.

### Implementation for User Story 2

- [x] T008 [P] [US2] Refactor `CharSheetContent.lua` save progression button handler to dispatch `GAC.Actions.UPDATE_PROGRESS`
- [x] T009 [P] [US2] Refactor `ExperienceConfigurator.lua` experience input handler to dispatch `GAC.Actions.ADD_EXPERIENCE`
- [x] T010 [P] [US2] Refactor `QuickButtonsMenu/index.lua` health/shield modification buttons to dispatch `GAC.Actions.MODIFY_HEALTH` and `GAC.Actions.MODIFY_SHIELD`

**Checkpoint**: UI screen button handlers no longer mutate persistent saved variables inline.

---

## Phase 5: User Story 3 - Reactive View Re-Rendering (Priority: P1)

**Goal**: Bind UI presentation frames to store state change notifications so views automatically re-render.

**Independent Test**: Modify store state via action dispatch and verify UI elements instantly update.

### Implementation for User Story 3

- [x] T011 [P] [US3] Subscribe `CharSheetContent.lua` summary views to `GAC.Store` updates for reactive text rendering
- [x] T012 [P] [US3] Subscribe `ExperienceConfigurator.lua` XP bars and level labels to `GAC.Store` updates
- [x] T013 [P] [US3] Subscribe `PlayerPlate.lua` health/shield bars and text to `GAC.Store` updates

**Checkpoint**: Unidirectional Flux loop (`Action` → `Dispatcher` → `Store` → `View`) is complete and reactive across all primary screens.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: End-to-end verification and documentation

- [x] T014 [P] Run validation scenarios from `specs/002-flux-ui-architecture/quickstart.md`
- [x] T015 Update task progress and mark completed tasks in `audit.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - starts immediately.
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS user stories.
- **User Stories (Phase 3+)**: Depend on Foundational phase completion.
  - User Story 1 (P1) → User Story 2 (P1) → User Story 3 (P1).
- **Polish (Phase 6)**: Depends on all user stories completing.

### Parallel Opportunities

- Tasks T005 and T006 in Phase 3 (Dispatcher & Store) can run in parallel.
- Tasks T008, T009, and T010 in Phase 4 (UI Screen action dispatches) can run in parallel.
- Tasks T011, T012, and T013 in Phase 5 (Reactive view subscriptions) can run in parallel.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1 (T005-T007)
4. **STOP and VALIDATE**: Test console action dispatching and store updates.

### Full Incremental Delivery

1. Complete Setup + Foundational → Core manifest ready
2. Add User Story 1 (T005-T007) → Validate Dispatcher & Store
3. Add User Story 2 (T008-T010) → Validate action dispatches from UI buttons
4. Add User Story 3 (T011-T013) → Validate reactive view re-rendering
5. Complete Polish (T014-T015) → Done!
