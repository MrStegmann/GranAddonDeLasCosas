# Feature Brief: Character Book UI & Systems

## System Overview & Specifications

* **Frame Dimensions:** 50% Viewport Width $\times$ 65% Viewport Height
* **Global Persistent Storage Key:** `SavedVariablesPerCharacter.Character` (On-disk persistent storage managed via `SavedVarsStorageAdapter`)
* **Session Runtime Cache:** In-memory character model instance cached during the active session in `CharacterCacheAdapter` to ensure zero-latency UI reads and updates.
* **Layout Structure:** Two-column split layout (Left: Navigation Sidebar | Right: Content Container)
* **Architectural Boundaries & IPC Isolation:** UI micro-frontends MUST NOT call backend `src/main/` domain/adapter functions directly nor listen to raw WoW engine events (`OnEvent`). All data reads, mutations, and backend signals MUST route strictly through feature-scoped local API bridges (`src/ui/[feature]/api/[feature]Api.lua`) via the decoupled IPC bus (`LocalIPCAdapter`).
* **Isolated Tab Persistence:** Every tab operates as an isolated sub-domain transaction. Saving edits within a specific tab commits changes ONLY to that tab's mapped properties in the `Character` domain model (e.g., `race` in `Personaje`, `attributes`/`talents` in `Atributos`, `positiveTraits`/`negativeTraits` in `Rasgos`, `heroics` in `Heroicas`, `skills`/`spells` in `Hechizos y Habilidades`) without altering, overwriting, or resetting data in other tabs.

---

## Feature 0: Component Architecture

### Minimap Anchor Button

* **Icon:** Book emblem texture
* **Behavior:** Free-form drag-and-drop around the minimap perimeter
* **Persistence:** Saves relative coordinates to `SavedVariablesPerCharacter.MinimapPos` on drag release
* **Trigger:** Left-click toggles Main Frame visibility via `SheetAPI.toggleVisibility()`

### Main Frame Navigation Sidebar

* **Index Options:** `Character` (Single fixed sidebar option)

**Wireframe & Layout Structure:**

```
--------------------------------------------------------------------------------------------------|x|
|   -------------------------- -------------------------------------------------------------------- |
|   |  [+] CharName            |  |                                                                 |
|   |                          |  |                                                                 |
|   |                          |  |                                                                 |
|   |                          |  |                                                                 |
|   |                          |  |                                                                 |
|   |                          |  |                       Content Area                              |
|   |                          |  |                                                                 |
|   |                          |  |                                                                 |
|   |                          |  |                                                                 |
|   -------------------------- -------------------------------------------------------------------  |
----------------------------------------------------------------------------------------------------
```

---

## Detailed Feature Specifications

### Feature 1: Character Creation & Sheet Navigation

**Initial State (No Sheet Created):**

* Selecting **Character** from the sidebar when `SavedVariablesPerCharacter.Character` is empty displays a centered `[Create Sheet]` button inside the content container.
* Clicking `[Create Sheet]` initializes a blank domain model instance using `src/main/domain/models/Character.lua` (`Character.createDefault()`) and opens the character editor directly in **Edit Mode** with top tab navigation.

**Tab Navigation Bar:**
Located at the top of the content container during creation/editing:
`[ Personaje ]` | `[ Atributos ]` | `[ Rasgos ]` | `[ Heroicas ]` | `[ Hechizos y Habilidades ]`

**Global Action Controls:**

* **Position:** Fixed at the **Top-Right** / **Bottom-Center** of the content container during edit mode.
* **Controls:** `[Save]` and `[Cancel]` buttons.
* **Behavior:** `[Save]` dispatches pending changes for the active tab via its local feature API client (`src/ui/[feature]/api/[feature]Api.lua`), updating the session cache and `SavedVariablesPerCharacter.Character`. `[Cancel]` discards pending changes for the current tab and reverts to the previously saved state. Switching tabs with unsaved changes prompts a confirmation dialog or auto-reverts pending tab edits.

---

### Feature 2: Character Information Tab (`Personaje`)

