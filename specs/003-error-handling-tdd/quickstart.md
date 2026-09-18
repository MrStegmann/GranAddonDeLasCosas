# Quickstart & Verification Guide: Error Handling & TDD Integration

## Setup & Execution Instructions

### 1. Running Unit Tests Standalone
Execute the test runner script from powershell or lua CLI:
```powershell
lua tests/run_tests.lua
```

### 2. In-Game Verification Scenarios

#### Scenario 1: TRP3 Integration Resilience
- **Action**: Disable Total RP 3 or invoke `/run GAC:GetActiveTRP3ProfileRace()` in console when TRP3 is not loaded.
- **Expected Outcome**: Method safely returns fallback value without throwing Lua runtime errors.

#### Scenario 2: Network Receiver Protection
- **Action**: Simulate corrupted/malformed network payload: `/run GAC:OnAddonMessageReceived("GAC_PREFIX", "INVALID;;PAYLOAD", "PARTY", "Sender")`.
- **Expected Outcome**: `Receiver.lua` safe call catches parsing issue cleanly and logs warning message without breaking channel communication.

#### Scenario 3: Domain Math Test Suite Execution
- **Action**: Run test suite for `LevelTable.lua`, `Armor.lua`, `Weapons.lua`, and `Helpers.lua`.
- **Expected Outcome**: 100% of test assertions pass across all level categories, equipment stat formulas, and string helpers.
