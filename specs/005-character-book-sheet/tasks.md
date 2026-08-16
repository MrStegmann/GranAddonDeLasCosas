# Tasks: CharacterBook UI - Basic Information

- [x] **Phase 1: Contracts & Interfaces**
  - [x] Task 1.1: Verify/Create API endpoints for `LevelDatabase` (`GetCategories`, `GetLevelsByCategory`).
  - [x] Task 1.2: Verify/Create API endpoints for `RaceDatabase` (`GetAllRaces`, `GetRaceTraits`).
- [x] **Phase 2: Core UI Implementation**
  - [x] Task 2.1: Bootstrap `src/ui/CharacterBook/` folder structure (Frame, Presenter, Controller, index).
  - [x] Task 2.2: Build `CharacterBookFrame.lua` base layout and Navigation Bar.
  - [x] Task 2.3: Build Sub-Tabs (Basic Info, Attributes, etc.) in Frame.
  - [x] Task 2.4: Implement Basic Info UI components (Dropdowns for Category/Level/Race, Checkbox for Worgen Curse).
- [x] **Phase 3: Controller & Data Binding (Logic)**
  - [x] Task 3.1: Implement TRP3 integration in `CharacterBookController.lua` to fetch Name and Class.
  - [x] Task 3.2: Bind `LevelDatabase` API endpoints to Category and Level dropdowns.
  - [x] Task 3.3: Bind `RaceDatabase` API endpoints to Race dropdowns.
  - [x] Task 3.4: Implement single race vs. dual race (Half-race) trait logic and UI state.
  - [x] Task 3.5: Implement Worgen Curse tooltip logic.
- [x] **Phase 4: Integration & Polish**
  - [x] Task 4.1: Wire `CharacterBook/index.lua` to XML manifest (`src/ui/ui.xml`).
  - [x] Task 4.2: Update memory-bank and close feature.
