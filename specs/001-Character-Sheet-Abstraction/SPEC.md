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

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The character model is loaded and cached correctly when the addon is loaded.
- **SC-002**: The character model is validated correctly when the addon is loaded.
- **SC-003**: The character model is created correctly when the addon is loaded.

