# AceDB-3.0

Manages SavedVariables. It provides a robust profiling system allowing users to have different settings per character, realm, or globally, and easily switch between them.

## Usage
Ensure your addon's `.toc` has `## SavedVariables: MyAddonDB`.

```lua
local MyAddon = LibStub("AceAddon-3.0"):NewAddon("MyAddon")

local defaults = {
    profile = {
        setting1 = true,
        setting2 = "default_value"
    },
    global = {
        minimapIcon = { hide = false }
    }
}

function MyAddon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("MyAddonDB", defaults, true)
    -- Access data: self.db.profile.setting1
    
    -- Handle profile changes
    self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
end

function MyAddon:RefreshConfig()
    -- Apply settings when profile changes
end
```
