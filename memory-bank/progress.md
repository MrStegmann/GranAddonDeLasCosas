# Project Progress & Roadmap Tracker

## Third-Party Libraries Integration — COMPLETED

- [x] **Core Base Framework Libraries (`libs/`)**
  - [x] `LibStub` (Library stub version manager)
  - [x] `CallbackHandler-1.0` (Event & callback dispatching)
- [x] **Ace3 Suite Libraries (`libs/`)**
  - [x] `AceAddon-3.0` (Addon lifecycle manager)
  - [x] `AceEvent-3.0` (Event registration wrapper)
  - [x] `AceDB-3.0` & `AceDBOptions-3.0` (SavedVariables persistence manager)
  - [x] `AceConsole-3.0` (Slash command handler)
  - [x] `AceGUI-3.0` (UI widget & modal framework)
  - [x] `AceComm-3.0` (P2P network transport & message chunking)
  - [x] `AceSerializer-3.0` (Table serialization)
- [x] **Minimap & Data Broker Libraries (`libs/`)**
  - [x] `LibDataBroker-1.1` (LDB launcher data provider)
  - [x] `LibDBIcon-1.0` (Draggable minimap icon persistence manager)
- [x] **Data Compression Libraries (`libs/`)**
  - [x] `LibDeflate` (DEFLATE payload compression for P2P networking)
- [x] **Master Manifest Integration**
  - [x] `libs/libs.xml` created loading all 13 library components in strict bottom-up order
  - [x] `GAC_DEV.toc` updated registering `libs\libs.xml` before `src\src.xml`

---

## Feature 003: Core Data Metadata Tables & Trait Services — COMPLETED

- [x] **Transpiled Domain Database Tables (`src/main/domain/database/`)**
  - [x] `ArmorDatabase.lua` (Transpiled from `armor-types.ts`)
  - [x] `AttributesTalentsDatabase.lua` (Transpiled from `attributes-talents-types.ts`)
  - [x] `LevelDatabase.lua` (Transpiled from `level-type.ts`)
  - [x] `RaceDatabase.lua` (Transpiled from `races-type.ts`)
  - [x] `ShieldDatabase.lua` (Transpiled from `shield-types.ts`)
  - [x] `TraitsDatabase.lua` (Transpiled from `traits-types.ts`)
  - [x] `WeaponsDatabase.lua` (Transpiled from `weapons-type.ts`)
  - [x] Cascading manifest `database.xml` created and wired into `domain.xml`
- [x] **Read-Only Access Ports (`src/main/ports/metadata/`)**
  - [x] `ArmorPort.lua`
  - [x] `AttributesTalentsPort.lua`
  - [x] `LevelPort.lua`
  - [x] `RacePort.lua`
  - [x] `ShieldPort.lua`
  - [x] `TraitsPort.lua`
  - [x] `WeaponsPort.lua`
  - [x] Cascading manifest `metadataPorts.xml` created and wired into `ports.xml`
- [x] **Mechanical Trait Services (`src/main/adapters/services/traits/`)**
  - [x] `combatTraitsService.lua` (dual wield, critical, initiative, immunity checks)
  - [x] `talentTraitsService.lua` (trait talent bonuses)
  - [x] `progressionTraitsService.lua` (1d4 fast learner exp bonus, disastrous reduction)
  - [x] Cascading manifests `traitsServices.xml` and `services.xml` created and wired into `adapters.xml`
- [x] **Domain Model Schema Parity (`src/main/domain/models/`)**
  - [x] Updated `Armor.lua` for `armor-types.ts` parity
  - [x] Updated `Shield.lua` for `shield-types.ts` parity
  - [x] Updated `Weapon.lua` for `weapons-type.ts` parity
  - [x] Updated `Character.lua` sanitizeEquipment offHand logic

---

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
  - [x] `Character.lua` domain metatable with schema validation, `CombatStats` integration, & `createDefault()` fallback
  - [x] Cascading manifest update in `models.xml` and `domain.xml`
- [x] **Persistent Data Loading (`src/main/adapters/events/`)**
  - [x] `AddonLoadedHandler.lua` event listener for `ADDON_LOADED`
  - [x] `GAC_CharacterDB.character` persistence loading, schema validation, and fallback instantiation
  - [x] Cascading manifest update in `events.xml` and `adapters.xml`

---

## Completed Milestones
* **Feature 003 Complete:** All metadata databases, read-only ports, trait mechanical services, domain model parity updates, and cascading XML manifests implemented and verified.
* **Feature 002 Complete:** TRP3 Characteristics and TRP3 Extended Inventory ports implemented and wired in `ports.xml`.
* **Feature 001 Complete:** Character Sheet domain abstraction models transpiled to pure Lua 5.1 and persistent data loading on `ADDON_LOADED` wired.
