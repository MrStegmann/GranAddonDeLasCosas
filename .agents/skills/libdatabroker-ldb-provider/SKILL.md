---
name: libdatabroker-ldb-provider
description: Register data broker source objects for minimap icons, status bars, and launcher displays. Use when you are creating or updating a LibDataBroker data object for UI toggles, tooltip triggers, or status text displays.
---

# Skill: LibDataBroker LDB Provider

## Objective
Register a data broker source object using `LibDataBroker-1.1` to expose addon status, icons, launcher clicks, and tooltips to minimap containers and display bars.

## Documented Inputs
- **`dataObjectName`** (string): Unique identifier for the data broker launcher (e.g. `"GAC_DEV"`).
- **`iconTexture`** (string/number): Icon texture path or file ID (e.g. `"Interface\\Icons\\INV_Misc_Book_09"`).
- **`label`** (string): Display text string for launcher bars.

## Explicit and Verifiable Acceptance Criteria
- [ ] Data object registers successfully with type `"data source"` or `"launcher"`.
- [ ] `OnClick(frame, button)` callback fires reliably when clicked.
- [ ] `OnTooltipShow(tooltip)` callback populates tooltip text cleanly.

## How to Use & Examples

### Example: Creating a Character Book LDB Launcher Object
```lua
local LDB = LibStub("LibDataBroker-1.1")

local GAC_LDB = LDB:NewDataObject("GAC_DEV", {
    type = "launcher",
    text = "Character Book",
    icon = "Interface\\Icons\\INV_Misc_Book_09",
    OnClick = function(clickedFrame, button)
        if button == "LeftButton" then
            -- Toggle main Character Book frame
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine("GAC Character Book")
        tooltip:AddLine("|cff00ff00Left-Click:|r Toggle Character Book UI", 1, 1, 1)
    end
})
```
