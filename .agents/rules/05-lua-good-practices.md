---
trigger: always_on
---

---
description: Code quality, memory hygiene, formatting standards, and domain entity schemas for all Lua files
globs: src/**/*.lua
---

# 05 - Lua Good Practices & Code Hygiene

## 1. Scope & Variable Hygiene
* **Strict Scoping:** All variables, local functions, and helper modules MUST be explicitly declared with `local`. NEVER declare implicit globals.
* **Global Scope Isolation:** Do NOT mutate global environments (`_G`) or third-party tables. Use namespace tables or isolated module returns.
* **Unused Variables:** Prefix unused function parameters with an underscore (`_` or `_event`).

## 2. WoW Lua Performance & Memory Management
* **Avoid GC Allocation in Loops:** Do NOT create throwaway tables (`{}`) or perform string concatenations inside high-frequency execution loops or frame event listeners. Reuse static or recycled buffers instead.
* **Defensive Nil-Guarding:** Always guard deeply nested table paths before accessing properties (`if sheet and sheet.attributes and sheet.attributes.strength then ...`).
* **Table Wiping:** Prefer `table.wipe(tbl)` or recycling tables over re-instantiating new tables.

## 3. Naming & Style Conventions
* **Variables & Functions:** Use `snake_case` (e.g., `calculate_derived_stats`, `player_guid`).
* **Modules & UI Classes:** Use `PascalCase` (e.g., `Character`, `CombatEngine`).
* **Constants:** Use `UPPER_SNAKE_CASE` (e.g., `MAX_ACTION_POINTS`, `DEFAULT_CACHE_TTL`).
* **Explicit Returns:** Modules must explicitly return their local table interface at the end of the file.

## 4. Domain Entity & Model Data Integrity
To enforce type safety and prevent state corruption from un-typed Lua tables, disk stores (`SavedVariablesPerCharacter`), or network payloads:
* **Schema Definitions:** Complex models (e.g., `Character`, `Item`, `Combatant`) MUST define a local static schema containing expected field keys, default fallback values, and types (`string`, `number`, `boolean`, `table`).
* **Factory Constructors:** Models MUST export a factory function (e.g., `Model.create(raw_data)`) that validates incoming raw data against the schema, repairs missing or invalid fields, and enforces value boundaries (e.g., `min`/`max` ranges) before returning the entity.
* **No Direct Property Mutation:** State changes on complex models MUST occur through explicit domain mutator functions (e.g., `Character.add_attribute_point(char, stat_name, amount)`) that validate parameters prior to assignment.
* **Avoid Metatable Proxy Overuse:** Do NOT use heavy `__newindex` or `__index` metatable traps for property enforcement due to garbage collection overhead in WoW Lua. Prefer clean table factory sanitization.