**Domain Model Alignment:** `src/main/domain/models/Character.lua` (`fullName`, `class`, `category`, `level`, `race`, `isWorgen`)

**Data Integration & Sources:**

* **Character Fullname:** Auto-populated from TotalRP3 via `TRP3Adapter.getFullName()`. Mapped to `Character.fullName`.
* **Class:** Auto-populated from TotalRP3 via `TRP3Adapter.getClass()`. Mapped to `Character.class`.
* **Dynamic Database:** Baseline statistical grid preview pulled dynamically from `src/main/domain/database/LevelDatabase.lua`.

**State & Validation Rules:**

* **Top-Right Action Button:** Toggles between `[ Edit ]` mode and `[ Save ]` / `[ Cancel ]` controls.
* **Validation Rule 1 (Level):** Level selector dropdown dynamically populates based on the chosen category:
  * `noob`: Level 1 to 5.
  * `normal`: Level 1 to 10.
  Changing category resets Level to 1 if current level exceeds target category max.
* **Validation Rule 2 (Category):** Must be selected from valid categories (`noob`, `normal`). Mapped to `Character.category`.

**Dual-Race Selection (Mestizo) & Special Traits:**

* **Main & Secondary Race:** Selection of `race.main` (string) and optional `race.secondary` (string).
* **Race Advantages & Disadvantages:** When `race.secondary` is selected, the **Race Advantages** (+3 points required) and **Race Disadvantages** (-3 points required) containers merge available options from both races. Allocated race talent points are stored in `Character.race.talents`.
* **Special Traits Unification:** Unique passive **Special Race Traits** from both selected races are automatically aggregated and listed in read-only mode without manual allocation.

**Level Statistics Display Grid:**
Displays dynamic preview values from `LevelDatabase.lua` corresponding to selected `category` and `level`:
`maxHealth`, `expToLevel`, `attPoints`, `skillPoints`, `heroicPoints`, `maxPositiveTraits`.

**Isolated Tab Persistence & API:**
Saving in `Personaje` tab dispatches `SheetAPI.saveCharacterInfo(infoData)` over IPC, updating only `fullName`, `class`, `category`, `level`, `race`, and `isWorgen` in `Character` domain model and session memory.

**Wireframe & Layout Structure (Content Area):**

```
----------------------------------------------------------------------------------------- |
----------------------------------------------------------------------------------------- |
| [ CharTab ]  [ AttTab ]  [ TraitsTab ] [ Heroics ] [ Skills & Spells ]                  |
----------------------------------------------------------------------------------------- |
| Character Fullname (Fetched via TRP3)              [ Edit ] / [ Save ]  [ Cancel ]    | |
| ------------------------------------------------------------------------------------- | |
| [Category Selector] - [Level Selector] - [Race 1 Selector] / [Race 2] - Class (TRP3)  | |
| ------------------------------------------------------------------------------------- | |
| |--- Race Advantages --------------|   |--- Race Disadvantages --------------|        | |
| | - +1 Talent Name                 |   | - -1 Talent Name                    |        | |
| |----------------------------------|   |-------------------------------------|        | |
| ------------------------------------------------------------------------------------- | |
| | Special Race Traits                                                               | | |
| | SuperStrength, Regeneration                                                       | | |
| ------------------------------------------------------------------------------------- | |
| | Level Resume                                                                      | | |
| |-----------------------------------------------------------------------------------| | |
| | maxHealth: 20  | EXP needed to next level: 30 | Attribute Points: 5               | | |
| | Skill/Spell points: 5 | Heroic Points: 2     | Positive Traits Points: 2          | | |
----------------------------------------------------------------------------------------- |
----------------------------------------------------------------------------------------- |
```

---

### Feature 3: Attributes Tab (`Atributos`)

**Domain Model Alignment:** `src/main/domain/models/Character.lua` (`Character.attributes`, `Character.talents`)

**Data Sources:** `src/main/domain/database/AttributesTalentsDatabase.lua` & `src/main/domain/database/LevelDatabase.lua`

