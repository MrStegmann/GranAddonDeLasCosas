---
name: libstub-version-management
description: Safely retrieve and instantiate versioned library references in WoW addon code. Use when you are importing or referencing shared libraries (Ace3, LibDataBroker, LibDeflate) or embedding library stubs.
---

# Skill: LibStub Version Management

## Objective
Safely fetch, instantiate, and verify shared library instances using `LibStub` in WoW Lua code without raising global errors if a library is missing or outdated.

## Documented Inputs
- **`majorVersion`** (string): The major identifier of the target library (e.g. `"AceDB-3.0"`, `"LibDeflate"`).
- **`silent`** (optional boolean): If `true`, returns `nil` when the library is not registered instead of raising a Lua error.

## Explicit and Verifiable Acceptance Criteria
- [ ] Returns the exact target library table instance when registered.
- [ ] Returns `nil` cleanly without throwing a runtime error when `silent = true` and the library is missing.
- [ ] Zero creation of duplicate global variables; uses local library references.

## How to Use & Examples

### Example: Safely Retrieving a Library
```lua
-- Retrieve LibStub securely
local LibStub = _G.LibStub
if not LibStub then return end

-- Fetch AceDB-3.0 with silent fallback check
local AceDB = LibStub("AceDB-3.0", true)
if not AceDB then
    print("[GAC_DEV] Error: AceDB-3.0 library missing.")
    return
end
```
