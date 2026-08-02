# Feature Specification: Core Data Metadata Tables & Trait Services

**Feature Branch**: `003-metadata`

**Created**: 2026-08-03

**Status**: APPROVED

**Input**: User description: "The spec will implement Metadata tables for core data. Transpilation of interface and types to Lua of all `specs\\003-Metadata\\*-types.ts`. Lua tables created and grouped by type in `src\\main\\domain\\database`. All specific trait functions created should be in `src\\main\\adapters\\services\\traits\\` grouped by functionality. Get functions for any lua table created must be defined inside `src\\main\\ports\\` grouped by tables access. Modified existed models to ensure match with the interface provided in every type.ts"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Core Metadata Database Tables & Access Ports (Priority: P1)

As the game domain engine, I want static metadata database tables created in `src/main/domain/database/` and exposed via ports in `src/main/ports/`, so that all subsystems (combat, character sheet, inventory) can query authoritative game metadata for armor, shields, weapons, races, level matrix, attributes/talents, and traits.

**Why this priority**: Static metadata is the foundational data layer of the RPG system. All item stats, racial bonuses, progression formulas, and dice calculations rely on these tables.

**Independent Test**: Can be tested independently by querying port functions in `src/main/ports/` (e.g. `ArmorPort.getArmor("plate")`, `WeaponsPort.getWeapon("dagger")`, `RacePort.getRace("human")`, `LevelPort.getLevelEntry("normal", 5)`) and validating that the returned Lua structures match the TypeScript schemas and values.

**Acceptance Scenarios**:

1. **Given** static metadata tables in `src/main/domain/database/`, **When** a port function is called with a valid identifier, **Then** it returns the exact immutable metadata structure matching the corresponding TypeScript interface.
2. **Given** an invalid or unknown identifier, **When** queried through the port getter functions, **Then** the port returns `nil` cleanly without throwing runtime errors.

---

### User Story 2 - Mechanical Trait Adapters & Effect Calculators (Priority: P2)

As the combat and character engine, I want mechanical trait helper functions implemented in `src/main/adapters/services/traits/` grouped by functionality, so that complex trait mechanics (e.g., dual-wielding penalty adjustments for `agileAmbidextrous` and `strongAmbidextrous`, extra combat actions for `advantaged`, experience bonus rolls for `fastLearner`) can be executed safely outside domain entities.

**Why this priority**: Mechanical traits modify roll calculations, dual-wielding penalties, action point counts, and experience gains. Separating trait calculation logic into adapter services keeps domain models pure while providing rich gameplay mechanics.

**Independent Test**: Can be tested independently by passing character state and equipment contexts into specific trait service functions and asserting that the calculated penalties, action additions, or dice rolls accurately reflect the trait's level.

**Acceptance Scenarios**:

1. **Given** a character with `agileAmbidextrous` level 1, **When** calculating dual-wielding attack penalties for agile weapons, **Then** the dual-wield penalty is negated completely.
2. **Given** a character with `fastLearner`, **When** experience points are awarded, **Then** a 1D4 extra experience roll is generated and returned to the caller.

---

### User Story 3 - Model Parity with TypeScript Interfaces (Priority: P2)

As a domain developer, I want existing domain models in `src/main/domain/models/` updated to match the exact interfaces provided across all `*-types.ts` specifications, so that schema creation and validation (`Model.create(raw_data)`) are 100% compliant with the typed data contracts.

**Why this priority**: Structural alignment prevents field mismatch bugs, missing default values, and invalid assertions when instantiating characters, equipment, or traits across the addon.

**Independent Test**: Can be tested independently by instantiating models (`Character.create()`, `Armor.create()`, etc.) and verifying all interface properties, optional fields, and requirement schemas pass validation.

**Acceptance Scenarios**:

1. **Given** raw item or character data, **When** passed through model factory constructors (`Model.create()`), **Then** all properties defined in `*-types.ts` are validated, normalized, and correctly assigned.

---

### Edge Cases

- **Optional Fields**: Missing optional properties (`requirements`, `penalties`, `throwable`, `twoHanded`, `special`) in table definitions return `nil` or empty arrays without causing table indexing errors.
- **Max Level Thresholds**: Level queries for max level (e.g., level 10 boss with `expToLevel: -1`) are handled cleanly without divide-by-zero or negative experience calculation issues.
- **Incompatible Traits**: Negative trait incompatibility lists are checked to ensure mutually exclusive traits cannot be active simultaneously on a character model.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST transpile all TypeScript type definitions and dataset constants from `specs/003-Metadata/*-types.ts` into pure Lua 5.1 tables in `src/main/domain/database/`:
  - `armor-types.ts` → `ArmorDatabase.lua` (`ArmorList`, `Slot`, `ArmorType`, `CombinableType`)
  - `attributes-talents-types.ts` → `AttributesTalentsDatabase.lua` (`Attributes`, talent groups, `AttributeGroup`)
  - `level-type.ts` → `LevelDatabase.lua` (`levelTable`, `Category`, `LevelEntry`)
  - `races-type.ts` → `RaceDatabase.lua` (`RaceList`, `WorgenCurse`, `RaceType`, `SpecialTraits`)
  - `shield-types.ts` → `ShieldDatabase.lua` (`ShieldList`, `ShieldType`)
  - `traits-types.ts` → `TraitsDatabase.lua` (`PositiveTraitList`, `NegativeTraitList`, `TraitType`)
  - `weapons-type.ts` → `WeaponsDatabase.lua` (`WeaponList`, `DamageType`)