**Layout:** 2-Column Grid of Attribute Cards (`Strength`, `Dexterity`, `Constitution`, `Intelligence`, `Willpower`, `Wisdom`, `Charisma`).

**Card Structure:**

* **Header:** Attribute Name, Base Value input/display (`Character.attributes[attrKey]`), Calculated Talent Points balance ($\text{Max Talent Points} = \text{Attribute Value} \times 2$).
* **Body:** List of assigned talents for that attribute tree from `AttributesTalentsDatabase.lua`, displaying point inputs per talent item (`Character.talents[attrKey][talentKey]`).

**Edit & Validation Logic:**

* **Top-Right Action Button:** Toggles `[ Edit ]` mode $\rightarrow$ `[ Save ]` / `[ Cancel ]`.
* **Validation Rule 1 (Attribute Points):** Sum of assigned attribute points cannot exceed available `attPoints` provided by selected Category + Level in `LevelDatabase.lua`:
  $$\sum_{\text{attr}} \text{attributes}[\text{attr}] \le \text{attPoints}$$
* **Validation Rule 2 (Talent Points):** Sum of talent points allocated within an attribute tree cannot exceed $\text{Attribute Value} \times 2$:
  $$\sum_{\text{talent}} \text{talents}[A][\text{talent}] \le \text{attributes}[A] \times 2$$
* **Error Handling & Visual Feedback:**
  * Over-allocation triggers a yellow warning toast at Top-Center: *"Attribute/Talent point limit reached."*
  * Over-allocated attribute headers display red text styling.
  * Exceeded talent allocations apply a red border to the entire Attribute Card and highlight invalid talent values in red.

**Isolated Tab Persistence & API:**
Saving dispatches `AttributesAPI.saveAttributes(attributesData, talentsData)` over IPC, updating strictly `Character.attributes` and `Character.talents` in session cache and disk.

**Wireframe & Layout Structure (Content Area):**

```
----------------------------------------------------------------------------------------- |
----------------------------------------------------------------------------------------- |
| [ CharTab ]  [ AttTab ]  [ TraitsTab ] [ Heroics ] [ Skills & Spells ]                  |
----------------------------------------------------------------------------------------- |
|                                                              [Edit] / [Save]  [Cancel]  |
|     --------------------------------------------------------------------------------    |
|     | Warning: You don't have enough Attribute/Talent points to spend               |   |
|     --------------------------------------------------------------------------------    |
|                                 Attributes Points remain/max                            |               
|      -------------------------------------      --------------------------------------| |
|     | Strength               value/input  |    | Constitution            value/input  | |
|     |-------------------------------------|    |--------------------------------------| |
|     |       Talents remain/max            |    |       Talents remain/max             | |
|     |  Talent1               value/input  |    |  Talent1                value/input  | |
|     |  Talent2               value/input  |    |  Talent2                value/input  | |
|     |-------------------------------------|    |--------------------------------------| |
|     | Intelligence          value/input   |    | Dexterity              value/input   | |
|     |-------------------------------------|    |--------------------------------------| |
|     |       Talents remain/max            |    |       Talents remain/max             | |
|     |  Talent1               value/input  |    |  Talent1                value/input  | |
|     |  Talent2               value/input  |    |  Talent2                value/input  | |
|     |-------------------------------------|    |--------------------------------------| |
|     | Willpower           value/input     |    | Wisdom               value/input     | |
|     |-------------------------------------|    |--------------------------------------| |
|     |       Talents remain/max            |    |       Talents remain/max             | |
|     |  Talent1               value/input  |    |  Talent1                value/input  | |
|     |  Talent2               value/input  |    |  Talent2                value/input  | |
|     |-------------------------------------|    |--------------------------------------| |
|     | Charisma            value/input     |                                             |
|     |-------------------------------------|                                             |
|     |       Talents remain/max            |                                             |
|     |  Talent1               value/input  |                                             |
|     |  Talent2               value/input  |                                             |
|     |-------------------------------------|                                             |
----------------------------------------------------------------------------------------- |
----------------------------------------------------------------------------------------- |
```

