---
name: acegui-widgets-and-modals
description: Build dynamic UI modal dialogs, edit forms, dropdowns, and popup frames. Use when you are building dynamic modal dialogs, edit confirmation popups, dropdown pickers, or secondary option windows.
---

# Skill: AceGUI Widgets & Modals

## Objective
Create dynamic modal dialogs, edit popups, and dynamic container controls using component widgets provided by `AceGUI-3.0`.

## Documented Inputs
- **`widgetType`** (string): Type of widget to instantiate (e.g. `"Frame"`, `"Dropdown"`, `"Button"`, `"EditBox"`).
- **`layoutType`** (string): Container layout type (`"Fill"`, `"Flow"`, `"List"`).
- **`title`** (string): Title string for window containers.

## Explicit and Verifiable Acceptance Criteria
- [ ] Widget creates and mounts cleanly over parent UI viewport.
- [ ] Callbacks (`OnClick`, `OnValueChanged`, `OnEnterPressed`) fire reliably.
- [ ] Window releases resources cleanly upon closing via `AceGUI:Release(container)`.

## How to Use & Examples

### Example: Creating an Edit Modal Confirmation Dialog
```lua
local AceGUI = LibStub("AceGUI-3.0")

function OpenHeroicCardModal(onConfirmCallback)
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("Add Heroic Card")
    frame:SetWidth(400)
    frame:SetHeight(300)
    frame:SetLayout("Flow")

    local nameInput = AceGUI:Create("EditBox")
    nameInput:SetLabel("Card Name:")
    nameInput:SetFullWidth(true)
    frame:AddChild(nameInput)

    local confirmBtn = AceGUI:Create("Button")
    confirmBtn:SetText("Save Card")
    confirmBtn:SetCallback("OnClick", function()
        local cardName = nameInput:GetText()
        if cardName and cardName ~= "" then
            onConfirmCallback(cardName)
            AceGUI:Release(frame)
        end
    end)
    frame:AddChild(confirmBtn)
end
```
