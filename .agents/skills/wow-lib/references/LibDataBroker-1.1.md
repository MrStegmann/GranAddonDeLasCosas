# LibDataBroker-1.1

A small WoW library providing an MVC-like pattern for sharing data between addons. "Data providers" (plugins) expose data (text, icons, tooltips) that "Display addons" (like Titan Panel, ChocolateBar, or Minimap icon libraries) can display.

## Usage

### Creating a Data Object (Provider)
```lua
local ldb = LibStub:GetLibrary("LibDataBroker-1.1")

local myDataObject = ldb:NewDataObject("MyAddonName", {
    type = "data source",
    text = "My Addon text",
    icon = "Interface\\Icons\\inv_misc_questionmark",
    
    OnClick = function(self, button)
        if button == "LeftButton" then
            print("Clicked!")
        end
    end,
    
    OnTooltipShow = function(tooltip)
        tooltip:AddLine("My Addon")
        tooltip:AddLine("Click for awesomeness.")
    end
})

-- Later, update the text to inform displays that data changed
myDataObject.text = "New text!"
```
