# Feature Specification: Models as Definition & Schema of Truth

**Feature Branch**: `001-Types-Models`  
**Created**: 2026-08-05  
**Status**: COMPLETED  
**Input**: User requirement: "Update specs/001-Types-Models/SPEC.md to add each model as a User Story. This SPEC must construct the Models as a Schema of Truth, so any data MUST be parsed by the models. Character models will be used to storage by persistence method by World of Warcraft via SavedVariablesPerCharacter. When a player creates a character, will use the model. When the addon is loaded from the persistence data, must use this model. To validate, must pass correctly raw data and verify functionality, and badly raw data for validating its work properly rejecting incorrect data. We will replace models of src/main/domain/models to fetch the models created in specs/001-Types-Models/*.ts. DO NOT write any code."

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Character & CombatStats Model Schema of Truth (Priority: P1)

As the game domain engine and persistence adapter, I want the `Character` and `CombatStats` models to act as the authoritative Schema of Truth, parsing, validating, and sanitizing raw table data during character creation and when loading from `SavedVariablesPerCharacter` (`GAC_CharacterDB`), so that invalid, missing, or corrupted character properties are rejected or defaulted without crashing the addon.

**Why this priority**: The `Character` model encompasses identity, core RPG attributes, talent trees, race configuration, traits, equipment, and combat mechanics. It forms the backbone of player storage in `SavedVariablesPerCharacter`.

**Independent Test**: Can be tested independently by passing valid raw character tables and corrupted/malformed raw character tables to `Character.create(rawData)` or `Character.sanitize(rawData)` and asserting that valid data produces an immutable model matching `Character.ts`, while malformed data cleanly rejects invalid fields or applies default fallbacks without raising Lua runtime errors.

**Acceptance Scenarios**:

1. **Given** valid raw character data (from player creation form or `SavedVariablesPerCharacter`), **When** parsed by `Character.create(rawData)`, **Then** it instantiates a valid character object containing all identity fields (`fullName`, `class`, `category`, `level`, `type`), 7 core attributes (`strength`, `dexterity`, `constitution`, `intelligence`, `willpower`, `wisdom`, `charisma`), 7 talent branch trees, `race` (`main`, `secondary`, `talents`), `isWorgen`, positive/negative traits arrays, `equipment` slots, `pets`, `heroics`, `skills`, `spells`, `professions`, and base `CombatStats` defaults (`healthPoints`, `resources`, `initiative`, `offensiveActions`, `defensiveActions`, `movement`, etc.).
2. **Given** corrupted raw character data (e.g. missing `level`, `category` string invalid like `"godmode"`, negative attribute values, missing `equipment` table, or malformed `race` object), **When** parsed during `ADDON_LOADED`, **Then** the parser sanitizes the table, rejecting invalid fields, clamping out-of-bound values, and applying safe default fallbacks (e.g., Level 1, Category `"normal"`, attributes set to 0, empty array fallbacks for arrays) without throwing Lua errors.
3. **Given** a new character creation request, **When** instantiated through the model factory, **Then** initial `CombatStats` are computed strictly according to category, level, and constitution attribute math (`healthPoints` default 20 + level/constitution bonus, `resources` mana/spirit default 10, `initiative` default 100, `movement` default 20).

---

### User Story 2 - Items & Equipment Models Schema of Truth (Armor, Weapon, Shield, Requirement, Penalty) (Priority: P1)

As an equipment and combat manager, I want `Item`, `Armor`, `Weapon`, and `Shield` models to validate and parse raw item tables imported from TRP3 Extended or character persistence data, ensuring that requirements, penalties, slot placements, and damage ranges strictly adhere to defined schemas.

**Why this priority**: Equipment directly affects armor reductions, movement penalties, talent prerequisites, and weapon damage roll calculations during combat.

**Independent Test**: Can be tested independently by feeding valid raw item tables (matching `Item.ts`) and malformed item tables to item model factories, verifying that slot assignments, damage ranges, requirement arrays, and penalty arrays validate cleanly.

**Acceptance Scenarios**:

