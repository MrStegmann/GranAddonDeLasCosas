# SPEC-001: Project Architecture & Structure Refactor

- **Status:** COMPLETED
- **Author:** GEMINI Code Agent
- **Created Date:** 2026-07-28
- **Target Feature Path:** `src/`

---

## 1. Executive Summary & Problem Statement
The GAC_DEV project has evolved with multiple components, but several modules currently violate the core rules defined in `AGENTS.md`. Specifically:
1. Persistence logic is mixed directly inside UI and data initialization scripts (e.g. `src/Data/AttributesAndTalents.lua` and `index.lua`), violating the Centralized Persistence Constraint.
2. File load order in `GranAddonDeLasCosas.xml` does not adhere to the mandatory sequence (e.g. `Models` loaded after `Communication` and `Utils`, missing `src/Events/Events.xml`, `src/Constants/Constants.xml`, and `src/Services/Services.xml`).
3. Several source files exceed or approach the strict 500-line ceiling (e.g. `src/Communication/TRP3Bridge.lua` at 1131 lines, `src/Frames/MainMenu/Components/CharSheet/CharacteristicsTab.lua` at 570 lines).
4. Inconsistent LDoc annotations (`@module`, `@param`, `@return`) and naming convention enforcement (`camelCase` for functions/variables, `PascalCase` for Frames/Models/XML files).
5. Global variable names for persistence need standardization according to `AGENTS.md` (`GAC_CharacterDB` / `SavedVariablesPerCharacter`).

This specification outlines the systematic refactoring plan to align the codebase fully with `AGENTS.md` while maintaining existing functionality.

---

## 2. Functional Requirements
- [ ] **FR-1:** All character data persistence operations must be centralized within `src/Events/PersistenceEvents.lua`.
- [ ] **FR-2:** `GAC_DEV.toc` and global scope must standardize persistence with `## SavedVariablesPerCharacter: GAC_CharacterDB`.
- [ ] **FR-3:** XML manifest loading in `GranAddonDeLasCosas.xml` must follow the strict 14-step dependency hierarchy.
- [ ] **FR-4:** Every file exceeding 500 lines (e.g., `TRP3Bridge.lua`, `CharacteristicsTab.lua`) must be modularized into sub-components/modules strictly under 500 lines each.
- [ ] **FR-5:** All Lua modules and functions must be fully documented with LDoc (`@module`, `@param`, `@return`).
- [ ] **FR-6:** Top-level UI frames must support dragging (`SetMovable(true)`, `EnableMouse(true)`, `RegisterForDrag("LeftButton")`, etc.) and remain decoupled via feature services.

---

## 3. Technical Architecture & File Plan

### New Files
- `src/Events/Events.xml` (Central Event Manifest)
- `src/Events/PersistenceEvents.lua` (Centralized `ADDON_LOADED` / `PLAYER_LOGOUT` persistence controller)
- `src/Constants/Constants.xml` (Constants Manifest)
- `src/Constants/GameConstants.lua` (Centralized game & UI constants)
- `src/Services/Services.xml` (Global Services Manifest)
- `src/Communication/TRP3/TRP3Bridge.lua` (Main orchestrator for TRP3 integration, < 300 lines)
- `src/Communication/TRP3/TRP3Data.lua` (Data conversion & formatting helper for TRP3)
- `src/Communication/TRP3/TRP3Events.lua` (TRP3 event listeners & message handlers)
- `src/Frames/MainMenu/Components/CharSheet/components/CharacteristicsHeader.lua` (Extracted header component)
- `src/Frames/MainMenu/Components/CharSheet/components/CharacteristicsList.lua` (Extracted list/grid rendering component)

### Modified Files
- `GAC_DEV.toc` (Update `SavedVariablesPerCharacter: GAC_CharacterDB` and load sequence)
- `GranAddonDeLasCosas.xml` (Reorder file includes to strict dependency hierarchy)
- `index.lua` (Remove direct persistence initialization; delegate to `src/Events/PersistenceEvents.lua`)
- `src/Data/AttributesAndTalents.lua` (Remove DB write side-effects; delegate to `PersistenceEvents.lua`)
- `src/Models/Models.xml` (Ensure all model schemas are loaded first)
- `src/Models/CharacterModel.lua` (Add factory `CharacterModel.createDefault()` and sanitizer methods)
- `src/Communication/TRP3Bridge.lua` (Replaced by modular sub-package `src/Communication/TRP3/`)
- `src/Frames/MainMenu/Components/CharSheet/CharacteristicsTab.lua` (Refactored orchestrator under 500 lines)

