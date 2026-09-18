# Feature Specification: Error Handling & TDD Integration

**Feature Branch**: `003-error-handling-tdd`

**Created**: 2026-09-18

**Status**: Draft

**Input**: User description: "Under Error Handling & TDD Integration, the work focuses on centralizing safe execution and establishing comprehensive test coverage. Task 3.1 requires enforcing a central `GAC:SafeCall` by removing duplicate `safeCall` implementations inside `TRP3Bridge.lua` while wrapping external TRP3 API calls, network handlers in `Receiver.lua`, and risky UI handlers with `GAC:SafeCall`. Task 3.2 establishes a unit test suite dedicated to `LevelTable.lua`, `Armor.lua`, `Weapons.lua`, and `Helpers.lua` to guarantee that all RPG math calculations have full test backing."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Centralized Safe Function Calls & Error Isolation (Priority: P1)

As a World of Warcraft player using the GAC addon, I want external API calls (e.g., Total RP 3 integration), network packet handlers, and UI event callbacks to execute safely inside error-isolated boundaries so that unexpected runtime errors or third-party addon failures do not taint global state or produce unhandled Lua script error popups.

**Why this priority**: High stability and resilience prevent addon crashes during gameplay, satisfying core project constitution rules regarding robust error handling (`GAC:SafeCall`).

**Independent Test**: Can be tested by invoking TRP3 bridge methods and network receiver handlers when dependencies or payload data are malformed, ensuring errors are logged cleanly without throwing unhandled Lua errors.

**Acceptance Scenarios**:

1. **Given** TRP3 or TRP3_Extended APIs throw an error or are missing, **When** `TRP3Bridge` methods are called, **Then** `GAC:SafeCall` safely catches the exception and returns `nil` with diagnostic logging.
2. **Given** malformed or unexpected data packets arrive via addon channel, **When** `Receiver.lua` processes the incoming payload, **Then** execution is wrapped in `GAC:SafeCall` preventing UI breakages.
3. **Given** `TRP3Bridge.lua`, **When** auditing code, **Then** duplicate local `safeCall` definitions are completely removed in favor of `GAC:SafeCall`.

---

### User Story 2 - Comprehensive RPG Math Unit Testing Suite (Priority: P1)

As a developer maintaining the GAC addon, I want automated unit tests backing core data tables and helper logic (`LevelTable.lua`, `Armor.lua`, `Weapons.lua`, and `Helpers.lua`) so that stat progressions, experience thresholds, item calculations, and utility functions can be modified with zero risk of regressions.

**Why this priority**: Ensures core RPG mechanics and calculations function predictably and satisfy Constitution Principle IV (TDD & Safe API Calling).

**Independent Test**: Execute unit test suite against calculation functions (`LevelTable`, `Armor`, `Weapons`, `Helpers`) and verify 100% pass rate for normal, boundary, and edge-case inputs.

**Acceptance Scenarios**:

1. **Given** level and category parameters, **When** `LevelTable` calculations or lookups are evaluated, **Then** test suite verifies max health, attribute points, and experience requirement outputs match defined progression tables.
2. **Given** weapon and armor data, **When** stat bonuses or damage/defense ratings are computed, **Then** test suite validates mathematical correctness against expected domain rules.
3. **Given** helper utility functions in `Helpers.lua` (string parsing, roll display formatting, safe calling), **When** boundary values (e.g. nil strings, invalid roll strings) are supplied, **Then** helper functions produce correct sanitization without erroring.

---

### Edge Cases

- What happens when TRP3 is not loaded or loaded after GAC? The safe call handles missing global references without raising errors.
- What happens when a network payload is truncated or invalid type? `Receiver.lua` safe calls catch payload errors gracefully.
- How does the test suite execute when WoW frame APIs are missing? Mock minimum frame APIs or isolate pure Lua data logic so tests can execute cleanly.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST remove duplicate local `safeCall` implementations in `TRP3Bridge.lua` and route all safe calls through `GAC:SafeCall`.
- **FR-002**: System MUST wrap all external TRP3 and TRP3_Extended API invocations in `GAC:SafeCall`.
- **FR-003**: System MUST wrap incoming packet decoding and processing in `Receiver.lua` with `GAC:SafeCall`.
- **FR-004**: System MUST wrap risky UI script callbacks and event handlers with `GAC:SafeCall`.
- **FR-005**: System MUST provide automated unit tests covering `LevelTable.lua` progression logic and level data lookups.
- **FR-006**: System MUST provide automated unit tests covering `Armor.lua` and `Weapons.lua` calculations and stat queries.
- **FR-007**: System MUST provide automated unit tests covering `Helpers.lua` utility functions and roll parsing logic.

### Key Entities *(include if feature involves data)*

- **SafeCall Interface**: Standard error-trapping wrapper function (`GAC:SafeCall(func, ...)`) executing functions inside protected call wrappers.
- **RPG Math Test Suite**: Test runner and test specs validating level entries, armor/weapon stats, and helper function outputs.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Zero unhandled Lua errors occur during external TRP3 calls or corrupted network message handling.
- **SC-002**: 100% of duplicate `safeCall` definitions in `TRP3Bridge.lua` are eliminated and unified under `GAC:SafeCall`.
- **SC-003**: Unit test suite executes and passes 100% of test cases for `LevelTable.lua`, `Armor.lua`, `Weapons.lua`, and `Helpers.lua`.

## Assumptions

- `GAC:SafeCall` defined in `src/Utils/Helpers.lua` is loaded prior to dependent modules.
- Unit testing framework uses standard Lua test setup compatible with WoW environment or standalone mock environment.
