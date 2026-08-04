---
name: aceconsole-slash-commands
description: Register user slash commands and format chat frame output. Use when you are creating new slash commands (e.g. /gac, /characterbook, /cb) or printing formatted chat messages to the user.
---

# Skill: AceConsole Slash Commands

## Objective
Register user slash commands (e.g. `/gac`) and format chat output using `AceConsole-3.0` without writing manual `SLASH_` globals or custom chat frame printers.

## Documented Inputs
- **`commandName`** (string): Primary command keyword (e.g. `"gac"`).
- **`commandAliases`** (optional strings/table): Additional alias keywords (e.g. `"cb"`, `"characterbook"`).
- **`handlerFunc`** (function or string): Function reference or method name on target object.

## Explicit and Verifiable Acceptance Criteria
- [ ] Slash command executes callback function when typed in chat.
- [ ] Command arguments (e.g. `/gac toggle`) parse correctly into string arguments.
- [ ] Print statements prefix messages with formatted addon header tags.

## How to Use & Examples

### Example: Registering Slash Commands
```lua
local AceConsole = LibStub("AceConsole-3.0")
local CommandAdapter = {}
AceConsole:Embed(CommandAdapter)

function CommandAdapter:RegisterCommands()
    CommandAdapter:RegisterChatCommand("gac", "HandleSlashCommand")
    CommandAdapter:RegisterChatCommand("characterbook", "HandleSlashCommand")
end

function CommandAdapter:HandleSlashCommand(input)
    local arg1, arg2 = CommandAdapter:GetArgs(input, 2)
    if arg1 == "toggle" or arg1 == "" then
        -- Toggle main Character Book UI
        print("|cff33ff99[GAC_DEV]|r Toggling Character Book UI...")
    end
end
```
