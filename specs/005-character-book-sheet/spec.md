# Feature: CharacterBook UI - Basic Information

## 1. Context & Motivation
GAC requires a comprehensive Character Sheet interface for players to manage their roleplay progression and stats. This feature introduces the `CharacterBook` as an isolated UI feature, starting with a navigation bar and the foundational "Character" tab that manages basic demographic information.

## 2. Requirements

- **FR-1**: Create a new isolated UI feature `CharacterBook` conforming to the Feature-based architecture (`src/ui/CharacterBook/`).
- **FR-2**: Provide a top navigation bar containing a single link/tab: "Character", which opens the Character Sheet.
- **FR-3**: The Character Sheet must include placeholder sub-tabs for future expansion: Basic Information, Attributes, Talent Tree, Traits, Heroics, Spells, and Skills.
- **FR-4**: **Focus on Basic Information tab**:
  - Display "Character Name" and "Class", fetched directly from the user's TRP3 Profile via the `trp3-profile-api`.
  - Provide a "Category" dropdown and a "Level" dropdown. Options must be dynamically populated from `LevelDatabase.lua` through the API layer.
  - Provide a "Race" selector. Options must be dynamically populated from `RaceDatabase.lua` through the API layer.
  - Provide a "Worgen Curse" checkbox. Hovering over this checkbox must display a tooltip detailing the curse's statistical modifiers.
- **FR-5**: **Race Selection Logic**:
  - A character may select up to 2 races (Half-race).
  - If 1 race is selected: the Race's inherent advantages and disadvantages are displayed as read-only text.
  - If 2 races are selected: the user is presented with a selection UI to manually pick exactly +3 advantages and -3 disadvantages from the combined pool of both selected races.
- **NFR-1**: The UI must not directly query databases (`src/main/Models/`); it must call endpoints in `src/main/API/`.
- **NFR-2**: The UI layout must be encapsulated in `CharacterBookFrame.lua` without business logic.
- **NFR-3**: Data binding and TRP3 integration must be orchestrated through `CharacterBookController.lua` and `CharacterBookPresenter.lua`.

## 3. Interface & Contract Changes
- **New UI Feature**: `src/ui/CharacterBook/`
- **Required API Endpoints**:
  - `GAC_API.Levels.GetCategories()`
  - `GAC_API.Levels.GetLevelsByCategory(category)`
  - `GAC_API.Races.GetAllRaces()`
  - `GAC_API.Races.GetRaceTraits(raceID)`

## 4. Edge Cases & Failure Modes
- **TRP3 Missing**: If TRP3 is not installed or the player lacks a profile, the UI must gracefully fallback to WoW's default `UnitName("player")` and `UnitClass("player")`.
- **Invalid Half-Race Traits Selection**: The UI must enforce exactly +3 and -3 selections for dual races before allowing a save. Prevent saving if constraints aren't met.
- **Dynamic Dropdowns**: Changing "Category" must clear and refresh the "Level" dropdown to prevent invalid configurations (e.g. selecting "Boss" category but keeping a level that doesn't exist for Bosses).

## 5. Acceptance Criteria
- [ ] `CharacterBook` menu exists as a standalone UI feature.
- [ ] Navigation bar exists with "Character" tab.
- [ ] Basic Information tab loads Name and Class from TRP3.
- [ ] Category and Level dropdowns are populated via API.
- [ ] Race(s) can be selected via API.
- [ ] Single race correctly displays static traits.
- [ ] Dual race correctly allows exact +3/-3 trait selection.
- [ ] Worgen curse tooltip renders on hover.
