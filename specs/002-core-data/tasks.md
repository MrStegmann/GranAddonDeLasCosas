---
description: "Task list for Core Hardcoded Domain Data Layer implementation"
---

# Tasks: Core Hardcoded Domain Data Layer

**Input**: Design documents from `specs/002-core-data/` (`SPEC.md`, `plan.md`)

**Prerequisites**: plan.md (required), SPEC.md (required for user stories)

**Organization**: Tasks are grouped by phase and user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3, US4)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Directory structure and cascading manifest initialization

- [x] T001 Create directory structure for domain database (`src/main/domain/database/`) and metadata ports (`src/main/ports/metadata/`)
- [x] T002 Create initial `database.xml` manifest in `src/main/domain/database/` and wire into `src/main/domain/domain.xml`
- [x] T003 [P] Create initial `metadataPorts.xml` manifest in `src/main/ports/metadata/` and wire into `src/main/ports/ports.xml`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core load order and immutability primitives

- [x] T004 Verify master load order in `src/src.xml` (ports before domain database)
- [x] T005 [P] Ensure read-only table return helper logic is ready for port implementations

---

## Phase 3: User Story 1 - Character Creation Data Fulfillment (Priority: P1) 🎯 MVP

**Goal**: Transpile core character creation datasets (races, levels, traits) into isolated Lua database tables and ports.

**Independent Test**: Initiate character creation reference lookup via ports for races, level curves, and positive/negative traits.

- [x] T006 [P] [US1] Transpile `races.json` to isolated `src/main/domain/database/RaceDatabase.lua`
- [x] T007 [P] [US1] Create read-only port endpoint `src/main/ports/metadata/RacePort.lua` for `RaceDatabase` with `GetAll()` and `GetById(id)`
- [x] T008 [P] [US1] Transpile `levels.json` to isolated `src/main/domain/database/LevelDatabase.lua`
- [x] T009 [P] [US1] Create read-only port endpoint `src/main/ports/metadata/LevelPort.lua` for `LevelDatabase` with `GetAll()` and `GetById(id)`
- [x] T010 [P] [US1] Transpile `traits-types.ts` (`PositiveTraits` & `NegativeTraits`) to `src/main/domain/database/TraitsDatabase.lua`, preserving all inline comments
- [x] T011 [P] [US1] Create read-only port endpoint `src/main/ports/metadata/TraitsPort.lua` for `TraitsDatabase` with `GetAll()`, `GetPositiveTraitById(id)`, and `GetNegativeTraitById(id)`
- [x] T012 [US1] Register `RaceDatabase.lua`, `LevelDatabase.lua`, `TraitsDatabase.lua` in `database.xml` and corresponding ports in `metadataPorts.xml`

**Checkpoint**: At this point, User Story 1 character creation data endpoints are fully functional and independently testable.

---

## Phase 4: User Story 2 - Accurate Character Inspection & Data Resolution (Priority: P1)

**Goal**: Transpile equipment and proficiency datasets (armor, weapons, shields) into isolated Lua database tables and ports for profile inspection resolution.

**Independent Test**: Query item metadata and armor combination rules via `ArmorPort`, `WeaponsPort`, and `ShieldPort`.

- [x] T013 [P] [US2] Transpile `armor-types.ts` (`ArmorList`, `ReinforcementList`) to isolated `src/main/domain/database/ArmorDatabase.lua`
- [x] T014 [P] [US2] Create read-only port endpoint `src/main/ports/metadata/ArmorPort.lua` for `ArmorDatabase` with `GetAll()` and `GetById(id)`
- [x] T015 [P] [US2] Transpile `weapons.json` to isolated `src/main/domain/database/WeaponsDatabase.lua`
- [x] T016 [P] [US2] Create read-only port endpoint `src/main/ports/metadata/WeaponsPort.lua` for `WeaponsDatabase` with `GetAll()` and `GetById(id)`
- [x] T017 [P] [US2] Transpile `shields.json` to isolated `src/main/domain/database/ShieldDatabase.lua`
- [x] T018 [P] [US2] Create read-only port endpoint `src/main/ports/metadata/ShieldPort.lua` for `ShieldDatabase` with `GetAll()` and `GetById(id)`
- [x] T019 [US2] Register `ArmorDatabase.lua`, `WeaponsDatabase.lua`, `ShieldDatabase.lua` in `database.xml` and corresponding ports in `metadataPorts.xml`

**Checkpoint**: User Story 1 and User Story 2 datasets are independently functional.

---

## Phase 5: User Story 3 - Mechanical Calculations & Combat Rule Engine (Priority: P1)

**Goal**: Transpile skills and spell school datasets (including empty tables) into isolated Lua database tables and ports for combat calculations.

**Independent Test**: Query skill thresholds and spell details via skill ports (`StrengthSkillsPort`, `DexSkillsPort`, `ConstitutionSkillsPort`) and spell school ports (`ArcanePort`, `ElementalPort`, etc.).