---

### Feature 4: Traits Tab (`Rasgos`)

**Domain Model Alignment:** `src/main/domain/models/Character.lua` (`Character.positiveTraits`, `Character.negativeTraits`)

**Layout:** 1-Column Vertical Stack

**Section Hierarchy:**

1. **Positive Traits:** List of selected positive traits (Displays empty state if zero allocated).
2. **Negative Traits:** List of selected negative traits (Displays empty state if zero allocated).

**Edit & Validation Logic:**

* **Top-Right Action Button:** Toggles `[ Edit ]` mode $\rightarrow$ `[ Save ]` / `[ Cancel ]`.
* **Validation Rule 1 (Positive Traits):** Sum of positive traits points cannot exceed `maxPositiveTraits` from `LevelDatabase.lua`:
  $$\sum \text{positiveTraits} \le \text{maxPositiveTraits}$$
* **Validation Rule 2 (Negative Traits):** Sum of negative traits points must satisfy minimum category bounds:
  * `noob`: $\ge 1$
  * `normal`, `elite`, `boss`: $\ge 2$
* **Error Handling & Visual Feedback:**
  * Over-allocation or missing required negative traits triggers a yellow warning toast at Top-Center: *"Trait point limit reached or minimum negative traits missing."*
  * Trait sections violating rules display red section borders and text highlights on invalid trait items.

**Isolated Tab Persistence & API:**
Saving dispatches `TraitsAPI.saveTraits(positiveTraits, negativeTraits)` over IPC, updating strictly `Character.positiveTraits` and `Character.negativeTraits` in session cache and disk.

**Wireframe & Layout Structure (Content Area):**

```
----------------------------------------------------------------------------------------- |
----------------------------------------------------------------------------------------- |
| [ CharTab ]  [ AttTab ]  [ TraitsTab ] [ Heroics ] [ Skills & Spells ]                  |
----------------------------------------------------------------------------------------- |
|                                                              [Edit] / [Save]  [Cancel]  |
|     --------------------------------------------------------------------------------    |
|     | Warning: You don't have enough positive traits points to spend                |   |
|     --------------------------------------------------------------------------------    |
|                                 Positive Traits Points remain/max                       |               
|      ---------------------------------------------------------------------------------| |
|     | Positive Traits                                                 Total/Max       | |
|     |---------------------------------------------------------------------------------| |
|     |   Trait Name                                                                    | |
|     |---------------------------------------------------------------------------------| |
|     |   Trait Description                                                             | |
|     |---------------------------------------------------------------------------------| |
|     | [ ] Level 1 - LevelValue  | [ ] Level 2 - LevelValue  | [ ] Level 3 - LevelValue| |
|     |---------------------------------------------------------------------------------| |
|                                                                                         |               
|     |---------------------------------------------------------------------------------| |
|     | Negative Traits                                                 Total/Min       | |
|     |---------------------------------------------------------------------------------| |
|     |   Trait Name                                                                    | |
|     |---------------------------------------------------------------------------------| |
|     |   Trait Description                                                             | |
|     |---------------------------------------------------------------------------------| |
|     | [ ] Level 1 - LevelValue  | [ ] Level 2 - LevelValue  | [ ] Level 3 - LevelValue| |
|     |---------------------------------------------------------------------------------| |
----------------------------------------------------------------------------------------- |
----------------------------------------------------------------------------------------- |
```

---

### Feature 5: Heroics Tab (`Heroicas`)

**Overview & Purpose:**
The Heroics tab allows players to author and manage custom narrative capabilities called **Heroics**. Characters do not possess default Heroics; players create them dynamically using allocated **Heroic Points** (`heroicPoints`) sourced from `src/main/domain/database/LevelDatabase.lua`.

**Currency & Cost Mechanics:**

* **Currency Key:** `heroicPoints` (Total available based on `category` and `level` in `LevelDatabase.lua`).
* **Cost Rule:** Each created Heroic entry consumes 1 Heroic Point per `version` rank. Total allocated points across heroics must not exceed available `heroicPoints`:
  $$\sum_{\text{heroic}} \text{heroic.version} \le \text{heroicPoints}$$

