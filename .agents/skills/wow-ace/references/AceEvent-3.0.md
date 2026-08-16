# AceEvent-3.0

Provides a wrapper for WoW's event system and a custom messaging system for intra-addon communication.

## Usage
```lua
local MyAddon = LibStub("AceAddon-3.0"):NewAddon("MyAddon", "AceEvent-3.0")

function MyAddon:OnEnable()
    -- Register WoW events
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("UNIT_AURA", "OnUnitAura") -- Maps to a specific function
    
    -- Register AceEvent custom messages
    self:RegisterMessage("MY_ADDON_CUSTOM_EVENT")
end

function MyAddon:PLAYER_REGEN_DISABLED(event)
    -- Handle event
end

function MyAddon:OnUnitAura(event, unit, ...)
    -- Handle event
end

function MyAddon:MY_ADDON_CUSTOM_EVENT(message, arg1, arg2)
    -- Handle custom message
end

-- Sending a custom message
function MyAddon:DoSomething()
    self:SendMessage("MY_ADDON_CUSTOM_EVENT", "hello", 123)
end
```
