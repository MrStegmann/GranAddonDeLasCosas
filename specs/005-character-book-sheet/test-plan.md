# Test Plan: CharacterBook UI

## Unit & Integration Scenarios

### Scenario 1: TRP3 Integration
- **Action**: Open the CharacterBook menu.
- **Expected Result**: Character Name and Class accurately reflect the current TRP3 profile data. 
- **Fallback**: If TRP3 is disabled, it displays standard WoW character Name and Class.

### Scenario 2: Dynamic Category & Level Logic
- **Action**: Open the Basic Info tab.
- **Expected Result**: Category dropdown is populated with `noob`, `normal`, `elite`, `boss`.
- **Action**: Select `elite`.
- **Expected Result**: Level dropdown populates with levels 1 through 10.
- **Action**: Select `boss`.
- **Expected Result**: Level dropdown clears its previous selection and populates with boss levels (1 through 3).

### Scenario 3: Single Race Selection
- **Action**: Select a single race (e.g., "Human").
- **Expected Result**: The UI displays the default advantages and disadvantages of the Human race as read-only text elements.

### Scenario 4: Dual Race (Half-Race) Selection
- **Action**: Select two races (e.g., "Human" and "Night Elf").
- **Expected Result**: A trait selection UI appears.
- **Action**: Attempt to save without selecting exactly +3 advantages and -3 disadvantages.
- **Expected Result**: Save is blocked, user is warned.
- **Action**: Select exactly +3 advantages and -3 disadvantages.
- **Expected Result**: Save succeeds, traits are persisted.

### Scenario 5: Worgen Curse Tooltip
- **Action**: Hover over the "Worgen Curse" checkbox.
- **Expected Result**: A GameTooltip appears showing the specific stat modifications tied to the curse.
