# AceComm-3.0

Handles inter-addon communication using WoW's `C_ChatInfo.SendAddonMessage` and `CHAT_MSG_ADDON`. It automatically handles serialization (when paired with AceSerializer) and splitting large messages that exceed the 255 character limit.

## Usage
```lua
local MyAddon = LibStub("AceAddon-3.0"):NewAddon("MyAddon", "AceComm-3.0", "AceSerializer-3.0")

function MyAddon:OnEnable()
    self:RegisterComm("MyAddonPrefix", "OnCommReceived")
end

function MyAddon:OnCommReceived(prefix, message, distribution, sender)
    local success, data = self:Deserialize(message)
    if success then
        -- Process data
    end
end

function MyAddon:SendData(data)
    local serializedData = self:Serialize(data)
    self:SendCommMessage("MyAddonPrefix", serializedData, "GUILD")
end
```
