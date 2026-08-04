# Feature Specification: Character Book UI & Data Integration

**Feature Branch**: `004-character-book`

**Created**: 2026-08-04

**Status**: Draft

**Input**: User description: "Analyze specs/004-Character-Book/Features.md, specs/004-Character-Book/pets-types.ts, specs/004-Character-Book/skills-spells-types.ts, spell JSON databases, and skill JSON databases (*skills.json). Create metadata tables in src/main/domain/database grouped by spellType (arcane, chi, elemental, elune, fel, holy_light, nature, necromancer/necromance, shadow) and by skill category (strength, dex, constitution, wisdom, charisma). Expose metadata via read-only ports in src/main/ports/."

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Minimap Button & Character Book Window Shell (Priority: P1)

As a roleplay player, I want to access the Character Book UI by clicking a draggable minimap button so that I can open a structured, two-column interactive book window occupying 50% width and 30% height of my screen with persistent position saving.

**Why this priority**: The minimap button and main frame shell form the entry point and container for all 6 character management sub-views. Without this shell, no character data can be displayed or managed.

**Independent Test**: Can be tested independently by logging in, dragging the minimap icon to a custom location around the minimap ring, reloading UI (`/reload`), verifying the button position persisted, clicking the icon to toggle the Character Book frame open/closed, and verifying the 50% width x 30% height viewport proportions and left-index sidebar navigation.

**Acceptance Scenarios**:

1. **Given** the player is in game, **When** they click the minimap book icon, **Then** the main Character Book window opens displaying 50% viewport width, 30% viewport height, thin borders, minimal padding, and a left index sidebar.
2. **Given** the player drags the minimap icon to a new coordinate around the minimap, **When** the UI reloads or the user reconnects, **Then** the minimap button restores its exact dragged position from `SavedVariablesPerCharacter`.
3. **Given** the Character Book window is open, **When** the player selects any of the 6 index tabs (Character Information, Attributes and Talents, Traits, Equipment, Pets, Skills & Spells), **Then** the main content view dynamically switches to display that selected index.

---

### User Story 2 - Character Information & Heroic Cards Management (Priority: P1)

As a character owner, I want to view and edit my character's identity summary (fullname, level, category, race/mestizo, class), racial advantage/disadvantage traits, level benefits matrix, and Heroic cards, so that my core character profile is accurately represented and persisted.

**Why this priority**: Core identity attributes and level matrix define character limits (`attPoints`, `skillPoints`, `heroicPoints`, `maxHealth`) used across all other tabs.

**Independent Test**: Can be tested independently by viewing the Character Information tab, clicking "Edit", modifying race/level/category or adding/editing/deleting a Heroic card (with confirmation popup), saving, and asserting that `SavedVariablesPerCharacter.Character` reflects the updated values and level matrix benefits from `LevelDatabase.lua`.

**Acceptance Scenarios**:

1. **Given** character data in `SavedVariablesPerCharacter.Character`, **When** viewing the header, **Then** it displays `{Fullname}` and sub-line `{Level} - {Category} | {Race or Mestizo} | {Class}`.
2. **Given** a single race or dual-race (Mestizo) character, **When** viewing the body layout, **Then** the first row displays two rounded-corner boxes for Racial Advantages and Racial Disadvantages, followed by special racial traits, a 3-column grid of level benefits (`maxHealth`, `expToLevel`, `attPoints`, `skillPoints`, `heroicPoints`, `maxPositiveTraits`), and a 2-column grid of Heroic Cards.
3. **Given** the tab is in Edit mode, **When** adding a Heroic card, **Then** a modal opens requesting Name, Type (active/passive), Cooldown (numeric), and Description, adding the card upon confirmation.
4. **Given** an existing Heroic card, **When** the user clicks Delete, **Then** a confirmation popup is displayed before removing the card.
5. **Given** changes in Edit mode, **When** the user clicks "Cancel", **Then** all unsaved edits are discarded and previous values are restored.

---

### User Story 3 - Attributes & Talents Tab with Limit Validation (Priority: P2)