- **FR-002**: System MUST place all transpiled database tables under `src/main/domain/database/`, enforcing pure Lua 5.1 domain purity (zero WoW API dependencies).
- **FR-003**: System MUST define read-only getter ports in `src/main/ports/` grouped by table access (e.g., `ArmorPort.lua`, `WeaponsPort.lua`, `ShieldPort.lua`, `RacePort.lua`, `LevelPort.lua`, `AttributesTalentsPort.lua`, `TraitsPort.lua`) to provide clean data access interfaces.
- **FR-004**: System MUST implement all specific trait mechanical calculation functions in `src/main/adapters/services/traits/` grouped by functionality (e.g., `combatTraitsService.lua`, `talentTraitsService.lua`, `progressionTraitsService.lua`).
- **FR-005**: System MUST update existing domain models in `src/main/domain/models/` (`Character.lua`, `Armor.lua`, `Shield.lua`, `Weapon.lua`) to guarantee complete structural match with the TypeScript interfaces in every `*-types.ts`.
- **FR-006**: System MUST update parent XML manifests (`src/main/domain/database/database.xml`, `src/main/adapters/services/traits/traits.xml`, `src/main/ports/ports.xml`, `src/main/main.xml`) following cascading bottom-up load order rules.

### Key Entities

- **ArmorMetadata & Armor**: Defense reductions (physical/magical), durability, damage type vulnerabilities, slot-based talent requirements, slot-based penalties, and combinable armor rules (`clothes`, `leather`, `mail`, `plate`).
- **ShieldMetadata & Shield**: Physical/magical reduction, durability, movement penalty, attack metadata (damage, dice count, damage type), talent requirements, and penalties.
- **Weapon & AttackMetaData**: Damage values, dice count, damage type, associated talent requirements, throwable attack options, and two-handed usage profiles.
- **Race & WorgenCurse**: Playable races with advantage talents, disadvantage talents, special racial traits (`nightVision`, `superiorHearing`, `fearAndSleepImmunity`, `poisonAndDiseaseImmunity`, `limbReplacement`, `superStrength`, `regeneration`, `innate:*`, `adaptability`, `perfectionism`, `hughMovility:fourLegs`), and Worgen transformation stats.
- **LevelTable & LevelEntry**: Level progression matrix indexed by category (`noob`, `normal`, `elite`, `boss`) and level (1-10), defining `maxHealth`, `expToLevel`, `attPoints`, `skillPoints`, `heroicPoints`, and `maxPositiveTraits`.
- **Attributes & Talents**: Attribute categories (`strength`, `dexterity`, `intelligence`, `willpower`, `constitution`, `wisdom`, `charisma`) mapped to their associated talent lists.
- **Traits (Positive & Negative)**: Trait definitions detailing `id`, `name`, `description`, `type` (`narrative`, `mechanical`, `talents`), level-scaled positive effects (level 1-3), negative trait effects, and incompatibility lists.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of TypeScript interfaces, types, and constants across all 7 `specs/003-Metadata/*-types.ts` files are transpiled to valid pure Lua 5.1 tables in `src/main/domain/database/`.
- **SC-002**: Read-only accessor ports in `src/main/ports/` cover 100% of created database tables, returning valid immutable data structures or `nil` for invalid queries.
- **SC-003**: 100% of mechanical trait functions specified in `traits-types.ts` are implemented in `src/main/adapters/services/traits/` grouped by trait domain functionality.
- **SC-004**: Existing models in `src/main/domain/models/` pass validation checks against all TypeScript interface specifications with 0 property mismatches.
- **SC-005**: All created files are registered in bottom-up cascading XML manifests with zero load-order or undefined variable runtime issues.

## Assumptions

- Transpiled Lua database tables are static, read-only data sources operating in pure Lua 5.1.
- No WoW client API calls (`CreateFrame`, `RegisterEvent`, C_ APIs) are permitted in `src/main/domain/database/` or `src/main/domain/models/`.
- Trait service adapters resolve complex calculations (e.g., dice rolls, penalty reductions) on demand when requested by combat/character domain logic.
