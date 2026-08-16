# AceConsole-3.0

Provides chat command registration and formatted printing.

## Usage
```lua
local MyAddon = LibStub("AceAddon-3.0"):NewAddon("MyAddon", "AceConsole-3.0")

function MyAddon:OnInitialize()
    -- Register a slash command: /myaddon or /ma
    self:RegisterChatCommand("myaddon", "MySlashProcessor")
    self:RegisterChatCommand("ma", "MySlashProcessor")
end

function MyAddon:MySlashProcessor(input)
    if input == "config" then
        self:Print("Opening config...")
    else
        self:Print("Unknown command.")
        self:Printf("You entered: %s", input)
    end
end
```
