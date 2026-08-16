# Feature Specification: CharacterBook Minimap Button

**Feature Branch**: `006-character-book-minimapbutton`

**Created**: 2026-08-16

**Status**: Draft

**Input**: User description: "Create inside CharacterBook a minimap button that allow opens AND close the CharacterBook menu."

## 1. Context & Motivation
Players need a convenient, accessible way to open and close the CharacterBook UI without relying exclusively on slash commands or macros. A standard minimap button provides immediate discoverability and a familiar UX for World of Warcraft addons.

## 2. Requirements

- **FR-1**: Create a DataBroker (LDB) object for the GAC addon.
- **FR-2**: Register a Minimap Icon using `LibDBIcon-1.0` tied to the GAC DataBroker object.
- **FR-3**: The minimap button must allow the user to click it to toggle (open/close) the `CharacterBook` UI frame.
- **FR-4**: The minimap button's dragged position (angle/radius) must persist between sessions by saving its state to `_G.GAC_CharacterDB.minimap`.
- **NFR-1**: The minimap button logic must reside as a component of the CharacterBook feature, e.g., `src/ui/CharacterBook/Components/MinimapButton.lua`.
- **NFR-2**: Initialization of the minimap button must safely wait until `ADDON_LOADED` or `PLAYER_LOGIN` to ensure `GAC_CharacterDB` is fully hydrated from SavedVariables.

## 3. Interface & Contract Changes
- **Database Schema**: `_G.GAC_CharacterDB.minimap` will be added to the character database to store the `hide` and `minimapPos` keys required by `LibDBIcon-1.0`.
- **New UI Component**: `src/ui/CharacterBook/Components/MinimapButton.lua`

## 4. Edge Cases & Failure Modes
- **Library Missing**: If `LibDataBroker-1.1` or `LibDBIcon-1.0` fails to load, the script must gracefully abort registering the minimap icon instead of throwing Lua errors.
- **Database Uninitialized**: If the minimap registers before the saved variables load, the position will reset. We must ensure registration happens *after* `ADDON_LOADED` for the addon itself.

## 5. Acceptance Criteria
- [ ] A minimap button with a placeholder/default icon appears around the minimap.
- [ ] Left-clicking the button toggles the `CharacterBook` frame visibility.
- [ ] Hovering over the button displays a tooltip (e.g., "GAC - Character Book").
- [ ] Dragging the minimap button around the minimap and reloading the UI (`/reload`) successfully persists the button's position.
