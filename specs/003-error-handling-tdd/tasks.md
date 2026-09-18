# Tasks: Error Handling & TDD Integration

**Input**: Design documents from `/specs/003-error-handling-tdd/`

**Prerequisites**: [plan.md](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/specs/003-error-handling-tdd/plan.md), [spec.md](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/specs/003-error-handling-tdd/spec.md), [research.md](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/specs/003-error-handling-tdd/research.md), [data-model.md](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/specs/003-error-handling-tdd/data-model.md), [quickstart.md](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/specs/003-error-handling-tdd/quickstart.md)

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project test directory setup and basic runner structure

- [x] T001 Create `tests/` directory and main test runner entry point in `tests/run_tests.lua`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Ensure central `GAC:SafeCall` helper operates reliably for all dependent wrappers

- [x] T002 Audit and refine `GAC:SafeCall` implementation in `src/Utils/Helpers.lua` to ensure safe variadic argument forwarding and exception logging

**Checkpoint**: Core safe calling helper is verified - user story implementation can begin.

---

## Phase 3: User Story 1 - Centralized Safe Function Calls & Error Isolation (Priority: P1) 🎯 MVP

**Goal**: Deprecate duplicate `safeCall` in `TRP3Bridge.lua` and enforce central `GAC:SafeCall` across TRP3 integration and network packet receiver.

**Independent Test**: Invoke TRP3 bridge methods and `Receiver.lua` packet handlers with missing APIs or corrupted payloads and verify errors are trapped safely without throwing unhandled Lua UI errors.

### Implementation for User Story 1

- [x] T003 [P] [US1] Remove duplicate local `safeCall` in `src/Communication/TRP3Bridge.lua` and replace internal invocations with `GAC:SafeCall`
- [x] T004 [P] [US1] Wrap external TRP3 and TRP3_Extended profile query methods in `src/Communication/TRP3Bridge.lua` with `GAC:SafeCall`
- [x] T005 [US1] Wrap incoming addon message decoding and handler dispatches in `src/Communication/Receiver.lua` with `GAC:SafeCall`

**Checkpoint**: At this point, all external bridge calls and incoming network message handlers are protected by central `GAC:SafeCall`.

---

## Phase 4: User Story 2 - Comprehensive RPG Math Unit Testing Suite (Priority: P1)

**Goal**: Build automated unit tests backing `LevelTable.lua`, `Armor.lua`, `Weapons.lua`, and `Helpers.lua`.

**Independent Test**: Execute `tests/run_tests.lua` (via Lua CLI or test runner) and verify 100% of assertions pass for level entries, equipment calculations, and utility helpers.

### Implementation for User Story 2

- [x] T006 [P] [US2] Create unit test module `tests/test_helpers.lua` testing string regex parsing, roll display formatting, and safe call mechanics
- [x] T007 [P] [US2] Create unit test module `tests/test_leveltable.lua` testing `LevelTable.lua` max health, attribute points, and exp requirements across categories
- [x] T008 [P] [US2] Create unit test module `tests/test_armor.lua` testing `Armor.lua` defense ratings and bonus attribute calculations
- [x] T009 [P] [US2] Create unit test module `tests/test_weapons.lua` testing `Weapons.lua` damage formulas and weapon stat calculations
- [x] T010 [US2] Integrate test modules (`test_helpers`, `test_leveltable`, `test_armor`, `test_weapons`) into `tests/run_tests.lua` suite runner

**Checkpoint**: RPG math calculations and core helper utilities have 100% automated test coverage.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: End-to-end verification and documentation updates

- [x] T011 Run quickstart validation scenarios from `specs/003-error-handling-tdd/quickstart.md`
- [x] T012 Update task progress and mark completed tasks in `audit.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - starts immediately.
- **Foundational (Phase 2)**: Depends on Setup completion.
- **User Stories (Phase 3 & Phase 4)**: Depend on Foundational phase completion. US1 and US2 can run independently.
- **Polish (Phase 5)**: Depends on completion of US1 and US2.

### Parallel Opportunities

- Tasks marked `[P]` within Phase 3 (T003, T004) can run in parallel.
- Test creation tasks marked `[P]` within Phase 4 (T006, T007, T008, T009) can run in parallel across separate files.
