# Tasks: Full Localization & Code Cleanup

**Input**: Design documents from `/specs/004-full-localization-cleanup/`

**Prerequisites**: [plan.md](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/specs/004-full-localization-cleanup/plan.md), [spec.md](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/specs/004-full-localization-cleanup/spec.md), [research.md](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/specs/004-full-localization-cleanup/research.md), [data-model.md](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/specs/004-full-localization-cleanup/data-model.md), [quickstart.md](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/specs/004-full-localization-cleanup/quickstart.md)

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Verify core localization table structure and translation resolver function

- [x] T001 Audit `GAC.Locales` table and `GAC:_("KEY")` resolver helper in `src/Locales/ES_es.lua`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Ensure submanifest initialization loads localization files before UI screens

- [x] T002 Verify `src/Locales/Locales.xml` submanifest script inclusion order

**Checkpoint**: Foundation ready - locale dictionary population can begin.

---

## Phase 3: User Story 1 - Centralized Spanish Locales Dictionary (Priority: P1) 🎯 MVP

**Goal**: Extract static UI string literals from primary UI view modules into `src/Locales/ES_es.lua`.

**Independent Test**: Inspect `src/Locales/ES_es.lua` dictionary keys and confirm all UI presentation strings are defined with corresponding Spanish translations.

### Implementation for User Story 1

- [x] T003 [P] [US1] Extract hardcoded UI strings from `CharSheetContent.lua` into `src/Locales/ES_es.lua`
- [x] T004 [P] [US1] Extract hardcoded UI strings from `ExperienceConfigurator.lua` into `src/Locales/ES_es.lua`
- [x] T005 [P] [US1] Extract hardcoded UI strings from `InventoryContent.lua` into `src/Locales/ES_es.lua`
- [x] T006 [P] [US1] Extract hardcoded UI strings from `QuickButtonsMenu/index.lua` into `src/Locales/ES_es.lua`

**Checkpoint**: At this point, all static UI strings for the four target views are fully registered in `src/Locales/ES_es.lua`.

---

## Phase 4: User Story 2 - UI Screen String Decoupling (Priority: P1)

**Goal**: Refactor UI screen code in `CharSheetContent.lua`, `ExperienceConfigurator.lua`, `InventoryContent.lua`, and `QuickButtonsMenu/index.lua` to replace raw string literals with dynamic `GAC:_("KEY")` calls.

**Independent Test**: Render UI frames in game and verify all headers, titles, buttons, inputs, warnings, and popups display localized text cleanly.

### Implementation for User Story 2

- [x] T007 [P] [US2] Refactor UI strings in `src/Frames/MainMenu/Screens/CharSheetContent.lua` to resolve via `GAC:_("KEY")`
- [x] T008 [P] [US2] Refactor UI strings in `src/Frames/MainMenu/Screens/ExperienceConfigurator.lua` to resolve via `GAC:_("KEY")`
- [x] T009 [P] [US2] Refactor UI strings in `src/Frames/MainMenu/Screens/InventoryContent.lua` to resolve via `GAC:_("KEY")`
- [x] T010 [P] [US2] Refactor UI strings in `src/Frames/QuickButtonsMenu/index.lua` to resolve via `GAC:_("KEY")`

**Checkpoint**: Primary UI screens are completely decoupled from hardcoded string literals.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: End-to-end verification and documentation updates

- [x] T011 Run quickstart validation scenarios from `specs/004-full-localization-cleanup/quickstart.md`
- [x] T012 Update task progress and mark completed tasks in `audit.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - starts immediately.
- **Foundational (Phase 2)**: Depends on Setup completion.
- **User Story 1 (Phase 3)**: Depends on Foundational phase completion.
- **User Story 2 (Phase 4)**: Depends on User Story 1 completion (locale keys must exist in `ES_es.lua`).
- **Polish (Phase 5)**: Depends on User Story 2 completion.

### Parallel Opportunities

- Tasks marked `[P]` within Phase 3 (T003, T004, T005, T006) can run in parallel.
- Tasks marked `[P]` within Phase 4 (T007, T008, T009, T010) can run in parallel across separate UI screen files.