As a player, I want to view my character's 7 primary attributes and their associated talent trees with automatic point calculations and real-time limit validation, so that I can distribute attribute and talent points within my level's budget.

**Why this priority**: Attribute scores and talent point allocations determine character capabilities, defense calculations, equipment requirements, and skill prerequisites.

**Independent Test**: Can be tested independently by opening Attributes and Talents, toggling Edit mode, attempting to over-allocate attribute points past `attPoints` or talent points past `attribute * 2`, asserting that yellow warning toasts and red border visual feedback trigger, and saving valid point distributions.

**Acceptance Scenarios**:

1. **Given** the Attributes and Talents tab, **When** rendered, **Then** it displays a 2-column grid of cards for Strength, Dexterity, Constitution, Intelligence, Willpower, Wisdom, and Charisma, showing attribute values, available talent points (`attribute * 2`), and bullet lists of talents from `AttributesTalentsDatabase.lua`.
2. **Given** Edit mode is active, **When** the sum of assigned attributes exceeds the available `attPoints` for the character's category and level (from `LevelDatabase.lua`), **Then** a yellow warning toast appears at top-center, and the over-allocated attribute card border and value turn red.
3. **Given** Edit mode is active, **When** the sum of talents under an attribute exceeds `attribute value * 2`, **Then** the card border and over-allocated talents turn red with warning feedback.
4. **Given** valid attribute and talent adjustments, **When** clicking "Save", **Then** the values are saved persistently to `SavedVariablesPerCharacter`.

---

### User Story 4 - Spells & Skills Domain Database Metadata Tables & Access Ports (Priority: P2)

As the game domain engine, I want static metadata database tables created in `src/main/domain/database/spells/` (grouped by spell category: `arcane`, `chi`, `elemental`, `elune`, `fel`, `holy_light`, `nature`, `necromance`/`necromantic`, `shadow`) and in `src/main/domain/database/skills/` (grouped by attribute category: `strength`, `dexterity`, `constitution`, `wisdom`, `charisma`), exposed via read-only ports `SpellsPort.lua` and `SkillsPort.lua` in `src/main/ports/`, so that all subsystems can query authoritative spell and skill metadata with 100% domain purity.

**Why this priority**: Decoupling raw JSON parsing into static Lua 5.1 domain tables ensures zero runtime JSON loading overhead during combat and character sheet rendering while strictly enforcing Hexagonal architecture rules.

**Independent Test**: Can be tested independently by calling port functions in `src/main/ports/` (e.g. `SpellsPort.getSpell("fireExplosion")`, `SpellsPort.getSpellsByCategory("arcane")`, `SkillsPort.getSkill("blockAndPush")`, `SkillsPort.getSkillsByCategory("strength")`) and verifying the returned Lua structures match the TypeScript schemas and values.

**Acceptance Scenarios**:

1. **Given** spell JSON files (`arcane.json`, `elemental.json`, `elune.json`, `holy_light.json`, `shadow.json`, etc.), **When** converted into Lua tables under `src/main/domain/database/spells/`, **Then** each table exports immutable spell objects containing `id`, `name`, `description`, `turnCooldown`, `costActions`, `costSlots`, `turnEffects`, `category`, `spellType`, `type`, `resourceCost`, `power`, `triggerOpportunityAttack`, and `isCanalizable`.
2. **Given** skill JSON files (`strength_skills.json`, `dex_skills.json`, `constitution_skills.json`, etc.), **When** converted into Lua tables under `src/main/domain/database/skills/`, **Then** each table exports immutable skill objects containing `id`, `name`, `description`, `turnCooldown`, `costActions`, `costSlots`, `turnEffects`, `type`, and `category`.
3. **Given** `SpellsPort.lua` and `SkillsPort.lua` in `src/main/ports/`, **When** queried with a valid ID or category, **Then** the exact matching metadata table is returned cleanly.
4. **Given** an unknown spell/skill ID or empty category (e.g. `chi`, `fel`, `nature`), **When** queried through port getters, **Then** an empty table or `nil` is returned without raising Lua errors.