1. **Given** valid raw `Armor` data (`slot: 'head'|'chest'|'hands'|'legs'`, `physicalReduction`, `magicalReduction`, `durability`, `piercingDamage`, `slashingDamage`, `crushingDamage`, `requirements`, `penalties`, `movementPenalty`), **When** parsed by the item model, **Then** it returns a validated `Armor` instance.
2. **Given** valid raw `Weapon` data (`damage`, `diceNumber`, `weaponId`), **When** parsed, **Then** it returns a validated `Weapon` instance with calculated min-max damage ranges.
3. **Given** valid raw `Shield` data (`type: 'light'|'medium'|'heavy'`, `slot: 'offHand'`, `durability`, `requirements`, `penalties`, `movementPenalty`), **When** parsed, **Then** it returns a validated `Shield` instance.
4. **Given** corrupted item raw data (e.g. `Armor` assigned to invalid slot `'feet'`, negative durability, missing `requirements` array, or invalid shield type string), **When** parsed, **Then** the parser rejects the item or parses it as `null` with explicit validation error details.

---

### User Story 3 - Combat Session & Initiative Model Schema of Truth (Combat, InitiativeOrder) (Priority: P2)

As a turn-based combat coordinator, I want the `Combat` and `InitiativeOrder` models to parse and enforce active encounter state, initiative queues, round tracking, and combat log entries with 100% schema integrity.

**Why this priority**: Turn-based combat requires reliable state synchronization across participating players without desynchronization or invalid turn ordering.

**Independent Test**: Can be tested by instantiating a combat encounter with raw character lists, verifying initiative sorting, round increments, active turn tracking, and asserting that corrupted state payloads (e.g. negative round numbers, empty character IDs) are sanitized or rejected.

**Acceptance Scenarios**:

1. **Given** valid raw combat data (`id`, `activeCharacterId`, `actualRound`, `initiativeOrder` array, `combatLog` array), **When** parsed by `Combat.create(rawData)`, **Then** it produces an active combat state object where `initiativeOrder` entries contain valid `characterId` and `initiativeResult` values.
2. **Given** corrupted combat raw data (e.g. `actualRound` < 1, missing `activeCharacterId`, or invalid `initiativeOrder` structure), **When** parsed during incoming P2P network sync, **Then** the model sanitizes the turn state, resetting `actualRound` to 1 and filtering out invalid character IDs.

---

### User Story 4 - Heroic Capabilities Model Schema of Truth (Heroic) (Priority: P2)

As a roleplay character manager, I want the `Heroic` model to parse and validate narrative heroic cards (`id`, `name`, `type: 'active'|'passive'`, `description`, `version`), allowing players to store and upgrade custom narrative actions cleanly.

**Why this priority**: Heroics provide custom narrative actions defined by players that improve with `heroicPoints` over time.

**Independent Test**: Can be tested by passing valid heroic table lists and invalid heroic tables (missing version, invalid type) to the `Heroic` parser and verifying strict validation.

**Acceptance Scenarios**:

1. **Given** valid raw heroic card data (`name: "Valkyrie Leap"`, `type: "active"`, `description: "Jump 20 yards"`, `version: 1`), **When** parsed by `Heroic.create(rawData)`, **Then** it creates a valid `Heroic` object.
2. **Given** malformed heroic raw data (e.g. `type: "invalidType"`, missing `description`, or non-numeric `version`), **When** parsed, **Then** the validation parser flags the card as invalid and prevents it from polluting character state.

---

### User Story 5 - Pet Companion Model Schema of Truth (Pet) (Priority: P3)

As a hunter or pet owner, I want the `Pet` model (extending `CombatStats`) to parse and validate secondary pet companion tables, ensuring pets maintain core attributes (`strength`, `dexterity`, `constitution`, `intelligence`, `willpower`, `wisdom`), pet type (`'magical'|'normal'`), level, and learned skills/spells lists.

**Why this priority**: Pets act as secondary combat entities with independent stats and damage math (1D4 + Strength physical, 1D4 + Intelligence magical).

**Independent Test**: Can be tested by passing valid and corrupted raw pet tables to `Pet.create(rawData)` and asserting proper attribute scaling and error rejection.

**Acceptance Scenarios**:

