---
name: callbackhandler-event-dispatching
description: Embed observable event registration and callback dispatching mechanisms into custom objects. Use when you are creating custom event emitters, internal pub/sub buses, or dispatching decoupled domain callbacks.
---

# Skill: CallbackHandler Event Dispatching

## Objective
Embed standardized event registration (`RegisterCallback`, `UnregisterCallback`, `Fire`) into custom domain models or adapters using `CallbackHandler-1.0`.

## Documented Inputs
- **`targetObject`** (table): The target table to embed callback registration methods into.
- **`eventName`** (string): The event key being registered or dispatched.
- **`callbackFunc`** (function or string): Function reference or method name on target object.

## Explicit and Verifiable Acceptance Criteria
- [ ] Embeds `RegisterCallback`, `UnregisterCallback`, and `UnregisterAllCallbacks` methods on the target table.
- [ ] Invoking `Fire(eventName, ...)` executes all registered callback functions with exact arguments.
- [ ] Prevents memory leaks by cleanly supporting callback unregistration.

## How to Use & Examples

### Example: Creating an Observable Domain Bus
```lua
local CallbackHandler = LibStub("CallbackHandler-1.0")

local EventBus = {}
EventBus.callbacks = CallbackHandler:New(EventBus)

-- Registering a callback listener
EventBus.RegisterCallback(self, "CHARACTER_STATS_UPDATED", function(event, characterData)
    print("Character stats changed for:", characterData.fullname)
end)

-- Dispatching an event trigger
EventBus.callbacks:Fire("CHARACTER_STATS_UPDATED", updatedCharacter)
```