---

### User Story 5 - Traits Overview & Selection Tab (Priority: P2)

As a player, I want to view and edit my character's active Positive, Negative, and Heroic traits in a clean one-column layout, so that I can manage my active character traits.

**Why this priority**: Traits provide passive mechanical and narrative modifiers to character actions, combat rolls, and skill usage.

**Independent Test**: Can be tested independently by opening the Traits tab, clicking "Edit", selecting/removing positive and negative traits from the authoritative database list, saving, and verifying that empty states or active trait lists render correctly.

**Acceptance Scenarios**:

1. **Given** the Traits tab, **When** opened, **Then** it displays a 1-column layout with 3 sections: Positive Traits (Row 1), Negative Traits (Row 2), and Heroic Traits (Row 3), showing empty state labels if no traits are selected.
2. **Given** Edit mode, **When** the player adds or removes traits, **Then** Save updates `SavedVariablesPerCharacter` while Cancel reverts to previous selections.

---

### User Story 6 - Equipment Resume & TRP3 Inventory Integration (Priority: P3)

As a combatant player, I want to view my equipped items imported from TRP3 Extended alongside a comprehensive breakdown of requirements, penalties, and weapon damage ranges, so that I can inspect my equipment compliance and combat output.

**Why this priority**: Equipment calculations integrate TRP3 item metadata with domain armor rules (`ArmorDatabase.lua`) to determine penalties, requirement gaps, and min-max damage.

**Independent Test**: Can be tested independently by equipping items in TRP3 Extended, opening the Equipment tab, verifying Head, Chest, Hands, Legs, MainHand, OffHand, and Range slot icons/tooltips, and validating requirement penalties and weapon damage dice calculations in the right-column summary.

**Acceptance Scenarios**:

1. **Given** TRP3 Extended inventory items, **When** viewing the left column, **Then** equipped items are displayed in Head, Chest, Hands, Legs, MainHand, OffHand, and Range slots with rich WoW-style tooltips showing Name (quality colored), Left/Right tooltips, Damage Min-Max (orange), Dice Roll (white), Requirements (green), Penalties (red), and Description.
2. **Given** equipped armor, **When** checking requirements against character talents, **Then** insufficient talent points duplicate penalties, while active flags in `ArmorDatabase.lua` highlight slot borders: Blue for `doubleRequirements`, Orange for `doubleDisadvantage`, Red for `notAllowed`.
3. **Given** equipped weapons, **When** calculating weapon damage, **Then** min-max damage ranges are calculated based on dice roll range + associated talent points.

---

### User Story 7 - Pets Sheet Management (Priority: P3)

As a hunter or pet owner, I want to create, edit, view, and delete pet sheets containing pet level, description, 7 core attributes, skills, and spells, so that my active companions are managed alongside my character.

**Why this priority**: Pets act as secondary combat entities with independent attributes, skills, and spells governed by `pets-types.ts`.

**Independent Test**: Can be tested independently by opening the Pets tab, clicking "Add Pet", filling the modal form (name, level, description, 7 attribute values), verifying the 2-column attribute card rendering, editing pet attributes, and deleting a pet sheet.

**Acceptance Scenarios**:

1. **Given** the Pets tab, **When** opened, **Then** it displays a list of pet sheets showing Header (Name), Description, Level, a 2-column grid of 7 core attributes (Strength, Dexterity, Constitution, Intelligence, Willpower, Wisdom, Charisma without talents), and lists for learned Pet Skills and Spells.
2. **Given** a pet sheet, **When** the user clicks "Edit", **Then** a modal opens allowing modifications to name, level, description, and attribute values.
3. **Given** the "Add Pet" button, **When** clicked, **Then** a creation modal opens without a delete button to instantiate a new pet sheet.
4. **Given** a delete action on a pet sheet, **When** confirmed, **Then** the pet sheet is permanently removed from `SavedVariablesPerCharacter`.

---

