# AceAddon-3.0

Provides a template for creating addon objects. It handles the initialization and enabling phases of the addon lifecycle, and allows embedding other Ace3 libraries (mixins).

## Usage
```lua
local MyAddon = LibStub("AceAddon-3.0"):NewAddon("MyAddon", "AceConsole-3.0", "AceEvent-3.0")

function MyAddon:OnInitialize()
    -- Called when the addon is loaded (ADDON_LOADED)
    self:Print("MyAddon Initialized")
end

function MyAddon:OnEnable()
    -- Called when the addon is enabled (PLAYER_LOGIN)
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
end

function MyAddon:OnDisable()
    -- Called when the addon is disabled
end
```

## Modules
AceAddon supports modules.
```lua
local MyModule = MyAddon:NewModule("MyModule", "AceEvent-3.0")
function MyModule:OnEnable() ... end
```