**Domain Model Alignment:** `src/main/domain/models/Heroic.lua`

* `id`: string (unique identifier `heroic_<timestamp>_<rand>`)
* `name`: string (Heroic title)
* `type`: `'active'` | `'passive'` (string enum)
* `description`: string (narrative detail and mechanics)
* `version`: number (integer $\ge 1$, increments when updated)
* `actionCost`: number (integer $\ge 0$, offensive/defensive action point cost)
* `effectTurns`: number (integer $\ge 0$, turn duration of effect)
* `cooldownTurns`: number (integer $\ge 1$ for active, 0 for passive)

**UI Layout & Interaction Components:**

1. **Header Banner & Action Control:**
   * **Points Summary:** Displays `Heroic Points: Allocated / Total` at top-left.
   * **Create Heroic Button:** A centered action button `[ + Create Heroic ]` positioned at the top of the content area.
   * Clicking `[ + Create Heroic ]` opens the **HeroicForm** interface in creation mode.

2. **Heroic Form (`HeroicForm` Component):**
   * Pushes the vertical list of Heroic cards downward when expanded.
   * **Input Fields:**
     * `Name`: Text input (string).
     * `Type Selector`: Dropdown / Segmented button (`[ Active ]` | `[ Passive ]`).
     * `Action Cost`: Integer input ($\ge 0$).
     * `Effect Turns`: Integer input ($\ge 0$).
     * `Cooldown Turns`: Integer input (min 1 for active).
     * `Description`: Multiline text box.
     * `Version Indicator`: Numeric display (Starts at `1` for new creations; increments on edit).
   * **Controls:** `[ Save Heroic ]` and `[ Cancel ]`.
   * **Validation:** If total `version` cost exceeds `heroicPoints`, saving is blocked and a yellow top-center warning toast appears: *"Insufficient Heroic Points to save/upgrade Heroic."*

3. **Heroic Card (`HeroicCard` Component):**
   * Rendered in a 1-column vertical list sorted by creation order.
   * **Header (Row 1):** Heroic `Name` (Left) | `Type` badge (`[Active]` / `[Passive]`) (Right).
   * **Sub-Header (Row 2):** `Action Cost` | `Effect Turns` | `Cooldown Turns` | `Version`.
   * **Body:** Multi-line `Description` text.
   * **Footer Controls:** `[ Edit ]` and `[ Delete ]` buttons.

4. **Inline Edit Mutation:**
   * Clicking `[ Edit ]` on a `HeroicCard` mutates that card inline into an active `HeroicForm` populated with existing data.
   * Action buttons toggle to `[ Save Heroic ]` and `[ Cancel ]`.
   * Saving an edit increments `version` by +1 (consuming 1 additional Heroic Point).

5. **Deletion Confirmation Modal:**
   * Clicking `[ Delete ]` on a card opens a modal overlay window asking:
     *"Are you sure you want to delete this Heroic? This action cannot be undone."*
   * Controls: `[ Confirm Delete ]` | `[ Cancel ]`.
   * Confirming deletion removes the entry from `Character.heroics`, refunds spent `heroicPoints`, and updates session cache & disk persistence.

**Isolated Tab Persistence & API:**
All Heroic mutations execute via `HeroicsAPI.lua` over IPC (`HeroicsAPI.saveHeroic(heroicData)`, `HeroicsAPI.deleteHeroic(heroicId)`), updating strictly `Character.heroics` in session cache and `SavedVariablesPerCharacter.Character`.

---

**Wireframe 1: Heroics Tab Main View & Heroic Cards List**

