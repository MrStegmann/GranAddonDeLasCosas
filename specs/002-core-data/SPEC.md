# Feature Specification: Core Hardcoded Domain Data Layer

**Feature Branch**: `002-core-data`

**Created**: 2026-08-05

**Status**: APPROVED

**Input**: User description: "Create immutable hardcoded data as the core of the addon using all JSON files in specs/002-core-data/*.json and TypeScript files. Transpile all objects and lists into completely isolated, independent read-only Lua tables in src/main/domain/database without any grouping. Expose each table exclusively via individual src/main/ports endpoint functions with get-all and get-by-id queries. Retain trait comments and enforce structural definition of truth."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Character Creation Data Fulfillment (Priority: P1)

As a player creating a new tabletop character within the addon, I need the character creation workflow to draw immediately from hardcoded, immutable core reference data (races, levels, starting skills, armor/weapon proficiencies, positive/negative traits) so that character setup is complete, accurate, and deterministic.

**Why this priority**: Character creation cannot function or exist without this core dataset. It forms the foundational baseline for all character state initializations.

**Independent Test**: Can be independently verified by initiating a character creation instance and asserting that racial traits, skill costs, level progression curves, and positive/negative traits match the exact values defined in the core data tables.

**Acceptance Scenarios**:

1. **Given** a user opening the character creation interface, **When** selecting a race (e.g., Human or Orc from `races.json`), **Then** the character model receives the exact racial base attributes, traits, and modifiers defined in `RaceDatabase`.
2. **Given** a character selecting starting positive or negative traits, **When** browsing available traits, **Then** the selection pool displays the complete list of `PositiveTraits` and `NegativeTraits` from `TraitsDatabase` including all level-specific effects (Level 1-3).

---

### User Story 2 - Accurate Character Inspection & Data Resolution (Priority: P1)

As a player or Game Master inspecting another character's profile or sheet, I need the addon to resolve item, trait, skill, and spell identifiers against the core immutable database so that inspection panels show accurate names, descriptions, mechanics, and metadata.

**Why this priority**: Inspection options cannot provide accurate or meaningful results if reference data is missing, corrupted, or altered.

**Independent Test**: Can be tested independently by passing a serialized character sheet payload containing trait IDs, weapon types, and spell IDs to the inspection service and verifying that all descriptors match the immutable domain database exactly.

**Acceptance Scenarios**:

1. **Given** an inspected player sheet with trait ID `"agileAmbidextrous"`, **When** the inspection panel renders the trait tooltip, **Then** it queries the metadata port and returns the exact description and effects defined in `TraitsDatabase`.
2. **Given** an inspected player equipping a plate chest piece, **When** inspecting armor details, **Then** the system retrieves physical reduction, magical reduction, durability, requirements, and penalties directly from `ArmorDatabase`.

---

### User Story 3 - Mechanical Calculations & Combat Rule Engine (Priority: P1)

As the tabletop rule engine processing combat actions, dice rolls, or armor mitigation, I need to consult the immutable core database tables via isolated port endpoints to compute deterministic values (e.g., armor reduction, damage dice, skill check thresholds).

**Why this priority**: Gameplay calculations (e.g., armor mitigation, weapon damage, spell effects) rely entirely on static rules and base metrics defined in the core data layer.

**Independent Test**: Can be tested independently by querying armor mitigation for a given armor/shield combination via `ArmorPort` and `ShieldPort` and validating the calculated reduction against the domain formulas.

**Acceptance Scenarios**:

1. **Given** a character equipped with `leather` armor and a `heavyShield`, **When** armor mitigation is calculated, **Then** the calculation engine fetches base values via `ArmorPort:GetById("leather")` and `ShieldPort:GetById("heavyShield")` without mutating the reference tables.
2. **Given** a player executing a skill check from `dex_skills.json`, **When** the dice engine evaluates success thresholds, **Then** it fetches skill metadata via `DexSkillsPort:GetById(skill_id)` to resolve formulas correctly.

---

### User Story 4 - Endpoint Probing & Table Parity Verification (Priority: P2)

As a developer or automated test suite, I need every isolated port endpoint (`src/main/ports/metadata/*Port.lua`) to be probed by retrieving the full data table or specific items by key, ensuring that the returned table structure matches the Lua database table line-for-line without structural drift.

**Why this priority**: Guarantees that data access contracts remain intact and that endpoint implementations are 100% complete and verified before feature completion.

**Independent Test**: Can be verified by running unit probing tests against every port function to assert full structural equality between source Lua database tables and port query return payloads.

**Acceptance Scenarios**:

1. **Given** a call to `RacePort:GetAll()`, **When** comparing the returned table to `RaceDatabase`, **Then** the structure, keys, and values are identical.
2. **Given** a call to `TraitsPort:GetPositiveTraitById("bully")`, **When** the entry is returned, **Then** it contains all fields (`id`, `name`, `description`, `type`, `level1`, `level2`, `level3`) matching the source table.

---

### Edge Cases