### User Story 8 - Skills & Spells Catalog & Learning System (Priority: P3)

As a progressing character, I want to browse available skills and spells filtered by category, type, and slot cost, and spend available `skillPoints` to learn new abilities, so that my character can expand their spellbook and skill list.

**Why this priority**: Skills and spells define actionable combat/roleplay abilities governed by `skills-spells-types.ts` and domain database ports (`SpellsPort`, `SkillsPort`).

**Independent Test**: Can be tested independently by opening Skills & Spells, clicking an empty slot, choosing Skill or Spell list modal, filtering by category/type/slotCost, selecting an unlearned skill/spell with gold border feedback, and clicking "Learn" to deduct `skillPoints` and populate the learned slot.

**Acceptance Scenarios**:

1. **Given** the Skills & Spells tab, **When** an empty skill/spell slot is clicked, **Then** a modal prompts the user to select "Skill List" or "Spell List".
2. **Given** the Skill List catalog, **When** opened, **Then** it queries `SkillsPort` and presents search input, category filter (`strength`, `dexterity`, `constitution`, `wisdom`, `charisma`), type filter (`active`, `passive`), and slotCost filter, displaying single-column `SkillCard` items (Name, Turns, Cooldown, Type, Description).
3. **Given** the Spell List catalog, **When** opened, **Then** it queries `SpellsPort` and presents search input, category filter (`arcane`, `fel`, `nature`, `necromantic`, `shadow`, `light`, `elune`, `chi`, `elemental`), type filter (`cantrip`, `fast`, `basic`, `potent`), and slotCost filter, displaying single-column `SpellCard` items (Name, Power, Turns, Cooldown, Type, Description).
4. **Given** learned skills/spells, **When** rendered in the catalog, **Then** they display with 50% opacity and are unselectable.
5. **Given** skills/spells exceeding remaining `skillPoints`, **When** rendered, **Then** they display disabled with 75% opacity.
6. **Given** an affordable, unlearned skill/spell, **When** selected, **Then** a gold border highlights the selection and clicking "Learn" saves it to character learned skills/spells and deducts `skillPoints`.

---

### Edge Cases