1. **Given** valid raw pet data (`id`, `name`, `level`, `type: 'normal'`, 6 core attributes, learned `skills`, learned `spells`), **When** parsed by `Pet.create(rawData)`, **Then** it returns a validated `Pet` object extending `CombatStats`.
2. **Given** corrupted pet raw data (e.g. missing `name`, `level` < 1, invalid `type`, or missing attribute table), **When** parsed, **Then** the pet parser rejects the table or initializes a base Level 1 default pet table.

---

### User Story 6 - Skills & Spells Metadata Models Schema of Truth (Skill, Spell) (Priority: P3)

As a character progression engine, I want `Skill` and `Spell` models to validate and parse raw ability metadata tables, ensuring action costs, slot costs, cooldowns, turn effects, spell power, and categories strictly conform to the system specifications.

**Why this priority**: Skills and spells define actionable combat abilities whose metadata originates from static databases (`SpellsPort`, `SkillsPort`) or learned character lists.

**Independent Test**: Can be tested by passing raw skill/spell tables to `Skill.create()` and `Spell.create()`, verifying attribute bounds, enum validations (`spellType: 'cantrip'|'fast'|'basic'|'potent'`), and failure states for corrupted payloads.

**Acceptance Scenarios**:

1. **Given** valid raw `Skill` data (`id`, `name`, `type: 'active'|'passive'`, `description`, `slotCost`, `actionCost`, `effectTurns`, `cooldownTurns`), **When** parsed, **Then** a valid `Skill` model is returned.
2. **Given** valid raw `Spell` data (`id`, `name`, `description`, `slotCost`, `actionCost`, `turnEffects`, `cooldownTurns`, `category`, `spellType: 'cantrip'`, `type`, `resourceCost`, `power`, `triggerOpportunityAttack`, `isCanalizable`), **When** parsed, **Then** a valid `Spell` model is returned.
3. **Given** malformed spell raw data (e.g. `spellType` = `"legendary"`, negative `actionCost`, non-boolean `triggerOpportunityAttack`), **When** parsed, **Then** validation fails and the malformed ability is rejected.

---

### User Story 7 - Professions Progression Model Schema of Truth (Profession) (Priority: P3)

As a character profile system, I want the `Profession` model to parse and validate trade profession entries (`id`, `name`, `description`, `level`, `currentExp`), persisting craft progression safely.

**Why this priority**: Professions track non-combat trade skills and experience points per character.

**Independent Test**: Can be tested by parsing valid profession tables and corrupted profession tables (negative experience, missing name), asserting proper bounds sanitization.

**Acceptance Scenarios**:

1. **Given** valid raw profession data (`id: "blacksmithing"`, `name: "Herrería"`, `description: "Armas y armaduras"`, `level: 3`, `currentExp: 150`), **When** parsed, **Then** a valid `Profession` model is instantiated.
2. **Given** corrupted raw profession data (e.g. negative `level` or `currentExp`), **When** parsed, **Then** the parser resets values to default `level = 1` and `currentExp = 0`.

---

### Edge Cases

