# Research & Design Decisions: Error Handling & TDD Integration

## 1. Centralized SafeCall Architecture

### Decision
Deprecate and remove local `safeCall` in `src/Communication/TRP3Bridge.lua`. Standardize all error-trapped function executions to use `GAC:SafeCall(func, ...)` defined in `src/Utils/Helpers.lua`.

### Rationale
- `GAC:SafeCall` provides a centralized error handling mechanism wrapped with `pcall` and standard `GAC` diagnostic logging.
- Having a duplicate local `safeCall` in `TRP3Bridge.lua` violates DRY and Constitution Principle IV.
- Wrapping `Receiver.lua` packet handling with `GAC:SafeCall` guarantees bad/malformed network data packets fail silently or log cleanly without throwing unhandled Lua errors in the player's client interface.

### Alternatives Considered
- *Raw `pcall` / `xpcall` in every file*: Rejected due to code duplication and inconsistent error reporting.
- *Throwing errors up to WoW default error handler*: Rejected because unhandled Lua UI errors disrupt gameplay and break user experience.

---

## 2. Unit Testing Strategy for WoW RPG Math Data

### Decision
Establish a lightweight, zero-dependency Lua unit test framework in `tests/` capable of testing `LevelTable.lua`, `Armor.lua`, `Weapons.lua`, and `Helpers.lua`.

### Rationale
- `LevelTable.lua`, `Armor.lua`, `Weapons.lua`, and `Helpers.lua` contain pure data structures and mathematical calculations with minimal reliance on WoW frame APIs.
- Setting up isolated test runners allows rapid verification of stat formulas, exp thresholds, positive/negative traits, armor/weapon bonus calculations, and string helpers.
- Satisfies Constitution Principle IV (TDD & Safe API Calling).

### Alternatives Considered
- *In-game slash command test suite only*: Useful for integration tests, but requires loading the full WoW client. Standalone unit tests provide instant feedback during development.