- **Corrupted SavedVariables**: If `SavedVariablesPerCharacter.Character` is missing or corrupted, the system initializes safe default structures (Level 1 Normal Category, base attributes, empty arrays for heroics/traits/pets/spells/skills).
- **Missing TRP3 Extended**: If TRP3 Extended is not loaded or `getEquipedItems` returns `nil`, equipment slots gracefully show empty slot backgrounds with placeholder tooltips without throwing Lua errors.
- **Empty Spell/Skill Categories**: Empty metadata tables (e.g. `chi`, `fel`, `nature`, `necromance`) render clean empty state lists with "No abilities available in this category" notifications.
- **Mestizo Race Toggle**: Switching race from Mestizo back to single race resets dual-race advantage/disadvantage allocation to standard racial defaults (+3 / -3).
- **Zero Skill Points**: When `skillPoints` is 0, all unlearned skills and spells render with 75% opacity and disabled "Learn" buttons.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST render a draggable minimap button with a book icon that toggles the main Character Book frame and saves its position persistently in `SavedVariablesPerCharacter`.
- **FR-002**: System MUST render the main Character Book frame at 50% viewport width and 30% viewport height with a 2-column layout (left Index sidebar, right Main Content area).
- **FR-003**: System MUST store and retrieve all primary character state from `SavedVariablesPerCharacter.Character`.
- **FR-004**: System MUST display Character Information with header `{Level} - {Category} | {Race or Mestizo} | {Class}`, racial advantages/disadvantages boxes, special racial traits, level benefits matrix (`maxHealth`, `expToLevel`, `attPoints`, `skillPoints`, `heroicPoints`, `maxPositiveTraits`), and Heroic Cards.
- **FR-005**: System MUST provide Edit mode on Character Information allowing modification of race, level, category, and CRUD management of Heroic cards (Name, Type active/passive, Cooldown numeric, Description) with confirmation popups on deletion.
- **FR-006**: System MUST render Attributes and Talents in a 2-column grid showing 7 primary attributes (`strength`, `dexterity`, `constitution`, `intelligence`, `willpower`, `wisdom`, `charisma`), talent points (`attribute * 2`), and talent trees from `AttributesTalentsDatabase.lua`.
- **FR-007**: System MUST validate attribute allocations against `attPoints` in `LevelDatabase.lua` and talent allocations against `attribute * 2`, displaying top-center yellow warning toasts and red border visual feedback when limits are exceeded.
- **FR-008**: System MUST transpile/convert all spell JSON databases (`arcane.json`, `chi.json`, `elemental.json`, `elune.json`, `fel.json`, `holy_light.json`, `nature.json`, `necromance.json`, `shadow.json`) into pure Lua 5.1 metadata database tables inside `src/main/domain/database/spells/` grouped by spell category (`arcane`, `chi`, `elemental`, `elune`, `fel`, `light`, `nature`, `necromantic`, `shadow`).
- **FR-009**: System MUST transpile/convert all skill JSON databases (`strength_skills.json`, `dex_skills.json`, `constitution_skills.json`, `wisdom_skills.json`, `charisma_skills.json`) into pure Lua 5.1 metadata database tables inside `src/main/domain/database/skills/` grouped by skill attribute category (`strength`, `dexterity`, `constitution`, `wisdom`, `charisma`).
- **FR-010**: System MUST define read-only getter ports `SpellsPort.lua` and `SkillsPort.lua` in `src/main/ports/` to expose spell and skill metadata queries to domain and UI layers without exposing internal table representations.
- **FR-011**: System MUST render Traits in a 1-column layout grouped into Positive, Negative, and Heroic sections with CRUD edit functionality.
- **FR-012**: System MUST integrate with `TRP3_Extends` inventory `getEquipedItems` to display Head, Chest, Hands, Legs, MainHand, OffHand, and Range equipment slots with rich WoW-formatted tooltips.
- **FR-013**: System MUST calculate equipment requirements, penalties, and min-max weapon damage ranges in the equipment summary column, enforcing `ArmorDatabase.lua` combination rules (`doubleRequirements` blue border, `doubleDisadvantage` orange border, `notAllowed` red border).
- **FR-014**: System MUST support Pet Sheet management (`pets-types.ts`) allowing creation, editing, viewing, and deletion of pets with 7 core attributes (no talents), level, description, learned skills, and learned spells.
- **FR-015**: System MUST render a Skills & Spells learning catalog querying metadata exclusively from `SpellsPort` and `SkillsPort`.
- **FR-016**: System MUST provide category, type, search, and slotCost filtering for Skills (`strength`, `dexterity`, `constitution`, `wisdom`, `charisma` / `active`, `passive`) and Spells (`arcane`, `fel`, `nature`, `necromantic`, `shadow`, `light`, `elune`, `chi`, `elemental` / `cantrip`, `fast`, `basic`, `potent`).
- **FR-017**: System MUST visually distinguish catalog items: 50% opacity for learned abilities, gold border for selected ability, and 75% opacity disabled state for unaffordable abilities exceeding available `skillPoints`.
- **FR-018**: System MUST enforce clean hexagonal architecture: UI frames in `src/ui/characterBook/`, IPC communications via `LocalIPCAdapter`, domain metadata in `src/main/domain/database/`, ports in `src/main/ports/`, and cascading bottom-up XML manifest loading (`spells.xml`, `skills.xml`, `database.xml`, `ports.xml`).

---

### Key Entities

