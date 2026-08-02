# Feature Specification: Character Model & Loaded Persistant Data

**Feature Branch**: `[001-character-sheet-abstraction]`

**Created**: 2026-08-02

**Status**: APPROVEDS

**Input**: Do transpilation of specs\001-Character-Sheet-Abstraction\Models.ts to Lua in src/main/domain/models/{Character, Armor, Shield, Weapon}.lua. Create the ADDON_LOADED event handler in src/main/adapters/events/events.xml to load the persistant data from GAC_CharacterDB.character when the addon is loaded.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Character Sheet Data Loading (Priority: P1)

As a system, I want to be able the Character model to load the persistant data from the game enviroment when the addon is loaded and cached the data since player is playing.

**Why this priority**: This is the most important feature because it is the foundation of the addon and character model is the core of the addon. Player Character and others player's characters use this model.

**Independent Test**: Can be fully tested by loading the addon and checking if the character model is loaded correctly

**Acceptance Scenarios**:

1. **Given** the addon is loaded, **When** the data is loaded from the game environment, **Then** the character model is loaded and cached

---

### User Story 2 - ADDON_LOADED Event Handler (Priority: P1)

As a system, I want to be able the ADDON_LOADED event handler to load the persistant data from the game environment when the addon is loaded and cached the data since player is entering the world.

**Why this priority**: This is P1 because the system must check if the is any Character saved in the game environment to load and cached it.

**Independent Test**: Can be fully tested by loading the addon and checking if the character model is loaded correctly

**Acceptance Scenarios**:

1. **Given** the game world is loaded, **When** the data is loaded by ADDON_LOADED, **Then** the character model is charged and cached.

---

### Edge Cases

- If theres no persistent data for the character model saved in GAC_CharacterDB.character, must create an Default character model.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST load the Character model from the game environment when the addon is loaded and cached the data since player is playing.
- **FR-002**: System MUST validate the persistant data from the game environment when the addon is loaded and cached the data since player is playing.
- **FR-003**: System MUST create an Default character model if theres no persistant data for the character model saved in GAC_CharacterDB.character.
- **FR-004**: System MUST include `CombatStats` properties within the `Character` model, initialized with their corresponding default values when creating a default character model.

### Key Entities *(include if feature involves data)*

- **CombatStats**: Represents dynamic combat attributes, resources, actions, perception/tactical flags, and condition states embedded directly into the `Character` model:
  - `healthPoints`: Total health points (Default: 20, derived from Category-Level metadata plus Constitution).
  - `resources`: Object containing `mana` and `spirit` (Default: 10 each, modified by Intelligence and Willpower).
  - `initiative`: Turn order initiative value (Default: 100).
  - `offensiveActions`: Available actions during offensive turn (Default: 2).
  - `canAttack`: Flag indicating if character can perform attacks (Default: true).
  - `criticalStrickRange`: Minimum D20 roll threshold for critical strikes (Default: 20).
  - `criticalFailureRange`: Maximum D20 roll threshold for critical failures (Default: 1).
  - `isAmbushActive`: Flag indicating if character is currently ambushing (Default: false).
  - `defensiveActions`: Available actions during defensive turn (Default: 1).
  - `canIntercept`: Flag determining if character can intercept offensive attacks targeting nearby players (Default: true).
  - `movement`: Movement distance capacity (Default: 20).
  - `canPhysicalPerceptionCheck`: Flag allowing physical perception checks (Default: true).
  - `canMagicPerceptionCheck`: Flag allowing magic perception checks (Default: true).
  - `canTrade`: Flag determining if character can conduct trades (Default: true).
  - `canAskAction`: Flag allowing requesting actions from others during turn (Default: true).
  - `isFlanked`: Tactical condition flag indicating character is flanked (Default: false).
  - `isDowned`: Health condition flag indicating character is downed (Default: false).
  - `isStunned`: Status condition flag indicating character is stunned (Default: false).
  - `isHighest`: Tactical flag indicating character holds the highest advantage (Default: false).
  - `isBacked`: Tactical flag indicating character has an enemy at their back (Default: false).
  - `isBlinded`: Vision condition flag indicating character is blinded by darkness or reduced visibility (Default: false).
  - `states`: Array of active state strings/status effects (`string[]`).

- **Character**: Core character model extending `CombatStats` and incorporating identity (`fullName`, `class`, `category`, `level`), primary attributes, talents, race configurations, positive/negative traits, equipped items (`head`, `chest`, `hands`, `legs`, `mainHand`, `offHand`, `ranged`), and optional pets.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The character model is loaded and cached correctly when the addon is loaded.
- **SC-002**: The character model is validated correctly when the addon is loaded.
- **SC-003**: The character model is created correctly when the addon is loaded.
- **SC-004**: The `CombatStats` properties are properly integrated and initialized with default values on the `Character` model.