---

## 4. API & Data Flow Contracts

### Centralized Persistence Architecture (`src/Events/PersistenceEvents.lua`)
- **Event Listeners:** Registers `ADDON_LOADED` and `PLAYER_LOGOUT`.
- **Hydration API:** `gacLoadCharacterData()` initializes and sanitizes memory model `GAC.characterData` from `GAC_CharacterDB`.
- **Flush API:** `gacSaveCharacterData()` flushes in-memory `GAC.characterData` back to `GAC_CharacterDB`.

```lua
--- @module Events.PersistenceEvents

--- Hydrates in-memory character state from persistent storage.
-- @param addonName string The name of the loaded addon
-- @return table CharacterModel table populated with sanitized state
function gacInitPersistence(addonName)
    if addonName ~= "GAC_DEV" then return end
    GAC_CharacterDB = GAC_CharacterDB or CharacterModel.createDefault()
    GAC.characterData = CharacterModel.sanitize(GAC_CharacterDB)
    return GAC.characterData
end

--- Flushes character state tree to persistent storage upon logout.
-- @return void
function gacFlushPersistence()
    if GAC.characterData then
        GAC_CharacterDB = CharacterModel.sanitize(GAC.characterData)
    end
end
```

### Models Factory Contract (`src/Models/CharacterModel.lua`)
```lua
--- @module Models.CharacterModel

CharacterModel = {}

--- Creates a default character data schema.
-- @return table CharacterModel structured default table
function CharacterModel.createDefault()
    return {
        attributes = {},
        talents = {},
        version = 1
    }
end

--- Sanitizes character data schema.
-- @param rawData table Raw unvalidated data
-- @return table Validated character data model
function CharacterModel.sanitize(rawData)
    local defaultData = CharacterModel.createDefault()
    if type(rawData) ~= "table" then return defaultData end
    rawData.attributes = rawData.attributes or defaultData.attributes
    rawData.talents = rawData.talents or defaultData.talents
    return rawData
end
```

---

## 5. Non-Functional & Security Constraints
- **Line Limit:** Strict 500-line ceiling per file.
- **Documentation:** Complete LDoc annotations (`@module`, `@param`, `@return`) on all Lua files and functions.
- **Naming Standard:** `camelCase` for all variables and functions; `PascalCase` for XML files, Frame constructors, and Model schemas.
- **UI Responsiveness:** Top-level UI frames must be draggable (`SetMovable(true)`, `EnableMouse(true)`, `RegisterForDrag("LeftButton")`, `SetClampedToScreen(true)`).
- **Decoupled State:** No UI frame or service directly reads/writes `GAC_CharacterDB` outside `src/Events/`.

---

## 6. Implementation Checklist
- [ ] **Step 1:** Create `src/Models/CharacterModel.lua` factory/sanitizer functions and ensure `src/Models/Models.xml` is accurate.
- [ ] **Step 2:** Create `src/Events/PersistenceEvents.lua` and `src/Events/Events.xml` to handle `ADDON_LOADED` & `PLAYER_LOGOUT`.
- [ ] **Step 3:** Update `GAC_DEV.toc` with `SavedVariablesPerCharacter: GAC_CharacterDB` and reorder `GranAddonDeLasCosas.xml`.
- [ ] **Step 4:** Refactor `index.lua` and `src/Data/AttributesAndTalents.lua` to remove direct DB access and use `PersistenceEvents`.
- [ ] **Step 5:** Modularize `src/Communication/TRP3Bridge.lua` (1131 lines) into `src/Communication/TRP3/` sub-modules (<500 lines each).
- [ ] **Step 6:** Modularize `src/Frames/MainMenu/Components/CharSheet/CharacteristicsTab.lua` (570 lines) into smaller components.
- [ ] **Step 7:** Verify all top-level frames have draggable frame logic.
- [ ] **Step 8:** Add/verify LDoc annotations across all modified/new files.
- [ ] **Step 9:** Update `DevNotes.md` under `### Otros Cambios Internos`.