```
----------------------------------------------------------------------------------------- |
----------------------------------------------------------------------------------------- |
| [ CharTab ]  [ AttTab ]  [ TraitsTab ] [ Heroics ] [ Skills & Spells ]                  |
----------------------------------------------------------------------------------------- |
| Heroic Points: 1/2 Used                                                                 |
|                                [ + Create Heroic ]                                      |
|     --------------------------------------------------------------------------------    |
|     |  Heroic Card #1                                                    [ Active ]|    |
|     |  Cost: 1 Action | Duration: 2 Turns | Cooldown: 3 Turns | Version: 1         |    |
|     |------------------------------------------------------------------------------|    |
|     |  Description: Performs a swift leap toward an ally, granting them a shield   |    |
|     |  equal to Constitution for 2 turns.                                          |    |
|     |------------------------------------------------------------------------------|    |
|     |                                                        [ Edit ]  [ Delete ]  |    |
|     --------------------------------------------------------------------------------    |
----------------------------------------------------------------------------------------- |
----------------------------------------------------------------------------------------- |
```

---

**Wireframe 2: Heroic Form View (Create / Edit Inline Mode)**

```
----------------------------------------------------------------------------------------- |
----------------------------------------------------------------------------------------- |
| [ CharTab ]  [ AttTab ]  [ TraitsTab ] [ Heroics ] [ Skills & Spells ]                  |
----------------------------------------------------------------------------------------- |
| Heroic Points: 1/2 Used                                                                 |
|     ======================== HEROIC FORM ==========================================     |
|     | Name: [ Input Heroic Title...                                             ] |     |
|     | Type: [ Active v ] | Action Cost: [ 1 ] | Turns: [ 2 ] | Cooldown: [ 3 ]    |     |
|     | Version: 1 (Cost: 1 Point)                                                  |     |
|     | Description:                                                                |     |
|     | [ Multiline text input for heroic mechanics...                            ] |     |
|     |                                              [ Save Heroic ]  [ Cancel ]    |     |
|     ===============================================================================     |
|     --------------------------------------------------------------------------------    |
|     |  Heroic Card #1 (Pushed down when form is active)                  [ Active ] |   |
|     --------------------------------------------------------------------------------    |
----------------------------------------------------------------------------------------- |
----------------------------------------------------------------------------------------- |
```

---

**Wireframe 3: Delete Confirmation Modal Window**

```
================================== DELETE CONFIRMATION ==================================
|                                                                                       |
|   Are you sure you want to delete this Heroic?                                        |
|   This action cannot be undone. Spent Heroic Points will be refunded.                 |
|                                                                                       |
|                                            [ Confirm Delete ]   [ Cancel ]            |
|                                                                                       |
=========================================================================================
```

---

### Feature 6: Skills & Spells Tab (`Hechizos y Habilidades`)

**Data Sources:** `src/main/domain/database/SkillsDatabase.lua` & `src/main/domain/database/SpellsDatabase.lua`

**Domain Model Alignment:** `src/main/domain/models/Skill.lua` & `src/main/domain/models/Spell.lua` stored in `Character.skills` and `Character.spells`.

**Currency:** Shared point pool (`skillPoints`) from `src/main/domain/database/LevelDatabase.lua`.

**Layout:** Grid of empty/allocated skill and spell slots divided into two distinct sections (**Skills** vs. **Spells**).

**Selection Flow & Modal Directory:**

1. Clicking an empty slot opens the **Selection Modal** prompting choice: `[ Skills ]` or `[ Spells ]`.
2. **Skills Directory View:**
   * **Filters:** Search Input, Attribute Category (`Strength`, `Dexterity`, `Constitution`, `Wisdom`, `Charisma`), Slot Cost, Type (`Active`/`Passive`).
   * **List Entry (SkillCard):** Header (`Name`, `Turns`, `Cooldown`, `Type`), Body (`Description`), Cost preview (`slotCost`).
3. **Spells Directory View:**
   * **Filters:** Search Input, Magic Category (`Arcane`, `Fel`, `Nature`, `Necromantic`, `Shadows`, `Light`, `Elune`, `Chi`, `Elemental`), Spell Tier (`Cantrip`, `Fast`, `Basic`, `Potent`), Slot Cost.
   * **List Entry (SpellCard):** Header (`Name`, `Power`, `Turns`, `Cooldown`, `Type`), Body (`Description`), Cost preview (`slotCost`).

