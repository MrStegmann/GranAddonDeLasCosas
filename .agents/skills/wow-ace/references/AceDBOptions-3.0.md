# AceDBOptions-3.0

A helper library that generates an `AceConfig-3.0` options table for managing `AceDB-3.0` profiles (creating, copying, resetting, deleting profiles).

## Usage
Normally paired with `AceConfig-3.0` and `AceConfigDialog-3.0` (even if not explicitly listed in `libs/`, Ace3 addons often use them together).

```lua
local MyAddon = LibStub("AceAddon-3.0"):NewAddon("MyAddon")

function MyAddon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("MyAddonDB", defaults, true)
    
    -- Generate the options table for profile management
    local profilesTable = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
    
    -- If using AceConfig, you would add it to your main options table:
    -- myOptions.args.profiles = profilesTable
end
```
