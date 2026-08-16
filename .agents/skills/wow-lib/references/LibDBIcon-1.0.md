# LibDBIcon-1.0

Allows addons to easily create a minimap icon from a DataBroker (LDB) object. It handles the rendering, dragging around the minimap, and saving the position into an AceDB-compatible database.

## Usage

```lua
local LDB = LibStub("LibDataBroker-1.1")
local icon = LibStub("LibDBIcon-1.0")

local myLDB = LDB:NewDataObject("MyAddon", {
    type = "launcher",
    text = "My Addon",
    icon = "Interface\\Icons\\inv_misc_questionmark",
    OnClick = function(self, button) print("Clicked!") end,
})

-- We need a place to save the minimap icon position
-- This table is usually saved in the addon's SavedVariables
local myMinimapDB = {
    hide = false,
    minimapPos = 220
}

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
    -- Register the icon with the LDB object and the saved variables table
    icon:Register("MyAddon", myLDB, myMinimapDB)
end)

-- To hide/show later:
-- icon:Hide("MyAddon")
-- icon:Show("MyAddon")
```
