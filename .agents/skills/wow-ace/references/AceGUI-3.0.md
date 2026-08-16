# AceGUI-3.0

A widget-based GUI library for creating configuration windows, frames, buttons, checkboxes, etc., without manually dealing with XML or `CreateFrame` layout math.

## Usage
```lua
local AceGUI = LibStub("AceGUI-3.0")

local function CreateUI()
    -- Create a frame
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("My Addon Options")
    frame:SetStatusText("Status Bar")
    frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    frame:SetLayout("Flow")
    
    -- Create a button
    local btn = AceGUI:Create("Button")
    btn:SetText("Click Me!")
    btn:SetWidth(200)
    btn:SetCallback("OnClick", function() print("Clicked!") end)
    
    -- Add the button to the frame
    frame:AddChild(btn)
end
```
