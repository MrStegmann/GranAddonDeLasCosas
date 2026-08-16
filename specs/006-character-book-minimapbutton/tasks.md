# Tasks: CharacterBook Minimap Button

- [x] **Phase 1: Persistence Setup**
  - [x] Task 1.1: Update `src/main/Controllers/events/AddonLoadedHandler.lua` to ensure `_G.GAC_CharacterDB.minimap` is instantiated.
- [/] **Phase 2: Minimap UI Component**
  - [ ] Task 2.1: Create `src/ui/CharacterBook/Components/MinimapButton.lua`.
  - [ ] Task 2.2: Implement `LibDataBroker-1.1` object creation in `MinimapButton.lua` with `OnClick` and `OnTooltipShow` handlers.
  - [ ] Task 2.3: Implement `LibDBIcon-1.0` registration using the LDB object and the `GAC_CharacterDB.minimap` table.
- [x] **Phase 3: Integration & Polish**
  - [x] Task 3.1: Wire `MinimapButton.lua` to be initialized inside `CharacterBook/index.lua` or directly in `CharacterBook.xml`.
  - [x] Task 3.2: Verify load order dependencies in `CharacterBook.xml`.
  - [x] Task 3.3: Update memory-bank and close feature.
