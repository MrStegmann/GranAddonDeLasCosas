---
name: acecomm-p2p-transport
description: Transmit and receive serialized P2P messages over chat channels with automatic packet chunking. Use when you are sending or receiving remote P2P character sheet updates, combat action deltas, or version check pings between players.
---

# Skill: AceComm P2P Transport

## Objective
Send and receive structured P2P message payloads across players using `AceComm-3.0`, handling prefix registration, channel target selection (`WHISPER`, `PARTY`, `RAID`), and payload chunking.

## Documented Inputs
- **`prefix`** (string): Unique registered addon message prefix (e.g. `"GAC_DEV_P2P"`).
- **`textPayload`** (string): Serialized or compressed string message.
- **`distribution`** (string): Target channel (`"PARTY"`, `"RAID"`, `"GUILD"`, `"WHISPER"`).
- **`targetPlayer`** (optional string): Target character name when `distribution = "WHISPER"`.

## Explicit and Verifiable Acceptance Criteria
- [ ] Message payloads exceeding 255 bytes split and reassemble transparently across recipients.
- [ ] Payload prefixes register once per session without throwing duplicate prefix warnings.
- [ ] Handlers unpack target payloads cleanly and isolate invalid channel broadcasts.

## How to Use & Examples

### Example: P2P Network Adapter Implementation
```lua
local AceComm = LibStub("AceComm-3.0")
local P2PAdapter = {}
AceComm:Embed(P2PAdapter)

function P2PAdapter:Initialize()
    P2PAdapter:RegisterComm("GAC_DEV_P2P", "OnCommReceived")
end

function P2PAdapter:SendPayload(serializedData, targetPlayer)
    if targetPlayer then
        P2PAdapter:SendCommMessage("GAC_DEV_P2P", serializedData, "WHISPER", targetPlayer)
    else
        P2PAdapter:SendCommMessage("GAC_DEV_P2P", serializedData, "PARTY")
    end
end

function P2PAdapter:OnCommReceived(prefix, message, distribution, sender)
    -- Received P2P message payload
    print("Received P2P payload from:", sender)
end
```
