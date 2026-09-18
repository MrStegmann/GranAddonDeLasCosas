# Rule: Scoped Module Namespace Isolation for Unified AddOn Suites

## Context & Architecture
When consolidating multiple World of Warcraft addons into a unified suite sharing a single `.toc` file, all loaded Lua scripts receive the exact same private table via `...` (`addonTable` / `addon`). To prevent namespace pollution, accidental overrides, and state collision between distinct modules, direct attachment of module-specific tables or state to the root `addon` table is strictly forbidden.

## Mandatory Rules

1. **Sub-namespace Declaration:**
   - Every file belonging to a submodule MUST declare and operate within its dedicated submodule namespace attached to `addon`.
   - Never attach utility tables, handlers, UI frames, or models directly to the root `addon` (e.g., forbidden: `addon.Utils = {}`, `addon.Events = {}`, `addon.Storage = {}`).
   - All submodule declarations must be safely initialized with `or {}`:
     ```lua
     local addonName, addon = ...
     addon.<MODULE_KEY> = addon.<MODULE_KEY> or {}
     local <ModuleAlias> = addon.<MODULE_KEY>
     ```

2. **File Header Standard Template:**
   Every Lua file within a module MUST start with the following pattern:
   ```lua
   local addonName, addon = ...
   addon.<MODULE_KEY> = addon.<MODULE_KEY> or {}
   local <ModuleAlias> = addon.<MODULE_KEY>

   -- Sub-feature registration strictly inside the module namespace
   <ModuleAlias>.<Feature> = <ModuleAlias>.<Feature> or {}
   local <Feature> = <ModuleAlias>.<Feature>