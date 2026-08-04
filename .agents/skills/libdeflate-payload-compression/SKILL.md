---
name: libdeflate-payload-compression
description: Compress and decompress Lua table strings before transmitting over chat message channels. Use when you are compressing large P2P network payloads (character sheets, spell catalogs, combat logs) to fit within bandwidth constraints.
---

# Skill: LibDeflate Payload Compression

## Objective
Compress string data into compact binary payloads (and encode for WoW addon channel safety) using `LibDeflate` to minimize P2P network transmission overhead.

## Documented Inputs
- **`rawString`** (string): Uncompressed text or serialized string (e.g. JSON string or AceSerializer string).
- **`compressedBlob`** (string): Compressed and WoW channel-encoded payload.

## Explicit and Verifiable Acceptance Criteria
- [ ] `CompressDeflate(rawString)` reduces string size by 50%-80%.
- [ ] `EncodeForWoWAddonChannel(compressed)` produces a string safe for transmission over `SendAddonMessage` without character corruption.
- [ ] `DecompressDeflate(DecodeForWoWAddonChannel(blob))` reconstructs the exact original uncompressed string.

## How to Use & Examples

### Example: Compressing & Decompressing Network Payloads
```lua
local LibDeflate = LibStub("LibDeflate")
local AceSerializer = LibStub("AceSerializer-3.0")

local largeData = { fullname = "Einarr", spells = { "fireExplosion", "arcaneShield" }, stats = {} }
local serialized = AceSerializer:Serialize(largeData)

-- Compression & Encoding for Network Send
local compressed = LibDeflate:CompressDeflate(serialized)
local printablePayload = LibDeflate:EncodeForWoWAddonChannel(compressed)

-- Receiving & Decompressing Payload
local decodedCompressed = LibDeflate:DecodeForWoWAddonChannel(printablePayload)
local originalSerialized = LibDeflate:DecompressDeflate(decodedCompressed)
local success, originalData = AceSerializer:Deserialize(originalSerialized)

if success then
    print("Decompressed character sheet:", originalData.fullname)
end
```
