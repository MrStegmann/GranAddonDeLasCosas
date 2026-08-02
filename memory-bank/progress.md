# Project Progress & Roadmap Tracker

## Feature 002: TRP3 Bridges (Characteristics & Inventory) — COMPLETED

- [x] **Characteristics Bridge Port (`src/main/ports/TR3Bridge/characteristics.lua`)**
  - [x] `getFullName()` concatenation function returning `"Einarr \"Augaraf\" Olafrson"` fallback
  - [x] `getClass()` function returning `"Vrykingul"` fallback
- [x] **Inventory Bridge Port (`src/main/ports/TR3Bridge/inventory.lua`)**
  - [x] `getEquipedItems()` function returning `ItemsResponse` structure (`Item[]`) or empty list `{}`
  - [x] `updateItem(itemData)` function modifying TRP3_Extended database item entries
- [x] **Cascading XML Manifest Integration**
  - [x] Created `src/main/ports/TR3Bridge/TR3Bridge.xml` registering script files
  - [x] Updated `src/main/ports/ports.xml` to include `TR3Bridge/TR3Bridge.xml`

---

## Feature 001: Character Sheet Abstraction — COMPLETED

- [x] **Transpilation of TypeScript Models (`Models.ts` -> `src/main/domain/models/`)**
  - [x] `Armor.lua` domain metatable with schema validation
  - [x] `Weapon.lua` domain metatable with schema validation
  - [x] `Shield.lua` domain metatable with schema validation
  - [x] `Character.lua` domain metatable with schema validation & `createDefault()` fallback
  - [x] Cascading manifest update in `models.xml` and `domain.xml`
- [x] **Persistent Data Loading (`src/main/adapters/events/`)**
  - [x] `AddonLoadedHandler.lua` event listener for `ADDON_LOADED`
  - [x] `GAC_CharacterDB.character` persistence loading, schema validation, and fallback instantiation
  - [x] Cascading manifest update in `events.xml` and `adapters.xml`

---

## Completed Milestones
* **Feature 002 Complete:** TRP3 Characteristics and TRP3 Extended Inventory ports implemented and wired in `ports.xml`.
* **Feature 001 Complete:** Character Sheet domain abstraction models transpiled to pure Lua 5.1 and persistent data loading on `ADDON_LOADED` wired.