**State & Visual Rules:**

* **Learned Items:** Rendered at **50% Opacity** and non-selectable (*"Already Learned"*).
* **Active Selection:** Highlighted with a **Gold Border** exposing a `[ Learn ]` button.
* **Affordability Lockout:** Items with `slotCost` exceeding the character's remaining `skillPoints` balance are disabled with **75% Opacity** (*"Insufficient Points"*).
* **Status Display:** Current available `skillPoints` balance is persistently displayed in the tab header and selection modal header.

**Isolated Tab Persistence & API:**
Saving dispatches `SkillsSpellsAPI.saveSkillsSpells(skillsList, spellsList)` over IPC, updating strictly `Character.skills` and `Character.spells` in session cache and persistent disk storage.

**Wireframe & Layout Structure (Content Area):**

```
----------------------------------------------------------------------------------------- |
----------------------------------------------------------------------------------------- |
| [ CharTab ]  [ AttTab ]  [ TraitsTab ] [ Heroics ] [ Skills & Spells ]                  |
----------------------------------------------------------------------------------------- |
| Skill/Spell Points: 5/5                                      [Edit] / [Save]  [Cancel]  |
|     --------------------------------------------------------------------------------    |
|     | Warning: You don't have enough Skill/Spell points to spend                   |    |
|     --------------------------------------------------------------------------------    |
|                                                                                         |
|  [=== SKILLS =========================================================================] |
|  | [ Slot 1 ]             | [ Slot 2 ]             | [ Slot 3 ]                       | |
|  | Skill Name             | Skill Name             | + Add Skill                      | |
|  | Cost: 1 | Type: Active | Cost: 2 | Type: Passive|                                  | |
|  | [X] Remove             | [X] Remove             |                                  | |
|  -------------------------------------------------------------------------------------- |
|                                                                                         |
|  [=== SPELLS =========================================================================] |
|  | [ Slot 1 ]             | [ Slot 2 ]             | [ Slot 3 ]                       | |
|  | Spell Name             | + Add Spell            | Empty                            | |
|  | Cost: 2 | Tier: Fast   |                        |                                  | |
|  | [X] Remove             |                        |                                  | |
|  -------------------------------------------------------------------------------------- |
|                                                                                         |
| ================================= SELECTION MODAL ====================================  |
| | [ Modal Title: Select Entry ]                                                 [ X ] | |
| | Points Available: 5                                                                 | |
| | ----------------------------------------------------------------------------------- | |
| | Search: [ Input... ] | Category: [ All v ] | Tier/Type: [ All v ] | Cost: [ All v ] | |
| | ----------------------------------------------------------------------------------- | |
| |  ---------------------------------------------------------------------------------  | |
| |  | Name: Power Slash (Cost: 1)                     Turns: Instant | Cooldown: 2   | | |
| |  | Type: Active | Category: Strength                                              | | |
| |  | Description: Deals weapon damage to a target enemy.                            | | |
| |  |                                                            [ Learn ]           | | |
| |  ---------------------------------------------------------------------------------  | |
| |  | Name: Fireball (Cost: 2)                        Turns: 1 | Cooldown: 3         | | |
| |  | Type: Active | Category: Arcane | Tier: Basic                                  | | |
| |  | Description: Launches a flare of fire (Learned)                                | | |
| |  | Status: [ 50% Opacity - Already Learned ]                                      | | |
| |  ---------------------------------------------------------------------------------  | |
| |  | Name: Meteor Shower (Cost: 8)                   Turns: 2 | Cooldown: 5         | | | 
| |  | Type: Active | Category: Arcane | Tier: Potent                                 | | | 
| |  | Description: Calls down massive meteors over a wide area.                      | | |
| |  | Status: [ 75% Opacity - Insufficient Points ]                                  | | |
| |  ---------------------------------------------------------------------------------  | |
| ======================================================================================= |
----------------------------------------------------------------------------------------- |
----------------------------------------------------------------------------------------- |
```