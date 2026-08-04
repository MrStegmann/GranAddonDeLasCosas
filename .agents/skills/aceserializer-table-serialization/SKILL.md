---
name: aceserializer-table-serialization
description: Serialize complex Lua tables into portable string payloads and deserialize incoming P2P data. Use when you are encoding domain objects (character sheets, turn-based actions, dice rolls) for network transport.
---

# Skill: AceSerializer Table Serialization

## Objective
Convert complex nested Lua tables into string formats using `AceSerializer-3.0` for network transmission or disk storage, and unpack serialized strings back into tables.

## Documented Inputs
- **`inputTable`** (table): The source Lua table to serialize.
- **`serializedString`** (string): The encoded string to deserialize.

## Explicit and Verifiable Acceptance Criteria
- [ ] `Serialize(inputTable)` returns a compact string encoding all primitive and nested table properties.
- [ ] `Deserialize(serializedString)` returns `true` and the reconstructed table matching the original table.
- [ ] Returns `false` and an error description if the serialized string is corrupt or invalid.

## How to Use & Examples

### Example: Serializing & Deserializing Character Sheet Data
```lua
local AceSerializer = LibStub("AceSerializer-3.0")
local Serializer = {}
AceSerializer:Embed(Serializer)

local characterData = { fullname = "Einarr", level = 10, category = "Heroic", attributes = { strength = 5 } }

-- Encoding table to string
local encodedString = Serializer:Serialize(characterData)

-- Decoding string back to table
local success, decodedTable = Serializer:Deserialize(encodedString)
if success then
    print("Reconstructed character:", decodedTable.fullname, decodedTable.level)
else
    print("Failed to deserialize payload!")
end
```
