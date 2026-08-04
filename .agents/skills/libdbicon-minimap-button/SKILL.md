---
name: libdbicon-minimap-button
description: Manage a draggable minimap button icon with position persistence in SavedVariables. Use when you are creating new minimap button icons, binding LibDataBroker sources to minimap frames, or managing minimap button visibility.
---

# Skill: LibDBIcon Minimap Button

## Objective
Create, display, and manage a circular draggable minimap button bound to a `LibDataBroker-1.1` object using `LibDBIcon-1.0`, saving coordinates persistently in `SavedVariablesPerCharacter`.

## Documented Inputs
- **`iconName`** (string): Unique identifier for the minimap icon (e.g. `"GAC_DEV"`).
- **`ldbObject`** (table): The registered LibDataBroker source table.
- **`dbTable`** (table): SavedVariables sub-table storing icon preferences (e.g. `{ minimapPos = 220, hide = false }`).

## Explicit and Verifiable Acceptance Criteria
- [ ] Minimap button renders on the minimap ring with the designated icon texture.
- [ ] Dragging the icon around the minimap updates `dbTable.minimapPos` dynamically.
- [ ] Button coordinates and visibility state persist across `/reload` and relogging events.

## How to Use & Examples

### Example: Registering Draggable Minimap Icon
```lua
local LDB = LibStub("LibDataBroker-1.1")
local Icon = LibStub("LibDBIcon-1.0")

local GAC_LDB = LDB:NewDataObject("GAC_DEV", {
    type = "launcher",
    text = "Character Book",
    icon = "Interface\\Icons\\INV_Misc_Book_09",
    OnClick = function(self, button)
        -- Toggle Character Book UI
    end
})

function SetupMinimapButton(dbCharSettings)
    -- dbCharSettings.minimap = { minimapPos = 180, hide = false }
    Icon:Register("GAC_DEV", GAC_LDB, dbCharSettings.minimap)
end
```