- **Corrupted SavedVariables Table Structure**: When `SavedVariablesPerCharacter.GAC_CharacterDB` contains broken Lua tables, strings where sub-tables are expected, or truncated data from client crash, `Character.create()` sanitizes all sub-tables and resets corrupted branches to safe schema defaults without aborting addon load.
- **Nil / Missing Secondary Race**: When `race.secondary` is `null` or `nil`, racial talent allocation for Mestizo is disabled and default single-race bonuses are enforced.
- **Empty / Null Equipment Slots**: Equipment slots with `null` values parse cleanly as empty slots without raising table index errors (`Attempt to index field 'head' (a nil value)`).
- **Extra Unknown Fields in Raw Data**: Any unrecognized properties present in raw tables (e.g., leftover legacy fields or third-party addon bloat) are automatically stripped during model parsing to keep persistence lightweight.
- **Unmatched Enum Strings**: Invalid string enums (e.g., `category` = `"godmode"`, `type` = `"alien"`, `spellType` = `"ultra"`) are automatically coerced to their default fallback enum value (`"normal"`, `"player"`, `"basic"`).

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST implement `Character.ts` and `CombatStats` as authoritative domain models, serving as the single Schema of Truth for character data.
- **FR-002**: System MUST parse and validate all character data through the `Character` model when creating a new character.
- **FR-003**: System MUST parse, sanitize, and validate all persistent player character data through the `Character` model when loaded from `SavedVariablesPerCharacter` (`GAC_CharacterDB`) on `ADDON_LOADED`.
- **FR-004**: System MUST validate raw input data against models and reject corrupted or malformed data while applying safe fallback defaults for non-critical missing properties.
- **FR-005**: System MUST implement `Item.ts`, `Armor`, `Weapon`, and `Shield` models as the Schema of Truth for all equipment data.
- **FR-006**: System MUST implement `Combat.ts` and `InitiativeOrder` models as the Schema of Truth for turn-based combat encounter state.
- **FR-007**: System MUST implement `Heroic.ts` model as the Schema of Truth for narrative heroic card data.
- **FR-008**: System MUST implement `Pet.ts` model as the Schema of Truth for secondary pet companion entities.
- **FR-009**: System MUST implement `Skill.ts` and `Spell.ts` models as the Schema of Truth for actionable ability metadata.
- **FR-010**: System MUST implement `Profession.ts` model as the Schema of Truth for trade skill progression.
- **FR-011**: System MUST replace existing domain model files in `src/main/domain/models/` to strictly align with and fetch schemas defined in `specs/001-Types-Models/*.ts`.
- **FR-012**: System MUST provide schema factory validation functions (e.g., `Model.create(rawData)` or `Model.validate(rawData)`) for every domain model entity.

---

### Key Entities

- **Character (Schema of Truth)**: Central character entity stored in `SavedVariablesPerCharacter`, containing identity (`fullName`, `class`, `category`, `level`, `type`), 7 core attributes, 7 talent branch structures, `race`, `isWorgen`, `positiveTraits`, `negativeTraits`, `equipment`, `pets`, `heroics`, `skills`, `spells`, `professions`, and `CombatStats`.
- **CombatStats**: Embedded base combat parameters (`healthPoints`, `resources`, `initiative`, `offensiveActions`, `defensiveActions`, `movement`, perception flags, combat state flags).
- **Item / Armor / Weapon / Shield**: Equipment entities specifying item properties, durability, damage dice, armor reductions, requirements, penalties, and movement penalties.
- **Combat / InitiativeOrder**: State machine models tracking active combat ID, current round, active character turn, initiative order list, and combat log.
- **Heroic**: Narrative card model (`id`, `name`, `type`, `description`, `version`).
- **Pet**: Companion entity model extending `CombatStats` with pet attributes, level, skills, and spells.
- **Skill / Spell**: Ability metadata models defining action costs, slot costs, cooldowns, effect turns, power, and categories.
- **Profession**: Trade skill model tracking profession level and experience.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of character creation and `SavedVariablesPerCharacter` data load operations parse through the `Character` model factory with 0 unhandled exception crashes.
- **SC-002**: 100% of valid raw data inputs successfully parse into immutable model instances matching `specs/001-Types-Models/*.ts` schemas.
- **SC-003**: 100% of malformed or corrupted raw data inputs (missing fields, wrong types, out-of-bound numbers, invalid enums) are rejected or safely sanitized to default fallbacks without raising Lua runtime errors.
- **SC-004**: Domain models in `src/main/domain/models/` achieve 100% schema alignment with TypeScript specifications in `specs/001-Types-Models/`.
- **SC-005**: Schema validation and parsing execute in under 5ms during `ADDON_LOADED`, introducing zero perceptible load delay.

---

## Assumptions

- **Persistence Storage**: `SavedVariablesPerCharacter.GAC_CharacterDB` is the designated per-character storage registered in `GAC_DEV.toc`.
- **Schema Location**: `specs/001-Types-Models/*.ts` files provide the authoritative TypeScript schemas for all domain entities.
- **Pure Lua Domain Implementation**: Transpiled/implemented Lua domain models in `src/main/domain/models/` operate in pure Lua 5.1 with zero WoW client API dependencies, fulfilling Hexagonal architecture rules.
- **No Direct Code Generation in SPEC Task**: This task updates `specs/001-Types-Models/SPEC.md` specification documentation exclusively without generating executable Lua or TS code.
