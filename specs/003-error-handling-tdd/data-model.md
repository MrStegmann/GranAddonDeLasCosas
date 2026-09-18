# Data Model & Interface Contracts: Error Handling & TDD Integration

## 1. SafeCall Core Contract

### Function Signature
`GAC:SafeCall(fn, ...)` -> `boolean (success), ... (results)`

### Contract Behavior
- **Inputs**: `fn` (function reference), `...` (variadic arguments passed to `fn`)
- **Execution**: Invokes `pcall(fn, ...)`
- **Success Case**: Returns `true`, followed by all return values of `fn`
- **Error Case**: Returns `false`, logs diagnostic error message via `GAC:Print` or debug output without interrupting frame execution or UI events.

---

## 2. Tested Domain Entities & Data Contracts

### Level Data Contract (`LevelTable.lua`)
- **Input**: `category` ("noob", "normal", "elite", "boss"), `level` (integer 1-60)
- **Output Entry Schema**:
  ```lua
  {
      maxHealth = number,
      expToLevel = number | nil,
      attPoints = number,
      skillPoints = number,
      heroicPoints = number,
      maxPositiveTraits = number
  }
  ```

### Equipment Calculations Contract (`Armor.lua`, `Weapons.lua`)
- **Input**: Item keys, stats, equipment slots
- **Calculations**: Physical defense, magic resistance, weapon damage multipliers, bonus attribute scaling.

### Helper Utility Contract (`Helpers.lua`)
- **String Parsing**: Roll expression regex validation (e.g. `1d20+5`), display name extraction, character formatting.