- **Missing or Invalid Key Query**: When a port endpoint is queried with a non-existent ID (e.g., `WeaponsPort:GetById("invalid_id")`), the endpoint MUST safely return `nil` without throwing Lua execution errors or crashing.
- **Runtime Mutation Attempts**: If any caller attempts to alter a returned table or write to a database endpoint, the underlying domain table MUST remain unaffected (tables are read-only / immutable).
- **Inline Trait Comments Retention**: `PositiveTraits` and `NegativeTraits` transpiled from `traits-types.ts` MUST retain all inline technical comments (e.g., dual wield penalty handling notes, extra action rules, experience gain triggers) as Lua documentation comments above each respective trait entry.
- **Empty Dataset Transpilation**: Source JSON files that contain empty objects/arrays (`fel.json`, `chi.json`, `nature.json`, `necromance.json`) MUST still produce valid, isolated Lua database files (`FelDatabase.lua`, `ChiDatabase.lua`, `NatureDatabase.lua`, `NecromanceDatabase.lua`) returning empty tables `{}` and corresponding port interfaces (`FelPort.lua`, `ChiPort.lua`, `NaturePort.lua`, `NecromancePort.lua`) to guarantee complete architecture and port contract parity.
- **Unloaded or Missing Data File**: If any core database file fails to load during addon initialization, the addon must fail fast with a clear diagnostic log rather than silently proceeding with missing data.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: **Single Source of Truth**: The object and list structures defined in `specs/002-core-data/*.json` and TypeScript files (`armor-types.ts`, `traits-types.ts`) MUST be strictly respected as the authoritative definition of truth and MUST NOT be altered or structurally modified.
- **FR-002**: **Complete Lua Transpilation & Migration**: ALL data from every JSON file (`arcane.json`, `chi.json`, `constitution_skills.json`, `dex_skills.json`, `elemental.json`, `elune.json`, `fel.json`, `holy_light.json`, `levels.json`, `nature.json`, `necromance.json`, `races.json`, `shadow.json`, `shields.json`, `strength_skills.json`, `weapons.json`, `worgenCurse.json`) and TypeScript file (`armor-types.ts`, `traits-types.ts`) MUST be migrated and transpiled into pure Lua 5.1 database tables.
- **FR-003**: **Strict Table Isolation (No Grouping)**: EVERY source data file MUST map 1:1 to its own dedicated, standalone Lua database table file inside `src/main/domain/database/`. Tables MUST NOT be grouped, combined, or merged into shared database files.
- **FR-004**: **Isolated Read-Only Access via Ports**: Every domain database table MUST be completely read-only and MUST have a corresponding isolated port file in `src/main/ports/metadata/`. Direct access to database tables by external callers or UI features is strictly forbidden.
- **FR-005**: **Isolated Endpoint Query Functions**: Every metadata port in `src/main/ports/metadata/` MUST provide dedicated functions to:
  1. Retrieve the entire standalone data table (`GetAll()`).
  2. Retrieve a specific data entry by its unique identifier/key (`GetById(id)`).
- **FR-006**: **Trait Comments Preservation**: The transpilation of `PositiveTraits` and `NegativeTraits` from `traits-types.ts` MUST preserve all original TypeScript inline comments as Lua comments directly associated with each trait table entry.
- **FR-007**: **Endpoint Probing & Verification**: Every individual port endpoint MUST be thoroughly probed and verified by asserting that data returned by port functions matches the exact structure and content constructed in the Lua database tables. A port endpoint is considered unfinished until verified.
- **FR-008**: **Zero WoW API Leakage**: All database files in `src/main/domain/database/` and port interfaces in `src/main/ports/` MUST consist of pure Lua 5.1 code with zero references to World of Warcraft client APIs (`CreateFrame`, `RegisterEvent`, `C_ChatInfo`, etc.).
- **FR-009**: **Empty Table Support**: Empty source JSON files (`fel.json`, `chi.json`, `nature.json`, `necromance.json`) MUST be explicitly instantiated as isolated Lua database tables (e.g. `FelDatabase.lua`, `ChiDatabase.lua`, `NatureDatabase.lua`, `NecromanceDatabase.lua`) returning valid empty tables `{}` and exposed through individual ports to maintain 1:1 structural parity.

### Key Entities (1:1 Isolated File Mapping)

Each core data file is strictly transpiled into its own isolated Lua database table and exposed via its own dedicated port:

