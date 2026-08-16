# AceSerializer-3.0

Provides robust serialization of Lua tables into strings, and deserialization back into tables. Crucial for sending complex data over addon communication channels.

## Usage
```lua
local MyAddon = LibStub("AceAddon-3.0"):NewAddon("MyAddon", "AceSerializer-3.0")

function MyAddon:Test()
    local myData = {
        name = "Test",
        values = {1, 2, 3},
        active = true
    }
    
    -- Serialize
    local serializedStr = self:Serialize(myData)
    
    -- Deserialize
    local success, deserializedData = self:Deserialize(serializedStr)
    
    if success then
        print(deserializedData.name) -- "Test"
    else
        print("Failed to deserialize:", deserializedData) -- Error message
    end
end
```