- [x] T020 [P] [US3] Transpile `strength_skills.json` to `src/main/domain/database/StrengthSkillsDatabase.lua`
- [x] T021 [P] [US3] Create port `src/main/ports/metadata/StrengthSkillsPort.lua` for `StrengthSkillsDatabase` with `GetAll()` and `GetById(id)`
- [x] T022 [P] [US3] Transpile `dex_skills.json` to `src/main/domain/database/DexSkillsDatabase.lua`
- [x] T023 [P] [US3] Create port `src/main/ports/metadata/DexSkillsPort.lua` for `DexSkillsDatabase` with `GetAll()` and `GetById(id)`
- [x] T024 [P] [US3] Transpile `constitution_skills.json` to `src/main/domain/database/ConstitutionSkillsDatabase.lua`
- [x] T025 [P] [US3] Create port `src/main/ports/metadata/ConstitutionSkillsPort.lua` for `ConstitutionSkillsDatabase` with `GetAll()` and `GetById(id)`
- [x] T026 [P] [US3] Transpile `arcane.json` to `src/main/domain/database/ArcaneDatabase.lua` and create `src/main/ports/metadata/ArcanePort.lua`
- [x] T027 [P] [US3] Transpile `elemental.json` to `src/main/domain/database/ElementalDatabase.lua` and create `src/main/ports/metadata/ElementalPort.lua`
- [x] T028 [P] [US3] Transpile `elune.json` to `src/main/domain/database/EluneDatabase.lua` and create `src/main/ports/metadata/ElunePort.lua`
- [x] T029 [P] [US3] Transpile `holy_light.json` to `src/main/domain/database/HolyLightDatabase.lua` and create `src/main/ports/metadata/HolyLightPort.lua`
- [x] T030 [P] [US3] Transpile `shadow.json` to `src/main/domain/database/ShadowDatabase.lua` and create `src/main/ports/metadata/ShadowPort.lua`
- [x] T031 [P] [US3] Transpile `worgenCurse.json` to `src/main/domain/database/WorgenCurseDatabase.lua` and create `src/main/ports/metadata/WorgenCursePort.lua`
- [x] T032 [P] [US3] Transpile empty `chi.json` to empty table `{}` in `src/main/domain/database/ChiDatabase.lua` and create `src/main/ports/metadata/ChiPort.lua`
- [x] T033 [P] [US3] Transpile empty `fel.json` to empty table `{}` in `src/main/domain/database/FelDatabase.lua` and create `src/main/ports/metadata/FelPort.lua`
- [x] T034 [P] [US3] Transpile empty `nature.json` to empty table `{}` in `src/main/domain/database/NatureDatabase.lua` and create `src/main/ports/metadata/NaturePort.lua`
- [x] T035 [P] [US3] Transpile empty `necromance.json` to empty table `{}` in `src/main/domain/database/NecromanceDatabase.lua` and create `src/main/ports/metadata/NecromancePort.lua`
- [x] T036 [US3] Register all skills and spells database files in `database.xml` and corresponding ports in `metadataPorts.xml`

**Checkpoint**: All 19 isolated data sources are instantiated and queryable via their dedicated ports.

---

## Phase 6: User Story 4 - Endpoint Probing & Table Parity Verification (Priority: P2)

**Goal**: Verify 100% data parity and structural matching for all 19 ports and database tables.

**Independent Test**: Run Lua unit test suite probing every `GetAll()` and `GetById(id)` port function against source domain tables.

- [x] T037 [P] [US4] Create unit probing tests for core data ports (`RacePort`, `LevelPort`, `TraitsPort`)
- [x] T038 [P] [US4] Create unit probing tests for equipment ports (`ArmorPort`, `WeaponsPort`, `ShieldPort`)
- [x] T039 [P] [US4] Create unit probing tests for skills ports (`StrengthSkillsPort`, `DexSkillsPort`, `ConstitutionSkillsPort`)
- [x] T040 [P] [US4] Create unit probing tests for spell school ports (`ArcanePort`, `ElementalPort`, `ElunePort`, `HolyLightPort`, `ShadowPort`, `WorgenCursePort`)
- [x] T041 [P] [US4] Create unit probing tests for empty dataset ports (`ChiPort`, `FelPort`, `NaturePort`, `NecromancePort`) verifying empty table `{}` returns
- [x] T042 [US4] Execute full probing test suite and assert 100% structural equality across all 19 endpoints

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Manifest validation, comment verification, and memory sync

- [x] T043 Update `src/main/domain/database/database.xml` and `src/main/ports/metadata/metadataPorts.xml` load order
- [x] T044 Verify complete comment retention in `TraitsDatabase.lua`
- [x] T045 Update `memory-bank/progress.md` and `memory-bank/activeContext.md` to log feature completion

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories can proceed sequentially (P1 → P2) or in parallel
- **Polish (Phase 7)**: Depends on all user stories being complete

### Within Each User Story

- Isolated database tables before corresponding metadata ports
- Individual database tables and ports can be built in parallel (`[P]`)
- Manifest registration after table and port file creation
- Story complete before proceeding to probing verification
