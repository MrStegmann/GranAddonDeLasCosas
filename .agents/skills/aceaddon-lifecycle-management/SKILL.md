---
name: aceaddon-lifecycle-management
description: Initialize and manage addon modules and lifecycle hooks. Use when you are creating the primary addon orchestrator, registering backend modules, or handling initialization lifecycle events (OnInitialize, OnEnable, OnDisable).
---

# Skill: AceAddon Lifecycle Management

## Objective
Instantiate and orchestrate core addon components and sub-modules using `AceAddon-3.0`, providing structured `OnInitialize` and `OnEnable` lifecycle hooks.

## Documented Inputs
- **`addonName`** (string): The identifier name of the addon (e.g. `"GAC_DEV"`).
- **`moduleName`** (string): The name of the sub-module being instantiated.
- **`embedMixins`** (optional strings): List of Ace3 mixins to embed (e.g. `"AceEvent-3.0"`, `"AceConsole-3.0"`).

## Explicit and Verifiable Acceptance Criteria
- [ ] Addon and modules initialize predictably during `ADDON_LOADED` and `PLAYER_ENTERING_WORLD`.
- [ ] Sub-modules inherit mixin functions without global namespace pollution.
- [ ] `OnInitialize` executes once before player login; `OnEnable` executes when the module activates.

## How to Use & Examples

### Example: Initializing Addon Core & Module
```lua
local AceAddon = LibStub("AceAddon-3.0")
local GAC_DEV = AceAddon:NewAddon("GAC_DEV", "AceEvent-3.0", "AceConsole-3.0")

function GAC_DEV:OnInitialize()
    -- Executed on ADDON_LOADED
    print("[GAC_DEV] Initializing core frameworks...")
end

function GAC_DEV:OnEnable()
    -- Executed when player enters world
    print("[GAC_DEV] Enabled and active.")
end

-- Creating a sub-module
local CombatModule = GAC_DEV:NewModule("CombatModule", "AceEvent-3.0")
function CombatModule:OnEnable()
    -- Module active
end
```