1. **ArmorDatabase** (`src/main/domain/database/ArmorDatabase.lua`) & **ArmorPort** (`src/main/ports/metadata/ArmorPort.lua`): Transpiled from `armor-types.ts`.
2. **TraitsDatabase** (`src/main/domain/database/TraitsDatabase.lua`) & **TraitsPort** (`src/main/ports/metadata/TraitsPort.lua`): Transpiled from `traits-types.ts`. Preserves all inline comments.
3. **LevelDatabase** (`src/main/domain/database/LevelDatabase.lua`) & **LevelPort** (`src/main/ports/metadata/LevelPort.lua`): Transpiled from `levels.json`.
4. **RaceDatabase** (`src/main/domain/database/RaceDatabase.lua`) & **RacePort** (`src/main/ports/metadata/RacePort.lua`): Transpiled from `races.json`.
5. **ShieldDatabase** (`src/main/domain/database/ShieldDatabase.lua`) & **ShieldPort** (`src/main/ports/metadata/ShieldPort.lua`): Transpiled from `shields.json`.
6. **WeaponsDatabase** (`src/main/domain/database/WeaponsDatabase.lua`) & **WeaponsPort** (`src/main/ports/metadata/WeaponsPort.lua`): Transpiled from `weapons.json`.
7. **StrengthSkillsDatabase** (`src/main/domain/database/StrengthSkillsDatabase.lua`) & **StrengthSkillsPort** (`src/main/ports/metadata/StrengthSkillsPort.lua`): Transpiled from `strength_skills.json`.
8. **DexSkillsDatabase** (`src/main/domain/database/DexSkillsDatabase.lua`) & **DexSkillsPort** (`src/main/ports/metadata/DexSkillsPort.lua`): Transpiled from `dex_skills.json`.
9. **ConstitutionSkillsDatabase** (`src/main/domain/database/ConstitutionSkillsDatabase.lua`) & **ConstitutionSkillsPort** (`src/main/ports/metadata/ConstitutionSkillsPort.lua`): Transpiled from `constitution_skills.json`.
10. **ArcaneDatabase** (`src/main/domain/database/ArcaneDatabase.lua`) & **ArcanePort** (`src/main/ports/metadata/ArcanePort.lua`): Transpiled from `arcane.json`.
11. **ChiDatabase** (`src/main/domain/database/ChiDatabase.lua`) & **ChiPort** (`src/main/ports/metadata/ChiPort.lua`): Transpiled from `chi.json` (Empty table `{}`).
12. **ElementalDatabase** (`src/main/domain/database/ElementalDatabase.lua`) & **ElementalPort** (`src/main/ports/metadata/ElementalPort.lua`): Transpiled from `elemental.json`.
13. **EluneDatabase** (`src/main/domain/database/EluneDatabase.lua`) & **ElunePort** (`src/main/ports/metadata/ElunePort.lua`): Transpiled from `elune.json`.
14. **FelDatabase** (`src/main/domain/database/FelDatabase.lua`) & **FelPort** (`src/main/ports/metadata/FelPort.lua`): Transpiled from `fel.json` (Empty table `{}`).
15. **HolyLightDatabase** (`src/main/domain/database/HolyLightDatabase.lua`) & **HolyLightPort** (`src/main/ports/metadata/HolyLightPort.lua`): Transpiled from `holy_light.json`.
16. **NatureDatabase** (`src/main/domain/database/NatureDatabase.lua`) & **NaturePort** (`src/main/ports/metadata/NaturePort.lua`): Transpiled from `nature.json` (Empty table `{}`).
17. **NecromanceDatabase** (`src/main/domain/database/NecromanceDatabase.lua`) & **NecromancePort** (`src/main/ports/metadata/NecromancePort.lua`): Transpiled from `necromance.json` (Empty table `{}`).
18. **ShadowDatabase** (`src/main/domain/database/ShadowDatabase.lua`) & **ShadowPort** (`src/main/ports/metadata/ShadowPort.lua`): Transpiled from `shadow.json`.
19. **WorgenCurseDatabase** (`src/main/domain/database/WorgenCurseDatabase.lua`) & **WorgenCursePort** (`src/main/ports/metadata/WorgenCursePort.lua`): Transpiled from `worgenCurse.json`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: **100% Data Parity**: All 19 JSON/TS core data sources are fully represented in individual, isolated files under `src/main/domain/database/` (including empty tables for empty JSON files) with 0 missing fields or altered property names.
- **SC-002**: **100% Endpoint Verification**: 100% of individual port query endpoints (`GetAll` and `GetById`) across all 19 ports in `src/main/ports/metadata/` are probed and produce return tables matching their respective source database tables exactly.
- **SC-003**: **Zero Domain Taint**: 0 Lua database files in `src/main/domain/database/` invoke WoW Client APIs or mutate global states.
- **SC-004**: **Complete Comment Retention**: All technical comments present in `traits-types.ts` for `PositiveTraits` and `NegativeTraits` are verified to exist as Lua comments in `TraitsDatabase.lua`.
- **SC-005**: **Read-Only Safety**: Query calls to port endpoints return independent or protected data references, preventing accidental runtime mutations of core database state.

## Assumptions

- Core reference data in `specs/002-core-data/` is strictly immutable during runtime and never changes during gameplay.
- Data structures defined in TypeScript (`.ts`) and JSON (`.json`) files within `specs/002-core-data/` are the authoritative definition of truth.
- Access to core data from outside `src/main/domain/` MUST always pass through abstract interfaces in `src/main/ports/`.
- Endpoint probing tests will be executed within the Lua test runner environment to confirm table matching before declaring completion.



