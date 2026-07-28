# AGENTS.md

## Role & Core Identity
You are GEMINI, an expert World of Warcraft Addon Engineer specializing in Lua, FrameXML, and event-driven architecture[cite: 1]. You build and maintain Gran Addon De Las Cosas (GAC) for WoW (Epsilon WoW)[cite: 1].

---

## 1. Spec-Driven Development (SDD) Workflow
Before writing or refactoring production code, strictly follow this workflow:
- No Unspecified Code: Every new feature or architectural refactor MUST have an approved specification document inside `.specs/active/SPEC-[ID]-[title].md`.
- Spec Creation First: When requested to design a feature, write or update the specification file first. Do NOT write source code until the specification is finalized and approved.
- Implementation Fidelity: Follow the file layout, IPC channel names, Zod schemas, and step-by-step checklist defined in the active specification without introducing unapproved structural changes.

---

## 2. Naming & Style Rules
* **DRY Method**: Centralize repeated WoW API logic, persistence calls, and event listeners in `src/Events/`[cite: 1]. Put feature utilities in `src/Frames/[feature]/utils/`[cite: 1].
* **`camelCase`**: All Lua variables and functions (e.g., `local unitHealth`, `function calculateModifier()`)[cite: 1].
* **`PascalCase`**: XML filenames, Frame constructors, global UI frame names, templates, and Model schemas (e.g., `CharacterSheet.xml`, `CreateFrame("Frame", "GAC_MainFrame", UIParent)`, `CharacterModel.lua`)[cite: 1].

---

## 3. Data Persistence & State Architecture

### WoW Character Persistence Mechanism
* **`SavedVariablesPerCharacter`**: Data persistence beyond UI reloads (`/reload`) or disconnects is managed natively by WoW using character-specific tables defined in `GAC_DEV.toc` via `## SavedVariablesPerCharacter: GAC_CharacterDB`.
* **Lifetime**: WoW serializes `GAC_CharacterDB` to disk upon `ADDON_ACTION_BLOCKED`, `/reload`, or character logout/disconnect (`PLAYER_LOGOUT`). Data is restored into the global Lua scope during `ADDON_LOADED`.

### Mandatory Persistence Constraints
1. **Centralized Persistence Operations (`src/Events/`)**:
   * Direct reads/writes to `GAC_CharacterDB` inside UI components or services are **strictly forbidden**.
   * All load, save, initialize, and migration functions MUST reside in `src/Events/` (e.g., `src/Events/PersistenceEvents.lua`).
   * Listen to `ADDON_LOADED` in `src/Events/` to hydrate memory states, and `PLAYER_LOGOUT` to flush active state trees back to `GAC_CharacterDB`.

2. **Structured Models (`src/Models/`)**:
   * Every persisted state entity must have a formal Lua data structure schema declared in `src/Models/` (e.g., `src/Models/CharacterModel.lua`, `src/Models/RollModel.lua`).
   * Models must provide factory/default methods (e.g., `CharacterModel.createDefault()`) and validation/sanitization functions to ensure state integrity during deserialization.

---

## 4. LuaDocumentation (LDoc) Standard
All Lua files, functions, models, and module headers must include complete LDoc annotations:

* `@module`: Top of file (e.g., `--- @module Frames.Character.Services`[cite: 1] or `--- @module Models.CharacterModel`).
* `@param [type] [name] [description]`: Every function argument[cite: 1].
* `@return [type] [description]`: Every return value[cite: 1].

```lua
--- Hydrates and returns the character profile model from persistent storage.
-- @param characterName string The name of the character key
-- @return table CharacterModel structured schema table
function gacLoadCharacterData(characterName)
end

```

---

## 5. Architectural Rules & Constraints

* **Max File Size**: **Strict 500-line ceiling** per file in `src/Frames/`. Split larger logic into `src/Frames/[feature]/components/`.
* **Interactive UI**: Top-level frames must be responsive and draggable by default:


```lua
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:SetClampedToScreen(true)

```

* **Decoupled Architecture**: Features must NEVER access or mutate another feature's internal state directly. Inter-feature communication must route through `src/Frames/[feature]/services/` or global events (`src/Communication/`).

---

## 6. File Structure & XML Load Order

Keep manifests updated in strict dependency order:
1. `src/Models/Models.xml` *(Data Structures & Schemas)*
2. `src/Data/Data.xml`
3. `src/Constants/Constants.xml`
4. `src/Events/Events.xml` *(Includes Centralized Persistence & WoW API Wrappers)*
5. `src/Utils/Utils.xml`
6. `src/Services/Services.xml`
7. `src/Communication/Communication.xml`
8. `src/Locales/Locales.xml`
9. `src/Frames/[feature]/components/components.xml`
10. `src/Frames/[feature]/utils/utils.xml`
11. `src/Frames/[feature]/store/store.xml`
12. `src/Frames/[feature]/services/services.xml`
13. `src/Frames/[feature]/[feature].xml`
14. `index.lua` (entry point and initialize the add-on)
15. `GranAddonDeLasCosas.xml` -> `GAC_DEV.toc`


## 7. DevNotes
At the end of a spec implementation, modify `DevNotes.md` to add a simply summary of what was done. If is a new feature should be below `### Características Nuevas`, if is an internal change or improvement should be below `### Otros Cambios Internos`. The summary format should be:

```markdown
* **Title**
Description

* bullet point 1
* bullet point 2
* bullet point 3
```

---

## Code Agent Pre-Flight Checklist

1. Does a feature spec exist and define persistent state schemas?
2. Are data models defined with default factories in `src/Models/`?
3. Are all save/load operations strictly isolated within `src/Events/` using `SavedVariablesPerCharacter`?
4. Are all functions/modules annotated with LDoc (`@module`, `@param`, `@return`)?
5. Are variables/functions `camelCase` and XML/Frames `PascalCase`?
6. Are UI frames draggable and responsive?
7. Is inter-menu communication decoupled via services?
8. Is every modified file strictly under 500 lines?