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

## Feature 006: CharacterBook Minimap Button — COMPLETED

- [x] **Minimap UI Component (`src/ui/CharacterBook/Components/MinimapButton.lua`)**
  - [x] Initialized `LibDataBroker-1.1` object (`GAC_CharacterBook`) with `OnClick` and `OnTooltipShow`.
  - [x] Registered LDB object with `LibDBIcon-1.0`.
- [x] **Persistence Integration**
  - [x] Added `_G.GAC_CharacterDB.minimap` fallback in `AddonLoadedHandler.lua`.
  - [x] Hooked MinimapButton init to `PLAYER_LOGIN` event to securely read from CharacterDB.
- [x] **Manifest Resolution**
  - [x] Wired `Components/MinimapButton.lua` in `CharacterBook.xml`.

---
## Feature 005: CharacterBook UI - Basic Information — COMPLETED

- [x] **Core UI Implementation (`src/ui/CharacterBook/`)**
  - [x] Bootstrapped feature-based UI components (Frame, Controller, Presenter, index).
  - [x] Implemented Navigation Bar and Sub-Tabs placeholder logic.
  - [x] Implemented Basic Info UI components (Dropdowns, Checkboxes, Trait displays).
- [x] **Controller & Data Binding (`src/ui/CharacterBook/CharacterBookController.lua`)**
  - [x] `FetchTRP3Data()` integration to extract Name and Class dynamically.
  - [x] Data-bound Category, Level, and Race dropdowns using API endpoints.
  - [x] Single-race and Dual-race traits logic via `UpdateTraitsDisplay()`.
  - [x] Interactive GameTooltip logic for the Worgen Curse checkbox.
- [x] **API Endpoint Parity (`src/main/API/metadata/`)**
  - [x] Expose `LevelPort.GetCategories()` and `LevelPort.GetLevelsByCategory()`.
  - [x] Expose `RacePort.GetAllRaces()` and `RacePort.GetRaceTraits()`.

---

## Feature 004: MVC Architecture Refactor — COMPLETED

- [x] **Architecture Redesign**
  - [x] Created `src/main/Models/`, `src/main/API/`, `src/main/Controllers/` enforcing MVC rules.
  - [x] Migrated `adapters`, `domain`, `ports`, and `Data` folders to their correct MVC counterparts.
- [x] **Manifest Resolution**
  - [x] Configured cascading XML load order (`Models.xml` -> `API.xml` -> `Controllers.xml`).
  - [x] Scrubbed `src/main/` of legacy folder structure references.

---
## Feature 003: Core Data Metadata Tables & Trait Services — COMPLETED

- [x] **Transpiled Domain Database Tables (`src/main/domain/database/`)**
  - [x] `ArmorDatabase.lua`, `LevelDatabase.lua`, `RaceDatabase.lua`, `ShieldDatabase.lua`, `TraitsDatabase.lua`, `WeaponsDatabase.lua`
  - [x] `StrengthSkillsDatabase.lua`, `DexSkillsDatabase.lua`, `ConstitutionSkillsDatabase.lua`
  - [x] `ArcaneDatabase.lua`, `ElementalDatabase.lua`, `EluneDatabase.lua`, `HolyLightDatabase.lua`, `ShadowDatabase.lua`, `WorgenCurseDatabase.lua`
  - [x] Empty tables: `ChiDatabase.lua`, `FelDatabase.lua`, `NatureDatabase.lua`, `NecromanceDatabase.lua`
  - [x] Cascading manifest `database.xml` created and wired into `domain.xml`
- [x] **Read-Only Access Ports (`src/main/ports/metadata/`)**
  - [x] `ArmorPort.lua`, `LevelPort.lua`, `RacePort.lua`, `ShieldPort.lua`, `TraitsPort.lua`, `WeaponsPort.lua`
  - [x] `StrengthSkillsPort.lua`, `DexSkillsPort.lua`, `ConstitutionSkillsPort.lua`
  - [x] `ArcanePort.lua`, `ElementalPort.lua`, `ElunePort.lua`, `HolyLightPort.lua`, `ShadowPort.lua`, `WorgenCursePort.lua`
  - [x] Empty ports: `ChiPort.lua`, `FelPort.lua`, `NaturePort.lua`, `NecromancePort.lua`
  - [x] Cascading manifest `metadataPorts.xml` created and wired into `ports.xml`
- [x] **Probing Test Suite & Parity Verification (`tests/probing/`)**
  - [x] `test_core_data_ports.lua`, `test_equipment_ports.lua`, `test_skills_ports.lua`, `test_spell_school_ports.lua`, `test_empty_ports.lua`
  - [x] `run_all_probing_tests.lua` master runner asserting 100% structural parity across all 19 endpoints
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
* **Feature 006 Complete:** Minimap Button toggles the CharacterBook UI and persists position via LibDBIcon.
* **Feature 005 Complete:** The CharacterBook UI feature is functional. TRP3 and database API endpoints are wired, and the basic info logic is sound.
* **Feature 004 Complete:** The MVC architecture refactor is successful, moving all legacy folders (`adapters`, `domain`, `ports`, `Data`) into `Models`, `API`, and `Controllers` securely with XML manifests.
* **Feature 003 Complete:** All metadata databases, read-only ports, trait mechanical services, domain model parity updates, and cascading XML manifests implemented and verified.
* **Feature 002 Complete:** TRP3 Characteristics and TRP3 Extended Inventory ports implemented and wired in `ports.xml`.
* **Feature 001 Complete:** Character Sheet domain abstraction models transpiled to pure Lua 5.1 and persistent data loading on `ADDON_LOADED` wired.
