---
name: aceevent-decoupled-events
description: Register and handle WoW engine events without raw frame script listeners. Use when you are implementing event adapters (src/main/adapters/events/) to listen for WoW client signals like CHAT_MSG_ADDON or PLAYER_ENTERING_WORLD.
---

# Skill: AceEvent Decoupled Events

## Objective
Register WoW client engine event listeners safely using `AceEvent-3.0`, routing signals into adapters without creating frame event scripts or leaking raw Blizzard parameters into domain models.

## Documented Inputs
- **`eventName`** (string): The Blizzard engine event (e.g. `"PLAYER_ENTERING_WORLD"`, `"CHAT_MSG_ADDON"`).
- **`handlerMethod`** (function or string): Function reference or method name on target object.

## Explicit and Verifiable Acceptance Criteria
- [ ] Listens to client events without creating raw `CreateFrame("Frame")` objects.
- [ ] Unregisters event listeners cleanly via `UnregisterEvent(eventName)`.
- [ ] Safely processes payload parameters within adapter boundaries.

## How to Use & Examples

### Example: Registering WoW Client Events in an Adapter
```lua
local AceEvent = LibStub("AceEvent-3.0")
local EventAdapter = {}
AceEvent:Embed(EventAdapter)

function EventAdapter:Initialize()
    EventAdapter:RegisterEvent("CHAT_MSG_ADDON", "OnAddonMessage")
    EventAdapter:RegisterEvent("PLAYER_LOGOUT", "OnPlayerLogout")
end

function EventAdapter:OnAddonMessage(event, prefix, message, channel, sender)
    if prefix ~= "GAC_DEV_P2P" then return end
    -- Route message to P2P network adapter
end

function EventAdapter:OnPlayerLogout(event)
    -- Flush pending state to SavedVariables
end
```
