---
name: acedb-savedvariables-persistence
description: Manage account-wide and per-character persistent data with automatic default initialization. Use when you are setting up SavedVariables (GranAddonDeLasCosasDB) or SavedVariablesPerCharacter (GAC_CharacterDB).
---

# Skill: AceDB SavedVariables Persistence

## Objective
Initialize, load, and manage persistent data tables using `AceDB-3.0`, guaranteeing fallback defaults, profile switching, and safe table sanitization.

## Documented Inputs
- **`tocSavedVariable`** (string): The registered `SavedVariables` name from `.toc` (e.g. `"GAC_CharacterDB"`).
- **`defaultsTable`** (table): Default schema structure for `char`, `global`, or `profile` scopes.
- **`defaultProfile`** (optional string/boolean): Default profile name fallback.

## Explicit and Verifiable Acceptance Criteria
- [ ] Automatically populates missing data properties from `defaultsTable` upon loading.
- [ ] Persists per-character modifications across UI reloads and logouts.
- [ ] Prevents table corruption by maintaining fallback defaults for uninitialized profiles.

## How to Use & Examples

### Example: Setting Up Per-Character Persistence
```lua
local AceDB = LibStub("AceDB-3.0")

local defaultSchema = {
    char = {
        Character = {
            fullname = "Unknown Hero",
            level = 1,
            category = "Normal",
            race = "Human",
            class = "Warrior",
            attPoints = 15,
            skillPoints = 10,
            heroicPoints = 2,
            maxHealth = 100,
            attributes = { strength = 0, dexterity = 0, constitution = 0, intelligence = 0, willpower = 0, wisdom = 0, charisma = 0 },
            talents = {},
            heroicCards = {},
            pets = {},
            learnedSkills = {},
            learnedSpells = {}
        }
    }
}

function GAC_DEV:InitializeDatabase()
    self.db = AceDB:New("GAC_CharacterDB", defaultSchema, true)
    -- Access character database safely
    local charData = self.db.char.Character
    print("Loaded character:", charData.fullname)
end
```