- **CharacterBookState**: Primary character entity stored in `SavedVariablesPerCharacter.Character`, containing identity (fullname, level, category, race, class, heroics), attribute values, talent point assignments, selected traits, equipped items cache, pets array, learned skills array, and learned spells array.
- **SpellsDatabase & SpellsPort**: Metadata storage in `src/main/domain/database/spells/` grouped by spell category (`arcane`, `chi`, `elemental`, `elune`, `fel`, `light`, `nature`, `necromantic`, `shadow`), exposed via getter functions in `SpellsPort.lua` (`getSpell(id)`, `getSpellsByCategory(category)`).
- **SkillsDatabase & SkillsPort**: Metadata storage in `src/main/domain/database/skills/` grouped by skill attribute category (`strength`, `dexterity`, `constitution`, `wisdom`, `charisma`), exposed via getter functions in `SkillsPort.lua` (`getSkill(id)`, `getSkillsByCategory(category)`).
- **HeroicCard**: Heroic action definition containing `id`, `name`, `type` (`active` | `passive`), `cooldown` (number), and `description`.
- **Pet**: Pet entity (`pets-types.ts`) containing `id`, `name`, `description`, `owner`, `level`, 7 core attribute values, array of learned `Spell` objects, and array of learned `Skill` objects.
- **Skill**: Skill metadata (`skills-spells-types.ts`) containing `id`, `name`, `description`, `turnCooldown`, `costActions`, `costSlots`, `turnEffects`, `type` (`active` | `passive`), and `category` (`strength` | `dexterity` | `constitution` | `wisdom` | `charisma`).
- **Spell**: Spell metadata (`skills-spells-types.ts`) containing `id`, `name`, `description`, `turnCooldown`, `costActions`, `costSlots`, `turnEffects`, `category` (`arcane` | `fel` | `nature` | `necromantic` | `shadow` | `light` | `elune` | `chi` | `elemental`), `spellType` (`cantrip` | `fast` | `basic` | `potent`), `type` (string school), `resourceCost`, `power`, `triggerOpportunityAttack`, and `isCanalizable`.
- **EquipmentSlotItem**: Item wrapper containing `id`, `name`, `icon`, `quality`, `description`, `tooltipLeft`, `tooltipRight`, requirements, penalties, and calculated damage ranges.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Minimap button position and window state persist across 100% of `/reload` and client disconnect events.
- **SC-002**: 100% of character edits (Identity, Attributes, Talents, Traits, Heroics, Pets, Skills, Spells) save persistently to `SavedVariablesPerCharacter.Character` without data loss.
- **SC-003**: 100% of spell JSON entries (305+ spells across 9 spell categories) and skill JSON entries (grouped across 5 attribute categories) are transpiled to pure Lua 5.1 database metadata tables in `src/main/domain/database/` with zero WoW client API calls.
- **SC-004**: `SpellsPort.lua` and `SkillsPort.lua` cover 100% of spell and skill categories, returning immutable data structures or `nil` for invalid queries.
- **SC-005**: Attribute and talent allocation limit checks evaluate in under 16ms, providing immediate visual feedback (red borders, yellow warning toasts) upon exceeding points budget.
- **SC-006**: TRP3 Extended inventory integration successfully populates equipment slots and calculates armor penalties/weapon damage ranges across all 7 equipment slots.
- **SC-007**: Skills and Spells catalogs filter 300+ spell entries and skill entries with 0 noticeable UI lag during search input or category/type dropdown toggles.
- **SC-008**: All newly created XML manifests (`spells.xml`, `skills.xml`, `database.xml`, `ports.xml`) resolve dependencies in strict bottom-up order with 0 global script loading errors.

---

## Assumptions

- **Persistence Storage**: `SavedVariablesPerCharacter.Character` is the authoritative per-character SavedVariables table registered in `GAC_DEV.toc`.
- **TRP3 Availability**: TRP3 Extended is an optional dependency; if missing, inventory slots gracefully fallback to empty state representations.
- **Data Source Parity**: Pre-populated spell JSON files and skill JSON files (`*skills.json`) in `specs/004-Character-Book/` provide authoritative content for domain metadata transpilation.
- **Pure Domain Boundary**: All domain calculations and metadata tables reside in `src/main/domain/` with zero WoW API references.
- **UI Autonomy**: The Character Book UI micro-frontend resides in `src/ui/characterBook/` and communicates strictly via feature APIs over `LocalIPCAdapter`.
